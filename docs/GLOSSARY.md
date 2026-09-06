---
id: glossary
type: glossary
status: accepted
owns: [backend/proto/, backend/crates/crypto/src/, backend/crates/common/src/]
read_when: [naming anything, writing a document, reviewing a proto change]
tokens: 1591
supersedes: []
---

# Glossary

The ubiquitous language. **Every term here was read out of the code** — proto messages,
proto enums, and public Rust types — never invented. If a term and its code symbol
disagree, the code is right and this file is stale: fix it here.

`forbidden_aliases` is enforced. `docs-verify` check #3 fails when a document uses one of
them in place of the canonical term, which is how `User`/`Player`-class naming drift dies.

## Identity

| Term | Code symbol | Meaning | forbidden_aliases |
|---|---|---|---|
| **User** | `UserId`, `UserProfile` (`common.proto`, `auth.proto`) | A human account. The unit of identity. | Account, Customer, Player |
| **Device** | `DeviceId`, `DeviceInfo` (`common.proto`, `auth.proto`) | One installation belonging to a User. Keys are per-device, not per-user. | Endpoint, Terminal |
| **Contact** | `Contact` (`auth.proto`) | Another User a User has added. | Friend, Buddy |
| **BlockedUser** | `BlockedUser` (`auth.proto`) | A User whose messages are refused. | Banned, Muted |

`Client` is *not* a synonym for Device — `ClientCapabilities` describes the software, not
the installation record.

## Messaging

| Term | Code symbol | Meaning | forbidden_aliases |
|---|---|---|---|
| **Message** | `Message`, `MessageType` (`messaging.proto`) | One addressed payload. Always ciphertext on the wire. | Msg, Note |
| **Conversation** | `Conversation` (`messaging.proto`) | A 1-to-1 or group exchange. The container for Messages. | Chat, Room, Dialog |
| **Group** | `GroupInfo`, `GroupMemberInfo`, `GroupMessage` | A multi-party Conversation with membership and roles. | Channel, Team |
| **Thread** | `ThreadReference` (`messaging.proto`) | A reply chain *inside* a Conversation. Not a synonym for Conversation. | — |
| **Reaction** | `Reaction`, `ReactionSummary` | An emoji response attached to a Message. | Like, Emoji |
| **ReadReceipt** | `ReadReceipt` (`messaging.proto`) | Proof a Message was read. | Seen, Ack |
| **DeliveryStatus** | `DeliveryStatus` enum | Where a Message is in transit. | State, Progress |
| **DisappearingConfig** | `DisappearingConfig` | Per-Conversation self-destruct timing. | Ephemeral, TTL |
| **ForwardInfo** | `ForwardInfo`, `MessageEdit` | Provenance of a forwarded Message; an edit record. | — |

## Cryptography

| Term | Code symbol | Meaning | forbidden_aliases |
|---|---|---|---|
| **KeyBundle** | `KeyBundle` (`common.proto`), `X3DHKeyBundle`, `HybridKeyBundle` | The published public key material a peer needs to start a session. | PreKeyBundle |
| **IdentityKeyPair** | `IdentityKeyPair` (`crypto`) | A Device's long-term key pair. Never leaves the Device. | MasterKey |
| **SignedPreKey** | `SignedPreKey` (`crypto`) | Medium-term key, signed by the identity key. | — |
| **OneTimePreKey** | `OneTimePreKey`, `OneTimePreKeyPublic` | Single-use key consumed by one session handshake. | OTK |
| **X3DH** | `X3DHProtocol`, `X3DHKeyMaterial`, `X3DHPrekeyMessage` | The asynchronous handshake establishing a shared secret. | Handshake |
| **PQXDH** | `HybridKeyBundle`, `HybridSharedSecret`, `HybridPrivateKeys` | X3DH extended with ML-KEM-768. **Implemented, not yet enabled** — see I-3. | PostQuantumX3DH |
| **DoubleRatchet** | `DoubleRatchet`, `MessageHeader` | Per-message forward-secret key evolution after the handshake. | Ratchet |
| **MLS** | `MlsGroupManager`, `MlsGroupState`, `MlsKeyPackage` | OpenMLS group encryption. The Group counterpart to Double Ratchet. | GroupCrypto |
| **SealedSender** | `SealedSender`, `SealedSenderEnvelope`, `SenderCertificate` | Hides sender identity from the server. | AnonymousSender |
| **EncryptedMessage** | `EncryptedMessage` (`crypto`) | Ciphertext plus the header needed to decrypt it. | Blob, Payload |
| **SFrame** | `SFrameKeyRotated`, `ExchangeSFrameKey*` | Frame-level media encryption for calls. | MediaCrypto |

**Never** write "encrypted payload" where `EncryptedMessage` is meant, and never let any of
these appear in a log — see [`.claude/rules/30-zk-logging.md`](../.claude/rules/30-zk-logging.md).

## Calls and presence

| Term | Code symbol | Meaning | forbidden_aliases |
|---|---|---|---|
| **Call** | `CallState`, `CallType`, `CallEndReason`, `CallQuality` | A voice or video session. | Ring, Session |
| **CallParticipant** | `CallParticipant`, `ParticipantKeyPackage` | One Device in a Call. | Attendee, Peer |
| **SdpMessage** | `SdpMessage`, `SdpType` | WebRTC session description exchanged during setup. | Offer, Answer |
| **IceCandidate** | `IceCandidate`, `IceServer` | WebRTC connectivity candidate. | Candidate |
| **Presence** | `UserPresence`, `PresenceUpdate`, `UserStatus` | Whether a User is reachable. | Online, Activity |

`Status` alone is ambiguous — `Status` is the health enum in `common.proto`, `UserStatus`
is presence, and `DeliveryStatus` is message transit. Always qualify it.

## Platform

| Term | Code symbol | Meaning | forbidden_aliases |
|---|---|---|---|
| **MediaMetadata** | `MediaMetadata`, `MediaType`, `UploadStatus` | Descriptor for an uploaded blob. The blob itself is ciphertext. | Attachment, File |
| **ErrorCode** | `ErrorCode` enum (`common.proto`) | The canonical error taxonomy. Read the proto — never invent a variant. | Errno |
| **HealthStatus** | `HealthStatus`, `Status` (`common.proto`) | Service liveness, reported per service. | Heartbeat |
| **EventEnvelope** | `EventEnvelope` (`common`) | The durable-log wrapper carried over Redpanda. | Payload, Record |
| **RateLimiter** | `RateLimiter`, `RateLimitConfig` | Per-process request throttle. **Not** distributed — see PR-41. | Throttle |

## Datastores and buses

| Term | Role | forbidden_aliases |
|---|---|---|
| **TiKV** | Metadata, auth and MLS state. Deliberately not PostgreSQL. | DB, Database |
| **ScyllaDB** | Message, call and notification history. | Cassandra |
| **MinIO** | Encrypted media blobs. | S3 |
| **NATS** | Ephemeral signalling. | Queue |
| **Redpanda** | Durable event log. | Kafka |
| **Envoy** | gRPC-Web gateway at the edge. | Proxy, Gateway |

NATS and Redpanda **coexist by design** with separated roles. Neither is "the bus".
