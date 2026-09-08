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

**The gap.** The `pq` feature is off by default, no backend service enables it, and —
decisively — `backend/proto/` contains **zero** ML-KEM fields, so a server cannot publish a
PQ public key at all. The implementation is unreached, not absent.

This ADR previously described `pqxdh.rs` as a complete implementation. That was measured
against the code compiling, not against it agreeing: the identity-key conversion above was
missing on both sides, so `test_classical_key_exchange` and `test_hybrid_key_exchange` had
never passed. Being unreachable end to end is what kept that invisible.

Repair is owned by PR-36 (proto fields) through PR-40 (fuzz, proptest, bench). Until then,
**do not describe the product as post-quantum protected.**

## Alternatives rejected

**Classical only** — fails I-3. **ML-KEM only** — discards decades of X25519 analysis for
a younger primitive. **Waiting for libsignal** — see ADR-0004; the extension point does not
exist there.
