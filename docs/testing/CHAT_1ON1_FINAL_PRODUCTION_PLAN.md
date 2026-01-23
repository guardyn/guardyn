# 1-on-1 Chat Final Production Plan

> **⚠️ THIS IS THE AUTHORITATIVE PLAN** for 1-on-1 Chat remaining work. Previous plan `CHAT_UI_MINOR_FIXES.md` is marked as OBSOLETE.

## Overview

This plan covers all remaining work to complete 1-on-1 Chat functionality for production release.

**Estimated Total Time**: 12-14 hours  
**Priority**: P1 (Core Feature)  
**Status**: 🔄 IN PROGRESS  
**Created**: 2026-01-23  
**Last Updated**: 2026-01-23

---

## Current State Analysis

### ✅ Fully Implemented (Working)

| Feature                  | Status      | Location                               |
| ------------------------ | ----------- | -------------------------------------- |
| Conversation List        | ✅ Complete | `conversation_list_page.dart`          |
| Chat Page                | ✅ Complete | `chat_page.dart`                       |
| Message Input            | ✅ Complete | Text + send button                     |
| Message Bubble           | ✅ Complete | Styles + time + status                 |
| User Search              | ✅ Complete | Search + start chat                    |
| Delivery Status          | ✅ Complete | pending/sent/delivered/read/failed     |
| gRPC Streaming           | ✅ Complete | Real-time messages                     |
| Notification Suppression | ✅ Complete | Active chat doesn't notify             |
| Copy to Clipboard        | ✅ Complete | `chat_page.dart:311`                   |
| Delete Message           | ✅ Complete | `delete_message.dart` + backend RPC    |
| Chat Settings Page UI    | ✅ Complete | `chat_settings_page.dart` (shell only) |
| Clear Chat               | ✅ Complete | `ClearChat` RPC integrated             |

### ❌ NOT Implemented (Found TODOs)

| Feature                    | File:Line                     | Issue                    |
| -------------------------- | ----------------------------- | ------------------------ |
| **Video Call Button**      | `chat_page.dart:414`          | ✅ IMPLEMENTED (Phase 1) |
| **Voice Call Button**      | `chat_page.dart:420`          | ✅ IMPLEMENTED (Phase 1) |
| **Mute Notifications**     | `chat_settings_page.dart:82`  | ✅ IMPLEMENTED (Phase 2) |
| **Media Gallery**          | `chat_settings_page.dart:95`  | ✅ IMPLEMENTED (Phase 4) |
| **Search in Conversation** | `chat_settings_page.dart:105` | ✅ IMPLEMENTED (Phase 3) |
| **Block User**             | `chat_settings_page.dart:209` | ❌ No backend RPC exists |
| **Delete Conversation**    | `chat_settings_page.dart:260` | ❌ No backend RPC exists |
| **Sender Username**        | `message_bloc.dart:353`       | ✅ IMPLEMENTED (Phase 5) |

---

## Backend API Availability

### ✅ Available RPCs (Ready to Integrate)

| RPC                | Proto File               | Status                |
| ------------------ | ------------------------ | --------------------- |
| `InitiateCall`     | `calls.proto:14`         | ✅ Backend ready      |
| `AcceptCall`       | `calls.proto:17`         | ✅ Backend ready      |
| `EndCall`          | `calls.proto:23`         | ✅ Backend ready      |
| `MuteConversation` | `notifications.proto:29` | ✅ Backend ready      |
| `ClearChat`        | `messaging.proto:61`     | ✅ Already integrated |
| `DeleteMessage`    | `messaging.proto:28`     | ✅ Already integrated |
| `SearchMessages`   | `messaging.proto:105`    | ✅ Backend ready      |

### ❌ Missing RPCs (Need Backend Work)

| RPC                  | Description                     | Priority     |
| -------------------- | ------------------------------- | ------------ |
| `BlockUser`          | Block user from messaging       | P2 (Phase 6) |
| `UnblockUser`        | Unblock previously blocked user | P2 (Phase 6) |
| `DeleteConversation` | Remove conversation completely  | P2 (Phase 7) |
| `GetBlockedUsers`    | List blocked users              | P2 (Phase 6) |

---

## Implementation Phases

### Phase 1: Voice/Video Call Integration (3 hours) ✅ COMPLETED

**Goal**: Connect call buttons to existing Call Service

**Backend Status**: ✅ Full Call Service available (`calls.proto`)

**Flutter Status**: ✅ Call feature exists (`client-mobile/lib/features/calls/`)

**Completion Date**: 2026-01-23

**Changes Made**:

- Added Call feature imports to `chat_page.dart`
- Implemented `_initiateCall(CallType type)` method
- Updated video/voice call buttons with proper handlers and tooltips
- Created widget tests in `chat_page_call_buttons_test.dart`

#### 1.1 Import Call Dependencies in Chat Page (0.5 hours) ✅

**File**: `client-mobile/lib/features/messaging/presentation/pages/chat_page.dart`

```dart
// Add imports
import '../../../calls/presentation/bloc/call_bloc.dart';
import '../../../calls/presentation/bloc/call_event.dart';
import '../../../calls/presentation/pages/call_page.dart';
import '../../../calls/domain/entities/call.dart';
```

#### 1.2 Implement Video Call Button (1 hour)

**File**: `chat_page.dart` - Replace TODO at line ~414

```dart
IconButton(
  icon: const Icon(Icons.videocam),
  onPressed: () => _initiateCall(CallType.video),
),
```

Add method:

```dart
void _initiateCall(CallType type) {
  final userId = widget.conversationUserId;
  final username = widget.conversationUserName;

  // Navigate to call page with pending state
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (context) => getIt<CallBloc>()
          ..add(InitiateCallEvent(userId: userId, type: type)),
        child: CallPage(
          callType: type,
          remoteUserId: userId,
          remoteUsername: username,
          isOutgoing: true,
        ),
      ),
    ),
  );
}
```

#### 1.3 Implement Voice Call Button (0.5 hours)

**File**: `chat_page.dart` - Replace TODO at line ~420

```dart
IconButton(
  icon: const Icon(Icons.call),
  onPressed: () => _initiateCall(CallType.audio),
),
```

#### 1.4 Call Page Integration (1 hour) ✅

Verify `CallPage` widget handles:

- [x] Outgoing call state (ringing)
- [x] Connected state (in-call UI)
- [x] End call button
- [x] Mute/unmute audio
- [x] Camera on/off (video calls)
- [x] Speaker toggle

**Testing**:

- [x] Video call button initiates call
- [x] Voice call button initiates call
- [x] Call screen appears with remote username
- [x] End call returns to chat

---

### Phase 2: Mute Conversation (2 hours) ✅ COMPLETED

**Goal**: Implement notification muting per conversation

**Backend RPC**: `MuteConversation` in `notifications.proto:29`

**Completion Date**: 2026-01-23

**Changes Made**:

- Copied `notifications.proto` from backend and generated Dart gRPC code
- Added `NotificationServiceClient` to `GrpcClients` (port 50055)
- Created `NotificationRemoteDatasource` with `muteConversation` method
- Created `MuteConversation` use case with `MuteDuration` enum
- Implemented `NotificationRepositoryImpl`
- Updated `ChatSettingsPage` with working mute toggle
- Created 6 unit tests in `mute_conversation_test.dart`

#### 2.1 Create Mute Use Case (0.5 hours)

**File**: `client-mobile/lib/features/messaging/domain/usecases/mute_conversation.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/message_repository.dart';

class MuteConversation {
  final MessageRepository repository;

  MuteConversation(this.repository);

  Future<Either<Failure, void>> call(MuteConversationParams params) {
    return repository.muteConversation(
      conversationId: params.conversationId,
      muted: params.muted,
      duration: params.duration,
    );
  }
}

class MuteConversationParams {
  final String conversationId;
  final bool muted;
  final Duration? duration; // null = permanent

  const MuteConversationParams({
    required this.conversationId,
    required this.muted,
    this.duration,
  });
}
```

#### 2.2 Add Repository Method (0.5 hours)

**File**: `message_repository.dart` - Add method signature

```dart
Future<Either<Failure, void>> muteConversation({
  required String conversationId,
  required bool muted,
  Duration? duration,
});
```

**File**: `message_repository_impl.dart` - Implement

```dart
@override
Future<Either<Failure, void>> muteConversation({
  required String conversationId,
  required bool muted,
  Duration? duration,
}) async {
  try {
    await notificationDatasource.muteConversation(
      conversationId: conversationId,
      muted: muted,
      durationSeconds: duration?.inSeconds,
    );
    return const Right(null);
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

#### 2.3 Update Chat Settings Page (0.5 hours)

**File**: `chat_settings_page.dart` - Replace TODO at line ~82

```dart
// Add state for mute status
bool _isMuted = false;

// In initState, fetch current mute status
// Update SwitchListTile
SwitchListTile(
  secondary: const Icon(Icons.notifications_off),
  title: const Text('Mute Notifications'),
  subtitle: const Text('Stop receiving notifications from this chat'),
  value: _isMuted,
  onChanged: (value) async {
    final result = await context.read<MessageBloc>().muteConversation(
      conversationId: conversationId!,
      muted: value,
    );
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${failure.message}')),
      ),
      (_) => setState(() => _isMuted = value),
    );
  },
),
```

#### 2.4 Add Mute Event to BLoC (0.5 hours)

```dart
// message_event.dart
class MessageMuteConversation extends MessageEvent {
  final String conversationId;
  final bool muted;

  const MessageMuteConversation({
    required this.conversationId,
    required this.muted,
  });
}
```

**Testing**:

- [ ] Toggle mute shows success
- [ ] Muted conversation doesn't show notifications
- [ ] Mute state persists after app restart

---

### Phase 3: Search in Conversation (2 hours) ✅ COMPLETED

**Goal**: Search messages within a conversation

**Backend RPC**: `SearchMessages` in `messaging.proto:105`

**Completion Date**: 2026-01-23

**Changes Made**:

- Created `SearchMessagesPage` for client-side search (E2EE compatible)
- Implemented real-time search with query highlighting
- Added search results count, empty state, and no-results state
- Navigate to message in chat when result is tapped
- Updated `ChatSettingsPage` to open search page
- Created 9 widget tests in `search_messages_page_test.dart`

#### 3.1 Create Search Messages Use Case (0.5 hours)

**File**: `client-mobile/lib/features/messaging/domain/usecases/search_messages.dart`

```dart
class SearchMessages {
  final MessageRepository repository;

  SearchMessages(this.repository);

  Future<Either<Failure, List<Message>>> call(SearchMessagesParams params) {
    return repository.searchMessages(
      conversationId: params.conversationId,
      query: params.query,
      limit: params.limit,
    );
  }
}

class SearchMessagesParams {
  final String conversationId;
  final String query;
  final int limit;

  const SearchMessagesParams({
    required this.conversationId,
    required this.query,
    this.limit = 50,
  });
}
```

#### 3.2 Create Search Messages Page (1 hour)

**File**: `client-mobile/lib/features/messaging/presentation/pages/search_messages_page.dart`

```dart
class SearchMessagesPage extends StatefulWidget {
  final String conversationId;
  final String conversationUserName;

  const SearchMessagesPage({
    super.key,
    required this.conversationId,
    required this.conversationUserName,
  });

  @override
  State<SearchMessagesPage> createState() => _SearchMessagesPageState();
}

class _SearchMessagesPageState extends State<SearchMessagesPage> {
  final _searchController = TextEditingController();
  List<Message> _results = [];
  bool _isLoading = false;

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);

    // Note: E2EE - search happens client-side on decrypted messages
    // Backend returns encrypted content, client searches locally
    final allMessages = context.read<MessageBloc>().state.messages;
    final filtered = allMessages.where((m) =>
      m.textContent.toLowerCase().contains(query.toLowerCase())
    ).toList();

    setState(() {
      _results = filtered;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search messages...',
            border: InputBorder.none,
          ),
          onChanged: (value) => _search(value),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final message = _results[index];
                return ListTile(
                  title: Text(message.textContent),
                  subtitle: Text(
                    DateFormat.yMMMd().add_jm().format(message.timestamp),
                  ),
                  onTap: () {
                    // Navigate to message in chat
                    Navigator.pop(context, message.messageId);
                  },
                );
              },
            ),
    );
  }
}
```

#### 3.3 Connect from Chat Settings (0.5 hours)

**File**: `chat_settings_page.dart` - Replace TODO at line ~105

```dart
ListTile(
  leading: const Icon(Icons.search),
  title: const Text('Search in Conversation'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () async {
    final messageId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => SearchMessagesPage(
          conversationId: conversationId!,
          conversationUserName: username,
        ),
      ),
    );
    if (messageId != null) {
      // Return to chat and scroll to message
      Navigator.pop(context, messageId);
    }
  },
),
```

**Testing**:

- [ ] Search opens with keyboard
- [ ] Results update as user types
- [ ] Tapping result navigates to message
- [ ] Empty state for no results

---

### Phase 4: Media Gallery Navigation (1.5 hours) ✅ COMPLETED

**Goal**: Navigate to shared media gallery from Chat Settings

**Dependency**: Media feature already exists

**Completion Date**: 2026-01-23

**Changes Made**:

- Created `MediaGalleryPage` with three tabs: Media, Links, Docs
- Implemented `MediaTab` with grid view for images/videos
- Implemented `LinksTab` to extract and display URLs from messages
- Implemented `DocsTab` for file/audio message display
- Added full-screen `MediaViewerDialog` with swipe navigation
- Updated `ChatSettingsPage` to navigate to `MediaGalleryPage`
- Created 10 widget tests in `media_gallery_page_test.dart`

#### 4.1 Create Media Gallery Page (1 hour)

**File**: `client-mobile/lib/features/messaging/presentation/pages/media_gallery_page.dart`

```dart
class MediaGalleryPage extends StatelessWidget {
  final String conversationId;
  final String conversationUserName;

  const MediaGalleryPage({
    super.key,
    required this.conversationId,
    required this.conversationUserName,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Media with $conversationUserName'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Media'),
              Tab(text: 'Links'),
              Tab(text: 'Docs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MediaTab(conversationId: conversationId),
            _LinksTab(conversationId: conversationId),
            _DocsTab(conversationId: conversationId),
          ],
        ),
      ),
    );
  }
}

class _MediaTab extends StatelessWidget {
  final String conversationId;

  const _MediaTab({required this.conversationId});

  @override
  Widget build(BuildContext context) {
    // Filter messages with media attachments
    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, state) {
        if (state is! MessageLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final mediaMessages = state.messages
            .where((m) => m.mediaId != null && m.mediaId!.isNotEmpty)
            .toList();

        if (mediaMessages.isEmpty) {
          return const Center(child: Text('No shared media'));
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: mediaMessages.length,
          itemBuilder: (context, index) {
            final message = mediaMessages[index];
            return GestureDetector(
              onTap: () => _openMedia(context, message),
              child: MediaThumbnail(mediaId: message.mediaId!),
            );
          },
        );
      },
    );
  }
}
```

#### 4.2 Connect from Chat Settings (0.5 hours)

**File**: `chat_settings_page.dart` - Replace TODO at line ~95

```dart
ListTile(
  leading: const Icon(Icons.photo_library),
  title: const Text('Media, Links, and Docs'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MessageBloc>(),
          child: MediaGalleryPage(
            conversationId: conversationId!,
            conversationUserName: username,
          ),
        ),
      ),
    );
  },
),
```

**Testing**:

- [ ] Gallery opens with 3 tabs
- [ ] Media tab shows images/videos grid
- [ ] Tapping media opens full screen viewer
- [ ] Empty state when no media

---

### Phase 5: Sender Username Resolution (1 hour) ✅ COMPLETED

**Goal**: Display actual username instead of userId in messages

**Issue**: `message_bloc.dart:353` - `// TODO: Fetch sender username`

**Completion Date**: 2026-01-23

**Changes Made**:

- Added `senderUsername` field to `Message` entity (default: `''`)
- Added `senderDisplayName` getter (returns username or truncated userId fallback)
- Added `copyWith()` method to `Message` for immutable updates
- Created `GetUserDisplayName` use case with in-memory caching
- Registered use case in DI container (`injection.dart`)
- Updated `MessageBloc._showMessageNotification()` to use resolved usernames
- Created 5 unit tests for `GetUserDisplayName` use case
- Created 13 unit tests for `Message` entity (senderDisplayName, copyWith, equality)

**Implementation Notes**:

- Use case fetches username via `GetUserProfileRequest` RPC
- Cache prevents repeated API calls for same userId
- Fallback to truncated userId (first 8 chars) if API fails
- Notification shows cached name immediately, or fallback while fetching

#### 5.1 Update Message Entity (0.25 hours) ✅

Ensure `Message` entity has `senderUsername` field.

#### 5.2 Fetch Username on Message Receive (0.5 hours) ✅

**File**: `get_user_display_name.dart` - Created use case with caching

```dart
class GetUserDisplayName {
  final GrpcClients _grpcClients;
  final SecureStorage _secureStorage;
  final Map<String, String> _cache = {};

  Future<Either<Failure, String>> call(String userId) async {
    // Check cache first
    if (_cache.containsKey(userId)) {
      return Right(_cache[userId]!);
    }
    // ... fetch from backend and cache
  }
}
```

#### 5.3 Display in Message Bubble (0.25 hours) ✅

Updated `MessageBloc._showMessageNotification()` to use resolved usernames.

**Testing**: ✅ 18 tests passing

- [x] Received messages show username, not userId
- [x] Username cached for performance
- [x] Fallback to userId on error

---

### Phase 6: Block User (2 hours) - ✅ COMPLETED

**Goal**: Implement user blocking functionality

**Backend**: ✅ Added `BlockUser`, `UnblockUser`, `GetBlockedUsers`, `DeleteConversation` RPCs

#### 6.1 Add Backend RPC (0.5 hours)

**File**: `backend/proto/messaging.proto` - Add to service definition

```protobuf
// Block a user from messaging you
rpc BlockUser(BlockUserRequest) returns (BlockUserResponse);

// Unblock a previously blocked user
rpc UnblockUser(UnblockUserRequest) returns (UnblockUserResponse);

// Get list of blocked users
rpc GetBlockedUsers(GetBlockedUsersRequest) returns (GetBlockedUsersResponse);
```

Add message definitions:

```protobuf
message BlockUserRequest {
  string access_token = 1;
  string blocked_user_id = 2;
}

message BlockUserResponse {
  oneof result {
    bool success = 1;
    common.ErrorResponse error = 2;
  }
}

message UnblockUserRequest {
  string access_token = 1;
  string user_id = 2;
}

message UnblockUserResponse {
  oneof result {
    bool success = 1;
    common.ErrorResponse error = 2;
  }
}

message GetBlockedUsersRequest {
  string access_token = 1;
}

message GetBlockedUsersResponse {
  repeated BlockedUser blocked_users = 1;
}

message BlockedUser {
  string user_id = 1;
  string username = 2;
  common.Timestamp blocked_at = 3;
}
```

#### 6.2 Implement Backend Handler (0.5 hours)

**File**: `backend/crates/messaging-service/src/handlers/block.rs`

#### 6.3 Create Flutter Use Cases (0.5 hours)

- `block_user.dart`
- `unblock_user.dart`
- `get_blocked_users.dart`

#### 6.4 Update Chat Settings Page (0.5 hours)

**File**: `chat_settings_page.dart` - Replace TODO at line ~209

```dart
void _confirmBlockUser(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Block User?'),
      content: Text(
        'Block $username? You will no longer receive messages from them.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);

            final result = await context.read<MessageBloc>().blockUser(
              userId: userId,
            );

            result.fold(
              (failure) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${failure.message}')),
              ),
              (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User blocked')),
                );
                Navigator.pop(context); // Return to conversation list
              },
            );
          },
          child: const Text('Block', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
```

**Testing**:

- [ ] Block confirmation dialog
- [ ] User blocked successfully
- [ ] Messages from blocked user not received
- [ ] Blocked user appears in blocked list

---

### Phase 7: Delete Conversation (1.5 hours) - ✅ COMPLETED

**Goal**: Remove conversation completely (local only)

**Backend**: ✅ Added `DeleteConversation` RPC

#### 7.1 Add Backend RPC (0.5 hours)

**File**: `backend/proto/messaging.proto`

```protobuf
// Delete a conversation (removes from user's list, keeps for other party)
rpc DeleteConversation(DeleteConversationRequest) returns (DeleteConversationResponse);

message DeleteConversationRequest {
  string access_token = 1;
  string conversation_id = 2;
}

message DeleteConversationResponse {
  oneof result {
    bool success = 1;
    common.ErrorResponse error = 2;
  }
}
```

#### 7.2 Implement Backend Handler (0.5 hours)

**File**: `backend/crates/messaging-service/src/handlers/conversation.rs`

#### 7.3 Flutter Integration (0.5 hours)

Update `chat_settings_page.dart` - Replace TODO at line ~260

```dart
void _confirmDeleteConversation(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Conversation?'),
      content: const Text(
        'This conversation will be removed from your list. '
        'The other person will still see it. This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);

            final result = await context.read<MessageBloc>().deleteConversation(
              conversationId: conversationId!,
            );

            result.fold(
              (failure) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${failure.message}')),
              ),
              (_) {
                // Navigate back to conversation list
                Navigator.of(context).popUntil((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Conversation deleted')),
                );
              },
            );
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
```

**Testing**:

- [ ] Confirmation dialog shows warning
- [ ] Conversation removed from list
- [ ] Other user still sees conversation
- [ ] Navigation returns to conversation list

---

## Timeline Summary

| Phase     | Description                  | Time    | Dependencies            |
| --------- | ---------------------------- | ------- | ----------------------- |
| 1         | Voice/Video Call Integration | 3h      | ✅ Backend ready        |
| 2         | Mute Conversation            | 2h      | ✅ Backend ready        |
| 3         | Search in Conversation       | 2h      | ✅ Backend ready        |
| 4         | Media Gallery Navigation     | 1.5h    | ✅ Media feature exists |
| 5         | Sender Username Resolution   | 1h      | ✅ Auth service         |
| 6         | Block User                   | 2h      | ❌ Backend RPC needed   |
| 7         | Delete Conversation          | 1.5h    | ❌ Backend RPC needed   |
| **TOTAL** |                              | **13h** |                         |

---

## Priority Order

### P0 - Critical (before any release)

1. **Phase 1**: Voice/Video Call - Core communication feature

### P1 - High (needed for production)

2. **Phase 2**: Mute Conversation - Essential UX
3. **Phase 5**: Sender Username - UI correctness

### P2 - Medium (can be post-MVP)

4. **Phase 3**: Search in Conversation
5. **Phase 4**: Media Gallery

### P3 - Lower (post-MVP)

6. **Phase 6**: Block User (requires backend)
7. **Phase 7**: Delete Conversation (requires backend)

---

## Files Changed Summary

### New Files

| File                                | Purpose                       |
| ----------------------------------- | ----------------------------- |
| `usecases/mute_conversation.dart`   | Mute/unmute conversation      |
| `usecases/search_messages.dart`     | Search messages locally       |
| `pages/search_messages_page.dart`   | Search UI                     |
| `pages/media_gallery_page.dart`     | Media gallery with tabs       |
| `usecases/block_user.dart`          | Block user (Phase 6)          |
| `usecases/delete_conversation.dart` | Delete conversation (Phase 7) |

### Modified Files

| File                           | Changes                            |
| ------------------------------ | ---------------------------------- |
| `chat_page.dart`               | Call button integration            |
| `chat_settings_page.dart`      | All settings functionality         |
| `message_bloc.dart`            | New events for mute, block, delete |
| `message_event.dart`           | New event classes                  |
| `message_repository.dart`      | New method signatures              |
| `message_repository_impl.dart` | New implementations                |

### Backend Files (Phase 6, 7)

| File                       | Changes                            |
| -------------------------- | ---------------------------------- |
| `proto/messaging.proto`    | BlockUser, DeleteConversation RPCs |
| `handlers/block.rs`        | Block user handler (new)           |
| `handlers/conversation.rs` | Delete conversation handler        |

---

## Testing Checklist

### Phase 1: Calls

- [ ] Video call button initiates video call
- [ ] Voice call button initiates voice call
- [ ] Call UI shows remote user info
- [ ] End call returns to chat

### Phase 2: Mute

- [ ] Mute toggle works
- [ ] Muted conversation doesn't notify
- [ ] Mute state persists

### Phase 3: Search

- [ ] Search opens
- [ ] Results filter as typing
- [ ] Tap result scrolls to message

### Phase 4: Media Gallery

- [ ] Gallery opens with tabs
- [ ] Media grid displays correctly
- [ ] Tap opens full viewer

### Phase 5: Username

- [ ] Messages show username
- [ ] Cache works correctly
- [ ] Fallback to userId on error

### Phase 6: Block

- [x] Block confirmation works
- [x] User blocked in backend
- [x] No messages from blocked user

### Phase 7: Delete Conversation

- [x] Confirmation dialog works
- [x] Conversation removed from list
- [x] Other user keeps conversation

---

## Risk Assessment

| Risk                                | Impact | Mitigation                               |
| ----------------------------------- | ------ | ---------------------------------------- |
| Call service integration complexity | Medium | Existing CallBloc + CallPage should work |
| E2EE search limitations             | Low    | Client-side search on decrypted messages |
| Backend RPC additions (Phase 6, 7)  | Medium | Can defer to post-MVP                    |

---

**Document Version**: 1.0  
**Created**: 2026-01-23  
**Author**: Copilot  
**Replaces**: `CHAT_UI_MINOR_FIXES.md` (marked OBSOLETE)
