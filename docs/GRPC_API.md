# gRPC API Documentation

## Overview

Guardyn uses gRPC for efficient, type-safe service-to-service communication. All API definitions are in Protocol Buffers v3 format.

**Last Updated**: November 23, 2025  
**Status**: Services operational, Envoy proxy deployed for web clients

---

## gRPC Communication Architecture

### Native gRPC (Backend Services)

Backend services communicate using **native gRPC** (HTTP/2 with gRPC framing):
- **Auth Service**: `auth-service:50051`
- **Messaging Service**: `messaging-service:50052`

### gRPC-Web (Browser Clients)

Web browsers cannot use native gRPC due to browser security restrictions (no direct TCP socket access). Instead, they use **gRPC-Web** via Envoy proxy:

```
Chrome/Firefox → Envoy (Port 8080) → Native gRPC Backend
```

**Envoy translates**:
- **Incoming**: gRPC-Web (HTTP/1.1 or HTTP/2 via `fetch` API) → Native gRPC (HTTP/2 with gRPC framing)
- **Outgoing**: Native gRPC responses → gRPC-Web format

**Platform Requirements**:

| Platform                           | Protocol    | Port        | Envoy Required? |
| ---------------------------------- | ----------- | ----------- | --------------- |
| Web (Chrome/Firefox/Safari)        | gRPC-Web    | 8080        | ✅ Yes          |
| Flutter Mobile (Android/iOS)       | Native gRPC | 50051-50055 | ❌ No           |
| Tauri Desktop (Win/Mac/Linux)      | Native gRPC | 50051-50055 | ❌ No           |

**Envoy Configuration**: See `infra/envoy/` for proxy configuration.

---

## Protocol Files

| File                         | Service               | Description                                                    |
| ---------------------------- | --------------------- | -------------------------------------------------------------- |
| `proto/common.proto`         | -                     | Shared types (Timestamp, UserId, KeyBundle, Error, Pagination) |
| `proto/auth.proto`           | `AuthService`         | User registration, login, JWT tokens, key bundles              |
| `proto/messaging.proto`      | `MessagingService`    | 1-on-1 & group E2EE messaging, history, read receipts          |
| `proto/presence.proto`       | `PresenceService`     | Online status, last seen, typing indicators                    |
| `proto/calls.proto`          | `CallService`         | Voice/video calls with WebRTC signaling + SFrame E2EE          |
| `proto/notifications.proto`  | `NotificationService` | Push notifications (FCM/APNs), device registration             |
| `proto/media.proto`          | `MediaService`        | Encrypted media upload, download, thumbnails                   |

---

## Common Types (`common.proto`)

### Core Data Structures

```protobuf
message Timestamp {
  int64 seconds = 1;
  int32 nanos = 2;
}

message UserId {
  string id = 1; // UUID format
}

message DeviceId {
  string user_id = 1;
  string device_id = 2;
}

// PQXDH Key Bundle for Post-Quantum Secure Key Exchange
// Hybrid: X25519 (classical) + ML-KEM-768 (post-quantum)
message KeyBundle {
  // Identity keys
  bytes identity_key = 1;        // Ed25519 public key (32 bytes)

  // Classical X25519 pre-keys
  bytes signed_pre_key = 2;      // X25519 public key (32 bytes)
  bytes signed_pre_key_signature = 3; // Ed25519 signature (64 bytes)
  repeated bytes one_time_pre_keys = 4; // X25519 public keys

  // Post-Quantum ML-KEM-768 pre-keys (PQXDH extension)
  bytes pq_pre_key = 5;          // ML-KEM-768 public key (1184 bytes)
  bytes pq_pre_key_signature = 6; // Ed25519 signature over pq_pre_key (64 bytes)

  Timestamp created_at = 7;
}
```

### Error Handling

```protobuf
message ErrorResponse {
  enum ErrorCode {
    UNKNOWN = 0;
    INVALID_REQUEST = 1;
    UNAUTHORIZED = 2;
    FORBIDDEN = 3;
    NOT_FOUND = 4;
    CONFLICT = 5;
    INTERNAL_ERROR = 6;
    SERVICE_UNAVAILABLE = 7;
    RATE_LIMITED = 8;
  }

  ErrorCode code = 1;
  string message = 2;
  map<string, string> details = 3;
}
```

### Pagination

```protobuf
message PaginationRequest {
  uint32 page = 1;      // 0-indexed
  uint32 page_size = 2; // Max 100
}

message PaginationResponse {
  uint32 total_items = 1;
  uint32 total_pages = 2;
  uint32 current_page = 3;
  uint32 page_size = 4;
}
```

---

## Authentication Service (`auth.proto`)

### Overview

**Package**: `guardyn.auth`  
**Port**: 50051 (gRPC)

### 1.1 Data Storage

**Database**: TiKV (users, devices, sessions, keys)

### RPCs

| RPC             | Request                | Response                | Description                           |
| --------------- | ---------------------- | ----------------------- | ------------------------------------- |
| `Register`      | `RegisterRequest`      | `RegisterResponse`      | Create new user with E2EE key bundle  |
| `Login`         | `LoginRequest`         | `LoginResponse`         | Authenticate device, issue JWT tokens |
| `Logout`        | `LogoutRequest`        | `LogoutResponse`        | Invalidate session(s)                 |
| `RefreshToken`  | `RefreshTokenRequest`  | `RefreshTokenResponse`  | Renew access token                    |
| `ValidateToken` | `ValidateTokenRequest` | `ValidateTokenResponse` | Internal token validation             |
| `GetKeyBundle`  | `GetKeyBundleRequest`  | `GetKeyBundleResponse`  | Retrieve user's public keys           |
| `UploadPreKeys` | `UploadPreKeysRequest` | `UploadPreKeysResponse` | Key rotation                          |
| `Health`        | `HealthRequest`        | `HealthStatus`          | Health check                          |

### Registration Flow

```protobuf
message RegisterRequest {
  string username = 1;      // 3-32 chars, alphanumeric + _
  string password = 2;      // Min 12 chars (Argon2id hashed)
  string email = 3;         // Optional (recovery)
  string device_name = 4;   // e.g., "iPhone 15 Pro"
  string device_type = 5;   // "ios", "android", "web", "desktop"
  KeyBundle key_bundle = 6; // E2EE public keys
}

message RegisterResponse {
  oneof result {
    RegisterSuccess success = 1;
    ErrorResponse error = 2;
  }
}

message RegisterSuccess {
  string user_id = 1;        // UUID
  string device_id = 2;      // UUID
  string access_token = 3;   // JWT (15 min)
  string refresh_token = 4;  // JWT (30 days)
  Timestamp created_at = 5;
}
```

**Success Response Example**:

```json
{
  "success": {
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "device_id": "660e8400-e29b-41d4-a716-446655440000",
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "created_at": {
      "seconds": 1730649600,
      "nanos": 0
    }
  }
}
```

### Login Flow

```protobuf
message LoginRequest {
  string username = 1;
  string password = 2;
  string device_id = 3;       // Optional (if existing device)
  string device_name = 4;
  string device_type = 5;
  KeyBundle key_bundle = 6;   // Required for new devices
}

message LoginSuccess {
  string user_id = 1;
  string device_id = 2;
  string access_token = 3;
  string refresh_token = 4;
  UserProfile profile = 5;
  repeated DeviceInfo devices = 6; // All user's devices
}
```

### JWT Token Structure

**Access Token** (15 min expiry):

```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",
  "device_id": "660e8400-e29b-41d4-a716-446655440000",
  "exp": 1730650500,
  "iat": 1730649600,
  "permissions": ["read", "write"]
}
```

**Refresh Token** (30 days expiry):

```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",
  "device_id": "660e8400-e29b-41d4-a716-446655440000",
  "exp": 1733241600,
  "iat": 1730649600,
  "type": "refresh"
}
```

---

## Messaging Service (`messaging.proto`)

### Overview

**Package**: `guardyn.messaging`  
**Port**: 50052 (gRPC)  
**Databases**:

- TiKV (delivery state, session tracking)
- ScyllaDB (message history, media metadata)
- Redpanda (real-time message routing, Kafka-compatible)

### RPCs

| RPC                   | Type             | Description                    |
| --------------------- | ---------------- | ------------------------------ |
| `SendMessage`         | Unary            | Send encrypted 1-on-1 message  |
| `ReceiveMessages`     | Server Streaming | Real-time message stream       |
| `GetMessages`         | Unary            | Fetch message history          |
| `MarkAsRead`          | Unary            | Send read receipts             |
| `DeleteMessage`       | Unary            | Delete message (self/everyone) |
| `SendTypingIndicator` | Unary            | Notify typing status           |
| `CreateGroup`         | Unary            | Create MLS group chat          |
| `AddGroupMember`      | Unary            | Add member to group            |
| `RemoveGroupMember`   | Unary            | Remove member from group       |
| `SendGroupMessage`    | Unary            | Send encrypted group message   |
| `GetGroupMessages`    | Unary            | Fetch group chat history       |
| `Health`              | Unary            | Health check                   |

### Message Sending

```protobuf
message SendMessageRequest {
  string access_token = 1;
  string recipient_user_id = 2;
  string recipient_device_id = 3;  // Optional (all devices if not set)
  bytes encrypted_content = 4;     // Double Ratchet encrypted
  MessageType message_type = 5;
  string client_message_id = 6;    // UUID for deduplication
  Timestamp client_timestamp = 7;
  string media_id = 8;              // Optional media reference
}

enum MessageType {
  TEXT = 0;
  IMAGE = 1;
  VIDEO = 2;
  AUDIO = 3;
  FILE = 4;
  VOICE_NOTE = 5;
  LOCATION = 6;
}

enum DeliveryStatus {
  PENDING = 0;    // Queued
  SENT = 1;       // Sent to device
  DELIVERED = 2;  // Device confirmed
  READ = 3;       // User read
  FAILED = 4;     // Delivery failed
}
```

### Message Streaming

```protobuf
message ReceiveMessagesRequest {
  string access_token = 1;
  bool include_history = 2; // Send offline messages first
}

// Server streams Message objects
rpc ReceiveMessages(ReceiveMessagesRequest) returns (stream Message);
```

### Group Messaging (MLS)

```protobuf
message CreateGroupRequest {
  string access_token = 1;
  string group_name = 2;
  repeated string member_user_ids = 3;
  bytes mls_group_state = 4; // OpenMLS serialized state
}

message SendGroupMessageRequest {
  string access_token = 1;
  string group_id = 2;
  bytes encrypted_content = 3; // MLS encrypted
  MessageType message_type = 4;
  string client_message_id = 5;
  Timestamp client_timestamp = 6;
  string media_id = 7;
}
```

---

## Presence Service (`presence.proto`)

### Overview

**Package**: `guardyn.presence`  
**Port**: 50053 (gRPC)  
**Database**: ScyllaDB (presence table with 24h TTL)

### RPCs

| RPC              | Type             | Description                |
| ---------------- | ---------------- | -------------------------- |
| `UpdateStatus`   | Unary            | Set online/away/DND status |
| `GetStatus`      | Unary            | Query user's status        |
| `Subscribe`      | Server Streaming | Real-time presence updates |
| `UpdateLastSeen` | Unary            | Update last seen timestamp |
| `Health`         | Unary            | Health check               |

### User Status

```protobuf
enum UserStatus {
  OFFLINE = 0;
  ONLINE = 1;
  AWAY = 2;            // Idle >5 min
  DO_NOT_DISTURB = 3;  // Mute notifications
  INVISIBLE = 4;       // Appear offline
}

message UpdateStatusRequest {
  string access_token = 1;
  UserStatus status = 2;
  string custom_status_text = 3; // Max 100 chars
}
```

### Presence Subscriptions

```protobuf
message SubscribeRequest {
  string access_token = 1;
  repeated string user_ids = 2; // Max 100 users
}

// Server streams PresenceUpdate objects
message PresenceUpdate {
  string user_id = 1;
  UserStatus status = 2;
  string custom_status_text = 3;
  Timestamp last_seen = 4;
  Timestamp updated_at = 5;
  bool is_typing = 6;
  string typing_in_conversation_with = 7;
}
```

---

## Call Service (`calls.proto`)

### Service Overview

**Package**: `guardyn.calls`  
**Port**: 50054 (gRPC)  
**Features**: Voice/video calls with WebRTC + SFrame E2EE

### RPC Methods

| RPC                   | Type             | Description                              |
| --------------------- | ---------------- | ---------------------------------------- |
| `InitiateCall`        | Unary            | Start a 1-on-1 or group call             |
| `AcceptCall`          | Unary            | Accept an incoming call                  |
| `RejectCall`          | Unary            | Decline a call                           |
| `EndCall`             | Unary            | End an active call                       |
| `JoinCall`            | Unary            | Join an ongoing group call               |
| `LeaveCall`           | Unary            | Leave group call without ending          |
| `SetMute`             | Unary            | Mute/unmute audio                        |
| `SetVideo`            | Unary            | Enable/disable video                     |
| `SetScreenShare`      | Unary            | Start/stop screen sharing                |
| `ExchangeIceCandidate`| Unary            | WebRTC ICE candidate exchange            |
| `ExchangeSdp`         | Unary            | WebRTC SDP offer/answer exchange         |
| `GetCallState`        | Unary            | Get current call state                   |
| `GetCallHistory`      | Unary            | Fetch call history                       |
| `StreamCallEvents`    | Server Streaming | Real-time call events (join/leave/state) |
| `ExchangeSFrameKey`   | Unary            | Exchange SFrame encryption keys          |
| `RotateSFrameKey`     | Unary            | Rotate SFrame key mid-call               |
| `Health`              | Unary            | Health check                             |

### Call Types and States

```protobuf
enum CallType {
  UNKNOWN_CALL_TYPE = 0;
  VOICE = 1;           // Voice-only call
  VIDEO = 2;           // Video call
}

enum CallState {
  UNKNOWN_STATE = 0;
  INITIATING = 1;      // Call is being set up
  RINGING = 2;         // Remote party is being notified
  CONNECTING = 3;      // Call accepted, establishing connection
  CONNECTED = 4;       // Call is active
  ON_HOLD = 5;         // Call is on hold
  ENDED = 6;           // Call has ended
  FAILED = 7;          // Call failed to connect
}
```

### SFrame E2EE

All media streams are encrypted using SFrame (RFC 9605):

```protobuf
message InitiateCallSuccess {
  string call_id = 1;
  CallState state = 2;
  Timestamp created_at = 3;
  repeated IceServer ice_servers = 4;  // TURN/STUN servers
  bytes sframe_key_material = 5;       // SFrame encryption key
  uint32 sframe_key_id = 6;            // Key identifier for rotation
}

message IceServer {
  repeated string urls = 1;    // STUN/TURN server URLs
  string username = 2;         // TURN username
  string credential = 3;       // TURN credential
}
```

---

## Notification Service (`notifications.proto`)

### Service Overview

**Package**: `guardyn.notifications`  
**Port**: 50055 (gRPC)  
**Platforms**: FCM (Android), APNs (iOS), Web Push (future)

### RPC Methods

| RPC                        | Type  | Description                        |
| -------------------------- | ----- | ---------------------------------- |
| `RegisterDevice`           | Unary | Register device for push           |
| `UnregisterDevice`         | Unary | Remove device registration         |
| `UpdatePushToken`          | Unary | Update FCM/APNs token              |
| `GetNotificationSettings`  | Unary | Get user's notification prefs      |
| `UpdateNotificationSettings`| Unary | Update notification preferences   |
| `MuteConversation`         | Unary | Mute/unmute a conversation         |
| `SendTestNotification`     | Unary | Send test push (debugging)         |
| `Health`                   | Unary | Health check                       |

### Device Registration

```protobuf
enum PushPlatform {
  UNKNOWN_PLATFORM = 0;
  FCM = 1;          // Firebase Cloud Messaging (Android)
  APNS = 2;         // Apple Push Notification Service (iOS)
  APNS_SANDBOX = 3; // APNs Sandbox (iOS development)
  WEB_PUSH = 4;     // Web Push (future)
}

message RegisterDeviceRequest {
  string access_token = 1;
  string device_id = 2;           // Unique device identifier
  string push_token = 3;          // FCM/APNs token
  PushPlatform platform = 4;
  string device_name = 5;         // "iPhone 15 Pro"
  string app_version = 6;
  string os_version = 7;
}
```

### Notification Settings

```protobuf
message NotificationSettings {
  bool notifications_enabled = 1;
  bool sound_enabled = 2;
  bool vibration_enabled = 3;
  bool show_preview = 4;          // Show message content
  bool show_sender = 5;           // Show sender name

  // Quiet hours
  bool quiet_hours_enabled = 6;
  int32 quiet_hours_start = 7;    // Start hour (0-23)
  int32 quiet_hours_end = 8;      // End hour (0-23)
  string quiet_hours_timezone = 9; // IANA timezone

  // Category toggles
  bool notify_messages = 10;
  bool notify_reactions = 11;
  bool notify_mentions = 12;
  bool notify_calls = 13;
  bool notify_group_messages = 14;
}
```

---

## Code Generation

### Build Configuration

Each service has a `build.rs` file:

```rust
fn main() -> Result<(), Box<dyn std::error::Error>> {
    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .out_dir("src/generated")
        .compile(
            &[
                "../proto/common.proto",
                "../proto/auth.proto",
            ],
            &["../proto"],
        )?;

    println!("cargo:rerun-if-changed=../proto/common.proto");
    println!("cargo:rerun-if-changed=../proto/auth.proto");

    Ok(())
}
```

### Generated Code Location

```text
backend/crates/auth-service/src/generated/
  ├── guardyn.common.rs
  └── guardyn.auth.rs

backend/crates/messaging-service/src/generated/
  ├── guardyn.common.rs
  └── guardyn.messaging.rs

backend/crates/presence-service/src/generated/
  ├── guardyn.common.rs
  └── guardyn.presence.rs

backend/crates/call-service/src/generated/
  ├── guardyn.common.rs
  └── guardyn.calls.rs

backend/crates/notification-service/src/generated/
  ├── guardyn.common.rs
  └── guardyn.notifications.rs
```

### Usage Example

```rust
// Import generated code
pub mod generated {
    pub mod auth {
        tonic::include_proto!("guardyn.auth");
    }
    pub mod common {
        tonic::include_proto!("guardyn.common");
    }
}

use generated::auth::{auth_service_server::AuthService, RegisterRequest, RegisterResponse};

// Implement service
#[tonic::async_trait]
impl AuthService for MyAuthService {
    async fn register(
        &self,
        request: tonic::Request<RegisterRequest>,
    ) -> Result<tonic::Response<RegisterResponse>, tonic::Status> {
        // Implementation
    }
}
```

---

## Security Considerations

### Authentication

- All RPCs (except `Register`, `Login`, `Health`) require `access_token` in request
- Tokens validated against TiKV sessions
- Short-lived access tokens (15 min) + long-lived refresh tokens (30 days)
- Session invalidation on logout

### Encryption

- **Message Content**: Double Ratchet (1-on-1), OpenMLS (groups), SFrame (calls)
- **Key Exchange**: PQXDH protocol (X25519 + ML-KEM-768 hybrid) for post-quantum security
- **Metadata Protection**: Sealed Sender for anonymous message delivery
- **Transport**: TLS 1.3 for all gRPC connections
- **At Rest**: ScyllaDB transparent encryption, TiKV encrypted backups
- **Traffic Analysis**: PADMÉ padding to constant message sizes

### Rate Limiting

- Registration: 5 attempts/hour per IP
- Login: 10 attempts/hour per account
- Message sending: 100 msg/min per user
- API requests: 1000 req/min per token

---

## Testing

### Unit Tests

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_register_success() {
        // Test implementation
    }
}
```

### Integration Tests

```bash
# Start test environment
docker-compose -f tests/docker-compose.yml up -d

# Run tests
cargo test --workspace --features integration-tests
```

### gRPC Client Testing

```bash
# Using grpcurl
grpcurl -plaintext -d @ localhost:50051 guardyn.auth.AuthService/Health <<EOF
{}
EOF
```

---

## Next Steps

1. ✅ Protocol definitions complete
2. ✅ Build configuration added
3. ⏳ Generate Rust code: `cargo build`
4. ⏳ Implement service handlers
5. ⏳ Add integration tests
6. ⏳ Deploy to Kubernetes with Ingress

**Status**: Ready for implementation phase.

---

**Maintained By**: Guardyn Backend Team  
**Contact**: See `CONTRIBUTING.md` for contribution guidelines
