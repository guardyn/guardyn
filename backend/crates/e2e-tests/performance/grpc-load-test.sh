#!/usr/bin/env bash
# Guardyn gRPC Load Testing Script
# Uses grpcurl for actual gRPC calls with concurrent load
#
# Usage: ./grpc-load-test.sh [concurrent_users] [duration_seconds]
#
# Prerequisites:
#   - grpcurl: go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
#   - Services running on localhost

set -euo pipefail

CONCURRENT=${1:-10}
DURATION=${2:-60}
AUTH_PORT=${AUTH_PORT:-50051}
MSG_PORT=${MSG_PORT:-50052}
PROTO_DIR="$(cd "$(dirname "$0")/../../../proto" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🚀 Guardyn gRPC Load Test${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  📍 Auth Service:      localhost:${AUTH_PORT}"
echo -e "  📍 Messaging Service: localhost:${MSG_PORT}"
echo -e "  👥 Concurrent Users:  ${CONCURRENT}"
echo -e "  ⏱️  Duration:          ${DURATION}s"
echo -e "  📁 Proto Dir:         ${PROTO_DIR}"
echo ""

# Check if grpcurl is available
if ! command -v grpcurl &> /dev/null; then
    echo -e "${RED}❌ grpcurl not found. Install with:${NC}"
    echo "   go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest"
    echo ""
    echo -e "${YELLOW}📊 Running simpler concurrent test instead...${NC}"
    echo ""
    
    # Fallback to parallel curl testing
    RESULTS_DIR="/tmp/guardyn-loadtest-$$"
    mkdir -p "$RESULTS_DIR"
    
    echo "Testing Auth Service health..."
    
    # Simple concurrent registration test
    TEST_COUNT=$((CONCURRENT * 5))
    SUCCESS=0
    FAILED=0
    TOTAL_TIME=0
    
    echo -e "${BLUE}Running ${TEST_COUNT} registration requests...${NC}"
    
    for i in $(seq 1 $TEST_COUNT); do
        USERNAME="loadtest_$(date +%s%N)_${i}"
        START=$(date +%s%N)
        
        # Use grpcurl if available, otherwise simulate with timeout
        if timeout 5s grpcurl -plaintext \
            -import-path "$PROTO_DIR" \
            -proto auth.proto \
            -d "{
                \"username\": \"$USERNAME\",
                \"password\": \"LoadTest123!\",
                \"device_name\": \"load-tester\",
                \"device_type\": \"test\"
            }" \
            localhost:${AUTH_PORT} guardyn.auth.AuthService/Register 2>/dev/null; then
            SUCCESS=$((SUCCESS + 1))
        else
            FAILED=$((FAILED + 1))
        fi
        
        END=$(date +%s%N)
        DURATION_MS=$(( (END - START) / 1000000 ))
        TOTAL_TIME=$((TOTAL_TIME + DURATION_MS))
        
        # Progress
        if [ $((i % 10)) -eq 0 ]; then
            echo -e "  Progress: ${i}/${TEST_COUNT} (Success: ${SUCCESS}, Failed: ${FAILED})"
        fi
    done
    
    AVG_TIME=$((TOTAL_TIME / TEST_COUNT))
    SUCCESS_RATE=$((SUCCESS * 100 / TEST_COUNT))
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}📊 Results${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  Total Requests:   ${TEST_COUNT}"
    echo -e "  Successful:       ${GREEN}${SUCCESS}${NC}"
    echo -e "  Failed:           ${RED}${FAILED}${NC}"
    echo -e "  Success Rate:     ${SUCCESS_RATE}%"
    echo -e "  Avg Latency:      ${AVG_TIME}ms"
    echo ""
    
    if [ $SUCCESS_RATE -ge 90 ]; then
        echo -e "${GREEN}✅ Load test PASSED (≥90% success rate)${NC}"
        exit 0
    else
        echo -e "${RED}❌ Load test FAILED (<90% success rate)${NC}"
        exit 1
    fi
fi

# With grpcurl available
echo -e "${GREEN}Found grpcurl, running comprehensive load test...${NC}"
echo ""

# Results tracking
RESULTS_DIR="/tmp/guardyn-loadtest-$$"
mkdir -p "$RESULTS_DIR"

# Function to run single user load
run_user_load() {
    local user_id=$1
    local duration=$2
    local results_file="$RESULTS_DIR/user_${user_id}.json"
    
    local end_time=$(($(date +%s) + duration))
    local requests=0
    local success=0
    local failed=0
    local total_latency=0
    
    while [ $(date +%s) -lt $end_time ]; do
        local timestamp=$(date +%s%N)
        local username="loadtest_u${user_id}_${timestamp}"
        local start=$(date +%s%N)
        
        # Registration request
        if grpcurl -plaintext \
            -import-path "$PROTO_DIR" \
            -proto auth.proto \
            -d "{
                \"username\": \"$username\",
                \"password\": \"LoadTest123!\",
                \"device_name\": \"load-tester-${user_id}\",
                \"device_type\": \"test\"
            }" \
            localhost:${AUTH_PORT} guardyn.auth.AuthService/Register &>/dev/null; then
            success=$((success + 1))
        else
            failed=$((failed + 1))
        fi
        
        local end=$(date +%s%N)
        local latency=$(( (end - start) / 1000000 ))
        total_latency=$((total_latency + latency))
        requests=$((requests + 1))
        
        # Small delay to prevent overwhelming
        sleep 0.1
    done
    
    local avg_latency=0
    if [ $requests -gt 0 ]; then
        avg_latency=$((total_latency / requests))
    fi
    
    echo "{\"user\":$user_id,\"requests\":$requests,\"success\":$success,\"failed\":$failed,\"avg_latency_ms\":$avg_latency}" > "$results_file"
}

# Launch concurrent users
echo -e "${BLUE}Launching ${CONCURRENT} concurrent users for ${DURATION}s...${NC}"
echo ""

for i in $(seq 1 $CONCURRENT); do
    run_user_load $i $DURATION &
done

# Wait for all users to complete
wait

# Aggregate results
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📊 Aggregated Results${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

TOTAL_REQUESTS=0
TOTAL_SUCCESS=0
TOTAL_FAILED=0
TOTAL_LATENCY=0

for f in "$RESULTS_DIR"/user_*.json; do
    if [ -f "$f" ]; then
        REQ=$(jq '.requests' "$f")
        SUC=$(jq '.success' "$f")
        FAI=$(jq '.failed' "$f")
        LAT=$(jq '.avg_latency_ms' "$f")
        
        TOTAL_REQUESTS=$((TOTAL_REQUESTS + REQ))
        TOTAL_SUCCESS=$((TOTAL_SUCCESS + SUC))
        TOTAL_FAILED=$((TOTAL_FAILED + FAI))
        TOTAL_LATENCY=$((TOTAL_LATENCY + LAT * REQ))
    fi
done

AVG_LATENCY=0
if [ $TOTAL_REQUESTS -gt 0 ]; then
    AVG_LATENCY=$((TOTAL_LATENCY / TOTAL_REQUESTS))
fi

SUCCESS_RATE=0
if [ $TOTAL_REQUESTS -gt 0 ]; then
    SUCCESS_RATE=$((TOTAL_SUCCESS * 100 / TOTAL_REQUESTS))
fi

RPS=$((TOTAL_REQUESTS / DURATION))

echo -e "  👥 Concurrent Users:  ${CONCURRENT}"
echo -e "  ⏱️  Duration:          ${DURATION}s"
echo -e "  📊 Total Requests:    ${TOTAL_REQUESTS}"
echo -e "  ✅ Successful:        ${GREEN}${TOTAL_SUCCESS}${NC}"
echo -e "  ❌ Failed:            ${RED}${TOTAL_FAILED}${NC}"
echo -e "  📈 Success Rate:      ${SUCCESS_RATE}%"
echo -e "  ⚡ Avg Latency:       ${AVG_LATENCY}ms"
echo -e "  🔥 Requests/sec:      ${RPS}"
echo ""

# Cleanup
rm -rf "$RESULTS_DIR"

# Determine pass/fail
if [ $SUCCESS_RATE -ge 90 ]; then
    echo -e "${GREEN}✅ Load test PASSED${NC}"
    echo "   - Success rate ≥ 90%"
    exit 0
else
    echo -e "${RED}❌ Load test FAILED${NC}"
    echo "   - Success rate < 90%"
    exit 1
fi
