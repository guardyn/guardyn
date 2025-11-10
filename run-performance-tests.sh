#!/usr/bin/env bash
# run-performance-tests.sh - Run k6 load tests for Guardyn services
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🚀 Guardyn Performance Tests${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if k6 is available
if ! command -v k6 &> /dev/null; then
    echo -e "${RED}❌ k6 not found. Please install k6 or use Nix environment.${NC}"
    echo -e "${YELLOW}Run: nix --extra-experimental-features 'nix-command flakes' develop${NC}"
    exit 1
fi

echo -e "\n${YELLOW}📋 Prerequisites:${NC}"
echo -e "1. k3d cluster running: ${GREEN}$(kubectl cluster-info &>/dev/null && echo '✅' || echo '❌')${NC}"
echo -e "2. Auth service: ${GREEN}$(kubectl get pods -n apps -l app=auth-service --no-headers 2>/dev/null | grep -c Running || echo '0') pods${NC}"
echo -e "3. Messaging service: ${GREEN}$(kubectl get pods -n apps -l app=messaging-service --no-headers 2>/dev/null | grep -c Running || echo '0') pods${NC}"

# Port-forward setup
echo -e "\n${YELLOW}🔧 Setting up port forwarding...${NC}"

# Kill existing port-forwards
pkill -f "port-forward.*auth-service" 2>/dev/null || true
pkill -f "port-forward.*messaging-service" 2>/dev/null || true
sleep 2

# Start port-forwards in background
kubectl port-forward -n apps svc/auth-service 50051:50051 &>/dev/null &
AUTH_PF_PID=$!
kubectl port-forward -n apps svc/messaging-service 50052:50052 &>/dev/null &
MESSAGING_PF_PID=$!

# Wait for port-forwards to be ready
echo -e "${YELLOW}Waiting for port-forwards...${NC}"
sleep 3

# Check if port-forwards are working
if ! lsof -Pi :50051 -sTCP:LISTEN -t &>/dev/null; then
    echo -e "${RED}❌ Auth service port-forward failed${NC}"
    exit 1
fi

if ! lsof -Pi :50052 -sTCP:LISTEN -t &>/dev/null; then
    echo -e "${RED}❌ Messaging service port-forward failed${NC}"
    kill $AUTH_PF_PID 2>/dev/null || true
    exit 1
fi

echo -e "${GREEN}✅ Port-forwards ready${NC}"
echo -e "   Auth: localhost:50051"
echo -e "   Messaging: localhost:50052"

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}🧹 Cleaning up...${NC}"
    kill $AUTH_PF_PID 2>/dev/null || true
    kill $MESSAGING_PF_PID 2>/dev/null || true
    echo -e "${GREEN}✅ Cleanup complete${NC}"
}
trap cleanup EXIT INT TERM

# Change to performance test directory
cd "$(dirname "$0")/backend/crates/e2e-tests/performance"

# Test selection
TEST_TYPE="${1:-combined}"

case "$TEST_TYPE" in
    auth)
        echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}🔐 Running Auth Service Load Test${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        k6 run --vus 50 --duration 5m auth-load-test.js
        ;;
    messaging)
        echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}💬 Running Messaging Service Load Test${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        k6 run --vus 50 --duration 5m messaging-load-test.js
        ;;
    combined|*)
        echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}🎯 Running Combined Load Test${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        k6 run --vus 50 --duration 5m combined-load-test.js
        ;;
esac

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Performance tests completed${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Show results file if it exists
if [ -f "performance-results.json" ]; then
    echo -e "\n${YELLOW}📊 Results saved to: performance-results.json${NC}"
fi
