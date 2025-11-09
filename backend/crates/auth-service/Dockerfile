# Multi-stage build for guardyn-auth-service
# Stage 1: Builder
FROM rust:1.84-slim-bookworm AS builder

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

# Copy all crates (needed for workspace build)
COPY crates/ ./crates/
COPY proto/ ./proto/

# Build the auth-service binary (release mode)
RUN cargo build --release -p guardyn-auth-service

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
COPY --from=builder /app/target/release/guardyn-auth-service /usr/local/bin/guardyn-auth-service

# Set ownership
RUN chown guardyn:guardyn /usr/local/bin/guardyn-auth-service

# Switch to non-root user
USER guardyn

# Expose gRPC port
EXPOSE 50051

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD ["/usr/local/bin/guardyn-auth-service", "--health-check"]

# Run the service
ENTRYPOINT ["/usr/local/bin/guardyn-auth-service"]
