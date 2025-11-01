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
  foundationdb)
    echo "Deploying FoundationDB operator..."
    kubectl apply -f https://raw.githubusercontent.com/FoundationDB/fdb-kubernetes-operator/v1.49.0/config/crd/bases/apps.foundationdb.org_foundationdbclusters.yaml
    kubectl apply -f https://raw.githubusercontent.com/FoundationDB/fdb-kubernetes-operator/v1.49.0/config/crd/bases/apps.foundationdb.org_foundationdbbackups.yaml
    kubectl apply -f https://raw.githubusercontent.com/FoundationDB/fdb-kubernetes-operator/v1.49.0/config/crd/bases/apps.foundationdb.org_foundationdbrestores.yaml
    kubectl apply -f https://raw.githubusercontent.com/FoundationDB/fdb-kubernetes-operator/v1.49.0/config/samples/deployment.yaml -n data
    echo "FoundationDB operator deployed. Create cluster with custom resources."
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
    ;;
  *)
    echo "Unsupported service '${SERVICE}'" >&2
    exit 1
    ;;
 esac
