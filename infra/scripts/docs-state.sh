#!/usr/bin/env bash
#
# Render docs/roadmap/STATE.md from docs/roadmap/roadmap.yaml. Run via `just docs-state`.
#
# STATE.md has carried a "generated, never hand-edited" header since PR-14 while nothing
# generated it. It rotted sixty steps behind the YAML, which is worse than having no such
# file: the header tells the reader the number is machine-derived and therefore trustworthy.
# This script is the missing half, and docs-verify check 6 is what makes the drift fail a
# build rather than wait for someone to notice.
#
# One direction only: roadmap.yaml -> STATE.md. This script never writes the YAML and never
# reads GitHub. roadmap.yaml:7-15 makes `status` the DESIRED state, so copying it back from
# live issues would invert the direction of truth - the mistake that reopened twenty-one
# correctly-closed issues before #228.
#
# It renders only what the YAML can support. The hand-maintained file carried "Blocked" and
# "Carried into Phase N" sections that were prose about facts recorded nowhere; a generator
# cannot derive them, and inventing them is how a generated file starts lying again.
#
# Bash, awk and sed only - no YAML parser. docs-verify.sh:13-14 sets that constraint, and
# I-4 makes every added runtime dependency a cost paid by every self-hoster.
#
# Usage:
#   docs-state.sh            print the rendered document to stdout
#   docs-state.sh --write    write it to docs/roadmap/STATE.md

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

ROADMAP="docs/roadmap/roadmap.yaml"
TARGET="docs/roadmap/STATE.md"

[ -f "$ROADMAP" ] || { echo "docs-state: missing $ROADMAP" >&2; exit 1; }

WRITE=0
case "${1:-}" in
  --write) WRITE=1 ;;
  "") ;;
  *) echo "usage: docs-state.sh [--write]" >&2; exit 2 ;;
esac

# ---------------------------------------------------------------------------- parsing
#
# Every entry is a single-line flow mapping, the same shape roadmap-sync.sh parses. Keep it
# on one line or neither tool sees it.

# Value of a scalar field. Stops at the first comma, so it is correct for id/phase/status
# and for any unquoted value without one - not for closed_by or note, which have their own
# extractors below.
field() { sed -n "s/.*[{,][[:space:]]*$2:[[:space:]]*\\([^,}]*\\).*/\\1/p" <<<"$1" | head -1 | sed 's/[[:space:]]*$//'; }

# Quoted field: title and note are double-quoted and may contain commas.
qfield() { sed -n "s/.*[{,][[:space:]]*$2:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" <<<"$1" | head -1; }

# Bracketed list: closed_by: [PR-30, PR-31a]
lfield() { sed -n "s/.*[{,][[:space:]]*$2:[[:space:]]*\\[\\([^]]*\\)\\].*/\\1/p" <<<"$1" | head -1; }

# Entries of one top-level block, from `key:` up to the next top-level key.
block() { sed -n "/^$1:/,/^[a-z_]*:/p" "$ROADMAP" | sed -n 's/^[[:space:]]*-[[:space:]]*{\(.*\)}[[:space:]]*$/{\1}/p'; }

INVARIANTS="$(block invariants)"
GATES="$(block gates)"
STEPS="$(sed -n '/^steps:/,$p' "$ROADMAP" | sed -n 's/^[[:space:]]*-[[:space:]]*{\(.*\)}[[:space:]]*$/{\1}/p')"

[ -n "$STEPS" ] || { echo "docs-state: no steps parsed from $ROADMAP - has the format changed?" >&2; exit 1; }

# ---------------------------------------------------------------------------- helpers

# A ten-cell progress bar. Rounds to nearest so 0 and 100 per cent are the only extremes
# that can render as an empty or full bar.
bar() {
  local d="$1" t="$2" filled=0 i out=""
  [ "$t" -gt 0 ] && filled=$(( (d * 10 + t / 2) / t ))
  for ((i = 0; i < 10; i++)); do
    if [ "$i" -lt "$filled" ]; then out="$out█"; else out="$out░"; fi
  done
  printf '%s' "$out"
}

phases_present() {
  while IFS= read -r s; do [ -n "$s" ] && field "$s" phase; done <<<"$STEPS" | sort -u -n
}

# ---------------------------------------------------------------------------- body

render_body() {
  echo
  echo "# State"
  echo
  echo "**Generated from [\`roadmap.yaml\`](roadmap.yaml) by \`just docs-state\`. Do not hand-edit** -"
  echo "\`docs-verify\` check 6 regenerates this file and fails on any difference."
  echo
  echo "## Progress"
  echo
  echo "| Phase | Done | Total | |"
  echo "|---|---|---|---|"

  local all_done=0 all_total=0 p d t
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    d=0; t=0
    while IFS= read -r s; do
      [ -n "$s" ] || continue
      [ "$(field "$s" phase)" = "$p" ] || continue
      t=$((t + 1))
      [ "$(field "$s" status)" = "done" ] && d=$((d + 1))
    done <<<"$STEPS"
    all_done=$((all_done + d)); all_total=$((all_total + t))
    printf '| %s | %s | %s | `%s` |\n' "$p" "$d" "$t" "$(bar "$d" "$t")"
  done < <(phases_present)

  printf '| **all** | **%s** | **%s** | |\n' "$all_done" "$all_total"

  # ---- position
  #
  # "Current phase" is the lowest phase with an open step. There is deliberately no "next
  # step" line: the YAML records which steps are open, not which one comes next, and file
  # order is not a sequencing claim. Naming one would be the generator inventing a fact.
  local current="" g gid gstatus next_gate=""
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    while IFS= read -r s; do
      [ -n "$s" ] || continue
      [ "$(field "$s" phase)" = "$p" ] || continue
      if [ "$(field "$s" status)" != "done" ] && [ -z "$current" ]; then current="$p"; fi
    done <<<"$STEPS"
    [ -n "$current" ] && break
  done < <(phases_present)

  while IFS= read -r g; do
    [ -n "$g" ] || continue
    gid="$(field "$g" id)"; gstatus="$(field "$g" status)"
    if [ "$gstatus" != "passed" ] && [ -z "$next_gate" ]; then next_gate="$gid"; fi
  done <<<"$GATES"

  echo
  echo "## Position"
  echo
  if [ -n "$current" ]; then
    echo "- **Current phase:** $current"
  else
    echo "- **Current phase:** none - every step is done"
  fi
  echo "- **Next gate:** ${next_gate:-none - every gate has passed}"
  echo "- **Open steps:** $((all_total - all_done)) of $all_total"

  # ---- gates
  echo
  echo "## Gates"
  echo
  echo "| Gate | After | Phase | Status |"
  echo "|---|---|---|---|"
  while IFS= read -r g; do
    [ -n "$g" ] || continue
    printf '| %s | %s | %s | %s |\n' \
      "$(field "$g" id)" "$(field "$g" after)" "$(field "$g" phase)" "$(field "$g" status)"
  done <<<"$GATES"

  # ---- invariants
  echo
  echo "## Invariants"
  echo
  echo "| # | Name | Met | Closed by |"
  echo "|---|---|---|---|"
  local inv closed note
  while IFS= read -r inv; do
    [ -n "$inv" ] || continue
    closed="$(lfield "$inv" closed_by)"
    note="$(qfield "$inv" note)"
    printf '| %s | %s | %s | %s |\n' \
      "$(field "$inv" id)" "$(field "$inv" name)" "$(field "$inv" met)" "${closed:-—}"
    [ -n "$note" ] && printf '| | | | *%s* |\n' "$note"
  done <<<"$INVARIANTS"

  # ---- open steps
  echo
  echo "## Open steps"
  echo
  if [ "$all_done" = "$all_total" ]; then
    echo "None."
  else
    echo "| Step | Phase | Issue | Title |"
    echo "|---|---|---|---|"
    # Grouped by phase, file order within a phase. The YAML does not encode sequencing, so
    # file order is presentation, not a claim about what comes next.
    local sid sph sis
    while IFS= read -r p; do
      [ -n "$p" ] || continue
      while IFS= read -r s; do
        [ -n "$s" ] || continue
        [ "$(field "$s" status)" = "done" ] && continue
        sph="$(field "$s" phase)"
        [ "$sph" = "$p" ] || continue
        sid="$(field "$s" id)"; sis="$(field "$s" issue)"
        if [ "$sis" = "null" ] || [ -z "$sis" ]; then
          sis="—"
        else
          sis="[#$sis](https://github.com/guardyn/guardyn/issues/$sis)"
        fi
        printf '| %s | %s | %s | %s |\n' "$sid" "$sph" "$sis" "$(qfield "$s" title)"
      done <<<"$STEPS"
    done < <(phases_present)
  fi
}

# ---------------------------------------------------------------------------- assemble
#
# `tokens:` is measured over the BODY, not the whole file. Counting the whole file would be
# a fixed point - the number changes the length that produced it - and the body is what a
# reader actually pays to load. Four characters per token is the conventional approximation;
# it is an estimate and the frontmatter contract does not claim otherwise.

BODY="$(render_body)"
TOKENS=$(( ${#BODY} / 4 ))

OUT="$(cat <<EOF
---
id: roadmap-state
type: roadmap
status: accepted
owns: [docs/roadmap/roadmap.yaml]
read_when: [asking where the work is, reporting at a gate]
tokens: $TOKENS
supersedes: []
---
$BODY
EOF
)"

if [ "$WRITE" = "1" ]; then
  printf '%s\n' "$OUT" > "$TARGET"
  echo "docs-state: wrote $TARGET ($TOKENS tokens)"
else
  printf '%s\n' "$OUT"
fi
