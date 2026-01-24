# Guardyn Production Deployment Guide

> **Phase 5: Launch Preparation**
> **Version:** 1.0.1
> **Last Updated:** 2026-01-24

## Overview

This guide covers deploying Guardyn to a production Kubernetes cluster with:
- High availability configuration
- Auto-scaling (HPA)
- Pod disruption budgets (PDB)
- Network policies
- TLS termination
- SLO monitoring and alerting

## Prerequisites

### Required Tools

```bash
# Verify all tools are installed
kubectl version --client
helm version
kustomize version
sops --version
age --version
```

### Required Secrets

Before deployment, ensure you have:

1. **JWT Secret** - For authentication tokens
2. **Database credentials** - TiKV/ScyllaDB access
3. **MinIO credentials** - Object storage access
4. **FCM/APNs keys** - Push notification credentials
5. **PagerDuty/Slack webhooks** - Alerting integration

### Managed Kubernetes Cluster

Recommended specifications:
- **Nodes:** Minimum 6 nodes (3 for data, 3 for apps)
- **Node size:** 4 vCPU, 16GB RAM minimum
- **Storage class:** SSD-backed (for TiKV and ScyllaDB)
- **Kubernetes version:** 1.28+
- **Ingress:** NGINX Ingress Controller or similar
- **CNI:** Cilium (recommended) or Calico

## Deployment Steps

### 1. Configure Domain

Set your production domain in the configuration:

```bash
export DOMAIN="yourdomain.com"
```

### 2. Prepare Secrets

Create encrypted secrets using SOPS:

```bash
cd infra/secrets

# Create production secrets file
cat > production-secrets.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: guardyn-backend-secrets
  namespace: apps
type: Opaque
stringData:
  jwt-secret: "$(openssl rand -base64 32)"
  tikv-password: "your-tikv-password"
  scylladb-password: "your-scylladb-password"
  minio-access-key: "your-minio-access-key"
  minio-secret-key: "your-minio-secret-key"
  fcm-server-key: "your-fcm-key"
  apns-key: "your-apns-key"
EOF

# Encrypt with SOPS
sops -e production-secrets.yaml > production-secrets.enc.yaml
rm production-secrets.yaml
```

### 3. Configure Alerting

Update Alertmanager configuration with your endpoints:

```bash
# Edit infra/k8s/overlays/prod/alertmanager-config.yaml
# Replace placeholders:
# - YOUR/SLACK/WEBHOOK with actual Slack webhook
# - PagerDuty service key
```

### 4. Deploy Infrastructure

```bash
# Apply namespaces first
kubectl apply -f infra/k8s/base/namespaces/

# Install cert-manager
helm repo add jetstack https://charts.jetstack.io
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

# Install Prometheus stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace observability \
  --create-namespace \
  -f infra/k8s/base/monitoring/values.yaml

# Deploy TiKV
kubectl apply -k infra/k8s/base/tikv/

# Deploy ScyllaDB
kubectl apply -k infra/k8s/base/scylladb/

# Deploy Redpanda
kubectl apply -k infra/k8s/base/redpanda/

# Deploy MinIO
kubectl apply -k infra/k8s/base/minio/
```

### 5. Deploy Application Services

```bash
# Apply production overlay
kubectl apply -k infra/k8s/overlays/prod/

# Verify deployments
kubectl get deployments -n apps
kubectl get pods -n apps

# Check HPA status
kubectl get hpa -n apps

# Check PDB status
kubectl get pdb -n apps
```

### 6. Configure Ingress

```bash
# Verify ingress resources
kubectl get ingress -n apps

# Check TLS certificates
kubectl get certificates -n apps
```

### 7. Import Grafana Dashboards

```bash
# Apply dashboard ConfigMap
kubectl create configmap grafana-dashboards \
  --from-file=infra/k8s/overlays/prod/grafana-dashboards/ \
  -n observability

# Restart Grafana to pick up dashboards
kubectl rollout restart deployment/kube-prometheus-stack-grafana -n observability
```

## Verification

### Health Checks

```bash
# Check all pods are running
kubectl get pods -A | grep -E "(apps|data|messaging|observability)"

# Verify services are responding
kubectl run test-pod --rm -it --image=curlimages/curl -- sh
# Inside pod:
curl http://auth-service.apps.svc.cluster.local:50051/health
```

### SLO Dashboard

Access Grafana at `https://grafana.${DOMAIN}` and verify:
1. SLO Dashboard is available
2. All metrics are being scraped
3. Error budget is showing correctly

### Alert Testing

Send a test alert:

```bash
kubectl exec -it prometheus-0 -n observability -- \
  amtool alert add test-alert severity=warning service=test
```

Verify alerts are received in Slack/PagerDuty.

## Rollback Procedure

If deployment fails:

```bash
# Rollback to previous version
kubectl rollout undo deployment/auth-service -n apps
kubectl rollout undo deployment/messaging-service -n apps
kubectl rollout undo deployment/presence-service -n apps
kubectl rollout undo deployment/media-service -n apps
kubectl rollout undo deployment/notification-service -n apps

# Verify rollback
kubectl rollout status deployment/auth-service -n apps
```

## Maintenance

### Scaling

```bash
# Manual scaling (if HPA is not sufficient)
kubectl scale deployment/messaging-service --replicas=5 -n apps

# View current HPA status
kubectl describe hpa messaging-service-hpa -n apps
```

### Certificate Renewal

Certificates are automatically renewed by cert-manager. To check status:

```bash
kubectl get certificates -n apps
kubectl describe certificate guardyn-api-tls -n apps
```

### Log Access

```bash
# View logs via Loki/Grafana or directly:
kubectl logs -f deployment/messaging-service -n apps

# Aggregate logs
kubectl logs -l app=messaging-service -n apps --tail=100
```

## Security Checklist

Before going live, verify:

- [ ] All secrets are encrypted with SOPS
- [ ] Network policies are active
- [ ] TLS is enabled on all ingresses
- [ ] Rate limiting is configured
- [ ] Pod security contexts are set (non-root)
- [ ] Resource limits are defined
- [ ] RBAC policies are minimal
- [ ] Audit logging is enabled

## SLO Targets

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Platform Availability | 99.9% | < 99.9% |
| Auth Service Latency (P99) | < 200ms | > 200ms |
| Messaging Service Latency (P99) | < 100ms | > 100ms |
| Message Delivery Rate | > 99% | < 99% |
| Error Budget | > 25% remaining | < 25% |

## Support

- **Critical Issues:** PagerDuty (auto-escalation)
- **Warnings:** #guardyn-alerts Slack channel
- **SLO Breaches:** #guardyn-slo Slack channel
- **Documentation:** https://docs.guardyn.io
