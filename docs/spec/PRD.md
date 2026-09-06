---
id: spec-prd
type: spec
status: accepted
owns: [backend/proto/, client-mobile/lib/, client-desktop/src/]
read_when: [adding a feature, questioning whether something is in scope, writing a client]
tokens: 1526
supersedes: []
---

# Product Requirements Document

**What the product does today**, in user-story form, grounded in the 94 RPCs that actually
exist. This is not a wish list: every story below maps to shipped RPCs, and anything not
yet built is in the "Not built" section rather than written as though it were.

Algorithms and parameters are in [`SRS.md`](SRS.md); the roadmap is in
[`../roadmap/ROADMAP.md`](../roadmap/ROADMAP.md).

## Who it is for

Someone who needs private communication and either does not want to trust a provider or
cannot. The self-hosting story is not a bonus feature — it is the product's reason to
exist, and it constrains every decision (**I-4**).

## Identity and contacts — `AuthService`, 19 RPCs

- *As a new user*, I register and log in, and receive an access token I can refresh
  without re-entering credentials.
  → `Register` `Login` `Logout` `RefreshToken` `ValidateToken`
- *As a user with several devices*, each device has its own keys, so compromising one does
  not expose the others.
  → `UploadPreKeys` `GetKeyBundle` `UploadMlsKeyPackage` `GetMlsKeyPackage`
- *As a user*, I find people, see and edit my profile, and delete my account outright.
  → `SearchUsers` `GetUserProfile` `UpdateProfile` `DeleteAccount`
- *As a user*, I keep a contact list with my own labels.
  → `AddContact` `RemoveContact` `ListContacts` `GetContact` `UpdateContact`

## Messaging — `MessagingService`, 34 RPCs

The largest surface, and the core of the product.

- *As a user*, I send and receive messages that only the recipient can read. The server
  stores ciphertext it cannot decrypt.
  → `SendMessage` `ReceiveMessages` `GetMessages` `GetConversations`
- *As a user*, I see when a message was delivered and read, and when someone is typing.
  → `MarkAsRead` `SendReadReceipt` `GetReadReceipts` `SendTypingIndicator`
- *As a user*, I correct or withdraw what I sent.
  → `EditMessage` `DeleteMessage` `ClearChat` `DeleteConversation`
- *As a user*, I react, forward, and search my own history.
  → `AddReaction` `RemoveReaction` `GetReactions` `ForwardMessage` `SearchMessages`
- *As a group member*, I take part in a group whose messages are encrypted to the group,
  with membership and roles that change over time.
  → `CreateGroup` `AddGroupMember` `RemoveGroupMember` `ChangeMemberRole` `UpdateGroup`
    `SendGroupMessage` `GetGroupMessages` `GetGroups` `GetGroupById` `LeaveGroup`
    `DeleteGroup`
- *As a user*, I set messages to disappear after a chosen interval.
  → `SetDisappearingMessages` `GetDisappearingConfig`
- *As a user*, I block someone and stop hearing from them.
  → `BlockUser` `UnblockUser` `GetBlockedUsers`

**Search is local to the user's own history.** The server cannot search plaintext it
cannot read — a direct consequence of I-1, not a limitation to be engineered away.

## Calls — `CallService`, 18 RPCs

- *As a user*, I place and receive one-to-one voice and video calls, with media encrypted
  frame by frame.
  → `InitiateCall` `AcceptCall` `RejectCall` `EndCall` `JoinCall` `LeaveCall`
    `ExchangeSFrameKey` `RotateSFrameKey`
- *As a participant*, I mute, turn video off, and share my screen.
  → `SetMute` `SetVideo` `SetScreenShare`
- *As a client*, I complete WebRTC negotiation and follow call state as it changes.
  → `ExchangeSdp` `ExchangeIceCandidate` `GetCallState` `StreamCallEvents`
    `SubscribeToIncomingCalls`
- *As a user*, I review my call history.
  → `GetCallHistory`

## Media — `MediaService`, 8 RPCs

- *As a user*, I attach images, video, files and voice messages; they are encrypted before
  upload and the server stores opaque blobs.
  → `UploadMedia` `DownloadMedia` `GetUploadUrl` `GetDownloadUrl` `GetMediaMetadata`
    `GenerateThumbnail` `ListMedia` `DeleteMedia`

## Presence — `PresenceService`, 7 RPCs

- *As a user*, I see who is reachable and when they were last seen, and I can subscribe to
  changes rather than poll.
  → `UpdateStatus` `GetStatus` `GetBulkStatus` `Subscribe` `UpdateLastSeen` `SetTyping`

## Notifications — `NotificationService`, 8 RPCs

- *As a user*, I am notified of messages while the app is closed, without the notification
  carrying the message.
  → `RegisterDevice` `UnregisterDevice` `UpdatePushToken` `SendTestNotification`
- *As a user*, I control what notifies me and mute individual conversations.
  → `GetNotificationSettings` `UpdateNotificationSettings` `MuteConversation`

## Platforms

Flutter for iOS and Android; Tauri 2 for Windows, macOS and Linux. Both reach the backend
through Envoy's gRPC-Web gateway and share the Rust crypto core through
`crypto-ffi`, so there is exactly one implementation of the cryptography.

## Cross-cutting requirements

| Requirement | Why |
|---|---|
| Encryption is never optional | I-2 — a switch that can be turned off will be |
| Nothing sensitive is ever logged | I-1 — the server must be unable to betray a user even if seized |
| Any domain, no vendor lock-in | I-4 — self-hosting is the product |
| Post-quantum key agreement | I-3 — traffic captured today must not decrypt in a decade |

## Not built

Stated plainly, because a PRD that implies capability is a PRD that misleads.

- **Group calls.** `CallService` covers one-to-one; multi-party needs an SFU.
- **Health for media-service.** Five of six services expose `Health`; `media.proto` has
  no such RPC (PR-27).
- **Post-quantum end to end.** The hybrid implementation exists in `crates/crypto`, but the
  `pq` feature is off by default and no proto field carries an ML-KEM key, so the server
  cannot publish one (PR-36…PR-40).
- **Always-on encryption.** `GUARDYN_E2EE_ENABLED` still exists and the non-E2EE handler is
  the registered one (PR-32).
- **A browser client.** Envoy routes three of six services; media, calls and notifications
  are not reachable from a browser today.
