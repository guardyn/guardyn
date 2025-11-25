# Multi-stage build for Guardyn backend services
# FIXED: Supports Cargo.lock v4 (requires Cargo 1.77+) and static OpenSSL linking for Alpine
FROM rustlang/rust:nightly-alpine AS builder

# Install build dependencies including static OpenSSL libraries
# openssl-libs-static is REQUIRED for static linking in Alpine
RUN apk add --no-cache \
    musl-dev \
    pkgconfig \
    openssl-dev \
    openssl-libs-static \
    protobuf-dev

WORKDIR /app

# Copy the entire backend directory
COPY backend/ .

# Build argument for service name
ARG SERVICE_NAME

# Build the specified service
RUN cargo build --release --bin ${SERVICE_NAME}

# Runtime stage
FROM alpine:3.19

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    openssl \
    libgcc

# Copy the built binary from builder stage
ARG SERVICE_NAME
COPY --from=builder /app/target/release/${SERVICE_NAME} /usr/local/bin/service

# Expose gRPC port
EXPOSE 50051

# Run the service
CMD ["/usr/local/bin/service"]
