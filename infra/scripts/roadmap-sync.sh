#!/usr/bin/env bash
#
# Roadmap sync - reconciles docs/roadmap/roadmap.yaml into GitHub Issues, their Milestones,
# and the Project v2 board. The YAML is the machine source of truth; this script moves the
# world toward it.
#
# Four passes, in descending order of how reliably they can run:
#   issue create - REST, ambient token. Only for a step whose `issue:` is null.
#   issue state  - REST, ambient token. Always runs.
#   milestone    - REST, ambient token. Always runs. `phase: N` maps to milestone "Phase N".
#   board        - GraphQL, needs a project scope no available token has yet (P-1). Guarded.
#
# Reconciling, not appending: every action is derived from the difference between the file
# and the platform, so running it twice changes nothing the second time. That property is
# what lets it run on every push to main without supervision.
#
# A dry run reads the platform too. It has to: the difference is what there is to report,
# and a dry run that only restates the file cannot find the one mistake the issue-sync skill
# warns about - a stale `status` that reopens a correctly-closed issue. Dry and write differ
# in whether `apply` executes, nothing else, and both count an action into `changed`, so
# "the second run reports 0 changed" means the same thing either way. See #180.
#
# Bash, git, gh and jq only - the same constraint docs-verify.sh works under. Adding a YAML
# parser would mean a runtime this repository does not otherwise depend on, and I-4 makes
# every added dependency a cost. The `steps:` entries are single-line flow mappings, which
# is regular enough to read with sed.
#
# Environment:
#   GUARDYN_PROJECT_TOKEN   classic PAT or App token with repo + project scope.
#                           Absent (P-1) -> the board half is skipped, issues still reconcile
#                           if GH_TOKEN can write them. Never fails CI for a missing secret.
#   GITHUB_REPOSITORY       owner/repo. Default: guardyn/guardyn
#   ROADMAP_SYNC_DRY_RUN    1 = print the plan, change nothing. Default when no token.
#
# Writes to the repository: creating an issue records its number onto that step's line in
# the roadmap file, so the file converges and the next run takes the ordinary path. That
# write is best-effort - `roadmap-sync.yml` runs with `contents: read` and cannot commit it -
# so creation does not depend on it. Idempotency comes from adopting an issue that already
# carries the title the step would use.
#
# Exit codes: 0 always, unless the roadmap file itself is unreadable or malformed. A missing
# credential is a documented state, not a build failure.

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

ROADMAP="docs/roadmap/roadmap.yaml"
REPO="${GITHUB_REPOSITORY:-guardyn/guardyn}"
DRY_RUN="${ROADMAP_SYNC_DRY_RUN:-0}"

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'; RESET=$'\033[0m'
changed=0; skipped=0; failed=0; unknown=0

say()  { printf '%s\n' "$*"; }
ok()   { printf '%s%s%s %s\n' "$GREEN" "sync" "$RESET" "$*"; changed=$((changed + 1)); }
plan() { printf '%s%s%s %s\n' "$YELLOW" "plan" "$RESET" "$*"; changed=$((changed + 1)); }
noop() { printf '%s%s%s %s\n' "$YELLOW" "same" "$RESET" "$*"; skipped=$((skipped + 1)); }
bad()  { printf '%s%s%s %s\n' "$RED" "FAIL" "$RESET" "$*" >&2; failed=$((failed + 1)); }

# Perform one reconciling write, or describe the write a dry run would perform.
#
# Dry and write differ in exactly one thing - whether the command runs - so they share this
# function rather than living in two branches that drift apart. **Both count the action into
# `changed`**, which is what makes "the second run reports 0 changed" a convergence proof.
# Before #180 a dry run counted every step into `skipped` and printed it as "already
# correct", so it agreed with itself no matter what GitHub held.
apply() {
  local what="$1"; shift
  if [ "$DRY_RUN" = "1" ]; then
    plan "$what"
    return 0
  fi
  if "$@" >/dev/null 2>&1; then
    ok "$what"
    return 0
  fi
  bad "$what"
  return 1
}

[ -r "$ROADMAP" ] || { bad "$ROADMAP is not readable"; exit 1; }

# ---------------------------------------------------------------------------------------
# Credentials
# ---------------------------------------------------------------------------------------
# P-1: the organization rejects fine-grained PATs with a lifetime over 366 days, and the
# fallback OAuth token carries no project scope. Until GUARDYN_PROJECT_TOKEN exists the
# board cannot be touched at all - so say so plainly and keep going rather than failing a
# build for a secret no agent can create.
BOARD_ENABLED=1
if [ -z "${GUARDYN_PROJECT_TOKEN:-}" ]; then
  say "${YELLOW}note${RESET} GUARDYN_PROJECT_TOKEN is unset - board sync skipped (preflight P-1)."
  say "     Issues still reconcile if the ambient token can write them."
  BOARD_ENABLED=0
fi

# Whether the platform can be *read*. Distinct from DRY_RUN, which is about writing: a dry
# run still has to read, or it cannot report a divergence. When this is 0 the script can only
# restate the file, and says so rather than reporting a comparison it never made.
GH_READY=1
if ! command -v gh >/dev/null 2>&1; then
  say "${YELLOW}note${RESET} gh is not installed - dry run only, and nothing can be compared."
  DRY_RUN=1
  GH_READY=0
elif ! gh api "repos/$REPO" --jq .full_name >/dev/null 2>&1; then
  # One probe, so an unusable token produces one honest line instead of a "#N does not
  # exist" for every step in the file.
  say "${YELLOW}note${RESET} $REPO is not readable with the ambient token - nothing can be compared."
  DRY_RUN=1
  GH_READY=0
fi

# project_sync_enabled governs the PROJECT BOARD, and nothing else. It used to force a global
# dry run, which made the issue and milestone passes unreachable while P-1 is open - a
# decorative automation of exactly the kind `continue-on-error` made of CI before PR-17.
# Issues and milestones need only the ambient token, so they run regardless.
sync_enabled="$(sed -n 's/^project_sync_enabled:[[:space:]]*//p' "$ROADMAP" | head -1)"
if [ "$sync_enabled" != "true" ]; then
  say "${YELLOW}note${RESET} project_sync_enabled is '${sync_enabled:-unset}' in $ROADMAP - board sync off."
  say "     Issue state and milestones still reconcile."
  BOARD_ENABLED=0
fi

[ "$DRY_RUN" = "1" ] && say "${YELLOW}note${RESET} dry run: nothing will be written."

# ---------------------------------------------------------------------------------------
# Read the desired state
# ---------------------------------------------------------------------------------------
# Each step is one line: {id: PR-07, issue: 18, phase: 1, type: docs, status: todo, title: "..."}
field() { sed -n "s/.*[{,][[:space:]]*$2:[[:space:]]*\\([^,}]*\\).*/\\1/p" <<<"$1" | head -1; }

steps_raw="$(sed -n '/^steps:/,/^[a-z_]*:/p' "$ROADMAP" | sed -n 's/^[[:space:]]*-[[:space:]]*{\(.*\)}[[:space:]]*$/{\1}/p')"
[ -n "$steps_raw" ] || { bad "no steps parsed from $ROADMAP - has the format changed?"; exit 1; }

total="$(printf '%s\n' "$steps_raw" | wc -l | tr -d ' ')"
say "roadmap-sync: $total step(s) in $ROADMAP, repo $REPO"

# ---------------------------------------------------------------------------------------
# Resolve the phase -> milestone map
# ---------------------------------------------------------------------------------------
# Phase is tracked by native GitHub Milestones titled "Phase N - ...", not by a phase: label
# and not by a Project v2 field. Milestones are plain REST and writable with the ambient
# token, so this pass sits OUTSIDE the board guard below: gating it on GUARDYN_PROJECT_TOKEN
# would make it dead code for a reason (P-1) that only applies to the Project v2 GraphQL API.
#
# A repository with no such milestones is a documented state, not an error - say so and let
# the issue pass run alone.
MILESTONE_MAP=""
if command -v gh >/dev/null 2>&1; then
  MILESTONE_MAP="$(gh api "repos/$REPO/milestones?state=all" --paginate \
    --jq '.[] | select(.title | test("^Phase [0-9]+ ")) |
          "\(.title | capture("^Phase (?<p>[0-9]+) ").p)\t\(.number)"' 2>/dev/null)"
fi

if [ -z "$MILESTONE_MAP" ]; then
  say "${YELLOW}note${RESET} no \"Phase N\" milestone found in $REPO - milestone pass skipped."
else
  say "milestones: $(printf '%s\n' "$MILESTONE_MAP" | wc -l | tr -d ' ') phase milestone(s) resolved"
fi

# phase number -> milestone number. Empty output means "no milestone for this phase".
milestone_for() { printf '%s\n' "$MILESTONE_MAP" | awk -F'\t' -v p="$1" '$1 == p { print $2; exit }'; }

# ---------------------------------------------------------------------------------------
# Creating an issue for a step that has none
# ---------------------------------------------------------------------------------------
# `issue: null` means "this step wants an issue and has not got one yet". Until #180 the
# script printed `would create` and `continue`d - in write mode as well as dry - so the
# capability the issue-sync skill describes did not exist, every number was recorded by
# hand, and the unexecuted branch still incremented `changed`, so a run that created nothing
# reported success.
#
# Creation has to reconcile like every other action here, or a second run appends a
# duplicate. Two things make it idempotent, and the order matters:
#
#   1. **Adopt before creating.** If an issue already carries the exact title this step
#      would use, take its number instead of opening a second one. This is the property that
#      holds in CI, where the checkout is thrown away and the write-back below is lost.
#   2. **Record the number into the YAML**, so the file converges and the next run takes the
#      ordinary path. Best effort only: `roadmap-sync.yml` runs with `contents: read` and
#      cannot commit, which is precisely why (1) rather than (2) is the safety property.
#
# Titles are `<id> · <title>`, the same string the old `would create` line printed, so an
# issue opened by hand under that convention is adopted rather than duplicated.
ISSUE_INDEX=""
ISSUE_INDEX_READY=0

# Read every issue once, lazily - only a file with a null step pays for it.
load_issue_index() {
  [ "$ISSUE_INDEX_READY" = "1" ] && return 0
  ISSUE_INDEX_READY=1
  ISSUE_INDEX="$(gh api "repos/$REPO/issues?state=all&per_page=100" --paginate \
    --jq '.[] | select(.pull_request == null) | "\(.number)\t\(.title)"' 2>/dev/null)"
}

issue_with_title() {
  printf '%s\n' "$ISSUE_INDEX" | awk -F'\t' -v t="$1" '$2 == t { print $1; exit }'
}

# The branch name the micro-step contract asks for: `feat/<issue>-pr36`.
branch_slug() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -d '-'; }

issue_body() {
  local id="$1" type="${2:-chore}"
  cat <<BODY
Opened by \`roadmap-sync\` from \`docs/roadmap/roadmap.yaml\` step $id.

That file is the source of truth for this step. Change it there and let the sync move this
issue - editing state here is reverted by the next run.

---
**Micro-step contract**
- Branch: \`$type/<issue>-$(branch_slug "$id")\`
- Budget: <=400 hand-written changed lines, or <=8 files. Split before opening if exceeded.
- Leaves \`main\` green and is independently revertable.
- Source of truth: \`docs/roadmap/roadmap.yaml\` step $id.
BODY
}

# Write the assigned number back onto this step's line, and nothing else on it.
#
# Matched on `{id: <id>,` including the comma, so `PR-8` cannot claim `PR-83`'s line, and
# the substitution touches only a literal `issue: null` - a line that already carries a
# number is left alone even if the id somehow matched twice.
record_issue_number() {
  local id="$1" number="$2" tmp
  tmp="$(mktemp)" || return 1
  awk -v id="$id" -v num="$number" '
    index($0, "{id: " id ",") && /issue:[[:space:]]*null/ {
      sub(/issue:[[:space:]]*null/, "issue: " num)
    }
    { print }
  ' "$ROADMAP" >"$tmp" || { rm -f "$tmp"; return 1; }

  # Copy through rather than `mv`: mktemp creates 0600, and moving it over a tracked file
  # would silently change that file's mode.
  cat "$tmp" >"$ROADMAP" || { rm -f "$tmp"; return 1; }
  rm -f "$tmp"
}

# Resolve a step with no issue to a number, adopting an existing issue or creating one.
#
# Sets RESOLVED_ISSUE and returns 0, or returns 1 when nothing could be resolved. It is
# deliberately NOT a function whose output is captured: `$( )` runs a subshell, and every
# `ok`/`noop`/`plan` inside one increments a counter that dies with it, so the summary would
# under-report exactly the actions this function exists to perform.
RESOLVED_ISSUE=""
resolve_issue() {
  local id="$1" title="$2" type="$3" gate="$4"
  local full="$id · $title" existing number
  local labels=()
  RESOLVED_ISSUE=""

  load_issue_index
  existing="$(issue_with_title "$full")"
  if [ -n "$existing" ]; then
    noop "$id adopted existing #$existing"
    RESOLVED_ISSUE="$existing"
    record_issue_number "$id" "$existing" \
      || say "${YELLOW}note${RESET} could not record #$existing into $ROADMAP - do it by hand."
    return 0
  fi

  if [ "$DRY_RUN" = "1" ]; then
    plan "$id has no issue -> would create \"$full\""
    return 1
  fi

  [ -n "$type" ] && labels+=(--label "type:$type")
  [ -n "$gate" ] && labels+=(--label "gate:$gate")

  # `gh issue create` prints the issue URL; the number is its last path segment. The
  # milestone is deliberately not passed here - the caller falls through to the milestone
  # pass below, so one implementation serves a new issue and an existing one alike.
  number="$(gh issue create --repo "$REPO" --title "$full" \
    --body "$(issue_body "$id" "$type")" ${labels[@]+"${labels[@]}"} 2>/dev/null \
    | sed -n 's|.*/\([0-9][0-9]*\)$|\1|p' | head -1)"

  if [ -z "$number" ]; then
    bad "$id could not create \"$full\""
    return 1
  fi

  ok "$id created #$number"
  RESOLVED_ISSUE="$number"
  record_issue_number "$id" "$number" \
    || say "${YELLOW}note${RESET} could not record #$number into $ROADMAP - do it by hand."
  return 0
}

# ---------------------------------------------------------------------------------------
# Reconcile issues
# ---------------------------------------------------------------------------------------
# status -> issue state. `done` closes with a reason; anything else must be open.
while IFS= read -r step; do
  [ -n "$step" ] || continue
  id="$(field "$step" id)"
  issue="$(field "$step" issue)"
  status="$(field "$step" status)"
  phase="$(field "$step" phase)"
  title="$(field "$step" title | sed 's/^"//; s/"$//')"

  type="$(field "$step" type)"
  gate="$(field "$step" gate)"

  want_state="open"
  [ "$status" = "done" ] && want_state="closed"

  want_ms="$(milestone_for "$phase")"

  # Nothing below can be compared without a readable platform, so restate the desired state
  # and count it as neither correct nor changed. Counting these into `skipped` is what let
  # the old dry run print "already correct" for a step it had never looked at.
  if [ "$GH_READY" = "0" ]; then
    say "  $id -> #${issue:-none} want=$want_state phase=$phase milestone=${want_ms:-none}"
    unknown=$((unknown + 1))
    continue
  fi

  if [ -z "$issue" ] || [ "$issue" = "null" ]; then
    resolve_issue "$id" "$title" "$type" "$gate" || continue
    issue="$RESOLVED_ISSUE"
  fi

  # One read serves both passes. `0` stands for "no milestone", which no real milestone
  # number can collide with, so it compares safely against an empty want_ms.
  #
  # This read sits ABOVE the dry-run branch as of #180. A dry run that never asked GitHub
  # anything printed the file back at the reader, and the issue-sync skill calls the dry run
  # "the only place a mistake is free" - the one mistake it warns about being a stale
  # `status` that reopens a correctly-closed issue, which is exactly what this comparison
  # now surfaces before anything is written.
  read -r have have_ms <<<"$(gh api "repos/$REPO/issues/$issue" \
    --jq '"\(.state) \(.milestone.number // 0)"' 2>/dev/null)"
  if [ -z "$have" ]; then
    bad "$id references #$issue which does not exist"
    continue
  fi

  if [ "$have" = "$want_state" ]; then
    noop "$id #$issue already $want_state"
  elif [ "$want_state" = "closed" ]; then
    apply "$id #$issue -> closed as completed" \
      gh api -X PATCH "repos/$REPO/issues/$issue" -f state=closed -f state_reason=completed
  else
    apply "$id #$issue -> reopened (status is '$status', not done)" \
      gh api -X PATCH "repos/$REPO/issues/$issue" -f state=open
  fi

  # Milestone. Written only on mismatch, so the second run of any pair reports `same`.
  if [ -z "$want_ms" ]; then
    :
  elif [ "$have_ms" = "$want_ms" ]; then
    noop "$id #$issue already on milestone $want_ms"
  else
    apply "$id #$issue -> milestone $want_ms" \
      gh api -X PATCH "repos/$REPO/issues/$issue" -F milestone="$want_ms"
  fi
done <<<"$steps_raw"

# ---------------------------------------------------------------------------------------
# Reconcile the project board
# ---------------------------------------------------------------------------------------
if [ "$BOARD_ENABLED" = "0" ] || [ "$DRY_RUN" = "1" ]; then
  say "${YELLOW}note${RESET} board reconciliation not attempted."
else
  project_number="$(sed -n 's/^project_number:[[:space:]]*//p' "$ROADMAP" | head -1)"
  owner="${REPO%%/*}"
  project_id="$(GH_TOKEN="$GUARDYN_PROJECT_TOKEN" gh api graphql \
    -f query='query($o:String!,$n:Int!){organization(login:$o){projectV2(number:$n){id}}}' \
    -f o="$owner" -F n="$project_number" --jq '.data.organization.projectV2.id' 2>/dev/null)"

  if [ -z "$project_id" ]; then
    bad "project $project_number not readable with GUARDYN_PROJECT_TOKEN - check its scopes"
  else
    say "board: project $project_number resolved"

    # addProjectV2ItemById is idempotent on GitHub's side: adding content that is already
    # on the board returns the existing item rather than an error. The mutation therefore
    # cannot tell us whether it changed anything, and reporting every successful call as a
    # change made the second write report the same count as the first - which is exactly
    # the convergence check the issue-sync skill asks for. So read the board once and diff
    # against it.
    on_board="$(GH_TOKEN="$GUARDYN_PROJECT_TOKEN" gh api graphql --paginate \
      -f query='query($o:String!,$n:Int!,$endCursor:String){organization(login:$o){projectV2(number:$n){items(first:100,after:$endCursor){pageInfo{hasNextPage,endCursor},nodes{content{... on Issue{number}}}}}}}' \
      -f o="$owner" -F n="$project_number" \
      --jq '.data.organization.projectV2.items.nodes[].content.number' 2>/dev/null)"

    while IFS= read -r step; do
      [ -n "$step" ] || continue
      issue="$(field "$step" issue)"
      id="$(field "$step" id)"
      [ -n "$issue" ] && [ "$issue" != "null" ] || continue
      if printf '%s\n' "$on_board" | grep -qx "$issue"; then
        noop "$id #$issue already on the board"
        continue
      fi
      node="$(gh api "repos/$REPO/issues/$issue" --jq '.node_id' 2>/dev/null)"
      [ -n "$node" ] || { bad "$id #$issue has no node id"; continue; }
      if GH_TOKEN="$GUARDYN_PROJECT_TOKEN" gh api graphql \
          -f query='mutation($p:ID!,$c:ID!){addProjectV2ItemById(input:{projectId:$p,contentId:$c}){item{id}}}' \
          -f p="$project_id" -f c="$node" >/dev/null 2>&1; then
        ok "$id #$issue added to the board"
      else
        bad "$id #$issue could not be added to the board"
      fi
    done <<<"$steps_raw"
  fi
fi

say ""
summary="roadmap-sync: ${changed} changed, ${skipped} already correct, ${failed} failed"
[ "$unknown" -gt 0 ] && summary="$summary, ${unknown} not compared"
say "$summary"
[ "$DRY_RUN" = "1" ] && say "${YELLOW}note${RESET} dry run: 'changed' counts what a write would do."
[ "$failed" -eq 0 ] || say "${YELLOW}note${RESET} failures above did not fail the build - see P-1."
exit 0
