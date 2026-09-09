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

`MlsGroupState` and `MlsKeyPackage` implement `Debug` by hand rather than deriving it.
`serialized_state` is the highest-value field in the crate - today it holds a secret exported
from the epoch secret - and `key_package_bytes` and `credential_identity` are likewise not
things to put in a log line. `group_id`, `epoch` and `package_id` stay visible, because an
operator debugging a group needs exactly those (see
[ADR-0007](ADR-0007-zero-knowledge-logging.md)).

The cost is real: hand-rolled protocol code carries the burden of proof. This is why
property tests and fuzz targets on every attacker-reachable parser are mandatory
(`AGENTS.md` §8), not optional.

OpenMLS 0.6 constrains the ciphersuite to `MLS_128_DHKEMX25519_CHACHA20POLY1305_SHA256_Ed25519`
— there is no AES-256-GCM option.

**Groups are created under a caller-supplied `GroupId`.** `MlsGroup::new` assigns a random
identifier and silently ignores any the caller had in mind, so creation goes through
`new_with_group_id`. A group whose identifier the caller cannot predict cannot be looked up.

**A member cannot decrypt its own message.** The sender's application ratchet is consumed on
encrypt, so OpenMLS answers `SecretTreeError(RatchetTypeError)`. This is MLS behaving
correctly; any test or handler that expects a self round-trip is wrong.

**Group state is not serialized at all.** `serialize_state` exports a 32-byte MLS exporter
secret rather than the group, and there is no deserialization counterpart. A two-party
exchange is also not yet possible: `generate_key_package` drops the provider and signature
keypair it creates, and `join_group` builds a fresh empty provider with no init keys, so no
Welcome can be processed.

This ADR previously recorded the defect as "group state serialization fails to round-trip
(`SecretTreeError(RatchetTypeError)`)". That conflated two unrelated things: the error comes
from self-decryption, and the round-trip does not fail so much as never happen.

**The server does not participate in MLS.** PR-31 (#42, #151, #152, #153) removes the
server-side group operations entirely rather than repairing them. The server keeps a membership
index and a monotonic epoch counter over opaque blobs; group state, epoch secrets and
credentials exist only on the clients. `MlsGroup::load<Storage: StorageProvider>` does exist
(`openmls-0.6.0/src/group/mls_group/mod.rs:417`) — the in-code comments claiming otherwise were
wrong — and that is precisely why the server must not hold group state: `load` restores
`group_epoch_secrets`, so a server able to reload a group is a server able to decrypt it.

`create_test_credential` is gone. It ignored its `identity` argument and was a byte-for-byte
duplicate of `create_test_keypair`, so the server calling it with a user's identity minted a
credential unrelated to that user — while appearing to act as them. Its only caller was the
server-side `create_group` path.

The client-side half of `serialize_state` is [#158](https://github.com/guardyn/guardyn/issues/158):
`client-desktop` persists the 32-byte export believing a group can be restored from it.

The architecture that replaced the server-side MLS implementation is
[ADR-0010](ADR-0010-pure-relay-server.md).

## Alternatives rejected

**libsignal** — proven, but a hard build across five targets and effectively closed to a
PQ extension. **Sender keys** — no standard, worse membership-change behaviour.
