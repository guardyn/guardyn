# Guardyn Encryption Architecture

This document provides a comprehensive technical overview of the encryption mechanisms used in Guardyn, including detailed diagrams and protocol descriptions.

## Table of Contents

1. [Encryption Overview](#encryption-overview)
2. [X3DH Key Exchange Protocol](#x3dh-key-exchange-protocol)
3. [Double Ratchet Algorithm](#double-ratchet-algorithm)
4. [MLS Group Encryption](#mls-group-encryption)
5. [End-to-End Encryption Flow](#end-to-end-encryption-flow)
6. [Key Storage and Management](#key-storage-and-management)
7. [Security Properties](#security-properties)

---

## Encryption Overview

Guardyn implements a multi-layer encryption architecture based on the Signal Protocol and OpenMLS standards. The system provides:

- **1-on-1 Messaging**: X3DH + Double Ratchet (Signal Protocol)
- **Group Messaging**: OpenMLS (IETF RFC 9420)
- **Media Encryption**: SFrame for voice/video calls (planned)

```mermaid
graph TB
    subgraph "Guardyn Encryption Stack"
        direction TB

        subgraph "Layer 3: Application"
            App[Application Layer<br/>Messages, Media, Calls]
        end

        subgraph "Layer 2: E2EE Protocols"
            DR[Double Ratchet<br/>1-on-1 Message Encryption]
            MLS[OpenMLS<br/>Group Message Encryption]
            SF[SFrame<br/>Media Encryption]
        end

        subgraph "Layer 1: Key Exchange"
            X3DH[X3DH Protocol<br/>Initial Key Agreement]
            MLSKE[MLS Key Exchange<br/>Group Key Agreement]
        end

        subgraph "Layer 0: Cryptographic Primitives"
            Ed25519[Ed25519<br/>Digital Signatures]
            X25519[X25519<br/>Diffie-Hellman]
            AES256[AES-256-GCM<br/>Symmetric Encryption]
            HKDF[HKDF-SHA256<br/>Key Derivation]
        end
    end

    App --> DR
    App --> MLS
    App --> SF

    DR --> X3DH
    MLS --> MLSKE
    SF --> MLSKE

    X3DH --> Ed25519
    X3DH --> X25519
    X3DH --> HKDF

    DR --> AES256
    DR --> HKDF
    DR --> X25519

    MLS --> Ed25519
    MLS --> X25519
    MLS --> AES256
    MLS --> HKDF

    style X3DH fill:#FFD93D,stroke:#333,stroke-width:2px
    style DR fill:#FFD93D,stroke:#333,stroke-width:2px
    style MLS fill:#FFD93D,stroke:#333,stroke-width:2px
    style AES256 fill:#50C878,stroke:#333,stroke-width:2px
    style Ed25519 fill:#50C878,stroke:#333,stroke-width:2px
    style X25519 fill:#50C878,stroke:#333,stroke-width:2px
```

---

## X3DH Key Exchange Protocol

X3DH (Extended Triple Diffie-Hellman) is used to establish initial shared secrets between two parties. It provides **asynchronous key agreement**, meaning Alice can initiate a secure session with Bob even if Bob is offline.

### Key Types in X3DH

```mermaid
graph LR
    subgraph "Alice's Keys"
        A_IK[Identity Key<br/>Ed25519<br/>Long-term]
        A_EK[Ephemeral Key<br/>X25519<br/>Per-session]
    end

    subgraph "Bob's Key Bundle (Published)"
        B_IK[Identity Key<br/>Ed25519<br/>Long-term]
        B_SPK[Signed Pre-Key<br/>X25519<br/>Medium-term]
        B_SPK_Sig[SPK Signature<br/>Ed25519]
        B_OPK[One-Time Pre-Keys<br/>X25519<br/>Single-use]
    end

    %% Note: Ephemeral Key (A_EK) is NOT signed - it's generated per-session
    %% Only Bob's Signed Pre-Key is signed by his Identity Key
    B_IK -->|signs| B_SPK
    B_SPK --> B_SPK_Sig

    style A_IK fill:#4A90E2
    style B_IK fill:#4A90E2
    style A_EK fill:#9B59B6
    style B_SPK fill:#50C878
    style B_OPK fill:#FFD93D
```

### X3DH Key Bundle Structure

| Key Type               | Algorithm | Lifetime    | Purpose                           |
| ---------------------- | --------- | ----------- | --------------------------------- |
| Identity Key (IK)      | Ed25519*  | Permanent   | Long-term identity verification   |
| Signed Pre-Key (SPK)   | X25519    | 1-4 weeks   | Medium-term key agreement         |
| SPK Signature          | Ed25519   | Same as SPK | Proves SPK authenticity           |
| One-Time Pre-Key (OPK) | X25519    | Single use  | Forward secrecy for first message |

> **\*Important Note on Identity Keys:** The Identity Key is stored as Ed25519 for digital signatures, but for Diffie-Hellman operations it is converted to X25519 using **Birational Equivalence mapping** between the twisted Edwards curve (Ed25519) and Montgomery curve (X25519). This is the same approach used by Signal Protocol.
>
> **Conversion Details:**
> - **Public key conversion:** Uses the formula `X_mont = (1 + Y_ed) / (1 - Y_ed) mod p` where `Y_ed` is the Ed25519 y-coordinate
> - **Secret key conversion:** The Ed25519 seed is hashed with SHA-512, then the first 32 bytes are clamped for X25519 use
> - **Rust implementation:** Uses `ed25519_dalek::VerifyingKey::to_montgomery()` and `SigningKey::to_scalar_bytes()`
> - **Dart implementation:** Uses `pinenacl` library's `TweetNaClExt.crypto_sign_ed25519_pk_to_x25519_pk()` and `crypto_sign_ed25519_sk_to_x25519_sk()`

### X3DH Protocol Flow

```mermaid
sequenceDiagram
    participant Alice as Alice (Initiator)
    participant Server as Auth Service
    participant Bob as Bob (Recipient)

    Note over Bob,Server: Bob publishes key bundle (offline)
    Bob->>+Server: Upload Key Bundle<br/>(IK_B, SPK_B, Sig_B, OPK_B[])
    Server-->>-Bob: Bundle stored

    Note over Alice,Server: Alice initiates session (Bob may be offline)
    Alice->>+Server: Request Bob's Key Bundle
    Server-->>-Alice: Bundle(IK_B, SPK_B, Sig_B, OPK_B[0])

    Note over Alice: Alice validates bundle
    Alice->>Alice: Verify Sig_B with IK_B
    Alice->>Alice: Generate ephemeral key EK_A

    Note over Alice: 4-DH Key Agreement
    rect rgb(255, 249, 196)
        Alice->>Alice: DH1 = DH(IK_A, SPK_B)
        Alice->>Alice: DH2 = DH(EK_A, IK_B)
        Alice->>Alice: DH3 = DH(EK_A, SPK_B)
        Alice->>Alice: DH4 = DH(EK_A, OPK_B) [optional]
    end

    Alice->>Alice: SK = HKDF(DH1 || DH2 || DH3 || DH4)

    Note over Alice,Bob: Initial message with key material
    Alice->>Server: Send Initial Message<br/>(IK_A, EK_A, OPK_id, encrypted_msg)
    Server->>Bob: Deliver message

    Note over Bob: Bob derives same shared secret
    rect rgb(255, 249, 196)
        Bob->>Bob: DH1 = DH(SPK_B, IK_A)
        Bob->>Bob: DH2 = DH(IK_B, EK_A)
        Bob->>Bob: DH3 = DH(SPK_B, EK_A)
        Bob->>Bob: DH4 = DH(OPK_B, EK_A) [if used]
    end

    Bob->>Bob: SK = HKDF(DH1 || DH2 || DH3 || DH4)
    Bob->>Bob: Decrypt message with SK
```

### X3DH Shared Secret Derivation

```mermaid
graph TD
    subgraph "DH Computations"
        DH1["DH1 = DH(IK_A, SPK_B)"]
        DH2["DH2 = DH(EK_A, IK_B)"]
        DH3["DH3 = DH(EK_A, SPK_B)"]
        DH4["DH4 = DH(EK_A, OPK_B) - Optional"]
    end

    subgraph "Key Derivation"
        Concat["Concatenate: DH1 || DH2 || DH3 || DH4"]
        HKDF["HKDF-SHA256<br/>info = 'X3DH'"]
        SK["Shared Secret - 32 bytes"]
    end

    DH1 --> Concat
    DH2 --> Concat
    DH3 --> Concat
    DH4 -.->|if available| Concat
    Concat --> HKDF
    HKDF --> SK

    style SK fill:#50C878,stroke:#333,stroke-width:2px
```

> **HKDF Parameters (X3DH Initial Key Agreement):**
>
> - **Hash**: SHA-256
> - **Salt**: None (empty)
> - **IKM**: DH1 || DH2 || DH3 [|| DH4]
> - **Info**: `"X3DH"` (ASCII bytes)
> - **Output Length**: 32 bytes

---

## Double Ratchet Algorithm

The Double Ratchet provides **forward secrecy** and **post-compromise security** for ongoing conversations. It combines:

1. **DH Ratchet**: Generates new key material on each message exchange
2. **Symmetric Ratchet**: Derives message keys from chain keys

### Double Ratchet Architecture

```mermaid
graph TB
    subgraph "Double Ratchet State"
        direction TB

        subgraph "Ratchet Keys"
            RK[Root Key<br/>32 bytes]
            DHs[DH Sending Key<br/>X25519 Private]
            DHr[DH Receiving Key<br/>X25519 Public]
        end

        subgraph "Chain Keys"
            CKs[Sending Chain Key<br/>32 bytes]
            CKr[Receiving Chain Key<br/>32 bytes]
        end

        subgraph "Counters"
            Ns[N_s: Send message #]
            Nr[N_r: Recv message #]
            PN[PN: Previous chain length]
        end

        subgraph "Skipped Keys"
            MKSKIPPED["Skipped Message Keys"]
        end
    end

    RK --> CKs
    RK --> CKr
    DHs -.->|DH with| DHr

    style RK fill:#FF6B6B,stroke:#333,stroke-width:2px
    style CKs fill:#4A90E2,stroke:#333,stroke-width:2px
    style CKr fill:#50C878,stroke:#333,stroke-width:2px
```

### DH Ratchet Step

The DH ratchet generates fresh key material whenever a new DH public key is received:

```mermaid
sequenceDiagram
    participant Alice
    participant Bob

    Note over Alice,Bob: Initial state after X3DH

    rect rgb(200, 230, 255)
        Note over Alice: Alice sends message 1
        Alice->>Alice: MK = CKs.message_key()
        Alice->>Alice: CKs = CKs.next()
        Alice->>Alice: Encrypt(MK, plaintext)
        Alice->>Bob: Header(DH_A, PN, N_s) + Ciphertext
    end

    rect rgb(200, 255, 200)
        Note over Bob: Bob receives & replies
        Bob->>Bob: Decrypt with derived MK
        Bob->>Bob: Generate new DH_B keypair
        Bob->>Bob: RK, CKs = RK.dh_ratchet(DH(DH_B, DH_A))
        Bob->>Bob: MK = CKs.message_key()
        Bob->>Bob: CKs = CKs.next()
        Bob->>Alice: Header(DH_B, PN, N_s) + Ciphertext
    end

    rect rgb(200, 230, 255)
        Note over Alice: Alice receives & ratchets
        Alice->>Alice: RK, CKr = RK.dh_ratchet(DH(DH_A, DH_B))
        Alice->>Alice: MK = CKr.message_key()
        Alice->>Alice: Decrypt message
        Alice->>Alice: Generate new DH_A' keypair
    end
```

### HKDF Parameters for Double Ratchet

The Double Ratchet uses different HKDF configurations for different key derivation operations:

> **DH Ratchet (Root Key Update):**
>
> - **Hash**: SHA-256
> - **Salt**: Current Root Key (32 bytes)
> - **IKM**: DH output from X25519 exchange
> - **Info**: `"guardyn-root-key"` (ASCII bytes)
> - **Output Length**: 64 bytes (split: first 32 bytes → new Root Key, last 32 bytes → new Chain Key)

> **Symmetric Ratchet (Chain Key → Next Chain Key):**
>
> - **Hash**: SHA-256
> - **Salt**: None (empty)
> - **IKM**: Current Chain Key (32 bytes)
> - **Info**: `"guardyn-chain-key"` (ASCII bytes)
> - **Output Length**: 32 bytes

> **Symmetric Ratchet (Chain Key → Message Key):**
>
> - **Hash**: SHA-256
> - **Salt**: None (empty)
> - **IKM**: Current Chain Key (32 bytes)
> - **Info**: `"guardyn-message-key"` (ASCII bytes)
> - **Output Length**: 32 bytes

### Symmetric Ratchet (Chain Key Derivation)

```mermaid
graph LR
    subgraph "Symmetric Ratchet"
        CK0[Chain Key 0] -->|HKDF| CK1[Chain Key 1]
        CK1 -->|HKDF| CK2[Chain Key 2]
        CK2 -->|HKDF| CK3[Chain Key 3]
        CK3 -->|HKDF| CKn[Chain Key n]

        CK0 -->|HKDF| MK0[Message Key 0]
        CK1 -->|HKDF| MK1[Message Key 1]
        CK2 -->|HKDF| MK2[Message Key 2]
        CK3 -->|HKDF| MK3[Message Key 3]
    end

    MK0 -->|AES-256-GCM| E0[Encrypted Message 0]
    MK1 -->|AES-256-GCM| E1[Encrypted Message 1]
    MK2 -->|AES-256-GCM| E2[Encrypted Message 2]
    MK3 -->|AES-256-GCM| E3[Encrypted Message 3]

    style MK0 fill:#50C878
    style MK1 fill:#50C878
    style MK2 fill:#50C878
    style MK3 fill:#50C878
```

### Message Encryption/Decryption

```mermaid
graph TB
    subgraph "Message Encryption"
        PT[Plaintext Message]
        MK[Message Key<br/>from Chain Ratchet]
        NONCE[Nonce<br/>12 bytes random]
        AAD[Associated Data<br/>Header bytes]

        PT --> AES[AES-256-GCM<br/>Authenticated Encryption]
        MK --> AES
        NONCE --> AES
        AAD --> AES

        AES --> CT[Ciphertext + Auth Tag]
    end

    subgraph "Wire Format"
        HDR_LEN[Header Length<br/>4 bytes Big-Endian]
        HDR[Header<br/>40 bytes]
        WIRE_NONCE[Nonce<br/>12 bytes]
        CIPHER[Ciphertext]
        TAG[Auth Tag<br/>16 bytes]

        HDR_LEN --> MSG[Encrypted Message]
        HDR --> MSG
        WIRE_NONCE --> MSG
        CIPHER --> MSG
        TAG --> MSG
    end

    CT --> CIPHER
    CT --> TAG

    style AES fill:#FFD93D,stroke:#333,stroke-width:2px
```

### Message Header Structure

| Field                 | Size         | Description                         |
| --------------------- | ------------ | ----------------------------------- |
| DH Public Key         | 32 bytes     | Current ratchet public key (X25519) |
| Previous Chain Length | 4 bytes      | Messages sent on previous chain     |
| Message Number        | 4 bytes      | Message index in current chain      |
| **Total**             | **40 bytes** | Header size                         |

### Encrypted Message Wire Format

| Field         | Size              | Description                                |
| ------------- | ----------------- | ------------------------------------------ |
| Header Length | 4 bytes           | Length of header (Big-Endian)              |
| Header        | 40 bytes          | Message header (see above)                 |
| Nonce         | 12 bytes          | Random nonce for AES-GCM                   |
| Ciphertext    | Variable          | Encrypted message content                  |
| Auth Tag      | 16 bytes          | AES-GCM authentication tag                 |
| **Total**     | **72 + N bytes**  | Where N is plaintext length                |

> **Note:** Integer fields (Previous Chain Length, Message Number) are encoded in **Big-Endian (Network Byte Order)** per RFC 1700 for cross-platform compatibility.

> **Security Note:** Each message uses a **cryptographically secure random 12-byte nonce** generated via `OsRng` (Rust) / `Random.secure()` (Dart). The nonce is prepended to the ciphertext, ensuring unique encryption even when the same message key is used (which should never happen in Double Ratchet, but defense-in-depth).

---

## MLS Group Encryption

OpenMLS (RFC 9420) provides scalable group encryption with efficient member management:

### MLS Tree Structure

```mermaid
graph TB
    subgraph "MLS Ratchet Tree (4 Members)"
        Root[Root Node<br/>Group Secret]

        L1[Internal Node]
        R1[Internal Node]

        A[Leaf: Alice<br/>KeyPackage_A]
        B[Leaf: Bob<br/>KeyPackage_B]
        C[Leaf: Carol<br/>KeyPackage_C]
        D[Leaf: Dave<br/>KeyPackage_D]

        Root --> L1
        Root --> R1
        L1 --> A
        L1 --> B
        R1 --> C
        R1 --> D
    end

    subgraph "Key Schedule"
        GS[Group Secret]
        JS[Joiner Secret]
        ES[Epoch Secret]

        HS[Handshake Secret]
        AS[Application Secret]

        HK[Handshake Key]
        HNONCE[Handshake Nonce]
        AK[Application Key]
        ANONCE[Application Nonce]
    end

    Root -.-> GS
    GS --> ES
    ES --> HS
    ES --> AS
    HS --> HK
    HS --> HNONCE
    AS --> AK
    AS --> ANONCE

    style Root fill:#FF6B6B,stroke:#333,stroke-width:2px
    style A fill:#4A90E2
    style B fill:#4A90E2
    style C fill:#4A90E2
    style D fill:#4A90E2
    style AK fill:#50C878
```

### MLS Group Lifecycle

```mermaid
sequenceDiagram
    participant Alice as Alice (Creator)
    participant Server as Messaging Service
    participant Bob as Bob
    participant Carol as Carol

    Note over Alice: Group Creation
    Alice->>Alice: Create MLS Group<br/>group_id, credential, keypair
    Alice->>Server: Store Group State<br/>epoch = 0

    Note over Alice,Bob: Add Bob to Group
    Alice->>Server: Get Bob's KeyPackage
    Server-->>Alice: KeyPackage_Bob
    Alice->>Alice: mls_group.add_member(KeyPackage_Bob)
    Alice->>Alice: Generate Welcome message
    Alice->>Server: Commit + Welcome

    Server->>Bob: Deliver Welcome
    Bob->>Bob: Join group from Welcome

    Note over Alice,Carol: Add Carol to Group
    Alice->>Server: Get Carol's KeyPackage
    Server-->>Alice: KeyPackage_Carol
    Alice->>Alice: mls_group.add_member(KeyPackage_Carol)

    rect rgb(255, 249, 196)
        Note over Alice,Carol: Encrypted Message
        Alice->>Alice: message = mls_group.create_message("Hello!")
        Alice->>Server: Broadcast MLS Message
        Server->>Bob: Deliver MLS Message
        Server->>Carol: Deliver MLS Message
        Bob->>Bob: mls_group.process_message()
        Carol->>Carol: mls_group.process_message()
    end

    Note over Alice,Carol: Remove Bob from Group
    Alice->>Alice: mls_group.remove_member(Bob)
    Alice->>Server: Commit (removes Bob)
    Server->>Carol: Deliver Commit
    Note over Bob: Bob can no longer decrypt<br/>new messages
```

### MLS Key Package Structure

```mermaid
graph LR
    subgraph "KeyPackage Contents"
        Version[Version: MLS 1.0]
        Cipher[Ciphersuite:<br/>MLS_128_DHKEMX25519_<br/>AES128GCM_SHA256_Ed25519]
        HPKE[HPKE Init Key<br/>X25519 Public]
        Cred[Credential<br/>Basic: user_id:device_id]
        Ext[Extensions<br/>Lifetime, Capabilities]
        Sig[Signature<br/>Ed25519]
    end

    Version --> KP[Key Package]
    Cipher --> KP
    HPKE --> KP
    Cred --> KP
    Ext --> KP
    Sig --> KP

    style KP fill:#FFD93D,stroke:#333,stroke-width:2px
```

### MLS Ciphersuite

Guardyn uses `MLS_128_DHKEMX25519_AES128GCM_SHA256_Ed25519`:

| Component | Algorithm   | Purpose            |
| --------- | ----------- | ------------------ |
| HPKE KEM  | X25519      | Key encapsulation  |
| AEAD      | AES-128-GCM | Message encryption |
| Hash      | SHA-256     | Key derivation     |
| Signature | Ed25519     | Authentication     |

> **Note on AES Key Sizes:** MLS uses **AES-128-GCM** (128-bit keys) as specified in RFC 9420 for the `MLS_128_*` ciphersuites, which provides approximately 128 bits of security. In contrast, the Double Ratchet protocol for 1-on-1 messaging uses **AES-256-GCM** (256-bit keys), providing approximately 256 bits of security. Both are considered secure for current and near-future threats. The choice of AES-128 for MLS aligns with the standard ciphersuite definitions, while AES-256 for Double Ratchet provides an extra security margin for long-term message confidentiality.

---

## End-to-End Encryption Flow

### Complete 1-on-1 Message Flow

```mermaid
sequenceDiagram
    participant Alice as Alice's Device
    participant AuthSvc as Auth Service
    participant MsgSvc as Messaging Service
    participant TiKV as TiKV
    participant ScyllaDB as ScyllaDB
    participant Bob as Bob's Device

    Note over Alice,Bob: Phase 1: Key Bundle Publishing
    rect rgb(230, 240, 255)
        Alice->>Alice: Generate X3DHKeyMaterial<br/>(IK, SPK, 100 OPKs)
        Alice->>+AuthSvc: Register(username, key_bundle)
        AuthSvc->>TiKV: Store user + key_bundle
        AuthSvc-->>-Alice: JWT token

        Bob->>Bob: Generate X3DHKeyMaterial
        Bob->>+AuthSvc: Register(username, key_bundle)
        AuthSvc->>TiKV: Store user + key_bundle
        AuthSvc-->>-Bob: JWT token
    end

    Note over Alice,Bob: Phase 2: Session Establishment
    rect rgb(255, 245, 200)
        Alice->>+AuthSvc: GetKeyBundle(bob_id)
        AuthSvc->>TiKV: Fetch Bob's bundle
        TiKV-->>AuthSvc: key_bundle
        AuthSvc-->>-Alice: KeyBundle(IK_B, SPK_B, OPK_B)

        Alice->>Alice: X3DH Key Agreement<br/>→ Shared Secret (SK)
        Alice->>Alice: Initialize Double Ratchet<br/>with SK as root key
    end

    Note over Alice,Bob: Phase 3: Message Encryption & Delivery
    rect rgb(200, 255, 200)
        Alice->>Alice: DR.encrypt("Hello Bob!")
        Alice->>Alice: → Header + Ciphertext

        Alice->>+MsgSvc: SendMessage(bob_id, encrypted_msg)
        MsgSvc->>TiKV: Store message metadata
        MsgSvc->>ScyllaDB: Store encrypted content
        MsgSvc-->>-Alice: message_id
    end

    Note over Alice,Bob: Phase 4: Message Decryption
    rect rgb(255, 220, 220)
        MsgSvc->>Bob: Push notification (NATS)
        Bob->>+MsgSvc: GetMessages(alice_id)
        MsgSvc->>ScyllaDB: Fetch encrypted messages
        MsgSvc-->>-Bob: encrypted_messages[]

        Bob->>Bob: Extract IK_A, EK_A from header
        Bob->>Bob: X3DH Key Agreement<br/>→ Same Shared Secret (SK)
        Bob->>Bob: Initialize Double Ratchet
        Bob->>Bob: DR.decrypt(ciphertext)<br/>→ "Hello Bob!"
    end
```

### Group Message Flow

```mermaid
sequenceDiagram
    participant Alice as Alice
    participant MsgSvc as Messaging Service
    participant ScyllaDB as ScyllaDB
    participant NATS as NATS JetStream
    participant Bob as Bob
    participant Carol as Carol

    Note over Alice: Create Group
    Alice->>Alice: MlsGroupManager::create_group()
    Alice->>MsgSvc: CreateGroup(group_id, name)

    Note over Alice: Add Members
    Alice->>MsgSvc: Get KeyPackages for Bob, Carol
    MsgSvc-->>Alice: [KeyPackage_Bob, KeyPackage_Carol]
    Alice->>Alice: mls_group.add_member(Bob)
    Alice->>Alice: mls_group.add_member(Carol)
    Alice->>MsgSvc: Send Welcome messages

    MsgSvc->>Bob: Welcome for Bob
    MsgSvc->>Carol: Welcome for Carol

    Bob->>Bob: MlsGroupManager::join_group(welcome)
    Carol->>Carol: MlsGroupManager::join_group(welcome)

    Note over Alice,Carol: Encrypted Group Message
    rect rgb(200, 255, 200)
        Alice->>Alice: mls_group.create_message("Hello group!")
        Alice->>MsgSvc: SendGroupMessage(group_id, mls_ciphertext)
        MsgSvc->>ScyllaDB: Store encrypted message
        MsgSvc->>NATS: Publish to group channel

        NATS->>Bob: Message notification
        NATS->>Carol: Message notification

        Bob->>Bob: mls_group.process_message()<br/>→ "Hello group!"
        Carol->>Carol: mls_group.process_message()<br/>→ "Hello group!"
    end
```

---

## Key Storage and Management

### Key Storage Architecture

```mermaid
graph TB
    subgraph "Client-Side (Secure Storage)"
        direction TB
        SecureStorage[Secure Enclave / Keychain]

        IK_Priv[Identity Private Key<br/>Ed25519]
        SPK_Priv[Signed Pre-Key Private<br/>X25519]
        OPK_Priv[One-Time Pre-Keys Private<br/>X25519 × 100]
        DR_State[Double Ratchet States<br/>Per conversation]
        MLS_State[MLS Group States<br/>Per group]

        SecureStorage --> IK_Priv
        SecureStorage --> SPK_Priv
        SecureStorage --> OPK_Priv
        SecureStorage --> DR_State
        SecureStorage --> MLS_State
    end

    subgraph "Server-Side (TiKV)"
        direction TB

        KeyBundles[(Key Bundles<br/>Public keys only)]
        MLSPackages[(MLS Key Packages<br/>Public packages)]

        subgraph "Stored Data"
            IK_Pub[Identity Public Key]
            SPK_Pub[Signed Pre-Key Public]
            SPK_Sig[SPK Signature]
            OPK_Pub[One-Time Pre-Keys Public]
            KP[MLS Key Packages]
        end

        KeyBundles --> IK_Pub
        KeyBundles --> SPK_Pub
        KeyBundles --> SPK_Sig
        KeyBundles --> OPK_Pub
        MLSPackages --> KP
    end

    subgraph "Message Storage (ScyllaDB)"
        Messages[(Encrypted Messages<br/>Ciphertext only)]

        Note1[Server CANNOT decrypt:<br/>- No access to private keys<br/>- No access to shared secrets<br/>- Only stores opaque blobs]
    end

    style SecureStorage fill:#50C878,stroke:#333,stroke-width:2px
    style Messages fill:#FF6B6B,stroke:#333,stroke-width:2px
```

### Key Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Generated: User Registration

    state "Identity Key" as IK {
        Generated --> Active: Published to server
        Active --> Active: Never rotates<br/>(unless compromised)
        Active --> Revoked: Device removed
    }

    state "Signed Pre-Key" as SPK {
        Generated --> Published: Upload to server
        Published --> Active: In use
        Active --> Rotating: Age > 1-4 weeks
        Rotating --> Published: New SPK generated
        Active --> Deleted: After rotation period
    }

    state "One-Time Pre-Key" as OPK {
        Generated --> Queued: Batch of 100
        Queued --> Used: Consumed by initiator
        Used --> Deleted: Immediately
        Queued --> Replenished: Count < 50
    }

    state "Double Ratchet Keys" as DR {
        Initial --> Ratcheting: X3DH complete
        Ratcheting --> Ratcheting: Every message exchange
        Ratcheting --> Deleted: Message key used
    }
```

---

## Security Properties

### Encryption Guarantees

```mermaid
graph TB
    subgraph "Security Properties"
        FS[Forward Secrecy<br/>Compromised key can't decrypt<br/>past messages]
        PCS[Post-Compromise Security<br/>Session heals after<br/>temporary compromise]
        Deniability[Deniability<br/>Cannot prove who<br/>sent a message]
        Auth[Authentication<br/>Verified sender identity<br/>via signatures]
    end

    subgraph "Enabled By"
        X3DH_P[X3DH Protocol]
        DR_P[Double Ratchet]
        MLS_P[OpenMLS]
    end

    X3DH_P --> FS
    X3DH_P --> Auth
    DR_P --> FS
    DR_P --> PCS
    DR_P --> Deniability
    MLS_P --> FS
    MLS_P --> PCS
    MLS_P --> Auth

    style FS fill:#50C878
    style PCS fill:#50C878
    style Deniability fill:#50C878
    style Auth fill:#50C878
```

### What the Server CAN and CANNOT See

```mermaid
graph LR
    subgraph "Server CAN See"
        Metadata[Metadata]
        M1[Who messages whom]
        M2[Message timestamps]
        M3[Message sizes]
        M4[Group membership]
        M5[Online/offline status]
    end

    subgraph "Server CANNOT See"
        Content[Content]
        C1[Message text]
        C2[Attachments]
        C3[Call content]
        C4[Private keys]
        C5[Session secrets]
    end

    Metadata --> M1
    Metadata --> M2
    Metadata --> M3
    Metadata --> M4
    Metadata --> M5

    Content --> C1
    Content --> C2
    Content --> C3
    Content --> C4
    Content --> C5

    style Metadata fill:#FFD93D
    style Content fill:#50C878
```

### Cryptographic Primitive Summary

| Primitive          | Algorithm   | Key Size | Purpose                  |
| ------------------ | ----------- | -------- | ------------------------ |
| Identity Signing   | Ed25519     | 256-bit  | Long-term identity       |
| Key Agreement      | X25519      | 256-bit  | Diffie-Hellman           |
| Message Encryption | AES-256-GCM | 256-bit  | Symmetric encryption     |
| Key Derivation     | HKDF-SHA256 | 256-bit  | Derive keys from secrets |
| MLS AEAD           | AES-128-GCM | 128-bit  | Group message encryption |
| MLS Signatures     | Ed25519     | 256-bit  | Group operations         |

---

## Implementation References

### Backend (Rust)

| File                                          | Description                      |
| --------------------------------------------- | -------------------------------- |
| `backend/crates/crypto/src/x3dh.rs`           | X3DH key exchange implementation |
| `backend/crates/crypto/src/double_ratchet.rs` | Double Ratchet algorithm         |
| `backend/crates/crypto/src/mls.rs`            | OpenMLS group encryption         |
| `backend/crates/crypto/src/key_storage.rs`    | Key storage interface            |

### Flutter Client (Dart)

| File                                           | Description                              |
| ---------------------------------------------- | ---------------------------------------- |
| `client/lib/core/crypto/double_ratchet.dart`   | Double Ratchet + X25519KeyPair           |
| `client/lib/core/crypto/x3dh.dart`             | X3DH key exchange + IdentityKeyPair      |
| `client/lib/core/crypto/crypto_service.dart`   | High-level encryption service            |
| `client/lib/core/crypto/crypto_exceptions.dart`| Crypto-specific exception types          |

### Protocol Definitions

| File                            | Description                     |
| ------------------------------- | ------------------------------- |
| `backend/proto/auth.proto`      | Key bundle upload/download RPCs |
| `backend/proto/messaging.proto` | Encrypted message handling RPCs |

---

## Further Reading

- [Signal Protocol Specification](https://signal.org/docs/)
- [OpenMLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/)
- [X3DH Key Agreement Protocol](https://signal.org/docs/specifications/x3dh/)
- [Double Ratchet Algorithm](https://signal.org/docs/specifications/doubleratchet/)
- [Guardyn Implementation Plan](./IMPLEMENTATION_PLAN.md)
