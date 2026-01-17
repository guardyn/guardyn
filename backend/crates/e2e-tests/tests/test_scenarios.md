# E2E Test Scenarios for Guardyn MVP

## Overview

This document describes the end-to-end test scenarios for the Guardyn Minimum Viable Product (MVP), focusing on the integration between Auth Service and Messaging Service.

## Test Environment

### Prerequisites

- **Kubernetes Cluster**: k3d cluster "guardyn-poc" running
- **Infrastructure**:
  - TiKV (distributed key-value store) - operational
  - ScyllaDB (message persistence) - operational
  - NATS JetStream (message streaming) - operational
- **Services**:
  - Auth Service (2 replicas) - port 50051
  - Messaging Service (3 replicas) - port 50052

### Setup Instructions

1. **Start port-forwarding** (in separate terminals):

   ```bash
   kubectl port-forward -n apps svc/auth-service 50051:50051
   kubectl port-forward -n apps svc/messaging-service 50052:50052
   ```

2. **Run tests**:

   ```bash
   # Run all tests sequentially
   cargo test --test e2e_auth_messaging_test -- --test-threads=1 --nocapture

   # Run specific test
   cargo test --test e2e_auth_messaging_test test_03_send_and_receive_message -- --nocapture

   # Run offline test (marked as ignored)
   cargo test --test e2e_auth_messaging_test test_06_offline_message_delivery -- --nocapture --ignored
   ```

3. **Environment variables** (optional):
   ```bash
   export AUTH_ENDPOINT=http://localhost:50051
   export MESSAGING_ENDPOINT=http://localhost:50052
   ```

---

## Test Scenarios

### Test 0: Service Health Check

**Purpose**: Verify that both Auth and Messaging services are reachable and responsive.

**Steps**:

1. Connect to Auth Service gRPC endpoint
2. Connect to Messaging Service gRPC endpoint

**Expected Results**:

- ✅ Both services respond to connection attempts
- ✅ No connection errors or timeouts

**Dependencies**: None

---

### Test 1: User Registration

**Purpose**: Verify that users can be registered through Auth Service.

**Steps**:

1. Generate unique usernames (with UUID suffix to avoid conflicts)
2. Call `AuthService.Register` for User 1
   - Username: `test_user_{uuid}`
   - Password: `SecurePassword123!`
   - Device ID: `{uuid}`
3. Call `AuthService.Register` for User 2 with different credentials

**Expected Results**:

- ✅ Both users receive `RegisterSuccess` response
- ✅ Each user gets unique `user_id`
- ✅ Each user receives JWT token
- ✅ No duplicate username errors

**Assertions**:

```rust
assert!(user1.user_id.is_some());
assert!(user1.token.is_some());
assert_ne!(user1.user_id, user2.user_id);
```

---

### Test 2: User Login/Logout

**Purpose**: Verify authentication lifecycle (login → logout → login).

**Steps**:

1. Register a new user
2. Save the initial JWT token
3. Call `AuthService.Logout` with token
4. Verify token is cleared
5. Call `AuthService.Login` with same credentials
6. Verify new token is issued

**Expected Results**:

- ✅ Logout clears authentication state
- ✅ Login after logout succeeds
- ✅ New token is different from original token
- ✅ Token can be used for authenticated requests

**Assertions**:

```rust
assert!(user.token.is_none()); // After logout
assert!(user.token.is_some()); // After re-login
assert_ne!(first_token, user.token); // Different tokens
```

---

### Test 3: Send and Receive 1-on-1 Message

**Purpose**: Verify end-to-end message flow from sender to recipient.

**Flow**:

```
User1 (Sender)                    Messaging Service                User2 (Recipient)
     │                                   │                              │
     ├──── SendMessage(User2) ──────────►│                              │
     │                                   ├──── Store in ScyllaDB        │
     │                                   ├──── Publish to NATS          │
     │                                   ├──── Queue in TiKV ───────────►│
     │◄──── SendMessageSuccess ──────────┤                              │
     │                                   │                              │
     │                                   │◄──── GetMessages ─────────────┤
     │                                   ├──── Query ScyllaDB           │
     │                                   ├───────────────────────────────►│
     │                                   │      Return messages          │
```

**Steps**:

1. Register User 1 (sender) and User 2 (recipient)
2. User 1 calls `MessagingService.SendMessage`:
   - `recipient_user_id`: User 2's ID
   - `encrypted_content`: `b"Hello from E2E test!"`
   - `client_message_id`: UUID
3. Wait 2 seconds for message propagation
4. User 2 calls `MessagingService.GetMessages`:
   - `conversation_user_id`: User 1's ID
5. Verify message is in response

**Expected Results**:

- ✅ SendMessage returns `message_id`
- ✅ GetMessages returns at least one message
- ✅ Message content matches sent content
- ✅ Sender user ID matches User 1
- ✅ Message stored in ScyllaDB (persisted)

**Assertions**:

```rust
assert!(!success.messages.is_empty());
assert_eq!(received_msg.encrypted_content, message_content);
assert_eq!(received_msg.sender_user_id, user1.user_id);
```

---

### Test 4: Mark as Read and Delete Message

**Purpose**: Verify message lifecycle operations (read receipts, deletion).

**Steps**:

1. Register two users
2. Send message from User 1 to User 2
3. User 2 calls `MessagingService.MarkAsRead` with message ID
4. Verify success response
5. User 2 calls `MessagingService.DeleteMessage` with message ID
6. Verify message marked as deleted

**Expected Results**:

- ✅ MarkAsRead succeeds
- ✅ DeleteMessage returns `deleted: true`
- ✅ Message remains in database but flagged as deleted
- ✅ Soft deletion (not physically removed)

**Assertions**:

```rust
assert!(mark_response.success);
assert!(delete_response.deleted);
```

---

### Test 5: Group Chat Creation and Messaging

**Purpose**: Verify group chat functionality end-to-end.

**Flow**:

```
User1 (Admin)                  Messaging Service              User2, User3 (Members)
     │                                │                              │
     ├──── CreateGroup ──────────────►│                              │
     │      [User2, User3]            ├──── Store in TiKV            │
     │◄──── group_id ─────────────────┤                              │
     │                                │                              │
     ├──── SendGroupMessage ─────────►│                              │
     │                                ├──── Store in ScyllaDB        │
     │                                ├──── NATS fanout ─────────────►│
     │                                │      to each member           │
     │◄──── message_id ───────────────┤                              │
     │                                │                              │
     │                                │◄──── GetGroupMessages ────────┤
     │                                ├───────────────────────────────►│
```

**Steps**:

1. Register 3 users (admin + 2 members)
2. User 1 calls `MessagingService.CreateGroup`:
   - `group_name`: "Test E2E Group"
   - `member_user_ids`: [User 2, User 3]
3. User 1 sends group message:
   - `encrypted_content`: `b"Hello everyone in the group!"`
4. Wait 2 seconds
5. User 2 calls `GetGroupMessages` with group ID
6. Verify message received

**Expected Results**:

- ✅ CreateGroup returns unique `group_id`
- ✅ SendGroupMessage returns `message_id`
- ✅ All members receive the message
- ✅ Message stored in ScyllaDB `group_messages` table
- ✅ NATS fanout delivers to all members

**Assertions**:

```rust
assert!(!success.messages.is_empty());
assert!(success.messages.iter().any(|m| m.message_id == group_message_id));
```

---

### Test 6: Offline Message Delivery (Manual Test)

**Purpose**: Verify message queuing for offline users.

**Note**: This test is marked `#[ignore]` and must be run manually with `--ignored` flag.

**Steps**:

1. Register User 1 (sender) and User 2 (recipient)
2. User 2 logs out (goes offline)
3. User 1 sends message to User 2
4. Verify message queued in TiKV
5. User 2 logs back in
6. Wait 3 seconds for message delivery
7. User 2 calls `GetMessages`
8. Verify offline message is delivered

**Expected Results**:

- ✅ SendMessage succeeds even when recipient is offline
- ✅ Message stored in TiKV offline queue
- ✅ On login, message is retrieved from queue
- ✅ Message appears in GetMessages response

**TiKV Keys Used**:

- `offline_queue:{user_id}` - Queue of pending message IDs
- `delivery_state:{message_id}` - Message delivery status

**Assertions**:

```rust
assert!(send_response.success); // Sent while offline
assert!(success.messages.iter().any(|m| m.message_id == message_id));
```

---

## Test Data Structure

### TestUser

Helper struct for managing test users:

```rust
struct TestUser {
    username: String,       // Unique username
    password: String,       // Always "SecurePassword123!"
    device_id: String,      // UUID
    user_id: Option<String>, // Received after registration
    token: Option<String>,   // JWT token
}
```

**Methods**:

- `new(username)` - Create new test user
- `register(&env)` - Register via Auth Service
- `login(&env)` - Authenticate
- `logout(&env)` - Clear session
- `token()` - Get JWT token
- `user_id()` - Get user ID

---

## Architecture Interactions

### Service Dependencies

```
E2E Tests
    ├── Auth Service
    │   └── TiKV (users, sessions, devices)
    │
    └── Messaging Service
        ├── TiKV (delivery state, offline queue, groups)
        ├── ScyllaDB (message history, group messages)
        └── NATS JetStream (real-time delivery)
```

### Data Flow

1. **Registration**:

   - Auth Service → TiKV (`users:{user_id}`, `sessions:{user_id}:{device_id}`)

2. **Messaging**:

   - Sender → Messaging Service → ScyllaDB (persistence)
   - Messaging Service → NATS (real-time delivery)
   - Messaging Service → TiKV (delivery state, offline queue)

3. **Group Chat**:
   - Create Group → TiKV (`groups:{group_id}`, `group_members:{group_id}`)
   - Send Group Message → ScyllaDB (`group_messages` table)
   - Fanout → NATS (subject per member: `messages.{user_id}.{message_id}`)

---

## Troubleshooting

### Common Issues

#### Connection Refused

**Symptom**: `Error: transport error`

**Solution**:

```bash
# Check services are running
kubectl get pods -n apps

# Verify port-forwarding
lsof -i :50051
lsof -i :50052

# Re-establish port-forward
kubectl port-forward -n apps svc/auth-service 50051:50051 &
kubectl port-forward -n apps svc/messaging-service 50052:50052 &
```

#### Message Not Delivered

**Symptom**: GetMessages returns empty array

**Solution**:

```bash
# Check ScyllaDB status
kubectl exec -n data guardyn-scylla-dc1-rack1-0 -c scylla -- nodetool status

# Check NATS connectivity
kubectl port-forward -n messaging svc/nats 4222:4222
nats stream list

# Check messaging service logs
kubectl logs -n apps -l app=messaging-service --tail=50
```

#### Authentication Failed

**Symptom**: gRPC status `UNAUTHENTICATED`

**Solution**:

- Verify token is included in metadata: `request.metadata_mut().insert("authorization", token)`
- Check JWT secret matches: `kubectl get secret -n apps guardyn-backend-secrets -o yaml`
- Re-register user if token expired

#### ScyllaDB Query Timeout

**Symptom**: `Error: ScyllaDB operation timed out`

**Solution**:

```bash
# Check ScyllaDB pod readiness
kubectl describe pod -n data guardyn-scylla-dc1-rack1-0

# Verify all 4 containers are running (scylla, scylla-manager-agent, ignition, probe)
kubectl get pod -n data guardyn-scylla-dc1-rack1-0 -o jsonpath='{.status.containerStatuses[*].ready}'
```

---

## Performance Metrics

### Expected Latencies (Local k3d Cluster)

| Operation        | Target Latency | Measured |
| ---------------- | -------------- | -------- |
| Register         | < 100ms        | TBD      |
| Login            | < 50ms         | TBD      |
| SendMessage      | < 150ms        | TBD      |
| GetMessages      | < 100ms        | TBD      |
| CreateGroup      | < 200ms        | TBD      |
| SendGroupMessage | < 200ms        | TBD      |

**Note**: Latencies measured during test execution will be documented here.

---

## Phase 2 Test Scenarios

### Test P2-01: Add and Remove Reaction

**Purpose**: Verify message reaction lifecycle (add, get, remove).

**Steps**:
1. Register User 1 (sender) and User 2 (recipient)
2. User 1 sends a message to User 2
3. User 2 adds a 👍 reaction to the message
4. Verify reaction is stored (GetReactions)
5. User 2 removes the reaction
6. Verify reaction is removed

**Expected Results**:
- ✅ AddReaction returns reaction with emoji, message_id, user_id
- ✅ GetReactions returns list of reactions
- ✅ RemoveReaction successfully removes the reaction
- ✅ Subsequent GetReactions shows reaction removed

---

### Test P2-02: Enhanced Read Receipts

**Purpose**: Verify read receipt sending and retrieval.

**Steps**:
1. Register User 1 and User 2
2. User 1 sends 3 messages to User 2
3. User 2 sends read receipt for last message
4. User 1 retrieves read receipts for conversation
5. Verify User 2's last_read_message_id matches

**Expected Results**:
- ✅ SendReadReceipt returns success with timestamp
- ✅ GetReadReceipts returns receipt with correct user_id and last_read_message_id
- ✅ Read receipt reflects last read message

---

### Test P2-03: Forward Message

**Purpose**: Verify message forwarding between conversations.

**Steps**:
1. Register User 1, User 2, User 3
2. User 1 sends message to User 2
3. User 2 forwards message to User 3
4. User 3 retrieves messages
5. Verify forwarded message has forward_info

**Expected Results**:
- ✅ ForwardMessage returns new message_id
- ✅ Forwarded message contains original content
- ✅ forward_info includes original_message_id, original_sender_id

---

### Test P2-04: Edit Message

**Purpose**: Verify message editing and version tracking.

**Steps**:
1. Register User 1 and User 2
2. User 1 sends message with "original content"
3. User 1 edits message with "edited content"
4. User 2 retrieves messages
5. Verify content is updated and edit_version >= 1

**Expected Results**:
- ✅ EditMessage returns edit_version >= 1
- ✅ Retrieved message has new content
- ✅ last_edited_at timestamp is set
- ✅ edit_version is incremented

---

### Test P2-05: Disappearing Messages

**Purpose**: Verify disappearing messages configuration.

**Steps**:
1. Register User 1 and User 2
2. User 1 enables disappearing messages (TTL = 1 day)
3. User 2 retrieves config
4. Verify TTL and set_by_user_id
5. User 1 disables disappearing messages (TTL = 0)
6. Verify config is disabled

**Expected Results**:
- ✅ SetDisappearingMessages returns config with correct TTL
- ✅ GetDisappearingConfig returns same TTL for other user
- ✅ set_by_user_id matches who configured it
- ✅ TTL = 0 disables disappearing messages

---

### Test P2-06: Multiple Reactions from Multiple Users

**Purpose**: Verify reaction aggregation in group chat.

**Steps**:
1. Register 3 users
2. Create group with all users
3. User 1 sends group message
4. User 1 reacts with 👍
5. User 2 reacts with ❤️ and 👍
6. User 3 reacts with 😂
7. Get all reactions
8. Verify reaction counts: 👍=2, ❤️=1, 😂=1

**Expected Results**:
- ✅ All reactions are stored
- ✅ GetReactions returns all reactions
- ✅ Same emoji from different users are separate reactions
- ✅ Reaction counts match expected

---

## Future Test Scenarios

### Phase 3 (Cryptography Integration)

- [x] X3DH key exchange (see `e2e_mls_integration.rs`)
- [x] Double Ratchet encryption/decryption (see crypto tests)
- [x] MLS group key management (see `e2e_mls_integration.rs`)
- [ ] Safety number verification
- [x] Forward secrecy validation (see MLS tests)
- [x] Post-quantum cryptography (ML-KEM hybrid in `guardyn-crypto`)

### Phase 4 (Security Hardening)

- [ ] Rate limiting verification
- [ ] Sealed Sender integration test
- [ ] Hardware key storage mocking

### Performance Tests

- [ ] Concurrent message sending (load testing)
- [ ] Message pagination (large conversation history)
- [ ] Media attachment upload/download
- [ ] Call service latency

---

## Test Execution Logs

### Run 1: Initial Test Suite Execution

**Date**: 2025-11-09  
**Environment**: k3d cluster `guardyn-poc`  
**Status**: ⏳ Pending execution

**Commands**:

```bash
# Start port-forwarding
kubectl port-forward -n apps svc/auth-service 50051:50051 &
kubectl port-forward -n apps svc/messaging-service 50052:50052 &

# Run tests
cargo test --test e2e_auth_messaging_test -- --test-threads=1 --nocapture
```

**Results**: TBD

---

## References

- **Implementation Plan**: `docs/IMPLEMENTATION_PLAN.md`
- **Proto Definitions**: `backend/proto/auth.proto`, `backend/proto/messaging.proto`
- **Auth Service**: `backend/crates/auth-service/`
- **Messaging Service**: `backend/crates/messaging-service/`
- **Infrastructure Guide**: `docs/infra_poc.md`

---

**Document Version**: 1.0  
**Last Updated**: 2025-11-09  
**Status**: Ready for test execution
