#!/usr/bin/env bash
#
# Run two-client integration test (Android + Chrome)
#
# This script orchestrates integration testing between two different Flutter clients:
# - Device 1 (Alice): Android emulator
# - Device 2 (Bob): Chrome browser
#
# Prerequisites:
# - Backend services running (kubectl get pods -n apps)
# - Port-forwarding active (localhost:50051, localhost:50052, localhost:18080)
# - Envoy proxy running (localhost:18080) for Chrome gRPC-Web
# - ChromeDriver running (localhost:4444) for Chrome integration tests
# - Android emulator running
# - Chrome browser available
#
# Usage:
#   ./scripts/run-two-client-test.sh

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# PID files for background processes
ANDROID_TEST_PID=""
CHROME_TEST_PID=""
AUTH_PF_PID=""
MESSAGING_PF_PID=""
ENVOY_PF_PID=""

log_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
  echo -e "${GREEN}✅ $1${NC}"
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

cleanup() {
  log_info "Cleaning up..."

  # Kill test processes
  if [ -n "${ANDROID_TEST_PID:-}" ]; then
    kill "$ANDROID_TEST_PID" 2>/dev/null || true
  fi

  if [ -n "${CHROME_TEST_PID:-}" ]; then
    kill "$CHROME_TEST_PID" 2>/dev/null || true
  fi

  # Note: Don't kill port-forwards - they might be used by other processes
  log_success "Cleanup complete"
}

trap cleanup EXIT INT TERM

# ============================================================
# Prerequisites Check
# ============================================================

log_header "Two-Client Integration Test"
log_info "Testing Android <-> Chrome messaging"

cd "$CLIENT_DIR"

# Check kubectl
if ! command -v kubectl &> /dev/null; then
  log_error "kubectl not found"
  exit 1
fi

# Check cluster
if ! kubectl cluster-info &> /dev/null; then
  log_error "Kubernetes cluster not accessible"
  exit 1
fi

# Check backend services
log_info "Checking backend services..."

AUTH_PODS=$(kubectl get pods -n apps -l app=auth-service --no-headers 2>/dev/null | wc -l)
MESSAGING_PODS=$(kubectl get pods -n apps -l app=messaging-service --no-headers 2>/dev/null | wc -l)

if [ "$AUTH_PODS" -eq 0 ]; then
  log_error "Auth service not running"
  exit 1
fi

if [ "$MESSAGING_PODS" -eq 0 ]; then
  log_error "Messaging service not running"
  exit 1
fi

log_success "Auth service: $AUTH_PODS pods"
log_success "Messaging service: $MESSAGING_PODS pods"

# Check port-forwarding
log_info "Checking port-forwarding..."

if ! lsof -i :50051 > /dev/null 2>&1; then
  log_error "Port 50051 not forwarded (auth-service)"
  log_info "Run: kubectl port-forward -n apps svc/auth-service 50051:50051 &"
  exit 1
fi

if ! lsof -i :50052 > /dev/null 2>&1; then
  log_error "Port 50052 not forwarded (messaging-service)"
  log_info "Run: kubectl port-forward -n apps svc/messaging-service 50052:50052 &"
  exit 1
fi

log_success "Port-forwarding active"

# Check Envoy proxy for Chrome
log_info "Checking Envoy proxy..."

if ! lsof -i :18080 > /dev/null 2>&1; then
  log_error "Port 18080 not forwarded (Envoy proxy)"
  log_info "Run: kubectl port-forward -n apps svc/guardyn-envoy 18080:8080 &"
  exit 1
fi

log_success "Envoy proxy active (port 18080)"

# Check ChromeDriver for Chrome integration tests
log_info "Checking ChromeDriver..."

if ! lsof -i :4444 > /dev/null 2>&1; then
  log_info "ChromeDriver not running, attempting to start..."
  
  # Try to find chromedriver
  CHROMEDRIVER_PATH=""
  if [ -f "$CLIENT_DIR/chromedriver/linux-142.0.7444.175/chromedriver-linux64/chromedriver" ]; then
    CHROMEDRIVER_PATH="$CLIENT_DIR/chromedriver/linux-142.0.7444.175/chromedriver-linux64/chromedriver"
  elif command -v chromedriver &> /dev/null; then
    CHROMEDRIVER_PATH=$(command -v chromedriver)
  fi
  
  if [ -z "$CHROMEDRIVER_PATH" ]; then
    log_error "ChromeDriver not found"
    log_info "Please install ChromeDriver or place it in client/chromedriver/"
    log_info "Download from: https://googlechromelabs.github.io/chrome-for-testing/"
    exit 1
  fi
  
  # Start ChromeDriver in background
  "$CHROMEDRIVER_PATH" --port=4444 > /tmp/chromedriver.log 2>&1 &
  CHROMEDRIVER_PID=$!
  
  # Wait for ChromeDriver to be ready
  sleep 2
  
  if curl -s http://localhost:4444/status | jq -r '.value.ready' 2>/dev/null | grep -q "true"; then
    log_success "ChromeDriver started (PID: $CHROMEDRIVER_PID, port: 4444)"
  else
    log_error "ChromeDriver failed to start"
    log_info "Check log: /tmp/chromedriver.log"
    exit 1
  fi
else
  log_success "ChromeDriver active (port 4444)"
fi

# Check Android emulator
log_info "Checking Android emulator..."

FLUTTER_DEVICES=$(flutter devices 2>/dev/null)
if ! echo "$FLUTTER_DEVICES" | grep -q "emulator"; then
  log_error "No Android emulator running"
  log_info "Start emulator: \$HOME/Android/Sdk/emulator/emulator -avd <avd-name> &"
  exit 1
fi

EMULATOR_ID=$(echo "$FLUTTER_DEVICES" | grep "emulator" | grep -oP 'emulator-\d+' | head -n1)
log_success "Android emulator: $EMULATOR_ID"

# Check Chrome
if ! echo "$FLUTTER_DEVICES" | grep -q "chrome"; then
  log_error "Chrome not available"
  exit 1
fi

log_success "Chrome available"

# ============================================================
# Run Tests in Parallel
# ============================================================

log_header "Running Tests"

log_info "Starting Android test (Alice)..."

# Run Android test in background
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/two_client_messaging_test.dart \
  -d "$EMULATOR_ID" \
  --dart-define=TEST_PLATFORM=android \
  > /tmp/android_test.log 2>&1 &

ANDROID_TEST_PID=$!
log_success "Android test started (PID: $ANDROID_TEST_PID)"

# Wait a bit for Android test to start
sleep 3

log_info "Starting Chrome test (Bob)..."

# Run Chrome test in background
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/two_client_messaging_test.dart \
  -d chrome \
  --dart-define=TEST_PLATFORM=chrome \
  > /tmp/chrome_test.log 2>&1 &

CHROME_TEST_PID=$!
log_success "Chrome test started (PID: $CHROME_TEST_PID)"

# ============================================================
# Monitor Test Progress
# ============================================================

log_info "Monitoring tests (this may take 60-90 seconds)..."
echo ""

# Tail both logs in parallel
tail -f /tmp/android_test.log | sed 's/^/  [Android] /' &
TAIL_ANDROID_PID=$!

tail -f /tmp/chrome_test.log | sed 's/^/  [Chrome] /' &
TAIL_CHROME_PID=$!

# Wait for both tests to complete
ANDROID_EXIT=0
CHROME_EXIT=0

wait "$ANDROID_TEST_PID" || ANDROID_EXIT=$?
wait "$CHROME_TEST_PID" || CHROME_EXIT=$?

# Kill tail processes
kill "$TAIL_ANDROID_PID" 2>/dev/null || true
kill "$TAIL_CHROME_PID" 2>/dev/null || true

# ============================================================
# Results
# ============================================================

log_header "Test Results"

if [ $ANDROID_EXIT -eq 0 ]; then
  log_success "Android test: PASSED"
else
  log_error "Android test: FAILED (exit code: $ANDROID_EXIT)"
  echo ""
  echo "Android test log:"
  tail -n 50 /tmp/android_test.log
fi

echo ""

if [ $CHROME_EXIT -eq 0 ]; then
  log_success "Chrome test: PASSED"
else
  log_error "Chrome test: FAILED (exit code: $CHROME_EXIT)"
  echo ""
  echo "Chrome test log:"
  tail -n 50 /tmp/chrome_test.log
fi

echo ""

if [ $ANDROID_EXIT -eq 0 ] && [ $CHROME_EXIT -eq 0 ]; then
  log_success "ALL TESTS PASSED ✅"
  exit 0
else
  log_error "SOME TESTS FAILED ❌"
  log_info "Full logs:"
  log_info "  Android: /tmp/android_test.log"
  log_info "  Chrome: /tmp/chrome_test.log"
  exit 1
fi
