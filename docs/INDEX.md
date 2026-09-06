---
id: index
type: index
status: accepted
owns: [docs/]
read_when: [starting any session]
tokens: 1107
supersedes: []
---

# Documentation index

**This is the only file an agent must read cold.** Everything else is reached through the
`read_when` column: match your task, load those documents, ignore the rest. A typical
session loads two or three files instead of the whole corpus — that is the point.

This file and `tokens:` counts are **generated** by `just docs-verify` (PR-15). Do not
hand-edit; change the frontmatter of the document itself.

## Read first, always

| Path | Purpose | read_when |
|---|---|---|
| [`AGENTS.md`](../AGENTS.md) | The agent constitution. Invariants, git workflow, language, logging, code standards. | starting any session, before any commit, before any PR |
| [`.claude/rules/00-invariants.md`](../.claude/rules/00-invariants.md) | I-1…I-4 as runnable predicates. | starting any session, touching crypto, changing configuration |
| [`GLOSSARY.md`](GLOSSARY.md) | Ubiquitous language; every domain term and its code symbol. | naming anything, writing a document, reviewing a proto change |

## Rules — the executable projection of AGENTS.md

| Path | Purpose | read_when |
|---|---|---|
| [`.claude/rules/10-git-workflow.md`](../.claude/rules/10-git-workflow.md) | Branch, budget and gate predicates. | before any commit, before opening a PR |
| [`.claude/rules/20-code-style.md`](../.claude/rules/20-code-style.md) | Rust, proto, language, naming and layout predicates. | writing Rust, changing a proto, adding a file |
| [`.claude/rules/30-zk-logging.md`](../.claude/rules/30-zk-logging.md) | I-1 enforcement in detail. | adding a log line, touching observability |
| [`.claude/rules/40-doc-sync.md`](../.claude/rules/40-doc-sync.md) | The documentation auto-maintenance algorithm. | changing any source file, adding a document |

## Specifications

| Path | Purpose | read_when |
|---|---|---|
| [`spec/SAD.md`](spec/SAD.md) | Architecture: crates, topology, data flow, store-per-concern. | changing service boundaries, adding a dependency between crates |
| [`spec/SRS.md`](spec/SRS.md) | The algorithmic source of truth: rules, edge cases, invariants. | implementing a handler, changing behaviour |
| [`spec/PRD.md`](spec/PRD.md) | Product features as they exist, in user-story form. | adding a feature, questioning whether something is in scope |
| [`api/INDEX.md`](api/INDEX.md) | Generated proto → service → RPC map. | calling an RPC, changing the wire contract |

## Decisions

| Path | Purpose | read_when |
|---|---|---|
| [`adr/index.md`](adr/index.md) | Every architectural decision, with status. | proposing a change to a decided thing |
| [`adr/ADR-0000-template.md`](adr/ADR-0000-template.md) | The template. Copy it; do not invent a shape. | writing an ADR |

An ADR records a decision **already embodied in the code**. Adding, replacing or removing a
datastore, bus or major dependency requires an accepted ADR *and* explicit user approval.

## Operations

| Path | Purpose | read_when |
|---|---|---|
| [`ops/DEPLOYMENT.md`](ops/DEPLOYMENT.md) | k3d and Kubernetes deployment, Kustomize overlays. | deploying, changing a manifest |
| [`ops/RUNBOOK.md`](ops/RUNBOOK.md) | Incident playbooks and on-call procedure. | an incident, a failing service |
| [`ops/OBSERVABILITY.md`](ops/OBSERVABILITY.md) | Tracing, metrics, logs and the ZK-logging rules. | adding a metric or span, debugging in production |

## Roadmap

| Path | Purpose | read_when |
|---|---|---|
| [`roadmap/ROADMAP.md`](roadmap/ROADMAP.md) | Narrative phases. | planning, answering "when" |
| [`roadmap/roadmap.yaml`](roadmap/roadmap.yaml) | **Machine source of truth**; drives issues and the project board. | changing scope or sequencing |
| [`roadmap/STATE.md`](roadmap/STATE.md) | Generated progress telemetry: current phase, gate, step. | asking where the work is |

## Security — retained, not rewritten

`docs/security/` predates this documentation base and is externally cited. It is kept in
place: `SECURITY_AUDIT.md`, `HARDENING_REVIEW.md`, `PENETRATION_TESTING.md`,
`RATE_LIMITING.md`, `SEALED_SENDER.md`, `RUST_FFI_SECURITY_AUDIT.md`, and `pgp/`.

## Not documentation

`_local/` is gitignored working material — grant applications and personal notes. It is
never deleted, never moved, and **never linked to from a tracked file**: cloners cannot see
it, so such a link is dead on arrival.
