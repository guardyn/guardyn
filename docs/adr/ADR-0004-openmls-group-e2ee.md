---
id: adr-0004
type: adr
status: accepted
owns: [backend/crates/crypto/src/mls.rs, backend/crates/crypto/src/x3dh.rs, backend/crates/crypto/src/double_ratchet.rs]
read_when: [touching crypto, changing group encryption]
tokens: 447
supersedes: []
---

# ADR-0004 · OpenMLS 0.6 for groups; own X3DH and Double Ratchet rather than libsignal

## Status

`accepted`

## Context

Group encryption by sender keys scales poorly in the membership-change case and has no
standard. MLS (RFC 9420) is the standard, and OpenMLS is the mature Rust implementation.

For one-to-one, libsignal exists but is C-heavy, awkward to build for the platform matrix
here (iOS, Android, three desktop targets via `crypto-ffi`), and hard to extend with a
post-quantum KEM — which **I-3** requires.

## Decision

Group encryption uses OpenMLS 0.6. One-to-one uses an in-repo X3DH and Double Ratchet in
`crates/crypto`, shared with every client through `crypto-ffi`.

## Consequences

One cryptographic implementation serves all platforms, and extending the handshake with
ML-KEM-768 (ADR-0005) is possible at all — which it would not be with an opaque upstream.

The cost is real: hand-rolled protocol code carries the burden of proof. This is why
property tests and fuzz targets on every attacker-reachable parser are mandatory
(`AGENTS.md` §8), not optional.

OpenMLS 0.6 constrains the ciphersuite to `MLS_128_DHKEMX25519_CHACHA20POLY1305_SHA256_Ed25519`
— there is no AES-256-GCM option. Group state serialization currently fails to round-trip
(`SecretTreeError(RatchetTypeError)`); PR-31 owns the repair.

## Alternatives rejected

**libsignal** — proven, but a hard build across five targets and effectively closed to a
PQ extension. **Sender keys** — no standard, worse membership-change behaviour.
