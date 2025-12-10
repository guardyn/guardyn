# Guardyn Testing Guide

Comprehensive testing guide for Guardyn MVP: E2E tests, performance tests, and best practices.

## 📚 Related Guides

- **[Flutter Client Testing Guide](./CLIENT_TESTING_GUIDE.md)** - Complete Flutter client testing with manual and automated scenarios
- **[Quick Start Testing](./QUICKSTART_TESTING.md)** - Быстрый старт для тестирования
- **[Two Client Testing](./TWO_CLIENT_TESTING.md)** - Two-device messaging testing setup

## 🎯 Testing Strategy

Guardyn MVP uses a layered testing approach:

1. **Unit Tests** - Individual function/module testing (Rust `cargo test`)
2. **Integration Tests** - Service-to-service communication
3. **E2E Tests** - Full user workflows (auth → messaging)
4. **Performance Tests** - Load testing with k6
5. **Smoke Tests** - Post-deployment validation
6. **Flutter Client Tests** - See [CLIENT_TESTING_GUIDE.md](./CLIENT_TESTING_GUIDE.md)

## 📋 Prerequisites

All tests require:

- **k3d cluster running**: `k3d cluster list`
- **Services deployed**: Auth + Messaging services + Envoy proxy in `apps` namespace
- **Nix environment**: `nix --extra-experimental-features 'nix-command flakes' develop`

**Port-forwarding for web clients**:

```bash
# Required for web browsers (Chrome/Firefox)
kubectl port-forward -n apps svc/guardyn-envoy 18080:8080

# Required for all platforms
kubectl port-forward -n apps svc/auth-service 50051:50051
kubectl port-forward -n apps svc/messaging-service 50052:50052
```

**Platform Requirements**:

| Platform | Protocol | Ports | Envoy Required? |
|----------|----------|-------|----------------|
| Web browsers | gRPC-Web | 8080 | ✅ Yes |
| Android/iOS/Desktop | Native gRPC | 50051/50052 | ❌ No |

## 🧪 E2E Tests

### Overview

E2E tests validate complete user workflows:

- User registration
- Login/logout
- 1-on-1 messaging
- Group chat
- Message delivery states
- Member management

### Running E2E Tests

**Quick Start**:

```bash
backend/crates/e2e-tests/scripts/run-e2e-tests.sh
```

**Manual Execution**:

```bash
cd backend
cargo test --package guardyn-e2e-tests --test e2e_mvp_simplified
```

**With Nix**:

```bash
nix --extra-experimental-features 'nix-command flakes' develop --command bash -c 'backend/crates/e2e-tests/scripts/run-e2e-tests.sh'
```

### Test Scenarios

#### Test 0: Service Health Check

```rust
test test_00_service_health_check
```

Validates:

- Auth service accessible at `auth-service:50051`
- Messaging service accessible at `messaging-service:50052`

#### Test 1: User Registration

```rust
test test_01_user_registration
```

Validates:

- Create new user with username + password
- Receive `user_id`, `device_id`, `access_token`
- JWT token is valid

#### Test 2: Send and Receive Message

```rust
test test_02_send_and_receive_message
```

Validates:

- User A sends message to User B
- Message persisted in ScyllaDB
- User B retrieves message
- Message content matches

#### Test 3: Mark Messages as Read

```rust
test test_03_mark_messages_as_read
```

Validates:

- Send multiple messages
- Mark messages as read
- Delivery status updated to `DELIVERED`

#### Test 4: Delete Message

```rust
test test_04_delete_message
```

Validates:

- Soft delete message
- Deleted message not returned in queries
- Original message preserved (for compliance)

#### Test 5: Group Chat Flow

```rust
test test_05_group_chat_flow
```

Validates:

- Create group with initial members
- Send group message
- All members retrieve message
- Group message stored in ScyllaDB

#### Test 6: Offline Message Delivery

```rust
test test_06_offline_message_delivery
```

Validates:

- Send message to offline user
- Message queued in NATS
- Offline user retrieves queued message
- Delivery status progression: SENT → DELIVERED

#### Test 7: Group Member Management

```rust
test test_07_group_member_management
```

Validates:

- Add member to group
- Remove member from group
- Removed member cannot access group messages
- New member can access group messages
- Authorization enforced

### Interpreting Results

**Success Output**:

```
running 8 tests
test test_00_service_health_check ... ok
test test_01_user_registration ... ok
test test_02_send_and_receive_message ... ok
test test_03_mark_messages_as_read ... ok
test test_04_delete_message ... ok
test test_05_group_chat_flow ... ok
test test_06_offline_message_delivery ... ok
test test_07_group_member_management ... ok

test result: ok. 8 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```

**Failure Output**:

```
test test_02_send_and_receive_message ... FAILED

failures:
    test_02_send_and_receive_message

---- test_02_send_and_receive_message stdout ----
thread 'test_02_send_and_receive_message' panicked at 'assertion failed: message_id.len() > 0'
```

### Debugging Failed Tests

**1. Check service logs**:

```bash
kubectl logs -n apps -l app=auth-service --tail=100
kubectl logs -n apps -l app=messaging-service --tail=100
```

**2. Check database connectivity**:

```bash
kubectl get pods -n data
kubectl logs -n data -l app=tikv
kubectl logs -n data -l app.kubernetes.io/name=scylla
```

**3. Check NATS**:

```bash
kubectl logs -n messaging -l app.kubernetes.io/name=nats
```

**4. Re-run with verbose logging**:

```bash
RUST_LOG=debug cargo test --package guardyn-e2e-tests --test e2e_mvp_simplified -- --nocapture
```

## 📈 Performance Tests

### Overview

Load tests using k6 to validate performance under load:

- **Target**: 50 concurrent users
- **Duration**: 5 minutes
- **P95 Latency**: < 200ms
- **Success Rate**: > 95%

### Running Performance Tests

**Quick Start** (uses Nix wrapper):

```bash
./k6-test.sh
```

**Auth Service Only**:

```bash
./k6-test.sh auth
```

**Messaging Service Only**:

```bash
./k6-test.sh messaging
```

**Alternative** (if already in Nix environment):

```bash
./run-performance-tests.sh           # Combined
./run-performance-tests.sh auth      # Auth only
./run-performance-tests.sh messaging # Messaging only
```

### Test Scripts

Located in: `backend/crates/e2e-tests/performance/`

1. **auth-load-test.js** - Auth service performance
   - Registration
   - Login
2. **messaging-load-test.js** - Messaging service performance
   - Send message
   - Get messages
3. **combined-load-test.js** - Full flow
   - Register → Login → Send → Retrieve

### Understanding Performance Results

**Sample Output**:

```
checks.........................: 100.00% ✓ 12000   ✗ 0
data_received..................: 24 MB   80 kB/s
data_sent......................: 12 MB   40 kB/s
registration_latency...........: avg=45ms  min=20ms med=40ms max=180ms p(90)=90ms p(95)=120ms
login_latency..................: avg=38ms  min=15ms med=35ms max=150ms p(90)=75ms p(95)=95ms
send_message_latency...........: avg=52ms  min=25ms med=48ms max=200ms p(90)=110ms p(95)=140ms
get_messages_latency...........: avg=41ms  min=18ms med=38ms max=130ms p(90)=85ms p(95)=110ms
vus............................: 50      min=50  max=50
```

**Key Metrics**:

- `p(95)` - 95th percentile latency (target: < 200ms)
- `checks` - Success rate (target: > 95%)
- `vus` - Virtual users (concurrent load)

**Pass Criteria**:

- ✅ All P95 latencies < 200ms
- ✅ Success rate > 95%
- ✅ No threshold failures

**Fail Criteria**:

- ❌ Any P95 >= 200ms
- ❌ Success rate <= 95%
- ❌ Total errors >= 50

### Performance Optimization

If tests fail:

1. **Check resource limits**:

```bash
kubectl top pods -n apps
kubectl top nodes
```

2. **Scale services**:

```bash
kubectl scale deployment messaging-service -n apps --replicas=5
```

3. **Check database performance**:

```bash
kubectl logs -n data -l app=tikv | grep -i "slow"
kubectl logs -n data -l app.kubernetes.io/name=scylla | grep -i "timeout"
```

4. **Analyze Prometheus metrics**:

```bash
kubectl port-forward -n observability svc/prometheus-kube-prometheus-stack-prometheus 9090:9090
# Open http://localhost:9090
```

## ✅ Smoke Tests

Quick validation after deployment:

```bash
# 1. Check pods
kubectl get pods -n apps

# 2. Check services
kubectl get svc -n apps

# 3. Port-forward
kubectl port-forward -n apps svc/auth-service 50051:50051 &
kubectl port-forward -n apps svc/messaging-service 50052:50052 &

# 4. Run health check (E2E Test 0)
cargo test --package guardyn-e2e-tests --test e2e_mvp_simplified test_00_service_health_check

# 5. Cleanup
pkill -f "port-forward"
```

## 🐛 Troubleshooting

### Tests Hang or Timeout

**Symptom**: Tests start but never complete

**Solutions**:

1. Check port-forwards are running:

```bash
lsof -i :50051
lsof -i :50052
```

2. Restart port-forwards:

```bash
pkill -f "port-forward"
kubectl port-forward -n apps svc/auth-service 50051:50051 &
kubectl port-forward -n apps svc/messaging-service 50052:50052 &
```

3. Check service health:

```bash
kubectl get pods -n apps
kubectl describe pod -n apps <pod-name>
```

### gRPC Connection Refused

**Symptom**: `Error: connection refused` or `transport error`

**Solutions**:

1. Verify services are running:

```bash
kubectl get pods -n apps -l app=auth-service
kubectl get pods -n apps -l app=messaging-service
```

2. Check service endpoints:

```bash
kubectl get endpoints -n apps
```

3. Verify port-forward:

```bash
netstat -an | grep 5005
```

### Database Connection Errors

**Symptom**: `Failed to connect to TiKV` or `ScyllaDB timeout`

**Solutions**:

1. Check database pods:

```bash
kubectl get pods -n data
```

2. Check connectivity:

```bash
kubectl exec -n apps <auth-pod> -- ping tikv-pd.data.svc.cluster.local
kubectl exec -n apps <messaging-pod> -- ping scylla.data.svc.cluster.local
```

3. Review database logs:

```bash
kubectl logs -n data <tikv-pod>
kubectl logs -n data <scylla-pod>
```

### JWT Token Errors

**Symptom**: `Invalid token` or `Unauthorized`

**Solutions**:

1. Check token generation:

```bash
kubectl logs -n apps -l app=auth-service | grep -i "token"
```

2. Verify JWT secret:

```bash
kubectl get secret -n apps app-secrets -o yaml
```

3. Check token expiration (default: 15 min):

```rust
// In code: auth-service/src/handlers/register.rs
let expiry = Utc::now() + Duration::minutes(15);
```

### E2EE / Encryption Errors

**Symptom**: Messages appear garbled or unreadable, decryption fails

**Causes**:

- Corrupted Double Ratchet session state
- Key bundle signature mismatch
- Session saved before DH ratchet completed

**Solutions**:

1. Clear client data (removes corrupted E2EE sessions):

```bash
just clear-client-data       # Interactive
just clear-client-data-force # Non-interactive
```

2. Verify key bundles in database:

```bash
# Check if user has valid key bundle
kubectl exec -it -n data tikv-0 -- tikv-ctl --host 127.0.0.1:20160 \
  scan --from '"/keys/user-"' --to '"/keys/user-~"' --limit 10
```

3. Check auth-service logs for key exchange:

```bash
kubectl logs -n apps -l app=auth-service | grep -i "key bundle\|x3dh"
```

### WebSocket Messages Not Arriving

**Symptom**: Messages save but don't appear in real-time for recipients

**Causes**:

- K8s messaging-service competing with local service for NATS messages
- NATS consumer not created
- WebSocket not connected

**Solutions**:

1. Stop k8s messaging-service if running locally:

```bash
kubectl scale deployment messaging-service -n apps --replicas=0
```

2. Check NATS consumers (should show only one `websocket-relay-*`):

```bash
kubectl run nats-check --rm -it --image=natsio/nats-box \
  --restart=Never -n messaging -- \
  nats con ls MESSAGES -s nats://nats:4222
```

3. Restart local messaging-service:

```bash
just dev-messaging
```

4. Check WebSocket connection in browser DevTools → Network → WS

## 📊 CI/CD Integration

### GitHub Actions Workflow

E2E tests run on:

- Pull requests (`.github/workflows/test.yml`)
- Push to `main` branch
- Release tags

**Workflow**:

1. Checkout code
2. Setup Nix environment
3. Create k3d cluster
4. Deploy services
5. Run E2E tests
6. Cleanup cluster

### Local CI Simulation

```bash
# Simulate CI workflow locally
just kube:create
just kube:bootstrap
just k8s-deploy tikv
just k8s-deploy scylladb
just k8s-deploy nats
./infra/scripts/deploy.sh auth-service
./infra/scripts/deploy.sh messaging-service
./run-e2e-tests.sh
just teardown
```

## 📚 Best Practices

### Writing New Tests

1. **Use descriptive test names**:

```rust
#[tokio::test]
async fn test_08_message_encryption_e2e() { }
```

2. **Create unique test data**:

```rust
let username = format!("test_user_{}", uuid::Uuid::new_v4());
```

3. **Clean up resources**:

```rust
// Delete test messages after test
messaging_client.invoke("DeleteMessage", request).await?;
```

4. **Add assertions with context**:

```rust
assert!(
    response.message_id.len() > 0,
    "Expected message_id, got empty string"
);
```

### Test Organization

```
backend/crates/e2e-tests/
├── Cargo.toml
├── build.rs
├── tests/
│   └── e2e_mvp_simplified.rs    # Main E2E test suite
└── performance/
    ├── auth-load-test.js
    ├── messaging-load-test.js
    └── combined-load-test.js
```

### Test Data Management

- Use unique identifiers (UUID) for test users
- Clean up after tests (optional for E2E, required for integration)
- Avoid hardcoded values (use config/env vars)

## 🔗 References

- [E2E Test Source](../backend/crates/e2e-tests/tests/e2e_mvp_simplified.rs)
- [Performance Test Scripts](../backend/crates/e2e-tests/performance/)
- [k6 Documentation](https://k6.io/docs/)
- [gRPC Testing Best Practices](https://grpc.io/docs/guides/performance/)

## ✅ Testing Checklist

Current coverage:

- [x] Service health checks
- [x] User registration
- [x] User login/logout
- [x] Send/receive 1-on-1 messages
- [x] Mark messages as read
- [x] Delete messages
- [x] Group chat (create, send, retrieve)
- [x] Offline message delivery
- [x] Group member management
- [x] Performance testing (k6 load tests)
- [x] Crypto key exchange (X3DH) - backend integration tests passing
- [x] Message encryption (Double Ratchet) - 11 unit + 10 integration tests
- [x] Group encryption (MLS) - 8/15 core tests passing
- [ ] Media upload/download - backend ready, needs E2E tests
- [ ] Presence updates - backend ready, needs E2E tests

