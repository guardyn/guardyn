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

**Derived from [`roadmap.yaml`](roadmap.yaml). Do not hand-edit** — when the two disagree, the
YAML wins.

> This file *claims* to be generated and to be checked by `docs-verify`. Neither is true yet:
> no generator exists and `docs-verify` has no staleness check. That is
> [#101](https://github.com/guardyn/guardyn/issues/101), and until it lands this file is
> maintained by hand and can rot between gates. It was last reconciled against the YAML and
> against GitHub on the date below.

Reconciled: 2026-09-07

## Progress

| Phase | Done | Total | |
|---|---|---|---|
| 1 | 19 | 19 | `██████████` |
| 2 | 7 | 7 | `██████████` |
| 3 | 0 | 12 | `░░░░░░░░░░` |
| 4 | 0 | 9 | `░░░░░░░░░░` |
| **all** | **26** | **47** | |

## Position

- **Current phase:** 2 — complete
- **Next gate:** **G2, reached** after PR-23. Awaiting explicit user approval.
- **Next step:** PR-24 — Add `common/src/redact.rs` (#35), and it must not start before G2 is
  approved.

## Gates

| Gate | After | Status |
|---|---|---|
| G1 | PR-17 | **passed** |
| G2 | PR-23 | **reached — awaiting approval** |
| G3 | PR-35 | not reached |
| G4 | PR-44 | not reached |

## Invariants

Unchanged by Phase 2, which touched tracking and build strategy rather than behaviour.

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
Project v2 board: the organization rejects fine-grained PATs over a 366-day lifetime, and the
fallback OAuth token has no `project` scope. Needs a human to create `GUARDYN_PROJECT_TOKEN`
with `repo` + `project` scope.

Its blast radius shrank in Phase 2. Phase is now tracked by **milestones**, which are plain
REST, so `roadmap-sync` and `pr-link` both do real work with the ambient token; only the board
half waits.

## Carried into Phase 3

| | |
|---|---|
| [#116](https://github.com/guardyn/guardyn/issues/116) | Phase 1 straggler — `desktop-build.yml` test job can never pass |
| [#101](https://github.com/guardyn/guardyn/issues/101) | `docs-verify` has no staleness check, and this file is maintained by hand because of it |
