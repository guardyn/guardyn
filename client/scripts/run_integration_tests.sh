#!/usr/bin/env bash
#
# Integration Test Runner for Guardyn Messaging
#
# This script:
# 1. Checks backend services are running
# 2. Sets up port-forwarding
# 3. Runs Flutter integration tests
# 4. Cleans up after completion
#
# Usage:
#   ./scripts/run_integration_tests.sh [options]
#
# Options:
#   -d DEVICE    Device to run tests on (default: first available)
#   -v           Verbose output
#   -h           Show this help message
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default options
DEVICE=""
VERBOSE=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Parse command line arguments
while getopts "d:vh" opt; do
  case $opt in
    d)
      DEVICE="$OPTARG"
      ;;
    v)
      VERBOSE="--verbose"
      ;;
    h)
      head -n 20 "$0" | grep "^#" | sed 's/^# //'
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

echo -e "${BLUE}🚀 Guardyn Integration Test Runner${NC}\n"

# ============================================================
# Step 1: Check prerequisites
# ============================================================

echo -e "${BLUE}📋 Checking prerequisites...${NC}"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
  echo -e "${RED}❌ kubectl not found. Please install kubectl.${NC}"
  exit 1
fi

# Check if k3d cluster is running
if ! kubectl cluster-info &> /dev/null; then
  echo -e "${RED}❌ Kubernetes cluster not accessible.${NC}"
  echo -e "${YELLOW}   Run: just kube-create && just kube-bootstrap${NC}"
  exit 1
fi

echo -e "${GREEN}✅ kubectl connected${NC}"

# Check if backend services are deployed
echo -e "${BLUE}🔍 Checking backend services...${NC}"

AUTH_PODS=$(kubectl get pods -n apps -l app=auth-service --no-headers 2>/dev/null | wc -l)
MESSAGING_PODS=$(kubectl get pods -n apps -l app=messaging-service --no-headers 2>/dev/null | wc -l)

if [ "$AUTH_PODS" -eq 0 ]; then
  echo -e "${RED}❌ Auth service not deployed${NC}"
  echo -e "${YELLOW}   Run: just k8s-deploy auth${NC}"
  exit 1
fi

if [ "$MESSAGING_PODS" -eq 0 ]; then
  echo -e "${RED}❌ Messaging service not deployed${NC}"
  echo -e "${YELLOW}   Run: just k8s-deploy messaging${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Auth service: $AUTH_PODS pods${NC}"
echo -e "${GREEN}✅ Messaging service: $MESSAGING_PODS pods${NC}"

# Check pod readiness
echo -e "${BLUE}⏳ Waiting for pods to be ready...${NC}"

if ! kubectl wait --for=condition=ready pod -n apps -l app=auth-service --timeout=60s &>/dev/null; then
  echo -e "${RED}❌ Auth service pods not ready${NC}"
  kubectl get pods -n apps -l app=auth-service
  exit 1
fi

if ! kubectl wait --for=condition=ready pod -n apps -l app=messaging-service --timeout=60s &>/dev/null; then
  echo -e "${RED}❌ Messaging service pods not ready${NC}"
  kubectl get pods -n apps -l app=messaging-service
  exit 1
fi

echo -e "${GREEN}✅ All pods ready${NC}\n"

# ============================================================
# Step 2: Setup port-forwarding
# ============================================================

echo -e "${BLUE}🔌 Setting up port-forwarding...${NC}"

# Kill any existing port-forwards on these ports
lsof -ti:50051 | xargs kill -9 2>/dev/null || true
lsof -ti:50052 | xargs kill -9 2>/dev/null || true

# Start port-forwarding in background
kubectl port-forward -n apps svc/auth-service 50051:50051 > /dev/null 2>&1 &
AUTH_PF_PID=$!

kubectl port-forward -n apps svc/messaging-service 50052:50052 > /dev/null 2>&1 &
MESSAGING_PF_PID=$!

# Wait for port-forwards to be ready
sleep 2

# Verify port-forwards are working
if ! lsof -i:50051 > /dev/null 2>&1; then
  echo -e "${RED}❌ Auth service port-forward failed${NC}"
  exit 1
fi

if ! lsof -i:50052 > /dev/null 2>&1; then
  echo -e "${RED}❌ Messaging service port-forward failed${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Port-forwarding active${NC}"
echo -e "${GREEN}   Auth service: localhost:50051${NC}"
echo -e "${GREEN}   Messaging service: localhost:50052${NC}\n"

# Cleanup function
cleanup() {
  echo -e "\n${BLUE}🧹 Cleaning up...${NC}"
  
  if [ -n "${AUTH_PF_PID:-}" ]; then
    kill "$AUTH_PF_PID" 2>/dev/null || true
    echo -e "${GREEN}✅ Stopped auth service port-forward${NC}"
  fi
  
  if [ -n "${MESSAGING_PF_PID:-}" ]; then
    kill "$MESSAGING_PF_PID" 2>/dev/null || true
    echo -e "${GREEN}✅ Stopped messaging service port-forward${NC}"
  fi
  
  echo -e "${GREEN}✅ Cleanup complete${NC}"
}

# Register cleanup on script exit
trap cleanup EXIT INT TERM

# ============================================================
# Step 3: Run integration tests
# ============================================================

echo -e "${BLUE}🧪 Running integration tests...${NC}\n"

cd "$CLIENT_DIR"

# Determine device if not specified
if [ -z "$DEVICE" ]; then
  DEVICE=$(flutter devices 2>/dev/null | grep -E "emulator|chrome" | head -n 1 | awk '{print $2}' || echo "")
  if [ -z "$DEVICE" ]; then
    echo -e "${YELLOW}⚠️  No device specified and none detected${NC}"
    echo -e "${YELLOW}   Available devices:${NC}"
    flutter devices
    exit 1
  fi
  echo -e "${BLUE}📱 Using device: $DEVICE${NC}\n"
fi

# Run tests
if flutter test integration_test/messaging_two_device_test.dart -d "$DEVICE" $VERBOSE; then
  echo -e "\n${GREEN}✅ Integration tests PASSED${NC}"
  EXIT_CODE=0
else
  echo -e "\n${RED}❌ Integration tests FAILED${NC}"
  EXIT_CODE=1
fi

# ============================================================
# Step 4: Display results
# ============================================================

echo -e "\n${BLUE}📊 Test Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $EXIT_CODE -eq 0 ]; then
  echo -e "${GREEN}Status: PASSED ✅${NC}"
else
  echo -e "${RED}Status: FAILED ❌${NC}"
fi

echo -e "${BLUE}Device: $DEVICE${NC}"
echo -e "${BLUE}Backend: k3d cluster${NC}"
echo -e "${BLUE}Auth service: localhost:50051${NC}"
echo -e "${BLUE}Messaging service: localhost:50052${NC}"

echo -e "\n${BLUE}📝 Next Steps:${NC}"
if [ $EXIT_CODE -eq 0 ]; then
  echo -e "${GREEN}1. Review test output above${NC}"
  echo -e "${GREEN}2. Check for any warnings or notes${NC}"
  echo -e "${GREEN}3. Proceed to manual testing if needed${NC}"
  echo -e "${GREEN}   See: client/MANUAL_TESTING_GUIDE.md${NC}"
else
  echo -e "${RED}1. Review error messages above${NC}"
  echo -e "${RED}2. Check backend logs:${NC}"
  echo -e "${YELLOW}   kubectl logs -n apps deployment/auth-service${NC}"
  echo -e "${YELLOW}   kubectl logs -n apps deployment/messaging-service${NC}"
  echo -e "${RED}3. Verify backend health:${NC}"
  echo -e "${YELLOW}   kubectl get pods -n apps${NC}"
fi

exit $EXIT_CODE
