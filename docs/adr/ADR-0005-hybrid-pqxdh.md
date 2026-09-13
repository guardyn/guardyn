---
id: adr-0005
type: adr
status: accepted
owns: [backend/crates/crypto/src/pqxdh.rs, backend/proto/common.proto]
read_when: [touching crypto, changing key bundles, enabling the pq feature]
tokens: 509
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

**What remains is the whole of the client half.** No client populates the fields — the desktop
hardcodes `pq_prekey: None` and `client-mobile`'s proto is still forked at tag 5 — and nothing
reads them back, because `derive_sender_shared_secret` is reached from no session-establishment
path. The implementation is compiled and unreached, which is a better state than uncompiled and
unreached, and is not the same as met. I-3 is met when PR-40 closes.

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

Nothing populates the field yet. PR-97 made the format *capable*; PR-39 (desktop) and PR-98
(mobile) are what put a ciphertext in it.

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

Repair is owned by PR-36 (proto fields — **landed**) through PR-40 (fuzz, proptest, bench).
Until the rest land, **do not describe the product as post-quantum protected.**

## Alternatives rejected

**Classical only** — fails I-3. **ML-KEM only** — discards decades of X25519 analysis for
a younger primitive. **Waiting for libsignal** — see ADR-0004; the extension point does not
exist there.
