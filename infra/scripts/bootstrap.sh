#!/usr/bin/env bash
set -euo pipefail

echo "Creating namespaces..."
kubectl apply -k infra/k8s/base/namespaces

echo "Installing cert-manager..."
kubectl apply -k infra/k8s/base/cert-manager

echo "Waiting for cert-manager to be ready..."
kubectl wait --for=condition=Available --timeout=300s deployment/cert-manager -n cert-manager
kubectl wait --for=condition=Available --timeout=300s deployment/cert-manager-webhook -n cert-manager
kubectl wait --for=condition=Available --timeout=300s deployment/cert-manager-cainjector -n cert-manager

echo "Bootstrap complete! K3s built-in CNI is already active."
echo "Use 'just k8s-deploy <service>' to deploy services."
