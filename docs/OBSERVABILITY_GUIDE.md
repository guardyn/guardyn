# Guardyn Observability Guide

Complete observability stack for Guardyn MVP: Prometheus, Loki, Tempo, Grafana.

## 🎯 Overview

Guardyn uses a modern observability stack:

- **Prometheus**: Metrics collection and alerting
- **Loki**: Log aggregation and querying
- **Tempo**: Distributed tracing
- **Grafana**: Visualization and dashboards

All backend services are instrumented with OpenTelemetry via the shared `guardyn-common` crate.

## 📊 Access Dashboards

### Grafana UI

**Port-forward Grafana**:

```bash
kubectl port-forward -n observability svc/kube-prometheus-stack-grafana 3000:80
```

**Access**: http://localhost:3000

**Default Credentials**:

- Username: `admin`
- Password: `prom-operator` (check with: `kubectl get secret -n observability kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d`)

### Prometheus UI

```bash
kubectl port-forward -n observability svc/prometheus-kube-prometheus-stack-prometheus 9090:9090
```

**Access**: http://localhost:9090

## 🔍 Structured Logging

All Guardyn services use **JSON structured logging** via `tracing-subscriber`.

### Log Format

```json
{
  "timestamp": "2025-11-10T14:07:11.813341Z",
  "level": "INFO",
  "fields": {
    "message": "Connected to TiKV and ScyllaDB"
  },
  "target": "guardyn_messaging_service"
}
```

### Query Logs with kubectl

**Messaging Service**:

```bash
kubectl logs -n apps -l app=messaging-service --tail=100
```

**Auth Service**:

```bash
kubectl logs -n apps -l app=auth-service --tail=100
```

**Filter by level**:

```bash
kubectl logs -n apps -l app=messaging-service | jq 'select(.level == "ERROR")'
```

### Query Logs with Loki (via Grafana)

1. Open Grafana → Explore
2. Select **Loki** data source
3. Run LogQL queries:

```logql
# All messaging service logs
{namespace="apps", app="messaging-service"}

# Only errors
{namespace="apps", app="messaging-service"} |~ "ERROR"

# Message operations
{namespace="apps", app="messaging-service"} |~ "SendMessage|GetMessages"

# Filter by time range and show JSON fields
{namespace="apps", app="messaging-service"} | json | line_format "{{.level}} - {{.message}}"
```

## 🔗 Distributed Tracing (Tempo)

All services send traces to Grafana Tempo via OpenTelemetry (OTLP).

### Access Tempo

```bash
kubectl port-forward -n observability svc/tempo 3200:3200
```

### Query Traces (via Grafana)

1. Open Grafana → Explore
2. Select **Tempo** data source
3. Run TraceQL queries:

```traceql
# All traces
{}

# Traces from specific service
{resource.service.name="auth-service"}

# Traces with errors
{status=error}

# Traces longer than 100ms
{duration>100ms}
```

### Service Instrumentation

Services use `guardyn-common::observability::init_tracing()`:

```rust
// In main.rs
let otlp_endpoint = std::env::var("OTEL_EXPORTER_OTLP_ENDPOINT").ok();
let _guard = observability::init_tracing("service-name", "info", otlp_endpoint.as_deref());
```

The `_guard` ensures traces are flushed on shutdown.

### Environment Variable

```bash
OTEL_EXPORTER_OTLP_ENDPOINT=http://tempo.observability.svc.cluster.local:4317
# or via OTel Collector:
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector-opentelemetry-collector.observability.svc.cluster.local:4317
```

## 📈 Prometheus Metrics

### Available Metrics

**Kubernetes Metrics** (automatically collected):

- `kube_pod_status_phase` - Pod running status
- `kube_pod_container_status_restarts_total` - Pod restarts
- `container_cpu_usage_seconds_total` - CPU usage
- `container_memory_working_set_bytes` - Memory usage
- `container_network_receive_bytes_total` - Network RX
- `container_network_transmit_bytes_total` - Network TX

**Envoy Proxy Metrics** (automatically exposed on port 9901):

- `envoy_http_downstream_rq_total` - Total HTTP requests received
- `envoy_http_downstream_rq_xx` - Requests by status code (2xx, 4xx, 5xx)
- `envoy_cluster_upstream_rq_total` - Requests forwarded to backend
- `envoy_cluster_upstream_rq_time` - Backend response time histogram
- `envoy_listener_downstream_cx_active` - Active connections

**Query Envoy metrics**:

```bash
# Port-forward to Envoy admin interface
kubectl port-forward -n apps svc/guardyn-envoy 9901:9901

# Access metrics
curl http://localhost:9901/stats/prometheus
```

**Example Queries**:

```promql
# Messaging service CPU usage
rate(container_cpu_usage_seconds_total{namespace="apps", pod=~"messaging-service.*"}[5m])

# Messaging service memory
container_memory_working_set_bytes{namespace="apps", pod=~"messaging-service.*"}

# Running pods
kube_pod_status_phase{namespace="apps", pod=~"messaging-service.*", phase="Running"}

# Envoy: Requests per second
rate(envoy_http_downstream_rq_total{namespace="apps", pod=~"guardyn-envoy.*"}[5m])

# Envoy: Request latency (P95)
histogram_quantile(0.95, rate(envoy_cluster_upstream_rq_time_bucket{namespace="apps"}[5m]))

# Envoy: Error rate (5xx responses)
rate(envoy_http_downstream_rq_5xx{namespace="apps", pod=~"guardyn-envoy.*"}[5m])
```

### Future: Application Metrics

To add custom application metrics (TODO):

1. Add `prometheus` crate to `Cargo.toml`
2. Instrument handlers with counters/histograms
3. Expose `/metrics` endpoint
4. Create ServiceMonitor for scraping

Example:

```rust
use prometheus::{Counter, Histogram, Registry};

lazy_static! {
    static ref MESSAGES_SENT: Counter = Counter::new("messages_sent_total", "Total messages sent").unwrap();
    static ref MESSAGE_LATENCY: Histogram = Histogram::new("message_send_latency_seconds", "Message send latency").unwrap();
}
```

## 📊 Grafana Dashboards

### Messaging Service Dashboard

**Import Dashboard**:

```bash
# Apply ConfigMap
kubectl apply -f infra/k8s/base/observability/grafana-dashboard-configmap.yaml

# Restart Grafana to pick up new dashboard
kubectl rollout restart deployment/kube-prometheus-stack-grafana -n observability
```

**Dashboard Panels**:

1. **Pod Status** - Running replicas count
2. **CPU Usage** - Per-pod CPU consumption
3. **Memory Usage** - Per-pod memory usage
4. **Log Levels** - Real-time logs with filtering
5. **Error Rate** - Errors per second (with alert)
6. **Message Operations** - SendMessage, GetMessages, etc.
7. **Network I/O** - RX/TX bytes per second
8. **Pod Restarts** - Restart count over time
9. **ScyllaDB Connection** - Database connection logs
10. **TiKV Connection** - TiKV connection logs

### Create Custom Dashboard

1. Open Grafana → Dashboards → New Dashboard
2. Add Panel → Choose visualization type
3. Select data source (Prometheus or Loki)
4. Write query (PromQL or LogQL)
5. Save dashboard

**Example Panel (Error Count)**:

```json
{
  "targets": [
    {
      "expr": "sum(rate({namespace=\"apps\", app=\"messaging-service\"} |~ \"ERROR\" [5m]))",
      "legendFormat": "Errors/s"
    }
  ],
  "type": "graph"
}
```

## 🚨 Alerting

### Current Alerts

**Pre-configured by kube-prometheus-stack**:

- Pod restarts
- High CPU/memory usage
- Node failures

### Custom Alerts (TODO)

Create PrometheusRule for custom alerts:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: guardyn-alerts
  namespace: observability
spec:
  groups:
    - name: messaging-service
      rules:
        - alert: HighErrorRate
          expr: sum(rate({namespace="apps", app="messaging-service"} |~ "ERROR" [5m])) > 5
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "High error rate in messaging service"
```

## 🔧 Troubleshooting

### Logs Not Showing in Loki

**Check Loki pods**:

```bash
kubectl get pods -n observability | grep loki
```

**Verify log forwarding**:

```bash
kubectl logs -n observability -l app.kubernetes.io/name=promtail
```

### Metrics Not Appearing

**Check Prometheus targets**:

1. Port-forward Prometheus UI
2. Go to Status → Targets
3. Verify `serviceMonitor/apps/*` targets are UP

**Check ServiceMonitor**:

```bash
kubectl get servicemonitor -n apps
```

### Grafana Dashboard Not Loading

**Verify ConfigMap**:

```bash
kubectl get cm -n observability grafana-dashboard-messaging
```

**Check Grafana logs**:

```bash
kubectl logs -n observability -l app.kubernetes.io/name=grafana
```

**Restart Grafana**:

```bash
kubectl rollout restart deployment/kube-prometheus-stack-grafana -n observability
```

## 📚 References

- [Prometheus Query Language](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [LogQL Log Query Language](https://grafana.com/docs/loki/latest/logql/)
- [Grafana Dashboards](https://grafana.com/docs/grafana/latest/dashboards/)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

## ✅ Observability Checklist

Current status:

- [x] JSON structured logging configured
- [x] Loki log aggregation deployed
- [x] Prometheus metrics collection deployed
- [x] Grafana dashboards deployed
- [x] Basic dashboard for messaging service created
- [ ] Custom application metrics (TODO)
- [ ] ServiceMonitor for custom metrics (TODO)
- [ ] Custom alerting rules (TODO)
- [ ] Distributed tracing with Tempo (TODO)
