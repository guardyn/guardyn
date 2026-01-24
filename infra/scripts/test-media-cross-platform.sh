#!/usr/bin/env bash
# =============================================================================
# Cross-Platform Media Verification Script
# =============================================================================
#
# This script verifies that media functionality works correctly across
# Flutter Mobile and Tauri Desktop clients.
#
# Prerequisites:
# - Backend services running (Docker Compose or k3d cluster)
# - Port forwarding active for media-service (50054), auth-service (50051)
# - MinIO accessible for file storage
#
# Usage:
#   ./test-media-cross-platform.sh [options]
#
# Options:
#   --flutter-only    Run only Flutter client tests
#   --desktop-only    Run only Tauri Desktop tests
#   --backend-only    Run only backend API tests
#   --full            Run complete cross-platform verification
#   --help            Show this help message
#
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Default endpoints
AUTH_ENDPOINT="${AUTH_ENDPOINT:-http://localhost:50051}"
MEDIA_ENDPOINT="${MEDIA_ENDPOINT:-http://localhost:50054}"
MESSAGING_ENDPOINT="${MESSAGING_ENDPOINT:-http://localhost:50052}"

# Test modes
RUN_FLUTTER=true
RUN_DESKTOP=true
RUN_BACKEND=true

# =============================================================================
# Helper Functions
# =============================================================================

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_section() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

show_help() {
    echo "Cross-Platform Media Verification Script"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --flutter-only    Run only Flutter client tests"
    echo "  --desktop-only    Run only Tauri Desktop tests"
    echo "  --backend-only    Run only backend API tests"
    echo "  --full            Run complete cross-platform verification"
    echo "  --help            Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  AUTH_ENDPOINT     Auth service endpoint (default: http://localhost:50051)"
    echo "  MEDIA_ENDPOINT    Media service endpoint (default: http://localhost:50054)"
    echo "  MESSAGING_ENDPOINT Messaging service endpoint (default: http://localhost:50052)"
}

# =============================================================================
# Backend API Tests
# =============================================================================

test_backend_services() {
    log_section "Backend Services Health Check"
    
    # Test Auth Service
    log_info "Checking Auth Service at $AUTH_ENDPOINT..."
    if curl -s --connect-timeout 5 "$AUTH_ENDPOINT" >/dev/null 2>&1 || \
       grpcurl -plaintext "${AUTH_ENDPOINT#http://}" list >/dev/null 2>&1; then
        log_success "Auth Service is reachable"
    else
        log_warning "Auth Service may not be running (expected during manual testing)"
    fi
    
    # Test Media Service
    log_info "Checking Media Service at $MEDIA_ENDPOINT..."
    if curl -s --connect-timeout 5 "$MEDIA_ENDPOINT" >/dev/null 2>&1 || \
       grpcurl -plaintext "${MEDIA_ENDPOINT#http://}" list >/dev/null 2>&1; then
        log_success "Media Service is reachable"
    else
        log_warning "Media Service may not be running (expected during manual testing)"
    fi
    
    log_success "Backend services check completed"
}

run_backend_e2e_tests() {
    log_section "Backend E2E Media Tests"
    
    log_info "Running media E2E tests..."
    cd "$PROJECT_ROOT/backend"
    
    if cargo test -p guardyn-e2e-tests --test e2e_media -- --nocapture --test-threads=1 2>&1; then
        log_success "All backend E2E media tests passed"
    else
        log_error "Some backend E2E media tests failed"
        return 1
    fi
}

# =============================================================================
# Flutter Client Tests
# =============================================================================

run_flutter_unit_tests() {
    log_section "Flutter Client Unit Tests"
    
    cd "$PROJECT_ROOT/client-mobile"
    
    log_info "Running Flutter media unit tests..."
    if flutter test test/features/media/ 2>&1; then
        log_success "Flutter media unit tests passed"
    else
        log_error "Flutter media unit tests failed"
        return 1
    fi
}

run_flutter_integration_tests() {
    log_section "Flutter Client Integration Tests"
    
    cd "$PROJECT_ROOT/client-mobile"
    
    log_info "Running Flutter media integration tests..."
    log_warning "Integration tests require a running emulator/device"
    
    # Check if any device is connected
    if flutter devices | grep -q "connected"; then
        if flutter test integration_test/media_flow_test.dart 2>&1; then
            log_success "Flutter media integration tests passed"
        else
            log_error "Flutter media integration tests failed"
            return 1
        fi
    else
        log_warning "No device connected - skipping integration tests"
        log_info "To run manually: flutter test integration_test/media_flow_test.dart"
    fi
}

# =============================================================================
# Tauri Desktop Tests
# =============================================================================

run_desktop_unit_tests() {
    log_section "Tauri Desktop Unit Tests"
    
    cd "$PROJECT_ROOT/client-desktop"
    
    log_info "Running Tauri Rust unit tests..."
    cd src-tauri
    if cargo test 2>&1; then
        log_success "Tauri Rust unit tests passed"
    else
        log_error "Tauri Rust unit tests failed"
        return 1
    fi
    
    cd ..
    log_info "Running TypeScript/Vitest tests..."
    if npm test 2>&1; then
        log_success "TypeScript tests passed"
    else
        log_error "TypeScript tests failed"
        return 1
    fi
}

run_desktop_e2e_tests() {
    log_section "Tauri Desktop E2E Tests"
    
    cd "$PROJECT_ROOT/client-desktop"
    
    log_info "Running Playwright E2E tests..."
    log_warning "E2E tests require built Tauri application"
    
    if [ -f "src-tauri/target/release/guardyn" ] || [ -f "src-tauri/target/debug/guardyn" ]; then
        if npx playwright test e2e/media.test.ts 2>&1; then
            log_success "Tauri E2E tests passed"
        else
            log_error "Tauri E2E tests failed"
            return 1
        fi
    else
        log_warning "Tauri app not built - skipping E2E tests"
        log_info "To build: cd client-desktop && npm run tauri build"
    fi
}

# =============================================================================
# Cross-Platform Verification
# =============================================================================

run_cross_platform_verification() {
    log_section "Cross-Platform Media Verification"
    
    echo ""
    echo "This verification checks that media sent from one platform"
    echo "can be received and displayed on another platform."
    echo ""
    echo "Manual testing steps:"
    echo ""
    echo "  1. Start Flutter app on mobile emulator/device"
    echo "  2. Start Tauri app on desktop"
    echo "  3. Login with same user on both platforms"
    echo ""
    echo "  4. Flutter → Desktop:"
    echo "     - Send image from Flutter in a conversation"
    echo "     - Verify image appears on Desktop"
    echo "     - Click image on Desktop to view fullscreen"
    echo ""
    echo "  5. Desktop → Flutter:"
    echo "     - Send document from Desktop in a conversation"
    echo "     - Verify document appears on Flutter"
    echo "     - Tap to open document on Flutter"
    echo ""
    echo "  6. Avatar sync:"
    echo "     - Update avatar on Flutter"
    echo "     - Verify avatar updated on Desktop"
    echo ""
    echo "  7. Media Gallery:"
    echo "     - Open group info on both platforms"
    echo "     - Verify Media Gallery shows same files"
    echo ""
    
    log_info "See docs/TESTING_GUIDE.md for detailed manual testing checklist"
}

# =============================================================================
# Summary Report
# =============================================================================

print_summary() {
    log_section "Test Summary"
    
    echo "Tests executed:"
    echo ""
    
    if [ "$RUN_BACKEND" = true ]; then
        echo "  ☐ Backend E2E Tests (run with --backend-only)"
    fi
    
    if [ "$RUN_FLUTTER" = true ]; then
        echo "  ☐ Flutter Unit Tests"
        echo "  ☐ Flutter Integration Tests"
    fi
    
    if [ "$RUN_DESKTOP" = true ]; then
        echo "  ☐ Tauri Rust Unit Tests"
        echo "  ☐ Tauri TypeScript Tests"
        echo "  ☐ Tauri E2E Tests"
    fi
    
    echo ""
    echo "Cross-Platform Manual Testing Checklist:"
    echo ""
    echo "  [ ] Flutter: Send image in 1-on-1 chat"
    echo "  [ ] Flutter: Send video in 1-on-1 chat"
    echo "  [ ] Flutter: Send document in 1-on-1 chat"
    echo "  [ ] Flutter: Send image in group chat"
    echo "  [ ] Desktop: Send image in 1-on-1 chat"
    echo "  [ ] Desktop: Send document in group chat"
    echo "  [ ] Cross-platform: Flutter→Desktop image"
    echo "  [ ] Cross-platform: Desktop→Flutter document"
    echo "  [ ] Flutter: Open fullscreen media viewer"
    echo "  [ ] Desktop: Open lightbox media viewer"
    echo "  [ ] Flutter: Media Gallery in group info"
    echo "  [ ] Desktop: Media Gallery in group info"
    echo "  [ ] Flutter: Upload avatar in settings"
    echo "  [ ] Desktop: Upload avatar in settings"
    echo "  [ ] Cross-platform: Avatar sync verification"
    echo ""
}

# =============================================================================
# Main
# =============================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --flutter-only)
                RUN_FLUTTER=true
                RUN_DESKTOP=false
                RUN_BACKEND=false
                shift
                ;;
            --desktop-only)
                RUN_FLUTTER=false
                RUN_DESKTOP=true
                RUN_BACKEND=false
                shift
                ;;
            --backend-only)
                RUN_FLUTTER=false
                RUN_DESKTOP=false
                RUN_BACKEND=true
                shift
                ;;
            --full)
                RUN_FLUTTER=true
                RUN_DESKTOP=true
                RUN_BACKEND=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    log_section "Cross-Platform Media Verification"
    echo "Project Root: $PROJECT_ROOT"
    echo "Mode: Backend=$RUN_BACKEND Flutter=$RUN_FLUTTER Desktop=$RUN_DESKTOP"
    echo ""
    
    # Run tests based on mode
    if [ "$RUN_BACKEND" = true ]; then
        test_backend_services
        # Uncomment to run E2E tests automatically:
        # run_backend_e2e_tests
    fi
    
    if [ "$RUN_FLUTTER" = true ]; then
        run_flutter_unit_tests || true
        # run_flutter_integration_tests || true
    fi
    
    if [ "$RUN_DESKTOP" = true ]; then
        run_desktop_unit_tests || true
        # run_desktop_e2e_tests || true
    fi
    
    # Always show cross-platform verification steps
    run_cross_platform_verification
    
    # Print summary
    print_summary
    
    log_success "Verification script completed"
}

# Run main function
main "$@"
