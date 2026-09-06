# CLAUDE.md

**[`AGENTS.md`](AGENTS.md) is the authoritative agent constitution. Read it first.**

This file exists only so Claude Code loads the two rules that must never be missed. It
deliberately does not duplicate `AGENTS.md` — duplication is how two sources of truth are
born.

## Never commit to `main`

`main` is protected by a ruleset requiring a pull request. Before any commit:

```sh
git branch --show-current   # must NOT be main or master
```

One micro-step = one branch = one PR = one issue. Branch: `<type>/<issue>-<slug>`.
PR budget: ≤400 hand-written lines or ≤8 files — split before opening if exceeded.

## Invariants — non-negotiable

| # | Invariant |
|---|---|
| I-1 | **Zero-Knowledge** — no payload, key, or PII in any log, trace or metric. |
| I-2 | **Always-On E2EE** — encryption can never be disabled. |
| I-3 | **Post-Quantum** — hybrid X25519 + ML-KEM-768 key agreement. |
| I-4 | **Data Sovereignty** — 100% self-hostable, no vendor lock-in. |

I-2 and I-3 are **currently violated** and under repair by owned steps (PR-32 and
PR-36…PR-40). Do not patch them ad hoc. See `AGENTS.md` §1.

## Current work

[`implementation_plan.md`](implementation_plan.md) — 44 steps, 4 gates.
Board: <https://github.com/orgs/guardyn/projects/3>

At a gate: **STOP. Report. Wait for explicit user approval.**
