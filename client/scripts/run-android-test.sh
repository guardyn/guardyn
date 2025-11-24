#!/usr/bin/env bash
#
# Run Android-only integration test
#
# Prerequisites:
# - Backend services running
# - Port-forwarding active (50051, 50052, 18080)
# - Android emulator running

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

cd "$CLIENT_DIR"

# Check emulator
log_info "Checking Android emulator..."
FLUTTER_DEVICES=$(flutter devices 2>/dev/null || echo "")
EMULATOR_ID=$(echo "$FLUTTER_DEVICES" | grep -oP 'emulator-\d+' | head -1 || echo "")

if [ -z "$EMULATOR_ID" ]; then
  log_error "No Android emulator found"
  exit 1
fi

log_success "Android emulator: $EMULATOR_ID"

# Setup adb reverse for port forwarding (emulator localhost -> host)
log_info "Setting up adb reverse port forwarding..."
adb -s "$EMULATOR_ID" reverse tcp:50051 tcp:50051
adb -s "$EMULATOR_ID" reverse tcp:50052 tcp:50052
log_success "Port forwarding configured"

# Run test
log_info "Starting Android test (Alice)..."
flutter drive \
  --target=integration_test/two_client_messaging_test.dart \
  --driver=test_driver/integration_test.dart \
  --dart-define=TEST_PLATFORM=android \
  --dart-define=GRPC_HOST=localhost \
  -d "$EMULATOR_ID"

echo ""
if [ $? -eq 0 ]; then
  log_success "TEST PASSED ✅"
else
  log_error "TEST FAILED ❌"
  exit 1
fi
