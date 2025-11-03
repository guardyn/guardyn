#!/usr/bin/env bash
# Deploy database schemas to running FoundationDB and ScyllaDB clusters

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

echo "=== Guardyn Database Schema Deployment ==="
echo ""

# Check if clusters are running
echo "Checking cluster status..."

# Check FoundationDB
if ! kubectl get pods -n data -l app=guardyn-fdb | grep -q Running; then
  echo "❌ FoundationDB cluster not running. Deploy it first with: just k8s-deploy foundationdb"
  exit 1
fi

# Check ScyllaDB
if ! kubectl get pods -n data -l app.kubernetes.io/name=scylla | grep -q Running; then
  echo "❌ ScyllaDB cluster not running. Deploy it first with: just k8s-deploy scylladb"
  exit 1
fi

echo "✅ Both database clusters are running"
echo ""

# Deploy FoundationDB schema
echo "=== Deploying FoundationDB Schema ==="
FDB_POD=$(kubectl get pods -n data -l app=guardyn-fdb -o jsonpath='{.items[0].metadata.name}')

echo "Copying initialization script to pod ${FDB_POD}..."
kubectl cp "${SCRIPT_DIR}/fdb-init.sh" "data/${FDB_POD}:/tmp/fdb-init.sh"

echo "Running FoundationDB initialization..."
kubectl exec -n data "${FDB_POD}" -- bash /tmp/fdb-init.sh

echo "✅ FoundationDB schema initialized"
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

echo "FoundationDB cluster status:"
kubectl exec -n data "${FDB_POD}" -- fdbcli --exec "status minimal"
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
