---
id: adr-0005
type: adr
status: accepted
owns: [backend/crates/crypto/src/pqxdh.rs, backend/proto/common.proto]
read_when: [touching crypto, changing key bundles, enabling the pq feature]
tokens: 600
supersedes: []
---

# ADR-0005 · Hybrid PQXDH (X25519 + ML-KEM-768)

## Status

`accepted` as the target. **Not met by the running system** — the gap is documented below
rather than hidden, because an ADR that reads as done when it is not is a lie with a
version number.

## Context

**I-3** exists because of harvest-now-decrypt-later: traffic captured today can be stored
until a cryptographically relevant quantum computer exists. For a messaging product whose
value is confidentiality over decades, classical-only key agreement is a dated liability,
not a present one.

Pure post-quantum is the wrong answer — ML-KEM is younger than X25519 and its long-term
cryptanalysis is thinner. Hybrid gives the maximum of both.

## Decision

Key agreement is hybrid: X25519 and ML-KEM-768, both secrets feeding the KDF. Classical
strength is the floor, never the ceiling. Sizes are 1184-byte public key, 1088-byte
ciphertext, 32-byte shared secret.

## Consequences

A break of either primitive alone leaves the session secure. Key bundles get materially
larger, and every wire structure carrying key material must have room for an ML-KEM key.

Both private halves are unprintable. `FfiHybridKeyBundle` implements `Debug` by hand,
wrapping `x25519_private` and `ml_kem_private` in `Redacted<T>` while leaving the
encapsulation and public keys visible; the decapsulation key is the one value whose
disclosure retroactively breaks the post-quantum half, so it must not be reachable through
a `{:?}` (see [ADR-0007](ADR-0007-zero-knowledge-logging.md)).

**Identity keys are Ed25519 and must be converted before any Diffie-Hellman.** The bundle
stores an Ed25519 identity key because it also signs the pre-keys; the classical half of the
agreement needs the Curve25519 form. The public side maps through `to_montgomery()`, the
secret side through SHA-512 then X25519 clamping. PQXDH shares one implementation of both
with X3DH (`x3dh.rs`) rather than carrying its own — an Ed25519 verifying key is not the
X25519 public point of the same seed, and treating it as one produces two sides that silently
derive different secrets.

**The gap, narrowed by three steps.** PR-36 added `ml_kem_public` (tag 6) and
`ml_kem_public_signature` (tag 7) to `common.KeyBundle`, so the wire contract can carry the
material and `PQ-WIRE` passes. PR-37 gave `db::KeyBundle` its ML-KEM columns, so `auth-service`
persists and serves what it is handed instead of dropping it. PR-38 put `pq` in this crate's
`default` set, so the code is compiled into the services that depend on it and `PQ-DEFAULT`
passes.

**The client half is complete on the desktop.** PR-39a made it generate, persist and publish an
ML-KEM pre-key; PR-39c gave it the responder; PR-39b gave it the initiator, so a desktop now
encapsulates to a peer's `ml_kem_public` and sets the `0x02` flag on the prekey message. Two
desktops agree a hybrid secret end to end. What remains is `client-mobile`, whose proto is still
forked at tag 5 (PR-98), and the fuzz and bench coverage of PR-40. **I-3 is met when PR-40
closes, not here** — an unfuzzed parser on a path reachable from a peer's bundle is not a met
invariant.

**The bundle crosses the IPC boundary, so the pair can be broken by omission.** The desktop
initiator receives its peer bundle back from the frontend, which maps it field by field in both
directions (`src/api/crypto.ts`). `pq_prekey` and `pq_prekey_signature` are therefore two
independent fields in that mapping, and leaving either out silently produces a half pair. That
now fails loudly rather than degrading: `hybrid_peer_bundle` is built whenever **either** field
is present, precisely so `verify_hybrid_bundle` sees the orphan and rejects the bundle in whole.
Routing a half pair down the classical branch instead would hand an attacker a classical session
for the price of deleting one field.

**The KDF has two domains, and the flags bit selects between them.** `x3dh.rs` expands with the
HKDF info string `X3DH`; `pqxdh.rs` expands with `PQXDH_SharedSecret`. The two are otherwise the
same function — the same four DH operations in the same order, the same IKM layout — so the info
string is the only thing separating a classical session from a hybrid one. A responder chooses
between them on the `0x02` flags bit of the prekey message, which is the whole of the
negotiation: an initiator sets it exactly when the bundle it fetched carried an ML-KEM pre-key.

That separation is correct, and it is also why the two halves of PR-39 could not land in their
numbered order. Every desktop has published an ML-KEM pre-key since PR-39a, so an initiator-first
PR-39b would have driven every desktop-to-desktop handshake into the hybrid domain while every
responder still answered in the classical one — two sides deriving different secrets, visible
only as an AEAD tag rejection, with `just test-two-client-messaging` wired into no workflow to
catch it. That is the PR-97/PR-105 break repeated knowingly rather than by accident. **PR-39c was
therefore landed before PR-39b.** A responder that can answer a hybrid handshake before any
initiator emits one breaks nothing, and the reordering costs a step number and no interop window.
The general rule this is an instance of: when a protocol change splits into a reader and a
writer, the reader ships first.

**A half pair is now rejected where it is read, not only where it is stored.**
`verify_hybrid_bundle` checked the ML-KEM signature under `if let (Some, Some)` with no `else`,
so a bundle carrying an encapsulation key with its signature stripped returned `Ok(())` and was
indistinguishable from a classical one. `auth-service` already refused that shape on the way into
the store, but a bundle can reach a client from somewhere other than `GetKeyBundle`, so the check
had to exist on both sides; it is exhaustive as of PR-39c, with the property test SRS rule 4a
asks for. Stripping a field is cheaper than breaking either primitive, which is precisely why the
degraded path must not exist.

**The ciphertext now has somewhere to ride.** "Every wire structure carrying key material must
have room for an ML-KEM key" was true of `common.KeyBundle` after PR-36, but the *handshake* has
a second structure: `derive_sender_shared_secret` returns a 1088-byte ciphertext the responder
must decapsulate, and that is per-handshake data rather than published key material, so it does
not belong in a key bundle. It rides in `X3DHPrekeyMessage`, inside the opaque `x3dh_prekey`
string the server relays without inspecting ([ADR-0010](ADR-0010-pure-relay-server.md)) — which
is why PR-97 needed no proto change at all.

That format could not grow. It had no version byte, its parser ignored trailing bytes, and its
one-time-key flag was compared `== 1` so every other value read as "absent". Appending a
ciphertext to it would have been *silently accepted* by an unchanged peer, which would then
derive a classical secret against an initiator's hybrid one — an I-3 failure presenting as an
AEAD tag rejection. PR-97 versioned it, replaced the flag byte with a flags byte, and made the
parser strict; the layout is in [SRS.md](../spec/SRS.md#x3dh-prekey-message-wire-format).

**The break was accepted, not negotiated.** Byte 0 of the old format was the first byte of an
Ed25519 public key, so unlike the ratchet frame in
[ADR-0011](ADR-0011-ratchet-header-authentication.md) there is no value that distinguishes old
from new. There is deliberately no fallback path: guessing which format a frame is in would
reintroduce exactly the ambiguity a version byte exists to remove. Rust and `client-desktop`
moved to v1 in PR-97 and `client-mobile` in PR-105
([#279](https://github.com/guardyn/guardyn/issues/279)).

**The cost of splitting it across two PRs was a live interop break.** Between those merges the
two clients could not establish a session with each other at all, and **no CI job detected it** -
`mobile.yml` runs only Dart tests, `build.yml` only Rust ones, and `just
test-two-client-messaging`, the one check that proves the two ends interoperate, needs two real
devices and is wired into no workflow. Both suites stayed green throughout. The split was
necessary under the `AGENTS.md` §2.3 budget and the break was signposted in both PRs, but a
lockstep format change is the case where that budget and a green `main` genuinely conflict, and
the honest record is that green meant nothing here. What now holds the two ends together is the
known-answer vectors: Rust emits them, Dart asserts them, and the strict-parser cases are ported
on both sides because a lenient parser satisfies every vector and is still wrong.

Nothing emits the field yet. PR-97 made the format *capable*, PR-39c made the desktop able to
*read* one; PR-39b (desktop) and PR-98 (mobile) are what put a ciphertext in it.

**PR-38's real finding was about the build, not the flag.** A `cargo test --workspace` build
already enabled `pq`, because `crypto-ffi` declares `default = ["full"] = ["pq"]` and Cargo
unifies features across a workspace. Services ship from `cargo build --release -p <service>`,
which unifies nothing, so `cargo tree -p guardyn-auth-service -i ml-kem` found no such package:
the hybrid tests passed in CI while every deployed binary contained no post-quantum code. When
a feature is an invariant, `default` is the only correct place for it — an opt-in that the test
build happens to opt into proves nothing about what ships.

The fields are `optional`, not bare `bytes`, so "never published" and "published empty" stay
distinct values. On a field whose absence is the normal case for years that distinction is
load-bearing: conflating the two is how a stripped field becomes a silent classical-only
session instead of a rejected bundle.

**`client-mobile/proto/common.proto` was byte-identical to the backend copy and PR-36 forks
them.** Nothing syncs or checks the two trees, and `PROTO-EDIT` matches only `.rs`, so the
Dart side will not notice. Recorded here rather than fixed, because routing `client-mobile`
through the hybrid path is [#262](https://github.com/guardyn/guardyn/issues/262) (PR-98) —
but an undeclared fork of a wire contract is worse than a declared one.

This ADR previously described `pqxdh.rs` as a complete implementation. That was measured
against the code compiling, not against it agreeing: the identity-key conversion above was
missing on both sides, so `test_classical_key_exchange` and `test_hybrid_key_exchange` had
never passed. Being unreachable end to end is what kept that invisible.

Repair is owned by PR-36 (proto fields — **landed**) through PR-40a (fuzz and proptest —
**landed**). PR-40b extended `bench_pqxdh` past key generation to the agreement itself
(**landed** — the measurements are below); it was split out of PR-40 before opening, per
AGENTS.md §2.3, because the two together came to 456 changed lines over 10 files.

**Desktop to desktop is hybrid; the product as a whole is not yet.** `client-mobile` still
publishes no ML-KEM material and negotiates classical X3DH — its proto is forked at tag 5 and
routing it through the hybrid path is [#262](https://github.com/guardyn/guardyn/issues/262)
(PR-98). So a desktop talking to a phone gets a classical session, correctly and by design, and
`I-3` stays `met: false` in [`roadmap.yaml`](../roadmap/roadmap.yaml) until that lands.
**Do not describe the product as post-quantum protected on the strength of this ADR alone** —
name the endpoints.

## What PR-40a pinned, and what PR-120 then fixed

Five properties cover the agreement itself as of PR-40a; before it, the only post-quantum
properties checked bundle *shape*, never whether the two sides actually agree.

`a_responder_that_skips_the_pq_half_diverges` was the one worth reading. Both halves of
`derive_recipient_shared_secret`'s `if let (Some, Some) … else { None }` were covered — a
decapsulation key with no ciphertext, and a ciphertext with no decapsulation key. Only the
second had a test before.

**Its assertion was `assert_ne`, not `is_err`, and that was the finding rather than an
oversight.** A responder that skipped the post-quantum half still agreed on the classical halves,
so the function returned `Ok` with a secret that was merely *different*; the mismatch surfaced
later as an AEAD tag rejection rather than as an error at the point of the mistake. PR-40a pinned
that behaviour rather than changing it — a known failure is not licence to patch it, and making
the function fail closed is a wire-visible behaviour change that belongs in its own step.

**PR-120 ([#329](https://github.com/guardyn/guardyn/issues/329)) is that step.** The gate is now
an exhaustive four-arm `match`, the same shape `verify_hybrid_bundle` uses for the bundle half
pair, and both asymmetric shapes return `CryptoError::Protocol`. `(None, None)` still derives a
classical secret: a classical-only responder answering a classical-only initiator is legitimate,
and classical strength is the floor. The test is renamed
`a_responder_that_skips_the_pq_half_fails` and asserts `is_err`.

Three details of that step are worth keeping.

**The gate runs before the classical Diffie-Hellman, not in place of the old `else`.** Returning
from the old position would have dropped `classical_ikm` — four DH outputs — without reaching its
`zeroize()`. The HKDF input layout is unchanged; only the point of decision moved.

**`Protocol`, not `InvalidKey`.** The wrong-length ciphertext path already returns
`InvalidKey("Invalid PQ ciphertext")`. Reusing it would collapse *absent* and *malformed* into
one variant a caller cannot tell apart, which matters precisely because the two want different
responses: malformed is a bad frame, absent is a downgrade attempt or a lost key.

**It was not exploitable when it was fixed, and that was the argument for fixing it.** The one
production caller pre-filters on `pq_ciphertext.is_some()`, so no shipped path reached the
branch. The safety lived entirely in that caller while the function is `pub` in a crate the
desktop, three backend services and `crypto-ffi` all depend on — and PR-98 adds another caller.
A guarantee that holds because every caller remembers is not a guarantee.

The `assert_ne` shape survives in
`a_tampered_pq_ciphertext_does_not_yield_the_sender_secret`, for a reason unrelated to any of the
above and now easier to mistake for an oversight with its neighbour gone: ML-KEM-768 is
unauthenticated and uses **implicit rejection**, so a tampered ciphertext of the right length
decapsulates successfully to an unrelated secret. A test asserting `is_err` there would assert
the opposite of how the primitive is specified to behave.

## What PR-40b measured

`bench_pqxdh` stopped at key generation until PR-40b. Key generation happens once per device
registration; encapsulation and decapsulation happen once per session, and that is the cost a
user can feel. Criterion medians, 95% confidence interval in brackets:

| | classical | hybrid | delta |
|---|---|---|---|
| `sender_agreement` | 201.45 µs [198.21, 204.96] | 276.24 µs [270.50, 282.13] | **+74.79 µs**, ×1.37 |
| `recipient_agreement` | 182.34 µs [179.53, 185.53] | 235.90 µs [231.78, 240.29] | **+53.56 µs**, ×1.29 |
| one handshake, both sides | 383.79 µs | 512.14 µs | **+128.35 µs**, ×1.33 |
| `generate_*_bundle` | 51.80 µs [51.19, 52.45] | 130.97 µs [126.89, 134.58] | **+79.17 µs**, ×2.53 |

Measured on an Intel Core i9-11900H (8 cores / 16 threads, 4.9 GHz max), 30 GiB RAM, Ubuntu
24.04.4, kernel 7.0.0-31, `rustc 1.98.1 (48a229cea 2026-09-01)`, criterion 0.5, `bench` profile,
100 samples per benchmark. One machine, one run, CPU unpinned and frequency scaling left on. The
intervals do not overlap between arms, so the deltas are real rather than noise — but treat the
absolute figures as this machine's, not as a specification.

**The delta is the ML-KEM half and nothing else, which is what makes it subtractable.** Both arms
call the same `derive_sender_shared_secret` and `derive_recipient_shared_secret`: neither is
feature-gated, neither verifies a signature, and the classical arm differs only in that its
bundle carries no ML-KEM pre-key. What survives the subtraction is encapsulation on one side and
decapsulation on the other, each including the decode of the key that feeds it — 1184 bytes for
the encapsulation key, 2400 for the decapsulation key. Benchmarking `x3dh.rs` against `pqxdh.rs`
instead would have measured the gap between two implementations and called it the cost of
post-quantum cryptography.

**This is a per-session cost, not a per-message one, and the ratios are the wrong number to carry
away.** 128 µs is paid once, when two devices establish a session, and never again for the
messages that follow — the double ratchet does not touch ML-KEM. A device opening ten
conversations spends about 1.3 ms in total on the post-quantum half.

**Key generation carries the largest ratio and matters least.** ×2.53 is the biggest number on
the table, and it is paid once per device registration, behind an account signup that already
costs a user more than 79 µs. It is recorded because omitting it would invite someone to
re-measure it later and believe they had found something.

**What the figures exclude.** Bundle generation is outside the agreement rows: keys are minted
once, outside the timing loop, because ML-KEM-768 key generation costs more than a single
encapsulation and would otherwise dominate the measurement. The ephemeral keypair is excluded for
a different reason — a real handshake mints a fresh one, but that cost falls identically on both
arms, so including it would shrink the ratio without making either figure more honest. Network,
storage and relay costs are not modelled at all, and in a deployment they dominate every number
above.

**Nothing regression-gates these.** `build.yml` compiles the bench target through
`cargo clippy --all-targets`, so it cannot rot silently, but no CI job runs it: a shared runner
varies by more than 128 µs. Re-measuring is a deliberate act — `just bench PQXDH`, recording the
machine alongside the result, as above. See [`RUNBOOK.md`](../ops/RUNBOOK.md).

## Alternatives rejected

**Classical only** — fails I-3. **ML-KEM only** — discards decades of X25519 analysis for
a younger primitive. **Waiting for libsignal** — see ADR-0004; the extension point does not
exist there.
