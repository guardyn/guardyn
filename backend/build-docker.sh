#!/usr/bin/env bash
# Build Docker images for Guardyn backend services
# Usage: ./build-docker.sh [service-name]
#   service-name: auth-service | guardyn-messaging-service | guardyn-media-service | all

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Build a single service
build_service() {
    local service_name=$1
    local image_tag=$2
    
    log_info "Building Docker image for ${service_name}..."
    log_info "Image tag: ${image_tag}"
    
    cd "$PROJECT_ROOT"
    
    if docker build \
        --build-arg SERVICE_NAME="${service_name}" \
        -t "${image_tag}" \
        -f backend/Dockerfile \
        .; then
        log_success "Successfully built ${image_tag}"
        return 0
    else
        log_error "Failed to build ${service_name}"
        return 1
    fi
}

# Main build logic
main() {
    local service="${1:-all}"
    
    log_info "Starting Docker build process..."
    log_info "Requested service: ${service}"
    
    case "$service" in
        auth-service)
            build_service "auth-service" "guardyn-auth-service:latest"
            ;;
        
        messaging-service|guardyn-messaging-service)
            build_service "guardyn-messaging-service" "guardyn-messaging-service:latest"
            ;;
        
        media-service|guardyn-media-service)
            build_service "guardyn-media-service" "guardyn-media-service:latest"
            ;;
        
        presence-service|guardyn-presence-service)
            build_service "guardyn-presence-service" "guardyn-presence-service:latest"
            ;;
        
        notification-service|guardyn-notification-service)
            build_service "guardyn-notification-service" "guardyn-notification-service:latest"
            ;;
        
        all)
            log_info "Building all services..."
            local failed_services=()
            
            # Build each service
            build_service "auth-service" "guardyn-auth-service:latest" || failed_services+=("auth-service")
            build_service "guardyn-messaging-service" "guardyn-messaging-service:latest" || failed_services+=("messaging-service")
            build_service "guardyn-media-service" "guardyn-media-service:latest" || failed_services+=("media-service")
            build_service "guardyn-presence-service" "guardyn-presence-service:latest" || failed_services+=("presence-service")
            build_service "guardyn-notification-service" "guardyn-notification-service:latest" || failed_services+=("notification-service")
            
            # Report results
            if [ ${#failed_services[@]} -eq 0 ]; then
                log_success "All services built successfully!"
            else
                log_error "Failed to build: ${failed_services[*]}"
                exit 1
            fi
            ;;
        
        *)
            log_error "Unknown service: ${service}"
            echo ""
            echo "Usage: $0 [service-name]"
            echo ""
            echo "Available services:"
            echo "  auth-service                - Authentication service"
            echo "  messaging-service          - Messaging service"
            echo "  media-service              - Media service"
            echo "  presence-service           - Presence service"
            echo "  notification-service       - Notification service"
            echo "  all                        - Build all services"
            exit 1
            ;;
    esac
}

main "$@"
