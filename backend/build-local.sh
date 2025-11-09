#!/bin/bash
set -e

echo "Building Rust services locally..."

cd /home/anry/projects/guardyn/guardyn

# Enter Nix shell and build
nix --extra-experimental-features 'nix-command flakes' develop --command bash -c "
  cd backend && \
  cargo build --release -p guardyn-auth-service -p guardyn-messaging-service
"

echo "✅ Build complete!"
echo "Binaries:"
ls -lh backend/target/release/guardyn-*-service
