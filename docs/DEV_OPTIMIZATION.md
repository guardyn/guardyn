# Development Optimization Guide

This guide describes how to optimize the local development environment for faster iteration and reduced resource consumption.

## Quick Start

### Scale Down for Development

Apply development scaling immediately:

```bash
just scale-dev
```

This reduces all backend services from 2-3 replicas to 1 replica each, saving ~9 pods.

### Run Services Locally (Fastest Rebuild)

For the fastest development iteration (~5-10 seconds rebuild vs ~60+ seconds with Docker):

```bash
# Start port-forwards to cluster databases
just dev-ports

# In another terminal, run a specific service
just dev-auth        # Run auth-service locally
just dev-messaging   # Run messaging-service locally
just dev-presence    # Run presence-service locally
just dev-media       # Run media-service locally

# Or run all services in tmux
just dev-all
```

### Stop Development Environment

```bash
just dev-stop    # Stop port-forwards
just scale-prod  # Restore production replicas
```

## Resource Comparison

| Mode            | Apps Pods | Data Pods | Est. Memory | Rebuild Time |
| --------------- | --------- | --------- | ----------- | ------------ |
| **Production**  | 10        | 6         | ~12GB       | ~60+ sec     |
| **Dev (k8s)**   | 5         | 4         | ~6GB        | ~60+ sec     |
| **Dev (local)** | 0         | 4         | ~3GB        | ~5-10 sec    |

## Available Commands

### Justfile Commands

```bash
# Development (local services with port-forward)
just dev-ports       # Start port-forwards to databases only
just dev-stop        # Stop all port-forwards
just dev-status      # Check port-forward status
just dev-auth        # Run auth-service locally
just dev-messaging   # Run messaging-service locally
just dev-presence    # Run presence-service locally
just dev-media       # Run media-service locally
just dev-all         # Run all services in tmux
just dev-watch <svc> # Run service with hot-reload (cargo-watch)

# Resource scaling
just scale-dev       # Scale all services to 1 replica
just scale-prod      # Restore production replicas
just resources       # Show current resource usage
```

## Local Development Architecture

When running services locally, the architecture looks like this:

```
┌─────────────────────────────────────────────────────────────────┐
│  Local Machine                                                   │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌───────────┐ │
│  │auth-service │ │messaging   │ │presence    │ │media     │ │
│  │(cargo run)  │ │(cargo run) │ │(cargo run) │ │(cargo run)│ │
│  │:50051       │ │:50052      │ │:50053      │ │:50054     │ │
│  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘ └─────┬─────┘ │
│         │               │               │               │       │
│         └───────────────┴───────────────┴───────────────┘       │
│                         │ port-forward                           │
└─────────────────────────┼───────────────────────────────────────┘
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  k3d cluster (databases only)                                    │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐            │
│  │ TiKV    │  │ScyllaDB │  │ NATS    │  │ MinIO   │            │
│  │ :2379   │  │ :9042   │  │ :4222   │  │ :9000   │            │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

## Port Mapping (Local Development)

| Service           | Local Port | Description           |
| ----------------- | ---------- | --------------------- |
| TiKV PD           | 2379       | TiKV Placement Driver |
| ScyllaDB          | 9042       | CQL native transport  |
| NATS              | 4222       | NATS client port      |
| MinIO             | 9000       | S3-compatible API     |
| auth-service      | 50051      | gRPC API              |
| messaging-service | 50052      | gRPC API              |
| presence-service  | 50053      | gRPC API              |
| media-service     | 50054      | gRPC API              |

## Hot Reload with cargo-watch

Install cargo-watch for automatic recompilation:

```bash
cargo install cargo-watch
```

Then run a service with hot-reload:

```bash
just dev-watch auth-service
```

Or manually:

```bash
cd backend
cargo watch -x "run --bin auth-service"
```

## ScyllaDB Single-Node Mode

For additional resource savings, ScyllaDB can be reduced to 1 node:

```bash
kubectl apply -f infra/k8s/overlays/local/scylla-dev-patch.yaml
```

This saves ~8 containers and ~4GB RAM.

**Note**: ScyllaDB decommissioning takes time. Wait for pods to terminate:

```bash
kubectl get pods -n data -w
```

## Environment Variables

When running services locally, these environment variables are set automatically by `dev-local.sh`:

```bash
# Database connections
GUARDYN_DATABASE__TIKV_PD_ENDPOINTS=127.0.0.1:2379
GUARDYN_DATABASE__SCYLLADB_NODES=127.0.0.1:9042

# NATS (multiple variables for compatibility)
GUARDYN_MESSAGING__NATS_URL=nats://127.0.0.1:4222
NATS_URL=nats://127.0.0.1:4222
NATS_ENDPOINT=nats://127.0.0.1:4222  # Required for messaging-service

# S3/MinIO
S3_ENDPOINT=http://127.0.0.1:9000

# ScyllaDB single-node settings
SCYLLA_CONSISTENCY=one
SCYLLA_REPLICATION_FACTOR=1

# JWT (dev only)
JWT_SECRET=dev-secret-key-for-local-development-only

# Logging
RUST_LOG=info,guardyn=debug
```

### Note on NATS Configuration

`messaging-service` uses `NATS_ENDPOINT` while other services may use `NATS_URL`. The `dev-local.sh` script sets both to ensure compatibility.

## Troubleshooting

### Port-forward dies unexpectedly

Check status and restart:

```bash
just dev-status
just dev-stop
just dev-ports
```

### Service can't connect to database

1. Verify port-forwards are running: `just dev-status`
2. Check database pods are healthy: `kubectl get pods -n data`
3. Test connection manually:

   ```bash
   # TiKV
   curl -s http://127.0.0.1:2379/pd/api/v1/health

   # ScyllaDB
   cqlsh 127.0.0.1 9042

   # NATS
   nats server check connection
   ```

### Slow compilation

Enable incremental compilation (default in Rust):

```bash
# Clear build cache if issues
cargo clean

# Use release mode for faster runtime (slower compile)
cargo build --release --bin auth-service
```

### WebSocket messages not arriving in real-time

**Symptom**: Messages save to database but clients only see them after refresh.

**Causes**:

1. K8s messaging-service pod competing with local service for NATS messages
2. NATS consumer not created (check `NATS_ENDPOINT` is set)
3. WebSocket not connected

**Fix**:

```bash
# 1. Stop k8s messaging-service
kubectl scale deployment messaging-service -n apps --replicas=0

# 2. Verify local service has NATS consumer
kubectl run nats-check --rm -it --image=natsio/nats-box \
  --restart=Never -n messaging -- \
  nats con ls MESSAGES -s nats://nats:4222

# Should show: websocket-relay-<UUID>

# 3. Restart local messaging-service
just dev-messaging

# 4. Check client WebSocket connection in browser DevTools
```

### E2EE messages are garbled or unreadable

**Symptom**: Messages appear but content is corrupted (random characters).

**Cause**: Corrupted Double Ratchet session state.

**Fix**:

```bash
# Clear all client data
just clear-client-data

# Restart both clients to generate fresh keys
```

## Best Practices

1. **Use local mode for development**: Much faster iteration cycle
2. **Scale down when not testing HA**: Use `just scale-dev`
3. **Keep ScyllaDB at 1 node for dev**: Saves significant resources
4. **Use cargo-watch**: Automatic recompilation on file changes
5. **Monitor resources**: Use `just resources` to check usage
6. **Stop k8s services when running locally**: Prevent message delivery conflicts

## ⚠️ Important: K8s vs Local Service Conflicts

When running services locally, you **MUST** stop the corresponding k8s deployments to avoid conflicts:

### Problem: Duplicate Message Consumers

If both k8s and local messaging-service are running:

1. Both create NATS consumers for the MESSAGES stream
2. Messages are delivered to the k8s pod (which has no WebSocket clients)
3. Local WebSocket clients never receive real-time messages
4. Messages only appear after manual refresh

### Solution: Stop K8s Services

```bash
# Before running services locally:
kubectl scale deployment messaging-service -n apps --replicas=0
kubectl scale deployment auth-service -n apps --replicas=0
kubectl scale deployment presence-service -n apps --replicas=0
kubectl scale deployment media-service -n apps --replicas=0

# Or use the development command:
just scale-local

# After local development, restore:
just scale-dev  # 1 replica each
just scale-prod # Full replicas
```

### Verify Only Local Services Are Running

```bash
# Check k8s deployments are scaled to 0:
kubectl get deployment -n apps

# Check local services are running:
ps aux | grep guardyn

# Check NATS consumers (should show only local consumer):
kubectl run nats-check --rm -it --image=natsio/nats-box \
  --restart=Never -n messaging -- \
  nats con ls MESSAGES -s nats://nats:4222
```

## Client Data Cleanup

When debugging E2EE issues or after protocol changes, clear client data:

```bash
# Interactive cleanup (with confirmation):
just clear-client-data

# Force cleanup (for CI/scripts):
just clear-client-data-force
```

This clears:

- E2EE session keys (Double Ratchet state)
- X3DH key material
- Cached user data

### What Gets Cleared

| Platform | Location | Data |
|----------|----------|------|
| Linux | `~/.local/share/guardyn_client/` | SQLite DB, key files |
| Android | App data via `adb pm clear` | All app storage |
| Web | Browser LocalStorage | Session data, keys |
