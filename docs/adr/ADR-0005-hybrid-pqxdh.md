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

**The gap.** `crates/crypto/src/pqxdh.rs` is a complete implementation, but the `pq`
feature is off by default, no backend service enables it, and — decisively —
`backend/proto/` contains **zero** ML-KEM fields, so a server cannot publish a PQ public
key at all. The implementation is unreached, not absent.

Repair is owned by PR-36 (proto fields) through PR-40 (fuzz, proptest, bench). Until then,
**do not describe the product as post-quantum protected.**

## Alternatives rejected

**Classical only** — fails I-3. **ML-KEM only** — discards decades of X25519 analysis for
a younger primitive. **Waiting for libsignal** — see ADR-0004; the extension point does not
exist there.
