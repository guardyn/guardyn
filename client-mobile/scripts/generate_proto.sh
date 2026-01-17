#!/usr/bin/env bash
set -euo pipefail

# Proto generation script for Flutter client
# Generates Dart gRPC code from .proto files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROTO_DIR="$CLIENT_DIR/proto"
OUTPUT_DIR="$CLIENT_DIR/lib/generated"

# Ensure protoc-gen-dart is in PATH
export PATH="$PATH:$HOME/.pub-cache/bin"

# Check if protoc-gen-dart is available
if ! command -v protoc-gen-dart &> /dev/null; then
    echo "Error: protoc-gen-dart not found"
    echo "Install with: dart pub global activate protoc_plugin"
    exit 1
fi

# Find protoc (try system protoc first, then check common locations)
PROTOC=""
if command -v protoc &> /dev/null; then
    PROTOC="protoc"
elif [ -f "/nix/store/i8f1flqxyxhbp8hcqif244gw5fkvjmmk-protobuf-24.4/bin/protoc" ]; then
    PROTOC="/nix/store/i8f1flqxyxhbp8hcqif244gw5fkvjmmk-protobuf-24.4/bin/protoc"
else
    echo "Error: protoc not found"
    echo "Install protobuf compiler or use 'nix develop'"
    exit 1
fi

echo "Using protoc: $PROTOC"
echo "Using protoc-gen-dart from: $(which protoc-gen-dart)"

# Clean output directory
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Generate Dart code
echo "Generating Dart gRPC code..."
$PROTOC \
    --dart_out=grpc:"$OUTPUT_DIR" \
    --proto_path="$PROTO_DIR" \
    "$PROTO_DIR"/*.proto

echo "✅ Proto generation complete!"
echo "Generated files in: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"
