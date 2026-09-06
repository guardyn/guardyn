---
id: rules-git-workflow
type: rules
status: accepted
owns: [.github/, CONTRIBUTING.md]
read_when: [before any commit, before opening a PR, starting a micro-step]
---

# 10 · Git workflow

Predicates for [`AGENTS.md`](../../AGENTS.md) §2 and `implementation_plan.md` §3.

**Convention: every check prints its violations. Empty output means PASS.**

| ID | Predicate |
|---|---|
| `GIT-NOTMAIN` | `HEAD` is not `main` or `master` |
| `GIT-BRANCH` | Branch is `<type>/<issue>-<slug>`, `<type>` ∈ `feat fix docs refactor chore security` |
| `GIT-BUDGET` | The branch changes ≤400 lines **or** ≤8 files against `origin/main` |
| `GIT-CLOSES` | The PR body contains exactly one `Closes #N` |
| `GIT-SCOPE` | The PR body states what was deliberately left out of scope |

```sh
echo "GIT-NOTMAIN"; git branch --show-current | grep -xE 'main|master'
echo "GIT-BRANCH";  git branch --show-current \
                      | grep -vE '^(feat|fix|docs|refactor|chore|security)/[0-9]+-[a-z0-9-]+$'
echo "GIT-BUDGET";  git diff --numstat origin/main...HEAD \
                      | awk '{a+=$1; d+=$2; f++} END {if (f>8 && a+d>400)
                              printf "over budget: %d files, %d lines\n", f, a+d}'
```

`GIT-CLOSES` and `GIT-SCOPE` are read off the PR body, not the tree.

## The budget is a ceiling on *hand-written* work

Bulk deletions and generated or vendored files do not count — but a PR that invokes that
exemption must contain **nothing else**. If the exemption is not needed, do not invoke it:
state the real numbers in the PR body instead.

`GIT-BUDGET` prints only when *both* limits are exceeded, because the contract is
"≤400 lines **or** ≤8 files". A 12-file, 90-line documentation PR is inside budget; a
2-file, 900-line one is not.

## Splitting

A step that will exceed budget is split **before** the branch is opened, not after the diff
grows. Each half gets its own issue: one micro-step is one branch, one PR, one issue. Never
retro-fit a second step onto an existing issue.

## Gates

Phases end at **G1–G4**. At a gate: stop, post the phase report, and wait for explicit user
approval. Never begin the next phase unprompted — not even the first "obviously safe" step
of it.

## What must never happen

- A commit directly on `main` or `master`.
- A force-push to `main` (blocked by the `main-protection` ruleset, but do not test it).
- A history rewrite of any kind without explicit user approval ([`AGENTS.md`](../../AGENTS.md) §10).
- A test weakened or deleted to turn CI green ([`AGENTS.md`](../../AGENTS.md) §8).
