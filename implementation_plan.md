---
id: implementation-plan
type: roadmap
status: accepted
version: 1.0.0
created: 2026-09-06
owns: [docs/, .claude/, .github/, AGENTS.md, CONTRIBUTING.md, README.md]
read_when: [starting any refactoring micro-step, resuming work, checking gate status]
supersedes: [docs/IMPLEMENTATION_PLAN.md]
---

# Guardyn — Full Revision & Refactoring Execution Plan

**Audience:** AI coding agents. **Language:** English only.
**Status:** Approved. Preflight blockers P-1 and P-2 are OPEN and require human action.

> **Reading contract.** This is the execution SSOT until `docs/roadmap/roadmap.yaml`
> exists (PR-14), after which `roadmap.yaml` becomes the machine SSOT and this file
> becomes the narrative reference. Do not begin any micro-step without reading
> §"Micro-stepping contract" and §"Preflight".

---

## 1. Context

Guardyn is a **large existing codebase**, not a greenfield project.

| Area | Scale |
|---|---|
| Tracked files | 1,073 |
| Backend (Rust) | 10 crates, 57,456 LOC (~43,600 hand-written, ~13,860 committed generated) |
| Mobile (Flutter) | 85,469 LOC, 240 files |
| Desktop (Tauri 2 + SolidJS) | 30,745 LOC TS/TSX + 19,278 LOC Rust |
| Landing (static HTML) | 6,465 LOC |
| Infra (k8s/Kustomize/Envoy) | 5,380 LOC |
| Tracked documentation | ~19,000 lines of Markdown |

It ships as `v1.0.1` and claims production readiness.

The originating brief was written for a **new** project. It is therefore executed here as
**reverse-documentation**: the AI-first documentation core is derived **from committed code**,
never invented ahead of it. Any document describing intent rather than shipped behaviour is a
hallucination vector and is out of scope.

### 1.1 Motivating defects (all verified)

1. **No AI-agent contract.** No `.claude/`, no `AGENTS.md`, no `CLAUDE.md`. `.agent/workflows/`
   is an empty directory. The de-facto agent constitution is `.github/copilot-instructions.md`
   (684 lines) — unversioned, with zero enforcement behind it.
2. **Documentation has no spine.** 38 files / 15,828 lines under `docs/` with **no index**,
   **no ADRs**, **no glossary**. Roadmap content is smeared across `README.md:245`,
   `CHANGELOG.md:484`, and a 2,001-line `docs/IMPLEMENTATION_PLAN.md`. Five files are dated
   status snapshots that are already rotting. Tracked `docs/archive/README.md` links into
   `_local/done/`, which is gitignored and invisible to every cloner.
3. **Nothing is enforced.** `main` has **no branch protection and no rulesets**; all recent
   commits landed directly on it. `build.yml` marks clippy, tests **and** cargo-audit
   `continue-on-error: true`, so only `cargo fmt` can fail the build. No CODEOWNERS, no
   dependabot.

### 1.2 Domain invariants (NON-NEGOTIABLE)

| # | Invariant | Current status |
|---|---|---|
| I-1 | **Zero-Knowledge** — server never accesses decrypted payloads | At risk: no log redaction (§Phase 3.1) |
| I-2 | **Always-On E2EE** — cannot be disabled | **VIOLATED**: non-E2EE handler path is the registered one; `GUARDYN_E2EE_ENABLED=false` in dev compose (§Phase 3.3) |
| I-3 | **Post-Quantum** — forward secrecy vs Harvest-Now-Decrypt-Later | **UNMET**: PQXDH unreachable end-to-end (§1.4) |
| I-4 | **Data Sovereignty** — 100 % self-hostable, no vendor lock-in | Holds. All components self-hosted. |

Any micro-step that would weaken I-1…I-4 is forbidden and must be escalated to the user.

### 1.3 Architecture decisions (user-approved 2026-09-06)

The brief's target architecture diverged from the code in two of four stores. Resolved:

| Concern | Decision | Consequence |
|---|---|---|
| Metadata / auth / RBAC | **Keep TiKV**, amend the spec | `tikv-client 0.3` + PD/TiKV v7.5.0 are load-bearing (auth, MLS group state, presence, media metadata). **No PostgreSQL migration.** TiKV already satisfies the multi-region goal the brief assigned to CockroachDB/TiDB. → ADR-0001 |
| Dragonfly / Redis L1 cache | **Defer post-launch** | Documented as ADR-approved scale target only. Ships on the current NATS/TiKV path. → ADR-0006 |
| Event bus | **Keep both, roles separated** | NATS = ephemeral low-latency signalling; Redpanda = durable ingestion log. No code churn. → ADR-0003 |
| Post-quantum | **Dedicated phase, hybrid KEM** | See §1.4. → ADR-0005 |

### 1.4 Post-quantum: verified state

`backend/crates/crypto/src/pqxdh.rs` (539 L) is a **real** hybrid X25519 + ML-KEM-768
implementation following the Signal PQXDH spec. It is nonetheless **entirely unreachable**:

- `crypto/Cargo.toml` — `default = ["std"]`; `pq = ["ml-kem"]` is opt-in.
- `auth-service`, `messaging-service`, `call-service` all declare
  `guardyn-crypto = { path = "../crypto" }` **with no features** → PQ is compiled out of every
  backend service.
- `crypto-ffi` does enable it (`default = ["full"] = ["pq"]`), so only the Flutter client can
  reach `crypto_generate_hybrid_key_bundle`.
- **Decisive blocker:** `grep -i 'ml_kem|kyber|pqxdh|post_quantum' backend/proto/` returns
  **NONE**. `common.KeyBundle` carries X25519/Ed25519 only. The server has no field in which to
  publish an ML-KEM public key, so the handshake cannot complete regardless of feature flags.

**Phase 4 is therefore wire-and-enable + prove, not implement.**

---

## 2. Preflight — hard blockers

These are **prerequisites, not tasks**. P-1 and P-2 require human action no agent can perform.

### P-1 · GitHub Project automation has no usable credential ⚠️ HUMAN ACTION REQUIRED

Zero-touch Project-board sync is a hard requirement. Verified state:

- `guardyn` is an **Organization**; repo is public; `has_projects: true`.
- The active `GITHUB_TOKEN` is a fine-grained PAT and is **rejected outright** by the org:
  *"forbids access via fine-grained personal access tokens if the token's lifetime is greater
  than 366 days."*
- The fallback keyring OAuth token authenticates but carries scopes
  `gist, read:org, repo, workflow` — **`read:project` / `project` are absent**, so
  `gh project list` and every `projectsV2` GraphQL field fail with `INSUFFICIENT_SCOPES`.

**Required from the human architect:**
1. A classic PAT (or GitHub App installation token) with `repo` + `project` scopes.
2. Stored as repository secret `GUARDYN_PROJECT_TOKEN`.
3. A Project v2 board created under the `guardyn` org, its number recorded in
   `docs/roadmap/roadmap.yaml` as `project_number`.

**Until this exists**, all Project-sync automation is authored and unit-tested but **cannot
run**. PR-18 ships it behind a guard that logs a warning and exits 0 rather than failing CI.

### P-2 · `main` is unprotected ⚠️ HUMAN ACTION REQUIRED

`GET /repos/guardyn/guardyn/branches/main/protection` → `404 Branch not protected`.
`GET /repos/guardyn/guardyn/rulesets` → `[]`.

The "no direct commits to main" rule is currently unenforceable at the platform level.

**Required ruleset on `main`:**
- Require a pull request before merging; require 1 approval.
- Require status checks: `lint-and-test`, `security-audit`, `docs-verify`.
- Block force-push and branch deletion. No bypass actors.

**Agent-side belt-and-braces** (PR-06, agent-authorable, does not replace the ruleset):
a `pre-commit` hook plus a `.claude/settings.json` `PreToolUse` Bash hook rejecting any
`git commit` / `git push` while `HEAD` is on `main` or `master`.

### P-3 · `_local/` is OUT OF SCOPE — do not delete

`_local/` is gitignored, ~5.2 MB, 44 Markdown files / 18,669 lines. It includes
`_local/grant/opentech.fund/` — **4.7 MB of live OTF grant application material**: proposal
drafts, budgets, funding determinations and correspondence.

**The "destroy old docs" directive applies to *tracked* documentation only.**
`_local/` is never touched, moved, or referenced from a tracked file.

---

## 3. Micro-stepping contract

Codified in `AGENTS.md` (PR-04) and `.claude/rules/10-git-workflow.md` (PR-05).

- **1 micro-step = 1 branch = 1 PR = 1 GitHub Issue.**
- **Branch naming:** `<type>/<issue-id>-<slug>` — e.g. `docs/42-adr-tikv-metadata-store`.
  `<type>` ∈ `feat | fix | docs | refactor | chore | security`.
- **PR budget: ≤ 400 changed lines** of hand-written diff, **or** ≤ 8 files.
  Bulk deletions and generated/vendored files are exempt but must be the PR's *only* content.
- A PR that would exceed budget **must be split before opening**. No exceptions.
- Each PR is independently revertable and leaves `main` green.
- **Never commit directly to `main` or `master`.** Ever.
- **Approval gate** at the end of every phase: the agent **STOPS**, posts a phase report to
  the Project board, and **waits for explicit user approval**. Gates are G1–G4.

**Rationale (token economy):** agents have finite context. A 400-line ceiling keeps an entire
micro-step — diff, tests, and the docs it touches — inside a single session window, so no
step ever requires reconstructing lost context.

---

## 4. Phase 1 — Purge & Initialization

**Goal:** delete legacy tracked docs; stand up the AI-first documentation core and the
enforcement layer. **No source code changes in this phase.**

### 4.1 Docs purge — PR-01 … PR-03

| PR | Action |
|---|---|
| **PR-01** | Delete the 24 top-level `docs/*.md`, `docs/testing/*`, `docs/archive/*`. Salvaged content is *quoted into* the new specs (§4.3), never moved wholesale. |
| **PR-02** | Delete `cicd/github/workflows/{build,release,test}.yml` — verified **byte-identical** duplicates of `.github/workflows/`; dead, since GitHub executes only `.github/`. Remove the stale `cicd/github/workflows/test.yml` path filter from `.github/workflows/test.yml`. Delete the orphaned `cicd/github/actions/reproducible-build/action.yml` and the unreferenced `cicd/docker/Dockerfile.ci`. |
| **PR-03** | Delete committed build artifacts: `client-desktop/e2e-report/`, `client-desktop/test-results/`, `client-mobile/flutter_0{1,2}.png`, `client-mobile/test-reports/`. Extend `.gitignore` accordingly. |

**Retained deliberately** (security-relevant, externally cited, or licence-bound):
`docs/security/**` (6 files — rewritten in place in §4.3, not deleted), `SECURITY.md`,
`LICENSE`, `NOTICE`, `CODE_OF_CONDUCT.md`, `CHANGELOG.md`, `landing/**`.

### 4.2 AI-agent contract — PR-04 … PR-07

```
AGENTS.md                       # canonical, tool-agnostic agent constitution
CLAUDE.md                       # 3-line pointer -> AGENTS.md (no duplication)
.claude/
  settings.json                 # permissions + PreToolUse guard hooks
  rules/
    00-invariants.md            # I-1..I-4 verbatim; first-read, always
    10-git-workflow.md          # branch/PR law (§3)
    20-code-style.md            # forbidden patterns, Rust/TS/Dart idiom
    30-zk-logging.md            # zero-knowledge logging law
    40-doc-sync.md              # the auto-maintenance algorithm (§4.4)
  skills/
    doc-sync/SKILL.md           # executes the §4.4 algorithm
    adr-new/SKILL.md            # scaffolds an ADR, assigns the next number
    issue-sync/SKILL.md         # roadmap.yaml -> Issues/Project (§5.1)
  commands/
    micro-step.md               # open branch+issue, enforce PR budget
.github/
  CODEOWNERS
  dependabot.yml
```

- **PR-04** — `AGENTS.md` + `CLAUDE.md`. `AGENTS.md` supersedes
  `.github/copilot-instructions.md`, which is reduced to a pointer stub (**kept**, so Copilot
  keeps working — not deleted). Its three load-bearing sections — Language Policy, Naming
  Conventions, File Organization — migrate into `.claude/rules/20-code-style.md`.
- **PR-05** — `.claude/rules/*`. Every rule is written as a **testable predicate**, not prose.
- **PR-06** — `.claude/settings.json` guard hooks + `pre-commit` hook (P-2 enforcement).
- **PR-07** — `CODEOWNERS`; `dependabot.yml` (cargo / npm / pub / github-actions); rewritten
  `CONTRIBUTING.md` (agent-first; drops human-onboarding prose); rewritten `README.md`
  (drops the embedded Roadmap section — it moves to §4.3).

### 4.3 Documentation core — PR-08 … PR-14

```
docs/
  INDEX.md              # machine-readable router: path | purpose | read_when | owns
  GLOSSARY.md           # SSOT ubiquitous language; every domain term + its code symbol
  spec/
    PRD.md              # features as they exist, user-story form
    SRS.md              # THE algorithmic SSOT: rules, edge cases, invariants
    SAD.md              # blueprint: crates, topology, data flow, store-per-concern
  adr/
    index.md
    ADR-0000-template.md
    ADR-0001 … ADR-0009
  api/
    INDEX.md            # proto -> service -> 89 RPCs; generated, not hand-written
  ops/
    DEPLOYMENT.md       # k3d/k8s deploy, Kustomize overlays
    RUNBOOK.md          # incident playbooks, on-call procedures
    OBSERVABILITY.md    # tracing/metrics/logs, ZK-logging rules
  roadmap/
    ROADMAP.md          # narrative phases
    roadmap.yaml        # MACHINE SSOT -> drives Issues + Project board
    STATE.md            # generated; current phase/gate/progress telemetry
```

**Every file carries YAML frontmatter.** This is what makes the base token-efficient and
indexable:

```yaml
---
id: adr-0005
type: adr            # adr | spec | ops | roadmap | index | glossary
status: accepted     # draft | accepted | superseded | deprecated
owns: [backend/crates/crypto/src/pqxdh.rs, backend/proto/common.proto]
read_when: [touching crypto, changing key bundles]
tokens: 820          # measured; INDEX.md sorts by cost so agents can budget reads
supersedes: []
---
```

`docs/INDEX.md` is the **only file an agent must read cold**. It routes to everything else via
`read_when`, so a typical session loads 2–3 documents instead of 38. This is the primary
token-economy mechanism of the whole system.

**ADRs to be written.** Each records a decision **already embodied in the code**, plus the four
taken on 2026-09-06:

| ADR | Subject |
|---|---|
| 0001 | TiKV as metadata / auth / MLS-state store (supersedes the brief's PostgreSQL) |
| 0002 | ScyllaDB for message / call / notification history |
| 0003 | Dual bus: NATS ephemeral signalling + Redpanda durable log |
| 0004 | OpenMLS 0.6 for group E2EE; custom X3DH + Double Ratchet over libsignal |
| 0005 | Hybrid PQXDH (X25519 + ML-KEM-768) — target state, gap documented |
| 0006 | Dragonfly / Redis L1 cache deferred post-launch |
| 0007 | Zero-knowledge logging and mandatory redaction |
| 0008 | Generated-protobuf strategy (`include_proto!` vs committed `src/generated/`) |
| 0009 | Micro-step PR budget and branch isolation |

| PR | Deliverable |
|---|---|
| **PR-08** | `INDEX.md` + `GLOSSARY.md` — glossary mined mechanically from proto messages and crate types, never invented |
| **PR-09** | `spec/SAD.md` |
| **PR-10** | `spec/SRS.md` |
| **PR-11** | `spec/PRD.md` |
| **PR-12** | All nine ADRs (budget-exempt: single-purpose, template-driven) |
| **PR-13** | `ops/DEPLOYMENT.md`, `ops/RUNBOOK.md`, `ops/OBSERVABILITY.md` |
| **PR-14** | `roadmap/ROADMAP.md`, `roadmap/roadmap.yaml`, `roadmap/STATE.md` |

**Language gate.** `docs/TESTING_GUIDE.md:8` is the repo's **only** genuine Cyrillic violation
(a stray Russian phrase); it dies with PR-01. The Cyrillic in
`.github/copilot-instructions.md` (lines 43–44) and `.github/.copilot-commit-message-instructions.md`
(line 50) is **intentional** — it is the policy statement listing forbidden languages, and a
bad-commit-message example. **The CI language check must allowlist those two files**, or it
will flag its own policy.

### 4.4 Auto-maintenance protocol — PR-15 … PR-16

The mechanism that makes documentation self-updating. Deterministic and CI-enforced — a
mechanism, not a convention.

**`docs/.manifest.yaml`** maps source globs to the documents that own them:

```yaml
mappings:
  - source: backend/proto/**
    requires: [docs/api/INDEX.md, docs/spec/SRS.md]
  - source: backend/crates/crypto/**
    requires: [docs/adr/ADR-0004*, docs/adr/ADR-0005*, docs/spec/SRS.md]
  - source: backend/crates/*/src/db.rs
    requires: [docs/spec/SAD.md, docs/adr/ADR-0001*, docs/adr/ADR-0002*]
  - source: backend/crates/common/src/observability.rs
    requires: [docs/ops/OBSERVABILITY.md, docs/adr/ADR-0007*]
  - source: infra/k8s/**
    requires: [docs/ops/DEPLOYMENT.md]
```

**`just docs-verify`** — a new recipe (the Justfile currently has **zero** docs recipes) —
runs five deterministic checks, wired as required CI job `docs-verify`:

1. **Frontmatter** — every `docs/**/*.md` parses; `id` unique; `status` within enum.
2. **Impact** — for each changed source path, at least one mapped doc is also changed in the
   same PR, **or** the PR carries label `docs-impact:none` with a stated reason. **Hard fail.**
   This is what converts documentation drift from a review nit into a build failure.
3. **Glossary** — no term defined in `GLOSSARY.md` appears in docs under a synonym listed in
   its `forbidden_aliases`. Kills `User`/`Player`-class naming drift.
4. **Links** — every relative link resolves, and **no tracked doc may link into `_local/`**
   (the existing `docs/archive/README.md` defect, caught structurally so it cannot recur).
5. **Language** — no Cyrillic outside the two allowlisted policy files (§4.3).

`INDEX.md`, `roadmap/STATE.md`, and per-document `tokens:` counts are **regenerated**, never
hand-edited; `docs-verify` fails if a regenerated file is stale.

- **PR-15** — `docs/.manifest.yaml`, `just docs-verify`, the check scripts.
- **PR-16** — `.github/workflows/docs.yml` running it on every PR.

### 4.5 CI truthfulness — PR-17

`build.yml` currently sets `continue-on-error: true` on clippy, tests **and** cargo-audit —
the job is decorative. Remove it from clippy and tests; keep it on `cargo-audit` alone
(advisory-DB churn), governed by `deny.toml`'s 6 existing RUSTSEC ignores.

**Without this, no later gate means anything.** This PR is a prerequisite for G1.

> ### 🚦 GATE G1 — STOP. Post phase report to the Project board. Await explicit user approval.

---

## 5. Phase 2 — Project Restructuring & Tracking

**Goal:** SSOT codebase rules plus the zero-touch GitHub tracking loop.

### 5.1 Roadmap → Issues → Project sync — PR-18 … PR-21

`docs/roadmap/roadmap.yaml` is the single source of truth:

```yaml
project_number: null      # set by human after P-1
phases:
  - id: P3
    title: Architectural Scaffolding
    gate: G3
    steps:
      - id: P3-01
        title: Unify protobuf codegen strategy
        status: todo      # todo | in-progress | review | done | blocked
        pr: null
        issue: null
        adr: [ADR-0008]
        est_lines: 300
```

- **PR-18** — `.github/workflows/roadmap-sync.yml`. On push to `main` touching `roadmap.yaml`,
  reconcile Issues (create / retitle / relabel / close with `state_reason`) and upsert
  Project v2 `Status` / `Phase` fields via GraphQL. **Idempotent** — reconciles toward desired
  state, never blindly appends. Writes `issue:` / `pr:` ids back to `roadmap.yaml` in a bot
  commit. **Guarded:** if `GUARDYN_PROJECT_TOKEN` is unset (P-1), log a warning and `exit 0`.
- **PR-19** — `.github/workflows/pr-link.yml`. On PR open, parse the issue id from the branch
  name, link PR ↔ Issue, move the Project card to `In Review`; on merge → `Done`.
- **PR-20** — `.claude/skills/issue-sync/SKILL.md`: the agent's local path. Edit
  `roadmap.yaml`, run `just roadmap-sync`. **Never touch the board by hand.**
- **PR-21** — Label taxonomy. The repo currently has only the 9 GitHub defaults, 1 open issue,
  and no milestones. Add: `phase:1`…`phase:4`, `type:{feat,fix,docs,refactor,chore,security}`,
  `gate:G1`…`gate:G4`, `docs-impact:none`, `blocked`.

**Result:** the human architect sees exact project state on the board at all times, with zero
manual maintenance. Every phase maps 1:1 to tracked tickets.

### 5.2 Codebase SSOT rules — PR-22 … PR-23

- **PR-22** — Codify in `.claude/rules/20-code-style.md`, each as a CI-checkable predicate:
  no `unwrap()` / `expect()` in non-test code; all errors via `thiserror` +
  `guardyn-common::error`; every public item carries a doc comment; one handler per file under
  `handlers/`; **no new datastore without an ADR**.
- **PR-23** — Resolve **ADR-0008**. `messaging-service` uses `tonic::include_proto!` (OUT_DIR)
  while five services `include!` **~13,800 lines of committed generated code** under
  `src/generated/` — a live drift risk, since all seven crates still run `tonic_build` in
  `build.rs`. Standardise on OUT_DIR for all six; delete the committed copies.
  Mechanical, large, budget-exempt.

> ### 🚦 GATE G2 — STOP. Post phase report. Await explicit user approval.

---

## 6. Phase 3 — Architectural Scaffolding & ZK Hardening

**Goal:** make the data layer and observability match the now-documented architecture, and
close the zero-knowledge gaps. **Highest-risk phase.**

### 6.1 Zero-knowledge logging — PR-24 … PR-26 — HIGHEST PRIORITY

`grep -E 'redact|mask|sanitiz|scrub'` across the entire backend returns **zero hits**, while
`common/src/observability.rs` emits **JSON structured logs** carrying `user_id`, device ids and
free-form handler fields. This directly threatens invariant **I-1**.

- **PR-24** — `common/src/redact.rs`: a `Redacted<T>` newtype whose `Debug` / `Display` /
  `Serialize` impls emit `[REDACTED]`, plus a `tracing` layer dropping a denylist of field
  names (`ciphertext`, `payload`, `key`, `token`, `password`, `pre_key`, `ml_kem_private`, …).
- **PR-25** — Apply `Redacted<T>` across the crypto, auth and messaging types carrying key or
  payload material. Split per-crate if over budget.
- **PR-26** — `call-service/src/main.rs:19` and `notification-service/src/main.rs:18` bypass
  `observability::init_tracing` with a raw `FmtSubscriber`, so they get neither JSON logs nor
  OTel traces **nor the new redaction layer**. Migrate both. Add a grep-based CI check
  forbidding direct `FmtSubscriber` construction.

### 6.2 Store & bus hygiene — PR-27 … PR-29

Per the approved ADRs — **no store is added or removed in this phase**.

- **PR-27** — Document and health-check the four live stores (TiKV, ScyllaDB, MinIO, and the
  NATS/Redpanda pair). `media-service` is the **only** service with no `Health` RPC — add it.
- **PR-28** — Redpanda is started in compose and `auth-service` `depends_on` it, yet only
  `guardyn.user.events` is actually produced and consumed; the other four topic constants in
  `common/src/events.rs` are declared and unwired. Either wire or delete them — no dead
  constants. The Kafka producer currently degrades **silently** to `None` on an unreachable
  broker (`auth-service/src/main.rs:340-350`); make that explicit and alertable.
- **PR-29** — `presence-service/src/db.rs:106` carries
  `/// In production, this would use Redis or similar with TTL support`. Per ADR-0006 Dragonfly
  is deferred, so replace the comment with a TTL-correct TiKV implementation plus a link to the
  ADR. **No silent gaps.**

### 6.3 E2EE correctness — PR-30 … PR-32

- **PR-30** — `crypto/src/key_storage.rs` ships **only** `MemoryKeyStorage`, self-documented
  `WARNING: This backend does NOT persist keys across restarts`, while its own doc comment
  advertises Keychain / KeyStore / TPM backends that do not exist. `messaging-service/src/crypto.rs`
  constructs `CryptoManager` with `key_storage: None` ("development mode"). Implement a
  persistent backend; remove the dev-mode path.
- **PR-31** — MLS group state cannot round-trip:
  `handlers/send_group_message_mls.rs:179` cannot deserialize OpenMLS 0.6 group state;
  `:213` passes client ciphertext through unchanged;
  `handlers/add_group_member_mls.rs:258,285` **rebuilds the group from scratch** on membership
  change. Fix, or explicitly gate the MLS path off behind a flag with a tracked upstream issue.
- **PR-32** — **Invariant I-2 repair.** Collapse the duplicated handler pairs in
  `messaging-service/src/handlers/`: `send_message.rs` vs `send_message_e2ee.rs`,
  `receive_messages.rs` vs `receive_messages_e2ee.rs`, `add_group_member.rs` vs `_mls`,
  `send_group_message.rs` vs `_mls`. The `_e2ee` variants carry
  `TODO: Replace existing ... after testing`, and **the non-E2EE path is the one registered**.
  Additionally, `docker-compose.dev.yml` sets `GUARDYN_E2EE_ENABLED=false` and
  `GUARDYN_MLS_ENABLED=false` for dev; per I-2 these flags should not exist.
  **Removing them is a behaviour change → requires explicit user sign-off at G3.**

### 6.4 Security testing — PR-33 … PR-35

Standard unit tests are insufficient for E2EE. Current state: **no fuzz targets anywhere in the
repo**, and `proptest = "1.4"` is declared in `crypto/Cargo.toml` dev-deps but **referenced by
zero `.rs` files** — a dead dependency.

- **PR-33** — `cargo-fuzz` targets for every parser touching attacker-controlled bytes:
  `X3DHPrekeyMessage` deserialization, Double Ratchet header parsing, `sealed_sender` envelope
  decode, PADMÉ `unpad`.
- **PR-34** — Real proptest suites: Double Ratchet round-trip under arbitrary skip/reorder
  ≤ `MAX_SKIP` (1000); PADMÉ `pad` ∘ `unpad` identity across 32 B – 16 MB; X3DH agreement
  symmetry.
- **PR-35** — `notification-service` has **0 unit tests** and no e2e coverage; `call-service`
  has 9 unit tests and no e2e. Add baseline coverage for both. Extend benches beyond the
  current padding + X3DH-keygen only.

**Also cleaned in this phase:** `crypto/src/mls.rs.backup` (20 KB dead file); the orphaned
`crypto/src/frb_generated.rs` (not declared in `lib.rs`); and the `sframe` feature flag that
gates nothing (there is no `sframe.rs` — SFrame key *distribution* lives in
`call-service/src/session.rs`).

> ### 🚦 GATE G3 — STOP. **Behaviour-change sign-off required** (PR-32). Await approval.

---

## 7. Phase 4 — Post-Quantum & Launch Optimization

**Goal:** satisfy invariant I-3 end-to-end, then trim launch surface. PQ lands **before**
optimization — the invariant outranks speed-to-market.

### 7.1 Hybrid PQXDH end-to-end — PR-36 … PR-40

- **PR-36** — Extend `backend/proto/common.proto`'s `KeyBundle` with `ml_kem_public` and its
  Ed25519 signature; extend `auth.proto` `UploadPreKeysRequest` to accept ML-KEM material.
  **Additive field numbers only** — wire-compatible with deployed v1.0.1 clients.
- **PR-37** — `auth-service`: persist and serve ML-KEM public keys through `db.rs` and
  `handlers/`. Also fixes the hardcoded `device_id = "default"` at
  `handlers/mls_key_package.rs:57`.
- **PR-38** — Enable `features = ["pq"]` on `guardyn-crypto` in `auth-service`,
  `messaging-service` and `call-service`; make `pq` part of `crypto`'s `default`.
- **PR-39** — Wire `PqxdhProtocol` into `messaging-service/src/crypto.rs` session
  establishment: negotiate hybrid when the peer bundle carries ML-KEM, fall back to classical
  X3DH otherwise. **Classical security remains the floor — hybrid is never weaker.**
- **PR-40** — Fuzz + proptest for the hybrid path (extends PR-33/34). Extend `bench_pqxdh`,
  which today exercises only `generate_classical_bundle` unless built `--features pq`.
  Client integration is already ~90 % complete: `crypto_generate_hybrid_key_bundle` and
  `crypto_is_pq_available` already exist in `crypto-ffi/src/api.rs`.

**Explicitly out of scope:** ML-DSA / Dilithium. Signatures remain Ed25519. Recorded as a known
limitation in ADR-0005 with a follow-up issue — **not silently ignored**.

### 7.2 Launch optimization — PR-41 … PR-44

- **PR-41** — `common/src/rate_limit.rs` (623 L) is a **process-local `HashMap`** behind a
  `parking_lot::RwLock`. It does not hold across replicas, so the k8s `prod` overlay's HPA
  renders it ineffective. Either move to a shared backend or document the single-replica
  constraint in `ops/RUNBOOK.md`. **Decision required at G4.**
- **PR-42** — Secrets hygiene. `infra/secrets/.gitignore` is **inverted relative to intent**:
  it ignores `*.enc.yaml` (the SOPS-**encrypted** files, which `infra/secrets/README.md`
  states are safe to commit) while the **plaintext `infra/secrets/app-secrets.yaml` is
  tracked**. Plaintext k8s Secrets are also committed at
  `infra/k8s/base/apps/backend-secrets.yaml` (`jwt-secret: "guardyn-jwt-secret-changeme-in-production…"`).
  All values are dev placeholders — **not a live leak** — but the mechanism is backwards and
  must be corrected before any real secret is added.
- **PR-43** — Observability. `docker-compose.dev.yml` lines 370–394 are entirely commented-out
  dead YAML, and the referenced `./infra/observability/prometheus.yml` **does not exist** (the
  real files live under `infra/k8s/base/observability/`). Every service sets
  `GUARDYN_OBSERVABILITY__OTLP_ENDPOINT: ""`. Uncomment and wire the stack. Note also
  `Sampler::AlwaysOn` — full-volume tracing, which needs a head-sampling decision before
  production.
- **PR-44** — Deployment parity. `call-service` runs in compose but has **no k8s Deployment**
  under `infra/k8s/base/apps/`. Prod overlay images are `ghcr.io/guardyn/<service>:latest` —
  digest-pin them. Add the missing Flutter/mobile CI workflow; none exists today, and mobile is
  tested only via manual `client-mobile/scripts/*.sh`.

> ### 🚦 GATE G4 — STOP. Final report. Await explicit user approval.

---

## 8. Verification

Every PR is gated on `just verify` (new aggregate recipe) plus the CI matrix:

| Layer | Command | Enforced by |
|---|---|---|
| Docs | `just docs-verify` | `docs.yml` (new, required) |
| Rust fmt / lint | `cargo fmt --check && cargo clippy -- -D warnings` | `build.yml` (`continue-on-error` removed, PR-17) |
| Rust tests | `cargo test --workspace --all-features` | `build.yml` |
| Fuzz smoke | `cargo fuzz run <target> -- -runs=10000` | nightly workflow (PR-33) |
| Property | `cargo test --features proptest-suite` | `build.yml` (PR-34) |
| Desktop | `npm test` + `tsc --noEmit` + Playwright | `desktop-ci.yml` (exists) |
| Mobile | `flutter test` + `flutter analyze` | **new workflow (PR-44)** |
| Security | cargo-audit, cargo-deny, Trivy, CodeQL, TruffleHog, SBOM | `security.yml` (exists, daily cron) |
| Integration | `just dc-up && cargo test -p guardyn-e2e-tests` | `test.yml` |
| Board sync | `roadmap.yaml` → Issues → Project reconciles | `roadmap-sync.yml` (new, PR-18) |

**Phase-gate verification** — run manually at each of G1–G4:

1. `just dc-up` → all 9 infra containers healthy; all 6 services report `Health`.
2. Two-client E2EE round trip: `just test-two-client-messaging` (Android ↔ Linux).
3. `just docs-verify` green; `docs/roadmap/STATE.md` matches the live board state.
4. **ZK-logging spot check:** run the stack, then
   `grep -iE 'ciphertext|BEGIN|eyJ' logs` → **zero hits**.

---

## 9. Risks

| Risk | Mitigation |
|---|---|
| P-1 credential unresolved → board automation cannot run | Automation ships guarded and unit-tested; activates the moment the secret exists. Surfaced at G1, not discovered at the end. |
| PR-32 removes the non-E2EE path → breaks deployed v1.0.1 clients | Explicit behaviour-change sign-off at G3 before merge. |
| PR-23 deletes 13.8k lines of committed protobuf | Single-purpose, trivially revertable PR; CI proves regeneration before the deletion lands. |
| PR-31 blocked by OpenMLS 0.6 deserialization limits | Fallback: gate the MLS path off behind a flag with a tracked upstream issue rather than fake a fix. |
| Documentation drifts from code after the rebuild | `docs-verify` check #2 makes drift a **CI failure**, not a review nit. |
| Agent exceeds context on a large step | 400-line PR budget (§3) is enforced by `.claude/commands/micro-step.md` before a branch is opened. |

---

## 10. Sequencing

```
Preflight (P-1, P-2 — human action)
        │
        ├─ Phase 1  PR-01 … PR-17   docs purge, agent contract, doc core, CI truth   → G1
        ├─ Phase 2  PR-18 … PR-23   board sync, SSOT rules, protobuf unification     → G2
        ├─ Phase 3  PR-24 … PR-35   ZK logging, store hygiene, E2EE repair, fuzzing  → G3 ⚠ sign-off
        └─ Phase 4  PR-36 … PR-44   hybrid PQXDH end-to-end, launch optimization     → G4
```

**44 micro-steps, 4 gates.**
Phases 1–2 touch no source code. Phase 3 carries the security-critical work.
Phase 4 closes invariant I-3.

---

## 11. Agent start-up checklist

Before **every** micro-step:

1. Read `docs/INDEX.md` → load only the documents whose `read_when` matches the task.
2. Read `.claude/rules/00-invariants.md`. Confirm the step weakens none of I-1…I-4.
3. Confirm `git branch --show-current` is **not** `main` / `master`. If it is, create the
   step's branch first.
4. Confirm the step's Issue exists and is `in-progress` in `roadmap.yaml`.
5. Verify the planned diff fits the 400-line / 8-file budget. If not, **split it**.
6. On completion: update the mapped docs (`docs/.manifest.yaml`), run `just docs-verify`,
   open the PR, and let `roadmap-sync.yml` move the board.
7. At a gate: **STOP**. Post the report. **Wait for the user.** Do not proceed.
