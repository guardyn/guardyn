#!/usr/bin/env bash
# ============================================================================
# Desktop Auth E2E Test Runner
#
# Runs end-to-end authentication tests for the Tauri desktop client.
#
# Prerequisites:
#   - Backend services running (docker compose -f docker-compose.dev.yml up -d)
#   - Node.js dependencies installed (npm install)
#   - Playwright browsers installed (npx playwright install)
#
# Usage:
#   ./scripts/run-auth-tests.sh [options]
#
# Options:
#   --headed      Run tests in headed mode (visible browser)
#   --ui          Open Playwright UI for interactive debugging
#   --debug       Enable Playwright debug mode
#   --update      Update snapshots
#   --grep PATTERN Run only tests matching pattern
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Default options
HEADED=""
UI=""
DEBUG=""
UPDATE=""
GREP=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --headed)
            HEADED="--headed"
            shift
            ;;
        --ui)
            UI="--ui"
            shift
            ;;
        --debug)
            DEBUG="--debug"
            shift
            ;;
        --update)
            UPDATE="--update-snapshots"
            shift
            ;;
        --grep)
            GREP="--grep $2"
            shift 2
            ;;
        *)
            warn "Unknown option: $1"
            shift
            ;;
    esac
done

cd "$PROJECT_ROOT"

info "Running Desktop Auth E2E Tests"
info "==============================="
echo ""

# Check dependencies
if ! command -v npm &> /dev/null; then
    error "npm is not installed"
    exit 1
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    warn "node_modules not found, installing dependencies..."
    npm install
fi

# Check if @playwright/test is installed
if ! npm list @playwright/test &> /dev/null; then
    warn "Installing @playwright/test..."
    npm install -D @playwright/test
fi

# Check if Playwright browsers are installed
if ! npx playwright --version &> /dev/null; then
    warn "Installing Playwright browsers (this may take a moment)..."
    npx playwright install chromium
fi

# Check if dev server is running on port 1420 (Vite default for Tauri)
DEV_SERVER_PORT=1420
if ! nc -z localhost $DEV_SERVER_PORT 2>/dev/null; then
    warn "Dev server not running on port $DEV_SERVER_PORT"
    info "Starting dev server in background..."
    npm run dev &
    DEV_PID=$!

    # Wait for dev server to be ready (max 60 seconds)
    info "Waiting for dev server to start..."
    for i in {1..60}; do
        if nc -z localhost $DEV_SERVER_PORT 2>/dev/null; then
            success "Dev server is ready!"
            break
        fi
        if [ $i -eq 60 ]; then
            error "Dev server failed to start within 60 seconds"
            kill $DEV_PID 2>/dev/null || true
            exit 1
        fi
        sleep 1
    done

    # Cleanup function
    cleanup() {
        info "Stopping dev server..."
        kill $DEV_PID 2>/dev/null || true
    }
    trap cleanup EXIT
else
    info "Dev server already running on port $DEV_SERVER_PORT"
fi

# Check if dev server is needed
if [ -z "$UI" ] && [ -z "$HEADED" ]; then
    info "Running auth tests in headless mode..."
else
    info "Running auth tests in interactive mode..."
fi

# Build command
CMD="npx playwright test e2e/auth.test.ts"

if [ -n "$HEADED" ]; then
    CMD="$CMD $HEADED"
fi

if [ -n "$UI" ]; then
    CMD="$CMD $UI"
fi

if [ -n "$DEBUG" ]; then
    CMD="$CMD $DEBUG"
fi

if [ -n "$UPDATE" ]; then
    CMD="$CMD $UPDATE"
fi

if [ -n "$GREP" ]; then
    CMD="$CMD $GREP"
fi

info "Executing: $CMD"
echo ""

# Run tests
if eval "$CMD"; then
    echo ""
    success "All auth E2E tests passed!"
    exit 0
else
    echo ""
    error "Some auth E2E tests failed"
    info "Run with --ui for interactive debugging"
    info "Run with --headed to see browser actions"
    exit 1
fi
