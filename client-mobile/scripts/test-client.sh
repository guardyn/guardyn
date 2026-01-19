#!/usr/bin/env bash
#
# Guardyn Flutter Client Testing Script
#
# This unified script provides all testing functionality:
# 1. Integration tests (automated)
# 2. Two-device manual testing (Linux + Android)
# 3. Backend verification
#
# Usage:
#   ./scripts/test-client.sh [command] [options]
#
# Commands:
#   integration            Run automated integration tests
#   two-device <linux>     Setup two-device manual testing
#   verify                 Verify backend and build
#   help                   Show this help message
#
# Options:
#   -d DEVICE    Device for integration tests (default: first available)
#   -v           Verbose output
#
# Security Note:
#   Web platform (Chrome/Firefox) has been removed for security reasons.
#   All platforms use native gRPC and Rust FFI for cryptography.
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$CLIENT_DIR/.." && pwd)"

# Global variables
DEVICE=""
VERBOSE=""
AUTH_PF_PID=""
MESSAGING_PF_PID=""
ENVOY_PF_PID=""

# ============================================================
# Utility Functions
# ============================================================

show_help() {
  head -n 30 "$0" | grep "^#" | sed 's/^# //'
  exit 0
}

log_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
  echo -e "${RED}❌ $1${NC}"
}

log_header() {
  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}$1${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

# ============================================================
# Backend Verification Functions
# ============================================================

check_kubectl() {
  if ! command -v kubectl &> /dev/null; then
    log_error "kubectl not found. Please install kubectl."
    exit 1
  fi
}

check_cluster() {
  if ! kubectl cluster-info &> /dev/null; then
    log_error "Kubernetes cluster not accessible."
    log_warning "Run: just kube-create && just kube-bootstrap"
    exit 1
  fi
}

check_backend_services() {
  log_info "Checking backend services..."

  AUTH_PODS=$(kubectl get pods -n apps -l app=auth-service --no-headers 2>/dev/null | wc -l)
  MESSAGING_PODS=$(kubectl get pods -n apps -l app=messaging-service --no-headers 2>/dev/null | wc -l)

  if [ "$AUTH_PODS" -eq 0 ]; then
    log_error "Auth service not deployed"
    log_warning "Run: infra/scripts/build-and-deploy-services.sh auth"
    exit 1
  fi

  if [ "$MESSAGING_PODS" -eq 0 ]; then
    log_error "Messaging service not deployed"
    log_warning "Run: infra/scripts/build-and-deploy-services.sh messaging"
    exit 1
  fi

  log_success "Auth service: $AUTH_PODS pods"
  log_success "Messaging service: $MESSAGING_PODS pods"
}

wait_for_pods() {
  log_info "Waiting for pods to be ready..."

  if ! kubectl wait --for=condition=ready pod -n apps -l app=auth-service --timeout=60s &>/dev/null; then
    log_error "Auth service pods not ready"
    kubectl get pods -n apps -l app=auth-service
    exit 1
  fi

  if ! kubectl wait --for=condition=ready pod -n apps -l app=messaging-service --timeout=60s &>/dev/null; then
    log_error "Messaging service pods not ready"
    kubectl get pods -n apps -l app=messaging-service
    exit 1
  fi

  log_success "All pods ready"
}

# ============================================================
# Port-Forwarding Functions
# ============================================================

cleanup_port_forwards() {
  # Kill any existing port-forwards on these ports
  lsof -ti:50051 | xargs kill -9 2>/dev/null || true
  lsof -ti:50052 | xargs kill -9 2>/dev/null || true
  lsof -ti:8080 | xargs kill -9 2>/dev/null || true
}

start_port_forwarding() {
  log_info "Setting up port-forwarding..."

  cleanup_port_forwards

  # Start port-forwarding in background
  kubectl port-forward -n apps svc/auth-service 50051:50051 > /dev/null 2>&1 &
  AUTH_PF_PID=$!

  kubectl port-forward -n apps svc/messaging-service 50052:50052 > /dev/null 2>&1 &
  MESSAGING_PF_PID=$!

  # Wait for port-forwards to be ready
  sleep 2

  # Verify port-forwards are working
  if ! lsof -i:50051 > /dev/null 2>&1; then
    log_error "Auth service port-forward failed"
    exit 1
  fi

  if ! lsof -i:50052 > /dev/null 2>&1; then
    log_error "Messaging service port-forward failed"
    exit 1
  fi

  log_success "Port-forwarding active"
  log_success "  Auth service: localhost:50051 (PID: $AUTH_PF_PID)"
  log_success "  Messaging service: localhost:50052 (PID: $MESSAGING_PF_PID)"
}

stop_port_forwarding() {
  if [ -n "${AUTH_PF_PID:-}" ]; then
    kill "$AUTH_PF_PID" 2>/dev/null || true
  fi

  if [ -n "${MESSAGING_PF_PID:-}" ]; then
    kill "$MESSAGING_PF_PID" 2>/dev/null || true
  fi

  cleanup_port_forwards
}

# ============================================================
# Testing Functions
# ============================================================

run_integration_tests() {
  log_header "Running Integration Tests"

  check_kubectl
  check_cluster
  check_backend_services
  wait_for_pods
  start_port_forwarding

  # Register cleanup on exit
  trap stop_port_forwarding EXIT INT TERM

  cd "$CLIENT_DIR"

  # Determine device if not specified
  if [ -z "$DEVICE" ]; then
    # Extract device ID from flutter devices output
    # Format: "Device Name (type) • device-id • platform • details"
    # We need the device-id field (between first and second bullet)
    DEVICE=$(flutter devices 2>/dev/null | grep -E "emulator|linux" | head -n 1 | awk -F '•' '{print $2}' | xargs || echo "")
    if [ -z "$DEVICE" ]; then
      log_warning "No device specified and none detected"
      log_info "Available devices:"
      flutter devices
      exit 1
    fi
    log_info "Using device: $DEVICE"
  fi

  echo ""
  log_info "Running integration tests..."
  echo ""

  # Run tests
  if flutter test integration_test/messaging_two_device_test.dart -d "$DEVICE" $VERBOSE; then
    echo ""
    log_success "Integration tests PASSED"
    EXIT_CODE=0
  else
    echo ""
    log_error "Integration tests FAILED"
    EXIT_CODE=1
  fi

  # Display results
  log_header "Test Summary"

  if [ $EXIT_CODE -eq 0 ]; then
    log_success "Status: PASSED"
  else
    log_error "Status: FAILED"
  fi

  echo ""
  log_info "Device: $DEVICE"
  log_info "Backend: k3d cluster"
  log_info "Auth service: localhost:50051"
  log_info "Messaging service: localhost:50052"

  echo ""
  if [ $EXIT_CODE -eq 0 ]; then
    log_info "Next Steps:"
    echo "  1. Review test output above"
    echo "  2. Check for any warnings or notes"
    echo "  3. Proceed to manual testing if needed"
    echo "     See: docs/CLIENT_TESTING_GUIDE.md"
  else
    log_error "Troubleshooting:"
    echo "  1. Review error messages above"
    echo "  2. Check backend logs:"
    echo "     kubectl logs -n apps deployment/auth-service"
    echo "     kubectl logs -n apps deployment/messaging-service"
    echo "  3. Verify backend health:"
    echo "     kubectl get pods -n apps"
  fi

  exit $EXIT_CODE
}

setup_two_device_testing() {
  local DEVICE1=$1

  log_header "Two-Device Testing Setup"

  check_kubectl
  check_cluster
  check_backend_services

  # Start port-forwarding if not already running
  if ! lsof -i :50051 > /dev/null 2>&1 || ! lsof -i :50052 > /dev/null 2>&1; then
    start_port_forwarding
    echo ""
    log_warning "Port-forwarding started in background"
    log_info "To stop: pkill -f 'kubectl port-forward'"
  else
    log_success "Port-forwarding already active"
  fi

  # Check for Android emulator
  echo ""
  log_info "Checking Android emulator..."

  EMULATOR_PATH="$HOME/Android/Sdk/emulator/emulator"
  if [[ ! -f "$EMULATOR_PATH" ]]; then
    log_error "Android emulator not found at $EMULATOR_PATH"
    exit 1
  fi

  AVDS=$($EMULATOR_PATH -list-avds)
  if [[ -z "$AVDS" ]]; then
    log_error "No Android Virtual Devices found"
    log_warning "Create one in Android Studio first"
    exit 1
  fi

  log_success "Available Android emulators:"
  echo "$AVDS" | sed 's/^/  - /'
  echo ""

  # Check if emulator is already running
  cd "$CLIENT_DIR"
  if flutter devices 2>/dev/null | grep -q "emulator"; then
    EMULATOR_ID=$(flutter devices 2>/dev/null | grep "emulator" | awk '{print $4}' | head -n1)
    log_success "Android emulator already running: $EMULATOR_ID"
  else
    FIRST_AVD=$(echo "$AVDS" | head -n1)

    read -p "Start Android emulator ($FIRST_AVD)? (y/n) [y]: " START_EMU
    START_EMU=${START_EMU:-y}

    if [[ "$START_EMU" =~ ^[Yy]$ ]]; then
      log_info "Starting Android emulator: $FIRST_AVD"
      $EMULATOR_PATH -avd "$FIRST_AVD" -no-snapshot -no-audio -gpu swiftshader_indirect >/dev/null 2>&1 &
      EMULATOR_PID=$!
      log_success "Emulator starting (PID: $EMULATOR_PID)"
      log_warning "Waiting for emulator to boot (30-60 seconds)..."

      # Wait for emulator to be ready
      for i in {1..30}; do
        sleep 2
        if flutter devices 2>/dev/null | grep -q "emulator"; then
          EMULATOR_ID=$(flutter devices 2>/dev/null | grep "emulator" | awk '{print $4}' | head -n1)
          log_success "Emulator ready: $EMULATOR_ID"
          break
        fi
      done
    else
      log_warning "Start emulator manually before testing"
      log_info "Command: $EMULATOR_PATH -avd <avd-name> &"
      EMULATOR_ID="emulator-5554"
    fi
  fi

  # Display instructions
  log_header "Testing Instructions"

  log_success "Device 1 (Alice): Linux desktop"
  echo ""
  echo -e "${YELLOW}Terminal 1 - Run Linux client:${NC}"
  echo "  cd $CLIENT_DIR"
  echo "  flutter run -d linux"

  echo ""
  log_success "Device 2 (Bob): Android emulator (${EMULATOR_ID:-emulator-5554})"
  echo ""
  echo -e "${YELLOW}Terminal 2 - Run Android client:${NC}"
  echo "  cd $CLIENT_DIR"
  echo "  flutter run -d ${EMULATOR_ID:-emulator-5554}"

  echo ""
  log_header "Testing Steps"
  echo "  1. Device 1 (Alice): Register as 'alice' - Copy User ID"
  echo "  2. Device 2 (Bob): Register as 'bob' - Copy User ID"
  echo "  3. Device 1: Navigate to Messages → Send to Bob's User ID"
  echo "  4. Device 2: Verify message received in real-time"
  echo "  5. Send replies back and forth"
  echo ""
  log_info "Full testing guide: docs/CLIENT_TESTING_GUIDE.md"
}

verify_setup() {
  log_header "Verifying Flutter Client Setup"

  check_kubectl
  check_cluster
  check_backend_services

  # Check port-forwarding
  echo ""
  log_info "Checking port-forwarding..."

  if ! lsof -i :50051 > /dev/null 2>&1; then
    log_warning "Port 50051 (auth-service) is not forwarded"
    log_info "Run: kubectl port-forward -n apps svc/auth-service 50051:50051 &"
  else
    log_success "Port 50051 (auth-service) is forwarded"
  fi

  if ! lsof -i :50052 > /dev/null 2>&1; then
    log_warning "Port 50052 (messaging-service) is not forwarded"
    log_info "Run: kubectl port-forward -n apps svc/messaging-service 50052:50052 &"
  else
    log_success "Port 50052 (messaging-service) is forwarded"
  fi

  # Test builds
  cd "$CLIENT_DIR"

  echo ""
  log_info "Testing Linux client build..."
  if flutter build linux > /tmp/flutter-linux-build.log 2>&1; then
    log_success "Linux build successful"
  else
    log_error "Linux build failed"
    cat /tmp/flutter-linux-build.log
    exit 1
  fi

  log_header "Verification Complete"
  log_success "All checks passed!"
  echo ""
  log_info "Platform-specific configuration:"
  echo "  • Android Emulator → 10.0.2.2:50051/50052"
  echo "  • Linux Desktop    → localhost:50051/50052"
  echo "  • iOS Simulator    → localhost:50051/50052"
  echo ""
  log_info "To test manually:"
  echo "  Linux:   flutter run -d linux"
  echo "  Android: flutter run -d emulator-5554"
}

# ============================================================
# Main Command Dispatcher
# ============================================================

main() {
  local COMMAND=${1:-help}

  case "$COMMAND" in
    integration)
      shift
      while getopts "d:v" opt; do
        case $opt in
          d) DEVICE="$OPTARG" ;;
          v) VERBOSE="--verbose" ;;
        esac
      done
      run_integration_tests
      ;;

    two-device)
      if [ -z "${2:-}" ]; then
        log_error "Missing device type argument"
        log_info "Usage: $0 two-device linux"
        exit 1
      fi

      DEVICE1=$2
      if [[ "$DEVICE1" != "linux" ]]; then
        log_error "Invalid device type: $DEVICE1"
        log_info "Use: linux"
        log_info "Note: Web platform has been removed for security reasons"
        exit 1
      fi

      setup_two_device_testing "$DEVICE1"
      ;;

    port-forward)
      log_header "Port-Forwarding Setup"
      check_kubectl
      check_cluster
      start_port_forwarding
      echo ""
      log_success "Port-forwarding is active"
      log_info "Press Ctrl+C to stop"

      # Keep script running
      trap stop_port_forwarding EXIT INT TERM
      while true; do sleep 1; done
      ;;

    verify)
      verify_setup
      ;;

    help|--help|-h)
      show_help
      ;;

    *)
      log_error "Unknown command: $COMMAND"
      echo ""
      log_info "Available commands:"
      echo "  integration      Run automated integration tests"
      echo "  two-device       Setup two-device manual testing (Linux + Android)"
      echo "  port-forward     Start port-forwarding only"
      echo "  verify           Verify backend and build"
      echo "  help             Show help message"
      echo ""
      log_info "Run '$0 help' for detailed usage"
      exit 1
      ;;
  esac
}

# Run main function
main "$@"
