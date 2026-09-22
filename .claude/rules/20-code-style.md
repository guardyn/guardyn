---
id: rules-code-style
type: rules
status: accepted
owns: [backend/crates/, backend/proto/, infra/scripts/, .github/copilot-instructions.md]
read_when: [writing Rust, changing a proto, adding a file, naming anything]
---

# 20 · Code style

Predicates for [`AGENTS.md`](../../AGENTS.md) §3 (language), §5 (code), §6 (domain) and
§7 (file organization). AGENTS.md carries the prose and the `ErrorCode` table; this file
carries only what a machine can check.

**These predicates are executed, not merely stated.** `just rules-verify` runs them, and
[`rules.yml`](../../.github/workflows/rules.yml) runs it on every pull request. The script
[`infra/scripts/rules-verify.sh`](../../infra/scripts/rules-verify.sh) is the authority; the
greps below are the same checks written out, kept because a predicate you cannot read is a
predicate you cannot argue with.

| ID | Predicate | Today | Enforcement |
|---|---|---|---|
| `RS-UNWRAP` | No `unwrap()` / `expect()` in non-test Rust | FAIL — 28 sites | ratchet at 28 |
| `RS-UNSAFE` | No `unsafe` outside an FFI crate | PASS | hard fail |
| `RS-FMT` | `cargo fmt` is clean | PASS | `build.yml` |
| `RS-CLIPPY` | `cargo clippy -- -D warnings` is clean | PASS | `build.yml`, real since PR-17 |
| `PROTO-EDIT` | Generated protobuf is never hand-edited | PASS | hard fail |
| `LANG-MD` | No Cyrillic in Markdown outside the one allowlisted file | PASS | hard fail |
| `NAME-SH` | Scripts are `kebab-case.sh` | FAIL — 5 files | ratchet at 5 |
| `NAME-RS` | Rust files are `snake_case.rs` | PASS | hard fail |
| `ORG-ROOT` | Only the 8 permitted root Markdown files exist | PASS | hard fail |
| `ORG-LOCAL` | No tracked file links into `_local/` | PASS | hard fail |

`RS-FMT` and `RS-CLIPPY` stay in `build.yml`: they need a Rust toolchain, and `rules-verify`
deliberately needs nothing but bash, git and awk.

## Ratchets, not warnings

`RS-UNWRAP` and `NAME-SH` fail today, and fixing them is owned work rather than this file's.
Each therefore carries a **budget equal to its measured count**: the build fails the moment
the number *grows*. Existing debt is frozen, new debt is impossible, and every fix lowers the
ceiling — the budget is edited down in the same PR that removes a site.

A warning nobody has to act on is how `continue-on-error` made CI decorative before PR-17.
A ratchet cannot be scrolled past.

**A ratchet must only count debt somebody can pay down.** `RS-UNWRAP` used to scan the two
`frb_generated.rs` files, which `just ffi-generate` writes and which nobody may hand-edit. They
held 21 of the 49 sites it reported, and the count moved whenever the bindings were regenerated:
flutter_rust_bridge 2.13.0 emits two more `unwrap`s than 2.11.1 did, so the FFI repair in #350
turned the ratchet red by running a code generator. Excluding them dropped the budget from 47 to
**28** — nineteen sites of the frozen debt were never anyone's to fix. The budget only ever
moves down, so this is the shape the rule intends; what it is not is a licence to exclude a file
because its count is inconvenient.

```sh
echo "RS-UNWRAP";  git ls-files 'backend/crates/*/src/*.rs' 'backend/crates/*/src/**/*.rs' \
                     | grep -v '/generated/' | grep -v 'frb_generated\.rs' | while read -r f; do
                         sed '/#\[cfg(test)\]/,$d' "$f" \
                           | grep -nE '\.(unwrap|expect)\(' | sed "s|^|$f:|"
                       done
echo "RS-UNSAFE";  grep -rln 'unsafe ' --include='*.rs' backend/crates/*/src | grep -vE 'crypto-ffi|/ffi'
echo "RS-FMT";     cargo fmt --all --manifest-path backend/Cargo.toml -- --check
echo "PROTO-EDIT"; git diff --name-only --diff-filter=d origin/main...HEAD \
                     | grep -E '/(generated|proto)/.*\.rs$'
echo "LANG-MD";    git grep -lIP '[\x{0400}-\x{04FF}]' -- '*.md' | grep -v 'copilot-commit-message'
echo "NAME-SH";    git ls-files '*.sh' | xargs -n1 basename | grep -vE '^[a-z0-9-]+\.sh$'
echo "NAME-RS";    git ls-files '*.rs' | grep -vE '/(generated|proto)/' \
                     | xargs -n1 basename | grep -vE '^[a-z0-9_]+\.rs$'
echo "ORG-ROOT";   git ls-files -- '*.md' | grep -v / \
                     | grep -vE '^(README|AGENTS|CLAUDE|CONTRIBUTING|CHANGELOG|SECURITY|CODE_OF_CONDUCT|implementation_plan)\.md$'
echo "ORG-LOCAL";  git grep -lI '](.*_local/' -- '*.md' | grep -v '^\.claude/rules/'
```

`ORG-LOCAL` excludes `.claude/rules/` because the line above *contains the pattern it
searches for* — this file matches itself. Same reason `LANG-MD` allowlists the policy file
that lists the forbidden alphabets: a rule may state its own violation.

The `CHANGELOG.md:55` instance this predicate was written for is **gone**. The one surviving
mention of `_local/` in `CHANGELOG.md` is prose in backticks, not a Markdown link, so it never
matched.

## Exceptions that are not violations

- **Cyrillic test fixtures are legitimate.** `auth-service/src/handlers/update_profile.rs`
  and `e2e-tests/tests/e2e_production_readiness.rs` carry Cyrillic *test data* — a messaging
  product must prove non-Latin names round-trip. `LANG-MD` therefore scopes to Markdown.
  The language policy governs prose, comments, identifiers and log strings, not fixtures.
- **ADR filenames** are `ADR-NNNN-kebab-slug.md`, not `SCREAMING_SNAKE_CASE.md`. The
  sequence number is what makes them sortable and citable.
- **Generated protobuf is committed nowhere.** PR-23 deleted
  `backend/crates/*/src/generated/` and PR-56 deleted `client-desktop/src-tauri/src/proto/`;
  every crate now compiles into `OUT_DIR` per
  [ADR-0008](../../docs/adr/ADR-0008-protobuf-codegen.md). The `/(generated|proto)/`
  exclusion in `NAME-RS` therefore filters nothing today — it is left in place as a guard
  against reintroduction, not because anything needs it. `PROTO-EDIT` keeps its own
  `--diff-filter=d` carve-out for the same reason.

## Rules a grep cannot check

- Errors use `thiserror` over `guardyn_common::error`. No stringly-typed errors.
- Every public item carries a doc comment.
- One gRPC handler per file under `handlers/`.
- `backend/proto/*.proto` is the canonical wire contract: change the proto, then
  regenerate. Never invent an enum variant — read the proto and use the converted name
  ([`AGENTS.md`](../../AGENTS.md) §5.2 has the real mistakes table).
- No new datastore, bus or major dependency without an accepted ADR **and** user approval.
- Never hardcode a domain. `${DOMAIN}` is the single source; see `SOV-DOMAIN` in
  [`00-invariants.md`](00-invariants.md).
