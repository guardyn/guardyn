default:
    @echo "Run 'just --list' to view available tasks."

kube-create:
    @echo "[kube:create] Creating k3d cluster using infra/k3d-config.yaml"
    k3d cluster create --config infra/k3d-config.yaml

kube-delete:
    @echo "[kube:delete] Deleting k3d cluster guardyn-poc"
    k3d cluster delete guardyn-poc || true

kube-bootstrap:
    @echo "[kube:bootstrap] Installing core components"
    bash infra/scripts/bootstrap.sh

k8s-deploy service:
    bash infra/scripts/deploy.sh "{{service}}"

verify-kube:
    @echo "[verify:kube] Running smoke checks"
    bash infra/scripts/verify.sh

teardown:
    @echo "[teardown] Destroying cluster and cleaning up"
    just kube-delete

# Port-forwarding with auto-restart watchdog
port-forward:
    @echo "[port-forward] Starting port-forward watchdog (Ctrl+C to stop)"
    bash infra/scripts/port-forward-watchdog.sh

# Port-forwarding without Envoy (for native apps only)
port-forward-native:
    @echo "[port-forward] Starting port-forward watchdog for native apps"
    bash infra/scripts/port-forward-watchdog.sh --no-envoy --no-chromedriver

# Port-forwarding status check
port-forward-status:
    bash infra/scripts/port-forward-watchdog.sh --status

# Stop all port-forwards
port-forward-stop:
    bash infra/scripts/port-forward-watchdog.sh --stop

# Run two-user chat E2E test
test-chat:
    @echo "[test] Running two-user chat E2E test"
    bash backend/crates/e2e-tests/scripts/test-two-user-chat.sh

# Run all messaging E2E tests
test-messaging:
    @echo "[test] Running all messaging E2E tests"
    bash backend/crates/e2e-tests/scripts/test-two-user-chat.sh --all

# =============================================================================
# User Management Commands
# =============================================================================

# List all registered users
list-users:
    @echo "[users] Listing registered users..."
    bash infra/scripts/user-management.sh list

# Delete a specific user and all their data
delete-user username:
    @echo "[users] Deleting user: {{username}}"
    bash infra/scripts/user-management.sh delete "{{username}}"

# Delete ALL users and data (DANGEROUS!)
delete-all-users:
    @echo "[users] ⚠️  Deleting ALL user data..."
    bash infra/scripts/user-management.sh delete-all

# =============================================================================
# Local Development Commands (Fast Rebuild)
# =============================================================================
# These commands run services locally with port-forwards to cluster databases.
# Benefits: ~5-10 sec rebuild (vs ~60+ sec with Docker), hot-reload, direct debug

# Start port-forwards to cluster databases only
dev-ports:
    @echo "[dev] Starting port-forwards to databases..."
    bash infra/scripts/dev-local.sh ports-only

# Stop all port-forwards
dev-stop:
    @echo "[dev] Stopping all port-forwards..."
    bash infra/scripts/dev-local.sh stop

# Check port-forward status
dev-status:
    @echo "[dev] Checking port-forward status..."
    bash infra/scripts/dev-local.sh status

# Run auth-service locally (with port-forwards)
dev-auth:
    @echo "[dev] Starting auth-service locally..."
    bash infra/scripts/dev-local.sh auth

# Run messaging-service locally (with port-forwards)
dev-messaging:
    @echo "[dev] Starting messaging-service locally..."
    bash infra/scripts/dev-local.sh messaging

# Run presence-service locally (with port-forwards)
dev-presence:
    @echo "[dev] Starting presence-service locally..."
    bash infra/scripts/dev-local.sh presence

# Run media-service locally (with port-forwards)
dev-media:
    @echo "[dev] Starting media-service locally..."
    bash infra/scripts/dev-local.sh media

# Run all services locally in tmux
dev-all:
    @echo "[dev] Starting all services in tmux..."
    bash infra/scripts/dev-local.sh all

# Stop all services (tmux session + port-forwards)
dev-kill:
    @echo "[dev] Stopping all services and port-forwards..."
    tmux kill-session -t guardyn-dev 2>/dev/null || true
    bash infra/scripts/dev-local.sh stop

# Run a service with hot-reload (requires cargo-watch)
dev-watch service:
    @echo "[dev] Starting {{service}} with hot-reload..."
    cd backend && cargo watch -x "run --bin {{service}}"

# =============================================================================
# Resource Optimization Commands
# =============================================================================

# Scale down services for development (saves ~9 pods)
scale-dev:
    @echo "[scale] Scaling services to dev mode (1 replica each)..."
    kubectl scale deployment -n apps auth-service --replicas=1
    kubectl scale deployment -n apps messaging-service --replicas=1
    kubectl scale deployment -n apps presence-service --replicas=1
    kubectl scale deployment -n apps media-service --replicas=1
    @echo "[scale] Done. Pods reduced from ~10 to ~4 in apps namespace."

# Scale up services for testing (original replicas)
scale-prod:
    @echo "[scale] Scaling services to prod mode..."
    kubectl scale deployment -n apps auth-service --replicas=2
    kubectl scale deployment -n apps messaging-service --replicas=3
    kubectl scale deployment -n apps presence-service --replicas=2
    kubectl scale deployment -n apps media-service --replicas=2
    @echo "[scale] Done. Services scaled to production replicas."

# Show current resource usage
resources:
    @echo "[resources] Current pod resource usage:"
    @echo "=== Apps namespace ==="
    kubectl top pods -n apps 2>/dev/null || echo "Metrics not available (install metrics-server)"
    @echo ""
    @echo "=== Data namespace ==="
    kubectl top pods -n data 2>/dev/null || echo "Metrics not available"
    @echo ""
    @echo "=== Pod counts ==="
    @echo "Apps: $(kubectl get pods -n apps --no-headers 2>/dev/null | wc -l) pods"
    @echo "Data: $(kubectl get pods -n data --no-headers 2>/dev/null | wc -l) pods"

