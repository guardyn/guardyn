#!/usr/bin/env bash
#
# Roadmap sync - reconciles docs/roadmap/roadmap.yaml into GitHub Issues, their Milestones,
# and the Project v2 board. The YAML is the machine source of truth; this script moves the
# world toward it.
#
# Three passes, in descending order of how reliably they can run:
#   issue state  - REST, ambient token. Always runs.
#   milestone    - REST, ambient token. Always runs. `phase: N` maps to milestone "Phase N".
#   board        - GraphQL, needs a project scope no available token has yet (P-1). Guarded.
#
# Reconciling, not appending: every action is derived from the difference between the file
# and the platform, so running it twice changes nothing the second time. That property is
# what lets it run on every push to main without supervision.
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
# Exit codes: 0 always, unless the roadmap file itself is unreadable or malformed. A missing
# credential is a documented state, not a build failure.

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

ROADMAP="docs/roadmap/roadmap.yaml"
REPO="${GITHUB_REPOSITORY:-guardyn/guardyn}"
DRY_RUN="${ROADMAP_SYNC_DRY_RUN:-0}"

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'; RESET=$'\033[0m'
changed=0; skipped=0; failed=0

say()  { printf '%s\n' "$*"; }
ok()   { printf '%s%s%s %s\n' "$GREEN" "sync" "$RESET" "$*"; changed=$((changed + 1)); }
noop() { printf '%s%s%s %s\n' "$YELLOW" "same" "$RESET" "$*"; skipped=$((skipped + 1)); }
bad()  { printf '%s%s%s %s\n' "$RED" "FAIL" "$RESET" "$*" >&2; failed=$((failed + 1)); }

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

if ! command -v gh >/dev/null 2>&1; then
  say "${YELLOW}note${RESET} gh is not installed - dry run only."
  DRY_RUN=1
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

  if [ -z "$issue" ] || [ "$issue" = "null" ]; then
    ok "$id has no issue yet - would create: \"$id · $title\""
    continue
  fi

  want_state="open"
  [ "$status" = "done" ] && want_state="closed"

  want_ms="$(milestone_for "$phase")"

  if [ "$DRY_RUN" = "1" ]; then
    say "  $id -> #$issue want=$want_state phase=$phase milestone=${want_ms:-none}"
    skipped=$((skipped + 1))
    continue
  fi

  # One read serves both passes. `0` stands for "no milestone", which no real milestone
  # number can collide with, so it compares safely against an empty want_ms.
  read -r have have_ms <<<"$(gh api "repos/$REPO/issues/$issue" \
    --jq '"\(.state) \(.milestone.number // 0)"' 2>/dev/null)"
  if [ -z "$have" ]; then
    bad "$id references #$issue which does not exist"
    continue
  fi

  if [ "$have" = "$want_state" ]; then
    noop "$id #$issue already $want_state"
  elif [ "$want_state" = "closed" ]; then
    if gh api -X PATCH "repos/$REPO/issues/$issue" \
        -f state=closed -f state_reason=completed >/dev/null 2>&1; then
      ok "$id #$issue closed as completed"
    else
      bad "$id #$issue could not be closed"
    fi
  else
    if gh api -X PATCH "repos/$REPO/issues/$issue" -f state=open >/dev/null 2>&1; then
      ok "$id #$issue reopened"
    else
      bad "$id #$issue could not be reopened"
    fi
  fi

  # Milestone. Written only on mismatch, so the second run of any pair reports `same`.
  if [ -z "$want_ms" ]; then
    :
  elif [ "$have_ms" = "$want_ms" ]; then
    noop "$id #$issue already on milestone $want_ms"
  elif gh api -X PATCH "repos/$REPO/issues/$issue" -F milestone="$want_ms" >/dev/null 2>&1; then
    ok "$id #$issue moved to milestone $want_ms"
  else
    bad "$id #$issue could not be moved to milestone $want_ms"
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
say "roadmap-sync: ${changed} changed, ${skipped} already correct, ${failed} failed"
[ "$failed" -eq 0 ] || say "${YELLOW}note${RESET} failures above did not fail the build - see P-1."
exit 0
