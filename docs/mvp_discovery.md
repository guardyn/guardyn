# MVP Discovery Package

## 1. Personas and Core User Stories

- **Everyday Communicator**
  - As a privacy-focused user, I want to create secure 1:1 chats in under 10 seconds so that I can start protected conversations immediately.
  - As a mobile user, I want seamless device-to-device sync so that I can resume conversations on my laptop without manual exports.
  - As a frequent caller, I want auto-upgraded audio-to-video calls so that rich communication feels effortless.
- **Group Coordinator**
  - As a community manager, I want to create moderated group channels so that I can manage large audiences with granular permissions.
  - As a power user, I want to schedule multi-party calls with calendar links so that participants join with no friction.
  - As a host, I want live reactions and low-latency streaming so that events feel interactive.
- **Enterprise Admin**
  - As an admin, I want managed identity provisioning so that onboarding/offboarding ties into existing directories.
  - As an admin, I want policy-based media retention so that compliance is enforced automatically.
  - As an admin, I want cryptographic posture reports so that audits can happen on demand.
- **Security Auditor**
  - As an external auditor, I want reproducible build artifacts so that I can verify no supply-chain tampering occurred.
  - As an auditor, I want formal protocol proofs so that I can validate the crypto claims quickly.
  - As an auditor, I want sandbox environments with real telemetry so that I can test threat models safely.
- **Creator / Broadcaster**
  - As a creator, I want to start a broadcast from mobile with one tap so that I can engage audiences instantly.
  - As a creator, I want to mix prerecorded clips during live sessions so that I can deliver polished experiences.
  - As a creator, I want tipping and interactive polls so that monetization and engagement are native.

## 2. Prioritized MVP Story Backlog

| Priority | Epic               | Story                         | Acceptance Criteria                                                           |
| -------- | ------------------ | ----------------------------- | ----------------------------------------------------------------------------- |
| P0       | Messaging Core     | Create E2EE 1:1 chat          | Contacts discoverable, keys exchanged, delivery < 500 ms on reference network |
| P0       | Sync & Identity    | Multi-device enrollment       | New device onboarding with key verification, protects against MITM            |
| P0       | Audio/Video Calls  | Initiate secure voice call    | Call setup < 2 s, voice latency < 150 ms end-to-end                           |
| P0       | Media Handling     | Share encrypted media         | Upload/download within 3 s for 10 MB file, decrypt client-side                |
| P1       | Group Messaging    | Small group MLS-backed chat   | Max 32 members, state consistent across members                               |
| P1       | Presence           | Real-time presence indicators | Presence updates propagate within 1 s                                         |
| P1       | Moderation         | Admin audit log export        | Logs signed, exportable as JSON/CSV                                           |
| P2       | Broadcasting       | Start low-latency stream      | < 2 s glass-to-glass, concurrent viewers 100                                  |
| P2       | Monetization hooks | Enable tipping                | Off-chain ledger with 3rd party integration, settlement via API               |

## 3. UX Wireframe Blueprint (Textual)

- **Onboarding Flow**: splash → phone/email verification → security key verification (QR + numeric code) → consent screens (privacy, telemetry opt-in) → device naming.
- **Home Hub**: left rail with navigation (Chats, Calls, Broadcasts, Settings), center column listing recent conversations, right info pane for contact details and shared media.
- **Chat View**: timeline with message bubbles, inline media cards, quick reaction bar; top bar shows encryption status and identity verification badge; bottom composer supports attachments, quick voice note, scheduling.
- **Call Overlay**: floating window with participant grid, adaptive to desktop/mobile; controls for mute, camera switch, screen share, live captions, E2EE indicator.
- **Broadcast Dashboard**: preview window, scene list, assets library, audience metrics mini-panel; mobile version uses collapsible drawer.
- **Settings**: tabbed layout (Account, Security, Devices, Notifications, Labs). Security tab hosts key management, device sessions, audit trails.
- **Admin Console (web)**: table view for users/devices, policy builder wizard, audit log viewer with export actions.

## 4. Security Protocol Requirements

- **Identity Establishment**: X3DH bootstrap with PQ hybrid (Kyber + ECDH P-256), device verification via QR/Numeric.
- **Session Management**: Double Ratchet for 1:1, OpenMLS for group chat and meeting spaces; rekey on membership changes.
- **Media Encryption**: WebRTC insertable streams with SFrame; keys rotated per session via MLS key schedule; media attachments encrypted using ChaCha20-Poly1305 + per-file keys stored client-side.
- **Device Lifecycle**: secure enclave storage (Secure Enclave, StrongBox, TPM), automatic key expiry, remote wipe.
- **Integrity & Telemetry**: signed logs (Ed25519), tamper-evident event store, anomaly detection hooks for brute-force/pattern monitoring.
- **Threat Modeling**: STRIDE baseline, periodic LINDDUN for privacy, red-team exercises before beta.

## 5. Audit and Certification Alignment

- **External Auditors**: Cure53 (application security), Symbolic Software (cryptography), Fallible (mobile hardening).
- **Deliverables**: architecture dossiers, formal proofs (TLA+, ProVerif, Verifpal outputs), reproducible build scripts (Nix), SBOM (SPDX) per release, test coverage reports.
- **Compliance Targets**: GDPR/DSGVO readiness, SOC 2 Type I controls for beta, ISO/IEC 27001 roadmap.
- **Schedule**:
  - Pre-alpha: internal security review + automated scans complete.
  - Alpha: deliver reproducible build artifact and protocol proofs to auditors.
  - Beta: pen-test window (6 weeks), bug bounty launch (HackerOne).
  - GA: compliance attestation, publish transparency report.

## 6. Immediate Discovery Actions

1. Validate personas and backlog with stakeholder interviews delivering prioritized requirements.
2. Produce low-fidelity wireframes for each screen and test with 5 target users per persona.
3. Finalize crypto protocol specification doc and align with security auditors for early feedback.
4. Draft audit engagement plan with timelines, deliverables, and budget approvals.
5. Feed backlog into issue tracker, mapping each story to epics and OKR owners.
