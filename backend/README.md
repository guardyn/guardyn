# Guardyn Backend Services

Rust-based microservices for the Guardyn secure communication platform.

## Architecture

This workspace contains the following services:

- **auth-service**: User authentication, registration, and session management
- **messaging-service**: Message routing, persistence, and delivery
- **presence-service**: Online/offline status and typing indicators
- **media-service**: File upload/download and media processing
- **notification-service**: Push notifications (FCM, APNs)

## Shared Crates

- **common**: Shared utilities, configuration, error handling
- **crypto**: Cryptographic protocols (X3DH, Double Ratchet, MLS)

## Development

### Prerequisites

Enter the Nix development shell:

```bash
nix develop
```

### Building

Build all services:

```bash
cargo build
```

Build specific service:

```bash
cargo build -p guardyn-auth-service
```

### Running

Run a service:

```bash
cargo run -p guardyn-auth-service
```

### Testing

Run all tests:

```bash
cargo test
```

### Configuration

Services are configured via environment variables with `GUARDYN_` prefix:

```bash
export GUARDYN_SERVICE_NAME=auth-service
export GUARDYN_HOST=0.0.0.0
export GUARDYN_PORT=8080
export GUARDYN_DATABASE__TIKV_PD_ENDPOINTS=pd.data.svc.cluster.local:2379
export GUARDYN_DATABASE__SCYLLADB_NODES=scylla-0.data.svc.cluster.local:9042
export GUARDYN_MESSAGING__NATS_URL=nats://nats.messaging.svc.cluster.local:4222
export GUARDYN_OBSERVABILITY__OTLP_ENDPOINT=http://tempo.observability.svc.cluster.local:4317
export GUARDYN_OBSERVABILITY__LOG_LEVEL=info
```

## Cryptography

### 1-on-1 Messaging

- **X3DH**: Initial key agreement
- **Double Ratchet**: Forward-secret encryption (via libsignal-protocol)

### Group Chat

- **MLS**: Messaging Layer Security (via OpenMLS)

### Post-Quantum

- **Kyber**: Hybrid ECDH + Kyber key exchange (planned)

## Database Schema

### TiKV

- User accounts and authentication state
- Session tokens
- Device registration

### ScyllaDB

- Message history
- Media metadata
- Presence events

## Deployment

Each service is containerized and deployed to Kubernetes:

```bash
# Build all services
./build-docker.sh

# Or build locally with Cargo
./build-local.sh

# Deploy to k8s cluster
just k8s-deploy auth
just k8s-deploy messaging
just k8s-deploy presence
just k8s-deploy media
```

## Status

✅ **MVP Complete** - All core services deployed and operational

- [x] Workspace structure
- [x] Common utilities crate
- [x] Cryptography crate (X3DH, Double Ratchet, MLS)
- [x] Auth service (registration, login, JWT, device management)
- [x] Messaging service (1-on-1, groups, E2EE, MLS)
- [x] Presence service (online/offline, typing indicators)
- [x] Media service (upload/download, thumbnails)
- [x] Notification service (scaffold)
- [x] Database integration (TiKV + ScyllaDB)
- [x] gRPC API definitions (proto/)
- [x] Testing suite (E2E + unit tests)
- [x] Containerization (Docker multi-stage builds)
- [x] Kubernetes deployment (k8s manifests)

