#!/usr/bin/env bash
#
# PreToolUse guard: refuse `git commit` and `git push` while HEAD is on a protected
# branch. Belt-and-braces for AGENTS.md §2.1 - the `main-protection` ruleset is the
# real enforcement; this catches the mistake locally, before it costs a round trip.
#
# Contract: the tool call arrives as JSON on stdin. Exit 2 blocks the call and shows
# stderr to the agent; exit 0 allows it.
#
# The payload is matched as raw text rather than parsed. A JSON parser would mean a
# dependency this repository does not otherwise carry, and the only cost of the crude
# match is blocking a command that merely mentions "git commit" while HEAD is already
# on a protected branch - where nothing should be committing anyway.
#
# Fails OPEN by design: a bug here would otherwise brick every git operation for every
# agent, and the server-side ruleset still holds the line.

set -uo pipefail

PROTECTED_BRANCHES="main master"

payload="$(cat 2>/dev/null || true)"

case "$payload" in
  *"git commit"* | *"git push"*) ;;
  *) exit 0 ;;
esac

branch="$(git branch --show-current 2>/dev/null || true)"
[ -n "$branch" ] || exit 0

for protected in $PROTECTED_BRANCHES; do
  if [ "$branch" = "$protected" ]; then
    cat >&2 <<MSG
Blocked: HEAD is on '$branch', which is protected (AGENTS.md §2.1).

One micro-step = one branch = one PR = one issue. Create the step's branch first:

    git checkout -b <type>/<issue>-<slug> origin/main

<type> is one of: feat fix docs refactor chore security
MSG
    exit 2
  fi
done

exit 0
