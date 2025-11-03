#!/usr/bin/env bash
# FoundationDB schema initialization script

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FDB_CLUSTER_FILE="${FDB_CLUSTER_FILE:-/var/fdb/fdb.cluster}"

echo "Initializing FoundationDB schema for Guardyn..."

# Wait for FoundationDB to be ready
echo "Waiting for FoundationDB cluster..."
until fdbcli --exec "status" --cluster-file="${FDB_CLUSTER_FILE}" > /dev/null 2>&1; do
  echo "  FoundationDB not ready, retrying in 5s..."
  sleep 5
done

echo "FoundationDB cluster is ready!"

# Create directory structure (subspaces)
# Note: FoundationDB doesn't require explicit schema creation
# but we document the keyspace structure here

cat << 'EOF'
FoundationDB Keyspace Structure:
---------------------------------
/users/<user_id>/profile
/users/<user_id>/identity_key
/users/username/<username>

/devices/<user_id>/<device_id>
/devices/<user_id>/<device_id>/pre_keys/<key_id>
/devices/<user_id>/<device_id>/one_time_keys/<key_id>

/sessions/<session_token>
/sessions/user/<user_id>/<session_token>

/delivery/<recipient_user_id>/<message_id>
EOF

echo ""
echo "Schema structure documented. FoundationDB uses dynamic keyspaces."
echo "No explicit schema creation needed - keys will be created on write."

# Verify cluster status
echo ""
echo "Cluster status:"
fdbcli --exec "status minimal" --cluster-file="${FDB_CLUSTER_FILE}"

echo ""
echo "✅ FoundationDB initialization complete!"
