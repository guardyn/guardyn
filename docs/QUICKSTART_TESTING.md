# Guardyn Quick Reference - Performance Testing

## 🚀 Running Performance Tests

### Recommended method (wrapper with Nix)

```bash
backend/crates/e2e-tests/scripts/k6-test.sh            # Combined test (auth + messaging)
backend/crates/e2e-tests/scripts/k6-test.sh auth       # Auth service only
backend/crates/e2e-tests/scripts/k6-test.sh messaging  # Messaging service only
```

**What the wrapper does**:
- ✅ Automatically enters Nix environment
- ✅ Checks k6 availability
- ✅ Sets up port-forwarding
- ✅ Runs tests
- ✅ Cleans up resources on exit

### Alternative (manual Nix shell)

```bash
# 1. Enter Nix environment
nix --extra-experimental-features 'nix-command flakes' develop

# 2. Run tests
backend/crates/e2e-tests/scripts/run-performance-tests.sh            # Combined
backend/crates/e2e-tests/scripts/run-performance-tests.sh auth       # Auth only
backend/crates/e2e-tests/scripts/run-performance-tests.sh messaging  # Messaging only

# 3. Exit
exit
```

## 📊 Target Metrics

- **Virtual Users**: 50 concurrent
- **Duration**: 5 minutes
- **P95 Latency**: < 200ms
- **Success Rate**: > 95%

## 🧪 E2E Tests

```bash
backend/crates/e2e-tests/scripts/run-e2e-tests.sh  # All 8 E2E tests
```

## 📈 Observability

```bash
# Grafana
kubectl port-forward -n observability svc/kube-prometheus-stack-grafana 3000:80
# Open http://localhost:3000

# Prometheus
kubectl port-forward -n observability svc/prometheus-kube-prometheus-stack-prometheus 9090:9090
# Open http://localhost:9090
```

## 🐛 Troubleshooting

### k6 not found
**Solution**: Use `backend/crates/e2e-tests/scripts/k6-test.sh` instead of running performance tests directly

### Port already in use
```bash
pkill -f "port-forward"
```

### Envoy proxy not running (web clients)
```bash
# Port-forward Envoy for web browsers
kubectl port-forward -n apps svc/guardyn-envoy 8080:8080

# Verify
lsof -i :8080
```

### Services not running
```bash
kubectl get pods -n apps
kubectl logs -n apps -l app=messaging-service
```

## 📚 Documentation

- **Testing Guide**: `docs/TESTING_GUIDE.md`
- **Observability Guide**: `docs/OBSERVABILITY_GUIDE.md`
- **Performance README**: `backend/crates/e2e-tests/performance/README.md`
