---
id: roadmap
type: roadmap
status: accepted
owns: [implementation_plan.md]
read_when: [planning, answering when, questioning sequencing]
tokens: 804
supersedes: []
---

# Roadmap

Narrative view. [`roadmap.yaml`](roadmap.yaml) is the machine source of truth that drives
issues and the project board; [`STATE.md`](STATE.md) is generated progress telemetry. When
this file and `roadmap.yaml` disagree, the YAML wins.

This roadmap absorbs the section that used to live in `README.md`, where nothing kept it
honest.

## Shipped — v1.0.1

- Six backend services: auth, messaging, presence, media, call, notification.
- Cryptography: X3DH, Double Ratchet, OpenMLS 0.6, sealed sender, PADMÉ padding, and a
  hybrid PQXDH implementation.
- Mobile clients (iOS, Android) and desktop clients (Windows, macOS, Linux).
- One-to-one voice and video calls with SFrame media encryption.
- Kubernetes deployment with Kustomize overlays, and a Docker Compose single-machine path.

**Shipped means the code exists and runs.** It does not mean every invariant holds — see
below.

## In progress — the 44-step revision

[`implementation_plan.md`](../../implementation_plan.md) is the execution charter: 44
micro-steps across four phases, each ending at an approval gate.

| Phase | Steps | Theme | Gate |
|---|---|---|---|
| 1 | PR-01…PR-17 | Purge legacy docs; agent contract; documentation core; CI truthfulness | **G1** |
| 2 | PR-18…PR-23 | Board sync, SSOT rules, protobuf unification | G2 |
| 3 | PR-24…PR-35 | Zero-knowledge logging, store hygiene, E2EE repair, fuzzing | G3 |
| 4 | PR-36…PR-44 | Hybrid PQXDH end to end, launch optimization | G4 |

Phases 1 and 2 touch no source code. Phase 3 carries the security-critical work. Phase 4
closes invariant I-3.

## The two unmet invariants

Stated first, because they are the most important facts about the current state and the
reason phases 3 and 4 exist.

| Invariant | State | Closed by |
|---|---|---|
| **I-2** Always-On E2EE | `GUARDYN_E2EE_ENABLED` still exists and the non-E2EE handler is the registered one | PR-32 (Phase 3) |
| **I-3** Post-Quantum | `pq` is off by default and no proto field carries an ML-KEM key, so no server can publish one | PR-36…PR-40 (Phase 4) |

Until those land, **the product must not be described as always-encrypted or
post-quantum protected.**

## After the revision

- External security audit. An audit before the invariants hold would audit the wrong
  system.
- Group calls, which need an SFU.
- App store submission and public beta.
- A browser client — Envoy currently routes three of six services.

Sequencing beyond G4 is deliberately not dated here. Dates belong on the board, where
they can be revised without a documentation change.

## Blocked

**P-1 — project automation has no usable credential.** The board at
<https://github.com/orgs/guardyn/projects/3> cannot be read or written by any token
available to CI: the fine-grained PAT is rejected outright by the organization, and the
fallback OAuth token lacks `read:project`. Until a token with `repo` + `project` scope
exists as the repository secret `GUARDYN_PROJECT_TOKEN`, roadmap-to-board sync (PR-18)
ships guarded and inert. This needs a human.
