#!/usr/bin/env bash
# User management script for Guardyn
# Provides commands to list, delete users and clear all data
#
# Usage:
#   ./user-management.sh list              - List all registered users
#   ./user-management.sh delete <username> - Delete specific user and all their data
#   ./user-management.sh delete-all        - Delete ALL users and data (destructive!)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# gRPC service endpoints (via port-forward)
AUTH_HOST="${AUTH_HOST:-localhost:50051}"
MESSAGING_HOST="${MESSAGING_HOST:-localhost:50052}"

# ScyllaDB access
SCYLLA_NAMESPACE="${SCYLLA_NAMESPACE:-data}"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check required tools
check_dependencies() {
    local missing=()

    # Check grpcurl - try both direct and via nix
    if ! command -v grpcurl &> /dev/null; then
        # Try to use nix shell
        if command -v nix &> /dev/null; then
            log_info "grpcurl not found, will use nix shell"
            GRPCURL_CMD="nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#grpcurl --command grpcurl"
        else
            missing+=("grpcurl")
        fi
    else
        GRPCURL_CMD="grpcurl"
    fi

    if ! command -v kubectl &> /dev/null; then
        missing+=("kubectl")
    fi

    if ! command -v nc &> /dev/null; then
        # nc is usually available, but check anyway
        NC_CMD="true"  # Skip nc check if not available
    else
        NC_CMD="nc"
    fi

    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing[*]}"
        log_info "Install grpcurl via: nix shell nixpkgs#grpcurl"
        log_info "Install kubectl via: nix shell nixpkgs#kubectl"
        exit 1
    fi
}

# Check if port-forwards are running
check_port_forwards() {
    if ! nc -z localhost 50051 2>/dev/null; then
        log_error "Auth service port-forward not running (port 50051)"
        log_info "Start with: just port-forward"
        exit 1
    fi
}

# Get ScyllaDB pod name
get_scylla_pod() {
    kubectl get pods -n "${SCYLLA_NAMESPACE}" -l app.kubernetes.io/name=scylla -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo ""
}

# Execute CQL command
exec_cql() {
    local query="$1"
    local scylla_pod
    scylla_pod=$(get_scylla_pod)

    if [ -z "$scylla_pod" ]; then
        log_warn "ScyllaDB pod not found, skipping ScyllaDB cleanup"
        return 1
    fi

    kubectl exec -n "${SCYLLA_NAMESPACE}" "${scylla_pod}" -c scylla -- cqlsh -e "$query" 2>/dev/null
}

# List all users using SearchUsers RPC
list_users() {
    log_info "Fetching registered users..."
    echo ""

    local scylla_pod
    scylla_pod=$(get_scylla_pod)

    local pd_pod
    pd_pod=$(kubectl get pods -n data -l app=pd -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " REGISTERED USERS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Query ScyllaDB for users from conversations (has username!)
    if [ -n "$scylla_pod" ]; then
        # Method 1: Get unique users from conversations (best - has usernames)
        log_info "Fetching users with usernames from conversations..."
        echo ""

        # Get other_user_id + other_username pairs from conversations and deduplicate
        local users_result
        users_result=$(kubectl exec -n "${SCYLLA_NAMESPACE}" "${scylla_pod}" -c scylla -- cqlsh -e "
            SELECT other_user_id, other_username FROM guardyn.conversations LIMIT 1000;
        " 2>/dev/null || echo "")

        if [ -n "$users_result" ] && [[ ! "$users_result" == *"Unable"* ]] && [[ ! "$users_result" == *"unconfigured"* ]] && [[ ! "$users_result" == *"Invalid"* ]]; then
            # Check if there are any UUID lines (actual data)
            local uuid_lines
            uuid_lines=$(echo "$users_result" | grep -E "^\s*[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}" || true)

            if [ -n "$uuid_lines" ]; then
                echo "👤 Users (user_id | username):"
                echo "────────────────────────────────────────────────────────────────────"
                echo "$uuid_lines" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $1); gsub(/^[ \t]+|[ \t]+$/, "", $2); print $1 " | " $2}' | sort -u
                echo "────────────────────────────────────────────────────────────────────"
                echo ""
            else
                echo "📭 No users found in conversations table (database may be empty)"
                echo ""
            fi
        fi

        # Also show unique user_id (the owners of conversations)
        log_info "Fetching all unique user IDs..."
        echo ""
        local owners_result
        owners_result=$(kubectl exec -n "${SCYLLA_NAMESPACE}" "${scylla_pod}" -c scylla -- cqlsh -e "
            SELECT DISTINCT user_id FROM guardyn.conversations;
        " 2>/dev/null || echo "")

        if [ -n "$owners_result" ] && [[ ! "$owners_result" == *"Unable"* ]] && [[ ! "$owners_result" == *"unconfigured"* ]]; then
            local owner_lines
            owner_lines=$(echo "$owners_result" | grep -E "^\s*[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}" || true)

            if [ -n "$owner_lines" ]; then
                echo "📋 All user IDs with conversations:"
                echo "$owner_lines" | awk '{gsub(/^[ \t]+|[ \t]+$/, "", $1); print $1}' | sort -u
                local user_count
                user_count=$(echo "$owner_lines" | wc -l | tr -d ' ')
                echo ""
                echo "Total: $user_count users"
                echo ""
            else
                echo "📭 No conversation owners found"
                echo ""
            fi
        fi

        # Message count
        log_info "Message statistics..."
        local msg_count
        msg_count=$(exec_cql "SELECT COUNT(*) FROM guardyn.messages;" 2>/dev/null || echo "")
        if [ -n "$msg_count" ]; then
            echo "📊 Total messages: $(echo "$msg_count" | grep -E "[0-9]+" | head -1 | tr -d ' ')"
            echo ""
        fi
    else
        log_warn "ScyllaDB pod not found"
    fi

    # Method 4: TiKV scan (if available)
    if [ -n "$pd_pod" ]; then
        local tikv_pod
        tikv_pod=$(kubectl get pods -n data -l app=tikv -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

        if [ -n "$tikv_pod" ]; then
            log_info "Attempting TiKV username scan..."

            # Try direct scan using tikv-ctl raw-scan
            # tikv-ctl scan requires "z" prefix for internal key format
            # Use --host for network access (--data-dir causes lock conflict with running TiKV)
            local scan_result
            scan_result=$(kubectl exec -n data "$tikv_pod" -- /tikv-ctl --host 127.0.0.1:20160 scan --from 'z/' --limit 50 2>/dev/null || echo "scan_error")

            if [ -n "$scan_result" ] && [[ "$scan_result" != *"error"* ]]; then
                echo ""
                echo "🔑 TiKV keys found:"
                echo "$scan_result"
            else
                echo "📭 No keys found in TiKV scan (database may be empty)"
            fi
        fi
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📝 Notes:"
    echo "  - Presence shows users who have been online"
    echo "  - Messages shows users who sent at least one message"
    echo "  - For full user list with usernames, use grpcurl with a valid token:"
    echo ""
    echo "    grpcurl -plaintext -d '{\"access_token\":\"<TOKEN>\",\"query\":\"\",\"limit\":100}' \\"
    echo "      localhost:50051 guardyn.auth.AuthService/SearchUsers"
    echo ""
}

# Delete a specific user
delete_user() {
    local username="$1"

    if [ -z "$username" ]; then
        log_error "Username is required"
        echo "Usage: $0 delete <username>"
        exit 1
    fi

    log_warn "This will permanently delete user '$username' and ALL their data!"
    echo "Data to be deleted:"
    echo "  - User profile and authentication data (TiKV)"
    echo "  - All devices and keys (TiKV)"
    echo "  - All sessions (TiKV)"
    echo "  - All sent and received messages (ScyllaDB)"
    echo "  - All media files metadata (ScyllaDB)"
    echo "  - Presence data (ScyllaDB)"
    echo ""
    read -p "Are you sure you want to continue? (yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        log_info "Operation cancelled"
        exit 0
    fi

    echo ""
    log_info "Deleting user: $username"

    # Step 1: Get user_id from username via TiKV
    log_info "Looking up user_id for username: $username"

    local tikv_pod
    tikv_pod=$(kubectl get pods -n data -l app=tikv -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

    # For now, we need to get user_id from the username mapping
    # This requires direct TiKV access or using the auth service

    # Try to use grpcurl to get user profile
    # Note: GetUserProfile requires user_id, not username
    # We need to either:
    # 1. Implement admin endpoints in auth-service
    # 2. Access TiKV directly
    # 3. Use DeleteAccount RPC (requires password)

    log_info "Attempting to find user in TiKV..."

    # Direct key lookup approach - read the username mapping key
    # Key format: /users/username/<username> -> user_id

    local user_id=""

    # Method 1: Try to use grpcurl SearchUsers to find the user
    # This requires a valid token, which we might not have for admin operations
    # Skipping this method for now

    # Method 2: Query ScyllaDB for messages from this sender to get user_id pattern
    local scylla_result
    scylla_result=$(exec_cql "SELECT sender_user_id FROM guardyn.messages WHERE sender_user_id LIKE '%' LIMIT 1 ALLOW FILTERING;" 2>/dev/null || echo "")

    log_warn "Direct username->user_id lookup requires TiKV client access."
    echo ""
    echo "To delete a user, you need the user_id (UUID)."
    echo "If you know the user_id, you can proceed with manual deletion:"
    echo ""
    echo "Manual deletion steps:"
    echo ""
    echo "1. Delete from TiKV (run these in tikv-ctl or via application):"
    echo "   - /users/<user_id>/profile"
    echo "   - /users/username/$username"
    echo "   - /users/<user_id>/identity_key"
    echo "   - /devices/<user_id>/* (all device keys)"
    echo "   - /sessions/user/<user_id>/* (all sessions)"
    echo "   - /mls/user/<user_id>/* (MLS key packages)"
    echo ""
    echo "2. Delete from ScyllaDB (run via cqlsh):"
    echo "   DELETE FROM guardyn.messages WHERE sender_user_id = '<user_id>';"
    echo "   DELETE FROM guardyn.group_messages WHERE sender_user_id = '<user_id>';"
    echo "   DELETE FROM guardyn.media_metadata WHERE uploader_user_id = '<user_id>';"
    echo "   DELETE FROM guardyn.presence WHERE user_id = '<user_id>';"
    echo ""

    # If we have user_id, proceed with deletion
    if [ -n "$user_id" ]; then
        delete_user_data "$user_id" "$username"
    fi
}

# Delete user data given user_id and username
delete_user_data() {
    local user_id="$1"
    local username="$2"

    log_info "Deleting data for user_id: $user_id"

    # Delete from ScyllaDB first
    log_info "Cleaning ScyllaDB data..."

    # Delete messages where user is sender
    exec_cql "DELETE FROM guardyn.messages WHERE sender_user_id = '$user_id';" 2>/dev/null && \
        log_success "Deleted sent messages" || log_warn "Failed to delete messages (table may not exist)"

    # Delete group messages where user is sender
    exec_cql "DELETE FROM guardyn.group_messages WHERE sender_user_id = '$user_id';" 2>/dev/null && \
        log_success "Deleted group messages" || log_warn "Failed to delete group messages"

    # Delete media metadata
    exec_cql "DELETE FROM guardyn.media_metadata WHERE uploader_user_id = '$user_id';" 2>/dev/null && \
        log_success "Deleted media metadata" || log_warn "Failed to delete media metadata"

    # Delete presence
    exec_cql "DELETE FROM guardyn.presence WHERE user_id = '$user_id';" 2>/dev/null && \
        log_success "Deleted presence data" || log_warn "Failed to delete presence"

    log_info "ScyllaDB cleanup complete"

    # TiKV cleanup would require tikv-client or DeleteAccount RPC
    log_warn "TiKV cleanup requires DeleteAccount RPC or direct tikv-client access"
    log_info "Use the auth-service DeleteAccount RPC with user's password for full cleanup"

    echo ""
    log_success "User data deletion initiated for: $username ($user_id)"
}

# Delete ALL users and data
delete_all() {
    log_error "⚠️  DANGER: This will DELETE ALL user data!"
    echo ""
    echo "This operation will:"
    echo "  - Truncate ALL messages in ScyllaDB"
    echo "  - Truncate ALL conversations in ScyllaDB"
    echo "  - Truncate ALL group messages in ScyllaDB"
    echo "  - Delete ALL user data from TiKV (users, devices, sessions, keys)"
    echo ""
    echo "This action is IRREVERSIBLE!"
    echo ""
    read -p "Type 'DELETE ALL DATA' to confirm: " confirm

    if [ "$confirm" != "DELETE ALL DATA" ]; then
        log_info "Operation cancelled"
        exit 0
    fi

    echo ""
    log_warn "Proceeding with full data wipe..."

    # Step 1: Truncate ScyllaDB tables
    log_info "Truncating ScyllaDB tables..."

    local scylla_pod
    scylla_pod=$(get_scylla_pod)

    if [ -n "$scylla_pod" ]; then
        # Core tables that exist
        exec_cql "TRUNCATE guardyn.messages;" && \
            log_success "Truncated messages table" || log_warn "Failed to truncate messages"

        exec_cql "TRUNCATE guardyn.conversations;" && \
            log_success "Truncated conversations table" || log_warn "Failed to truncate conversations"

        exec_cql "TRUNCATE guardyn.group_messages;" && \
            log_success "Truncated group_messages table" || log_warn "Failed to truncate group_messages"

        # Optional tables (may or may not exist depending on deployment)
        exec_cql "TRUNCATE guardyn.media_metadata;" 2>/dev/null && \
            log_success "Truncated media_metadata table" || true

        exec_cql "TRUNCATE guardyn.presence;" 2>/dev/null && \
            log_success "Truncated presence table" || true

        exec_cql "TRUNCATE guardyn.call_history;" 2>/dev/null && \
            log_success "Truncated call_history table" || true

        exec_cql "TRUNCATE guardyn.groups;" 2>/dev/null && \
            log_success "Truncated groups table" || true

        exec_cql "TRUNCATE guardyn.group_members;" 2>/dev/null && \
            log_success "Truncated group_members table" || true

        exec_cql "TRUNCATE guardyn.notifications;" 2>/dev/null && \
            log_success "Truncated notifications table" || true

        exec_cql "TRUNCATE guardyn.analytics_events;" 2>/dev/null && \
            log_success "Truncated analytics_events table" || true

        log_success "ScyllaDB cleanup complete"
    else
        log_warn "ScyllaDB pod not found, skipping ScyllaDB cleanup"
    fi

    # Step 2: Delete all TiKV user data
    log_info "Deleting TiKV user data..."

    # TiKV cleanup is challenging because tikv-ctl is not available in standard pods
    # We need to use alternative approaches:

    # Option A: Scale down TiKV, delete PVC data, scale up (most reliable but destructive)
    # Option B: Use raw delete through PD API
    # Option C: Restart services (clears in-memory caches, but data persists)

    local pd_pod
    pd_pod=$(kubectl get pods -n data -l app=pd -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

    if [ -n "$pd_pod" ]; then
        log_info "TiKV PD pod found: $pd_pod"

        # Method 1: Delete TiKV PVC data (nuclear but effective)
        echo ""
        log_warn "TiKV data cleanup options:"
        echo ""
        echo "For COMPLETE TiKV data removal, the most reliable method is:"
        echo ""
        echo "Option 1 - Delete and recreate TiKV PVCs (recommended for dev):"
        echo "  kubectl delete pvc -n data -l app=tikv"
        echo "  kubectl delete pod -n data -l app=tikv"
        echo "  # Wait for new pods with fresh storage"
        echo ""
        echo "Option 2 - Scale down, clear, scale up:"
        echo "  kubectl scale statefulset tikv -n data --replicas=0"
        echo "  kubectl delete pvc -n data -l app=tikv"
        echo "  kubectl scale statefulset tikv -n data --replicas=1"
        echo ""

        # Try to restart services anyway to clear caches
        log_info "Restarting backend services to clear caches..."

        # Restart auth-service
        kubectl rollout restart deployment/auth-service -n apps 2>/dev/null && \
            log_success "Restarted auth-service" || log_warn "Failed to restart auth-service"

        # Restart messaging-service
        kubectl rollout restart deployment/messaging-service -n apps 2>/dev/null && \
            log_success "Restarted messaging-service" || log_warn "Failed to restart messaging-service"

        # Restart presence-service
        kubectl rollout restart deployment/presence-service -n apps 2>/dev/null && \
            log_success "Restarted presence-service" || log_warn "Failed to restart presence-service"

        # Ask user if they want to delete TiKV data completely
        echo ""
        read -p "Do you want to DELETE TiKV PVCs for complete cleanup? (yes/no): " tikv_confirm

        if [ "$tikv_confirm" == "yes" ]; then
            log_warn "Deleting TiKV data..."

            # Scale down TiKV statefulset first
            kubectl scale statefulset tikv -n data --replicas=0 2>/dev/null && \
                log_success "Scaled down TiKV" || log_warn "Failed to scale down TiKV"

            # Wait for pods to terminate
            log_info "Waiting for TiKV pods to terminate..."
            kubectl wait --for=delete pod/tikv-0 -n data --timeout=60s 2>/dev/null || true

            # Delete TiKV PVCs
            kubectl delete pvc data-tikv-0 -n data 2>/dev/null && \
                log_success "Deleted TiKV PVC" || log_warn "TiKV PVC not found or already deleted"

            # Optionally delete PD data too for complete reset
            read -p "Also delete PD (Placement Driver) data? (yes/no): " pd_confirm
            if [ "$pd_confirm" == "yes" ]; then
                kubectl scale statefulset pd -n data --replicas=0 2>/dev/null && \
                    log_success "Scaled down PD" || log_warn "Failed to scale down PD"
                kubectl wait --for=delete pod/pd-0 -n data --timeout=60s 2>/dev/null || true
                kubectl delete pvc data-pd-0 -n data 2>/dev/null && \
                    log_success "Deleted PD PVC" || log_warn "PD PVC not found"
            fi

            # Scale back up
            log_info "Scaling TiKV and PD back up..."
            kubectl scale statefulset pd -n data --replicas=1 2>/dev/null || true
            sleep 5
            kubectl scale statefulset tikv -n data --replicas=1 2>/dev/null || true

            log_info "Waiting for TiKV cluster to be ready..."
            kubectl wait --for=condition=Ready pod/pd-0 -n data --timeout=120s 2>/dev/null && \
                log_success "PD is ready" || log_warn "PD not ready yet"
            kubectl wait --for=condition=Ready pod/tikv-0 -n data --timeout=120s 2>/dev/null && \
                log_success "TiKV is ready" || log_warn "TiKV not ready yet"

            log_success "TiKV data cleared and cluster restarted!"
        else
            log_info "Skipping TiKV PVC deletion"
            echo ""
            log_warn "TiKV data will persist. For complete cleanup, run manually:"
            echo "  kubectl scale statefulset tikv -n data --replicas=0"
            echo "  kubectl delete pvc data-tikv-0 -n data"
            echo "  kubectl scale statefulset tikv -n data --replicas=1"
        fi
    else
        log_warn "TiKV PD pod not found"
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_success "Data cleanup completed!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Next steps:"
    echo "  - Wait for services to restart: kubectl get pods -n apps -w"
    echo "  - Verify cleanup: just list-users"
    echo ""
}

# Main entry point
main() {
    local command="${1:-help}"

    check_dependencies

    case "$command" in
        list)
            list_users
            ;;
        delete)
            check_port_forwards
            delete_user "${2:-}"
            ;;
        delete-all)
            delete_all
            ;;
        help|--help|-h)
            echo "Guardyn User Management"
            echo ""
            echo "Usage:"
            echo "  $0 list              - List all registered users"
            echo "  $0 delete <username> - Delete specific user and all their data"
            echo "  $0 delete-all        - Delete ALL users and data (destructive!)"
            echo ""
            echo "Environment variables:"
            echo "  AUTH_HOST         - Auth service address (default: localhost:50051)"
            echo "  SCYLLA_NAMESPACE  - ScyllaDB namespace (default: data)"
            echo ""
            echo "Prerequisites:"
            echo "  - Port forwards running: just port-forward"
            echo "  - grpcurl installed: nix shell nixpkgs#grpcurl"
            echo "  - kubectl configured for the cluster"
            ;;
        *)
            log_error "Unknown command: $command"
            echo "Run '$0 help' for usage"
            exit 1
            ;;
    esac
}

main "$@"
