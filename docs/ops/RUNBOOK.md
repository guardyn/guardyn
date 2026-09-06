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

## Escalation

Security issues go to security@guardyn.app and **never** into a public issue
([`SECURITY.md`](../../SECURITY.md)). Anything touching an invariant in `AGENTS.md` §1 is a
security issue by definition.
