#!/usr/bin/env bash
#
# Port-Forward Watchdog Script for Guardyn Development
#
# This script provides robust, auto-restarting port-forwarding for local development.
# It monitors all required ports and automatically restarts them if they die.
#
# Features:
# - Automatic restart on failure with exponential backoff
# - Health checks every 5 seconds
# - Clean shutdown on SIGINT/SIGTERM
# - Colored status output
# - Log files for debugging
# - ChromeDriver support (optional)
#
# Usage:
#   ./port-forward-watchdog.sh [options]
#
# Options:
#   --no-chromedriver  Skip ChromeDriver (for non-web testing)
#   --no-envoy         Skip Envoy proxy (for native apps only)
#   --check-interval N Health check interval in seconds (default: 5)
#   --log-dir DIR      Log directory (default: /tmp/guardyn-pf)
#   --foreground       Run in foreground with live status
#   --daemon           Run as background daemon
#   --stop             Stop all port-forwards and exit
#   --status           Show current status and exit
#   --help             Show this help
#

set -euo pipefail

# ============================================================
# Configuration
# ============================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Default configuration
CHECK_INTERVAL=5
LOG_DIR="/tmp/guardyn-pf"
ENABLE_CHROMEDRIVER=true
ENABLE_ENVOY=true
DAEMON_MODE=false
FOREGROUND_MODE=true
PID_FILE="/tmp/guardyn-pf-watchdog.pid"

# Port configuration
AUTH_PORT=50051
MESSAGING_PORT=50052
PRESENCE_PORT=50053
WEBSOCKET_PORT=8081
ENVOY_LOCAL_PORT=18080
ENVOY_REMOTE_PORT=8080
CHROMEDRIVER_PORT=4444

# Retry configuration
MAX_RETRIES=10
RETRY_DELAY=2

# Process tracking
declare -A PIDS
declare -A RESTART_COUNTS
declare -A LAST_RESTART

# Script directory for finding chromedriver
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ============================================================
# Argument Parsing
# ============================================================

while [[ $# -gt 0 ]]; do
  case $1 in
    --no-chromedriver)
      ENABLE_CHROMEDRIVER=false
      shift
      ;;
    --no-envoy)
      ENABLE_ENVOY=false
      shift
      ;;
    --check-interval)
      CHECK_INTERVAL="$2"
      shift 2
      ;;
    --log-dir)
      LOG_DIR="$2"
      shift 2
      ;;
    --foreground)
      FOREGROUND_MODE=true
      DAEMON_MODE=false
      shift
      ;;
    --daemon)
      DAEMON_MODE=true
      FOREGROUND_MODE=false
      shift
      ;;
    --stop)
      # Stop all processes and exit
      if [ -f "$PID_FILE" ]; then
        WATCHDOG_PID=$(cat "$PID_FILE")
        if kill -0 "$WATCHDOG_PID" 2>/dev/null; then
          kill "$WATCHDOG_PID" 2>/dev/null || true
          echo -e "${GREEN}✅ Watchdog stopped (PID: $WATCHDOG_PID)${NC}"
        fi
        rm -f "$PID_FILE"
      fi
      # Kill any remaining port-forwards
      pkill -f "kubectl port-forward.*auth-service" 2>/dev/null || true
      pkill -f "kubectl port-forward.*messaging-service.*50052" 2>/dev/null || true
      pkill -f "kubectl port-forward.*messaging-service.*8081" 2>/dev/null || true
      pkill -f "kubectl port-forward.*presence-service" 2>/dev/null || true
      pkill -f "kubectl port-forward.*guardyn-envoy" 2>/dev/null || true
      pkill -f "chromedriver.*--port=$CHROMEDRIVER_PORT" 2>/dev/null || true
      echo -e "${GREEN}✅ All port-forwards stopped${NC}"
      exit 0
      ;;
    --status)
      echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
      echo -e "${CYAN}Guardyn Port-Forward Status${NC}"
      echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

      check_port() {
        local port=$1
        local name=$2
        if lsof -i ":$port" 2>/dev/null | grep -q LISTEN; then
          echo -e "${GREEN}✅ $name (port $port): Running${NC}"
        else
          echo -e "${RED}❌ $name (port $port): Not running${NC}"
        fi
      }

      check_port $AUTH_PORT "Auth Service"
      check_port $MESSAGING_PORT "Messaging gRPC"
      check_port $WEBSOCKET_PORT "Messaging WebSocket"
      check_port $PRESENCE_PORT "Presence Service"
      check_port $ENVOY_LOCAL_PORT "Envoy Proxy"
      check_port $CHROMEDRIVER_PORT "ChromeDriver"

      if [ -f "$PID_FILE" ]; then
        WATCHDOG_PID=$(cat "$PID_FILE")
        if kill -0 "$WATCHDOG_PID" 2>/dev/null; then
          echo -e "${GREEN}✅ Watchdog daemon: Running (PID: $WATCHDOG_PID)${NC}"
        else
          echo -e "${YELLOW}⚠️  Watchdog daemon: Stale PID file${NC}"
        fi
      else
        echo -e "${GRAY}ℹ️  Watchdog daemon: Not running${NC}"
      fi
      exit 0
      ;;
    --help|-h)
      head -n 35 "$0" | grep "^#" | sed 's/^# //'
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

# ============================================================
# Utility Functions
# ============================================================

log_info() {
  if [ "$FOREGROUND_MODE" = true ]; then
    echo -e "${BLUE}ℹ️  $1${NC}"
  fi
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1" >> "$LOG_DIR/watchdog.log"
}

log_success() {
  if [ "$FOREGROUND_MODE" = true ]; then
    echo -e "${GREEN}✅ $1${NC}"
  fi
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $1" >> "$LOG_DIR/watchdog.log"
}

log_warning() {
  if [ "$FOREGROUND_MODE" = true ]; then
    echo -e "${YELLOW}⚠️  $1${NC}"
  fi
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1" >> "$LOG_DIR/watchdog.log"
}

log_error() {
  if [ "$FOREGROUND_MODE" = true ]; then
    echo -e "${RED}❌ $1${NC}"
  fi
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$LOG_DIR/watchdog.log"
}

# ============================================================
# Port-Forward Functions
# ============================================================

is_port_listening() {
  local port=$1
  lsof -i ":$port" 2>/dev/null | grep -q LISTEN
}

wait_for_port() {
  local port=$1
  local name=$2
  local timeout=${3:-10}
  local elapsed=0

  while [ $elapsed -lt $timeout ]; do
    if is_port_listening "$port"; then
      return 0
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done
  return 1
}

start_auth_forward() {
  log_info "Starting auth-service port-forward (port $AUTH_PORT)..."

  # Kill any existing process on this port
  lsof -ti ":$AUTH_PORT" 2>/dev/null | xargs kill -9 2>/dev/null || true
  sleep 0.5

  # Use --address=0.0.0.0 to allow Android emulator connections via 10.0.2.2
  kubectl port-forward -n apps svc/auth-service "$AUTH_PORT:$AUTH_PORT" --address=0.0.0.0 \
    >> "$LOG_DIR/auth-service.log" 2>&1 &
  PIDS["auth"]=$!

  if wait_for_port "$AUTH_PORT" "auth-service" 10; then
    log_success "Auth service port-forward started (PID: ${PIDS[auth]})"
    return 0
  else
    log_error "Auth service port-forward failed to start"
    return 1
  fi
}

start_messaging_forward() {
  log_info "Starting messaging-service port-forward (port $MESSAGING_PORT)..."

  lsof -ti ":$MESSAGING_PORT" 2>/dev/null | xargs kill -9 2>/dev/null || true
  sleep 0.5

  # Use --address=0.0.0.0 to allow Android emulator connections via 10.0.2.2
  kubectl port-forward -n apps svc/messaging-service "$MESSAGING_PORT:$MESSAGING_PORT" --address=0.0.0.0 \
    >> "$LOG_DIR/messaging-service.log" 2>&1 &
  PIDS["messaging"]=$!

  if wait_for_port "$MESSAGING_PORT" "messaging-service" 10; then
    log_success "Messaging gRPC port-forward started (PID: ${PIDS[messaging]})"
    return 0
  else
    log_error "Messaging gRPC port-forward failed to start"
    return 1
  fi
}

start_websocket_forward() {
  log_info "Starting messaging-service WebSocket port-forward (port $WEBSOCKET_PORT)..."

  lsof -ti ":$WEBSOCKET_PORT" 2>/dev/null | xargs kill -9 2>/dev/null || true
  sleep 0.5

  # Use --address=0.0.0.0 to allow Android emulator connections via 10.0.2.2
  kubectl port-forward -n apps svc/messaging-service "$WEBSOCKET_PORT:$WEBSOCKET_PORT" --address=0.0.0.0 \
    >> "$LOG_DIR/websocket.log" 2>&1 &
  PIDS["websocket"]=$!

  if wait_for_port "$WEBSOCKET_PORT" "messaging-websocket" 10; then
    log_success "Messaging WebSocket port-forward started (PID: ${PIDS[websocket]})"
    return 0
  else
    log_error "Messaging WebSocket port-forward failed to start"
    return 1
  fi
}

start_presence_forward() {
  log_info "Starting presence-service port-forward (port $PRESENCE_PORT)..."

  lsof -ti ":$PRESENCE_PORT" 2>/dev/null | xargs kill -9 2>/dev/null || true
  sleep 0.5

  # Use --address=0.0.0.0 to allow Android emulator connections via 10.0.2.2
  kubectl port-forward -n apps svc/presence-service "$PRESENCE_PORT:$PRESENCE_PORT" --address=0.0.0.0 \
    >> "$LOG_DIR/presence-service.log" 2>&1 &
  PIDS["presence"]=$!

  if wait_for_port "$PRESENCE_PORT" "presence-service" 10; then
    log_success "Presence service port-forward started (PID: ${PIDS[presence]})"
    return 0
  else
    log_error "Presence service port-forward failed to start"
    return 1
  fi
}

start_envoy_forward() {
  if [ "$ENABLE_ENVOY" != true ]; then
    return 0
  fi

  log_info "Starting Envoy proxy port-forward (port $ENVOY_LOCAL_PORT → $ENVOY_REMOTE_PORT)..."

  lsof -ti ":$ENVOY_LOCAL_PORT" 2>/dev/null | xargs kill -9 2>/dev/null || true
  sleep 0.5

  # Use --address=0.0.0.0 for consistency (mainly used by web, but available to all)
  kubectl port-forward -n apps svc/guardyn-envoy "$ENVOY_LOCAL_PORT:$ENVOY_REMOTE_PORT" --address=0.0.0.0 \
    >> "$LOG_DIR/envoy.log" 2>&1 &
  PIDS["envoy"]=$!

  if wait_for_port "$ENVOY_LOCAL_PORT" "envoy" 10; then
    log_success "Envoy proxy port-forward started (PID: ${PIDS[envoy]})"
    return 0
  else
    log_error "Envoy proxy port-forward failed to start"
    return 1
  fi
}

start_chromedriver() {
  if [ "$ENABLE_CHROMEDRIVER" != true ]; then
    return 0
  fi

  log_info "Starting ChromeDriver (port $CHROMEDRIVER_PORT)..."

  lsof -ti ":$CHROMEDRIVER_PORT" 2>/dev/null | xargs kill -9 2>/dev/null || true
  sleep 0.5

  # Find chromedriver
  CHROMEDRIVER_BIN=""

  # Check common locations
  if command -v chromedriver &> /dev/null; then
    CHROMEDRIVER_BIN="chromedriver"
  elif [ -x "$ROOT_DIR/client/chromedriver/linux-142.0.7444.175/chromedriver-linux64/chromedriver" ]; then
    CHROMEDRIVER_BIN="$ROOT_DIR/client/chromedriver/linux-142.0.7444.175/chromedriver-linux64/chromedriver"
  elif [ -x "/usr/bin/chromedriver" ]; then
    CHROMEDRIVER_BIN="/usr/bin/chromedriver"
  elif [ -x "/usr/local/bin/chromedriver" ]; then
    CHROMEDRIVER_BIN="/usr/local/bin/chromedriver"
  fi

  if [ -z "$CHROMEDRIVER_BIN" ]; then
    log_warning "ChromeDriver not found - skipping (install with: apt install chromium-chromedriver)"
    ENABLE_CHROMEDRIVER=false
    return 0
  fi

  "$CHROMEDRIVER_BIN" --port="$CHROMEDRIVER_PORT" \
    >> "$LOG_DIR/chromedriver.log" 2>&1 &
  PIDS["chromedriver"]=$!

  if wait_for_port "$CHROMEDRIVER_PORT" "chromedriver" 10; then
    log_success "ChromeDriver started (PID: ${PIDS[chromedriver]})"
    return 0
  else
    log_error "ChromeDriver failed to start"
    return 1
  fi
}

# ============================================================
# Watchdog Functions
# ============================================================

check_and_restart() {
  local name=$1
  local port=$2
  local start_func=$3

  if ! is_port_listening "$port"; then
    local count=${RESTART_COUNTS[$name]:-0}
    count=$((count + 1))
    RESTART_COUNTS[$name]=$count

    if [ $count -le $MAX_RETRIES ]; then
      log_warning "$name died (port $port), restarting (attempt $count/$MAX_RETRIES)..."

      # Exponential backoff
      local delay=$((RETRY_DELAY * count))
      if [ $delay -gt 30 ]; then
        delay=30
      fi
      sleep $delay

      if $start_func; then
        log_success "$name restarted successfully"
        RESTART_COUNTS[$name]=0
      fi
    else
      log_error "$name failed after $MAX_RETRIES attempts - check logs in $LOG_DIR"
    fi
  else
    # Reset restart count on successful health check
    RESTART_COUNTS[$name]=0
  fi
}

run_watchdog() {
  log_info "Starting watchdog loop (interval: ${CHECK_INTERVAL}s)..."

  while true; do
    check_and_restart "auth" $AUTH_PORT start_auth_forward
    check_and_restart "messaging" $MESSAGING_PORT start_messaging_forward
    check_and_restart "websocket" $WEBSOCKET_PORT start_websocket_forward
    check_and_restart "presence" $PRESENCE_PORT start_presence_forward

    if [ "$ENABLE_ENVOY" = true ]; then
      check_and_restart "envoy" $ENVOY_LOCAL_PORT start_envoy_forward
    fi

    if [ "$ENABLE_CHROMEDRIVER" = true ]; then
      check_and_restart "chromedriver" $CHROMEDRIVER_PORT start_chromedriver
    fi

    sleep "$CHECK_INTERVAL"
  done
}

# ============================================================
# Cleanup Functions
# ============================================================

cleanup() {
  log_info "Shutting down port-forwards..."

  for name in "${!PIDS[@]}"; do
    pid=${PIDS[$name]}
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
      log_info "Stopped $name (PID: $pid)"
    fi
  done

  rm -f "$PID_FILE"
  log_success "Cleanup complete"
  exit 0
}

trap cleanup SIGINT SIGTERM EXIT

# ============================================================
# Main Execution
# ============================================================

main() {
  # Create log directory
  mkdir -p "$LOG_DIR"

  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}Guardyn Port-Forward Watchdog${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""

  # Check prerequisites
  if ! command -v kubectl &> /dev/null; then
    log_error "kubectl not found"
    exit 1
  fi

  if ! kubectl cluster-info &> /dev/null; then
    log_error "Kubernetes cluster not accessible"
    exit 1
  fi

  # Check if pods are running
  log_info "Checking backend pods..."

  AUTH_READY=$(kubectl get pods -n apps -l app=auth-service --no-headers 2>/dev/null | grep -c Running || echo 0)
  MSG_READY=$(kubectl get pods -n apps -l app=messaging-service --no-headers 2>/dev/null | grep -c Running || echo 0)
  PRESENCE_READY=$(kubectl get pods -n apps -l app=presence-service --no-headers 2>/dev/null | grep -c Running || echo 0)

  if [ "$AUTH_READY" -eq 0 ]; then
    log_error "Auth service pods not running"
    exit 1
  fi

  if [ "$MSG_READY" -eq 0 ]; then
    log_error "Messaging service pods not running"
    exit 1
  fi

  if [ "$PRESENCE_READY" -eq 0 ]; then
    log_warning "Presence service pods not running - heartbeats will fail"
  fi

  if [ "$ENABLE_ENVOY" = true ]; then
    ENVOY_READY=$(kubectl get pods -n apps -l app=guardyn-envoy --no-headers 2>/dev/null | grep -c Running || echo 0)
    if [ "$ENVOY_READY" -eq 0 ]; then
      log_warning "Envoy pod not running - disabling Envoy proxy"
      ENABLE_ENVOY=false
    fi
  fi

  log_success "Backend pods verified"
  echo ""

  # Start initial port-forwards
  log_info "Starting port-forwards..."

  start_auth_forward || exit 1
  start_messaging_forward || exit 1
  start_websocket_forward || exit 1
  start_presence_forward || exit 1

  if [ "$ENABLE_ENVOY" = true ]; then
    start_envoy_forward || true
  fi

  if [ "$ENABLE_CHROMEDRIVER" = true ]; then
    start_chromedriver || true
  fi

  echo ""
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}All port-forwards active!${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "  Auth service:      ${CYAN}localhost:$AUTH_PORT${NC}"
  echo -e "  Messaging gRPC:    ${CYAN}localhost:$MESSAGING_PORT${NC}"
  echo -e "  Messaging WS:      ${CYAN}localhost:$WEBSOCKET_PORT${NC}"
  echo -e "  Presence service:  ${CYAN}localhost:$PRESENCE_PORT${NC}"
  if [ "$ENABLE_ENVOY" = true ]; then
    echo -e "  Envoy proxy:       ${CYAN}localhost:$ENVOY_LOCAL_PORT${NC} (for Chrome)"
  fi
  if [ "$ENABLE_CHROMEDRIVER" = true ]; then
    echo -e "  ChromeDriver:      ${CYAN}localhost:$CHROMEDRIVER_PORT${NC}"
  fi
  echo ""
  echo -e "  Log directory:     ${GRAY}$LOG_DIR${NC}"
  echo ""
  echo -e "${YELLOW}Press Ctrl+C to stop all port-forwards${NC}"
  echo ""

  # Handle daemon mode
  if [ "$DAEMON_MODE" = true ]; then
    echo $$ > "$PID_FILE"
    log_info "Running in daemon mode (PID: $$)"
    FOREGROUND_MODE=false
  fi

  # Run watchdog loop
  run_watchdog
}

main
