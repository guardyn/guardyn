---
id: agents
type: index
status: accepted
owns: [.claude/, .github/copilot-instructions.md, CONTRIBUTING.md]
read_when: [starting any session, before any commit, before any PR]
---

# AGENTS.md — Guardyn Agent Constitution

**This file is law.** It is tool-agnostic: Claude Code, Copilot, Cursor, Devin and any
other agent working in this repository obey it. Where a tool-specific file exists
(`CLAUDE.md`, `.github/copilot-instructions.md`), it is a pointer to this file, never a
competing source of truth.

**Read this before your first tool call in any session.**

---

## 0. Fast orientation

| Question | Answer |
|---|---|
| What is Guardyn? | Self-hostable, zero-knowledge, end-to-end-encrypted messaging and VoIP. |
| Backend | Rust, 10 crates under `backend/crates/`, gRPC via tonic. |
| Clients | Flutter (`client-mobile/`), Tauri 2 + SolidJS (`client-desktop/`). |
| Data stores | TiKV (metadata/auth/MLS state), ScyllaDB (message history), MinIO (blobs). |
| Buses | NATS (ephemeral signalling), Redpanda (durable log). **Both are intentional.** |
| Edge | Envoy (gRPC-Web gateway). |
| Current work | See [`implementation_plan.md`](implementation_plan.md) — a 44-step, 4-gate refactoring. |
| Task board | <https://github.com/orgs/guardyn/projects/3> |

Once `docs/INDEX.md` exists, read it instead of exploring the tree. It routes to every
document by `read_when`, so a session loads 2–3 files rather than the whole corpus.

---

## 1. Invariants — NON-NEGOTIABLE

Any change that weakens these is forbidden. If a task appears to require it, **stop and
ask the user.** Do not proceed under an assumption.

| # | Invariant | Meaning |
|---|---|---|
| **I-1** | **Zero-Knowledge** | The server must never be able to read message, file or media plaintext. No payload, key, or decrypted metadata may ever reach a log, a metric, a trace, or `stdout`. |
| **I-2** | **Always-On E2EE** | Encryption cannot be disabled — not by flag, not by config, not "for development". |
| **I-3** | **Post-Quantum** | Key agreement must resist Harvest-Now-Decrypt-Later. Hybrid X25519 + ML-KEM-768; classical strength is the floor, never the ceiling. |
| **I-4** | **Data Sovereignty** | The entire stack must be 100% self-hostable with no third-party dependency and no vendor lock-in. |

### Known violations under repair

Two invariants are **currently unmet**. Do not "fix" them ad hoc — they have owned steps:

- **I-2 is violated.** `messaging-service/src/handlers/` carries duplicate handler pairs
  (`send_message.rs` vs `send_message_e2ee.rs`, and three more). **The non-E2EE path is the
  registered one.** `docker-compose.dev.yml` sets `GUARDYN_E2EE_ENABLED=false`.
  → Repaired by **PR-32**. Breaking change, already approved.
- **I-3 is unmet.** `crypto/src/pqxdh.rs` is a real hybrid implementation, but the `pq`
  feature is off by default and no backend service enables it — and decisively,
  `backend/proto/` contains **zero** ML-KEM fields, so the server cannot publish a PQ
  public key at all. → Repaired by **PR-36…PR-40**.

---

## 2. Git workflow — STRICT

### 2.1 Never commit to `main`

Direct commits to `main` or `master` are **forbidden**. `main` is protected by a ruleset
requiring a pull request. Before any commit:

```sh
git branch --show-current   # must NOT be main or master
```

### 2.2 One micro-step = one branch = one PR = one issue

- Branch name: `<type>/<issue-number>-<slug>` — e.g. `security/43-enforce-always-on-e2ee`.
- `<type>` ∈ `feat | fix | docs | refactor | chore | security`.
- Every PR closes exactly one issue and is tracked on the project board.

### 2.3 PR budget

**≤400 hand-written changed lines, or ≤8 files.** If a step would exceed this, **split it
before opening the PR**. No exceptions.

Bulk deletions and generated/vendored files are exempt from the count, but such a PR must
contain *nothing else*.

Rationale: agents have finite context. A 400-line ceiling keeps a whole step — diff, tests
and the docs it touches — inside one session, so no step needs context reconstruction.

### 2.4 Commit messages

Conventional Commits, English, imperative mood. Reference the issue with `Refs #N`.
Explain **why**, not just what. State anything deliberately left out of scope.

### 2.5 Approval gates

Phases end at gates **G1–G4**. At a gate: **STOP**, post the phase report to the board,
and **wait for explicit user approval**. Never carry on into the next phase unprompted.

---

## 3. Language policy — English only

**English is the only permitted language for all project content**: documentation, code
comments, commit messages, PR text, identifiers, and log strings. No transliteration.

**Forbidden:** Russian, Ukrainian, any Cyrillic-script language, any non-English language,
and mixed-language content.

**The only exceptions** are explicitly-marked localization files:
`client-mobile/lib/l10n/`, `landing/i18n/`, and files suffixed `.{locale}.md`
(`README.ru.md` is valid; Russian inside `README.md` is not).

**Allowlisted file** that legitimately contains Cyrillic, because the Cyrillic *is* a
counter-example rather than content — never flag it:
`.github/.copilot-commit-message-instructions.md`.

**Why:** third-party security auditors require English. Ambiguity in a security-critical
implementation is a vulnerability.

If asked to produce non-English content, state this policy and offer a separate,
suffixed translation file.

---

## 4. Zero-knowledge logging — I-1 enforcement

The backend emits **structured JSON logs**. Everything below is a hard prohibition.

**Never log, trace, or emit as a metric label:**
- Message, file or media plaintext — or ciphertext.
- Any key material: identity keys, pre-keys, ratchet state, MLS secrets, ML-KEM private keys.
- Tokens, passwords, password hashes, session secrets.
- PII: email, phone number, IP address, precise location.

**Practices:**
- Never `#[derive(Debug)]` on a type holding key or payload material — implement `Debug` to
  emit `[REDACTED]`. Use the `Redacted<T>` wrapper from `guardyn-common` once PR-24 lands.
- Never interpolate a whole request or response struct into a log line.
- Identifiers (`user_id`, `device_id`) are correlatable metadata: log only when genuinely
  needed for an operation, never at `info` on a hot path.
- Initialize tracing **only** via `guardyn_common::observability::init_tracing`. Constructing
  a `tracing_subscriber::FmtSubscriber` directly bypasses the redaction layer and is forbidden.

When unsure whether a field is sensitive: **do not log it.**

---

## 5. Code standards

### 5.1 Rust

- **No `unwrap()` or `expect()` in non-test code.** Propagate with `Result` and `?`.
- Errors via `thiserror`, built on `guardyn_common::error`. No stringly-typed errors.
- Every public item carries a doc comment.
- One gRPC handler per file under `handlers/`.
- `cargo fmt` and `cargo clippy -- -D warnings` must both pass.
- No `unsafe` outside FFI boundaries; where unavoidable, justify it in a comment.

### 5.2 Protocol Buffers are canonical

`backend/proto/*.proto` is the **single source of truth** for the wire contract.

| Element | Convention |
|---|---|
| Messages, services, RPCs | `PascalCase` |
| Fields | `snake_case` |
| Enum type | `PascalCase` |
| Enum values | `SCREAMING_SNAKE_CASE` |

Prost converts these to Rust automatically. **Never invent an enum variant** — read the
proto and use the converted name:

| ❌ Wrong | ✅ Correct | Proto |
|---|---|---|
| `ErrorCode::Internal` | `ErrorCode::InternalError` | `INTERNAL_ERROR` |
| `ErrorCode::Unauthenticated` | `ErrorCode::Unauthorized` | `UNAUTHORIZED` |
| `ErrorCode::InvalidInput` | `ErrorCode::InvalidRequest` | `INVALID_REQUEST` |
| `ErrorCode::AlreadyExists` | `ErrorCode::Conflict` | `CONFLICT` |

Change the proto first, then regenerate. **Never hand-edit generated code.**

> Codegen is currently inconsistent — `messaging-service` uses `tonic::include_proto!`
> (OUT_DIR) while five services `include!` ~13,800 lines of committed output under
> `src/generated/`. **PR-23** unifies this on OUT_DIR. Until then, treat the `.proto`
> file — never the committed copy — as truth.

### 5.3 No new datastore without an ADR

The store topology is deliberate and user-approved. Adding, replacing or removing a
datastore requires an accepted ADR **and** explicit user approval. In particular:

- **TiKV**, not PostgreSQL, is the metadata/auth store. This is deliberate; do not "fix" it.
- **Dragonfly/Redis is deliberately absent**, deferred post-launch. Do not introduce it.
- **NATS and Redpanda coexist by design** with separated roles. Do not consolidate them.

---

## 6. Domain-agnostic architecture

Guardyn must deploy under **any** domain — this is how I-4 is honoured in practice.

**Never hardcode a domain** in code, manifests, or documentation.

```yaml
host: auth.guardyn.io   # ❌ never
host: auth.${DOMAIN}    # ✅ always
```

The `DOMAIN` environment variable is the **single source of truth**. All service hostnames
derive from it: `auth.${DOMAIN}`, `api.${DOMAIN}`, `ws.${DOMAIN}`, `media.${DOMAIN}`,
`app.${DOMAIN}`.

In documentation use `yourdomain.com` or `example.com`. Never assume a subdomain layout or
a TLD. Changes must work with `.local`, `.test` and real domains alike.

---

## 7. File organization

| Content | Location |
|---|---|
| Documentation | `docs/` (never the repo root, except the files listed below) |
| Infrastructure scripts | `infra/scripts/` |
| E2E / test scripts | `backend/crates/e2e-tests/scripts/` |
| Scratch, WIP, personal notes | `_local/` — **gitignored, never referenced from a tracked file** |

**Permitted root-level Markdown:** `README.md`, `AGENTS.md`, `CLAUDE.md`,
`CONTRIBUTING.md`, `CHANGELOG.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`,
`implementation_plan.md`. Adding another requires justification.

**Naming:** `SCREAMING_SNAKE_CASE.md` for docs, `kebab-case.sh` for scripts,
`snake_case.rs` for Rust, `kebab-case/` for directories.

`_local/` holds live grant material and personal notes. **Never delete it, never move it,
and never link to it from a tracked file** — cloners cannot see it.

---

## 8. Testing

Standard unit tests are **insufficient** for E2EE code.

- Cryptographic modules require **property-based tests** (`proptest`) and **fuzz targets**
  (`cargo-fuzz`) on every parser reachable from attacker-controlled bytes.
- A bug fix lands with a regression test that fails before the fix.
- Never weaken or delete a test to make CI pass. If a test is wrong, say so explicitly and
  explain why in the PR.

---

## 9. Session checklist

Before starting:
1. Read `docs/INDEX.md` (once it exists); load only what `read_when` matches.
2. Confirm the step weakens no invariant in §1.
3. Confirm `git branch --show-current` is not `main`.
4. Confirm the issue exists and is `In Progress` on the board.

Before opening a PR:
5. Diff is within the §2.3 budget — otherwise split it.
6. `cargo fmt --check`, `cargo clippy -- -D warnings`, and the test suite pass.
7. Documentation mapped to the changed paths is updated (see `docs/.manifest.yaml`
   once PR-15 lands), or the PR is labelled `docs-impact:none` with a reason.
8. The PR body states what was deliberately left out of scope.

At a gate: **STOP. Report. Wait.**

---

## 10. When to stop and ask

Stop and ask the user — do not guess — when a task would:

- Weaken any invariant in §1.
- Add, remove or replace a datastore, message bus, or major dependency.
- Change a public wire contract in a non-additive way.
- Delete anything under `_local/`.
- Rewrite git history.
- Require a credential or permission you do not have.

Asking costs one message. Guessing wrong on a security-critical system costs far more.
