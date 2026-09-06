#!/usr/bin/env bash
#
# Documentation verification - the mechanism that makes doc drift a build failure
# rather than a review nit. Run via `just docs-verify`.
#
# Five checks, defined in .claude/rules/40-doc-sync.md:
#   1 frontmatter  every docs/**/*.md parses; id unique; status within enum
#   2 impact       a changed source path's mapped docs changed too, or the PR is labelled
#   3 glossary     no forbidden alias used in place of a canonical term
#   4 links        every relative link resolves; no tracked doc links into _local/
#   5 language     no Cyrillic in docs/ outside the allowlist
#
# Bash, awk and git only. Adding a YAML or Markdown parser would mean a runtime this
# repository does not otherwise depend on, and I-4 makes every added dependency a cost.
#
# Environment:
#   DOCS_VERIFY_BASE   base ref for the changed-file set (default: origin/main)
#   DOCS_IMPACT_NONE   set to 1 when the PR carries the docs-impact:none label

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

MANIFEST="docs/.manifest.yaml"
BASE="${DOCS_VERIFY_BASE:-origin/main}"
STATUS_ENUM="draft accepted superseded deprecated"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
failures=0

fail() { printf "${RED}FAIL${NC} %s\n" "$1"; failures=$((failures + 1)); }
pass() { printf "${GREEN}ok${NC}   %s\n" "$1"; }
warn() { printf "${YELLOW}warn${NC} %s\n" "$1"; }

[ -f "$MANIFEST" ] || { fail "missing $MANIFEST"; exit 1; }

# Values of a simple YAML list under a top-level key, e.g. frontmatter_exempt.
manifest_list() {
  awk -v key="$1" '
    $0 ~ "^" key ":" { inlist = 1; next }
    inlist && /^[[:space:]]*-[[:space:]]/ { sub(/^[[:space:]]*-[[:space:]]*/, ""); print; next }
    inlist && /^[^[:space:]#]/ { inlist = 0 }
  ' "$MANIFEST"
}

docs_files() {
  local exempt f keep
  exempt="$(manifest_list frontmatter_exempt)"
  while IFS= read -r f; do
    keep=1
    while IFS= read -r e; do
      [ -n "$e" ] && case "$f" in "$e"*) keep=0 ;; esac
    done <<< "$exempt"
    [ "$keep" = 1 ] && printf '%s\n' "$f"
  done < <(git ls-files 'docs/*.md' 'docs/**/*.md')
}

# ---------------------------------------------------------------- 1. frontmatter
check_frontmatter() {
  local f ids dupes bad=0
  ids=""
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if [ "$(head -1 "$f")" != "---" ]; then
      fail "frontmatter: $f does not start with ---"; bad=1; continue
    fi
    local id status
    id="$(awk 'NR>1 && /^---$/{exit} /^id:/{sub(/^id:[[:space:]]*/,""); print; exit}' "$f")"
    status="$(awk 'NR>1 && /^---$/{exit} /^status:/{sub(/^status:[[:space:]]*/,""); print; exit}' "$f")"
    [ -n "$id" ] || { fail "frontmatter: $f has no id"; bad=1; }
    if [ -z "$status" ]; then
      fail "frontmatter: $f has no status"; bad=1
    elif ! printf '%s' " $STATUS_ENUM " | grep -q " $status "; then
      fail "frontmatter: $f status '$status' is outside {$STATUS_ENUM}"; bad=1
    fi
    [ -n "$id" ] && ids="$ids$id"$'\n'
  done < <(docs_files)

  dupes="$(printf '%s' "$ids" | grep -v '^$' | sort | uniq -d)"
  if [ -n "$dupes" ]; then
    fail "frontmatter: duplicate id(s): $(printf '%s' "$dupes" | tr '\n' ' ')"; bad=1
  fi
  [ "$bad" = 0 ] && pass "frontmatter: $(docs_files | wc -l | tr -d ' ') documents, ids unique, status within enum"
}

# ---------------------------------------------------------------- 2. impact
check_impact() {
  local changed src reqs hit bad=0 checked=0
  if ! git rev-parse --verify --quiet "$BASE" > /dev/null; then
    warn "impact: base ref '$BASE' not found - skipped"; return
  fi
  changed="$(git diff --name-only "$BASE"...HEAD 2>/dev/null)"
  [ -n "$changed" ] || { pass "impact: no changes against $BASE"; return; }

  # Each mapping is "- source: X" followed by "requires: [a, b]".
  while IFS='|' read -r src reqs; do
    [ -n "$src" ] || continue
    printf '%s\n' "$changed" | grep -q "^$src" || continue
    checked=$((checked + 1))
    hit=0
    for r in ${reqs//,/ }; do
      printf '%s\n' "$changed" | grep -qx "$r" && { hit=1; break; }
    done
    if [ "$hit" = 0 ]; then
      if [ "${DOCS_IMPACT_NONE:-0}" = "1" ]; then
        warn "impact: '$src' changed with no mapped doc - allowed by docs-impact:none"
      else
        fail "impact: '$src' changed but none of its documents did: ${reqs//,/ }"
        bad=1
      fi
    fi
  done < <(awk '
    /^[[:space:]]*-[[:space:]]*source:/ { sub(/.*source:[[:space:]]*/, ""); src = $0; next }
    /^[[:space:]]*requires:/ && src != "" {
      sub(/.*requires:[[:space:]]*\[/, ""); sub(/\][[:space:]]*$/, "");
      gsub(/[[:space:]]/, ""); print src "|" $0; src = ""
    }
  ' "$MANIFEST")

  [ "$bad" = 0 ] && pass "impact: $checked mapped source path(s) changed, all documented"
}

# ---------------------------------------------------------------- 3. glossary
check_glossary() {
  local g="docs/GLOSSARY.md" bad=0 term aliases a hits
  [ -f "$g" ] || { warn "glossary: $g not found - skipped"; return; }

  while IFS='|' read -r term aliases; do
    [ -n "$aliases" ] || continue
    for a in ${aliases//,/ }; do
      [ -n "$a" ] || continue
      # A forbidden alias only counts as a capitalised standalone word in prose:
      # lowercase use ("my account") is English, and CamelCase use (ClearChat) is a symbol.
      hits="$(grep -rnE "(^|[^A-Za-z\`_])${a}([^A-Za-z\`_]|$)" --include='*.md' docs \
                | grep -v '^docs/security/' | grep -v "^$g:" | grep -v '`' || true)"
      if [ -n "$hits" ]; then
        fail "glossary: forbidden alias '$a' (use '$term') at: $(printf '%s' "$hits" | head -2 | cut -d: -f1,2 | tr '\n' ' ')"
        bad=1
      fi
    done
  done < <(awk -F'|' '
    /^\|[[:space:]]*\*\*/ {
      t = $2; gsub(/[[:space:]]|\*/, "", t);
      al = $(NF-1); gsub(/^[[:space:]]+|[[:space:]]+$/, "", al);
      if (al == "" || al == "—" || al ~ /^-+$/) next;
      print t "|" al;
    }
  ' "$g")

  [ "$bad" = 0 ] && pass "glossary: no forbidden alias used in place of a canonical term"
}

# ---------------------------------------------------------------- 4. links
check_links() {
  local f link target bad=0 count=0
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    local dir; dir="$(dirname "$f")"
    while IFS= read -r link; do
      [ -n "$link" ] || continue
      case "$link" in http*|mailto:*|'#'*) continue ;; esac
      target="${link%%#*}"
      [ -n "$target" ] || continue
      count=$((count + 1))
      if [ ! -e "$dir/$target" ]; then
        fail "links: $f -> $target does not resolve"; bad=1
      fi
    done < <(grep -oE '\]\([^)]+\)' "$f" | sed 's/^](//; s/)$//')
  done < <(git ls-files '*.md')

  local locals
  locals="$(git grep -lI '](\(\./\)\?/\?_local/' -- '*.md' 2>/dev/null || true)"
  if [ -n "$locals" ]; then
    fail "links: tracked document(s) link into gitignored _local/: $(printf '%s' "$locals" | tr '\n' ' ')"
    bad=1
  fi
  [ "$bad" = 0 ] && pass "links: $count relative link(s) resolve, none into _local/"
}

# ---------------------------------------------------------------- 5. language
check_language() {
  local allow hits bad=0
  # git must be built with PCRE for \x{...}. Without it the grep would error and the
  # check would silently pass - a fail-open on a policy check is worse than a loud skip.
  if ! echo "x" | git grep -qP 'x' -- 2> /dev/null; then
    if ! printf 'x' | grep -qP 'x' 2> /dev/null; then
      warn "language: git grep has no PCRE support - check skipped"; return
    fi
  fi
  allow="$(manifest_list language_allowlist)"
  hits="$(git grep -lIP '[\x{0400}-\x{04FF}]' -- 'docs/*.md' 'docs/**/*.md' '*.md' 2>/dev/null || true)"
  while IFS= read -r a; do
    [ -n "$a" ] && hits="$(printf '%s\n' "$hits" | grep -vFx "$a" || true)"
  done <<< "$allow"
  hits="$(printf '%s\n' "$hits" | grep -v '^$' || true)"
  if [ -n "$hits" ]; then
    fail "language: Cyrillic outside the allowlist: $(printf '%s' "$hits" | tr '\n' ' ')"
    bad=1
  fi
  [ "$bad" = 0 ] && pass "language: no Cyrillic in tracked Markdown outside the allowlist"
}

echo "docs-verify (base: $BASE)"
check_frontmatter
check_impact
check_glossary
check_links
check_language

if [ "$failures" -gt 0 ]; then
  printf "\n${RED}%d check(s) failed${NC}\n" "$failures"
  exit 1
fi
printf "\n${GREEN}all checks passed${NC}\n"
