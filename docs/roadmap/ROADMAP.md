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

Each phase is a **GitHub Milestone** titled `Phase N — …`, naming its gate. That is the only
place phase is recorded: the `phase:1`…`phase:4` labels were retired in PR-21, and the custom
`Phase` field on the Project v2 board goes with them. One fact, one encoding — and the
milestone is the encoding that gives a progress bar and a board grouping without maintenance.

## The two unmet invariants

Stated first, because they are the most important facts about the current state and the
reason phases 3 and 4 exist.

| Invariant | State | Closed by |
|---|---|---|
| **I-2** Always-On E2EE | server-side encryption removed, no flag remains, no client transmits plaintext, and desktop one-to-one messaging runs over the encrypted path; **mobile groups still refuse for want of MLS** | PR-30′, PR-31a–d, PR-32a–c, PR-75–PR-81c (Phase 3) |
| **I-3** Post-Quantum | `pq` is off by default and no proto field carries an ML-KEM key, so no server can publish one | PR-36…PR-40 (Phase 4) |

Until those land, **the product must not be described as always-encrypted or
post-quantum protected.**

**I-2 is a client problem now.** The server became a pure relay in Phase 3
([ADR-0010](../adr/ADR-0010-pure-relay-server.md)), which moved the whole burden onto the
clients — and neither carries it. `client-desktop` sends plaintext in `encrypted_content`
(#163) and a second plaintext copy over WebSocket; `client-mobile` *falls back* to plaintext
whenever encryption fails, and sends group messages unencrypted while the UI renders an MLS
padlock over them. The Dart client is also still on the pre-[ADR-0011](../adr/ADR-0011-ratchet-header-authentication.md)
wire format, so Dart and Rust cannot decrypt each other at all. PR-67…PR-83 repair this, and
mobile CI is pulled forward out of PR-44 because none of it was under test.

**I-2's scope changed during Phase 3.** The row above used to read "`GUARDYN_E2EE_ENABLED` still
exists and the non-E2EE handler is the registered one", which had the fix backwards: the `_e2ee`
handlers encrypted *server-side*, so the registered unsuffixed handler was already the relay.
PR-32 is therefore three deletion steps rather than a collapse, and PR-30 and PR-31 are
re-scoped with it. [ADR-0010](../adr/ADR-0010-pure-relay-server.md) records the architecture;
`implementation_plan.md` §6.3 records the two false premises the original scoping rested on.

The remaining gap is on the client, not the server: `client-desktop` puts plaintext in
`encrypted_content` (#163), which the server used to encrypt on its behalf. PR-32c is blocked on
that.

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
exists as the repository secret `GUARDYN_PROJECT_TOKEN`, roadmap-to-**board** sync ships
guarded and inert. This needs a human.

The blast radius is smaller than it was. Issue state and milestones are plain REST and
reconcile with the ambient token, so `roadmap-sync` and `pr-link` both do real work today;
only the Project v2 half waits. Two board operations remain manual regardless of the token:
deleting the `Phase` field, and grouping the board view by Milestone — GitHub's
`updateProjectV2View` mutation accepts a name, layout, filter and visible fields, but has no
input for grouping.
