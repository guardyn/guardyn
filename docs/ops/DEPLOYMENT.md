---
id: ops-deployment
type: ops
status: accepted
owns: [infra/k8s/, infra/k3d-config.yaml, docker-compose.dev.yml, Justfile]
read_when: [deploying, changing a manifest, changing an overlay, onboarding a self-hoster]
tokens: 875
supersedes: []
---

# Deployment

Two targets: Docker Compose for a single machine, Kubernetes for everything else. Both are
first-class — self-hosting is the product (**I-4**), so neither is a toy.

## Single machine — Docker Compose

```sh
just dc-up          # nine infrastructure containers plus six services
just dc-status      # health of each
just dc-logs        # follow everything
just dc-down        # stop
just dc-reset       # stop and destroy volumes
```

Infrastructure: `nats`, `redpanda`, `redpanda-console`, `pd`, `tikv`, `scylladb`, `minio`,
`minio-init`, `envoy`. Services: auth, messaging, presence, media, call, notification.

`just dc-rebuild <service>` rebuilds one image; `just dc-shell <service>` opens a shell;
`just dc-cqlsh`, `just dc-tikv-status` and `just dc-redpanda-health` reach the stores
directly.

## Kubernetes

```sh
just kube-create      # k3d cluster from infra/k3d-config.yaml
just kube-bootstrap   # cert-manager and core components
just k8s-deploy <service>
just verify-kube      # smoke checks
just teardown
```

The local cluster is k3d: **3 servers, 2 agents**, k3s `v1.31.5-k3s1`, Traefik disabled
because Envoy is the ingress path.

### Layout

`infra/k8s/base/` holds `namespaces`, `apps`, `envoy`, `tikv`, `scylladb`, `minio`,
`cert-manager`, `cilium`, `monitoring` and `observability`.

`overlays/local` is the development layer. `overlays/prod` adds `hpa.yaml`, `pdb.yaml`,
`ingress.yaml`, `network-policies.yaml`, `service-monitors.yaml`, `slo-rules.yaml`,
`alertmanager-config.yaml` and Grafana SLO dashboards.

### Ports

| Service | Port |
|---|---|
| auth-service | 50051 |
| messaging-service | 50052 (gRPC), 8081 (WebSocket) |
| presence-service | 50053 |
| media-service | 50054 |
| notification-service | 8080, 9090 (metrics) |

## Domains

**Never hardcode a hostname.** `DOMAIN` is the single source of truth, and every hostname
derives from it: `auth.${DOMAIN}`, `api.${DOMAIN}`, `ws.${DOMAIN}`, `media.${DOMAIN}`,
`app.${DOMAIN}`. Deployment must work with `.local`, `.test` and real domains alike.

## Secrets

SOPS with age, configured in `.sops.yaml`. Only `*.enc.yaml` is committed; `age-key.txt`
and any `*.key` are gitignored and must never reach the repository.

## Known deployment gaps

| Gap | Consequence | Owned by |
|---|---|---|
| No `call-service` Deployment in `infra/k8s/base/apps/` | call-service is Compose-only and cannot be deployed to Kubernetes | PR-44 |
| Envoy routes 3 of 6 services (auth, messaging, presence) | media, calls and notifications are unreachable from a browser client | PR-44 |
| `infra/k8s/base/envoy/ingress.yaml:18` hardcodes `envoy.guardyn.local` | breaks the `${DOMAIN}` rule above | **unowned** |
| Production images are tagged, not digest-pinned | a tag can be moved under a running cluster | PR-44 |
| `infra/secrets/.gitignore` ignores `*.enc.yaml` — the **encrypted** file — while the plaintext `app-secrets.yaml` is tracked | exactly inverted: the safe artefact is excluded and the unsafe one committed. The tracked values are placeholders, so no live credential is exposed *yet* | PR-42 |
| `infra/justfile` is a second, divergent task file whose `k8s:deploy` references a values file that does not exist | dead code that will mislead | unowned |
