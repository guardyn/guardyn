#!/bin/bash

# Verify TiKV cluster health

set -e

echo "🔍 Checking TiKV cluster health..."
echo ""

# Check PD pod
echo "1. Checking PD (Placement Driver)..."
kubectl get pods -n data -l app=pd
echo ""

# Check TiKV pods
echo "2. Checking TiKV storage nodes..."
kubectl get pods -n data -l app=tikv
echo ""

# Check PD cluster info
echo "3. PD Cluster Information..."
kubectl exec -n data pd-0 -- /pd-ctl -u http://localhost:2379 cluster
echo ""

# Check registered stores
echo "4. Registered TiKV Stores..."
kubectl exec -n data pd-0 -- /pd-ctl -u http://localhost:2379 store
echo ""

echo "✅ TiKV cluster health check complete!"
