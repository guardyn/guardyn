---
id: adr-0009
type: adr
status: accepted
owns: [AGENTS.md, .claude/rules/10-git-workflow.md]
read_when: [planning work, splitting a change, opening a PR]
tokens: 430
supersedes: []
---

# ADR-0009 · Micro-step PR budget and branch isolation

## Status

`accepted`

## Context

Most of this repository is changed by AI agents, which have a finite context window. A
change large enough to exceed it forces the agent to reconstruct lost context mid-task —
the point at which it starts guessing, and where a security-critical system is least
tolerant of guesses.

Large pull requests are also harder to review and harder to revert, and those costs fall on
humans.

## Decision

One micro-step = one branch = one pull request = one issue. Branch names are
`<type>/<issue>-<slug>`. The budget is **≤400 hand-written changed lines, or ≤8 files**. A
step that would exceed it is split *before* the branch is opened.

## Consequences

A whole step — diff, tests, and the documentation it touches — fits in one session, so no
step needs its context rebuilt. Every PR is independently revertable and leaves `main`
green. Review stays tractable.

The cost is ceremony: an issue per step, and real work spread across many PRs, which makes
a large refactor look slower than it is. Bulk deletions and generated files are exempt from
the count, but such a PR must contain nothing else — otherwise the exemption becomes the
loophole that swallows the rule.

## Alternatives rejected

**Feature branches** — accumulate context until nothing fits in a window and nothing is
revertable. **Line limit only** — a 40-file, 300-line rename is inside a line budget and
still unreviewable, which is why the file count is there.
