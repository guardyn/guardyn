#!/usr/bin/env bash
#
# Quick Two-Client Test Setup
#
# This is a simplified version that helps you manually test
# two clients without full automation.
#
# Usage:
#   ./scripts/quick-two-client-setup.sh

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

log_header() {
  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}$1${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

log_header "Quick Two-Client Test Setup"

# Start port-forwarding
log_info "Setting up port-forwarding..."

# Kill existing port-forwards
pkill -f "port-forward.*auth-service" 2>/dev/null || true
pkill -f "port-forward.*messaging-service" 2>/dev/null || true
pkill -f "port-forward.*guardyn-envoy" 2>/dev/null || true

sleep 1

# Start new port-forwards
kubectl port-forward -n apps svc/auth-service 50051:50051 > /tmp/pf-auth.log 2>&1 &
AUTH_PID=$!

kubectl port-forward -n apps svc/messaging-service 50052:50052 > /tmp/pf-messaging.log 2>&1 &
MESSAGING_PID=$!

kubectl port-forward -n apps svc/guardyn-envoy 8080:8080 > /tmp/pf-envoy.log 2>&1 &
ENVOY_PID=$!

sleep 3

log_success "Port-forwarding started:"
log_success "  Auth (50051): PID $AUTH_PID"
log_success "  Messaging (50052): PID $MESSAGING_PID"
log_success "  Envoy (8080): PID $ENVOY_PID"

# Check emulator
log_header "Device Setup"

EMULATOR_COUNT=$(flutter devices 2>/dev/null | grep -c "emulator" || echo "0")

if [ "$EMULATOR_COUNT" -eq "0" ]; then
  log_info "No Android emulator running"
  log_info "Start one with: \$HOME/Android/Sdk/emulator/emulator -avd <name> &"
elif [ "$EMULATOR_COUNT" -eq "1" ]; then
  EMULATOR_ID=$(flutter devices 2>/dev/null | grep "emulator" | awk '{print $4}')
  log_success "Found 1 emulator: $EMULATOR_ID"
  log_info "For two-device testing, you can use:"
  log_info "  Device 1: $EMULATOR_ID (Alice)"
  log_info "  Device 2: Chrome browser (Bob)"
else
  log_success "Found $EMULATOR_COUNT emulators"
  flutter devices 2>/dev/null | grep "emulator"
fi

# Instructions
log_header "Manual Testing Steps"

echo -e "${YELLOW}DEVICE 1 (Alice - Android):${NC}"
echo "  1. Open Terminal 1"
echo "  2. cd client/"
echo "  3. flutter run -d emulator-5554"
echo "  4. Register as: alice_test"
echo "  5. Go to Messages"
echo ""

echo -e "${YELLOW}DEVICE 2 (Bob - Chrome):${NC}"
echo "  1. Open Terminal 2"
echo "  2. cd client/"
echo "  3. flutter run -d chrome --web-port 8081"
echo "  4. Register as: bob_test"
echo "  5. Go to Messages"
echo ""

echo -e "${YELLOW}TEST THE MESSAGING:${NC}"
echo "  1. Alice: Search for bob_test → Start conversation"
echo "  2. Alice: Send message 'Hello from Android'"
echo "  3. Bob: Should see message from alice_test"
echo "  4. Bob: Reply 'Hello from Chrome'"
echo "  5. Alice: Should see Bob's reply"
echo ""

log_success "Setup complete! Follow the steps above."
echo ""
log_info "To stop port-forwarding:"
echo "  kill $AUTH_PID $MESSAGING_PID $ENVOY_PID"
