# Guardyn MVP Implementation Plan

## Project Overview

**Guardyn** is a privacy-focused, end-to-end encrypted (E2EE) messaging platform designed for the modern security landscape. This MVP establishes a foundation for secure, real-time communication with strong cryptographic guarantees.

### Key Differentiators

- **Security-First**: E2EE messaging (X3DH/Double Ratchet/OpenMLS), audio/video calls, group chat with cryptographic verification
- **Infrastructure**: Kubernetes-native with TiKV, ScyllaDB, NATS JetStream

## 🎯 Current Status (Updated: November 3, 2025)

### Completed Work ✅

- **TiKV cluster deployed** (Placement Driver + TiKV nodes in `data` namespace)
- **ScyllaDB cluster** (3 nodes, datacenter `dc1`)
- **NATS JetStream** (with 4 streams: MESSAGES, PRESENCE, NOTIFICATIONS, MEDIA)
- **Cert-manager** (for TLS certificate automation)

### 🔄 **Backend Services Ready (Phase 4)**

- **Kubernetes Manifests**: All 5 services configured ✅
- **Service Infrastructure**: Health checks, TLS, secrets ready ✅
- **Database Connections**: TiKV/Scylla connectivity configured ✅
- **Code Implementation**: Service logic pending implementation

### 🔐 **Cryptography Crate (Phase 6)**

- **Crate Structure**: Module organization complete ✅
- **Dependencies**: libsignal-protocol, OpenMLS, x25519-dalek, ed25519-dalek configured ✅
- **X3DH Scaffold**: Key bundle structure defined, implementation pending
- **Double Ratchet Scaffold**: Interface defined, implementation pending
- **MLS Scaffold**: Group manager structure defined, implementation pending
- **Key Storage**: Basic interface defined, secure storage pending

### ⏳ **Next Priorities**

1. ✅ Database schemas ready (TiKV for users/sessions, ScyllaDB for messages/media)
2. ✅ gRPC API definitions complete (.proto files)
3. Implement X3DH key agreement protocol
4. Implement Double Ratchet encryption/decryption
5. Implement authentication service business logic

---

## Phase 1: Foundation & Infrastructure ✅ (Partially Complete)

### 1.1 Documentation & Planning ✅

- [x] Product vision document (`docs/mvp_discovery.md`)

- [x] User stories and personas defined

- [x] Security requirements documented

- [x] Infrastructure PoC guide (`docs/infra_poc.md`)

- [ ] Formal cryptographic specifications (ProVerif/Tamarin models)

- [ ] TLA+ specifications for message ordering

### 1.2 Repository Structure ✅

- [x] Project directory structure created

- [x] Infrastructure manifests (`infra/k8s/`)

- [x] CI/CD workflows skeleton (`cicd/github/`)

- [x] Justfile automation setup

- [x] Nix flake for reproducible builds

- [x] SOPS configuration for secrets

### 1.3 Local Development Environment ✅ (Complete)

- [x] Install development tools:

  - [x] `just` (v1.43.0)
  - [x] `k3d` (v5.8.3)
  - [x] `kubectl` (v1.34.0)
  - [x] `helm` (v3.19.0)
  - [x] `kustomize` (v5.7.1)
  - [x] `sops` (v3.11.0)
  - [x] `age` (v1.2.1)

- [x] Fix k3d cluster creation issues

- [x] Verify cluster bootstrapping

- [x] Test all infrastructure components

### 1.4 Kubernetes Cluster Setup ✅ (Complete)

- [x] **FIXED**: Resolved k3d cluster creation (volumeMounts config issue)

- [x] Create local k3d cluster (3 servers + 2 agents)

- [x] Bootstrap core namespaces (`platform`, `data`, `messaging`, `observability`, `apps`)

- [x] Deploy cert-manager

- [x] Use K3s built-in CNI (skipped Cilium for MVP)

- [x] Verify cluster health

---

## Phase 2: Data & Messaging Infrastructure ✅ (Complete)

#### 2.1 Database Schemas

- Database schema design for TiKV and ScyllaDB

**Tasks**:

1. ScyllaDB Schema (Message History):

   - [ ] Create keyspace with replication strategy
   - [ ] Messages table with partition by user/conversation
   - [ ] Media metadata table
   - [ ] Delivery receipts table (denormalized for fast queries)

2. TiKV Key-Value Schema Design:
   - [ ] Define TiKV keyspace for users and sessions

### 2.2 Messaging Infrastructure ✅

- [x] Deploy NATS JetStream

  - [x] Configure 3-node cluster
  - [x] Create streams for messaging (MESSAGES, PRESENCE, NOTIFICATIONS, MEDIA)
  - [x] Set up retention policies
  - [x] Configure TLS certificates

- [x] Test pub/sub functionality

- [x] Implement message queuing patterns

### 2.3 Secrets Management ✅ (Complete)

- [x] Generate Age encryption keys

- [x] Configure SOPS with Age public keys

- [ ] Deploy HashiCorp Vault (optional for production)

- [x] Encrypt sensitive configuration files

- [x] Document secret rotation procedures

---

## Phase 3: Observability Stack ✅ (Complete)

### 3.1 Monitoring ✅

- [x] Deploy Prometheus operator

- [x] Configure service monitors

- [ ] Set up alerting rules

- [x] Create performance dashboards

### 3.2 Logging ✅

- [x] Deploy Loki stack

- [ ] Configure log aggregation

- [ ] Set up log retention policies

- [ ] Create log query dashboards

### 3.3 Tracing

- [ ] Deploy Tempo

- [ ] Configure OpenTelemetry collector

- [ ] Instrument services for distributed tracing

- [ ] Create trace analysis dashboards

### 3.4 Visualization ✅

- [x] Deploy Grafana

- [ ] Import monitoring dashboards

- [x] Configure data sources (Prometheus, Loki, Tempo)

- [ ] Set up user access controls

---

## Phase 4: Backend Services (Rust) 🔄 (In Progress - 90% Complete)

### 4.1 Authentication Service ✅ (Implementation Complete)

- [x] Create service scaffold

- [x] Deploy Kubernetes manifests

- [x] Configure TLS certificates

- [x] Connect to secrets management

- [x] **Implement user registration** ✅ (Nov 8, 2025)

- [x] **Implement login/logout** ✅ (Nov 8, 2025)

- [x] **Device management** ✅ (Nov 8, 2025)

- [x] **Session handling** ✅ (Nov 8, 2025)

- [x] **Token generation/validation (JWT)** ✅ (Nov 8, 2025)

- [x] **TiKV database integration** ✅ (Nov 8, 2025)

- [ ] Integration with Secure Enclave/HSM

- [x] **Integration tests** ✅ (Nov 8, 2025)

### 4.2 Messaging Service ✅ (Implementation Complete - Nov 9, 2025)

- [x] Create service scaffold

- [x] Deploy Kubernetes manifests

- [x] Configure database connections

- [x] **TiKV + ScyllaDB integration** ✅ (Nov 8, 2025)

- [x] **NATS JetStream client** ✅ (Nov 8, 2025)

- [x] **SendMessage handler** ✅ (Nov 8, 2025)

- [x] **GetMessages handler** ✅ (Nov 8, 2025)

- [x] **MarkAsRead handler** ✅ (Nov 8, 2025)

- [x] **DeleteMessage handler** ✅ (Nov 8, 2025)

- [x] **ReceiveMessages streaming** ✅ (Nov 9, 2025)

- [x] **Message routing logic** ✅ (Nov 9, 2025)

- [x] **Delivery guarantees** ✅ (NATS + TiKV delivery state)

- [x] **Offline message queuing** ✅ (TiKV pending messages)

- [x] **Group chat logic** ✅ (Nov 9, 2025)
  - [x] CreateGroup handler
  - [x] AddMember handler
  - [x] RemoveMember handler
  - [x] SendGroupMessage handler (with ScyllaDB persistence)
  - [x] GetGroupMessages handler (with ScyllaDB retrieval)
  - [x] NATS fanout for group message delivery

- [x] **Group message persistence** ✅ (Nov 9, 2025)
  - [x] ScyllaDB schema (group_messages table)
  - [x] Storage implementation (store_group_message)
  - [x] Retrieval implementation (get_group_messages)

- [x] **Integration tests** ✅ (Nov 9, 2025)
  - [x] Docker Compose setup with auth + messaging services
  - [x] 1-on-1 messaging tests (send, receive, mark as read, delete)
  - [x] Offline message delivery test
  - [x] Group chat flow test (create, send, retrieve)

### 4.3 Presence Service ✅

- [x] Create service scaffold

- [x] Deploy Kubernetes manifests

- [ ] Online/offline status tracking

- [ ] Last seen timestamps

- [ ] Typing indicators

- [ ] Read receipts

### 4.4 Media Service ✅

- [x] Create service scaffold

- [x] Deploy Kubernetes manifests

- [x] Configure persistent storage

- [ ] File upload/download handling

- [ ] Media storage (S3-compatible/MinIO)

- [ ] Thumbnail generation

- [ ] Media encryption/decryption

- [ ] Streaming support

### 4.5 Notification Service ✅

- [x] Create service scaffold

- [x] Deploy Kubernetes manifests

- [ ] Push notification integration (FCM, APNs)

- [ ] Notification delivery logic

- [ ] Silent push for message sync

- [ ] Notification preferences

---

## Phase 5: Real-Time Communication (RTC) ⏳

### 5.1 Signaling Server

- [ ] WebRTC signaling implementation

- [ ] STUN/TURN server setup

- [ ] ICE candidate exchange

- [ ] SDP offer/answer handling

### 5.2 Media Server (SFU)

- [ ] Deploy Jellyfish or LiveKit SFU

- [ ] Configure media routing

- [ ] Implement adaptive bitrate

- [ ] Set up recording capabilities

### 5.3 E2EE Media Encryption

- [ ] Implement SFrame encryption

- [ ] Key distribution via MLS

- [ ] Insertable Streams API integration

- [ ] Audio/video frame encryption

### 5.4 Call Features

- [ ] 1-on-1 voice calls

- [ ] 1-on-1 video calls

- [ ] Group voice calls (≤4 participants MVP)

- [ ] Group video calls (≤4 participants MVP)

- [ ] Screen sharing

- [ ] Call quality metrics

---

## Phase 6: Cryptography Implementation 🔄 (In Progress)

### 6.1 Key Exchange & Session Setup

- [x] Create crypto crate structure

- [x] Add X3DH key bundle structure

- [ ] Implement X3DH protocol (initial key agreement)

- [ ] Identity key generation

- [ ] Signed pre-keys

- [ ] One-time pre-keys

- [ ] Key bundle publishing

### 6.2 Message Encryption (1-on-1)

- [x] Add libsignal-protocol dependency

- [x] Create Double Ratchet module structure

- [ ] Double Ratchet implementation (libsignal)

- [ ] Message encryption/decryption

- [ ] Key rotation logic

- [ ] Out-of-order message handling

- [ ] Forward secrecy guarantees

### 6.3 Group Chat Encryption

- [x] Add OpenMLS dependency

- [x] Create MLS module structure

- [ ] MLS (OpenMLS) integration

- [ ] Group creation/join/leave

- [ ] Member addition/removal

- [ ] Epoch management

- [ ] Tree synchronization

### 6.4 Post-Quantum Cryptography

- [ ] Integrate Kyber (PQC KEM)

- [ ] Hybrid ECDH + Kyber key exchange

- [ ] Update key agreement protocols

### 6.5 Cryptographic Verification

- [ ] Safety number generation

- [ ] QR code verification

- [ ] Fingerprint comparison UI

- [ ] Transparency log integration

---

## Phase 7: Client Applications ⏳

### 7.1 Core Client Library (Rust)

- [ ] Network layer (QUIC/WebTransport)

- [ ] Cryptography wrappers

- [ ] Message serialization (Protocol Buffers/FlatBuffers)

- [ ] Local database (SQLite encrypted)

- [ ] State synchronization

- [ ] FFI bindings for mobile

### 7.2 Android Client (Kotlin Multiplatform)

- [ ] Project setup with KMP

- [ ] UI implementation (Jetpack Compose)

- [ ] Rust core integration via JNI

- [ ] Background service for push notifications

- [ ] Media capture/playback

- [ ] Native API access (Bluetooth, NFC)

- [ ] Secure Enclave integration

### 7.3 iOS Client (SwiftUI)

- [ ] Project setup

- [ ] UI implementation (SwiftUI)

- [ ] Rust core integration via FFI

- [ ] Background notification handling

- [ ] Media capture/playback

- [ ] Native API access

- [ ] Keychain & Secure Enclave integration

### 7.4 Desktop Client (Tauri + Rust)

- [ ] Windows build

- [ ] macOS build

- [ ] Linux build

- [ ] UI framework (Tauri with web frontend)

- [ ] System tray integration

- [ ] Notifications

- [ ] Auto-updates

### 7.5 Web Client (WebAssembly)

- [ ] Rust core compiled to WASM

- [ ] Web UI (React/Vue/Svelte)

- [ ] WebRTC integration

- [ ] IndexedDB for local storage

- [ ] Service Worker for offline support

- [ ] Progressive Web App (PWA) manifest

---

## Phase 8: CI/CD & Security Automation ⏳

### 8.1 Build Pipeline

- [ ] Reproducible builds with Nix

- [ ] Multi-platform compilation

- [ ] Artifact generation (binaries, containers)

- [ ] SBOM generation (Syft)

- [ ] Dependency scanning

- [ ] License compliance checks

### 8.2 Security Scanning

- [ ] Static analysis (clippy, cargo-audit)

- [ ] SAST tools integration

- [ ] Dependency vulnerability scanning (Trivy)

- [ ] Container image scanning

- [ ] Secret detection (Gitleaks)

### 8.3 Testing Automation

- [ ] Unit tests

- [ ] Integration tests

- [ ] E2E tests (k6, Playwright)

- [ ] Fuzz testing (cargo-fuzz)

- [ ] Load testing (k6 + WebRTC harness)

- [ ] Security tests (penetration testing automation)

### 8.4 Signing & Verification

- [ ] Code signing with Cosign (Sigstore)

- [ ] Container image signing

- [ ] Binary signing for all platforms

- [ ] Transparency log publishing

- [ ] Verification documentation

### 8.5 Deployment Automation

- [ ] ArgoCD setup for GitOps

- [ ] Canary deployments

- [ ] Rollback procedures

- [ ] Smoke tests post-deployment

- [ ] Production monitoring alerts

---

## Phase 9: Testing & Quality Assurance ⏳

### 9.1 Functional Testing

- [ ] User registration/login flows

- [ ] 1-on-1 messaging

- [ ] Group messaging

- [ ] Voice/video calls

- [ ] Media sharing

- [ ] Device synchronization

### 9.2 Performance Testing

- [ ] Message latency benchmarks (<100ms target)

- [ ] Call quality metrics (latency <150ms)

- [ ] Concurrent user load tests

- [ ] Database throughput tests

- [ ] Network resilience tests

### 9.3 Security Testing

- [ ] Cryptographic protocol verification (ProVerif/Tamarin)

- [ ] Penetration testing

- [ ] Fuzzing critical paths

- [ ] Side-channel attack analysis

- [ ] Threat modeling (STRIDE)

### 9.4 Compatibility Testing

- [ ] Cross-platform client testing

- [ ] Browser compatibility (web client)

- [ ] OS version compatibility

- [ ] Network condition testing (3G, 4G, 5G, WiFi)

---

## Phase 10: Documentation & Audit Preparation ⏳

### 10.1 Technical Documentation

- [ ] Architecture diagrams

- [ ] API documentation (OpenAPI/Swagger)

- [ ] Database schemas

- [ ] Deployment guides

- [ ] Troubleshooting runbooks

### 10.2 Security Documentation

- [ ] Cryptographic protocol specifications

- [ ] Threat model documentation

- [ ] Security controls matrix

- [ ] Incident response plan

- [ ] Data retention policies

### 10.3 User Documentation

- [ ] User guides (per platform)

- [ ] Privacy policy

- [ ] Terms of service

- [ ] FAQ

- [ ] Support documentation

### 10.4 Audit Preparation

- [ ] Code repository organization

- [ ] Cryptographic primitives isolation

- [ ] Test coverage reports

- [ ] Security scan results compilation

- [ ] Reproducible build verification guide

- [ ] Contact security auditors (Cure53, Symbolic Software, Fallible)

- [ ] Prepare audit scope document

---

## Phase 11: MVP Launch Preparation ⏳

### 11.1 Beta Testing

- [ ] Recruit beta testers (internal + external)

- [ ] Set up feedback channels

- [ ] Bug tracking and triage

- [ ] Performance monitoring

- [ ] User behavior analytics (privacy-respecting)

### 11.2 Production Infrastructure

- [ ] Multi-cloud/bare-metal Kubernetes setup

- [ ] Load balancing configuration

- [ ] CDN integration (if needed)

- [ ] Backup and disaster recovery

- [ ] Monitoring and alerting at scale

### 11.3 Compliance & Legal

- [ ] GDPR compliance review

- [ ] Data protection impact assessment (DPIA)

- [ ] Terms of service finalization

- [ ] Privacy policy finalization

- [ ] Export compliance (cryptography regulations)

### 11.4 Launch Checklist

- [ ] Final security audit completed

- [ ] All critical bugs resolved

- [ ] Performance benchmarks met

- [ ] Documentation complete

- [ ] Support infrastructure ready

- [ ] Marketing materials prepared

- [ ] App store submissions (iOS, Android)

- [ ] Public announcement plan

---

## Current Status & Immediate Next Steps

### ✅ Completed

- Project structure and documentation foundation
- Development tools installation (just, k3d, kubectl, helm, kustomize, sops, age)
- Infrastructure manifests created
- CI/CD workflow skeletons
- **k3d cluster creation and bootstrapping**
- **NATS JetStream deployment**
- **TiKV cluster deployment**
- **ScyllaDB operator deployment**
- **Observability stack (Prometheus, Grafana, Loki)**
- **Rust workspace structure for backend services**
- **Cryptography crate scaffold with libsignal and OpenMLS**
- **X3DH, Double Ratchet, and MLS module structures created**

### 🔄 In Progress

- Backend service implementation (auth, messaging, presence, media, notification)
- Cryptography protocol implementation (X3DH, Double Ratchet, MLS)
- Database schema design for TiKV and ScyllaDB

### 🚨 Immediate Blockers

**NONE** - All critical infrastructure is operational!

### 📋 Next Actions (Priority Order)

#### Critical (This Week)

1. **Database schema design**

   - [ ] Define TiKV keyspace for users and sessions
   - [ ] Define ScyllaDB schema for messages and media
   - [ ] Create migration scripts

2. **Cryptography implementation**

   - [x] Complete crypto crate structure
   - [x] Add X3DH key bundle structure
   - [x] Add Double Ratchet module
   - [x] Add MLS module
   - [ ] Implement X3DH key agreement
   - [ ] Implement Double Ratchet encryption
   - [ ] Write comprehensive crypto tests

3. **Authentication service**
   - [ ] User registration endpoint
   - [ ] Login/logout logic
   - [ ] JWT token generation
   - [ ] Device management

#### High Priority (Next Week)

1. **Messaging service core**

   - [ ] Message routing logic
   - [ ] TiKV integration for delivery state
   - [ ] ScyllaDB integration for history
   - [ ] NATS JetStream pub/sub

2. **gRPC API definitions** ✅

   - [x] Define .proto files for all services (auth, messaging, presence, common)
   - [x] Generate Rust code from protos (build.rs configured)
   - [ ] Implement API endpoints

3. **Testing infrastructure**
   - [ ] Unit tests for crypto primitives
   - [ ] Integration tests for services
   - [ ] Load testing setup (k6)

#### Medium Priority (This Month)

1. **Observability integration**

   - [ ] Add OpenTelemetry tracing to services
   - [ ] Create Grafana dashboards
   - [ ] Set up alerting rules

2. **Security hardening**
   - [ ] TLS/mTLS for all service communication
   - [ ] Secrets management with SOPS
   - [ ] Rate limiting and DDoS protection

---

## Team Roles & Responsibilities

### Product & Tech Lead

- OKR management and roadmap updates
- Requirements gathering and audit coordination
- Stakeholder communication

### Architecture & Security Lead

- Cryptographic design and protocol review
- Formal specifications (ProVerif, Tamarin, TLA+)
- Security audits coordination

### Backend Team (Rust)

- **Messaging/Auth Services**: Core service implementation
- **DevOps Engineer**: Kubernetes, CI/CD, infrastructure automation
- **Database Administrator**: TiKV, ScyllaDB optimization

### RTC/Media Team

- WebRTC/SFU integration
- Media pipeline development (Rust + C++)
- Load testing and performance QA

### Client Team

- **Mobile**: Kotlin Multiplatform, SwiftUI developers
- **Desktop**: Tauri/Rust developer
- **Web**: WebAssembly + frontend developer
- **UI/UX Designer**: Design system and user experience

### Infrastructure/Observability

- SRE for Kubernetes operations
- Secrets management (Vault, SOPS)
- Monitoring and alerting

### QA & Security

- Test automation
- Fuzzing and penetration testing
- Security audit coordination

---

## Sprint Rhythm (2-week sprints)

- **Sprint 0**: Environment setup, CI/CD, standards
- **Sprint 1**: Auth + basic chat + client prototypes
- **Sprint 2+**: Incremental features, security hardening, media integration
- **Mid-sprint reviews**: Progress check-ins
- **End-of-sprint**: Demos and retrospectives

---

## OKR Framework (Example Q1 2025)

### Objective 1: Establish Secure Infrastructure

- **KR1**: Local k3d PoC operational with all core services (NATS, TiKV, Scylla)
- **KR2**: 99.9% uptime for messaging service in local environment
- **KR3**: Complete observability stack with <5min mean-time-to-detect

### Objective 2: Implement E2EE Messaging

- **KR1**: Double Ratchet 1-on-1 chat working end-to-end
- **KR2**: MLS group chat supports ≥10 members
- **KR3**: Cryptographic audit preparation complete (formal specs written)

### Objective 3: Deliver MVP Client Applications

- **KR1**: Android + iOS clients with basic chat functional
- **KR2**: Voice call latency <150ms p95
- **KR3**: Beta testing with 50+ external users

### Objective 4: Security & Compliance

- **KR1**: Reproducible builds verified for all artifacts
- **KR2**: 90%+ code coverage for cryptographic modules
- **KR3**: External security audit scheduled with Cure53

---

## Risk Management

### Technical Risks

- **Cryptography complexity**: Mitigation via formal verification and early audit
- **Performance bottlenecks**: Load testing from Sprint 2, profiling tools integrated
- **Cross-platform compatibility**: Continuous testing on all target platforms

### Operational Risks

- **Infrastructure downtime**: HA setup, disaster recovery plans
- **Dependency vulnerabilities**: Automated scanning, rapid patching process

### Security Risks

- **Cryptographic flaws**: External audits, formal specifications, bug bounty
- **Supply chain attacks**: Reproducible builds, artifact signing, SBOM generation

### Timeline Risks

- **MVP scope creep**: Strict prioritization, MVP-only features for Phase 1
- **Team scaling**: Modular architecture allows parallel development

---

## Success Metrics

### MVP Launch Criteria

- [ ] 1-on-1 E2EE chat working on Android + iOS

- [ ] Voice calls <150ms latency

- [ ] 1000+ messages/sec throughput

- [ ] <5% crash rate

- [ ] Formal cryptographic specifications published

- [ ] Security audit initiated

- [ ] 50+ beta testers onboarded

### Post-MVP Targets (6 months)

- [ ] 10,000+ active users

- [ ] Group chat with 100+ members

- [ ] Video conferencing up to 16 participants

- [ ] Desktop + web clients launched

- [ ] Security audit passed with high rating

- [ ] Bug bounty program active

---

## References

- **Product Vision**: `docs/mvp_discovery.md`
- **Infrastructure Guide**: `docs/infra_poc.md`
- **Justfile Commands**: Run `just --list` for all automation tasks
- **Kubernetes Manifests**: `infra/k8s/base/` and `infra/k8s/overlays/`
- **CI/CD Workflows**: `cicd/github/workflows/`
- **Nix Configuration**: `flake.nix`

---

## Notes

- **English-Only Policy**: All code, documentation, and communication MUST be in English per project guidelines (see `.github/copilot-instructions.md`)
- **Open Source**: All components must use OSS licenses
- **Audit-Ready**: Every architectural decision should consider external security review requirements
- **Reproducibility**: Nix flakes ensure deterministic builds across all environments

---

**Last Updated**: 2025-11-03  
**Plan Version**: 1.1  
**Status**: Infrastructure operational, cryptography scaffolding complete, implementing core protocols
