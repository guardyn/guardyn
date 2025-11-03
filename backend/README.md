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

Each service will be containerized and deployed to Kubernetes:

```bash
# Build container
docker build -f Dockerfile.auth-service -t guardyn-auth-service:latest .

# Deploy to k8s
kubectl apply -f k8s/auth-service.yaml
```

## Status

🔄 **In Development** - Core scaffolding complete, implementation in progress

- [x] Workspace structure
- [x] Common utilities crate
- [x] Cryptography crate skeleton
- [x] Auth service skeleton
- [x] Messaging service skeleton
- [ ] Database integration
- [ ] gRPC API definitions
- [ ] Cryptography implementation
- [ ] Testing suite
- [ ] Containerization
