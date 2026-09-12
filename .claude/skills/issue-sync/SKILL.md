---
name: issue-sync
description: Move the roadmap forward - change a step's status, add a step, or record an issue or PR id. Use whenever GitHub Issues, milestones or the project board need to reflect a change in the plan. Edits docs/roadmap/roadmap.yaml and reconciles GitHub to it; never touches the platform by hand.
---

# issue-sync

`docs/roadmap/roadmap.yaml` is the machine source of truth for the roadmap. GitHub is a
**projection** of it. This skill is the only supported way to change either.

## The law

**Never edit an issue, milestone or board card by hand.** Edit the YAML and let
`roadmap-sync` move the platform. Hand-edits produce two states that disagree with no way to
tell which is right, and the next sync silently reverts whichever one you made.

That includes closing an issue in the web UI. Set `status: done` instead.

## The loop

```sh
$EDITOR docs/roadmap/roadmap.yaml   # 1. change the desired state
just roadmap-sync                   # 2. dry run - prints the plan, writes nothing
just roadmap-sync 0                 # 3. write
just roadmap-sync 0                 # 4. must report "0 changed" - proves it converged
```

Step 2 is not optional. It is the only place a mistake is free.

Step 4 is the real test. `roadmap-sync` reconciles rather than appends, so a correct run is
idempotent. If the second write still reports changes, something outside the YAML is moving
and you need to find out what before running again.

## What a step looks like

One line, a flow mapping, parsed with `sed` - keep it on one line or the parser will not see
it:

```yaml
- {id: PR-19, issue: 30, phase: 2, type: feat, status: todo, gate: G2, title: "Add pr-link.yml"}
```

| Field | Meaning |
|---|---|
| `id` | `PR-NN`, the step id from `implementation_plan.md` |
| `issue` | the GitHub issue number, or `null` before one exists |
| `phase` | `1`-`4`. Selects the milestone titled `Phase N - ...` |
| `status` | `todo` \| `in-progress` \| `review` \| `done` \| `blocked`. Only `done` closes the issue |
| `gate` | present only on the last step of a phase |

## What the sync reconciles, and what it does not

| | |
|---|---|
| **Issue creation** | a step with `issue: null` gets one, titled `<id> · <title>`, carrying its `type:` and `gate:` labels. The number is written back onto that step's line |
| **Issue state** | `status: done` closes with `state_reason: completed`; anything else reopens |
| **Milestone** | from `phase: N`. Written only on mismatch |
| **Project v2 board** | blocked - see P-1 below |
| **Issue titles and bodies** | **not reconciled.** Set at creation; editing a title afterwards needs `gh issue edit` |
| **`type:` and `gate:` labels** | applied at creation, **not reconciled** afterwards |

## Before you change a `status`

> **A `status:` that disagrees with its issue is a live hazard, not a cosmetic one.** The
> script reconciles issue state *from* the file, so a stale `todo` **reopens a
> correctly-closed issue**. This has already happened once: PR-06 through PR-18 stayed `todo`
> after merging, and would have reopened thirteen issues on the first write-mode run.

**The dry run now checks this for you.** As of #180 it reads each issue's real state and
names every divergence before anything is written, so `just roadmap-sync` is the check rather
than a restatement of the file. It previously printed the *desired* state back at you and
counted every step as "already correct", which is why the hazard above needed a separate
command:

```sh
gh issue list --state all --limit 200 --json number,state --jq '.[] | "\(.number) \(.state)"'
```

That command is still a fine second opinion, but the dry run is no longer blind to what it
would answer.

## P-1 - the board half runs locally, not in CI

Two things gate the board, and they are no longer in the same state:

- `project_sync_enabled` is **`true`** in the YAML. This section used to say `false`.
- `GUARDYN_PROJECT_TOKEN` must be set. In a developer's environment it is, so the board
  reconciles from a local run. As a **repository secret** it still does not exist, so
  `roadmap-sync.yml` skips the board half and exits 0.

The flag and the token gate **the board only**. Issue creation, issue state and milestones
reconcile either way - all three are plain REST and need only the ambient token.

Do not work around this. Do not edit the board by hand, and do not treat a CI run that
reports no board activity as a failure. The remaining half of preflight **P-1** in
`implementation_plan.md` is a human's to resolve.

## Adding a step

New steps get an issue too - one micro-step is one branch, one PR, one issue. Set
`issue: null` and run the loop; the write run creates the issue and records its number back
onto that step's line. Never retro-fit a second step onto an existing issue.

**This used to be a manual step, and the instruction described a capability that did not
exist.** Until #180 the script printed `would create` and moved on - in write mode as well as
dry - so every number was recorded by hand, and the run still reported success for the issue
it had not opened. If you find a step still carrying `issue: null` after a write run, that is
a bug, not the design.

Creation adopts before it creates: an issue already titled `<id> · <title>` is taken rather
than duplicated. That is what makes the pass safe to run from CI, where the checkout is
discarded and the write-back is lost - so a lost write-back costs an extra search, never a
duplicate issue.

## See also

- [`docs/ops/RUNBOOK.md`](../../../docs/ops/RUNBOOK.md) - the operational view, and `pr-link`
- [`.claude/rules/10-git-workflow.md`](../../rules/10-git-workflow.md) - the micro-step contract
- `infra/scripts/roadmap-sync.sh` - the mechanism itself
