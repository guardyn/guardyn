#!/usr/bin/env bash
# Deploy database schemas to running TiKV and ScyllaDB clusters

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

echo "=== Guardyn Database Schema Deployment ==="
echo ""

# Check if clusters are running
echo "Checking cluster status..."

# Check TiKV
if ! kubectl get pods -n data -l app=pd | grep -q Running; then
  echo "❌ TiKV cluster not running. Deploy it first with: just k8s-deploy tikv"
  exit 1
fi

# Check ScyllaDB
if ! kubectl get pods -n data -l app.kubernetes.io/name=scylla | grep -q Running; then
  echo "❌ ScyllaDB cluster not running. Deploy it first with: just k8s-deploy scylladb"
  exit 1
fi

echo "✅ Both database clusters are running"
echo ""

# Verify TiKV cluster health
echo "=== Verifying TiKV Cluster ==="
PD_POD=$(kubectl get pods -n data -l app=pd -o jsonpath='{.items[0].metadata.name}')

echo "Checking TiKV cluster status..."
kubectl exec -n data "${PD_POD}" -- /pd-ctl -u http://localhost:2379 store

echo "✅ TiKV cluster is healthy"
echo "Note: TiKV schema is managed by application code (key-value patterns)"
echo ""

# Deploy ScyllaDB schema
echo "=== Deploying ScyllaDB Schema ==="
SCYLLA_POD=$(kubectl get pods -n data -l app.kubernetes.io/name=scylla -o jsonpath='{.items[0].metadata.name}')

echo "Copying schema script to pod ${SCYLLA_POD}..."
kubectl cp "${SCRIPT_DIR}/scylla-init.cql" "data/${SCYLLA_POD}:/tmp/scylla-init.cql"

echo "Running ScyllaDB schema creation..."
kubectl exec -n data "${SCYLLA_POD}" -- cqlsh -f /tmp/scylla-init.cql

echo "✅ ScyllaDB schema created"
echo ""

# Verify schemas
echo "=== Verification ==="

echo "TiKV cluster status:"
kubectl exec -n data "${PD_POD}" -- /pd-ctl -u http://localhost:2379 store
echo ""

echo "ScyllaDB keyspace information:"
kubectl exec -n data "${SCYLLA_POD}" -- cqlsh -e "DESCRIBE KEYSPACE guardyn;"
echo ""

echo "✅ All database schemas deployed successfully!"
echo ""
echo "Next steps:"
echo "  1. Deploy backend services: just k8s-deploy apps"
echo "  2. Check service logs: kubectl logs -n apps -l app=auth-service"
echo "  3. Access Grafana: kubectl port-forward -n observability svc/grafana 3000:3000"
