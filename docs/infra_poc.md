# Infrastructure PoC Guide — Variant 1 MVP

## 1. Overview

Objective: stand up a reproducible local environment mirroring production topology — Kubernetes control plane, data layer (FoundationDB + ScyllaDB), messaging fabric (NATS JetStream), observability stack, and CI/CD pipeline providing deterministic builds and security checks.

## 2. Prerequisites

- Host OS: Linux (kernel >= 5.10). Install packages `docker`, `kubectl`, `helm`, `kustomize`, `age`, `sops`.
- Tooling:
  - [`k3d`](https://k3d.io/) for lightweight Kubernetes clusters.
  - [`just`](https://github.com/casey/just) command runner for scripted workflows.
  - [`direnv`](https://direnv.net/) to manage environment secrets.
  - [`nix`](https://nixos.org/) for reproducible build environments.
  - [`cosign`](https://github.com/sigstore/cosign) for image signing.
  - [`task`](https://taskfile.dev/) optional alternative runner for CI parity.
- GitHub repository prepared with GitHub Actions runners (one cloud-hosted, one self-hosted with Docker privileges).

## 3. Repository Layout

```text
.
├── infra
│   ├── k8s
│   │   ├── base
│   │   │   ├── namespaces
│   │   │   ├── cert-manager
│   │   │   ├── cilium
│   │   │   ├── nats
│   │   │   ├── foundationdb
│   │   │   ├── scylladb
│   │   │   └── monitoring
│   │   └── overlays
│   │       ├── local
│   │       └── prod
│   ├── justfile
│   ├── k3d-config.yaml
│   └── secrets
│       ├── README.md
│       └── age-key.txt (gitignored)
├── cicd
│   ├── github
│   │   ├── workflows
│   │   │   ├── build.yml
│   │   │   ├── test.yml
│   │   │   └── release.yml
│   │   └── actions
│   │       └── reproducible-build
│   └── docker
│       └── Dockerfile.ci
└── docs
    └── infra_poc.md
```

## 4. Local Kubernetes PoC

### 4.1 Create Cluster

```bash
just kube:create # wraps k3d cluster create --config infra/k3d-config.yaml
```

- `k3d-config.yaml` sets 3 server nodes, 2 agent nodes, load balancer, registry mirror.
- Enable Cilium CNI with eBPF datapath for realistic networking.

### 4.2 Bootstrap Base Components

```bash
just kube:bootstrap
```

Steps executed:

1. Install CRDs: cert-manager, Cilium, FoundationDB operator, Scylla operator, NATS JetStream operator.
2. Apply namespaces: `platform`, `data`, `messaging`, `observability`, `apps`.
3. Configure storage class using `local-path-provisioner` for PoC, placeholder for Ceph/Rook in prod.

### 4.3 Deploy Messaging Layer

```bash
just k8s:deploy nats
```

- Installs NATS JetStream via Helm.
- Configures cluster of 3 pods, memory storage with file-backed persistence for PoC.
- Exposes monitoring endpoint on ClusterIP + ServiceMonitor for Prometheus.

### 4.4 Deploy Data Stores

```bash
just k8s:deploy foundationdb
just k8s:deploy scylladb
```

- FoundationDB: 3 storage pods, 3 stateless pods, fault domain simulated via node labels.
- ScyllaDB: 3-node rack-aware setup.
- Seed secrets created with `sops` encrypted manifests (`infra/secrets/data.yaml`).

### 4.5 Observability Stack

```bash
just k8s:deploy observability
```

- Deploys Prometheus Operator, Loki, Tempo, Grafana, OpenTelemetry Collector.
- Sets default dashboards for service latency, resource usage, and message throughput.

### 4.6 Smoke Tests

```bash
just verify:kube
```

- Validates Pod readiness, runs `kubectl port-forward` to run NATS publish/subscribe tests, FoundationDB status check (`fdbcli --exec status minimal`), Scylla health via `nodetool status`.

## 5. Secrets and Configuration Management

- Generate AGE key for SOPS:

  ```bash
  age-keygen -o infra/secrets/age-key.txt
  ```

- Export public key to `.sops.yaml` for encrypted manifests.
- Store CI secrets in Vault (dev mode for PoC) with dynamic lease for FoundationDB/Scylla credentials.
- Direnv loads `.envrc` with development credentials, referencing `age` key securely (never committed).

## 6. Reproducible Build Environment

### 6.1 Nix Flake

`flake.nix` defines build inputs: Rust toolchain (via `oxalica`), cargo-audit, cargo-deny, protobuf compilers, wasm-pack.

```nix
packages.default = pkgs.mkShell {
  nativeBuildInputs = [ pkgs.cargo pkgs.rustc pkgs.rustfmt pkgs.clippy pkgs.cargo-audit pkgs.cargo-deny pkgs.protobuf pkgs.wasm-pack ];
  RUSTFLAGS = "-C target-cpu=native";
};
```

- Developers run `nix develop` for consistent toolchain.
- CI uses `nix build .#app` to generate deterministic binaries.

### 6.2 Container Images

- Base image: Wolfi-based minimal `Dockerfile` pinned by digest.
- Build via `ko` or `nix build` to OCI, sign with Cosign.
- Store provenance using `cosign attest` with SLSA Level 2 predicate.

## 7. CI/CD Pipeline

### 7.1 GitHub Actions Workflows

**`build.yml`**

- Trigger: PR.
- Jobs: lint (rustfmt/clippy), unit tests, cargo-audit, cargo-deny.
- Uses `nix develop` cache for reproducible toolchain.

**`test.yml`**

- Trigger: push to `main`.
- Integration tests with ephemeral `k3d` cluster (spun up via `actions-runner-controller` self-hosted runner).
- Runs end-to-end tests hitting NATS + FoundationDB (using `kubectl port-forward`).

**`release.yml`**

- Trigger: tag.
- Build release binaries via `nix build`, produce SBOM (Syft), sign artifacts with Cosign, publish to container registry + GitHub Releases.
- Generate provenance (`cosign attest`), upload reproducible build logs.

### 7.2 Security Gates

- `cargo audit`, `cargo deny` for dependencies.
- `trivy fs` and `trivy image` scans; fail on high severity CVEs.
- `gitleaks` pre-commit/CI.
- `slsa-verifier` to validate provenance before deploy.

### 7.3 Deployment Automation

- ArgoCD (local install) watches `infra/k8s/overlays/local`.
- On successful CI, workflow updates container tag in `kustomization.yaml` via PR bot; ArgoCD syncs environment.

## 8. Developer Experience

- `just up`: bundle `nix develop`, `direnv allow`, `k3d` cluster creation, Helm chart installs.
- `just teardown`: destroy cluster, clean volumes.
- Pre-commit hooks enforce formatting, SOPS encryption checks, commit message linting.

## 9. Next Steps After PoC

1. Harden etcd / replace k3d with Talos or kubeadm cluster for staging.
2. Introduce service mesh (Linkerd) with mutual TLS.
3. Configure external secret management (Vault + external-secrets operator).
4. Expand observability with distributed tracing (Tempo) integration into Rust services.
5. Update CI/CD to include fuzz testing (cargo fuzz) and chaos scenarios (LitmusChaos) before beta.
