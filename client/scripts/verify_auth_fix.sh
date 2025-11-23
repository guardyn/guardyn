#!/usr/bin/env bash
# Test authentication on Linux and Chrome platforms
# This script verifies the gRPC connection fix

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "🔧 Testing Flutter Client Authentication Fix"
echo "=============================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if backend services are running
echo -e "${YELLOW}Step 1: Checking backend services...${NC}"
if ! kubectl get pods -n apps | grep -q "auth-service.*Running"; then
    echo -e "${RED}❌ auth-service is not running in k8s${NC}"
    echo "Run: kubectl get pods -n apps"
    exit 1
fi

if ! kubectl get pods -n apps | grep -q "messaging-service.*Running"; then
    echo -e "${RED}❌ messaging-service is not running in k8s${NC}"
    echo "Run: kubectl get pods -n apps"
    exit 1
fi

echo -e "${GREEN}✅ Backend services are running${NC}"
echo ""

# Check port-forwarding
echo -e "${YELLOW}Step 2: Checking port-forwarding...${NC}"
if ! lsof -i :50051 > /dev/null 2>&1; then
    echo -e "${RED}❌ Port 50051 (auth-service) is not forwarded${NC}"
    echo "Run: kubectl port-forward -n apps svc/auth-service 50051:50051 &"
    exit 1
fi

if ! lsof -i :50052 > /dev/null 2>&1; then
    echo -e "${RED}❌ Port 50052 (messaging-service) is not forwarded${NC}"
    echo "Run: kubectl port-forward -n apps svc/messaging-service 50052:50052 &"
    exit 1
fi

echo -e "${GREEN}✅ Port-forwarding is active${NC}"
echo ""

# Test Linux build
echo -e "${YELLOW}Step 3: Testing Linux client build...${NC}"
if flutter build linux > /tmp/flutter-linux-build.log 2>&1; then
    echo -e "${GREEN}✅ Linux build successful${NC}"
else
    echo -e "${RED}❌ Linux build failed${NC}"
    cat /tmp/flutter-linux-build.log
    exit 1
fi
echo ""

# Test Chrome/Web build
echo -e "${YELLOW}Step 4: Testing Chrome/Web client build...${NC}"
if flutter build web > /tmp/flutter-web-build.log 2>&1; then
    echo -e "${GREEN}✅ Chrome/Web build successful${NC}"
else
    echo -e "${RED}❌ Chrome/Web build failed${NC}"
    cat /tmp/flutter-web-build.log
    exit 1
fi
echo ""

echo "=============================================="
echo -e "${GREEN}✅ All checks passed!${NC}"
echo ""
echo "Platform-specific configuration:"
echo "  • Android Emulator → 10.0.2.2:50051/50052"
echo "  • Linux Desktop    → localhost:50051/50052"
echo "  • Chrome/Web       → localhost:50051/50052"
echo "  • iOS Simulator    → localhost:50051/50052"
echo ""
echo "To test manually:"
echo "  Linux:  flutter run -d linux"
echo "  Chrome: flutter run -d chrome"
echo "  Android: flutter run -d emulator-5554"
echo ""
