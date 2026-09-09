---
id: spec-srs
type: spec
status: accepted
owns: [backend/crates/crypto/src/, backend/crates/messaging-service/src/, backend/crates/common/src/rate_limit.rs, backend/proto/]
read_when: [implementing a handler, changing behaviour, changing a crypto parameter, handling an error]
tokens: 1663
supersedes: []
---

# Software Requirements Specification

**The algorithmic source of truth.** Rules, parameters, edge cases and the behaviour a
change must preserve. Shape lives in [`SAD.md`](SAD.md); rationale lives in the ADRs.

Every constant below is quoted from the code with its file. If a value here and a value in
the code disagree, **the code is right and this file is stale.**

## Invariants this specification serves

| # | Requirement |
|---|---|
| **I-1** | No payload, key, or decrypted metadata reaches a log, span, metric label, or `stdout`. |
| **I-2** | Encryption cannot be disabled — not by flag, config, or "for development". |
| **I-3** | Key agreement resists harvest-now-decrypt-later: hybrid X25519 + ML-KEM-768. |
| **I-4** | The stack is 100% self-hostable, with no third-party dependency. |

**I-2 and I-3 are not met today.** They are specified here as required behaviour and
repaired by PR-32 and PR-36…PR-40. This document states the requirement, not the state.

## Cryptographic parameters

Primitives, by usage in `crates/crypto`: X25519 (key agreement), Ed25519 (signatures),
HKDF-SHA256 (derivation), AES-256-GCM (message AEAD), ChaCha20-Poly1305 (MLS AEAD and
FFI), ML-KEM-768 (post-quantum KEM).

| Parameter | Value | Source |
|---|---|---|
| `MAX_SKIP` | 1000 | `double_ratchet.rs:20` |
| `MIN_PADDED_LENGTH` | 32 bytes | `padding.rs:13` |
| `MAX_MESSAGE_LENGTH` | 16 MiB | `padding.rs:16` |
| `MLKEM_PUBLIC_KEY_SIZE` | 1184 bytes | `pqxdh.rs:29` |
| `MLKEM_CIPHERTEXT_SIZE` | 1088 bytes | `pqxdh.rs:33` |
| `MLKEM_SHARED_SECRET_SIZE` | 32 bytes | `pqxdh.rs:37` |
| MLS ciphersuite | `MLS_128_DHKEMX25519_CHACHA20POLY1305_SHA256_Ed25519` | `mls.rs:27` |
| HKDF labels | `guardyn-root-key`, `guardyn-chain-key`, `guardyn-message-key` | `double_ratchet.rs:17-19` |
| Sealed-sender label | `Guardyn-SealedSender-v1` | `sealed_sender.rs:39` |

**MLS uses ChaCha20-Poly1305, not AES-256-GCM**, because OpenMLS 0.6 offers no AES-256-GCM
ciphersuite. Both carry a 256-bit key; this is a library constraint, not a downgrade, and
it is recorded here so nobody "fixes" it.

## Session establishment (X3DH)

1. The initiator fetches the responder's `KeyBundle`: identity key, signed pre-key with its
   signature, and one `OneTimePreKey` if any remain.
2. The signed pre-key signature **must** verify against the identity key. Failure aborts —
   never downgrade to an unsigned exchange.
3. Three or four DH operations produce the shared secret. A consumed one-time pre-key is
   never reissued.
4. Under **I-3** the same handshake also encapsulates to an ML-KEM-768 public key, and both
   secrets feed the KDF. Classical strength is the floor, never the ceiling.

**Edge cases.** No one-time pre-keys left: proceed with the three-DH variant — never refuse,
never fall back to an unauthenticated exchange. Bundle from an unknown device: `NOT_FOUND`.
A replayed prekey message fails because the one-time key is already consumed.

## Message encryption (Double Ratchet)

0. **Both sides seed the ratchet from the responder's signed pre-key.** The initiator
   ratchets against the signed pre-key it just ran X3DH against; the responder must supply
   the matching secret rather than generating a fresh key. This is not an implementation
   detail - if the responder invents its own key the two sides derive different root and
   chain keys, and every AEAD tag check fails while both sides appear healthy.
1. Plaintext is padded with PADMÉ before encryption, so ciphertext length leaks at most
   about 10% of the plaintext length.
2. A message key is derived per message and discarded after use: compromise of one key must
   not expose its neighbours.
3. Out-of-order delivery is handled by storing skipped message keys, **bounded by
   `MAX_SKIP` = 1000**. Beyond that the message is rejected, rather than letting an
   attacker-chosen counter drive unbounded memory growth.
4. Every parser reachable from attacker-controlled bytes — prekey message, ratchet header,
   sealed-sender envelope, PADMÉ unpad — requires a fuzz target (PR-33).
5. **The header is bound into the AEAD associated data**: `AD = AD_caller || header`, as the
   Signal specification requires. `dh_public_key`, `previous_chain_length` and
   `message_number` are therefore covered by the tag and cannot be rewritten in flight.

**Edge cases.** A padded length below `MIN_PADDED_LENGTH` (32) is invalid. Plaintext above
`MAX_MESSAGE_LENGTH` (16 MiB) is rejected before encryption. A header claiming a counter
more than `MAX_SKIP` ahead is rejected, not accommodated.

**Wire format.** A serialized message is
`version(1) || header_len:u32 BE || header(40) || nonce(12) || ciphertext || tag(16)`. The
version byte is 1. The previous format had no version byte and began with the high byte of
`header_len`, always `0x00` for a 40-byte header, so a leading `0x01` is unambiguous against
anything the old format could emit: an un-upgraded peer gets an explicit version error rather
than an opaque authentication failure.

Binding the header changed the ciphertext format non-additively. Deployed clients that predate
it cannot decrypt, and this was accepted deliberately at gate G3 rather than carried into
Phase 4, where #105 and #106 would have forced the clients to re-parse a second time.

**Known gaps.** Skipped-key derivation advances the receiving chain before the tag is verified,
so a forged header can poison a session (#106). Binding the header reduces that exposure - the
counter driving the loop is now authenticated - but does not remove it: a replayed genuine
header still drives `skip_message_keys`, and `dh_ratchet_receive` likewise mutates
`dh_self`, `root_key` and both chain keys before any tag is checked.

## Groups (MLS)

Group encryption is OpenMLS 0.6, not sender keys. Group state is persisted to TiKV and
**must round-trip**: serialize, store, load, decrypt. Groups are created under the
caller-supplied `GroupId`, never a random one. Adding a member must not break decryption for
members already in the group.

A member **cannot** decrypt a message it sent itself: the sender's application ratchet is
consumed on encrypt and OpenMLS answers `SecretTreeError(RatchetTypeError)`. That is correct
MLS behaviour, not a defect.

The round-trip above is not implemented — `serialize_state` exports a 32-byte exporter secret
rather than the group, with no deserialization counterpart, and no two-party exchange is
possible until the KeyPackage and provider lifetimes are fixed. PR-31 owns the repair.

## Errors

`ErrorCode` in `common.proto` is the complete taxonomy — exactly nine variants:

`UNKNOWN` · `INVALID_REQUEST` · `UNAUTHORIZED` · `FORBIDDEN` · `NOT_FOUND` · `CONFLICT` ·
`INTERNAL_ERROR` · `SERVICE_UNAVAILABLE` · `RATE_LIMITED`

Never invent a variant, and never map an unexpected condition to `UNKNOWN` to avoid
choosing one. `INTERNAL_ERROR` must never carry a message that leaks state — no key
material, no payload, no PII.

## Rate limiting

Sliding window per endpoint (`common/src/rate_limit.rs`). Three presets:

| Preset | max_requests | window | burst |
|---|---|---|---|
| `strict` | 5 | 60 s | 2 |
| `standard` | 60 | 60 s | 10 |
| `relaxed` | 100 | 60 s | 10 |

Exceeding a limit returns `RATE_LIMITED`. **The limiter is process-local**, so the
effective limit is the preset multiplied by the replica count. Until PR-41 resolves this,
either the state is shared or the single-replica constraint is documented and enforced — a
limit that silently scales with replicas is not a limit.

Blocking an address must not log the address (**I-1**). The block and unblock paths
therefore log `ip_fingerprint(&ip)` — a 16-hex-digit hash under a salt generated once per
process — instead of the address itself. An operator can still tell that the *same* address
was blocked repeatedly, which is the operational need; the log carries no address.

Because the salt lives only in process memory, fingerprints do not correlate across restarts
or between replicas, and cannot be matched against a precomputed table. They are **not** a
cryptographic commitment: anyone able to read process memory recovers the salt and can confirm
a guessed address. That is the right bar for log hygiene, not for defence against an attacker
already inside the process.

`RateLimitError::IpBlocked` still carries the address as a field for the caller to act on, but
its `Display` must not render it — `Display` is what reaches a log.

## Logging

Structured JSON, initialised **only** through
`guardyn_common::observability::init_tracing`. Constructing a `tracing_subscriber`
directly bypasses the redaction layer and is forbidden.

Never emitted: plaintext or ciphertext; identity keys, pre-keys, ratchet state, MLS
secrets, ML-KEM private keys; tokens, passwords, password hashes, session secrets; email,
phone number, IP address, precise location. `user_id` and `device_id` are correlatable
metadata — log them only when an operation needs them, never at `info` on a hot path.

## Testing requirements

Unit tests are insufficient for E2EE code. Cryptographic modules require property-based
tests and fuzz targets on every attacker-reachable parser.

Required properties: ratchet round-trip up to `MAX_SKIP`; PADMÉ `unpad(pad(m)) == m` for
32 B … 16 MiB; X3DH symmetry, both sides deriving the same secret.

**Status.** `crypto/src/proptests.rs` (PR-34) covers twelve properties: the three required
above, plus PADMÉ length monotonicity and its 12% overhead bound, `unpad_message` not panicking
on arbitrary bytes, X3DH identity-key export/import, signature binding, AEAD rejection of
mismatched associated data, single-bit ciphertext tampering, and out-of-order delivery. Each was
negative-tested by inversion — a property suite that passes vacuously is worse than none, because
it reads as coverage.

Not yet covered: the ratchet round-trip is exercised over short chains rather than up to
`MAX_SKIP`, and the sealed-sender envelope parser has no property test. Fuzz targets are PR-33.

**Fuzzing.** `crypto/fuzz/` (PR-33a) holds the `cargo-fuzz` scaffold and the PADMÉ unpad
target. The crate sits outside the backend workspace on purpose: `cargo-fuzz` needs
`-Z sanitizer=address`, and `rust-toolchain.toml` pins 1.98.1 for everything else. Its nightly
is pinned to a date rather than the `nightly` channel, for the reason that file gives — a gate
that can fail without a change to this repository is not a signal.

All four parsers §4 names now have a target: `padme_unpad`, `ratchet_message`,
`sealed_sender_envelope` and `x3dh_prekey_message` (PR-33b). `fuzz.yml` compiles them on every
crypto pull request and runs them nightly. Operating instructions are in
[RUNBOOK.md](../ops/RUNBOOK.md).

`ratchet_message` targets `EncryptedMessage::from_bytes` rather than `MessageHeader::from_bytes`:
the header parser is private, and the public entry point is both the path that reaches it and the
one that reads a 32-bit length from attacker bytes and slices on it.

A bug fix lands with a regression test that fails before the fix. **Never weaken or delete
a test to make CI pass.**
