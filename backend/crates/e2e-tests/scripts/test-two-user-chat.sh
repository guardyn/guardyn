#!/usr/bin/env bash
# Two-User Chat E2E Test Runner
#
# This script runs the automated test for messaging between two users.
# It verifies:
# - User registration (Alice and Bob)
# - Message sending from Alice to Bob
# - Message retrieval by Bob
# - Message content verification
#
# Usage:
#   ./scripts/test-two-user-chat.sh
#   ./scripts/test-two-user-chat.sh --all   # Run all messaging tests

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Two-User Chat E2E Test Runner${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check for required services
echo -e "${YELLOW}📋 Checking service connectivity...${NC}"

check_port() {
    local port=$1
    local service=$2
    if nc -z localhost "$port" 2>/dev/null; then
        echo -e "  ${GREEN}✅ $service (port $port)${NC}"
        return 0
    else
        echo -e "  ${RED}❌ $service (port $port) - NOT REACHABLE${NC}"
        return 1
    fi
}

SERVICES_OK=true
check_port 50051 "Auth Service" || SERVICES_OK=false
check_port 50052 "Messaging Service" || SERVICES_OK=false

if [ "$SERVICES_OK" = false ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Some services are not reachable. Setting up port-forwarding...${NC}"
    
    # Kill existing port-forwards
    pkill -f "kubectl port-forward.*auth-service" 2>/dev/null || true
    pkill -f "kubectl port-forward.*messaging-service" 2>/dev/null || true
    sleep 1
    
    # Start port-forwarding
    kubectl port-forward -n apps svc/auth-service 50051:50051 >/dev/null 2>&1 &
    AUTH_PF_PID=$!
    kubectl port-forward -n apps svc/messaging-service 50052:50052 >/dev/null 2>&1 &
    MSG_PF_PID=$!
    
    # Wait for port-forwards
    sleep 3
    
    # Cleanup on exit
    trap "kill $AUTH_PF_PID $MSG_PF_PID 2>/dev/null || true" EXIT
    
    echo -e "${GREEN}✅ Port-forwards established${NC}"
fi

echo ""
echo -e "${YELLOW}🧪 Running Two-User Chat Tests...${NC}"
echo ""

cd "$PROJECT_ROOT"

if [ "${1:-}" = "--all" ]; then
    # Run all messaging-related tests one by one
    echo -e "${BLUE}Running all messaging tests:${NC}"
    echo "  - test_02_send_and_receive_message"
    echo "  - test_03_mark_messages_as_read"
    echo "  - test_04_delete_message"
    echo "  - test_06_offline_message_delivery"
    echo ""
    
    FAILED=0
    for TEST in test_02_send_and_receive_message test_03_mark_messages_as_read test_04_delete_message test_06_offline_message_delivery; do
        echo -e "${YELLOW}▶️  Running $TEST${NC}"
        if ! nix --extra-experimental-features 'nix-command flakes' develop --command bash -c \
            "cd backend && cargo test -p guardyn-e2e-tests --test e2e_mvp_simplified $TEST -- --nocapture" 2>&1; then
            echo -e "${RED}❌ $TEST FAILED${NC}"
            FAILED=$((FAILED + 1))
        fi
        echo ""
    done
    
    if [ $FAILED -gt 0 ]; then
        echo -e "${RED}❌ $FAILED test(s) failed${NC}"
        exit 1
    fi
else
    # Run just the basic two-user chat test
    echo -e "${BLUE}Running basic two-user chat test:${NC}"
    echo "  - test_02_send_and_receive_message"
    echo ""
    
    nix --extra-experimental-features 'nix-command flakes' develop --command bash -c \
        "cd backend && cargo test -p guardyn-e2e-tests --test e2e_mvp_simplified \
        test_02_send_and_receive_message \
        -- --nocapture"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ Two-User Chat Test Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
