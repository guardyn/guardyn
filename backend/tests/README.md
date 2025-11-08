# Integration Tests for Guardyn Backend

## Overview

This directory contains integration tests for Guardyn backend services, with infrastructure provided via Docker Compose.

## Prerequisites

- Docker and Docker Compose
- Rust toolchain (via Nix or native install)
- Running auth-service on port 50051

## Test Infrastructure

### Docker Compose Stack

```bash
cd backend/tests
docker-compose up -d
```

**Services:**

- **TiKV**: Distributed KV store (PD on 2379, TiKV on 20160)
- **NATS**: JetStream messaging (4222)
- **ScyllaDB**: Message history (9042)

### Wait for Services

```bash
# Check TiKV health
curl http://localhost:2379/pd/api/v1/health

# Check NATS
curl http://localhost:8222/healthz

# Check ScyllaDB
docker-compose exec scylla nodetool status
```

## Running Tests

### 1. Start Test Infrastructure

```bash
docker-compose up -d
sleep 10  # Wait for services to be ready
```

### 2. Start Auth Service

```bash
cd backend/crates/auth-service
cargo run
```

### 3. Run Integration Tests

```bash
cd backend
cargo test --test auth_integration_test -- --nocapture
```

**Expected Output:**

```
✅ User registration successful
   User ID: 550e8400-e29b-41d4-a716-446655440000
   Access Token: eyJ0eXAiOiJKV1QiLCJh...

✅ User login successful
   User ID: 550e8400-e29b-41d4-a716-446655440000
   Devices: 1

✅ Token refresh successful
   New Access Token: eyJ0eXAiOiJKV1QiLCJh...

✅ Token validation successful
   User ID: 550e8400-e29b-41d4-a716-446655440000
   Permissions: ["read", "write"]
```

## Test Scenarios

### 1. User Registration (`test_user_registration`)

**Flow:**

1. Connect to auth service
2. Create mock E2EE key bundle
3. Register new user with credentials
4. Verify JWT tokens returned
5. Check token expiry times

**Validates:**

- Username validation (3-32 chars, alphanumeric + \_)
- Password hashing with Argon2id
- User storage in TiKV
- Key bundle storage
- JWT token generation

### 2. User Login (`test_user_login`)

**Flow:**

1. Login with existing user credentials
2. Verify password check
3. Get JWT tokens
4. Verify device list returned

**Validates:**

- Password verification
- Session creation
- Device management
- Token generation for existing users

### 3. Token Refresh (`test_token_refresh`)

**Flow:**

1. Login to get refresh token
2. Use refresh token to get new access token
3. Verify new token validity

**Validates:**

- Refresh token validation
- Session lookup in TiKV
- New access token generation

### 4. Token Validation (`test_token_validation`)

**Flow:**

1. Login to get access token
2. Validate token via gRPC
3. Extract user claims

**Validates:**

- JWT signature verification
- Token expiry check
- Claims extraction (user_id, device_id, permissions)

## Test Data

**Test User:**

- Username: `test_user_integration`
- Password: `TestPassword123!`
- Device ID: `test_device_001`

**Note:** Test data accumulates in TiKV. For production tests, implement cleanup.

## Cleanup

```bash
# Stop services
docker-compose down

# Remove volumes (WARNING: destroys all test data)
docker-compose down -v
```

## Troubleshooting

### TiKV Connection Refused

```bash
# Check PD is running
docker-compose logs pd

# Verify PD endpoint
curl http://localhost:2379/pd/api/v1/health
```

### Auth Service Not Responding

```bash
# Check service logs
cd backend/crates/auth-service
RUST_LOG=debug cargo run

# Verify gRPC endpoint
grpcurl -plaintext localhost:50051 guardyn.auth.AuthService/Health
```

### Test Failures

```bash
# Run with verbose output
cargo test --test auth_integration_test -- --nocapture

# Check TiKV data
docker-compose exec tikv tikv-ctl --host=tikv:20160 scan --from="" --limit=10
```

## Environment Variables

| Variable            | Default                  | Description       |
| ------------------- | ------------------------ | ----------------- |
| `AUTH_SERVICE_URL`  | `http://127.0.0.1:50051` | gRPC endpoint     |
| `TIKV_PD_ENDPOINTS` | `127.0.0.1:2379`         | TiKV PD endpoints |
| `RUST_LOG`          | `info`                   | Log level         |

## Next Steps

1. Add E2E test for full registration → login → message send flow
2. Implement test data cleanup hooks
3. Add load tests with k6
4. Add security tests (invalid tokens, SQL injection attempts)
5. Add concurrency tests (parallel registrations)

## CI/CD Integration

Tests are run in GitHub Actions via `.github/workflows/test.yml`:

```yaml
- name: Start test infrastructure
  run: docker-compose -f backend/tests/docker-compose.yml up -d

- name: Wait for services
  run: sleep 30

- name: Run integration tests
  run: cargo test --workspace --test '*_integration_test'
```

---

**Last Updated**: November 8, 2025  
**Status**: ✅ Basic integration tests implemented
