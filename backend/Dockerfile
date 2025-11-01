# Multi-stage Rust build for Guardyn services
FROM rust:1.75-alpine AS builder

# Install build dependencies
RUN apk add --no-cache musl-dev pkgconfig openssl-dev

WORKDIR /app
COPY backend/ .

# Build the service (service name will be passed as build arg)
ARG SERVICE_NAME
RUN cargo build --release --bin ${SERVICE_NAME}

# Runtime stage
FROM alpine:3.18
RUN apk add --no-cache ca-certificates openssl

ARG SERVICE_NAME
COPY --from=builder /app/target/release/${SERVICE_NAME} /usr/local/bin/service

EXPOSE 8080
CMD ["/usr/local/bin/service"]
