#!/usr/bin/env bash
set -euo pipefail
SERVICE="${1:-}"
if [[ -z "${SERVICE}" ]]; then
  echo "Usage: $0 <service>" >&2
  exit 1
fi
case "${SERVICE}" in
  nats)
    helm repo add nats https://nats-io.github.io/k8s/helm/charts >/dev/null
    helm repo update >/dev/null
    helm upgrade --install nats nats/nats \
      --namespace messaging \
      --create-namespace \
      --values infra/k8s/base/nats/values.yaml
    ;;
  tikv)
    echo "Deploying TiKV cluster..."
    kubectl apply -k infra/k8s/base/tikv
    echo "TiKV cluster deployed (PD + storage nodes)."
    ;;
  scylladb)
    kubectl create namespace scylla-operator --dry-run=client -o yaml | kubectl apply -f -
    helm repo add scylla https://scylla-operator-charts.storage.googleapis.com/stable >/dev/null
    helm repo update >/dev/null
    helm upgrade --install scylla-operator scylla/scylla-operator \
      --namespace scylla-operator \
      --values infra/k8s/base/scylladb/values.yaml
    ;;
  monitoring)
    helm repo add grafana https://grafana.github.io/helm-charts >/dev/null
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
    helm repo update >/dev/null
    helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
      --namespace observability \
      --create-namespace \
      --values infra/k8s/base/monitoring/values.yaml
    helm upgrade --install grafana-loki grafana/loki-distributed \
      --namespace observability \
      --values infra/k8s/base/monitoring/loki-values.yaml
    # Deploy Promtail for log collection
    echo "Deploying Promtail log collector..."
    helm upgrade --install promtail grafana/promtail \
      --namespace observability \
      --values infra/k8s/base/monitoring/promtail-values.yaml
    # Apply Guardyn-specific alerting rules
    echo "Applying Guardyn alerting rules..."
    kubectl apply -f infra/k8s/base/monitoring/alerting-rules.yaml
    # Apply Grafana dashboards
    echo "Applying Guardyn Grafana dashboards..."
    kubectl apply -f infra/k8s/base/observability/grafana-dashboard-logs-configmap.yaml
    echo "Logging stack deployed:"
    echo "  - Loki: Log storage with 7-day retention"
    echo "  - Promtail: Log collection from all namespaces"
    echo "  - Grafana dashboard: guardyn-logs"
    echo "Check with: kubectl get pods -n observability -l app.kubernetes.io/name=promtail"
    ;;
  tracing)
    echo "Deploying distributed tracing stack (Tempo + OpenTelemetry Collector)..."
    helm repo add grafana https://grafana.github.io/helm-charts >/dev/null
    helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts >/dev/null
    helm repo update >/dev/null
    # Deploy Tempo for trace storage
    helm upgrade --install tempo grafana/tempo \
      --namespace observability \
      --create-namespace \
      --values infra/k8s/base/observability/tempo-values.yaml
    # Deploy OpenTelemetry Collector
    helm upgrade --install otel-collector open-telemetry/opentelemetry-collector \
      --namespace observability \
      --values infra/k8s/base/observability/otel-collector-values.yaml
    echo "Tracing stack deployed. Services can send traces to:"
    echo "  - otel-collector.observability.svc.cluster.local:4317 (OTLP gRPC)"
    echo "  - tempo.observability.svc.cluster.local:4317 (OTLP gRPC direct)"
    ;;
  *)
    echo "Unsupported service '${SERVICE}'" >&2
    exit 1
    ;;
 esac
