---
id: ops-observability
type: ops
status: accepted
owns: [backend/crates/common/src/observability.rs, infra/k8s/base/observability/, infra/k8s/base/monitoring/]
read_when: [adding a metric or span, debugging in production, changing tracing]
tokens: 891
supersedes: []
---

# Observability

Three signals — logs, metrics, traces — under one hard constraint: **none of them may
carry anything the server is not supposed to know** (**I-1**). Observability that leaks a
payload defeats the encryption above it.

## The one way to initialise tracing

```rust
guardyn_common::observability::init_tracing(service_name, log_level, otlp_endpoint)
```

Constructing a `tracing_subscriber::FmtSubscriber` directly **bypasses the redaction
layer and is forbidden** (ADR-0007). Logs are structured JSON (`.json()`), tagged with
`service = service_name`.

`init_tracing` takes an optional OTLP endpoint. When present it initialises an
OpenTelemetry tracer exporting to Tempo; when absent, tracing is local only, and the
service still starts.

## Never emit

Message, file or media plaintext **or ciphertext** · identity keys, pre-keys, ratchet
state, MLS secrets, ML-KEM private keys · tokens, passwords, password hashes, session
secrets · email, phone number, **IP address**, precise location.

This applies to log lines, span attributes, **and metric labels** equally. A metric label
is a log line that is retained longer.

`user_id` and `device_id` are correlatable metadata: log them only when an operation
genuinely needs them, and never at `info` on a hot path.

When unsure whether a field is sensitive: **do not log it.**

## Checking yourself

```sh
# no service builds its own subscriber
grep -rln --include='*.rs' -e FmtSubscriber -e 'tracing_subscriber::fmt()' backend/crates/*/src

# no log macro takes a raw IP, email or phone
grep -rnE '(trace|debug|info|warn|error)!\(' --include='*.rs' backend/crates/*/src \
  | grep -iE '"[^"]*\b(ip|email|phone)\b[^"]*"[^)]*,'
```

Both must print nothing. The full predicate set is in
[`../../.claude/rules/30-zk-logging.md`](../../.claude/rules/30-zk-logging.md).

After running the stack, the spot check is:

```sh
grep -iE 'ciphertext|BEGIN|eyJ' <logs>   # must return zero hits
```

`eyJ` catches a base64-encoded JWT header — the most common accidental token leak.

## Stack

| Signal | Collector | Store | View |
|---|---|---|---|
| Traces | OpenTelemetry Collector | Tempo | Grafana |
| Logs | Promtail | Loki | Grafana |
| Metrics | Prometheus | Prometheus | Grafana |

Manifests live in `infra/k8s/base/observability/` (otel-collector, Tempo, Grafana
dashboards for messaging, logs and tracing) and `infra/k8s/base/monitoring/` (Loki,
Promtail, alerting rules). The prod overlay adds service monitors, SLO rules and
alertmanager configuration.

## Known observability gaps

| Gap | Consequence | Owned by |
|---|---|---|
| `call-service` and `notification-service` build a `FmtSubscriber` directly | two services log outside the redaction layer | PR-26 |
| `common/src/rate_limit.rs:241,256` log a raw client IP | PII in logs — a direct I-1 breach | **unowned** |
| The Compose observability stack is commented out, and references `./infra/observability/prometheus.yml` which does not exist | no local metrics; uncommenting it fails | PR-43 |
| `GUARDYN_OBSERVABILITY__OTLP_ENDPOINT` is `""` for every Compose service | no traces are exported locally | PR-43 |
| `Sampler::AlwaysOn` (`observability.rs:132`) | 100% trace sampling — fine in development, a cost and volume decision in production | PR-43 |
