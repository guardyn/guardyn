#!/usr/bin/env bash
set -euo pipefail
kubectl apply -k infra/k8s/base/namespaces
kubectl apply -k infra/k8s/base/cert-manager
kubectl apply -k infra/k8s/base/cilium
kubectl apply -k infra/k8s/base/foundationdb
kubectl apply -k infra/k8s/base/scylladb
kubectl apply -k infra/k8s/base/monitoring
