#!/usr/bin/env bash
# Build and deploy all backend services
set -euo pipefail

SERVICES=("auth-service" "messaging-service")

echo "🔨 Building all backend services..."
cd backend
nix --extra-experimental-features 'nix-command flakes' develop --command \
    cargo build --release -p guardyn-auth-service -p guardyn-messaging-service

cd ..

for SERVICE in "${SERVICES[@]}"; do
    echo ""
    echo "📦 Building Docker image for ${SERVICE}..."
    docker build -f backend/crates/${SERVICE}/Dockerfile -t guardyn-${SERVICE}:latest backend/

    echo "📥 Importing to k3d cluster..."
    k3d image import guardyn-${SERVICE}:latest -c guardyn-poc
done

echo ""
echo "♻️  Updating deployments..."
kubectl set image deployment/auth-service -n apps auth-service=guardyn-auth-service:latest
kubectl set image deployment/messaging-service -n apps messaging-service=guardyn-messaging-service:latest

kubectl rollout restart deployment/auth-service -n apps
kubectl rollout restart deployment/messaging-service -n apps

echo ""
echo "✅ Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pods -l app=auth-service -n apps --timeout=120s
kubectl wait --for=condition=Ready pods -l app=messaging-service -n apps --timeout=120s

echo ""
echo "🎉 All services deployed successfully!"
echo ""
echo "📊 Service status:"
kubectl get pods -n apps
