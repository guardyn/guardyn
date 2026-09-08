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

### Service addresses are container names, never `localhost`

Every service reaches its dependencies by Compose DNS name — `pd:2379`, `scylladb:9042`,
`nats://nats:4222`, `minio:9000`, **`redpanda:9092`**. Inside a container `localhost` is that
container itself, so a `localhost` address is always wrong here.

Redpanda advertises two listeners: `internal://redpanda:9092` for clients on the Compose
network, and `external://localhost:19092` for clients on the host. Only 19092 is published, so
in-container clients must use the internal one. `auth-service` (producer) and
`messaging-service` (consumer) are the only services using Kafka; both are given
`REDPANDA_BROKERS`. Host-side tooling such as `infra/scripts/init-redpanda-topics.sh`
correctly uses `localhost:19092`.

### Two services bypass the `GUARDYN_*` config loader

`notification-service` and `call-service` read plain environment variables in `main.rs`
rather than going through `guardyn_common::config`. `notification-service` reads `LISTEN_ADDR`
and `SCYLLA_HOSTS`; setting only `GUARDYN_PORT` and `GUARDYN_DATABASE__SCYLLADB_NODES` leaves
it binding the wrong port and dialling the Kubernetes ScyllaDB FQDN. Compose now sets both
forms. Unifying this is tracked separately.

### There is no encryption feature flag

`GUARDYN_E2EE_ENABLED`, `GUARDYN_MLS_ENABLED` and their four companions are gone from Compose,
the Kubernetes base and the production overlay. Invariant I-2 admits no switch that turns
encryption off, so there is nothing to set — `messaging-service` relays opaque ciphertext and
holds no key material either way. `rules-verify` enforces this as `E2EE-FLAG`; a manifest that
reintroduces one of these names fails the build.

Before this, the production overlay set `GUARDYN_E2EE_ENABLED=true`, which selected a handler
that encrypted server-side and held the ratchet state. "Enabled" meant the opposite of what it
appears to mean, which is the reason the flag could not simply be defaulted differently.

`SCYLLADB_ENDPOINTS` and `AUTH_SERVICE_ENDPOINT` were removed alongside them. Both were read
only by a `MessagingConfig` whose fields nothing used; the live names are
`GUARDYN_DATABASE__SCYLLADB_NODES` and `AUTH_SERVICE_URL`.

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
| call-service | 50056 (gRPC), 8085 |
| notification-service | 50055 |

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
