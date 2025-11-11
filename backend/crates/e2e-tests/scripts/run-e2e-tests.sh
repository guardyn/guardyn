#!/usr/bin/env bash
# E2E Test Runner for Guardyn MVP
#
# This script sets up port-forwarding and runs E2E tests

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 Starting E2E Test Runner${NC}"

# Kill any existing port-forwards
echo -e "${YELLOW}Cleaning up old port-forwards...${NC}"
pkill -f "kubectl port-forward.*auth-service" || true
pkill -f "kubectl port-forward.*messaging-service" || true
sleep 1

# Start port-forwarding
echo -e "${YELLOW}Setting up port-forwards...${NC}"
kubectl port-forward -n apps svc/auth-service 50051:50051 >/dev/null 2>&1 &
AUTH_PF_PID=$!
kubectl port-forward -n apps svc/messaging-service 50052:50052 >/dev/null 2>&1 &
MSG_PF_PID=$!

# Wait for port-forwards to be ready
sleep 3

echo -e "${GREEN}✅ Port-forwards active (Auth: $AUTH_PF_PID, Messaging: $MSG_PF_PID)${NC}"

# Cleanup function
cleanup() {
    echo -e "${YELLOW}Cleaning up...${NC}"
    kill $AUTH_PF_PID $MSG_PF_PID 2>/dev/null || true
}
trap cleanup EXIT

# Run tests
echo -e "${YELLOW}Running E2E tests...${NC}"
cd backend
nix --extra-experimental-features 'nix-command flakes' develop --command cargo test \
    -p guardyn-e2e-tests \
    --test e2e_mvp_simplified \
    -- --nocapture --test-threads=1

echo -e "${GREEN}✅ E2E tests completed${NC}"
