#!/usr/bin/env bash
# Quick rebuild and redeploy messaging service
set -euo pipefail

echo "🔨 Building messaging service..."
cd backend
nix --extra-experimental-features 'nix-command flakes' develop --command \
    cargo build --release -p guardyn-messaging-service

echo "📦 Building Docker image..."
cd ..
docker build -f backend/crates/messaging-service/Dockerfile -t guardyn-messaging-service:latest backend/

echo "🚀 Pushing to registry..."
docker tag guardyn-messaging-service:latest localhost:5000/guardyn-messaging-service:latest
docker push localhost:5000/guardyn-messaging-service:latest

echo "♻️  Redeploying pods..."
kubectl delete pods -n apps -l app=messaging-service

echo "✅ Done! Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pods -l app=messaging-service -n apps --timeout=60s

echo "🎉 Messaging service redeployed successfully!"
