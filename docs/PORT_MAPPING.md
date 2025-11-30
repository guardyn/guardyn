# Guardyn Port Mapping Reference

This document provides a comprehensive overview of all ports used in the Guardyn system.

## Quick Reference Table

| Port | Service | Protocol | Namespace | Description |
|------|---------|----------|-----------|-------------|
| **50051** | auth-service | gRPC | apps | Authentication & user management |
| **50052** | messaging-service | gRPC | apps | Messaging operations |
| **50053** | presence-service | gRPC | apps | Online status & typing indicators |
| **50054** | media-service | gRPC | apps | File upload/download |
| **8080** | envoy | HTTP | apps | gRPC-Web proxy (browser clients) |
| **8080** | notification-service | HTTP | apps | Push notifications (HTTP API) |
| **8081** | messaging-service | WebSocket | apps | Real-time messaging |
| **9090** | notification-service | HTTP | apps | Metrics endpoint |
| **9901** | envoy | HTTP | apps | Envoy admin interface |
| **4222** | nats | TCP | messaging | NATS client connections |
| **4223** | nats | TCP | messaging | NATS cluster routing |
| **2379** | pd (TiKV) | TCP | data | TiKV Placement Driver client |
| **2380** | pd (TiKV) | TCP | data | TiKV Placement Driver peer |
| **20160** | tikv | TCP | data | TiKV storage node |
| **9042** | scylladb | TCP | data | ScyllaDB CQL native protocol |
| **9000** | minio | HTTP | data | MinIO S3 API |
| **9001** | minio | HTTP | data | MinIO Console UI |
| **5000** | guardyn-registry | HTTP | host | Container image registry |
| **6443** | k3s API | HTTPS | host | Kubernetes API server |
| **80** | loadbalancer | HTTP | host | HTTP ingress |
| **443** | loadbalancer | HTTPS | host | HTTPS ingress |

---

## Detailed Port Breakdown

### Application Services (namespace: `apps`)

#### Auth Service
| Port | Name | Protocol | Purpose |
|------|------|----------|---------|
| 50051 | grpc | TCP | User registration, login, logout, device management, JWT tokens |

**K8s Service:** `auth-service.apps.svc.cluster.local:50051`

#### Messaging Service
| Port | Name | Protocol | Purpose |
|------|------|----------|---------|
| 50052 | grpc | TCP | SendMessage, GetMessages, MarkAsRead, DeleteMessage, Groups |
| 8081 | websocket | TCP | Real-time message delivery, typing indicators, presence |

**K8s Services:**
- gRPC: `messaging-service.apps.svc.cluster.local:50052`
- WebSocket: `messaging-service.apps.svc.cluster.local:8081`

#### Presence Service
| Port | Name | Protocol | Purpose |
|------|------|----------|---------|
| 50053 | grpc | TCP | UpdateStatus, GetStatus, GetBulkStatus, Subscribe |

**K8s Service:** `presence-service.apps.svc.cluster.local:50053`

#### Media Service
| Port | Name | Protocol | Purpose |
|------|------|----------|---------|
| 50054 | grpc | TCP | File upload/download, presigned URLs, S3/MinIO integration |

**K8s Service:** `media-service.apps.svc.cluster.local:50054`

#### Notification Service
| Port | Name | Protocol | Purpose |
|------|------|----------|---------|
| 8080 | http | TCP | Push notification delivery (FCM/APNs) |
| 9090 | metrics | TCP | Prometheus metrics |

**K8s Service:** `notification-service.apps.svc.cluster.local:8080`

#### Envoy Proxy
| Port | Name | Protocol | Purpose |
|------|------|----------|---------|
| 8080 | grpc-web | TCP | gRPC-Web to gRPC translation for browser clients |
| 9901 | admin | TCP | Envoy admin interface (stats, config dump) |

**K8s Service:** `guardyn-envoy.apps.svc.cluster.local:8080`

---

### Messaging Infrastructure (namespace: `messaging`)

#### NATS JetStream
| Port | Name | Protocol | Purpose |
|------|------|----------|---------|
| 4222 | client | TCP | NATS client connections (pub/sub) |
| 4223 | cluster | TCP | NATS cluster routing (node-to-node) |
| 6222 | leafnode | TCP | NATS leaf node connections |
| 8222 | http | TCP | NATS monitoring HTTP endpoint |

**K8s Service:** `nats.messaging.svc.cluster.local:4222`

**Streams configured:**
- MESSAGES - Message delivery
- PRESENCE - Presence updates
- NOTIFICATIONS - Push notification queue
- MEDIA - Media processing events

---

### Data Layer (namespace: `data`)

#### TiKV Placement Driver (PD)
| Port | Name | Protocol | Purpose |
|------|------|----------|---------|
| 2379 | client | TCP | PD client API (cluster metadata, TSO) |
| 2380 | peer | TCP | PD peer communication (Raft) |

**K8s Service:** `pd.data.svc.cluster.local:2379`

#### TiKV Storage
| Port | Name | Protocol | Purpose |
|------|------|----------|---------|
| 20160 | tikv | TCP | TiKV gRPC API (key-value operations) |

**K8s Service:** `tikv.data.svc.cluster.local:20160`

#### ScyllaDB
| Port | Name | Protocol | Purpose |
|------|------|----------|---------|
| 9042 | cql | TCP | CQL native protocol (queries) |
| 9142 | ssl | TCP | CQL with TLS |
| 7000 | inter-node | TCP | Inter-node communication |
| 7001 | ssl-inter | TCP | Inter-node with TLS |
| 7199 | jmx | TCP | JMX monitoring |
| 10000 | rest | TCP | REST API |

**K8s Service:** `guardyn-scylla-client.data.svc.cluster.local:9042`

#### MinIO (S3-compatible storage)
| Port | Name | Protocol | Purpose |
|------|------|----------|---------|
| 9000 | api | TCP | S3-compatible API |
| 9001 | console | TCP | MinIO web console |

**K8s Service:** `minio.data.svc.cluster.local:9000`

---

### Host Network (exposed via k3d)

| Port | Service | Purpose |
|------|---------|---------|
| 80 | Ingress | HTTP traffic to cluster |
| 443 | Ingress | HTTPS traffic to cluster |
| 4222 | NATS | Direct NATS access for testing |
| 4223 | NATS | Direct NATS cluster access |
| 5000 | Registry | Container image registry |
| 6443 | Kubernetes API | kubectl access |

---

## Connection Flow Diagrams

### Browser Client (gRPC-Web)
```
Browser → :80/:443 (Ingress) → :8080 (Envoy) → :50051/:50052 (gRPC services)
Browser → :80/:443 (Ingress) → :8081 (WebSocket) → messaging-service
```

### Mobile/Desktop Client (native gRPC)
```
Client → :50051 (auth-service) → Authentication
Client → :50052 (messaging-service) → Messaging
Client → :8081 (messaging-service) → WebSocket real-time
```

### Internal Service Communication
```
messaging-service → :4222 (NATS) → Event streaming
messaging-service → :2379 (PD) → :20160 (TiKV) → Key-value storage
messaging-service → :9042 (ScyllaDB) → Message history
media-service → :9000 (MinIO) → File storage
```

---

## Port Allocation Strategy

### Reserved Ranges

| Range | Purpose |
|-------|---------|
| 50051-50059 | gRPC backend services |
| 8080-8089 | HTTP/WebSocket services |
| 9000-9099 | Metrics & admin endpoints |
| 2379-2380 | TiKV PD |
| 20160-20169 | TiKV nodes |
| 4222-4223 | NATS |
| 9042 | ScyllaDB |

### Future Allocations

| Port | Reserved For |
|------|--------------|
| 50055 | call-service (WebRTC signaling) |
| 50056 | group-service (if separated) |
| 8082 | WebSocket for calls |
| 3478 | TURN server (WebRTC) |
| 5349 | TURN TLS |

---

## Environment Variables

Services read port configuration from environment variables:

```bash
# Auth Service
GUARDYN_PORT=50051

# Messaging Service
GUARDYN_PORT=50052
WEBSOCKET_PORT=8081
ENABLE_WEBSOCKET=true

# Presence Service
GUARDYN_PORT=50053

# Media Service
GUARDYN_PORT=50054

# Database connections
GUARDYN_DATABASE__TIKV_PD_ENDPOINTS=pd.data.svc.cluster.local:2379
GUARDYN_DATABASE__SCYLLADB_NODES=guardyn-scylla-client.data.svc.cluster.local:9042
GUARDYN_MESSAGING__NATS_URL=nats://nats.messaging.svc.cluster.local:4222
```

---

## Security Considerations

1. **Internal ports only** (50051-50054, 8081): Not exposed outside cluster, accessed via Ingress
2. **Admin ports** (9901, 9001): Should be restricted in production
3. **Database ports** (2379, 20160, 9042): Never expose to public internet
4. **WebSocket** (8081): Requires JWT authentication on connect

---

*Last updated: November 30, 2025*
