#!/usr/bin/env bash
#
# Code-style verification - the predicates of .claude/rules/20-code-style.md, executable.
# Run via `just rules-verify`.
#
# The rules file has stated these as testable predicates since PR-05, but nothing ran them,
# so they were prose with a table for a hat. This is the mechanism behind them.
#
#   RS-UNWRAP    no unwrap()/expect() in non-test Rust          ratcheted
#   RS-UNSAFE    no `unsafe` outside an FFI crate
#   ZK-INIT      tracing is initialised only via observability::init_tracing
#   PROTO-EDIT   generated protobuf is never hand-edited
#   LANG-MD      no Cyrillic in Markdown outside the allowlist
#   NAME-SH      scripts are kebab-case.sh                      ratcheted
#   NAME-RS      Rust files are snake_case.rs
#   ORG-ROOT     only the 8 permitted root Markdown files exist
#   ORG-LOCAL    no tracked file links into _local/
#
# RS-FMT and RS-CLIPPY are deliberately absent: build.yml already runs `cargo fmt --check`
# and `cargo clippy -- -D warnings`, and since PR-17 both actually fail the build. Repeating
# them here would mean a Rust toolchain in a job that otherwise needs none.
#
# Ratchets, not warnings. RS-UNWRAP and NAME-SH fail today - 52 sites and 5 files - and
# fixing them is owned work, not this step's. A warning everyone learns to scroll past is
# how `continue-on-error` made CI decorative before PR-17. So each carries a budget equal to
# its measured count: the build fails the moment the number GROWS. Existing debt is frozen,
# new debt is impossible, and every fix lowers the ceiling.
#
# Bash, git and awk only. I-4 makes every added runtime a cost.
#
# Environment:
#   RULES_VERIFY_BASE   base ref for PROTO-EDIT's changed-file set (default: origin/main)

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

# Every predicate below is a git query. Without a working repository they would all return
# nothing and the script would report "all checks passed" - a verifier that passes vacuously
# is the same decorative CI that PR-17 removed. Refuse instead.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  printf "${RED}FAIL${NC} %s\n" "not inside a git work tree - every predicate would pass vacuously"
  exit 1
}

BASE="${RULES_VERIFY_BASE:-origin/main}"

# Frozen debt. These may only ever be lowered. Lower them in the same PR that removes a site.
RS_UNWRAP_BUDGET=49
NAME_SH_BUDGET=5

failures=0

fail() { printf "${RED}FAIL${NC} %s\n" "$1"; failures=$((failures + 1)); }
pass() { printf "${GREEN}ok${NC}   %s\n" "$1"; }
warn() { printf "${YELLOW}warn${NC} %s\n" "$1"; }

# Print the offending lines, indented, so a failure is actionable without a second command.
show() { printf '%s\n' "$1" | sed 's/^/       /'; }

# A ratcheted predicate: fail when the count exceeds its frozen budget, note when it drops.
ratchet() {
  local id="$1" budget="$2" hits="$3" n
  n="$(printf '%s' "$hits" | grep -c . || true)"
  if [ "$n" -gt "$budget" ]; then
    fail "$id: $n site(s), budget $budget - this change adds $((n - budget))"
    show "$hits"
  elif [ "$n" -lt "$budget" ]; then
    pass "$id: $n site(s), down from $budget - lower the budget in this PR"
  else
    warn "$id: $n site(s), at the frozen budget - known debt, not a regression"
  fi
}

# ---------------------------------------------------------------- RS-UNWRAP
check_rs_unwrap() {
  local hits
  # Everything from the first #[cfg(test)] onward is test code, where unwrap is idiomatic.
  hits="$(git ls-files 'backend/crates/*/src/*.rs' 'backend/crates/*/src/**/*.rs' \
    | grep -v '/generated/' \
    | while IFS= read -r f; do
        sed '/#\[cfg(test)\]/,$d' "$f" | grep -nE '\.(unwrap|expect)\(' | sed "s|^|$f:|"
      done)"
  ratchet RS-UNWRAP "$RS_UNWRAP_BUDGET" "$hits"
}

# ---------------------------------------------------------------- RS-UNSAFE
check_rs_unsafe() {
  local hits
  hits="$(grep -rln 'unsafe ' --include='*.rs' backend/crates/*/src 2>/dev/null \
    | grep -vE 'crypto-ffi|/ffi' || true)"
  if [ -n "$hits" ]; then
    fail "RS-UNSAFE: unsafe outside an FFI crate"
    show "$hits"
  else
    pass "RS-UNSAFE: no unsafe outside an FFI crate"
  fi
}

# ---------------------------------------------------------------- ZK-INIT
#
# Enforces I-1. A service that builds its own subscriber gets neither JSON logs
# nor OTel traces nor the redaction layer, so a payload or key field reaches the
# writer unfiltered. A plain fail, not a ratchet: PR-26 left zero sites, and a
# ratchet's warn branch is for frozen debt rather than a predicate that holds.
check_zk_init() {
  local hits
  hits="$(grep -rln --include='*.rs' -e FmtSubscriber -e 'tracing_subscriber::fmt()' \
    backend/crates/*/src 2>/dev/null || true)"
  if [ -n "$hits" ]; then
    fail "ZK-INIT: tracing initialised outside observability::init_tracing"
    show "$hits"
  else
    pass "ZK-INIT: every service initialises tracing via init_tracing"
  fi
}

# ------------------------------------------------------------------ E2EE-DUP
# Inverted on purpose: a `*_e2ee.rs` file existing proves a non-E2EE original
# still sits beside it, and one of the two paths must be the wrong one. After
# PR-32a there is a single relay handler with no suffix.
check_e2ee_dup() {
  local hits
  hits="$(ls backend/crates/messaging-service/src/handlers/*_e2ee.rs 2>/dev/null || true)"
  if [ -n "$hits" ]; then
    fail "E2EE-DUP: a handler has a non-E2EE twin"
    show "$hits"
  else
    pass "E2EE-DUP: one message path, no non-E2EE twin"
  fi
}

# -------------------------------------------------------------------- ZK-PII
# A log macro handed a raw IP, email or phone number. AGENTS.md §4 lists all
# three as PII, and I-1 forbids PII in any log, span or metric.
#
# Matches the field NAME, positionally interpolated or structured. It cannot see
# a value that is PII under a neutral name - that is what review is for.
check_zk_pii() {
  local hits
  hits="$(git ls-files -z -- 'backend/crates/*/src/*.rs' 'backend/crates/*/src/**/*.rs' \
    | xargs -0 grep -nE '(trace|debug|info|warn|error)!\(' 2>/dev/null \
    | grep -iE '"[^"]*\b(ip|email|phone)\b[^"]*"[^)]*,' || true)"
  if [ -n "$hits" ]; then
    fail "ZK-PII: a log macro is passed a raw IP, email or phone number"
    show "$hits"
  else
    pass "ZK-PII: no raw IP, email or phone number in a log macro"
  fi
}

# ---------------------------------------------------------------- PROTO-EDIT
check_proto_edit() {
  local hits
  if ! git rev-parse --verify --quiet "$BASE" >/dev/null; then
    warn "PROTO-EDIT: $BASE is not available - skipped"
    return
  fi
  # --diff-filter=d excludes deletions. The predicate forbids hand-EDITING generated code;
  # deleting it is the opposite - PR-23 removes 13 such files, and flagging that as a
  # violation would have made the predicate fire on the change that satisfies ADR-0008.
  hits="$(git diff --name-only --diff-filter=d "$BASE"...HEAD \
    | grep -E '/(generated|proto)/.*\.rs$' || true)"
  if [ -n "$hits" ]; then
    fail "PROTO-EDIT: generated protobuf edited by hand - change the .proto and regenerate"
    show "$hits"
  else
    pass "PROTO-EDIT: no generated protobuf hand-edited"
  fi
}

# ---------------------------------------------------------------- LANG-MD
check_lang_md() {
  local hits
  hits="$(git grep -lIP '[\x{0400}-\x{04FF}]' -- '*.md' 2>/dev/null \
    | grep -v 'copilot-commit-message' || true)"
  if [ -n "$hits" ]; then
    fail "LANG-MD: Cyrillic in Markdown outside the allowlist"
    show "$hits"
  else
    pass "LANG-MD: no Cyrillic in Markdown outside the allowlist"
  fi
}

# ---------------------------------------------------------------- NAME-SH
check_name_sh() {
  local hits
  hits="$(git ls-files '*.sh' | xargs -r -n1 basename | grep -vE '^[a-z0-9-]+\.sh$' || true)"
  ratchet NAME-SH "$NAME_SH_BUDGET" "$hits"
}

# ---------------------------------------------------------------- NAME-RS
check_name_rs() {
  local hits
  hits="$(git ls-files '*.rs' | grep -vE '/(generated|proto)/' \
    | xargs -r -n1 basename | grep -vE '^[a-z0-9_]+\.rs$' || true)"
  if [ -n "$hits" ]; then
    fail "NAME-RS: Rust files must be snake_case.rs"
    show "$hits"
  else
    pass "NAME-RS: every Rust file is snake_case.rs"
  fi
}

# ---------------------------------------------------------------- ORG-ROOT
check_org_root() {
  local hits
  hits="$(git ls-files -- '*.md' | grep -v / \
    | grep -vE '^(README|AGENTS|CLAUDE|CONTRIBUTING|CHANGELOG|SECURITY|CODE_OF_CONDUCT|implementation_plan)\.md$' || true)"
  if [ -n "$hits" ]; then
    fail "ORG-ROOT: only the 8 permitted root Markdown files may exist"
    show "$hits"
  else
    pass "ORG-ROOT: only the 8 permitted root Markdown files exist"
  fi
}

# ---------------------------------------------------------------- ORG-LOCAL
check_org_local() {
  local hits
  # .claude/rules/ is excluded because it *documents* this predicate: the grep that defines
  # the check contains the pattern it searches for, so the rules file matches itself. Same
  # reason LANG-MD allowlists the policy file that lists the forbidden alphabets.
  hits="$(git grep -lI '](.*_local/' -- '*.md' 2>/dev/null \
    | grep -v '^\.claude/rules/' || true)"
  if [ -n "$hits" ]; then
    fail "ORG-LOCAL: a tracked document links into _local/, which is gitignored"
    show "$hits"
  else
    pass "ORG-LOCAL: no tracked document links into _local/"
  fi
}

echo "rules-verify (base: $BASE)"
check_rs_unwrap
check_rs_unsafe
check_zk_init
check_e2ee_dup
check_zk_pii
check_proto_edit
check_lang_md
check_name_sh
check_name_rs
check_org_root
check_org_local

if [ "$failures" -gt 0 ]; then
  printf "\n${RED}%d check(s) failed${NC}\n" "$failures"
  exit 1
fi
printf "\n${GREEN}all checks passed${NC}\n"
