# Developer Quick Start Guide

Welcome to Guardyn! This guide will help you get productive quickly.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Setup (10 minutes)](#quick-setup-10-minutes)
- [Development Workflows](#development-workflows)
- [Project Structure](#project-structure)
- [Common Tasks](#common-tasks)
- [Troubleshooting](#troubleshooting)
- [Essential Documentation](#essential-documentation)

---

## Prerequisites

| Requirement | Version | Notes                                                              |
| ----------- | ------- | ------------------------------------------------------------------ |
| **Nix**     | 2.18+   | [Install Nix](https://nixos.org/download.html) with flakes enabled |
| **Docker**  | 24+     | Or Podman 4+                                                       |
| **RAM**     | 16GB+   | 8GB minimum for reduced mode                                       |
| **kubectl** | 1.28+   | Included in Nix shell                                              |
| **Flutter** | 3.19+   | For client development                                             |

### Enable Nix Flakes

```bash
# Add to ~/.config/nix/nix.conf
experimental-features = nix-command flakes
```

---

## Quick Setup (10 minutes)

### Step 1: Clone and Enter Environment

```bash
git clone https://github.com/guardyn/guardyn.git
cd guardyn

# Enter reproducible development shell (installs all tools)
nix develop
```

### Step 2: Start Kubernetes Cluster

```bash
# Create local k3d cluster
just kube-create

# Bootstrap core components (CRDs, namespaces, operators)
just kube-bootstrap

# Deploy all services
just k8s-deploy nats
just k8s-deploy tikv
just k8s-deploy scylladb
just k8s-deploy monitoring
kubectl apply -k infra/k8s/overlays/local

# Verify everything is running
just verify-kube
```

### Step 3: Optimize for Development (Recommended)

```bash
# Reduce replicas for local development (saves ~5 pods)
just scale-dev

# Start port-forwarding to databases
just port-forward
```

### Step 4: Verify Setup

```bash
# Check pod status
kubectl get pods -n apps
kubectl get pods -n data

# Expected output:
# - auth-service: 1/1 Running
# - messaging-service: 1/1 Running
# - presence-service: 1/1 Running
# - media-service: 1/1 Running
# - envoy: 1/1 Running
```

---

## Development Workflows

### Backend Development (Rust)

**Option A: Local Services (Fastest - Recommended)**

Run services locally with database connections to cluster:

```bash
# IMPORTANT: Stop k8s services first to avoid conflicts
kubectl scale deployment messaging-service -n apps --replicas=0
kubectl scale deployment auth-service -n apps --replicas=0

# Terminal 1: Start port-forwards
just dev-ports

# Terminal 2: Run specific service
just dev-auth        # Auth service on :50051
just dev-messaging   # Messaging service on :50052
just dev-presence    # Presence service on :50053
just dev-media       # Media service on :50054

# Hot-reload (requires cargo-watch)
cargo install cargo-watch
just dev-watch auth-service
```

> ⚠️ **Important**: If both k8s and local services are running, NATS message
> consumers will compete, causing real-time WebSocket delivery to fail.
> Always scale k8s deployments to 0 before running locally.

**Rebuild time: ~5-10 seconds** (vs ~60+ seconds with Docker)

**Option B: Full Kubernetes Deployment**

Build and deploy to cluster:

```bash
cd backend

# Build all services
./build-docker.sh

# Deploy to cluster
bash infra/scripts/build-and-deploy-services.sh
```

### Frontend Development (Flutter)

```bash
cd client

# Get dependencies
flutter pub get

# Generate protobuf code
./scripts/generate-protos.sh

# Run on connected Android/iOS device
flutter run

# For Desktop (Windows/macOS/Linux) use Tauri:
cd ../client-desktop && npm run tauri dev

# Run tests
flutter test
```

### Running Tests

```bash
# Backend unit tests
cd backend && cargo test

# Backend E2E tests
just test-messaging

# Flutter tests
cd client && flutter test

# Integration tests
cd client && flutter test integration_test
```

---

## Project Structure

```
guardyn/
├── backend/                 # Rust backend services
│   ├── crates/
│   │   ├── auth-service/    # Authentication, user management
│   │   ├── messaging-service/ # Messages, groups, E2EE
│   │   ├── presence-service/ # Online status, typing indicators
│   │   ├── media-service/   # File uploads, thumbnails
│   │   ├── common/          # Shared utilities
│   │   ├── crypto/          # X3DH, Double Ratchet, OpenMLS
│   │   └── e2e-tests/       # Integration tests
│   └── proto/               # Protocol Buffers definitions
│
├── client-mobile/           # Flutter multi-platform client
│   ├── lib/
│   │   ├── core/           # DI, routing, theme
│   │   ├── features/       # Feature modules (auth, messaging, etc.)
│   │   └── shared/         # Shared widgets, utils
│   └── test/               # Unit and widget tests
│
├── infra/                   # Infrastructure as Code
│   ├── k8s/
│   │   ├── base/           # Base Kubernetes manifests
│   │   └── overlays/       # Environment-specific configs
│   └── scripts/            # Deployment and utility scripts
│
├── docs/                    # Documentation
├── landing/                 # Landing page
└── Justfile                 # Task runner commands
```

---

## Common Tasks

### Daily Development Commands

```bash
# Start development environment
nix develop
just port-forward

# Build backend
cd backend && cargo build

# Run specific service locally
just dev-auth

# Check logs
kubectl logs -f deployment/auth-service -n apps

# Restart a service
kubectl rollout restart deployment/messaging-service -n apps
```

### Database Access

```bash
# TiKV (via pd-ctl)
kubectl exec -it pd-0 -n data -- pd-ctl -u http://localhost:2379 store

# ScyllaDB (cqlsh)
kubectl exec -it guardyn-scylla-dc1-rack1-0 -n data -- cqlsh

# NATS
kubectl exec -it deployment/nats-box -n messaging -- nats sub ">"
```

### Monitoring

```bash
# Grafana dashboards
kubectl port-forward svc/grafana -n observability 3000:3000
# Open: http://localhost:3000 (admin/admin)

# Prometheus metrics
kubectl port-forward svc/prometheus -n observability 9090:9090
```

### Resource Management

```bash
# View current resource usage
just resources

# Scale down for development
just scale-dev

# Restore production replicas
just scale-prod
```

---

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -A

# Check events
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs <pod-name> -n <namespace>
```

### Database Connection Issues

```bash
# Verify port-forwards
just dev-status

# Restart port-forwards
just dev-stop
just dev-ports

# Check database pods
kubectl get pods -n data
```

### Build Failures

```bash
# Clean Rust build cache
cd backend && cargo clean

# Regenerate proto files
cd backend && cargo build --bin auth-service

# Clear Flutter cache
cd client && flutter clean && flutter pub get
```

### Cluster Issues

```bash
# Restart cluster
just teardown
just kube-create
just kube-bootstrap

# Fix after system restart
bash infra/scripts/fix-cluster-after-restart.sh
```

---

## Essential Documentation

### Getting Started

| Document                                   | Description                     |
| ------------------------------------------ | ------------------------------- |
| **[This Guide](DEVELOPER_QUICKSTART.md)**  | Quick start for new developers  |
| [DEV_OPTIMIZATION.md](DEV_OPTIMIZATION.md) | Speed up local development      |
| [DOCKER_DEV_GUIDE.md](DOCKER_DEV_GUIDE.md) | Docker Compose development guide|

### Architecture

| Document                                                 | Description                                          |
| -------------------------------------------------------- | ---------------------------------------------------- |
| [ARCHITECTURE.md](ARCHITECTURE.md)                       | System architecture with diagrams                    |
| [ENCRYPTION_ARCHITECTURE.md](ENCRYPTION_ARCHITECTURE.md) | Cryptography details (X3DH, Double Ratchet, OpenMLS) |
| [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md)                 | TiKV and ScyllaDB schemas                            |
| [GRPC_API.md](GRPC_API.md)                               | gRPC service APIs                                    |

### Testing

| Document                                           | Description                    |
| -------------------------------------------------- | ------------------------------ |
| [TESTING_GUIDE.md](TESTING_GUIDE.md)               | Complete testing documentation |
| [QUICKSTART_TESTING.md](QUICKSTART_TESTING.md)     | Quick testing reference        |
| [CLIENT_TESTING_GUIDE.md](CLIENT_TESTING_GUIDE.md) | Flutter client testing         |
| [TWO_CLIENT_TESTING.md](TWO_CLIENT_TESTING.md)     | Multi-client E2EE testing      |

### Operations

| Document                                         | Description            |
| ------------------------------------------------ | ---------------------- |
| [PORT_MAPPING.md](PORT_MAPPING.md)               | All service ports      |
| [OBSERVABILITY_GUIDE.md](OBSERVABILITY_GUIDE.md) | Monitoring and logging |
| [DOCKER_BUILD_GUIDE.md](DOCKER_BUILD_GUIDE.md)   | Building Docker images |

### Planning

| Document                                         | Description                     |
| ------------------------------------------------ | ------------------------------- |
| [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) | Technical roadmap               |
| [mvp_discovery.md](mvp_discovery.md)             | Product vision and user stories |

---

## Code Conventions

### Language Policy

**All code and documentation MUST be in English.** See [copilot-instructions.md](../.github/copilot-instructions.md) for details.

### Rust

- Follow `rustfmt` and `clippy` conventions
- Use `cargo fmt` before committing
- Proto enum values: use PascalCase (e.g., `ErrorCode::InternalError`)

### Flutter/Dart

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `dart format` before committing
- Feature-based folder structure

### Git

- Conventional Commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`
- Branch naming: `feature/`, `fix/`, `docs/`
- PRs require passing CI checks

---

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/guardyn/guardyn/issues)
- **Contact**: See [CONTACT.md](CONTACT.md)
- **Security**: See [SECURITY.md](../SECURITY.md)

---

## Next Steps

1. ✅ Complete this Quick Start
2. 📖 Read [ARCHITECTURE.md](ARCHITECTURE.md) for system overview
3. 🔐 Review [ENCRYPTION_ARCHITECTURE.md](ENCRYPTION_ARCHITECTURE.md) for crypto details
4. ⚡ Set up [DEV_OPTIMIZATION.md](DEV_OPTIMIZATION.md) for fast iteration
5. 🧪 Run tests using [TESTING_GUIDE.md](TESTING_GUIDE.md)

Welcome to the team! 🎉
