# Sealed Sender Protocol

Guardyn implements the Sealed Sender protocol for metadata protection. This document describes the protocol design, implementation, and security properties.

## Overview

Sealed Sender hides the sender's identity from the server. Only the intended recipient can decrypt the envelope and discover who sent the message.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SEALED SENDER FLOW                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  SENDER                        SERVER                      RECIPIENT    │
│    │                             │                             │        │
│    │  1. Create Certificate      │                             │        │
│    │     (sign with identity)    │                             │        │
│    │                             │                             │        │
│    │  2. Encrypt message with    │                             │        │
│    │     Double Ratchet          │                             │        │
│    │                             │                             │        │
│    │  3. Seal envelope:          │                             │        │
│    │     - Generate ephemeral    │                             │        │
│    │     - ECDH with recipient   │                             │        │
│    │     - Encrypt cert + msg    │                             │        │
│    │                             │                             │        │
│    │  4. Send sealed envelope    │                             │        │
│    │ ──────────────────────────► │                             │        │
│    │     (sender unknown)        │                             │        │
│    │                             │  5. Forward envelope        │        │
│    │                             │ ───────────────────────────►│        │
│    │                             │     (recipient known)       │        │
│    │                             │                             │        │
│    │                             │                     6. Unseal:       │
│    │                             │                     - ECDH decrypt   │
│    │                             │                     - Verify cert    │
│    │                             │                     - Decrypt msg    │
│    │                             │                             │        │
│    │                             │                     7. Sender        │
│    │                             │                        revealed!     │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Protocol Specification

### Sender Certificate

The sender proves their identity to the recipient using a signed certificate:

```
SenderCertificate {
    sender_user_id:     String,     // UUID of sender
    sender_device_id:   String,     // Device UUID
    sender_identity_key: [u8; 32],  // Ed25519 public key
    expires_at:         i64,        // Unix timestamp (seconds)
    signature:          [u8; 64],   // Ed25519 signature
}
```

**Certificate Message (signed content):**

```
sender_user_id || 0x00 || sender_device_id || 0x00 || identity_key || expires_at
```

### Sealed Envelope

```
SealedSenderEnvelope {
    version:              u8,       // Protocol version (1)
    ephemeral_public_key: [u8; 32], // X25519 ephemeral key
    encrypted_payload:    Vec<u8>,  // AES-256-GCM ciphertext
}
```

**Wire Format:**

| Offset | Size | Field                |
| ------ | ---- | -------------------- |
| 0      | 1    | Version (0x01)       |
| 1      | 32   | Ephemeral public key |
| 33     | 12   | Nonce                |
| 45     | N    | Ciphertext           |
| 45+N   | 16   | Authentication tag   |

**Plaintext Payload:**

```
cert_length (4 bytes BE) || certificate || inner_message
```

### Cryptographic Operations

#### Key Derivation

```
shared_secret = ECDH(ephemeral_private, recipient_public)
encryption_key = HKDF-SHA256(
    ikm:  shared_secret,
    salt: None,
    info: "Guardyn-SealedSender-v1"
)
```

#### Encryption

- Algorithm: AES-256-GCM
- Nonce: 12 random bytes
- Associated Data: None

## Security Properties

### 1. Sender Anonymity

The server sees only:

- Recipient user ID (for routing)
- Encrypted envelope (opaque blob)
- Ephemeral public key (random, unlinkable)

The server CANNOT determine:

- Who sent the message
- Message content
- Message type

### 2. Recipient Authentication

Only the intended recipient can decrypt:

- Uses recipient's long-term X25519 identity key
- ECDH shared secret is unique to the pair

### 3. Sender Authentication

Recipient verifies sender via certificate:

- Certificate signed by sender's Ed25519 identity key
- Expiration prevents replay attacks
- Signature binds identity to message

### 4. Forward Secrecy

Ephemeral keys provide forward secrecy:

- New ephemeral key per message
- Compromise of identity key doesn't reveal past messages

### 5. Replay Protection

- Certificate expiration (typically 24 hours)
- Message timestamps in inner content
- Duplicate detection at application layer

## Implementation Files

### Rust (Backend)

- [`backend/crates/crypto/src/sealed_sender.rs`](../../backend/crates/crypto/src/sealed_sender.rs)
  - `SenderCertificate` - Certificate creation and verification
  - `SealedSenderEnvelope` - Envelope serialization
  - `SealedSender::seal()` - Seal message
  - `SealedSender::unseal()` - Unseal and verify

### Dart (Flutter Client)

- [`client/lib/core/crypto/sealed_sender.dart`](../../client/lib/core/crypto/sealed_sender.dart)
  - Same API as Rust implementation
  - Uses `package:cryptography` for crypto operations

## Usage Examples

### Rust

```rust
use guardyn_crypto::{SealedSender, SenderCertificate};

// Create certificate
let cert = SenderCertificate::new(
    "user-id".to_string(),
    "device-id".to_string(),
    &signing_key,
    expires_at,
)?;

// Seal message
let envelope = SealedSender::seal(
    &cert,
    &recipient_public_key,
    &inner_message,
)?;

// Send envelope.to_bytes() to server
```

```rust
// Recipient unseals
let (sender_cert, inner_message) = SealedSender::unseal(
    &envelope,
    &recipient_private_key,
)?;

println!("Message from: {}", sender_cert.sender_user_id);
```

### Dart

```dart
// Create certificate
final cert = await SenderCertificate.create(
  senderUserId: 'user-id',
  senderDeviceId: 'device-id',
  signingKeyPair: myKeyPair,
  expiresAt: DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch ~/ 1000,
);

// Seal message
final envelope = await SealedSender.seal(
  certificate: cert,
  recipientPublicKey: recipientPublicKeyBytes,
  innerMessage: encryptedContent,
);

// Send envelope.toBytes() to server
```

```dart
// Recipient unseals
final result = await SealedSender.unseal(
  envelope: envelope,
  recipientKeyPair: myKeyPair,
);

print('Message from: ${result.senderCertificate.senderUserId}');
```

## Integration with Double Ratchet

Sealed Sender wraps Double Ratchet messages:

```
┌─────────────────────────────────────────────────────────┐
│                   SEALED ENVELOPE                        │
│  ┌───────────────────────────────────────────────────┐  │
│  │              SENDER CERTIFICATE                    │  │
│  │  (encrypted with recipient's identity key)        │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │          DOUBLE RATCHET MESSAGE                    │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │  Header: DH key, chain number, msg number   │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │  Ciphertext: AES-GCM encrypted content      │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Certificate Lifecycle

### Creation

1. User registers → generates Ed25519 identity key pair
2. App creates certificate with 24-hour expiration
3. Certificate cached locally

### Renewal

1. Before expiration, app creates new certificate
2. New certificate signed with same identity key
3. Old certificate remains valid until expiration

### Revocation

If identity key is compromised:

1. User initiates key rotation
2. Contacts notified of new identity key
3. Old certificates rejected after verification

## Server Behavior

The server handling Sealed Sender:

1. Receives envelope with only recipient ID visible
2. Routes to recipient's device(s)
3. Does NOT log sender (unknown to server)
4. Does NOT decrypt envelope (no access to keys)

### Abuse Prevention

Without visible sender, abuse prevention uses:

- Rate limiting by source IP
- Account-level reputation
- Recipient-side blocking
- Reporting mechanisms

## Testing

### Rust Tests

```bash
cargo test -p guardyn-crypto sealed_sender
```

Tests cover:

- Certificate creation and verification
- Envelope serialization round-trip
- Successful seal/unseal
- Expired certificate rejection
- Wrong recipient rejection
- Tampered envelope detection

### Flutter Tests

```bash
cd client && flutter test test/core/crypto/sealed_sender_test.dart
```

## References

- [Signal Sealed Sender](https://signal.org/blog/sealed-sender/)
- [Sealed Sender Technical Details](https://signal.org/docs/specifications/sealed-sender/)
- [X25519 (RFC 7748)](https://tools.ietf.org/html/rfc7748)
- [Ed25519 (RFC 8032)](https://tools.ietf.org/html/rfc8032)
- [AES-GCM (NIST SP 800-38D)](https://csrc.nist.gov/publications/detail/sp/800-38d/final)
