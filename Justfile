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

# Stop local Envoy
dev-envoy-stop:
    @echo "[dev] Stopping local Envoy..."
    docker stop envoy-local 2>/dev/null || true

# Run Envoy port-forward from k8s (for testing with cluster services)
dev-envoy-k8s:
    @echo "[dev] Starting Envoy port-forward from k8s on :18080..."
    kubectl port-forward -n apps svc/guardyn-envoy 18080:8080

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

# Scale down ALL app services to 0 (for local dev mode)
scale-local:
    @echo "[scale] Scaling all app services to 0 (local dev mode)..."
    kubectl scale deployment -n apps auth-service messaging-service presence-service media-service guardyn-envoy --replicas=0
    @echo "[scale] Done. All app pods stopped. Use 'just dev-all' + 'just dev-envoy-local' for local development."

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

# =============================================================================
# Flutter Client Commands
# =============================================================================

# Run Flutter Linux client (requires dev-all + dev-envoy-local)
dev-linux:
    @echo "[dev] Starting Flutter Linux client..."
    @echo "[dev] Make sure services are running: just dev-all && just dev-envoy-local"
    cd client && flutter run -d linux

# Run Flutter Android client (requires dev-all + dev-envoy-local + emulator)
dev-android:
    @echo "[dev] Starting Flutter Android client..."
    @echo "[dev] Make sure services are running: just dev-all && just dev-envoy-local"
    @echo "[dev] Make sure Android emulator is running: flutter run -d <emulator_id> OR: flutter emulators --launch <emulator_id>"
    cd client && flutter run -d emulator-5554

# List available Flutter devices
dev-devices:
    @echo "[dev] Available Flutter devices:"
    flutter devices

# Run Envoy LOCALLY for Flutter Web (gRPC-Web proxy to local services)
# This is the recommended way for development - enables hot reload!
# Uses port 18080 to avoid conflict with k3d (which uses 8080)
dev-envoy-local:
    @echo "[dev] Starting local Envoy on :18080 → localhost:50051-50054..."
    @echo "[dev] Make sure services are running: just dev-all"
    @docker rm -f envoy-local 2>/dev/null || true
    docker run -d --name envoy-local \
        --network host \
        -v $(pwd)/client-mobile/envoy-local.yaml:/etc/envoy/envoy.yaml:ro \
        envoyproxy/envoy:v1.28-latest
    @sleep 2 && nc -z localhost 18080 && echo "[dev] ✅ Envoy running on port 18080" || echo "[dev] ❌ Envoy failed to start"


# Run Flutter Web client (requires dev-envoy-local in another terminal)
dev-web:
    @echo "[dev] Starting Flutter Web on :3000..."
    @echo "[dev] Make sure Envoy is running: just dev-envoy-local"
    cd client && flutter run -d chrome --web-port=3000

# Run Flutter Web client in release mode
dev-web-release:
    @echo "[dev] Starting Flutter Web in release mode on :3000..."
    cd client && flutter run -d chrome --web-port=3000 --release

# =============================================================================
# Client Data Management
# =============================================================================

# Clear all client data (E2EE sessions, keys) - interactive mode
clear-client-data:
    @echo "[client] Clearing client data (E2EE sessions, keys)..."
    bash client-mobile/scripts/clear-client-data.sh

# Force clear all client data without confirmation
clear-client-data-force:
    @echo "[client] Force clearing all client data..."
    bash client-mobile/scripts/clear-client-data.sh --force

# =============================================================================
# Docker Compose Local Development (Recommended for beginners)
# =============================================================================
# Fast local development with hot-reload. No k8s required!
# Start: just dc-up   |  Stop: just dc-down   |  Logs: just dc-logs

COMPOSE := "docker compose -f docker-compose.dev.yml"

# Start all services (data layer + backend + envoy)
dc-up:
    @echo "[docker] Starting all services (~30 seconds)..."
    {{COMPOSE}} up -d
    @echo ""
    @echo "✅ Services starting. Check status: just dc-ps"
    @echo "📊 Redpanda Console: http://localhost:8088"
    @echo "🪣 MinIO Console: http://localhost:9001 (guardyn/guardyn-dev-secret)"
    @echo "🔌 Envoy (gRPC-Web): http://localhost:8080"

# Start only data layer (TiKV, ScyllaDB, Redpanda, MinIO)
dc-up-data:
    @echo "[docker] Starting data layer only..."
    {{COMPOSE}} up -d pd tikv scylladb redpanda minio minio-init
    @echo "✅ Data layer started. Wait for health checks: just dc-ps"

# Start specific service(s)
dc-up-service +services:
    @echo "[docker] Starting: {{services}}..."
    {{COMPOSE}} up -d {{services}}

# Stop all services (keep volumes)
dc-down:
    @echo "[docker] Stopping all services..."
    {{COMPOSE}} down

# Stop all services and DELETE volumes (reset all data)
dc-reset:
    @echo "[docker] ⚠️  Stopping and removing ALL data..."
    {{COMPOSE}} down -v
    @echo "✅ All containers and volumes removed"

# Show running containers
dc-ps:
    {{COMPOSE}} ps

# Show container status with health
dc-status:
    @echo "[docker] Container status:"
    {{COMPOSE}} ps --format "table {{{{.Name}}}}\t{{{{.Status}}}}\t{{{{.Ports}}}}"

# Follow logs for all services
dc-logs:
    {{COMPOSE}} logs -f

# Follow logs for specific service
dc-log service:
    {{COMPOSE}} logs -f {{service}}

# Rebuild and restart a specific service
dc-rebuild service:
    @echo "[docker] Rebuilding {{service}}..."
    {{COMPOSE}} up -d --build {{service}}

# Rebuild all backend services
dc-rebuild-all:
    @echo "[docker] Rebuilding all backend services..."
    {{COMPOSE}} up -d --build auth-service messaging-service presence-service media-service notification-service

# Restart a specific service
dc-restart service:
    {{COMPOSE}} restart {{service}}

# Execute command in a running container
dc-exec service +cmd:
    {{COMPOSE}} exec {{service}} {{cmd}}

# Open shell in a running container
dc-shell service:
    {{COMPOSE}} exec {{service}} /bin/sh

# Check ScyllaDB status
dc-scylla-status:
    {{COMPOSE}} exec scylladb nodetool status

# Open CQL shell to ScyllaDB
dc-cqlsh:
    {{COMPOSE}} exec scylladb cqlsh

# Check TiKV cluster status
dc-tikv-status:
    {{COMPOSE}} exec pd /pd-ctl store

# Check Redpanda cluster health
dc-redpanda-health:
    {{COMPOSE}} exec redpanda rpk cluster health

# List Redpanda topics
dc-redpanda-topics:
    {{COMPOSE}} exec redpanda rpk topic list

# Show resource usage
dc-stats:
    docker stats --no-stream $({{COMPOSE}} ps -q)

# Clean up unused Docker resources
dc-prune:
    @echo "[docker] Cleaning unused resources..."
    docker system prune -f
    @echo "✅ Cleanup complete"

# Pull latest images
dc-pull:
    @echo "[docker] Pulling latest images..."
    {{COMPOSE}} pull

# =============================================================================
# Rust FFI Commands (Native Crypto Library)
# =============================================================================

# Build crypto-ffi for all platforms
ffi-build-all:
    @echo "[ffi] Building crypto-ffi for all platforms..."
    cd backend/crates/crypto-ffi && ./build-mobile.sh all

# Build crypto-ffi for Android
ffi-build-android:
    @echo "[ffi] Building crypto-ffi for Android..."
    cd backend/crates/crypto-ffi && ./build-mobile.sh android

# Build crypto-ffi for iOS (macOS only)
ffi-build-ios:
    @echo "[ffi] Building crypto-ffi for iOS..."
    cd backend/crates/crypto-ffi && ./build-mobile.sh ios

# Build crypto-ffi for desktop (current platform)
ffi-build-desktop:
    @echo "[ffi] Building crypto-ffi for desktop..."
    cd backend/crates/crypto-ffi && ./build-mobile.sh desktop

# Generate Dart bindings with flutter_rust_bridge
ffi-generate:
    @echo "[ffi] Generating Dart bindings..."
    cd backend/crates/crypto-ffi && ./build-mobile.sh generate

# Test crypto-ffi crate
ffi-test:
    @echo "[ffi] Testing crypto-ffi..."
    cd backend && cargo test -p guardyn-crypto-ffi --features full

# Check crypto-ffi compiles
ffi-check:
    @echo "[ffi] Checking crypto-ffi..."
    cd backend && cargo check -p guardyn-crypto-ffi --features full

# Install crypto-ffi library for Linux Flutter development
ffi-install-linux:
    @echo "[ffi] Installing crypto-ffi for Linux..."
    cd backend && cargo build -p guardyn-crypto-ffi --release
    client-mobile/scripts/install-linux-lib.sh
