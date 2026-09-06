# Guardyn AI Coding Instructions

> **This file is a pointer, not a source of truth.**
>
> The authoritative agent constitution is **[`AGENTS.md`](../AGENTS.md)** at the repository
> root. It is tool-agnostic and governs Copilot, Claude Code, Cursor, Devin and every other
> agent working here.
>
> **Read [`AGENTS.md`](../AGENTS.md) before writing any code.**

This file previously held 684 lines that duplicated project rules. That duplication was the
problem it now solves: the copy drifted from reality (it documented Go comment conventions
for a project with no Go, and a `cicd/` directory that no longer exists), and nothing
enforced it. Rules now live in exactly one place.

## What moved where

| Topic | Now in |
|---|---|
| Invariants (Zero-Knowledge, Always-On E2EE, Post-Quantum, Data Sovereignty) | [`AGENTS.md`](../AGENTS.md) §1 |
| Git workflow, branch naming, PR budget, approval gates | [`AGENTS.md`](../AGENTS.md) §2 |
| Language policy (English only) | [`AGENTS.md`](../AGENTS.md) §3 |
| Zero-knowledge logging rules | [`AGENTS.md`](../AGENTS.md) §4 |
| Rust standards, Protocol Buffers naming, datastore policy | [`AGENTS.md`](../AGENTS.md) §5 |
| Domain-agnostic architecture (`${DOMAIN}`) | [`AGENTS.md`](../AGENTS.md) §6 |
| File organization and naming | [`AGENTS.md`](../AGENTS.md) §7 |
| Testing requirements (property-based, fuzzing) | [`AGENTS.md`](../AGENTS.md) §8 |

## The three rules you cannot get wrong

1. **Never commit to `main`.** Branch, PR, and let CI run. `main` is protected by a ruleset.
2. **Never disable encryption**, and never log a payload, a key, or PII.
3. **English only**, in code, comments, commits and documentation.

## Current work

[`implementation_plan.md`](../implementation_plan.md) — a 44-step, 4-gate refactoring.
Board: <https://github.com/orgs/guardyn/projects/3>
