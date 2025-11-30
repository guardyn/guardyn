#!/usr/bin/env bash
# =============================================================================
# E2E Tests for Group Chat Functionality
# =============================================================================
#
# This script runs comprehensive E2E tests for Guardyn group chat features.
#
# Prerequisites:
#   - k3d cluster running (guardyn-poc)
#   - Port-forwarding active for auth-service and messaging-service
#   - Nix development environment available
#
# Usage:
#   ./run-group-tests.sh           # Run all tests
#   ./run-group-tests.sh <test>    # Run specific test
#
# Examples:
#   ./run-group-tests.sh test_03_group_messaging
#   ./run-group-tests.sh test_09_full_group_flow
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}             Guardyn Group Chat E2E Tests                      ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check port-forwarding
check_port_forward() {
    local port=$1
    local service=$2
    if ! nc -z localhost "$port" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Port $port ($service) not forwarded${NC}"
        echo -e "${YELLOW}   Starting port-forward in background...${NC}"
        kubectl port-forward -n apps "svc/$service" "$port:$port" &>/dev/null &
        sleep 2
    fi
}

echo -e "${BLUE}Checking prerequisites...${NC}"

# Check cluster
if ! kubectl cluster-info &>/dev/null; then
    echo -e "${RED}❌ Kubernetes cluster not accessible${NC}"
    echo "   Please start the k3d cluster: just kube-create"
    exit 1
fi
echo -e "${GREEN}✅ Kubernetes cluster accessible${NC}"

# Check port-forwarding
check_port_forward 50051 auth-service
check_port_forward 50052 messaging-service

echo -e "${GREEN}✅ Port-forwarding active${NC}"
echo ""

# Run tests
cd "$PROJECT_ROOT"

TEST_FILTER="${1:-}"

if [ -n "$TEST_FILTER" ]; then
    echo -e "${BLUE}Running test: ${TEST_FILTER}${NC}"
    echo ""
    nix --extra-experimental-features 'nix-command flakes' develop --command bash -c \
        "cd backend && cargo test -p guardyn-e2e-tests --test e2e_groups $TEST_FILTER -- --nocapture"
else
    echo -e "${BLUE}Running all group tests (sequential)...${NC}"
    echo ""
    nix --extra-experimental-features 'nix-command flakes' develop --command bash -c \
        "cd backend && cargo test -p guardyn-e2e-tests --test e2e_groups -- --nocapture --test-threads=1"
fi

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                    All tests passed! ✅                        ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
else
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}                  Some tests failed ❌                          ${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
fi

exit $EXIT_CODE
