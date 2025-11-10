# Guardyn Performance Tests

Performance testing suite for Guardyn MVP using k6 load testing framework.

## 🎯 Test Goals

- **Target**: 50 concurrent users
- **Duration**: 5 minutes
- **P95 Latency**: < 200ms
- **Success Rate**: > 95%

## 📋 Prerequisites

1. **k3d cluster running**:

   ```bash
   k3d cluster list  # Should show guardyn-poc
   ```

2. **Services deployed**:

   ```bash
   kubectl get pods -n apps
   # auth-service: 2/2 Running
   # messaging-service: 3/3 Running
   ```

3. **k6 installed** (via Nix environment):
   ```bash
   nix --extra-experimental-features 'nix-command flakes' develop
   k6 version
   ```

## 🚀 Running Tests

### Quick Start (Recommended)

Run combined auth + messaging load test:

```bash
./run-performance-tests.sh
```

This script automatically:

- Sets up port-forwarding to services
- Runs combined load test
- Cleans up port-forwards on exit

### Individual Tests

**Auth Service only**:

```bash
./run-performance-tests.sh auth
```

**Messaging Service only**:

```bash
./run-performance-tests.sh messaging
```

### Manual Execution

If you prefer manual control:

```bash
# 1. Port-forward services
kubectl port-forward -n apps svc/auth-service 50051:50051 &
kubectl port-forward -n apps svc/messaging-service 50052:50052 &

# 2. Run k6 test
cd backend/crates/e2e-tests/performance
k6 run --vus 50 --duration 5m combined-load-test.js

# 3. Cleanup
pkill -f "port-forward"
```

## 📊 Test Scenarios

### 1. Auth Load Test (`auth-load-test.js`)

Tests authentication service performance:

- User registration
- User login
- JWT token validation

**Metrics**:

- `registration_latency` - Time to register new user
- `login_latency` - Time to login existing user
- `registration_success` - Success rate for registrations
- `login_success` - Success rate for logins

### 2. Messaging Load Test (`messaging-load-test.js`)

Tests messaging service performance:

- Send 1-on-1 messages
- Retrieve message history

**Setup**: Creates 2 test users, then VUs exchange messages.

**Metrics**:

- `send_message_latency` - Time to send message
- `get_messages_latency` - Time to fetch messages
- `send_message_success` - Success rate for sends
- `get_messages_success` - Success rate for fetches

### 3. Combined Load Test (`combined-load-test.js`)

Full end-to-end flow:

1. Register user
2. Login user
3. Send message
4. Retrieve messages

**Setup**: Creates shared receiver, each VU sends messages to it.

**Metrics**: All of the above combined.

## 📈 Understanding Results

### Sample Output

```
✓ registration successful
✓ login successful
✓ send message successful
✓ get messages successful

checks.........................: 100.00% ✓ 12000   ✗ 0
data_received..................: 24 MB   80 kB/s
data_sent......................: 12 MB   40 kB/s
registration_latency...........: avg=45ms  p(95)=120ms
login_latency..................: avg=38ms  p(95)=95ms
send_message_latency...........: avg=52ms  p(95)=140ms
get_messages_latency...........: avg=41ms  p(95)=110ms
vus............................: 50      min=50  max=50
```

### Thresholds

Tests PASS if:

- ✅ P95 latency < 200ms for all operations
- ✅ Success rate > 95% for all operations
- ✅ Total errors < 50

Tests FAIL if:

- ❌ Any P95 latency >= 200ms
- ❌ Any success rate <= 95%
- ❌ Total errors >= 50

## 🔧 Customization

### Adjust Load Parameters

Edit test files or use k6 CLI flags:

```bash
# 100 VUs for 10 minutes
k6 run --vus 100 --duration 10m combined-load-test.js

# Ramp up from 10 to 100 VUs over 2 minutes, sustain 5 min
k6 run --stage 2m:10,2m:100,5m:100,2m:0 combined-load-test.js
```

### Change Thresholds

Edit `options.thresholds` in test files:

```javascript
export const options = {
  thresholds: {
    send_message_latency: ["p(95)<150"], // Stricter: 150ms
    send_message_success: ["rate>0.99"], // 99% success
  },
};
```

## 🐛 Troubleshooting

### Port-forward fails

```bash
# Check if ports are already in use
lsof -i :50051
lsof -i :50052

# Kill existing processes
pkill -f "port-forward"

# Restart port-forwards
kubectl port-forward -n apps svc/auth-service 50051:50051 &
kubectl port-forward -n apps svc/messaging-service 50052:50052 &
```

### High latency (P95 > 200ms)

Possible causes:

1. **Database bottleneck**: Check TiKV/ScyllaDB CPU/memory
2. **Network issues**: Check k3d cluster networking
3. **Insufficient resources**: Scale up service replicas

```bash
# Scale messaging service
kubectl scale deployment messaging-service -n apps --replicas=5

# Check resource usage
kubectl top pods -n apps
kubectl top nodes
```

### Low success rate (< 95%)

Check service logs:

```bash
kubectl logs -n apps -l app=auth-service --tail=100
kubectl logs -n apps -l app=messaging-service --tail=100
```

Common issues:

- JWT token expiration (increase token TTL)
- Database connection pool exhausted (increase pool size)
- Rate limiting (adjust limits or disable for testing)

## 📁 Output Files

- `performance-results.json` - Full test results in JSON format
- Can be imported into Grafana or analyzed with jq

Example analysis:

```bash
# Extract P95 latencies
jq '.metrics | to_entries | map({(.key): .value.values["p(95)"]})' performance-results.json

# Extract success rates
jq '.metrics | to_entries | map(select(.key | endswith("_success"))) | map({(.key): .value.values.rate})' performance-results.json
```

## 🔗 References

- [k6 Documentation](https://k6.io/docs/)
- [k6 gRPC Testing](https://k6.io/docs/using-k6/protocols/grpc/)
- [k6 Thresholds](https://k6.io/docs/using-k6/thresholds/)
- [k6 Metrics](https://k6.io/docs/using-k6/metrics/)
