#!/usr/bin/env bash
# Clear Guardyn client data (removes corrupted E2EE sessions)
# This is useful when debugging encryption issues or after a protocol change

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🧹 Guardyn Client Data Cleanup${NC}"
echo "================================"
echo ""

# Linux client data directory
LINUX_DATA_DIR="${HOME}/.local/share/guardyn_client"

# Android emulator data directories (common locations)
ANDROID_AVD_DIR="${HOME}/.android/avd"
ANDROID_PACKAGE="com.guardyn.client"

# Function to clear Linux client data
clear_linux_data() {
    echo -e "${YELLOW}📱 Linux Client Data${NC}"

    if [[ -d "$LINUX_DATA_DIR" ]]; then
        echo "   Found: $LINUX_DATA_DIR"

        # Show contents before deletion
        echo "   Contents:"
        ls -la "$LINUX_DATA_DIR" 2>/dev/null | head -20 | sed 's/^/      /'

        read -p "   Delete this directory? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$LINUX_DATA_DIR"
            echo -e "   ${GREEN}✓ Deleted${NC}"
        else
            echo -e "   ${YELLOW}⊘ Skipped${NC}"
        fi
    else
        echo -e "   ${GREEN}✓ Not found (already clean)${NC}"
    fi
    echo ""
}

# Function to clear Android client data
clear_android_data() {
    echo -e "${YELLOW}🤖 Android Client Data${NC}"

    # Check if adb is available
    if ! command -v adb &> /dev/null; then
        echo -e "   ${YELLOW}⚠ adb not found. Install Android SDK or run 'nix develop'.${NC}"
        echo "   Manual steps for physical device or emulator:"
        echo "   1. Settings → Apps → Guardyn → Storage → Clear Data"
        echo "   2. Or uninstall and reinstall the app"
        echo ""
        return
    fi

    # Check if any device is connected
    DEVICES=$(adb devices 2>/dev/null | grep -v "List of devices" | grep -v "^$" | wc -l)

    if [[ "$DEVICES" -eq 0 ]]; then
        echo -e "   ${YELLOW}⚠ No Android devices/emulators connected${NC}"
        echo "   Start an emulator or connect a device, then run:"
        echo "   adb shell pm clear $ANDROID_PACKAGE"
        echo ""
        return
    fi

    echo "   Connected devices:"
    adb devices 2>/dev/null | grep -v "List of devices" | grep -v "^$" | sed 's/^/      /'
    echo ""

    read -p "   Clear app data on connected device(s)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Try to clear app data
        if adb shell pm clear "$ANDROID_PACKAGE" 2>/dev/null; then
            echo -e "   ${GREEN}✓ App data cleared${NC}"
        else
            echo -e "   ${YELLOW}⚠ Could not clear data (app may not be installed)${NC}"
        fi
    else
        echo -e "   ${YELLOW}⊘ Skipped${NC}"
    fi
    echo ""
}

# Function to show Web client cleanup instructions
show_web_instructions() {
    echo -e "${YELLOW}🌐 Web Client Data (Chrome/Firefox)${NC}"
    echo ""
    echo "   Web client data is stored in browser Local Storage."
    echo "   To clear it manually:"
    echo ""
    echo "   Chrome:"
    echo "   1. Open DevTools (F12)"
    echo "   2. Go to Application tab → Storage → Local Storage"
    echo "   3. Right-click on 'http://localhost:3000' → Clear"
    echo "   OR run in console: localStorage.clear()"
    echo ""
    echo "   Firefox:"
    echo "   1. Open DevTools (F12)"
    echo "   2. Go to Storage tab → Local Storage"
    echo "   3. Right-click on 'http://localhost:3000' → Delete All"
    echo ""
    echo "   Alternatively, you can use Incognito/Private mode for testing."
    echo ""
}

# Function to clear all without confirmation (for CI/scripts)
clear_all_force() {
    echo -e "${YELLOW}🗑️  Force clearing all client data...${NC}"

    # Linux
    if [[ -d "$LINUX_DATA_DIR" ]]; then
        rm -rf "$LINUX_DATA_DIR"
        echo -e "${GREEN}✓ Deleted: $LINUX_DATA_DIR${NC}"
    else
        echo -e "${GREEN}✓ Linux data already clean${NC}"
    fi

    # Android (if adb available and device connected)
    if command -v adb &> /dev/null; then
        DEVICES=$(adb devices 2>/dev/null | grep -v "List of devices" | grep -v "^$" | wc -l)
        if [[ "$DEVICES" -gt 0 ]]; then
            if adb shell pm clear "$ANDROID_PACKAGE" 2>/dev/null; then
                echo -e "${GREEN}✓ Android app data cleared${NC}"
            else
                echo -e "${YELLOW}⚠ Could not clear Android data${NC}"
            fi
        fi
    fi

    echo ""
    echo -e "${YELLOW}Note: Web client data must be cleared manually in browser.${NC}"
}

# Parse command line arguments
case "${1:-}" in
    --force|-f)
        clear_all_force
        ;;
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --force, -f    Clear all data without confirmation"
        echo "  --help, -h     Show this help message"
        echo ""
        echo "This script clears Guardyn client data including:"
        echo "  - E2EE session keys"
        echo "  - X3DH key material"
        echo "  - Cached user data"
        echo ""
        echo "Use this when:"
        echo "  - Debugging encryption issues"
        echo "  - After protocol/schema changes"
        echo "  - To test fresh key exchange"
        ;;
    *)
        clear_linux_data
        clear_android_data
        show_web_instructions
        echo -e "${GREEN}✅ Cleanup complete!${NC}"
        echo ""
        echo "Now restart your clients to generate fresh keys."
        ;;
esac
