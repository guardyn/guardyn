---
name: 🏗️ Infrastructure/DevOps Issue
about: Report issues with infrastructure, deployment, or DevOps tooling
title: "[INFRA] "
labels: ["infrastructure", "needs-triage"]
assignees: ""
---

## Infrastructure Issue Description

<!-- Describe the infrastructure or DevOps issue -->

## Component

<!-- Which infrastructure component is affected? -->

- [ ] Kubernetes Cluster (k3d)
- [ ] Data Layer (TiKV, ScyllaDB)
- [ ] Messaging (NATS JetStream)
- [ ] Observability (Prometheus, Grafana, Loki, Tempo)
- [ ] Container Registry
- [ ] Networking (Cilium, Ingress)
- [ ] CI/CD Pipelines
- [ ] Nix Build Environment
- [ ] Secret Management (SOPS)
- [ ] Deployment Scripts
- [ ] Other: <!-- specify -->

## Issue Type

- [ ] Service not starting
- [ ] Configuration issue
- [ ] Resource constraints (CPU, memory, disk)
- [ ] Networking issue
- [ ] Deployment failure
- [ ] Build failure
- [ ] Performance degradation
- [ ] Monitoring/alerting issue
- [ ] Secret management issue
- [ ] Other: <!-- specify -->

## Environment

**Deployment Type:**

- [ ] Local Development (k3d)
- [ ] Staging
- [ ] Production
- [ ] CI/CD Environment

**Platform:**

- OS: <!-- e.g., Ubuntu 22.04, NixOS -->
- Kubernetes Version: <!-- e.g., k3s v1.28.4 -->
- k3d Version: <!-- if applicable -->
- Docker Version: <!-- if applicable -->
- Nix Version: <!-- if applicable -->

**Cluster Details:**

- Node Count: <!-- e.g., 3 servers + 2 agents -->
- Resource Allocation: <!-- CPU, Memory -->
- Storage: <!-- local-path, cloud provider -->

## Steps to Reproduce

1. <!-- First step -->
2. <!-- Second step -->
3. <!-- Additional steps... -->

## Expected Behavior

<!-- What should happen? -->

## Actual Behavior

<!-- What actually happens? -->

## Logs and Diagnostics

<!-- Paste relevant logs, error messages, or diagnostic output -->

```bash
# kubectl get pods -A
# kubectl describe pod <pod-name> -n <namespace>
# kubectl logs <pod-name> -n <namespace>
```

```text
<!-- Paste output here -->
```

## Configuration Files

<!-- If relevant, share configuration snippets (remove sensitive data!) -->

```yaml
<!-- Paste relevant config here -->
```

## Impact

<!-- How severe is this issue? -->

- [ ] Critical - Production/development environment down
- [ ] High - Major functionality unavailable
- [ ] Medium - Workaround available
- [ ] Low - Minor inconvenience

## Attempted Solutions

<!-- What have you already tried? -->

## System Resources

<!-- Current resource usage if relevant -->

```text
<!-- Paste kubectl top nodes/pods output or similar -->
```

## Additional Context

<!-- Add any other context, related issues, or architecture diagrams -->

---

**Before submitting:**

- [ ] I have checked pod logs and events
- [ ] I have verified resource availability (CPU, memory, disk)
- [ ] I have included relevant configuration files (with secrets removed)
- [ ] I have checked the infrastructure documentation (docs/infra_poc.md)
