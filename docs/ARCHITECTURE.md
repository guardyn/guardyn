# Guardyn Architecture

This document provides a comprehensive overview of the Guardyn platform architecture using Mermaid diagrams.

## High-Level Architecture Overview

```mermaid
graph TB
    subgraph "Client Layer"
        MobileApp[Mobile Apps<br/>Flutter iOS/Android]
        DesktopApp[Desktop Apps<br/>Tauri Win/Mac/Linux]
    end

    subgraph "Edge Layer"
        Envoy[Envoy Proxy<br/>gRPC-Web Gateway]
        LB[Load Balancer<br/>k3d/Ingress]
    end

    subgraph "Application Services - Kubernetes Cluster"
        subgraph "apps namespace"
            Auth[Auth Service<br/>:50051<br/>User Auth & Key Management]
            Messaging[Messaging Service<br/>:50052<br/>E2EE Messages]
            Media[Media Service<br/>:50053<br/>Encrypted Media]
            Presence[Presence Service<br/>:50054<br/>User Status]
            Notification[Notification Service<br/>:50055<br/>Push Notifications]
            Call[Call Service<br/>:50056<br/>WebRTC Signaling & SFU]
        end
    end

    subgraph "Data Layer"
        subgraph "data namespace"
            TiKV[(TiKV<br/>Distributed KV Store<br/>Transactional Data)]
            ScyllaDB[(ScyllaDB<br/>Wide Column Store<br/>Message History)]
        end
    end

    subgraph "Event Streaming"
        subgraph "messaging namespace"
            Redpanda[Redpanda<br/>Kafka-Compatible<br/>Event Streaming]
        end
    end

    subgraph "Observability Stack"
        subgraph "observability namespace"
            Prometheus[Prometheus<br/>Metrics Collection]
            Loki[Loki<br/>Log Aggregation]
            Tempo[Tempo<br/>Distributed Tracing]
            Grafana[Grafana<br/>Dashboards]
        end
    end

    subgraph "Platform Services"
        subgraph "platform namespace"
            CertManager[cert-manager<br/>TLS Certificate Management]
            Cilium[Cilium CNI<br/>eBPF Networking]
        end
    end

    %% Client Connections
    MobileApp -->|Native gRPC| LB
    DesktopApp -->|Native gRPC| LB

    %% Edge Routing
    LB --> Auth
    LB --> Messaging
    LB --> Media
    LB --> Presence
    LB --> Notification
    LB --> Call

    %% Service Dependencies
    Auth --> TiKV
    Auth --> Redpanda
    Messaging --> TiKV
    Messaging --> ScyllaDB
    Messaging --> Redpanda
    Media --> TiKV
    Media --> ScyllaDB
    Presence --> TiKV
    Presence --> Redpanda
    Notification --> Redpanda
    Call --> Redpanda
    Call --> TiKV

    %% Observability
    Auth -.->|metrics| Prometheus
    Messaging -.->|metrics| Prometheus
    Media -.->|metrics| Prometheus
    Presence -.->|metrics| Prometheus
    Notification -.->|metrics| Prometheus
    Call -.->|metrics| Prometheus

    Auth -.->|logs| Loki
    Messaging -.->|logs| Loki
    Media -.->|logs| Loki
    Presence -.->|logs| Loki
    Notification -.->|logs| Loki
    Call -.->|logs| Loki

    Auth -.->|traces| Tempo
    Messaging -.->|traces| Tempo
    Media -.->|traces| Tempo
    Call -.->|traces| Tempo

    Prometheus --> Grafana
    Loki --> Grafana
    Tempo --> Grafana

    %% Platform Services
    CertManager -.->|TLS certs| LB
    Cilium -.->|network policy| Auth
    Cilium -.->|network policy| Messaging
    Cilium -.->|network policy| Media
    Cilium -.->|network policy| Presence
    Cilium -.->|network policy| Notification
    Cilium -.->|network policy| Call

    style MobileApp fill:#4A90E2
    style DesktopApp fill:#4A90E2
    style Auth fill:#50C878
    style Messaging fill:#50C878
    style Media fill:#50C878
    style Presence fill:#50C878
    style Notification fill:#50C878
    style Call fill:#50C878
    style TiKV fill:#FF6B6B
    style ScyllaDB fill:#FF6B6B
    style Redpanda fill:#FFD93D
    style Envoy fill:#9B59B6
```

## Security Architecture

```mermaid
graph LR
    subgraph "Client-Side Cryptography (guardyn-crypto)"
        Client[Client Device]
        PQXDH[PQXDH Key Exchange<br/>ML-KEM-768 + X25519]
        DR[Double Ratchet<br/>1:1 Encryption]
        MLS[OpenMLS<br/>Group Encryption]
        SFrame[SFrame<br/>Media Encryption]
        SS[Sealed Sender<br/>Metadata Protection]
    end

    subgraph "Key Management"
        Auth[Auth Service]
        KeyStore[(TiKV<br/>Key Bundles<br/>Pre-keys<br/>MLS Packages)]
        HW[Hardware Key Storage<br/>Secure Enclave/KeyStore]
    end

    subgraph "Secure Communication"
        E2EEMsg[Encrypted Messages<br/>PADMÉ Padding]
        E2EEMedia[Encrypted Media]
        E2EECall[Encrypted Calls]
    end

    Client --> PQXDH
    PQXDH --> DR
    PQXDH --> MLS
    Client --> SFrame
    Client --> SS

    DR --> E2EEMsg
    MLS --> E2EEMsg
    SFrame --> E2EECall
    SFrame --> E2EEMedia
    SS --> E2EEMsg

    Client <-->|Identity Keys| HW
    Client -->|Upload Keys| Auth
    Auth --> KeyStore
    Client -->|Fetch Keys| Auth

    E2EEMsg -->|Encrypted Payload| Messaging[Messaging Service]
    E2EEMedia -->|Encrypted Payload| Media[Media Service]
    E2EECall -->|Encrypted Streams| Call[Call Service]

    style PQXDH fill:#FFD93D
    style DR fill:#FFD93D
    style MLS fill:#FFD93D
    style SFrame fill:#FFD93D
    style SS fill:#FFD93D
    style E2EEMsg fill:#50C878
    style E2EEMedia fill:#50C878
    style E2EECall fill:#50C878
    style HW fill:#9B59B6
```

## Data Flow Architecture

```mermaid
sequenceDiagram
    participant Client
    participant Envoy
    participant Auth
    participant Messaging
    participant Redpanda
    participant TiKV
    participant ScyllaDB
    participant Recipient

    Note over Client,ScyllaDB: User Registration & Key Upload
    Client->>+Auth: Register(username, identity_key)
    Auth->>TiKV: Store user identity
    Auth->>TiKV: Store key bundle (PQXDH keys)
    Auth-->>-Client: JWT token

    Note over Client,ScyllaDB: Secure Messaging Flow
    Client->>+Auth: GetKeyBundle(recipient_id)
    Auth->>TiKV: Fetch recipient keys
    Auth-->>-Client: Key bundle (ML-KEM + X25519)

    Client->>Client: PQXDH key exchange<br/>Generate shared secret
    Client->>Client: Encrypt message<br/>(Double Ratchet + PADMÉ)
    Client->>Client: Apply Sealed Sender

    Client->>+Envoy: SendMessage(sealed_payload)
    Envoy->>+Messaging: gRPC SendMessage
    Messaging->>TiKV: Store message metadata
    Messaging->>ScyllaDB: Store encrypted message
    Messaging->>Redpanda: Publish message event
    Messaging-->>-Envoy: Message ID
    Envoy-->>-Client: Success

    Redpanda-->>Recipient: Real-time message notification
    Recipient->>+Messaging: ReceiveMessages(stream)
    Messaging->>ScyllaDB: Fetch encrypted messages
    Messaging-->>-Recipient: Sealed messages
    Recipient->>Recipient: Unseal Sender
    Recipient->>Recipient: Decrypt with Double Ratchet
```

## Kubernetes Deployment Architecture

```mermaid
graph TB
    subgraph "k3d Cluster - Local Development"
        subgraph "Control Plane"
            Server1[k3d-server-0]
            Server2[k3d-server-1]
            Server3[k3d-server-2]
        end

        subgraph "Worker Nodes"
            Agent1[k3d-agent-0]
            Agent2[k3d-agent-1]
        end

        subgraph "Namespaces"
            direction TB
            Platform[platform<br/>cert-manager, Cilium]
            Data[data<br/>TiKV, ScyllaDB]
            Messaging[messaging<br/>Redpanda]
            Apps[apps<br/>Backend Services]
            Observability[observability<br/>Prometheus, Loki, Tempo, Grafana]
        end
    end

    subgraph "External Components"
        Registry[Local Registry<br/>guardyn-registry:5000]
        LoadBalancer[Load Balancer<br/>localhost:80/443]
    end

    subgraph "Persistent Storage"
        LocalPath[local-path-provisioner<br/>PersistentVolumes]
    end

    Server1 --> Platform
    Server1 --> Data
    Server1 --> Messaging
    Server2 --> Apps
    Server3 --> Observability

    Agent1 --> Apps
    Agent2 --> Apps

    Registry -.->|Pull Images| Apps
    Registry -.->|Pull Images| Data
    Registry -.->|Pull Images| Messaging

    LoadBalancer --> Apps

    Data --> LocalPath
    Messaging --> LocalPath

    style Platform fill:#E8F5E9
    style Data fill:#FFE0B2
    style Messaging fill:#FFF9C4
    style Apps fill:#C5E1A5
    style Observability fill:#B3E5FC
```

## CI/CD Pipeline Architecture

```mermaid
graph LR
    subgraph "Development"
        Dev[Developer]
        LocalEnv[Local Environment<br/>Nix + k3d]
    end

    subgraph "GitHub Repository"
        Code[Source Code]
        PR[Pull Request]
        Main[main branch]
        Tag[Version Tag]
    end

    subgraph "GitHub Actions Workflows"
        Build[build.yml<br/>Lint, Test, Audit]
        Test[test.yml<br/>Integration Tests]
        Release[release.yml<br/>Build & Sign]
    end

    subgraph "Build Process"
        NixBuild[Nix Build<br/>Reproducible]
        CargoAudit[cargo-audit<br/>Security Scan]
        Trivy[Trivy<br/>Container Scan]
    end

    subgraph "Artifact Management"
        SBOM[SBOM Generation<br/>Syft]
        Cosign[Cosign Signing<br/>Provenance]
        Registry[Container Registry<br/>guardyn-registry]
        GitHub[GitHub Releases]
    end

    subgraph "Deployment"
        Kustomize[Kustomize<br/>Manifest Generation]
        K8s[Kubernetes Cluster]
    end

    Dev -->|Commit| Code
    Code --> PR
    PR --> Build
    Build --> NixBuild
    Build --> CargoAudit

    PR -->|Merge| Main
    Main --> Test
    Test --> NixBuild

    Main -->|Tag| Tag
    Tag --> Release
    Release --> NixBuild
    Release --> Trivy
    Release --> SBOM
    Release --> Cosign

    Cosign --> Registry
    Cosign --> GitHub

    Registry --> Kustomize
    Kustomize --> K8s

    LocalEnv -.->|Test Locally| Dev

    style NixBuild fill:#FFD93D
    style Cosign fill:#50C878
    style SBOM fill:#50C878
```

## Technology Stack

```mermaid
mindmap
  root((Guardyn<br/>Technology<br/>Stack))
    Frontend
      Flutter Mobile
        iOS
        Android
      Tauri Desktop
        Windows
        macOS
        Linux
      gRPC Native
    Backend Services
      Rust
        Tokio async runtime
        tonic gRPC
        prost Protocol Buffers
      guardyn-crypto
        PQXDH ML-KEM-768 + X25519
        Double Ratchet encryption
        OpenMLS group encryption
        SFrame media encryption
        Sealed Sender metadata protection
    Infrastructure
      Kubernetes
        k3d local clusters
        Cilium CNI with eBPF
        cert-manager TLS
      Deployment
        Kustomize manifests
        Helm for operators
    Data Layer
      TiKV
        Distributed KV store
        ACID transactions
      ScyllaDB
        Wide column store
        High throughput
    Event Streaming
      Redpanda
        Kafka-compatible API
        2-3M msg/sec throughput
        Tiered storage
    Observability
      Prometheus metrics
      Loki logs
      Tempo traces
      Grafana dashboards
    DevOps
      Nix
        Reproducible builds
        Deterministic tooling
      SOPS
        Secret encryption
        Age key management
      Cosign
        Artifact signing
        SLSA provenance
      GitHub Actions
        CI/CD workflows
        Automated testing
```

## Network Communication Patterns

```mermaid
graph TB
    subgraph "Client Communication Patterns"
        direction TB

        subgraph "Mobile Apps"
            Mobile[Flutter iOS/Android]
            MobileGRPC[Native gRPC<br/>HTTP/2 + gRPC Framing]
        end

        subgraph "Desktop Apps"
            Desktop[Tauri Win/Mac/Linux]
            DesktopGRPC[Native gRPC<br/>HTTP/2 + gRPC Framing]
        end
    end

    subgraph "Gateway Layer"
        Ingress[k8s Ingress<br/>:443<br/>TLS Termination]
    end

    subgraph "Service Communication"
        direction TB
        Services[Backend Services]
        Internal[Internal gRPC<br/>ClusterIP Services]
    end

    subgraph "Event-Driven"
        Redpanda[Redpanda<br/>Kafka Protocol<br/>Real-time Events]
    end

    Mobile --> MobileGRPC
    MobileGRPC -->|gRPC/TLS| Ingress

    Desktop --> DesktopGRPC
    DesktopGRPC -->|gRPC/TLS| Ingress

    Ingress -->|gRPC| Services

    Services <-->|gRPC| Internal
    Services -->|Publish| Redpanda
    Services <-->|Subscribe| Redpanda

    style Mobile fill:#4A90E2
    style Desktop fill:#4A90E2
    style Services fill:#50C878
    style Redpanda fill:#FFD93D
```

## Key Design Principles

1. **Privacy-First**: End-to-end encryption for all communications using PQXDH (ML-KEM-768), Double Ratchet, OpenMLS, and Sealed Sender
2. **Post-Quantum Ready**: ML-KEM-768 hybrid key exchange provides resistance against quantum computer attacks
3. **Reproducible Builds**: Nix flakes ensure deterministic builds and audit-ready artifacts
4. **Kubernetes-Native**: All infrastructure managed with Kustomize and Helm operators
5. **Domain-Agnostic**: Single `DOMAIN` variable configures all services for any deployment
6. **Observability**: Comprehensive metrics, logs, and traces via Prometheus, Loki, and Tempo
7. **Security by Design**: SOPS encryption for secrets, Cosign signing for artifacts, regular security audits
8. **Local Development Parity**: Docker Compose for fast local dev (~30s startup), k3d mirrors production topology
9. **Microservices Architecture**: Independently deployable services with clear boundaries
10. **Event-Driven Communication**: Redpanda (Kafka-compatible) for high-throughput real-time messaging
11. **Multi-Platform Support**: Flutter for mobile (iOS/Android), Tauri for desktop (Windows/macOS/Linux)
12. **Unified Cryptography**: guardyn-crypto Rust library shared across all platforms via FFI
