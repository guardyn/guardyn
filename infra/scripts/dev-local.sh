#!/usr/bin/env bash
# =============================================================================
# Local Development Environment Script
# =============================================================================
# This script sets up port-forwarding to cluster databases and runs backend
# services locally for fast development iteration.
#
# Usage:
#   ./dev-local.sh [service|all|ports-only|stop]
#
# Examples:
#   ./dev-local.sh ports-only    # Only start port-forwards to databases
#   ./dev-local.sh auth          # Start port-forwards + auth-service
#   ./dev-local.sh messaging     # Start port-forwards + messaging-service
#   ./dev-local.sh all           # Start port-forwards + all services
#   ./dev-local.sh stop          # Stop all port-forwards
#
# Benefits:
#   - Rebuild time: ~5-10 seconds (vs ~60+ seconds with Docker)
#   - Hot reload with cargo-watch
#   - Direct debugging with IDE
#   - ~70% memory savings (no k8s overhead for services)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
BACKEND_DIR="${PROJECT_ROOT}/backend"
PID_DIR="${PROJECT_ROOT}/_local/.dev-pids"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Default ports for local development
TIKV_PD_PORT=2379
TIKV_STORE_PORT=20160  # TiKV gRPC port for actual data operations
SCYLLADB_PORT=9042
NATS_PORT=4222
MINIO_PORT=9000
MINIO_CONSOLE_PORT=9001

# Service ports (matching k8s configuration)
AUTH_PORT=50051
MESSAGING_PORT=50052
PRESENCE_PORT=50053
MEDIA_PORT=50054

# Environment variables for local services
export RUST_LOG="${RUST_LOG:-info,guardyn=debug}"
export RUST_BACKTRACE=1

# TiKV configuration
export GUARDYN_DATABASE__TIKV_PD_ENDPOINTS="127.0.0.1:${TIKV_PD_PORT}"
export TIKV_PD_ENDPOINTS="127.0.0.1:${TIKV_PD_PORT}"

# ScyllaDB configuration
export GUARDYN_DATABASE__SCYLLADB_NODES="127.0.0.1:${SCYLLADB_PORT}"
export SCYLLADB_ENDPOINTS="127.0.0.1:${SCYLLADB_PORT}"
# For local dev with single ScyllaDB node - use consistency level "one"
export SCYLLA_CONSISTENCY="one"
export SCYLLA_REPLICATION_FACTOR="1"

# NATS configuration
export GUARDYN_MESSAGING__NATS_URL="nats://127.0.0.1:${NATS_PORT}"
export NATS_URL="nats://127.0.0.1:${NATS_PORT}"
export NATS_ENDPOINT="nats://127.0.0.1:${NATS_PORT}"

# MinIO/S3 configuration
export S3_ENDPOINT="http://127.0.0.1:${MINIO_PORT}"
export S3_REGION="us-east-1"
export S3_BUCKET_NAME="guardyn-media"

# JWT Secret (for local dev only - use a consistent value)
export JWT_SECRET="${JWT_SECRET:-dev-secret-key-for-local-development-only}"

# Observability (disabled for local dev by default)
export GUARDYN_OBSERVABILITY__OTLP_ENDPOINT=""
export OTEL_EXPORTER_OTLP_ENDPOINT=""

ensure_pid_dir() {
    mkdir -p "${PID_DIR}"
}

# Start port-forward in background and save PID
start_port_forward() {
    local name="$1"
    local namespace="$2"
    local resource="$3"
    local ports="$4"
    local pid_file="${PID_DIR}/pf-${name}.pid"
    local log_file="${PID_DIR}/pf-${name}.log"

    # Kill existing if running
    if [[ -f "${pid_file}" ]]; then
        local old_pid
        old_pid=$(cat "${pid_file}" 2>/dev/null || echo "")
        if [[ -n "${old_pid}" ]] && kill -0 "${old_pid}" 2>/dev/null; then
            log_warn "Killing existing port-forward for ${name} (PID: ${old_pid})"
            kill "${old_pid}" 2>/dev/null || true
            sleep 1
        fi
        rm -f "${pid_file}"
    fi

    log_info "Starting port-forward: ${name} (${ports})"

    # Start port-forward with logging to file for debugging
    kubectl port-forward -n "${namespace}" "${resource}" "${ports}" >"${log_file}" 2>&1 &
    local pid=$!
    echo "${pid}" > "${pid_file}"

    # Wait and verify it started (with retry)
    local retries=5
    local wait_time=1
    for ((i=1; i<=retries; i++)); do
        sleep "${wait_time}"
        if kill -0 "${pid}" 2>/dev/null; then
            # Process is running, check if port is actually open
            local port_num="${ports%%:*}"
            if nc -z localhost "${port_num}" 2>/dev/null; then
                log_success "Port-forward ${name} started (PID: ${pid})"
                return 0
            fi
        else
            # Process died, show error from log
            if [[ -f "${log_file}" ]] && [[ -s "${log_file}" ]]; then
                log_error "Port-forward ${name} failed: $(cat "${log_file}")"
            else
                log_error "Port-forward ${name} failed (no error details)"
            fi
            return 1
        fi
    done

    # Process running but port not open yet - still consider it success
    if kill -0 "${pid}" 2>/dev/null; then
        log_success "Port-forward ${name} started (PID: ${pid})"
        return 0
    fi

    log_error "Failed to start port-forward for ${name}"
    return 1
}

# Stop all port-forwards
stop_port_forwards() {
    log_info "Stopping all port-forwards..."

    if [[ -d "${PID_DIR}" ]]; then
        for pid_file in "${PID_DIR}"/pf-*.pid; do
            if [[ -f "${pid_file}" ]]; then
                local pid
                pid=$(cat "${pid_file}" 2>/dev/null || echo "")
                local name
                name=$(basename "${pid_file}" .pid | sed 's/pf-//')
                if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
                    log_info "Stopping ${name} (PID: ${pid})"
                    kill "${pid}" 2>/dev/null || true
                fi
                rm -f "${pid_file}"
            fi
        done
    fi

    # Also kill any remaining kubectl port-forward processes
    pkill -f "kubectl port-forward" 2>/dev/null || true

    log_success "All port-forwards stopped"
}

# Start all required port-forwards
start_all_port_forwards() {
    log_info "Starting port-forwards to cluster databases..."

    ensure_pid_dir

    # TiKV PD (for cluster discovery)
    start_port_forward "tikv-pd" "data" "svc/pd" "${TIKV_PD_PORT}:2379"

    # TiKV Store (for actual data operations - REQUIRED!)
    # Note: TiKV client gets store address from PD and connects directly
    # The /etc/hosts should have: 127.0.0.1 tikv-0.tikv.data.svc.cluster.local
    # Using pod directly since tikv service is headless
    start_port_forward "tikv-store" "data" "pod/tikv-0" "${TIKV_STORE_PORT}:20160"

    # ScyllaDB
    start_port_forward "scylladb" "data" "svc/guardyn-scylla-client" "${SCYLLADB_PORT}:9042"

    # NATS
    start_port_forward "nats" "messaging" "svc/nats" "${NATS_PORT}:4222"

    # MinIO
    start_port_forward "minio" "data" "svc/minio" "${MINIO_PORT}:9000"

    log_success "All port-forwards started"
    echo ""
    log_info "Database endpoints available at:"
    echo "  - TiKV PD:    127.0.0.1:${TIKV_PD_PORT}"
    echo "  - TiKV Store: 127.0.0.1:${TIKV_STORE_PORT}"
    echo "  - ScyllaDB:   127.0.0.1:${SCYLLADB_PORT}"
    echo "  - NATS:       127.0.0.1:${NATS_PORT}"
    echo "  - MinIO:      127.0.0.1:${MINIO_PORT}"
    echo ""
}

# Check if port-forwards are running
check_port_forwards() {
    local all_running=true

    # Service name -> port mapping
    declare -A ports=(
        ["tikv-pd"]="${TIKV_PD_PORT}"
        ["tikv-store"]="${TIKV_STORE_PORT}"
        ["scylladb"]="${SCYLLADB_PORT}"
        ["nats"]="${NATS_PORT}"
        ["minio"]="${MINIO_PORT}"
    )

    echo ""
    echo "Port-forward status:"
    echo "===================="

    for service in tikv-pd tikv-store scylladb nats minio; do
        local pid_file="${PID_DIR}/pf-${service}.pid"
        local port="${ports[$service]}"
        if [[ -f "${pid_file}" ]]; then
            local pid
            pid=$(cat "${pid_file}" 2>/dev/null || echo "")
            if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
                log_success "${service}: localhost:${port} (PID: ${pid})"
            else
                log_error "${service}: not running (port ${port})"
                all_running=false
            fi
        else
            log_error "${service}: not started (port ${port})"
            all_running=false
        fi
    done

    echo ""
    echo "Local services (if running):"
    echo "============================"
    for svc_port in 50051 50052 50053 50054; do
        local svc_name=""
        case ${svc_port} in
            50051) svc_name="auth-service" ;;
            50052) svc_name="messaging-service" ;;
            50053) svc_name="presence-service" ;;
            50054) svc_name="media-service" ;;
        esac
        if nc -z localhost ${svc_port} 2>/dev/null; then
            log_success "${svc_name}: localhost:${svc_port}"
        else
            echo -e "  ${svc_name}: not running (port ${svc_port})"
        fi
    done
    echo ""

    ${all_running}
}

# Run a backend service locally with hot-reload
# Service binary names:
#   - auth-service
#   - guardyn-messaging-service
#   - guardyn-presence-service
#   - guardyn-media-service
run_service() {
    local service="$1"
    local port="$2"

    log_info "Starting ${service} locally on port ${port}..."

    # Common environment variables
    export GUARDYN_HOST="0.0.0.0"
    export GUARDYN_PORT="${port}"
    export GUARDYN_SERVICE_NAME="${service}"
    export GRPC_PORT="${port}"
    export GUARDYN_OBSERVABILITY__LOG_LEVEL="debug"

    # Map service name to binary name
    local bin_name="${service}"
    case "${service}" in
        messaging-service)
            bin_name="guardyn-messaging-service"
            # Messaging service needs auth-service endpoint
            export AUTH_SERVICE_URL="http://127.0.0.1:${AUTH_PORT}"
            export AUTH_SERVICE_ENDPOINT="http://127.0.0.1:${AUTH_PORT}"
            ;;
        presence-service)
            bin_name="guardyn-presence-service"
            ;;
        media-service)
            bin_name="guardyn-media-service"
            # Media service needs S3/MinIO credentials
            export S3_ACCESS_KEY="${S3_ACCESS_KEY:-minioadmin}"
            export S3_SECRET_KEY="${S3_SECRET_KEY:-minioadmin-secret-password}"
            ;;
    esac

    cd "${BACKEND_DIR}"

    # Check if cargo-watch is available for hot reload
    # Run inside nix develop to ensure cargo is available
    log_info "Using nix develop to ensure cargo toolchain..."
    log_info "Binary: ${bin_name}, Port: ${port}"

    cd "${PROJECT_ROOT}"
    nix develop --command bash -c "cd backend && \
        export GUARDYN_HOST='0.0.0.0' && \
        export GUARDYN_PORT='${port}' && \
        export GUARDYN_SERVICE_NAME='${service}' && \
        export GRPC_PORT='${port}' && \
        export GUARDYN_OBSERVABILITY__LOG_LEVEL='debug' && \
        export GUARDYN_DATABASE__TIKV_PD_ENDPOINTS='127.0.0.1:${TIKV_PD_PORT}' && \
        export GUARDYN_DATABASE__SCYLLADB_NODES='127.0.0.1:${SCYLLADB_PORT}' && \
        export GUARDYN_MESSAGING__NATS_URL='nats://127.0.0.1:${NATS_PORT}' && \
        export SCYLLA_CONSISTENCY='one' && \
        export SCYLLA_REPLICATION_FACTOR='1' && \
        export JWT_SECRET='${JWT_SECRET}' && \
        export RUST_LOG='info,guardyn=debug' && \
        if command -v cargo-watch &>/dev/null; then \
            cargo watch -x 'run --bin ${bin_name}'; \
        else \
            cargo run --bin ${bin_name}; \
        fi"
}

# Run all services in separate terminals (requires tmux or screen)
run_all_services() {
    if command -v tmux &>/dev/null; then
        log_info "Starting all services in tmux..."

        # Kill existing session if present
        tmux kill-session -t guardyn-dev 2>/dev/null || true

        # Common env exports (shared by all services)
        local common_env="export JWT_SECRET='${JWT_SECRET}' && \
export GUARDYN_HOST='0.0.0.0' && \
export GUARDYN_DATABASE__TIKV_PD_ENDPOINTS='127.0.0.1:${TIKV_PD_PORT}' && \
export TIKV_PD_ENDPOINTS='127.0.0.1:${TIKV_PD_PORT}' && \
export GUARDYN_DATABASE__SCYLLADB_NODES='127.0.0.1:${SCYLLADB_PORT}' && \
export GUARDYN_MESSAGING__NATS_URL='nats://127.0.0.1:${NATS_PORT}' && \
export SCYLLA_CONSISTENCY='one' && \
export SCYLLA_REPLICATION_FACTOR='1' && \
export GUARDYN_OBSERVABILITY__OTLP_ENDPOINT='' && \
export GUARDYN_OBSERVABILITY__LOG_LEVEL='debug' && \
export RUST_LOG='info,guardyn=debug'"

        # Create new tmux session
        tmux new-session -d -s guardyn-dev -n main

        # Auth Service
        tmux new-window -t guardyn-dev -n auth
        tmux send-keys -t guardyn-dev:auth "cd ${PROJECT_ROOT} && nix develop --command bash -c '${common_env} && GUARDYN_SERVICE_NAME=auth-service GUARDYN_PORT=50051 cargo watch -x \"run --bin auth-service\" -C backend'" Enter

        # Messaging Service
        tmux new-window -t guardyn-dev -n messaging
        tmux send-keys -t guardyn-dev:messaging "cd ${PROJECT_ROOT} && nix develop --command bash -c '${common_env} && GUARDYN_SERVICE_NAME=messaging-service GUARDYN_PORT=50052 AUTH_SERVICE_URL=\"http://127.0.0.1:50051\" cargo watch -x \"run --bin guardyn-messaging-service\" -C backend'" Enter

        # Presence Service
        tmux new-window -t guardyn-dev -n presence
        tmux send-keys -t guardyn-dev:presence "cd ${PROJECT_ROOT} && nix develop --command bash -c '${common_env} && GUARDYN_SERVICE_NAME=presence-service GUARDYN_PORT=50053 cargo watch -x \"run --bin guardyn-presence-service\" -C backend'" Enter

        # Media Service
        tmux new-window -t guardyn-dev -n media
        tmux send-keys -t guardyn-dev:media "cd ${PROJECT_ROOT} && nix develop --command bash -c '${common_env} && GUARDYN_SERVICE_NAME=media-service GUARDYN_PORT=50054 S3_ENDPOINT=\"http://127.0.0.1:${MINIO_PORT}\" S3_ACCESS_KEY=\"minioadmin\" S3_SECRET_KEY=\"minioadmin-secret-password\" cargo watch -x \"run --bin guardyn-media-service\" -C backend'" Enter

        log_success "All services started in tmux session 'guardyn-dev'"
        log_info "To view logs: tmux attach -t guardyn-dev"
        log_info "To check status: just dev-status"
        log_info "To stop all: just dev-kill"
    else
        log_error "tmux is required to run all services. Install with: sudo apt install tmux"
        log_info "Alternatively, run services individually in separate terminals:"
        echo "  just dev-auth"
        echo "  just dev-messaging"
        echo "  just dev-presence"
        echo "  just dev-media"
        exit 1
    fi
}

# Print usage
usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  ports-only    Start port-forwards to databases only"
    echo "  auth          Start auth-service locally"
    echo "  messaging     Start messaging-service locally"
    echo "  presence      Start presence-service locally"
    echo "  media         Start media-service locally"
    echo "  all           Start all services in tmux"
    echo "  stop          Stop all port-forwards"
    echo "  status        Check port-forward status"
    echo ""
    echo "Examples:"
    echo "  $0 ports-only    # Only start port-forwards"
    echo "  $0 auth          # Start port-forwards + auth-service"
    echo "  $0 all           # Start all services in tmux"
}

# Main
main() {
    local command="${1:-help}"

    case "${command}" in
        ports-only|ports)
            start_all_port_forwards
            log_info "Port-forwards running. Press Ctrl+C to stop, or run '$0 stop'"
            # Keep script running
            wait
            ;;
        auth)
            start_all_port_forwards
            run_service "auth-service" "${AUTH_PORT}"
            ;;
        messaging)
            start_all_port_forwards
            run_service "messaging-service" "${MESSAGING_PORT}"
            ;;
        presence)
            start_all_port_forwards
            run_service "presence-service" "${PRESENCE_PORT}"
            ;;
        media)
            start_all_port_forwards
            run_service "media-service" "${MEDIA_PORT}"
            ;;
        all)
            start_all_port_forwards
            run_all_services
            ;;
        stop)
            stop_port_forwards
            ;;
        status)
            ensure_pid_dir
            check_port_forwards || true  # Don't fail on status check
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            log_error "Unknown command: ${command}"
            usage
            exit 1
            ;;
    esac
}

# Handle Ctrl+C
trap 'echo ""; log_info "Interrupted. Run \"$0 stop\" to stop port-forwards."; exit 0' INT

main "$@"
