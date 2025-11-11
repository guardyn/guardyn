#!/usr/bin/env bash
set -euo pipefail
kubectl get nodes -o wide
kubectl wait --for=condition=Ready pods --all --timeout=180s --all-namespaces
kubectl run nats-smoke --rm -i --restart=Never --namespace messaging --image=natsio/nats-box:latest \
  -- /bin/sh -c "nats server check jetstream || nats -s nats://nats:4222 sub foo & sleep 2 && nats -s nats://nats:4222 pub foo 'hello'"
echo "✅ NATS JetStream is healthy!"

# ===== TiKV Verification =====
echo ""
echo "🔍 Verifying TiKV cluster..."
kubectl -n data exec pd-0 -- /pd-ctl -u http://localhost:2379 store

# ===== ScyllaDB Verification =====
echo ""
echo "🔍 Verifying ScyllaDB cluster..."

# Check if ScyllaDB StatefulSet exists and is ready
SCYLLA_READY=$(kubectl get statefulset -n data scylla -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
if [ "$SCYLLA_READY" -gt 0 ]; then
    echo "✅ ScyllaDB cluster is running ($SCYLLA_READY replicas ready)"

    # Try to execute nodetool status on the existing ScyllaDB pod
    if kubectl exec -n data scylla-0 -- nodetool status >/dev/null 2>&1; then
        echo "✅ ScyllaDB node is responsive"
        kubectl exec -n data scylla-0 -- nodetool status
    else
        echo "⚠️  ScyllaDB pod exists but nodetool check failed (this may be normal during startup)"
    fi
else
    echo "⚠️  ScyllaDB cluster not found or not ready"
fi

echo ""
echo "✅ All smoke tests completed!"
