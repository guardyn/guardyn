---
id: roadmap-state
type: roadmap
status: accepted
owns: [docs/roadmap/roadmap.yaml]
read_when: [asking where the work is, reporting at a gate]
tokens: 1012
supersedes: []
---

# State

**Generated from [`roadmap.yaml`](roadmap.yaml) by `just docs-state`. Do not hand-edit** -
`docs-verify` check 6 regenerates this file and fails on any difference.

## Progress

| Phase | Done | Total | |
|---|---|---|---|
| 1 | 19 | 19 | `██████████` |
| 2 | 7 | 7 | `██████████` |
| 3 | 62 | 70 | `█████████░` |
| 4 | 0 | 13 | `░░░░░░░░░░` |
| **all** | **88** | **109** | |

## Position

- **Current phase:** 3
- **Next gate:** G4
- **Open steps:** 21 of 109

## Gates

| Gate | After | Phase | Status |
|---|---|---|---|
| G1 | PR-17 | 1 | passed |
| G2 | PR-23 | 2 | passed |
| G3 | PR-35 | 3 | passed |
| G4 | PR-44 | 4 | not-reached |

## Invariants

| # | Name | Met | Closed by |
|---|---|---|---|
| I-1 | Zero-Knowledge | partial | — |
| | | | *rate_limit.rs logs a raw IP; span fields are not redacted* |
| I-2 | Always-On E2EE | partial | PR-30, PR-31a, PR-31b, PR-32a, PR-32b, PR-32c, PR-75, PR-76, PR-77, PR-78, PR-79, PR-80, PR-80b, PR-81, PR-81b, PR-81c |
| | | | *no switch can disable encryption - E2EE-FLAG passes and rules-verify enforces it - no client path transmits plaintext, and client-desktop one-to-one messaging now runs over the encrypted path. Remaining: mobile groups refuse for want of MLS* |
| I-3 | Post-Quantum | false | PR-36, PR-37, PR-38, PR-39, PR-40 |
| I-4 | Data Sovereignty | partial | — |
| | | | *envoy/ingress.yaml hardcodes a domain* |

## Open steps

| Step | Phase | Issue | Title |
|---|---|---|---|
| PR-56 | 3 | [#188](https://github.com/guardyn/guardyn/issues/188) | Regenerate or drop the stale client-desktop protobuf |
| PR-62 | 3 | [#191](https://github.com/guardyn/guardyn/issues/191) | Clear the 132 client-desktop clippy errors |
| PR-63 | 3 | [#192](https://github.com/guardyn/guardyn/issues/192) | Reconcile the desktop coverage thresholds with reality |
| PR-65 | 3 | [#199](https://github.com/guardyn/guardyn/issues/199) | Stop Build Linux flaking in linuxdeploy |
| PR-95 | 3 | [#255](https://github.com/guardyn/guardyn/issues/255) | X3DHPrekeyMessage one-time key id endianness differs between Rust and Dart |
| PR-82 | 3 | [#211](https://github.com/guardyn/guardyn/issues/211) | Add an FFI-backed mobile CI job |
| PR-83 | 3 | [#268](https://github.com/guardyn/guardyn/issues/268) | Clear the 314 flutter analyze info diagnostics |
| PR-89 | 3 | [#235](https://github.com/guardyn/guardyn/issues/235) | group_chat_page_test renders a replica of the page, not the page |
| PR-36 | 4 | [#47](https://github.com/guardyn/guardyn/issues/47) | Extend protos with ML-KEM key material fields |
| PR-37 | 4 | [#48](https://github.com/guardyn/guardyn/issues/48) | Persist and serve ML-KEM public keys in auth-service |
| PR-38 | 4 | [#49](https://github.com/guardyn/guardyn/issues/49) | Enable the pq feature across backend services |
| PR-39 | 4 | [#50](https://github.com/guardyn/guardyn/issues/50) | Wire PqxdhProtocol into messaging-service session establishment |
| PR-40 | 4 | [#51](https://github.com/guardyn/guardyn/issues/51) | Add fuzz, proptest and bench coverage for the hybrid PQ path |
| PR-41 | 4 | [#52](https://github.com/guardyn/guardyn/issues/52) | Make rate limiting distributed or document the single-replica constraint |
| PR-42 | 4 | [#53](https://github.com/guardyn/guardyn/issues/53) | Fix the inverted secrets gitignore |
| PR-43 | 4 | [#54](https://github.com/guardyn/guardyn/issues/54) | Wire the compose observability stack |
| PR-44 | 4 | [#55](https://github.com/guardyn/guardyn/issues/55) | Deployment parity - call-service k8s Deployment and image digest pins |
| PR-96 | 4 | [#257](https://github.com/guardyn/guardyn/issues/257) | kube-bootstrap races the cert-manager webhook CA |
| PR-91 | 4 | [#241](https://github.com/guardyn/guardyn/issues/241) | Generate docs/INDEX.md and the tokens: counts |
| PR-93 | 4 | [#246](https://github.com/guardyn/guardyn/issues/246) | Consume the one-time pre-key that GetKeyBundle serves |
| PR-94 | 4 | [#253](https://github.com/guardyn/guardyn/issues/253) | Partition client-desktop SecureStorage per account |
