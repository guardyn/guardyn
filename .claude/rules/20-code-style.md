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

**Convention: every check prints its violations. Empty output means PASS.**

| ID | Predicate | Today |
|---|---|---|
| `RS-UNWRAP` | No `unwrap()` / `expect()` in non-test Rust | FAIL — 52 in 25 files, PR-22 |
| `RS-UNSAFE` | No `unsafe` outside an FFI crate | PASS |
| `RS-FMT` | `cargo fmt` is clean | see `build.yml` |
| `RS-CLIPPY` | `cargo clippy -- -D warnings` is clean | masked until PR-17 |
| `PROTO-EDIT` | Generated protobuf is never hand-edited | PASS |
| `LANG-MD` | No Cyrillic in Markdown outside the one allowlisted file | PASS |
| `NAME-SH` | Scripts are `kebab-case.sh` | FAIL — 5 files |
| `NAME-RS` | Rust files are `snake_case.rs` | PASS |
| `ORG-ROOT` | Only the 8 permitted root Markdown files exist | PASS |
| `ORG-LOCAL` | No tracked file links into `_local/` | FAIL — `CHANGELOG.md:55` |

```sh
echo "RS-UNWRAP";  git ls-files 'backend/crates/*/src/*.rs' 'backend/crates/*/src/**/*.rs' \
                     | grep -v '/generated/' | while read -r f; do
                         sed '/#\[cfg(test)\]/,$d' "$f" \
                           | grep -nE '\.(unwrap|expect)\(' | sed "s|^|$f:|"
                       done
echo "RS-UNSAFE";  grep -rln 'unsafe ' --include='*.rs' backend/crates/*/src | grep -vE 'crypto-ffi|/ffi'
echo "RS-FMT";     cargo fmt --all --manifest-path backend/Cargo.toml -- --check
echo "PROTO-EDIT"; git diff --name-only origin/main...HEAD | grep -E '/(generated|proto)/.*\.rs$'
echo "LANG-MD";    git grep -lIP '[\x{0400}-\x{04FF}]' -- '*.md' | grep -v 'copilot-commit-message'
echo "NAME-SH";    git ls-files '*.sh' | xargs -n1 basename | grep -vE '^[a-z0-9-]+\.sh$'
echo "NAME-RS";    git ls-files '*.rs' | grep -vE '/(generated|proto)/' \
                     | xargs -n1 basename | grep -vE '^[a-z0-9_]+\.rs$'
echo "ORG-ROOT";   git ls-files -- '*.md' | grep -v / \
                     | grep -vE '^(README|AGENTS|CLAUDE|CONTRIBUTING|CHANGELOG|SECURITY|CODE_OF_CONDUCT|implementation_plan)\.md$'
echo "ORG-LOCAL";  git grep -lI '](.*_local/' -- '*.md'
```

## Exceptions that are not violations

- **Cyrillic test fixtures are legitimate.** `auth-service/src/handlers/update_profile.rs`
  and `e2e-tests/tests/e2e_production_readiness.rs` carry Cyrillic *test data* — a messaging
  product must prove non-Latin names round-trip. `LANG-MD` therefore scopes to Markdown.
  The language policy governs prose, comments, identifiers and log strings, not fixtures.
- **ADR filenames** are `ADR-NNNN-kebab-slug.md`, not `SCREAMING_SNAKE_CASE.md`. The
  sequence number is what makes them sortable and citable.
- **Generated protobuf** lives in two places — `backend/crates/*/src/generated/` (13 files)
  and `client-desktop/src-tauri/src/proto/` (8 files). Both are excluded from `NAME-RS`,
  and both are in scope for PR-23's unification; the plan names only the first.

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
