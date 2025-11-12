# Guardyn Flutter Client

Privacy-focused secure communication platform - Mobile client implementation.

## Overview

This is the Flutter mobile client for Guardyn MVP. It provides user authentication and will support 1-on-1 messaging, group chat, and end-to-end encrypted communication.

**Current Status**: Initial authentication flow implemented (registration + login).

## Features Implemented

### ✅ Phase 1: Authentication (Current)

- User registration with device management
- User login with JWT token management
- Secure token storage (flutter_secure_storage)
- Clean Architecture pattern (Domain/Data/Presentation layers)
- BLoC state management for authentication
- Splash screen with auto-login check
- Basic UI (Material Design 3)

### 🚧 Phase 2: Messaging (Planned)

- 1-on-1 messaging
- Message history
- Real-time message delivery (NATS subscription)
- E2EE with Double Ratchet protocol
- Message read receipts

### 🚧 Phase 3: Group Chat (Planned)

- Group creation and management
- MLS-encrypted group messages
- Member management

## Architecture

### Clean Architecture Layers

```
lib/
├── core/                      # Shared utilities
│   ├── di/                   # Dependency injection (GetIt)
│   ├── network/              # gRPC clients
│   ├── storage/              # Secure storage wrapper
│   └── constants/            # App configuration
│
├── features/                 # Feature modules
│   └── auth/                # Authentication feature
│       ├── domain/          # Business logic
│       │   ├── entities/   # User entity
│       │   ├── repositories/ # Repository interface
│       │   └── usecases/   # RegisterUser, LoginUser, LogoutUser
│       ├── data/           # Data layer
│       │   ├── datasources/ # gRPC remote datasource
│       │   └── repositories/ # Repository implementation
│       └── presentation/   # UI layer
│           ├── bloc/      # BLoC state management
│           └── pages/     # UI screens
│
└── generated/              # Protocol Buffers generated code
```

### Data Flow

```
UI Widget → BLoC Event → Use Case → Repository → Remote Datasource (gRPC) → Backend
                                        ↓
                                   Secure Storage
                ↓
         BLoC State → UI Update
```

## Setup

### Prerequisites

- Flutter 3.x SDK
- Dart SDK 3.x
- Protocol Buffers compiler (protoc)
- Running Guardyn backend services (see `../infra/`)

### Installation

1. **Install dependencies:**

   ```bash
   flutter pub get
   ```

2. **Generate Dart code from proto files:**

   ```bash
   ./scripts/generate_proto.sh
   ```

3. **Configure backend endpoints:**

   Edit `lib/core/constants/config.dart` to match your backend:

   ```dart
   static const String authHost = 'localhost';
   static const int authPort = 50051;
   ```

### Running the App

1. **Start k3d cluster and port-forward services:**

   ```bash
   cd ../infra
   just kube-create
   just kube-bootstrap
   just k8s-deploy auth

   # Port-forward auth service
   kubectl port-forward -n apps svc/auth-service 50051:50051
   ```

2. **Run Flutter app:**

   ```bash
   flutter run
   ```

   Or for specific device:

   ```bash
   flutter devices  # List available devices
   flutter run -d <device-id>
   ```

## Testing

### Manual Testing

1. **Registration Flow:**

   - Launch app
   - Tap "Don't have an account? Register"
   - Fill in: username, password, confirm password, device name
   - Tap "Register"
   - Should navigate to home page with user info

2. **Login Flow:**

   - Launch app (after registering)
   - Logout from home page
   - Enter username and password
   - Tap "Login"
   - Should navigate to home page

3. **Error Handling:**
   - Try invalid credentials
   - Try duplicate username registration
   - Try weak password (< 8 chars)

### Unit Tests

```bash
flutter test
```

## Dependencies

### Core

- `flutter_bloc ^8.1.3` - State management
- `equatable ^2.0.5` - Value equality
- `get_it ^7.6.4` - Dependency injection

### Networking

- `grpc ^4.3.1` - gRPC client
- `protobuf ^5.1.0` - Protocol Buffers

### Storage

- `flutter_secure_storage ^9.0.0` - Secure token storage

### Utilities

- `logger ^2.0.2+1` - Logging
- `intl ^0.18.1` - Internationalization

## Configuration

### gRPC Endpoints

**Local Development (with port-forwarding):**

```dart
authHost: 'localhost'
authPort: 50051
messagingHost: 'localhost'
messagingPort: 50052
```

**Production (with TLS - future):**

```dart
authHost: 'auth.yourdomain.com'
authPort: 443
```

### Secure Storage

Tokens are stored using platform-specific secure storage:

- **iOS**: Keychain
- **Android**: EncryptedSharedPreferences
- **Linux**: libsecret
- **Windows**: Credential Store

## Known Limitations

### Current Session

1. **Placeholder Cryptography**: KeyBundle generation uses random bytes instead of real X3DH keys
2. **No Messaging UI**: Only authentication implemented
3. **No Group Chat**: Group features not implemented
4. **No Offline Support**: No local message caching
5. **No Push Notifications**: Requires notification service integration

### Future Work

- Implement X3DH key generation (real cryptography)
- Implement Double Ratchet for 1-on-1 E2EE
- Add messaging UI (chat screens)
- Add group chat UI
- Implement offline message caching (SQLite)
- Add push notifications (FCM/APNs)
- Add biometric authentication
- Add device management UI
- Add key backup/restore

## Troubleshooting

### gRPC Connection Errors

**Error**: `Connection refused` or `failed to connect`

**Solution**:

1. Verify backend services are running:
   ```bash
   kubectl get pods -n apps
   ```
2. Verify port-forwarding is active:
   ```bash
   kubectl port-forward -n apps svc/auth-service 50051:50051
   ```
3. Check firewall settings

### Proto Generation Errors

**Error**: `protoc-gen-dart not found`

**Solution**:

```bash
dart pub global activate protoc_plugin
export PATH="$PATH:$HOME/.pub-cache/bin"
```

### Secure Storage Errors (Linux)

**Error**: `MissingPluginException` on Linux

**Solution**: Install libsecret:

```bash
sudo apt-get install libsecret-1-dev
```

## Project Structure

```
client/
├── lib/
│   ├── main.dart                  # App entry point
│   ├── app.dart                   # MaterialApp configuration
│   ├── core/                      # Shared utilities
│   ├── features/                  # Feature modules
│   └── generated/                 # Proto-generated code
├── proto/                         # .proto files (copied from backend)
├── scripts/
│   └── generate_proto.sh         # Proto generation script
├── test/                          # Unit tests
├── pubspec.yaml                   # Dependencies
└── README.md                      # This file
```

## Contributing

See `../CONTRIBUTING.md` for contribution guidelines.

## License

See `../LICENSE` for license information.
