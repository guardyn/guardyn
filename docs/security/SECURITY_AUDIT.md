# Security Audit Preparation

## Overview

This document provides comprehensive information for security auditors reviewing Guardyn's security implementation. Guardyn is a privacy-focused secure communication platform with end-to-end encryption (E2EE) for messaging, voice, and video calls.

## Table of Contents

1. [Cryptographic Architecture](#cryptographic-architecture)
2. [Key Management](#key-management)
3. [Authentication and Authorization](#authentication-and-authorization)
4. [Rate Limiting and Abuse Prevention](#rate-limiting-and-abuse-prevention)
5. [Data Protection](#data-protection)
6. [Infrastructure Security](#infrastructure-security)
7. [Threat Model](#threat-model)
8. [Security Testing](#security-testing)

---

## 1. Cryptographic Architecture

### 1.1 Overview

All cryptographic operations are implemented in a single Rust crate: `guardyn-crypto`, ensuring:

- Single source of truth for all platforms
- Consistent security guarantees
- Easier auditing
- No crypto drift between platforms

### 1.2 Key Exchange (X3DH + ML-KEM Hybrid)

**Protocol:** Post-Quantum Extended Triple Diffie-Hellman (PQXDH)

| Component         | Algorithm  | Security Level |
| ----------------- | ---------- | -------------- |
| Classical KEM     | X25519     | 128-bit        |
| Post-Quantum KEM  | ML-KEM-768 | NIST Level 3   |
| Signature         | Ed25519    | 128-bit        |
| Combined Security | Hybrid     | 192-bit+       |

**Key Bundle Structure:**

```
IdentityKey    = Ed25519 public key (32 bytes)
SignedPreKey   = X25519 public key (32 bytes) + signature (64 bytes)
OneTimePreKey  = X25519 public key (32 bytes) + ML-KEM-768 encapsulation key
```

### 1.3 Message Encryption (Double Ratchet)

**Protocol:** Signal Protocol Double Ratchet with AES-256-GCM

| Parameter            | Value       |
| -------------------- | ----------- |
| Ratchet DH           | X25519      |
| Symmetric Cipher     | AES-256-GCM |
| KDF                  | HKDF-SHA512 |
| Chain Key Derivation | HMAC-SHA256 |
| Message Key Size     | 256 bits    |

### 1.4 Group Encryption (MLS)

**Protocol:** Messaging Layer Security (RFC 9420)

| Parameter            | Value                                               |
| -------------------- | --------------------------------------------------- |
| Cipher Suite         | MLS_128_DHKEMX25519_CHACHA20POLY1305_SHA256_Ed25519 |
| Epoch Key Derivation | MLS Key Schedule                                    |
| Group Size           | Up to 1000 members                                  |
| Rekeying             | On member add/remove                                |

### 1.5 Voice/Video Encryption (SFrame)

**Protocol:** Secure Frames (draft-ietf-sframe)

| Parameter      | Value                                        |
| -------------- | -------------------------------------------- |
| Frame Cipher   | AES-256-CTR                                  |
| Authentication | HMAC-SHA256                                  |
| Key Derivation | MLS (for group calls) / Double Ratchet (1:1) |

### 1.6 Traffic Analysis Protection (PADMÉ)

**Implementation:** PADMÉ padding scheme

| Parameter         | Value                |
| ----------------- | -------------------- |
| Padding Algorithm | Power-of-two buckets |
| Minimum Size      | 1024 bytes           |
| Maximum Overhead  | 103%                 |
| Constant-time     | Yes                  |

---

## 2. Key Management

### 2.1 Key Hierarchy

```
Master Secret (hardware-backed when available)
    │
    ├── Identity Key (Ed25519)
    │   └── Long-term device identity
    │
    ├── Signed PreKey (X25519)
    │   └── Rotated every 7-30 days
    │
    └── One-Time PreKeys (X25519 + ML-KEM)
        └── Single-use, replenished periodically
```

### 2.2 Key Storage

| Platform          | Storage Mechanism        | Protection        |
| ----------------- | ------------------------ | ----------------- |
| iOS               | Secure Enclave           | Hardware          |
| Android           | StrongBox KeyStore / TEE | Hardware/Firmware |
| Desktop (Windows) | TPM 2.0 + DPAPI          | Hardware          |
| Desktop (macOS)   | Secure Enclave           | Hardware          |
| Desktop (Linux)   | TPM 2.0 / Secret Service | Hardware/Software |

### 2.3 Key Rotation

| Key Type         | Rotation Period     | Trigger                 |
| ---------------- | ------------------- | ----------------------- |
| Identity Key     | Never (per-device)  | Device reinstall        |
| Signed PreKey    | 7-30 days           | Automatic               |
| One-Time PreKeys | Single-use          | Automatic replenishment |
| MLS Epoch Keys   | Per group operation | Member add/remove       |
| Session Keys     | Per message         | Double Ratchet          |

---

## 3. Authentication and Authorization

### 3.1 Authentication Flow

1. **Registration:**
   - Phone/email verification (OTP)
   - Identity key generation
   - Key bundle upload

2. **Login:**
   - Credential verification
   - JWT token issuance (short-lived: 15 min)
   - Refresh token (device-bound)

3. **Device Verification:**
   - QR code or comparison codes
   - Cross-signing with identity key

### 3.2 Token Security

| Token              | Lifetime   | Storage        | Revocation               |
| ------------------ | ---------- | -------------- | ------------------------ |
| Access Token (JWT) | 15 minutes | Memory only    | Not revocable            |
| Refresh Token      | 30 days    | Secure storage | Server-side revocation   |
| Device Token       | Indefinite | Secure storage | On logout/device removal |

### 3.3 Authorization Model

- **RBAC:** Role-based access for groups (admin, member)
- **Capability-based:** Fine-grained permissions per resource
- **Zero-trust:** All requests authenticated and authorized

---

## 4. Rate Limiting and Abuse Prevention

### 4.1 Rate Limit Configuration

| Endpoint     | Limit   | Window | Burst | Blocking  |
| ------------ | ------- | ------ | ----- | --------- |
| Login        | 5 req   | 60s    | 2     | IP-based  |
| Register     | 3 req   | 1h     | 0     | IP-based  |
| Message Send | 60 req  | 60s    | 10    | User + IP |
| Media Upload | 20 req  | 60s    | 5     | User + IP |
| Search       | 30 req  | 60s    | 10    | User + IP |
| General API  | 300 req | 60s    | 50    | User + IP |

### 4.2 Abuse Detection

| Attack            | Detection Method  | Response                     |
| ----------------- | ----------------- | ---------------------------- |
| Brute Force       | Failed auth count | Progressive delay + IP block |
| Registration Spam | IP frequency      | CAPTCHA + IP block           |
| Message Flooding  | Rate monitoring   | Throttle + warning           |
| API Scraping      | Request patterns  | Rate limit + block           |

### 4.3 Implementation

- **Algorithm:** Sliding window with burst allowance
- **Tracking:** Per-IP and per-user
- **Headers:** `X-RateLimit-Remaining`, `Retry-After`
- **Response:** 429 Too Many Requests / 403 Forbidden

See: [docs/security/RATE_LIMITING.md](RATE_LIMITING.md)

---

## 5. Data Protection

### 5.1 Data at Rest

| Data Type | Encryption            | Location             |
| --------- | --------------------- | -------------------- |
| Messages  | E2EE (sender key)     | ScyllaDB             |
| Media     | E2EE (attachment key) | MinIO/S3             |
| Keys      | Device encryption     | Local secure storage |
| Metadata  | Minimal collection    | TiKV                 |

### 5.2 Data in Transit

| Connection      | Protocol         | Certificate |
| --------------- | ---------------- | ----------- |
| Client ↔ Server | TLS 1.3          | ECDSA P-256 |
| Server ↔ Server | mTLS             | Internal CA |
| gRPC            | HTTP/2 + TLS 1.3 | ECDSA P-256 |

### 5.3 Data Retention

| Data Type    | Retention              | User Control          |
| ------------ | ---------------------- | --------------------- |
| Messages     | Until deleted by user  | Disappearing messages |
| Media        | Until deleted by user  | Auto-delete option    |
| Account Data | Until account deletion | Full export/delete    |
| Logs         | 90 days                | N/A (no user data)    |

---

## 6. Infrastructure Security

### 6.1 Deployment

- **Orchestration:** Kubernetes with hardened security policies
- **Network:** Cilium CNI with network policies
- **Secrets:** SOPS + Age encryption
- **Container:** Distroless base images
- **Signing:** Cosign for image signatures

### 6.2 Network Segmentation

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet                              │
└──────────────────────────┬──────────────────────────────────┘
                           │
                    ┌──────┴──────┐
                    │   Envoy     │ (TLS termination, rate limit)
                    │   Ingress   │
                    └──────┬──────┘
                           │
    ┌──────────────────────┼──────────────────────┐
    │                 apps namespace               │
    │  ┌─────────┐  ┌─────────┐  ┌─────────┐     │
    │  │  Auth   │  │  Msg    │  │  Media  │     │
    │  │ Service │  │ Service │  │ Service │     │
    │  └────┬────┘  └────┬────┘  └────┬────┘     │
    └───────┼────────────┼───────────┼───────────┘
            │            │           │
    ┌───────┴────────────┴───────────┴───────────┐
    │               data namespace                │
    │  ┌─────────┐  ┌─────────┐  ┌─────────┐     │
    │  │  TiKV   │  │ ScyllaDB│  │ Redpanda│     │
    │  └─────────┘  └─────────┘  └─────────┘     │
    └─────────────────────────────────────────────┘
```

### 6.3 Security Policies

- **Pod Security Standards:** Restricted profile
- **Network Policies:** Deny-all default, explicit allows
- **RBAC:** Least privilege for service accounts
- **Resource Limits:** CPU/memory limits on all pods

---

## 7. Threat Model

### 7.1 Adversary Classes

| Adversary          | Capabilities       | Goals                |
| ------------------ | ------------------ | -------------------- |
| Passive Network    | Traffic analysis   | Metadata extraction  |
| Active Network     | MITM attempts      | Message interception |
| Compromised Server | Full server access | Data exfiltration    |
| Malicious User     | Valid account      | Abuse/harassment     |
| Nation-State       | Advanced resources | Mass surveillance    |

### 7.2 Security Guarantees

| Guarantee                | Against            | Implementation               |
| ------------------------ | ------------------ | ---------------------------- |
| Confidentiality          | Network/Server     | E2EE (X3DH + Double Ratchet) |
| Integrity                | Tampering          | AEAD (AES-256-GCM)           |
| Forward Secrecy          | Key compromise     | Ratcheting                   |
| Post-Compromise Security | Session compromise | Ratcheting                   |
| Metadata Protection      | Server             | Sealed Sender (planned)      |
| Quantum Resistance       | Future threats     | ML-KEM hybrid                |

### 7.3 Known Limitations

| Limitation                     | Risk             | Mitigation               |
| ------------------------------ | ---------------- | ------------------------ |
| Server learns sender/recipient | Metadata leak    | Sealed Sender (roadmap)  |
| Device compromise              | Full access      | Device verification, PIN |
| Backup exposure                | Historical data  | Encrypted backups        |
| Social engineering             | Account takeover | 2FA, verification codes  |

---

## 8. Security Testing

### 8.1 Automated Testing

| Test Type         | Coverage             | Frequency    |
| ----------------- | -------------------- | ------------ |
| Unit Tests        | Crypto primitives    | Every commit |
| Integration Tests | Protocol flows       | Every PR     |
| Fuzzing           | Parsers, crypto      | Weekly       |
| SAST              | Code vulnerabilities | Every commit |
| Dependency Scan   | Known CVEs           | Daily        |

### 8.2 Manual Testing

| Test Type           | Scope                  | Frequency |
| ------------------- | ---------------------- | --------- |
| Code Review         | Security-critical code | Every PR  |
| Penetration Testing | Full application       | Quarterly |
| Red Team Exercise   | Full infrastructure    | Annually  |

### 8.3 Bug Bounty

**Program:** [details to be added]

| Severity | Reward Range     |
| -------- | ---------------- |
| Critical | $5,000 - $20,000 |
| High     | $2,000 - $5,000  |
| Medium   | $500 - $2,000    |
| Low      | $100 - $500      |

---

## Appendix

### A. Cryptographic Library Dependencies

| Library          | Version | Purpose              | Audit Status      |
| ---------------- | ------- | -------------------- | ----------------- |
| ring             | 0.17+   | TLS primitives       | Audited           |
| ed25519-dalek    | 2.0+    | Signatures           | Audited           |
| x25519-dalek     | 2.0+    | Key exchange         | Audited           |
| ml-kem           | 0.2+    | Post-quantum KEM     | NIST standardized |
| aes-gcm          | 0.10+   | Symmetric encryption | Audited           |
| chacha20poly1305 | 0.10+   | Symmetric encryption | Audited           |
| hkdf             | 0.12+   | Key derivation       | Audited           |

### B. Security Contact

- **Security Issues:** security@yourdomain.com
- **PGP Key:** [link to PGP key]
- **Response Time:** 24-48 hours

### C. Document History

| Version | Date    | Changes                     |
| ------- | ------- | --------------------------- |
| 1.0     | 2024-01 | Initial document            |
| 1.1     | 2024-12 | Added rate limiting section |
