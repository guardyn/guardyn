#!/usr/bin/env bash
set -euo pipefail

# Quick script to run Flutter on two devices for testing
# Usage: ./scripts/test_two_devices.sh [chrome|linux]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Guardyn Two-Device Testing${NC}"
echo ""

# Get device type for Device 1 (default: chrome)
DEVICE1=${1:-chrome}

# Check available devices
cd "$CLIENT_DIR"
echo -e "${YELLOW}📱 Checking available devices...${NC}"
DEVICES=$(flutter devices)

if ! echo "$DEVICES" | grep -q "emulator"; then
    echo -e "${RED}❌ No Android emulator running!${NC}"
    echo ""
    echo "Start emulator with:"
    echo -e "  ${YELLOW}\$HOME/Android/Sdk/emulator/emulator -avd Medium_Phone_API_36.1 -no-snapshot -no-audio -gpu swiftshader_indirect &${NC}"
    exit 1
fi

# Get emulator device ID
EMULATOR_ID=$(echo "$DEVICES" | grep "emulator" | awk '{print $4}' | head -n1)

echo -e "${GREEN}✅ Found emulator: $EMULATOR_ID${NC}"
echo ""

# Device 1
if [[ "$DEVICE1" == "chrome" ]]; then
    echo -e "${GREEN}🌐 Device 1 (Alice): Chrome browser${NC}"
    echo -e "${YELLOW}   Run in Terminal 1:${NC}"
    echo -e "   cd $CLIENT_DIR && flutter run -d chrome"
elif [[ "$DEVICE1" == "linux" ]]; then
    echo -e "${GREEN}🖥️  Device 1 (Alice): Linux desktop${NC}"
    echo -e "${YELLOW}   Run in Terminal 1:${NC}"
    echo -e "   cd $CLIENT_DIR && flutter run -d linux"
else
    echo -e "${RED}❌ Invalid device type: $DEVICE1${NC}"
    echo "Usage: $0 [chrome|linux]"
    exit 1
fi

echo ""
echo -e "${GREEN}📱 Device 2 (Bob): Android emulator ($EMULATOR_ID)${NC}"
echo -e "${YELLOW}   Run in Terminal 2:${NC}"
echo -e "   cd $CLIENT_DIR && flutter run -d $EMULATOR_ID"

echo ""
echo -e "${GREEN}✅ Ready to test!${NC}"
echo ""
echo -e "${YELLOW}Testing instructions:${NC}"
echo "  1. Device 1: Register as 'alice' (write down User ID)"
echo "  2. Device 2: Register as 'bob' (write down User ID)"
echo "  3. Device 1: Navigate to Messages → Send to Bob's User ID"
echo "  4. Device 2: Verify message received in real-time"
echo "  5. Send replies back and forth"
echo ""
echo -e "${YELLOW}📖 Full guide: client/MANUAL_TESTING_GUIDE.md${NC}"
