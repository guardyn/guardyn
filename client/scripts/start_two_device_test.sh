#!/usr/bin/env bash
set -euo pipefail

# Guardyn Two-Device Testing Script
# This script helps set up testing environment with Chrome + Android emulator

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Guardyn Two-Device Testing Setup${NC}"
echo ""

# Check if backend services are running
echo -e "${YELLOW}📋 Checking backend services...${NC}"
if ! kubectl get pods -n apps &>/dev/null; then
    echo -e "${RED}❌ Kubernetes cluster not accessible. Run 'just kube-create' first.${NC}"
    exit 1
fi

AUTH_PODS=$(kubectl get pods -n apps -l app=auth-service --no-headers 2>/dev/null | wc -l)
MSG_PODS=$(kubectl get pods -n apps -l app=messaging-service --no-headers 2>/dev/null | wc -l)

if [[ $AUTH_PODS -lt 1 ]] || [[ $MSG_PODS -lt 1 ]]; then
    echo -e "${RED}❌ Backend services not deployed. Run deployment first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Backend services running (auth: $AUTH_PODS, messaging: $MSG_PODS)${NC}"
echo ""

# Check if port-forwarding is already running
echo -e "${YELLOW}🔌 Checking port-forwarding...${NC}"
AUTH_PORT_CHECK=$(lsof -i :50051 -t 2>/dev/null || true)
MSG_PORT_CHECK=$(lsof -i :50052 -t 2>/dev/null || true)

if [[ -n "$AUTH_PORT_CHECK" ]] && [[ -n "$MSG_PORT_CHECK" ]]; then
    echo -e "${GREEN}✅ Port-forwarding already active${NC}"
else
    echo -e "${YELLOW}⚙️  Starting port-forwarding in background...${NC}"
    
    # Kill existing port-forwards if any
    pkill -f "kubectl port-forward.*auth-service" 2>/dev/null || true
    pkill -f "kubectl port-forward.*messaging-service" 2>/dev/null || true
    
    # Start new port-forwards
    kubectl port-forward -n apps svc/auth-service 50051:50051 >/dev/null 2>&1 &
    AUTH_PF_PID=$!
    kubectl port-forward -n apps svc/messaging-service 50052:50052 >/dev/null 2>&1 &
    MSG_PF_PID=$!
    
    # Wait for ports to be ready
    sleep 2
    
    echo -e "${GREEN}✅ Port-forwarding started (PIDs: $AUTH_PF_PID, $MSG_PF_PID)${NC}"
    echo -e "${YELLOW}   (To stop: pkill -f 'kubectl port-forward')${NC}"
fi

echo ""
echo -e "${GREEN}📱 Device Setup Options:${NC}"
echo ""
echo -e "${YELLOW}Option A: Chrome + Android Emulator (Recommended)${NC}"
echo "  Device 1 (Alice): Chrome browser"
echo "  Device 2 (Bob): Android emulator"
echo ""
echo -e "${YELLOW}Option B: Linux Desktop + Android Emulator${NC}"
echo "  Device 1 (Alice): Linux desktop app"
echo "  Device 2 (Bob): Android emulator"
echo ""

# Detect available emulators
EMULATOR_PATH="$HOME/Android/Sdk/emulator/emulator"
if [[ ! -f "$EMULATOR_PATH" ]]; then
    echo -e "${RED}❌ Android emulator not found at $EMULATOR_PATH${NC}"
    exit 1
fi

AVDS=$($EMULATOR_PATH -list-avds)
if [[ -z "$AVDS" ]]; then
    echo -e "${RED}❌ No Android Virtual Devices found. Create one in Android Studio first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Available Android emulators:${NC}"
echo "$AVDS" | sed 's/^/  - /'
echo ""

# Ask user which option
read -p "Choose option (A/B) [A]: " CHOICE
CHOICE=${CHOICE:-A}

if [[ "$CHOICE" =~ ^[Aa]$ ]]; then
    # Option A: Chrome + Android
    echo ""
    echo -e "${GREEN}🌐 Starting Device 1 (Alice) on Chrome...${NC}"
    echo "   Open a new terminal and run:"
    echo -e "   ${YELLOW}cd client && flutter run -d chrome${NC}"
    echo ""
    
    # Get first AVD
    FIRST_AVD=$(echo "$AVDS" | head -n1)
    
    read -p "Press Enter to start Android emulator ($FIRST_AVD) for Device 2 (Bob)..."
    
    echo -e "${GREEN}📱 Starting Android emulator: $FIRST_AVD${NC}"
    $EMULATOR_PATH -avd "$FIRST_AVD" >/dev/null 2>&1 &
    EMULATOR_PID=$!
    echo -e "${GREEN}✅ Emulator starting (PID: $EMULATOR_PID)${NC}"
    echo ""
    echo -e "${YELLOW}⏳ Waiting for emulator to boot (this may take 30-60 seconds)...${NC}"
    
    # Wait for emulator to be ready
    sleep 10
    flutter devices | grep -q "emulator" && echo -e "${GREEN}✅ Emulator ready!${NC}" || echo -e "${YELLOW}⏳ Still booting...${NC}"
    
    echo ""
    echo -e "${GREEN}📱 Starting Device 2 (Bob) on Android...${NC}"
    echo "   Open another terminal and run:"
    EMULATOR_DEVICE=$(flutter devices 2>/dev/null | grep "emulator" | awk '{print $4}' | head -n1)
    if [[ -n "$EMULATOR_DEVICE" ]]; then
        echo -e "   ${YELLOW}cd client && flutter run -d $EMULATOR_DEVICE${NC}"
    else
        echo -e "   ${YELLOW}cd client && flutter run -d <emulator-id>${NC}"
    fi
    
elif [[ "$CHOICE" =~ ^[Bb]$ ]]; then
    # Option B: Linux + Android
    echo ""
    echo -e "${GREEN}🖥️  Starting Device 1 (Alice) on Linux Desktop...${NC}"
    echo "   Open a new terminal and run:"
    echo -e "   ${YELLOW}cd client && flutter run -d linux${NC}"
    echo ""
    
    # Get first AVD
    FIRST_AVD=$(echo "$AVDS" | head -n1)
    
    read -p "Press Enter to start Android emulator ($FIRST_AVD) for Device 2 (Bob)..."
    
    echo -e "${GREEN}📱 Starting Android emulator: $FIRST_AVD${NC}"
    $EMULATOR_PATH -avd "$FIRST_AVD" >/dev/null 2>&1 &
    EMULATOR_PID=$!
    echo -e "${GREEN}✅ Emulator starting (PID: $EMULATOR_PID)${NC}"
    echo ""
    echo -e "${YELLOW}⏳ Waiting for emulator to boot...${NC}"
    
    sleep 10
    flutter devices | grep -q "emulator" && echo -e "${GREEN}✅ Emulator ready!${NC}" || echo -e "${YELLOW}⏳ Still booting...${NC}"
    
    echo ""
    echo -e "${GREEN}📱 Starting Device 2 (Bob) on Android...${NC}"
    echo "   Open another terminal and run:"
    EMULATOR_DEVICE=$(flutter devices 2>/dev/null | grep "emulator" | awk '{print $4}' | head -n1)
    if [[ -n "$EMULATOR_DEVICE" ]]; then
        echo -e "   ${YELLOW}cd client && flutter run -d $EMULATOR_DEVICE${NC}"
    else
        echo -e "   ${YELLOW}cd client && flutter run -d <emulator-id>${NC}"
    fi
else
    echo -e "${RED}Invalid choice. Exiting.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo -e "${YELLOW}📖 Testing Instructions:${NC}"
echo "  1. Device 1 (Alice): Register user 'alice'"
echo "  2. Device 2 (Bob): Register user 'bob'"
echo "  3. Device 1: Navigate to Messages → Send message to Bob's User ID"
echo "  4. Device 2: Verify message received"
echo ""
echo -e "${YELLOW}📚 Full testing guide: client/MANUAL_TESTING_GUIDE.md${NC}"
echo ""
