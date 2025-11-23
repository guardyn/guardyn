# Guardyn Architecture

This document provides a comprehensive overview of the Guardyn platform architecture using Mermaid diagrams.

## High-Level Architecture Overview

```mermaid
graph TB
    subgraph "Client Layer"
        WebApp[Web Application<br/>Flutter Web]
        MobileApp[Mobile Apps<br/>Flutter iOS/Android]
        DesktopApp[Desktop Apps<br/>Flutter Desktop]
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
        end
    end

    subgraph "Data Layer"
        subgraph "data namespace"
            TiKV[(TiKV<br/>Distributed KV Store<br/>Transactional Data)]
            ScyllaDB[(ScyllaDB<br/>Wide Column Store<br/>Message History)]
        end
    end

    subgraph "Messaging Infrastructure"
        subgraph "messaging namespace"
            NATS[NATS JetStream<br/>Event Streaming<br/>Real-time Communication]
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
    WebApp -->|gRPC-Web/HTTP| Envoy
    MobileApp -->|Native gRPC| LB
    DesktopApp -->|Native gRPC| LB

    %% Edge Routing
    Envoy -->|gRPC| Auth
    Envoy -->|gRPC| Messaging
    LB --> Auth
    LB --> Messaging
    LB --> Media
    LB --> Presence
    LB --> Notification

    %% Service Dependencies
    Auth --> TiKV
    Auth --> NATS
    Messaging --> TiKV
    Messaging --> ScyllaDB
    Messaging --> NATS
    Media --> TiKV
    Media --> ScyllaDB
    Presence --> TiKV
    Presence --> NATS
    Notification --> NATS

    %% Observability
    Auth -.->|metrics| Prometheus
    Messaging -.->|metrics| Prometheus
    Media -.->|metrics| Prometheus
    Presence -.->|metrics| Prometheus
    Notification -.->|metrics| Prometheus

    Auth -.->|logs| Loki
    Messaging -.->|logs| Loki
    Media -.->|logs| Loki
    Presence -.->|logs| Loki
    Notification -.->|logs| Loki

    Auth -.->|traces| Tempo
    Messaging -.->|traces| Tempo
    Media -.->|traces| Tempo

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

    style WebApp fill:#4A90E2
    style MobileApp fill:#4A90E2
    style DesktopApp fill:#4A90E2
    style Auth fill:#50C878
    style Messaging fill:#50C878
    style Media fill:#50C878
    style Presence fill:#50C878
    style Notification fill:#50C878
    style TiKV fill:#FF6B6B
    style ScyllaDB fill:#FF6B6B
    style NATS fill:#FFD93D
    style Envoy fill:#9B59B6
```

## Security Architecture

```mermaid
graph LR
    subgraph "Client-Side Cryptography"
        Client[Client Device]
        X3DH[X3DH Key Exchange<br/>Kyber + ECDH P-256]
        DR[Double Ratchet<br/>1:1 Encryption]
        MLS[OpenMLS<br/>Group Encryption]
        SFrame[SFrame<br/>Media Encryption]
    end

    subgraph "Key Management"
        Auth[Auth Service]
        KeyStore[(TiKV<br/>Key Bundles<br/>Pre-keys<br/>MLS Packages)]
    end

    subgraph "Secure Communication"
        E2EEMsg[Encrypted Messages]
        E2EEMedia[Encrypted Media]
        E2EECall[Encrypted Calls]
    end

    Client --> X3DH
    X3DH --> DR
    X3DH --> MLS
    Client --> SFrame

    DR --> E2EEMsg
    MLS --> E2EEMsg
    SFrame --> E2EECall
    SFrame --> E2EEMedia

    Client -->|Upload Keys| Auth
    Auth --> KeyStore
    Client -->|Fetch Keys| Auth

    E2EEMsg -->|Encrypted Payload| Messaging[Messaging Service]
    E2EEMedia -->|Encrypted Payload| Media[Media Service]
    E2EECall -->|Encrypted Streams| Media

    style X3DH fill:#FFD93D
    style DR fill:#FFD93D
    style MLS fill:#FFD93D
    style SFrame fill:#FFD93D
    style E2EEMsg fill:#50C878
    style E2EEMedia fill:#50C878
    style E2EECall fill:#50C878
```

## Data Flow Architecture

```mermaid
sequenceDiagram
    participant Client
    participant Envoy
    participant Auth
    participant Messaging
    participant NATS
    participant TiKV
    participant ScyllaDB
    participant Recipient

    Note over Client,ScyllaDB: User Registration & Key Upload
    Client->>+Auth: Register(username, identity_key)
    Auth->>TiKV: Store user identity
    Auth->>TiKV: Store key bundle
    Auth-->>-Client: JWT token

    Note over Client,ScyllaDB: Secure Messaging Flow
    Client->>+Auth: GetKeyBundle(recipient_id)
    Auth->>TiKV: Fetch recipient keys
    Auth-->>-Client: Key bundle

    Client->>Client: X3DH key exchange<br/>Generate shared secret
    Client->>Client: Encrypt message<br/>(Double Ratchet)

    Client->>+Envoy: SendMessage(encrypted_payload)
    Envoy->>+Messaging: gRPC SendMessage
    Messaging->>TiKV: Store message metadata
    Messaging->>ScyllaDB: Store encrypted message
    Messaging->>NATS: Publish message event
    Messaging-->>-Envoy: Message ID
    Envoy-->>-Client: Success

    NATS-->>Recipient: Real-time message notification
    Recipient->>+Messaging: ReceiveMessages(stream)
    Messaging->>ScyllaDB: Fetch encrypted messages
    Messaging-->>-Recipient: Encrypted messages
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
            Messaging[messaging<br/>NATS JetStream]
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
      Flutter
        Web
        iOS
        Android
        Desktop
      gRPC-Web
    Backend Services
      Rust
        Tokio async runtime
        tonic gRPC
        prost Protocol Buffers
      Security
        X3DH key exchange
        Double Ratchet encryption
        OpenMLS group encryption
        SFrame media encryption
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
    Messaging
      NATS JetStream
        Event streaming
        Real-time communication
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

        subgraph "Web Browser"
            Browser[Browser Client]
            GRPCWeb[gRPC-Web Protocol<br/>HTTP/1.1 or HTTP/2]
        end

        subgraph "Native Apps"
            Mobile[Mobile/Desktop Client]
            NativeGRPC[Native gRPC<br/>HTTP/2 + gRPC Framing]
        end
    end

    subgraph "Gateway Layer"
        Envoy[Envoy Proxy<br/>:8080<br/>gRPC-Web → gRPC]
        Ingress[k8s Ingress<br/>:443<br/>TLS Termination]
    end

    subgraph "Service Communication"
        direction TB
        Services[Backend Services]
        Internal[Internal gRPC<br/>ClusterIP Services]
    end

    subgraph "Event-Driven"
        NATS[NATS JetStream<br/>Pub/Sub<br/>Real-time Events]
    end

    Browser --> GRPCWeb
    GRPCWeb -->|HTTP| Envoy

    Mobile --> NativeGRPC
    NativeGRPC -->|gRPC/TLS| Ingress

    Envoy -->|gRPC| Services
    Ingress -->|gRPC| Services

    Services <-->|gRPC| Internal
    Services -->|Publish| NATS
    Services <-->|Subscribe| NATS

    style Browser fill:#4A90E2
    style Mobile fill:#4A90E2
    style Envoy fill:#9B59B6
    style Services fill:#50C878
    style NATS fill:#FFD93D
```

## Key Design Principles

1. **Privacy-First**: End-to-end encryption for all user communications using X3DH, Double Ratchet, and OpenMLS
2. **Reproducible Builds**: Nix flakes ensure deterministic builds and audit-ready artifacts
3. **Kubernetes-Native**: All infrastructure managed with Kustomize and Helm operators
4. **Domain-Agnostic**: Single `DOMAIN` variable configures all services for any deployment
5. **Observability**: Comprehensive metrics, logs, and traces via Prometheus, Loki, and Tempo
6. **Security by Design**: SOPS encryption for secrets, Cosign signing for artifacts, regular security audits
7. **Local Development Parity**: k3d clusters mirror production topology for consistent testing
8. **Microservices Architecture**: Independently deployable services with clear boundaries
9. **Event-Driven Communication**: NATS JetStream for real-time messaging and loose coupling
10. **Multi-Platform Support**: Flutter clients for web, mobile, and desktop with unified codebase
