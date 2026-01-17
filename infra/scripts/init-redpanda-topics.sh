#!/usr/bin/env bash
# Redpanda Topic Initialization Script
# Run this after `docker compose up` to create required topics

set -euo pipefail

REDPANDA_CONTAINER="${REDPANDA_CONTAINER:-guardyn-redpanda}"
REDPANDA_BROKER="${REDPANDA_BROKER:-localhost:19092}"

echo "=== Guardyn Redpanda Topic Initialization ==="
echo "Broker: ${REDPANDA_BROKER}"
echo ""

# Wait for Redpanda to be ready
echo "Waiting for Redpanda to be ready..."
until docker exec "${REDPANDA_CONTAINER}" rpk cluster health 2>/dev/null | grep -q "Healthy"; do
    echo "  Waiting..."
    sleep 2
done
echo "Redpanda is ready!"
echo ""

# Function to create topic if it doesn't exist
create_topic() {
    local topic=$1
    local partitions=$2
    local retention_ms=$3
    local description=$4

    echo "Creating topic: ${topic}"
    echo "  Partitions: ${partitions}, Retention: $((retention_ms / 86400000)) days"
    
    docker exec "${REDPANDA_CONTAINER}" rpk topic create "${topic}" \
        --partitions "${partitions}" \
        --config retention.ms="${retention_ms}" \
        --config cleanup.policy=delete \
        2>/dev/null || echo "  Topic already exists"
}

echo "=== Creating Topics ==="
echo ""

# Messages topic - main message stream
# 12 partitions for good parallelism, 7 days retention
create_topic "guardyn.messages" 12 604800000 "Encrypted messages between users"

# Presence topic - online status updates
# 6 partitions, 1 day retention (status is ephemeral)
create_topic "guardyn.presence" 6 86400000 "User presence updates (online/offline/typing)"

# Notifications topic - push notification events
# 6 partitions, 3 days retention
create_topic "guardyn.notifications" 6 259200000 "Push notification events for FCM/APNs"

# Media topic - media upload/processing events
# 6 partitions, 7 days retention
create_topic "guardyn.media" 6 604800000 "Media upload and processing events"

# Key exchange topic - key bundle updates
# 3 partitions, 30 days retention (keys need longer retention)
create_topic "guardyn.keys" 3 2592000000 "Key bundle updates and prekey replenishment"

# Group events topic - MLS group operations
# 6 partitions, 14 days retention
create_topic "guardyn.groups" 6 1209600000 "MLS group operations (create/add/remove/update)"

# Audit topic - security audit events (optional, for compliance)
# 3 partitions, 90 days retention
create_topic "guardyn.audit" 3 7776000000 "Security audit events"

echo ""
echo "=== Topic List ==="
docker exec "${REDPANDA_CONTAINER}" rpk topic list

echo ""
echo "=== Topic Details ==="
for topic in guardyn.messages guardyn.presence guardyn.notifications guardyn.media guardyn.keys guardyn.groups guardyn.audit; do
    echo "--- ${topic} ---"
    docker exec "${REDPANDA_CONTAINER}" rpk topic describe "${topic}" 2>/dev/null | head -10
    echo ""
done

echo "=== Initialization Complete ==="
echo ""
echo "Redpanda Console: http://localhost:8088"
echo "Kafka API: localhost:19092"
echo "Schema Registry: localhost:18081"
