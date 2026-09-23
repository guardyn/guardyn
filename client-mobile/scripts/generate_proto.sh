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

# The generator version is part of the output, not a detail of the environment.
#
# `dart pub global activate protoc_plugin` with no version installs the newest, which is 25.x.
# protoc_plugin 25.x emits the protobuf 6 API - a deprecated `create()` and a new
# `$_createMessage` - while client-mobile/pubspec.lock pins the protobuf *runtime* at 5.1.0.
# Regenerating with it produces Dart that runtime cannot support, `flutter analyze` fails, and
# the obvious-looking fix is a dependency bump that whatever step tripped over it has no
# business making. Measured drift against the committed output, regenerating an UNCHANGED
# proto: 25.1.0 differs by 134 lines, 23.0.0 by 14, 24.0.0 by one inert lint-ignore comment.
#
# 24.0.0 is the newest release built against protobuf ^5.0.0. Before changing it, regenerate an
# unchanged proto and diff - a version that reproduces the committed output is the only one
# that can be adopted without rewriting every generated file in the same commit.
readonly PROTOC_GEN_DART_VERSION="24.0.0"

if ! command -v protoc-gen-dart &> /dev/null; then
    echo "Error: protoc-gen-dart not found"
    echo "Install with: dart pub global activate protoc_plugin $PROTOC_GEN_DART_VERSION"
    exit 1
fi

# Refuse to run on the wrong generator rather than silently emitting incompatible Dart. A
# wrong version here is invisible until `flutter analyze` fails somewhere unrelated.
ACTIVE_PLUGIN_VERSION="$(dart pub global list 2>/dev/null \
    | sed -nE 's/^protoc_plugin ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p')"
if [ "$ACTIVE_PLUGIN_VERSION" != "$PROTOC_GEN_DART_VERSION" ]; then
    echo "Error: protoc_plugin ${ACTIVE_PLUGIN_VERSION:-<not activated>} is active, but this"
    echo "       project generates with $PROTOC_GEN_DART_VERSION (protobuf ^5.0.0, matching"
    echo "       the runtime pinned in pubspec.lock)."
    echo "Fix with: dart pub global activate protoc_plugin $PROTOC_GEN_DART_VERSION"
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

# Clean output directory (preserve rust/ subdirectory for flutter_rust_bridge)
if [ -d "$OUTPUT_DIR/rust" ]; then
    # Move rust dir temporarily
    mv "$OUTPUT_DIR/rust" /tmp/guardyn_rust_generated_backup
fi
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
# Restore rust dir
if [ -d /tmp/guardyn_rust_generated_backup ]; then
    mv /tmp/guardyn_rust_generated_backup "$OUTPUT_DIR/rust"
fi

# Generate Dart code
echo "Generating Dart gRPC code..."
$PROTOC \
    --dart_out=grpc:"$OUTPUT_DIR" \
    --proto_path="$PROTO_DIR" \
    "$PROTO_DIR"/*.proto

echo "✅ Proto generation complete!"
echo "Generated files in: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"
