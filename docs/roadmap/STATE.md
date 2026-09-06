---
id: roadmap-state
type: roadmap
status: accepted
owns: [docs/roadmap/roadmap.yaml]
read_when: [asking where the work is, reporting at a gate]
tokens: 397
supersedes: []
---

# State

**Generated from [`roadmap.yaml`](roadmap.yaml). Do not hand-edit** — `docs-verify` fails
if this file and the YAML disagree. Regenerate instead.

Generated: 2026-09-06

## Progress

| Phase | Done | Total | |
|---|---|---|---|
| 1 | 7 | 19 | `████░░░░░░` |
| 2 | 0 | 6 | `░░░░░░░░░░` |
| 3 | 0 | 12 | `░░░░░░░░░░` |
| 4 | 0 | 9 | `░░░░░░░░░░` |
| **all** | **7** | **46** | |

## Position

- **Current phase:** 1
- **Next gate:** G1, after PR-17
- **Next step:** PR-06 — Add .claude/settings.json guard hooks and pre-commit hook (#17)

## Gates

| Gate | After | Status |
|---|---|---|
| G1 | PR-17 | not reached |
| G2 | PR-23 | not reached |
| G3 | PR-35 | not reached |
| G4 | PR-44 | not reached |

## Invariants

| # | Name | Met | Closed by |
|---|---|---|---|
| I-1 | Zero-Knowledge | partial | — |
| | | | *2 services log outside init_tracing; rate_limit.rs logs a raw IP* |
| I-2 | Always-On E2EE | False | PR-32 |
| I-3 | Post-Quantum | False | PR-36, PR-37, PR-38, PR-39, PR-40 |
| I-4 | Data Sovereignty | partial | — |
| | | | *envoy/ingress.yaml hardcodes a domain* |

## Blocked

**P-1** — `project_sync_enabled: false`. No token available to CI can read or write the
project board, so roadmap-to-board sync cannot run. Needs a human to create
`GUARDYN_PROJECT_TOKEN` with `repo` + `project` scope.
