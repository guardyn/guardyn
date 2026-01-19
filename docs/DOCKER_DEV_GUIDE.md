# Guardyn Local Development Environment

This directory contains Docker Compose configuration for rapid local development.

## Quick Start

```bash
# From project root
docker compose -f docker-compose.dev.yml up -d

# View logs for all services
docker compose -f docker-compose.dev.yml logs -f

# View logs for specific service
docker compose -f docker-compose.dev.yml logs -f auth-service

# Stop everything
docker compose -f docker-compose.dev.yml down

# Reset all data
docker compose -f docker-compose.dev.yml down -v
```

## Services

### Data Layer

| Service      | Port(s)                                              | Description                        |
| ------------ | ---------------------------------------------------- | ---------------------------------- |
| **Redpanda** | 19092 (Kafka), 18081 (Schema Registry), 9644 (Admin) | Event streaming (Kafka-compatible) |
| **TiKV**     | 20160                                                | Distributed transactional KV store |
| **PD**       | 2379                                                 | TiKV Placement Driver              |
| **ScyllaDB** | 9042 (CQL)                                           | High-performance wide-column DB    |
| **MinIO**    | 9000 (S3), 9001 (Console)                            | Object storage for media           |

### Edge Layer

| Service   | Port(s)                       | Description        |
| --------- | ----------------------------- | ------------------ |
| **Envoy** | 8080 (HTTP), 9901 (Admin)     | API Gateway        |

### Backend Services

| Service                  | Port(s)                        | Description                      |
| ------------------------ | ------------------------------ | -------------------------------- |
| **auth-service**         | 50051                          | Authentication, key bundles      |
| **messaging-service**    | 50052 (gRPC), 8081 (WebSocket) | Messages, groups                 |
| **presence-service**     | 50053                          | Online status, typing indicators |
| **media-service**        | 50054                          | File upload/download             |
| **notification-service** | 50055                          | Push notifications               |

### Development Tools

| Service              | Port(s) | Description             |
| -------------------- | ------- | ----------------------- |
| **Redpanda Console** | 8088    | Web UI for Kafka topics |

## Development Workflow

### Hot Reload

All Rust services use `cargo-watch` for automatic recompilation on file changes:

```bash
# Changes to backend code automatically trigger rebuild
# Watch the logs to see recompilation
docker compose -f docker-compose.dev.yml logs -f auth-service
```

### Rebuild Specific Service

```bash
docker compose -f docker-compose.dev.yml up -d --build auth-service
```

### Access Redpanda Console

Open http://localhost:8088 to view Kafka topics, consumer groups, and messages.

### Access MinIO Console

Open http://localhost:9001 with credentials:

- **Username:** guardyn
- **Password:** guardyn-dev-secret

### Connect to ScyllaDB

```bash
docker exec -it guardyn-scylladb cqlsh
```

## Environment Variables

Backend services support these environment variables:

| Variable            | Description                                 | Default         |
| ------------------- | ------------------------------------------- | --------------- |
| `RUST_LOG`          | Log level (trace, debug, info, warn, error) | `debug`         |
| `RUST_BACKTRACE`    | Enable backtraces (0, 1, full)              | `1`             |
| `TIKV_PD_ENDPOINTS` | TiKV PD endpoints                           | `pd:2379`       |
| `SCYLLA_HOSTS`      | ScyllaDB contact points                     | `scylladb:9042` |
| `REDPANDA_BROKERS`  | Redpanda/Kafka brokers                      | `redpanda:9092` |
| `MINIO_ENDPOINT`    | MinIO S3 endpoint                           | `minio:9000`    |

## Troubleshooting

### Services Not Starting

```bash
# Check container status
docker compose -f docker-compose.dev.yml ps

# Check specific service logs
docker compose -f docker-compose.dev.yml logs scylladb

# Restart a service
docker compose -f docker-compose.dev.yml restart auth-service
```

### TiKV Issues

TiKV requires PD to be healthy before starting:

```bash
# Check PD health
curl http://localhost:2379/health

# Check TiKV status
curl http://localhost:20180/status
```

### ScyllaDB Slow Start

ScyllaDB takes 30-60 seconds to become ready on first start:

```bash
# Wait for ScyllaDB
docker exec guardyn-scylladb nodetool status
```

### Port Conflicts

If ports are already in use, modify `docker-compose.dev.yml`:

```yaml
services:
  envoy:
    ports:
      - "18080:8080" # Changed from 8080
```

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│              Client (Flutter Mobile / Tauri Desktop)             │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    │ gRPC (native)
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Envoy API Gateway                           │
│                         localhost:8080                           │
└─────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    ▼               ▼               ▼
            ┌───────────┐   ┌───────────┐   ┌───────────┐
            │   Auth    │   │ Messaging │   │  Media    │
            │  :50051   │   │  :50052   │   │  :50054   │
            └───────────┘   └───────────┘   └───────────┘
                    │               │               │
        ┌───────────┼───────────────┼───────────────┼───────────┐
        │           │               │               │           │
        ▼           ▼               ▼               ▼           ▼
   ┌─────────┐ ┌─────────┐   ┌─────────────┐   ┌─────────┐ ┌─────────┐
   │  TiKV   │ │  PD     │   │   Redpanda  │   │ ScyllaDB│ │  MinIO  │
   │ :20160  │ │ :2379   │   │    :19092   │   │ :9042   │ │ :9000   │
   └─────────┘ └─────────┘   └─────────────┘   └─────────┘ └─────────┘
```

## Comparison with k3d

| Aspect              | Docker Compose (dev) | k3d (staging/prod)           |
| ------------------- | -------------------- | ---------------------------- |
| Startup time        | ~30 seconds          | ~5 minutes                   |
| Resource usage      | Low                  | High                         |
| Hot reload          | Yes (cargo-watch)    | Manual rebuild               |
| Kubernetes features | No                   | Yes                          |
| Use case            | Daily development    | Integration testing, staging |

Use Docker Compose for daily development, k3d for testing Kubernetes manifests.
