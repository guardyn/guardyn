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
| **Issue state** | `status: done` closes with `state_reason: completed`; anything else reopens |
| **Milestone** | from `phase: N`. Written only on mismatch |
| **Project v2 board** | blocked - see P-1 below |
| **`type:` and `gate:` labels** | **not reconciled.** Set them when you create the issue |

## Before you change a `status`

> **A `status:` that disagrees with its issue is a live hazard, not a cosmetic one.** The
> script reconciles issue state *from* the file, so a stale `todo` **reopens a
> correctly-closed issue**. This has already happened once: PR-06 through PR-18 stayed `todo`
> after merging, and would have reopened thirteen issues on the first write-mode run.

Check the file against reality before writing:

```sh
gh issue list --state all --limit 200 --json number,state --jq '.[] | "\(.number) \(.state)"'
```

## P-1 - the board half cannot run

`project_sync_enabled: false` in the YAML. The Project v2 board needs `GUARDYN_PROJECT_TOKEN`
with `repo` + `project` scope, which no agent can create: the organization rejects
fine-grained PATs over a 366-day lifetime, and the fallback OAuth token has no project scope.

The flag gates **the board only**. Issue state and milestones reconcile either way, because
both are plain REST and need only the ambient token.

Do not work around this. Do not create the token, do not edit the board by hand, and do not
flip the flag until the secret exists. It is preflight **P-1** in `implementation_plan.md`,
and it is a human's to resolve.

## Adding a step

New steps get an issue too - one micro-step is one branch, one PR, one issue. Set
`issue: null`, run the dry sync to see what it would create, then record the number the
issue actually gets. Never retro-fit a second step onto an existing issue.

## See also

- [`docs/ops/RUNBOOK.md`](../../../docs/ops/RUNBOOK.md) - the operational view, and `pr-link`
- [`.claude/rules/10-git-workflow.md`](../../rules/10-git-workflow.md) - the micro-step contract
- `infra/scripts/roadmap-sync.sh` - the mechanism itself
