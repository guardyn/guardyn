# Messaging Feature - Manual Testing Guide

This guide provides step-by-step instructions for manually testing the Guardyn messaging feature with two Flutter clients.

## Prerequisites

### 1. Infrastructure Requirements

Ensure the following services are running in your k3d cluster:

```bash
# Check cluster status
kubectl get pods -A | grep -E "(auth|messaging|tikv|scylla)"

# Expected output:
# apps          auth-service-xxx        Running
# apps          messaging-service-xxx   Running
# data          tikv-xxx                Running
# data          scylla-xxx              Running
```

### 2. Port Forwarding Setup

Set up port forwarding for backend services:

```bash
# Terminal 1: Auth service
kubectl port-forward -n apps svc/auth-service 50051:50051

# Terminal 2: Messaging service  
kubectl port-forward -n apps svc/messaging-service 50052:50052

# Terminal 3: Envoy proxy (for gRPC-Web)
kubectl port-forward -n apps svc/envoy-proxy 8080:8080
```

### 3. Flutter Environment

```bash
# Verify Flutter installation
flutter doctor

# Navigate to client directory
cd client

# Get dependencies
flutter pub get

# Generate code (if needed)
flutter pub run build_runner build --delete-conflicting-outputs
```

## Test Scenarios

### Scenario 1: Two-Device Messaging Test

This scenario tests messaging between two users on separate devices/emulators.

#### Setup

- **Device 1**: Android Emulator (Pixel 6 API 33) or Physical Device A
- **Device 2**: Android Emulator (Pixel 7 API 34) or Physical Device B
- **Alternative**: Use Chrome browser for one client (web version)

#### Steps

##### Step 1: Register User "Alice" (Device 1)

1. Launch the Guardyn app on Device 1
2. Tap "Register"
3. Fill in registration form:
   - Username: `alice`
   - Email: `alice@test.com`
   - Password: `Test123!`
4. Tap "Create Account"
5. ✅ **Verify**: Registration succeeds and navigates to Home screen

##### Step 2: Register User "Bob" (Device 2)

1. Launch the Guardyn app on Device 2
2. Tap "Register"
3. Fill in registration form:
   - Username: `bob`
   - Email: `bob@test.com`
   - Password: `Test123!`
4. Tap "Create Account"
5. ✅ **Verify**: Registration succeeds and navigates to Home screen

##### Step 3: Alice Searches for Bob (Device 1)

1. On Device 1, tap "Messages" button on Home screen
2. Tap the FAB (floating action button) to start a new conversation
3. In the search field, type: `bob`
4. ✅ **Verify**: User "bob" appears in search results
5. Tap on "bob" to start a conversation

##### Step 4: Alice Sends Message to Bob (Device 1)

1. On the chat screen, type in the message field: `Hello Bob! How are you?`
2. Tap the Send button
3. ✅ **Verify**: Message appears in chat with:
   - "Sent" status indicator (single checkmark)
   - Correct timestamp
   - Blue/primary color bubble (sent by me)

##### Step 5: Bob Receives Message (Device 2)

1. On Device 2, navigate to Messages
2. ✅ **Verify**: Conversation with "alice" appears in list
3. Tap to open the conversation
4. ✅ **Verify**: Message "Hello Bob! How are you?" is visible
   - Gray/secondary color bubble (received)
   - Shows sender as "alice"
   - Correct timestamp

##### Step 6: Bob Replies to Alice (Device 2)

1. Type: `Hi Alice! I'm doing great, thanks!`
2. Tap Send
3. ✅ **Verify**: Message appears in Bob's chat view

##### Step 7: Alice Receives Reply (Device 1)

1. Wait 2-3 seconds (polling interval)
2. ✅ **Verify**: Bob's reply appears in Alice's chat view
3. ✅ **Verify**: Messages are in correct chronological order

##### Step 8: Multi-Message Exchange

Send 5 messages back and forth:

| Sender | Message |
|--------|---------|
| Alice | Message 1: "What are you up to?" |
| Bob | Message 2: "Working on Guardyn!" |
| Alice | Message 3: "That's awesome 🎉" |
| Bob | Message 4: "E2EE is working great" |
| Alice | Message 5: "Let's ship it! 🚀" |

✅ **Verify** for each message:
- Appears in both clients
- Correct sender attribution
- Timestamps are accurate
- Delivery status updates

---

### Scenario 2: Message History Persistence

Tests that message history is preserved across app restarts.

#### Steps

1. After Scenario 1, **close** the Guardyn app on Device 1 completely
2. Reopen the app
3. Log in as Alice (if needed)
4. Navigate to Messages → Open chat with Bob
5. ✅ **Verify**: All previous messages are loaded from server
6. ✅ **Verify**: Messages are in correct order
7. ✅ **Verify**: Timestamps and statuses are preserved

---

### Scenario 3: Offline Message Delivery

Tests that messages sent while recipient is offline are delivered when they come back online.

#### Steps

1. On Device 2, close the Guardyn app (Bob is offline)
2. On Device 1 (Alice), send 3 messages to Bob:
   - "Offline test 1"
   - "Offline test 2"
   - "Offline test 3"
3. Wait 5 seconds
4. ✅ **Verify** (Device 1): Messages show "Sent" status
5. Reopen Guardyn app on Device 2 (Bob comes online)
6. Navigate to chat with Alice
7. ✅ **Verify** (Device 2): All 3 offline messages are received

---

### Scenario 4: User Search Functionality

Tests the user search feature in auth-service.

#### Steps

1. On Device 1 (Alice), navigate to Messages
2. Tap FAB to start new conversation
3. Test search queries:
   | Query | Expected Result |
   |-------|-----------------|
   | `bob` | Shows user "bob" |
   | `BOB` | Shows user "bob" (case-insensitive) |
   | `b` | Shows all users starting with "b" |
   | `alice` | **Should NOT show** (current user excluded) |
   | `xyz` | Shows "No users found" |

✅ **Verify**: Search results match expected behavior

---

### Scenario 5: Conversation List

Tests the conversation list displays correctly.

#### Steps

1. Create conversations with multiple users (if available)
2. Navigate to Messages screen
3. ✅ **Verify**: All conversations are listed
4. ✅ **Verify**: Each conversation shows:
   - Other participant's username
   - Last message preview (or "Start a conversation")
   - Timestamp of last activity

---

## Success Criteria Checklist

Mark each item as you verify:

### Core Messaging
- [ ] Messages send successfully between two devices
- [ ] Messages appear on both sender and recipient clients
- [ ] Real-time message delivery works (< 3 seconds with polling)
- [ ] Message history loads correctly after app restart
- [ ] Offline messages are delivered when user comes online

### UI/UX
- [ ] Timestamps display correctly and update format based on age
- [ ] Sent messages show in primary color (blue)
- [ ] Received messages show in secondary color (gray)
- [ ] Delivery status icons display correctly:
  - Clock icon for pending
  - Single checkmark for sent
  - Double checkmarks for delivered
  - Blue double checkmarks for read
- [ ] Chat auto-scrolls to newest message
- [ ] Empty chat shows helpful prompt text

### User Search
- [ ] Search returns matching users
- [ ] Search is case-insensitive
- [ ] Current user is excluded from results
- [ ] No results shows appropriate message

### Error Handling
- [ ] Network errors show user-friendly message
- [ ] Invalid operations fail gracefully
- [ ] App doesn't crash on edge cases

### Performance
- [ ] Messages load within 2 seconds
- [ ] Search results appear within 1 second
- [ ] No UI freezing during operations
- [ ] Memory usage remains stable during extended use

---

## Troubleshooting

### Messages Not Sending

1. Check port forwarding is active:
   ```bash
   netstat -an | grep -E "(50051|50052)"
   ```

2. Verify services are running:
   ```bash
   kubectl get pods -n apps
   ```

3. Check logs for errors:
   ```bash
   kubectl logs -n apps deployment/messaging-service --tail=50
   ```

### Search Not Working

1. Verify auth-service is running:
   ```bash
   kubectl logs -n apps deployment/auth-service --tail=50
   ```

2. Test SearchUsers directly:
   ```bash
   grpcurl -plaintext -d '{"access_token":"<TOKEN>","query":"bob"}' \
     localhost:50051 auth.AuthService/SearchUsers
   ```

### Messages Not Received (Polling)

1. Check polling is active (see console logs)
2. Verify conversation ID is correct
3. Check messaging-service logs:
   ```bash
   kubectl logs -n apps deployment/messaging-service -f
   ```

### Connection Issues

1. Restart port-forwarding
2. Check firewall settings
3. Verify cluster network:
   ```bash
   kubectl get svc -n apps
   ```

---

## Backend API Testing (grpcurl)

Use grpcurl for direct API testing:

### Register User
```bash
grpcurl -plaintext -d '{"username":"testuser","email":"test@example.com","password":"Test123!","device_id":"device-001"}' \
  localhost:50051 auth.AuthService/Register
```

### Login
```bash
grpcurl -plaintext -d '{"username":"testuser","password":"Test123!","device_id":"device-001"}' \
  localhost:50051 auth.AuthService/Login
```

### Search Users
```bash
grpcurl -plaintext -d '{"access_token":"<TOKEN>","query":"bob"}' \
  localhost:50051 auth.AuthService/SearchUsers
```

### Send Message
```bash
grpcurl -plaintext -d '{"access_token":"<TOKEN>","recipient_user_id":"<USER_ID>","recipient_device_id":"<DEVICE_ID>","recipient_username":"bob","encrypted_content":"SGVsbG8=","message_type":"TEXT","client_message_id":"msg-001","client_timestamp":{"seconds":1732896000}}' \
  localhost:50052 messaging.MessagingService/SendMessage
```

### Get Messages
```bash
grpcurl -plaintext -d '{"access_token":"<TOKEN>","conversation_user_id":"<USER_ID>","conversation_id":"<CONV_ID>","limit":50}' \
  localhost:50052 messaging.MessagingService/GetMessages
```

### Get Conversations
```bash
grpcurl -plaintext -d '{"access_token":"<TOKEN>","limit":50}' \
  localhost:50052 messaging.MessagingService/GetConversations
```

---

## Document History

| Date | Version | Changes |
|------|---------|---------|
| November 29, 2025 | 1.0 | Initial version with all test scenarios |
