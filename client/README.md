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

### Building the App

Build scripts are provided to compile the app for all platforms with warnings suppressed:

**Build all platforms:**

```bash
./scripts/build-all.sh [debug|release]  # Default: debug
```

**Build specific platforms:**

```bash
./scripts/build-linux.sh [debug|release]
./scripts/build-android.sh [debug|release]
./scripts/build-web.sh [debug|release]
```

**Build artifacts:**

- Linux: `build/linux/x64/debug/bundle/guardyn_client`
- Android: `build/app/outputs/flutter-apk/app-debug.apk`
- Web: `build/web`

**Note**: Build scripts suppress known warnings:

- Android: Java 8 deprecation warnings (using Java 11)
- Web: Wasm compatibility warnings (building for JS, not Wasm)

### Running the App

1. **Start k3d cluster:**

   ```bash
   cd ../infra
   just kube-create
   just kube-bootstrap
   just k8s-deploy auth
   just k8s-deploy messaging
   ```

2. **Port-forward backend services:**

   **Platform requirements:**

   | Platform                  | Envoy (18080) | Auth (50051) | Messaging (50052) |
   | ------------------------- | ------------- | ------------ | ----------------- |
   | **Chrome/Firefox/Safari** | ✅ Required   | ✅ Required  | ✅ Required       |
   | **Android/iOS native**    | ❌ Not needed | ✅ Required  | ✅ Required       |
   | **Linux/macOS/Windows**   | ❌ Not needed | ✅ Required  | ✅ Required       |

   **Terminal 1: Envoy Proxy (Web browsers ONLY)**

   ```bash
   kubectl port-forward -n apps svc/guardyn-envoy 18080:8080
   ```

   **Required for**: Chrome, Firefox, Safari (any web browser)  
   **Not needed for**: Android, iOS, Linux, macOS, Windows desktop apps

   **Why Envoy?** Browsers cannot create TCP sockets directly (security sandbox), so they cannot use native gRPC. Envoy translates gRPC-Web (HTTP/1.1 or HTTP/2 via browser `fetch` API) to native gRPC (HTTP/2 with gRPC framing).

   **Terminal 2: Auth Service (All platforms)**

   ```bash
   kubectl port-forward -n apps svc/auth-service 50051:50051
   ```

   **Terminal 3: Messaging Service (All platforms)**

   ```bash
   kubectl port-forward -n apps svc/messaging-service 50052:50052
   ```

   **Keep these terminals running throughout testing!**

3. **Run Flutter app:**

   ```bash
   flutter run
   ```

   Or for specific device:

   ```bash
   flutter devices  # List available devices
   flutter run -d chrome        # Web browser (needs Envoy)
   flutter run -d linux         # Linux desktop (no Envoy needed)
   flutter run -d <device-id>   # Android emulator (no Envoy needed)
   ```

## Testing

**📖 For comprehensive testing guide, see [CLIENT_TESTING_GUIDE.md](../docs/CLIENT_TESTING_GUIDE.md)**

The testing guide includes:

- Detailed setup instructions for all platforms
- Envoy proxy configuration for web browsers
- Manual testing scenarios and test cases
- Automated testing scripts
- Troubleshooting common issues

### Unit Tests (41 tests - 100% passing)

Run all unit tests:

```bash
cd client
flutter test
```

**Test Coverage:**

- AuthBloc: 18 tests
- RegisterUser use case: 11 tests
- LoginUser use case: 6 tests
- LogoutUser use case: 6 tests

### Integration Tests (Automated)

Integration tests simulate two users exchanging messages programmatically.

**Prerequisites:**

```bash
# 1. Ensure backend is running
kubectl get pods -n apps

# 2. Port-forward services
# Terminal 1: Envoy (web browsers only)
kubectl port-forward -n apps svc/guardyn-envoy 18080:8080

# Terminal 2: Auth service (all platforms)
kubectl port-forward -n apps svc/auth-service 50051:50051

# Terminal 3: Messaging service (all platforms)
kubectl port-forward -n apps svc/messaging-service 50052:50052
```

**Note**: Envoy (port 18080) is only required when testing on Chrome/web browsers. Native platforms (Android, Linux, iOS, macOS, Windows) connect directly to services on ports 50051/50052.

**Run integration tests:**

**Single-device test (simulated):**

```bash
cd client
./scripts/test-client.sh integration
```

**Two-client test (Android + Chrome):**

This tests real cross-platform messaging between Android and Chrome:

```bash
# Quick setup (manual testing)
cd client
./scripts/quick-two-client-setup.sh

# Follow on-screen instructions to run:
# Terminal 1: flutter run -d emulator-5554  (Alice on Android)
# Terminal 2: flutter run -d chrome (Bob on Chrome)
```

**Automated two-client test:**

```bash
cd client
./scripts/run-two-client-test.sh
```

See [Two-Client Testing Guide](../docs/TWO_CLIENT_TESTING.md) for detailed instructions

# Run on specific device

flutter test integration_test/ -d chrome flutter test integration_test/ -d emulator-5554

````

**What gets tested:**
- ✅ User registration (Alice and Bob)
- ✅ User login/logout flows
- ✅ Navigation to Messages screen
- ✅ Backend connectivity health check
- ⏳ Message sending (requires "New Chat" UI)

See `integration_test/README.md` for full documentation.

### Manual Testing (Two Devices)

For comprehensive UI testing with real devices/emulators, see detailed guide:

**📖 [MANUAL_TESTING_GUIDE.md](MANUAL_TESTING_GUIDE.md)**

**Quick start:**

1. **Launch two emulators:**
   ```bash
   emulator -avd Pixel_6_API_33 &
   emulator -avd Pixel_7_API_34 &
````

2. **Run Flutter on both devices:**

   ```bash
   # Terminal 3
   flutter run -d emulator-5554

   # Terminal 4
   flutter run -d emulator-5556
   ```

3. **Test messaging flow:**
   - Device 1: Register as "alice"
   - Device 2: Register as "bob"
   - Device 1: Send message to Bob's user ID
   - Device 2: Verify message received
   - Test bidirectional conversation

**18 comprehensive test cases** covering:

- Authentication (13 tests)
- Two-device messaging (8 tests)
- Error handling, offline scenarios, rapid sending

### Test Results Summary

Run the manual testing checklist and report:

- ✅ Test case results
- 🐛 Issues encountered
- 📸 Screenshots/recordings
- 💡 UX feedback

---

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

   **For web browsers (Chrome/Firefox/Safari):**

   ```bash
   # Check Envoy is running
   lsof -i :18080
   kubectl port-forward -n apps svc/guardyn-envoy 18080:8080

   # Check backend services
   lsof -i :50051
   kubectl port-forward -n apps svc/auth-service 50051:50051
   kubectl port-forward -n apps svc/messaging-service 50052:50052
   ```

   **For native platforms (Android/iOS/Desktop):**

   ```bash
   # Envoy not needed, only backend services
   lsof -i :50051
   kubectl port-forward -n apps svc/auth-service 50051:50051
   kubectl port-forward -n apps svc/messaging-service 50052:50052
   ```

3. Check platform-specific configuration:

   - **Web browsers**: Must use Envoy on port 18080 (gRPC-Web)
   - **Android emulator**: Uses `10.0.2.2:50051` to reach host machine
   - **Linux/Desktop**: Uses `localhost:50051` directly

4. Check firewall settings

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
