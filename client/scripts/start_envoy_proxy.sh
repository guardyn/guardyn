#!/usr/bin/env bash
# Start Envoy gRPC-Web proxy via Kubernetes port-forward
# Envoy runs as a Pod in k3d cluster, not as standalone Docker container

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../.."

echo "🌐 Starting Envoy gRPC-Web Proxy (Kubernetes)"
echo "=============================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed${NC}"
    exit 1
fi

# Check if Envoy pod exists in Kubernetes
echo -e "${YELLOW}Checking Envoy deployment in Kubernetes...${NC}"
if ! kubectl get deployment -n apps envoy-grpc-web &> /dev/null; then
    echo -e "${RED}❌ Envoy deployment not found in Kubernetes${NC}"
    echo ""
    echo "Deploy Envoy to Kubernetes first:"
    echo "  kubectl apply -k infra/k8s/base/envoy"
    exit 1
fi

# Check if Envoy pod is running
POD_STATUS=$(kubectl get pods -n apps -l app=envoy-grpc-web -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")
if [ "$POD_STATUS" != "Running" ]; then
    echo -e "${RED}❌ Envoy pod is not running (status: $POD_STATUS)${NC}"
    echo ""
    echo "Check pod status:"
    echo "  kubectl get pods -n apps -l app=envoy-grpc-web"
    echo "  kubectl logs -n apps -l app=envoy-grpc-web"
    exit 1
fi

echo -e "${GREEN}✅ Envoy pod is running in Kubernetes${NC}"
echo ""

# Check if port 8080 is available
if lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Port 8080 is already in use${NC}"
    echo "Checking if it's our port-forward..."
    if pgrep -f "port-forward.*envoy-grpc-web.*8080" > /dev/null; then
        echo -e "${GREEN}✅ Port-forward already running${NC}"
        exit 0
    else
        echo -e "${RED}Another process is using port 8080${NC}"
        echo "Kill it or use a different port"
        exit 1
    fi
fi

echo -e "${GREEN}Starting port-forward to Envoy service...${NC}"
echo ""

# Start port-forward in background
kubectl port-forward -n apps svc/envoy-grpc-web 8080:8080 &
PORT_FORWARD_PID=$!

# Wait a moment for port-forward to start
sleep 2

# Verify port-forward is working
if ! lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${RED}❌ Port-forward failed to start${NC}"
    kill $PORT_FORWARD_PID 2>/dev/null || true
    exit 1
fi

echo ""
echo "=============================================="
echo -e "${GREEN}✅ Envoy gRPC-Web proxy is ready!${NC}"
echo ""
echo "Configuration:"
echo "  • Envoy Pod:            apps/envoy-grpc-web"
echo "  • Service:              envoy-grpc-web:8080"
echo "  • Local access:         http://localhost:8080"
echo "  • Admin interface:      Port-forward 9901 separately"
echo ""
echo "Chrome client will connect to:"
echo "  • http://localhost:8080"
echo ""
echo "To stop port-forward:"
echo "  kill $PORT_FORWARD_PID"
echo ""
echo "To view Envoy logs:"
echo "  kubectl logs -n apps -l app=envoy-grpc-web -f"
echo ""
echo "To check Envoy health:"
echo "  kubectl port-forward -n apps svc/envoy-grpc-web 9901:9901 &"
echo "  curl http://localhost:9901/ready"
echo ""
