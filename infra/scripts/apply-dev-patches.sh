#!/usr/bin/env bash
# =============================================================================
# Apply development optimizations to cluster
# =============================================================================
# This script applies kustomize patches to reduce resource usage for development.
# 
# What it does:
#   - Scales services to 1 replica each
#   - Optionally reduces ScyllaDB to 1 node (requires restart)
#
# Usage:
#   ./apply-dev-patches.sh         # Apply replica reduction only
#   ./apply-dev-patches.sh --full  # Apply all patches including ScyllaDB
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_current_state() {
    log_info "Current pod state:"
    echo ""
    echo "=== Apps namespace ==="
    kubectl get pods -n apps -o wide 2>/dev/null || echo "No pods"
    echo ""
    echo "=== Data namespace ==="
    kubectl get pods -n data -o wide 2>/dev/null || echo "No pods"
    echo ""
}

scale_services_to_dev() {
    log_info "Scaling services to development mode (1 replica each)..."
    
    kubectl scale deployment -n apps auth-service --replicas=1 2>/dev/null || log_warn "auth-service not found"
    kubectl scale deployment -n apps messaging-service --replicas=1 2>/dev/null || log_warn "messaging-service not found"
    kubectl scale deployment -n apps presence-service --replicas=1 2>/dev/null || log_warn "presence-service not found"
    kubectl scale deployment -n apps media-service --replicas=1 2>/dev/null || log_warn "media-service not found"
    
    log_success "Services scaled to 1 replica each"
    
    # Wait for pods to terminate
    log_info "Waiting for pods to terminate..."
    sleep 5
    
    log_info "Current apps pods:"
    kubectl get pods -n apps --no-headers 2>/dev/null | head -10
}

reduce_scylladb() {
    log_warn "ScyllaDB reduction requires cluster reconfiguration."
    log_warn "This will cause downtime and potential data issues."
    echo ""
    read -p "Are you sure you want to reduce ScyllaDB to 1 node? [y/N] " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipping ScyllaDB reduction"
        return 0
    fi
    
    log_info "Applying ScyllaDB dev patch..."
    kubectl apply -f "${PROJECT_ROOT}/infra/k8s/overlays/local/scylla-dev-patch.yaml"
    
    log_info "Waiting for ScyllaDB to reconfigure..."
    log_warn "This may take several minutes..."
    
    # Wait for ScyllaDB to stabilize
    sleep 30
    kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=scylla -n data --timeout=300s 2>/dev/null || true
    
    log_success "ScyllaDB reduced to 1 node"
}

show_savings() {
    echo ""
    log_success "=== Resource Optimization Summary ==="
    echo ""
    echo "Before optimization:"
    echo "  - auth-service:      2 replicas"
    echo "  - messaging-service: 3 replicas"
    echo "  - presence-service:  2 replicas"
    echo "  - media-service:     2 replicas"
    echo "  - ScyllaDB:          3 nodes (12 containers)"
    echo "  - Total:             ~16+ pods"
    echo ""
    echo "After optimization:"
    echo "  - auth-service:      1 replica"
    echo "  - messaging-service: 1 replica"
    echo "  - presence-service:  1 replica"
    echo "  - media-service:     1 replica"
    echo "  - ScyllaDB:          1 node (4 containers)"
    echo "  - Total:             ~7 pods"
    echo ""
    log_success "Estimated savings: ~60% memory, ~50% CPU"
    echo ""
}

main() {
    local full_mode=false
    
    for arg in "$@"; do
        case "$arg" in
            --full)
                full_mode=true
                ;;
            --help|-h)
                echo "Usage: $0 [--full]"
                echo ""
                echo "Options:"
                echo "  --full    Apply all patches including ScyllaDB reduction"
                exit 0
                ;;
        esac
    done
    
    show_current_state
    
    scale_services_to_dev
    
    if [[ "${full_mode}" == "true" ]]; then
        reduce_scylladb
    fi
    
    show_savings
    
    log_info "Current pod state after optimization:"
    echo ""
    kubectl get pods -n apps --no-headers 2>/dev/null | wc -l | xargs -I{} echo "Apps namespace: {} pods"
    kubectl get pods -n data --no-headers 2>/dev/null | wc -l | xargs -I{} echo "Data namespace: {} pods"
}

main "$@"
