#!/usr/bin/env bash
set -euo pipefail

# Fix Guardyn cluster issues after computer restart
# Addresses:
# 1. Missing TLS secrets in apps namespace
# 2. ScyllaDB AIO limits
# 3. Pending PVCs
# 4. Failed pods

echo "🔧 Fixing Guardyn cluster after restart..."

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
log_info() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# 1. Fix AIO limits for ScyllaDB
echo ""
echo "📊 Step 1: Checking AIO limits..."
CURRENT_AIO=$(cat /proc/sys/fs/aio-max-nr)
REQUIRED_AIO=1048576

if [ "$CURRENT_AIO" -lt "$REQUIRED_AIO" ]; then
    log_warn "Current AIO limit ($CURRENT_AIO) is below required ($REQUIRED_AIO)"
    echo "  Increasing to $REQUIRED_AIO..."
    sudo sysctl -w fs.aio-max-nr=$REQUIRED_AIO
    log_info "AIO limit increased to $REQUIRED_AIO"

    # Make it persistent
    if ! grep -q "fs.aio-max-nr" /etc/sysctl.conf 2>/dev/null; then
        echo "fs.aio-max-nr = $REQUIRED_AIO" | sudo tee -a /etc/sysctl.conf > /dev/null
        log_info "AIO limit made persistent in /etc/sysctl.conf"
    fi
else
    log_info "AIO limit is sufficient ($CURRENT_AIO >= $REQUIRED_AIO)"
fi

# 2. Copy TLS secret to apps namespace
echo ""
echo "🔐 Step 2: Fixing TLS secrets..."
if kubectl get secret guardyn-backend-tls -n cert-manager >/dev/null 2>&1; then
    if ! kubectl get secret guardyn-backend-tls -n apps >/dev/null 2>&1; then
        log_warn "TLS secret missing in apps namespace, copying from cert-manager..."
        kubectl get secret guardyn-backend-tls -n cert-manager -o yaml | \
            sed 's/namespace: cert-manager/namespace: apps/' | \
            kubectl apply -f -
        log_info "TLS secret copied to apps namespace"
    else
        log_info "TLS secret already exists in apps namespace"
    fi
else
    log_error "TLS secret not found in cert-manager namespace!"
    echo "  Run: kubectl apply -f infra/k8s/base/cert-manager/"
    exit 1
fi

# 3. Delete and recreate failed ScyllaDB pods
echo ""
echo "🗄️ Step 3: Fixing ScyllaDB cluster..."
FAILED_SCYLLA_PODS=$(kubectl get pods -n data -l app.kubernetes.io/name=scylla -o jsonpath='{.items[?(@.status.containerStatuses[*].state.waiting.reason=="CrashLoopBackOff")].metadata.name}')

if [ -n "$FAILED_SCYLLA_PODS" ]; then
    log_warn "Found ScyllaDB pods in CrashLoopBackOff: $FAILED_SCYLLA_PODS"
    for pod in $FAILED_SCYLLA_PODS; do
        echo "  Deleting pod $pod..."
        kubectl delete pod "$pod" -n data --grace-period=0 --force || true
    done
    log_info "ScyllaDB pods deleted, they will be recreated"

    echo "  Waiting 30 seconds for pods to restart..."
    sleep 30
else
    log_info "No ScyllaDB pods in CrashLoopBackOff"
fi

# 4. Delete pending PVCs and recreate
echo ""
echo "💾 Step 4: Fixing pending PVCs..."
PENDING_PVCS=$(kubectl get pvc -n apps -o jsonpath='{.items[?(@.status.phase=="Pending")].metadata.name}')

if [ -n "$PENDING_PVCS" ]; then
    log_warn "Found pending PVCs: $PENDING_PVCS"
    for pvc in $PENDING_PVCS; do
        # Get the PVC definition before deleting
        kubectl get pvc "$pvc" -n apps -o yaml > "/tmp/${pvc}.yaml"

        echo "  Deleting PVC $pvc..."
        kubectl delete pvc "$pvc" -n apps

        echo "  Recreating PVC $pvc..."
        kubectl apply -f "/tmp/${pvc}.yaml"
        rm "/tmp/${pvc}.yaml"
    done
    log_info "PVCs recreated"
else
    log_info "No pending PVCs found"
fi

# 5. Restart failed pods in apps namespace
echo ""
echo "🔄 Step 5: Restarting failed application pods..."
FAILED_APPS=$(kubectl get pods -n apps -o jsonpath='{.items[?(@.status.phase!="Running")].metadata.name}')

if [ -n "$FAILED_APPS" ]; then
    log_warn "Found failed application pods, deleting them..."
    for pod in $FAILED_APPS; do
        echo "  Deleting pod $pod..."
        kubectl delete pod "$pod" -n apps --grace-period=30 || true
    done
    log_info "Failed pods deleted, they will be recreated by their controllers"
else
    log_info "No failed application pods found"
fi

# 6. Wait for pods to become ready
echo ""
echo "⏳ Step 6: Waiting for pods to become ready..."
echo "  This may take 2-3 minutes..."

# Wait for ScyllaDB
echo "  Waiting for ScyllaDB cluster (max 3 minutes)..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=scylla -n data --timeout=180s || log_warn "ScyllaDB pods not ready yet"

# Wait for apps
echo "  Waiting for application pods (max 3 minutes)..."
kubectl wait --for=condition=ready pod -l guardyn.io/stage=poc -n apps --timeout=180s || log_warn "Some application pods not ready yet"

# 7. Verify cluster health
echo ""
echo "🏥 Step 7: Verifying cluster health..."

echo ""
echo "Data namespace pods:"
kubectl get pods -n data -o wide

echo ""
echo "Apps namespace pods:"
kubectl get pods -n apps -o wide

echo ""
echo "PVCs in apps namespace:"
kubectl get pvc -n apps

# Check ScyllaDB cluster status
echo ""
echo "📊 ScyllaDB cluster status:"
SCYLLA_POD=$(kubectl get pods -n data -l app.kubernetes.io/name=scylla -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$SCYLLA_POD" ]; then
    kubectl exec -n data "$SCYLLA_POD" -c scylla -- nodetool status || log_warn "Could not get ScyllaDB status"
else
    log_warn "No ScyllaDB pods found"
fi

echo ""
echo "✅ Cluster fix completed!"
echo ""
echo "📝 Next steps:"
echo "  1. Check pod status: kubectl get pods -A"
echo "  2. Check logs if issues persist: kubectl logs -n apps <pod-name>"
echo "  3. If ScyllaDB still failing, consider reducing replica count"
echo "  4. If messaging service fails, check ScyllaDB is healthy first"
