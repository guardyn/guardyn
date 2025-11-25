# Docker Build Guide

This guide explains how to build Docker images for Guardyn backend services.

## Quick Start

### Build Single Service

```bash
# From project root
./backend/build-docker.sh auth-service
./backend/build-docker.sh messaging-service
./backend/build-docker.sh media-service
```

### Build All Services

```bash
./backend/build-docker.sh all
```

## Manual Build Commands

If you prefer to build manually:

### Auth Service

```bash
docker build \
  --build-arg SERVICE_NAME=auth-service \
  -t guardyn-auth-service:latest \
  -f backend/Dockerfile \
  .
```

### Messaging Service

```bash
docker build \
  --build-arg SERVICE_NAME=guardyn-messaging-service \
  -t guardyn-messaging-service:latest \
  -f backend/Dockerfile \
  .
```

### Media Service

```bash
docker build \
  --build-arg SERVICE_NAME=guardyn-media-service \
  -t guardyn-media-service:latest \
  -f backend/Dockerfile \
  .
```

### Presence Service

```bash
docker build \
  --build-arg SERVICE_NAME=guardyn-presence-service \
  -t guardyn-presence-service:latest \
  -f backend/Dockerfile \
  .
```

### Notification Service

```bash
docker build \
  --build-arg SERVICE_NAME=guardyn-notification-service \
  -t guardyn-notification-service:latest \
  -f backend/Dockerfile \
  .
```

## Dockerfile Details

The `backend/Dockerfile` uses a multi-stage build:

### Builder Stage (rustlang/rust:nightly-alpine)

- **Base Image**: `rustlang/rust:nightly-alpine`

  - Uses Rust nightly to support Cargo.lock version 4
  - Alpine Linux for minimal image size

- **Dependencies**:

  - `musl-dev` - C standard library for Alpine
  - `pkgconfig` - Package configuration tool
  - `openssl-dev` - OpenSSL development headers
  - `openssl-libs-static` - **CRITICAL** for static linking
  - `protobuf-dev` - Protocol Buffers compiler

- **Build Process**:
  - Copies entire `backend/` directory
  - Runs `cargo build --release --bin ${SERVICE_NAME}`
  - Produces statically-linked binary in `/app/target/release/`

### Runtime Stage (alpine:3.19)

- **Base Image**: `alpine:3.19`

  - Minimal runtime environment

- **Dependencies**:

  - `ca-certificates` - SSL/TLS certificate validation
  - `openssl` - OpenSSL runtime libraries
  - `libgcc` - GCC runtime support

- **Binary**: Copied from builder stage to `/usr/local/bin/service`

- **Port**: Exposes 50051 (gRPC)

## Important Notes

### 1. Cargo.lock Version 4 Compatibility

Our project uses Cargo.lock version 4, which requires Cargo 1.77 or later:

- ❌ `rust:1.75-alpine` - Does NOT support Cargo.lock v4
- ❌ `rust:1.83-alpine` - Edition2024 not stabilized
- ✅ `rustlang/rust:nightly-alpine` - Full support

### 2. Static OpenSSL Linking

Alpine Linux requires explicit static linking for OpenSSL:

- **Without** `openssl-libs-static`: Build fails with linker error

  ```
  error: linking with `cc` failed: exit status: 1
  ld: cannot find -lssl
  ld: cannot find -lcrypto
  ```

- **With** `openssl-libs-static`: Static linking succeeds ✅

### 3. Binary Names

Service binary names match `[[bin]]` sections in `backend/Cargo.toml`:

| Service      | Binary Name                    |
| ------------ | ------------------------------ |
| Auth         | `auth-service`                 |
| Messaging    | `guardyn-messaging-service`    |
| Media        | `guardyn-media-service`        |
| Presence     | `guardyn-presence-service`     |
| Notification | `guardyn-notification-service` |

### 4. Build Context

Docker build context includes the entire project root (`.`):

- **Size**: ~5-6 GB (includes `target/` directory)
- **Optimization**: Consider adding `.dockerignore` to exclude `target/`

### 5. Build Times

Approximate build times (first build, no cache):

| Service      | Build Time   |
| ------------ | ------------ |
| Auth         | ~3-4 minutes |
| Messaging    | ~3-4 minutes |
| Media        | ~3-4 minutes |
| Presence     | ~2-3 minutes |
| Notification | ~2-3 minutes |

Subsequent builds use Docker layer caching and are much faster.

## Troubleshooting

### Error: "no bin target named X"

**Problem**: Incorrect SERVICE_NAME argument

**Solution**: Check `backend/Cargo.toml` for correct binary name:

```toml
[[bin]]
name = "auth-service"  # Use this exact name
```

### Error: "cannot find -lssl -lcrypto"

**Problem**: Missing static OpenSSL libraries

**Solution**: Ensure Dockerfile includes `openssl-libs-static`:

```dockerfile
RUN apk add --no-cache \
    musl-dev \
    pkgconfig \
    openssl-dev \
    openssl-libs-static \  # <- Must have this
    protobuf-dev
```

### Error: "Cargo.lock file version 4 is not supported"

**Problem**: Rust version too old

**Solution**: Use `rustlang/rust:nightly-alpine` instead of `rust:1.75-alpine`

### Build is Very Slow

**Causes**:

1. Large Docker build context (includes `target/` directory)
2. No layer caching (rebuilding dependencies)

**Solutions**:

1. Create `.dockerignore` to exclude `target/`:

   ```
   target/
   **/.git
   **/node_modules
   ```

2. Use Docker BuildKit for better caching:
   ```bash
   DOCKER_BUILDKIT=1 docker build ...
   ```

## Deployment to k3d

After building images, import them to k3d cluster:

```bash
# Import single service
k3d image import guardyn-auth-service:latest -c guardyn-poc

# Import all services
k3d image import \
  guardyn-auth-service:latest \
  guardyn-messaging-service:latest \
  guardyn-media-service:latest \
  -c guardyn-poc
```

Then restart deployments:

```bash
kubectl rollout restart deployment/auth-service -n apps
kubectl rollout restart deployment/messaging-service -n apps
```

## CI/CD Integration

The Dockerfile is designed for CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Build Docker image
  run: |
    docker build \
      --build-arg SERVICE_NAME=auth-service \
      -t ghcr.io/guardyn/auth-service:${{ github.sha }} \
      -f backend/Dockerfile \
      .
```

## See Also

- [Backend Development Guide](../docs/BACKEND_DEVELOPMENT.md)
- [Deployment Guide](../docs/DEPLOYMENT.md)
- [Troubleshooting Guide](../docs/TROUBLESHOOTING.md)
