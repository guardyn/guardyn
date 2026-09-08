---
id: ops-runbook
type: ops
status: accepted
owns: [infra/scripts/, Justfile]
read_when: [an incident, a failing service, a store that will not start]
tokens: 1062
supersedes: []
---

# Runbook

Incident procedure. Read [`OBSERVABILITY.md`](OBSERVABILITY.md) first if you are about to
add logging to diagnose something — **what you must not log applies during an incident
too**, and an incident is exactly when the temptation to dump a request is strongest.

## Rule zero

Nothing you paste into a ticket, a chat, or a postmortem may contain a payload, a key, or
PII. Redact before you copy, not after.

## Triage

```sh
just dc-status                       # Compose: per-container health
kubectl get pods -n apps             # Kubernetes: what is running
just verify-kube                     # smoke checks
just dc-logs                         # follow everything
just dc-log <service>                # one service
```

Five of six services expose a `Health` RPC. **`media-service` does not** — its liveness
must be inferred from the pod and from MinIO reachability until PR-27 adds one.

## A service will not start

1. `just dc-log <service>` — configuration errors surface immediately at startup.
2. Check its store is up before blaming the service: `just dc-tikv-status`,
   `just dc-scylla-status`, `just dc-redpanda-health`.
3. Check the JWT secret. `auth-service` and `presence-service` warn loudly when running on
   a development default; in production that warning is an incident.
4. `just dc-rebuild <service>` after a dependency change; `just dc-rebuild-clean <service>`
   if the build cache is suspect.

## A store is unhealthy

| Store | Check | Notes |
|---|---|---|
| TiKV | `just dc-tikv-status` | needs `pd` up first; a TiKV that cannot reach PD looks like a TiKV fault |
| ScyllaDB | `just dc-scylla-status`, `just dc-cqlsh` | slow first start is normal — it allocates before serving |
| Redpanda | `just dc-redpanda-health`, `just dc-redpanda-topics` | `redpanda-console` gives a UI |
| MinIO | container health | `minio-init` must have completed, or buckets are missing |
| NATS | container health | losing NATS drops presence and call setup, not messages |

**A NATS outage is not a data-loss incident** — it carries ephemeral signalling only.
A Redpanda outage is: the durable log backs notification delivery.

## Kubernetes: port-forwards keep dying

```sh
just port-forward           # watchdog: auto-restarts with backoff
just port-forward-status
just port-forward-stop
```

The watchdog health-checks every 5 seconds and restarts with exponential backoff up to 10
attempts. ChromeDriver is optional and is fetched on demand; if it is missing the watchdog
warns and continues rather than failing the whole port-forward set.

## Cluster wedged after a host restart

`bash infra/scripts/fix-cluster-after-restart.sh` — the common k3d-after-reboot repair.
If it does not help, `just kube-delete && just kube-create && just kube-bootstrap` is
cheap for a local cluster.

## Suspected data exposure

1. **Stop shipping logs** before investigating. Every second of continued export widens
   the exposure.
2. Establish what was emitted, using the greps in `OBSERVABILITY.md`.
3. Rotate anything that could have been exposed — JWT secret, age key, store credentials.
4. The fix is a regression test that fails before it (`AGENTS.md` §8), not just a patch.
5. If key material was exposed, affected sessions must be re-established. There is no way
   to un-leak a ratchet state.

## Documentation checks

```sh
just docs-verify
```

Five checks — frontmatter, impact, glossary, links, language — defined in
[`../../.claude/rules/40-doc-sync.md`](../../.claude/rules/40-doc-sync.md) and run in CI on
every pull request. Check 2 is the one that matters: changing a source path without
updating the documents mapped to it in `docs/.manifest.yaml` fails the build, unless the PR
carries `docs-impact:none` **with a stated reason**.

Run it before pushing. It is faster than a round trip through CI.

## Code-style verification

```sh
just rules-verify
```

The predicates of [`.claude/rules/20-code-style.md`](../../.claude/rules/20-code-style.md)
plus `ZK-INIT` from [`30-zk-logging.md`](../../.claude/rules/30-zk-logging.md), executed. They had been stated as testable predicates since PR-05 with nothing running them.
[`rules.yml`](../../.github/workflows/rules.yml) runs it on **every** pull request - not on a
path filter, because `NAME-SH`, `ORG-ROOT`, `LANG-MD` and `ORG-LOCAL` are repository-wide
properties and a `backend/**` filter would leave them unenforced for exactly the changes most
likely to break them.

Bash, git and awk only, so the job needs no toolchain and finishes in seconds. `cargo fmt` and
`cargo clippy` stay in `build.yml`, where a Rust toolchain already exists.

**Two predicates are ratcheted rather than enforced.** `RS-UNWRAP` (49 sites) and `NAME-SH`
(5 files) fail today and are owned by later work, so each carries a budget equal to its
measured count: the build fails when the number **grows**, and every fix lowers the ceiling.

If `rules-verify` fails on a ratchet you did not mean to touch, you added a site. If it tells
you the count is *down*, lower the budget in the same PR - the number is a claim about the
repository, and a stale one is worse than none.

**If `ZK-INIT` fails**, a service is building its own `tracing` subscriber. That service gets
no JSON logs, no OTel traces, and - the reason this is a hard fail rather than a style nit -
**no redaction layer**, so any payload or key field it logs reaches the writer in clear. The
fix is never to relax the check: route the service through
`guardyn_common::observability::init_tracing`, binding the returned guard to a named variable
so it is not dropped immediately. `presence-service/src/main.rs` is the reference for a
service with no `ServiceConfig`; `auth-service/src/main.rs` for one with.

**If `E2EE-DUP` fails**, a `*_e2ee.rs` handler has appeared beside an unsuffixed one. The check
is inverted on purpose: two handlers for one RPC means one of them is the wrong path, and the
suffix does not tell you which. In this repository it was the `_e2ee` one — those handlers
encrypted the client's plaintext server-side and decrypted on the way back out, while the
unsuffixed handler relayed ciphertext untouched. The fix is to delete the twin, never to rename
it or to exempt the path.

**If `ZK-PII` fails**, a log macro is being handed a raw IP address, email or phone number.
All three are PII under `AGENTS.md` §4, and **I-1** forbids PII in any log, span or metric.
Do not silence it by renaming the field — the address is the problem, not the label. For a
client IP, log `guardyn_common::rate_limit::ip_fingerprint(&ip)` instead: an operator still
sees that the same address recurred, without the address reaching the log.

The predicate greps for the field *name*, so it is a floor, not a ceiling. **It cannot see a
raw IP under a neutral name, or one that reaches a log through a `Display` impl.**
`RateLimitError::IpBlocked` was exactly that second case and was found by reading the code,
not by the check. Treat a `ZK-PII` pass as "no obvious breach", never as proof.

## Fuzzing

```sh
just fuzz-build                    # compile every target - the cheap drift check
just fuzz padme_unpad 300          # fuzz one parser for 300 seconds
just fuzz ratchet_message          # 60 seconds by default
```

Four targets, one per parser reachable from attacker-controlled bytes:
`padme_unpad`, `ratchet_message`, `sealed_sender_envelope`, `x3dh_prekey_message`.

`fuzz.yml` runs the **build** on every crypto pull request and the **run** on a nightly
schedule. The split is deliberate: compiling catches the way fuzz targets usually rot — a parser
signature changes and the harness stops matching it — while a meaningful run takes longer than a
PR should wait. `workflow_dispatch` takes a `seconds` input for an on-demand longer run.

**The toolchain is pinned to a date**, `nightly-2026-01-31`, in two places that must agree:
`FUZZ_TOOLCHAIN` in the Justfile and the `env` block of `fuzz.yml`. `cargo-fuzz` needs
`-Z sanitizer=address`, which stable does not have; a bare `nightly` would reintroduce exactly
the drift `rust-toolchain.toml` exists to prevent. The fuzz crate is outside the backend
workspace for the same reason, which needs both an `exclude` in `backend/Cargo.toml` **and** an
empty `[workspace]` table in `fuzz/Cargo.toml` — without the second, cargo resolves the parent
workspace anyway and refuses to build.

**When a target crashes**, libFuzzer writes the input to `fuzz/artifacts/<target>/crash-<hash>`
and CI uploads it as an artifact. Reproduce with
`cargo +nightly-2026-01-31 fuzz run <target> fuzz/artifacts/<target>/crash-<hash>`. Then commit a
**named regression test** carrying those bytes — `corpus/` and `artifacts/` are gitignored, so a
crash left there is lost on the next clean checkout.

## Roadmap and board sync

[`roadmap.yaml`](../roadmap/roadmap.yaml) is the machine source of truth. `roadmap-sync`
moves GitHub toward it - issue state, then milestones, then the Project v2 board - and
reconciles rather than appends, so running it twice changes nothing the second time.

Phase is tracked by **native GitHub Milestones**, titled `Phase N - ...`. A step's `phase: N`
selects the milestone; the script writes it only when it differs from what the issue already
carries. Milestones are REST and work with the ambient token, so unlike the board half this
pass is never skipped.

```sh
just roadmap-sync        # dry: print the plan, write nothing
just roadmap-sync 0      # write
```

It runs in CI on every push to `main` that touches `roadmap.yaml`, and a manual
`workflow_dispatch` defaults to dry.

**Never edit the board by hand.** Edit `roadmap.yaml` and let the sync move it, or the two
diverge with no way to tell which is right.

One condition still makes the **board half** a no-op, deliberately:
`project_sync_enabled: false` in `roadmap.yaml`. The board needs `GUARDYN_PROJECT_TOKEN`
with `repo` + `project` scope, which no agent can create - preflight **P-1**. A missing
secret is a documented state, not a build failure, so the script says so and exits 0. The
flag gates the board **only** - issue state and milestones reconcile either way.

> **Before flipping `project_sync_enabled` to `true`, check that every `status:` in
> `roadmap.yaml` matches its issue's real state.** The script reconciles issue state *from*
> the file, so a stale `todo` reopens a correctly-closed issue. This bit once: PR-06 through
> PR-18 stayed `todo` after merging, which would have reopened thirteen issues.

## PR to issue linking

`roadmap-sync` reconciles the roadmap on a schedule; [`pr-link.yml`](../../.github/workflows/pr-link.yml)
handles the single PR in front of it, at the moment it opens.

One micro-step is one branch, one PR, one issue, and the branch name carries the issue id -
`feat/121-milestone-sync` belongs to #121. From that the workflow derives two things:

| It sets | So that |
|---|---|
| `Closes #N` in the PR body, when no closing reference is there already | merging the PR closes the issue, with no one having to remember |
| the issue's milestone, on the PR | a phase's progress counts the work, not only the ticket |

It never rewrites a body that already names a closing issue, and it writes the milestone only
when it differs - the same reconcile-don't-append rule `roadmap-sync` follows.

**A branch that does not match `<type>/<issue>-<slug>` is skipped, not failed.** Dependabot
branches are the common case, and nothing here is a merge gate.

The board move (*In Review* on open, *Done* on merge) is **not implemented** - P-1 again. The
guard is in place and says so.

## Escalation

Security issues go to security@guardyn.app and **never** into a public issue
([`SECURITY.md`](../../SECURITY.md)). Anything touching an invariant in `AGENTS.md` §1 is a
security issue by definition.
