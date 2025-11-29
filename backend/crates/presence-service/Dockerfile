# Multi-stage build for guardyn-presence-service
# Stage 1: Builder
FROM rust:1.91-slim-bookworm AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy workspace manifest
COPY Cargo.toml Cargo.lock ./

# Copy proto files FIRST (needed for build.rs)
COPY proto/ ./proto/

# Copy all crates (needed for workspace build)
COPY crates/ ./crates/

# Build the presence-service binary (release mode)
RUN cargo build --release -p guardyn-presence-service

# Stage 2: Runtime
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1000 -s /bin/bash guardyn

# Copy binary from builder
COPY --from=builder /app/target/release/guardyn-presence-service /usr/local/bin/guardyn-presence-service

# Set ownership
RUN chown guardyn:guardyn /usr/local/bin/guardyn-presence-service

# Switch to non-root user
USER guardyn

# Expose gRPC port
EXPOSE 50053

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD ["/usr/local/bin/guardyn-presence-service", "--health-check"]

# Run the service
ENTRYPOINT ["/usr/local/bin/guardyn-presence-service"]
