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
GUARDYN_MESSAGING__NATS_URL=nats://127.0.0.1:4222
S3_ENDPOINT=http://127.0.0.1:9000

# JWT (dev only)
JWT_SECRET=dev-secret-key-for-local-development-only

# Logging
RUST_LOG=info,guardyn=debug
```

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

## Best Practices

1. **Use local mode for development**: Much faster iteration cycle
2. **Scale down when not testing HA**: Use `just scale-dev`
3. **Keep ScyllaDB at 1 node for dev**: Saves significant resources
4. **Use cargo-watch**: Automatic recompilation on file changes
5. **Monitor resources**: Use `just resources` to check usage
