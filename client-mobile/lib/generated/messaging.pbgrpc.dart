// This is a generated file - do not edit.
//
// Generated from messaging.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $1;
import 'messaging.pb.dart' as $0;

export 'messaging.pb.dart';

@$pb.GrpcServiceName('guardyn.messaging.MessagingService')
class MessagingServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  MessagingServiceClient(super.channel, {super.options, super.interceptors});

  /// Send 1-on-1 encrypted message
  $grpc.ResponseFuture<$0.SendMessageResponse> sendMessage(
    $0.SendMessageRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sendMessage, request, options: options);
  }

  /// Receive messages (streaming from server)
  $grpc.ResponseStream<$0.Message> receiveMessages(
    $0.ReceiveMessagesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$receiveMessages, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Get message history
  $grpc.ResponseFuture<$0.GetMessagesResponse> getMessages(
    $0.GetMessagesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getMessages, request, options: options);
  }

  /// Get list of conversations
  $grpc.ResponseFuture<$0.GetConversationsResponse> getConversations(
    $0.GetConversationsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getConversations, request, options: options);
  }

  /// Mark message as read (send read receipt)
  $grpc.ResponseFuture<$0.MarkAsReadResponse> markAsRead(
    $0.MarkAsReadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$markAsRead, request, options: options);
  }

  /// Delete message (for self or for everyone)
  $grpc.ResponseFuture<$0.DeleteMessageResponse> deleteMessage(
    $0.DeleteMessageRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteMessage, request, options: options);
  }

  /// Send typing indicator
  $grpc.ResponseFuture<$0.TypingIndicatorResponse> sendTypingIndicator(
    $0.TypingIndicatorRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sendTypingIndicator, request, options: options);
  }

  /// Create group chat
  $grpc.ResponseFuture<$0.CreateGroupResponse> createGroup(
    $0.CreateGroupRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createGroup, request, options: options);
  }

  /// Add member to group
  $grpc.ResponseFuture<$0.AddGroupMemberResponse> addGroupMember(
    $0.AddGroupMemberRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addGroupMember, request, options: options);
  }

  /// Remove member from group
  $grpc.ResponseFuture<$0.RemoveGroupMemberResponse> removeGroupMember(
    $0.RemoveGroupMemberRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeGroupMember, request, options: options);
  }

  /// Change a member's role in a group (owner only)
  $grpc.ResponseFuture<$0.ChangeMemberRoleResponse> changeMemberRole(
    $0.ChangeMemberRoleRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$changeMemberRole, request, options: options);
  }

  /// Send group message
  $grpc.ResponseFuture<$0.SendGroupMessageResponse> sendGroupMessage(
    $0.SendGroupMessageRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sendGroupMessage, request, options: options);
  }

  /// Get group messages
  $grpc.ResponseFuture<$0.GetGroupMessagesResponse> getGroupMessages(
    $0.GetGroupMessagesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getGroupMessages, request, options: options);
  }

  /// Get all groups for the current user
  $grpc.ResponseFuture<$0.GetGroupsResponse> getGroups(
    $0.GetGroupsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getGroups, request, options: options);
  }

  /// Get group details by ID
  $grpc.ResponseFuture<$0.GetGroupByIdResponse> getGroupById(
    $0.GetGroupByIdRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getGroupById, request, options: options);
  }

  /// Update group (name, icon, description)
  $grpc.ResponseFuture<$0.UpdateGroupResponse> updateGroup(
    $0.UpdateGroupRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateGroup, request, options: options);
  }

  /// Leave a group
  $grpc.ResponseFuture<$0.LeaveGroupResponse> leaveGroup(
    $0.LeaveGroupRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$leaveGroup, request, options: options);
  }

  /// Delete a group (owner only)
  $grpc.ResponseFuture<$0.DeleteGroupResponse> deleteGroup(
    $0.DeleteGroupRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteGroup, request, options: options);
  }

  /// Clear all messages in a conversation (local delete for current user)
  $grpc.ResponseFuture<$0.ClearChatResponse> clearChat(
    $0.ClearChatRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$clearChat, request, options: options);
  }

  /// Add reaction to a message
  $grpc.ResponseFuture<$0.AddReactionResponse> addReaction(
    $0.AddReactionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addReaction, request, options: options);
  }

  /// Remove reaction from a message
  $grpc.ResponseFuture<$0.RemoveReactionResponse> removeReaction(
    $0.RemoveReactionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeReaction, request, options: options);
  }

  /// Get all reactions for a message
  $grpc.ResponseFuture<$0.GetReactionsResponse> getReactions(
    $0.GetReactionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getReactions, request, options: options);
  }

  /// Send read receipt for a conversation
  $grpc.ResponseFuture<$0.SendReadReceiptResponse> sendReadReceipt(
    $0.SendReadReceiptRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sendReadReceipt, request, options: options);
  }

  /// Get read receipts for a conversation (who read what)
  $grpc.ResponseFuture<$0.GetReadReceiptsResponse> getReadReceipts(
    $0.GetReadReceiptsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getReadReceipts, request, options: options);
  }

  /// Forward a message to another conversation
  $grpc.ResponseFuture<$0.ForwardMessageResponse> forwardMessage(
    $0.ForwardMessageRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$forwardMessage, request, options: options);
  }

  /// Edit a previously sent message
  $grpc.ResponseFuture<$0.EditMessageResponse> editMessage(
    $0.EditMessageRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$editMessage, request, options: options);
  }

  /// Search messages (returns encrypted content for client-side search)
  $grpc.ResponseFuture<$0.SearchMessagesResponse> searchMessages(
    $0.SearchMessagesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$searchMessages, request, options: options);
  }

  /// Set disappearing messages config for a conversation
  $grpc.ResponseFuture<$0.SetDisappearingMessagesResponse>
      setDisappearingMessages(
    $0.SetDisappearingMessagesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setDisappearingMessages, request,
        options: options);
  }

  /// Get disappearing messages config
  $grpc.ResponseFuture<$0.GetDisappearingConfigResponse> getDisappearingConfig(
    $0.GetDisappearingConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDisappearingConfig, request, options: options);
  }

  /// Block a user from messaging you
  $grpc.ResponseFuture<$0.BlockUserResponse> blockUser(
    $0.BlockUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$blockUser, request, options: options);
  }

  /// Unblock a previously blocked user
  $grpc.ResponseFuture<$0.UnblockUserResponse> unblockUser(
    $0.UnblockUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unblockUser, request, options: options);
  }

  /// Get list of blocked users
  $grpc.ResponseFuture<$0.GetBlockedUsersResponse> getBlockedUsers(
    $0.GetBlockedUsersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getBlockedUsers, request, options: options);
  }

  /// Delete a conversation (removes from user's list, keeps for other party)
  $grpc.ResponseFuture<$0.DeleteConversationResponse> deleteConversation(
    $0.DeleteConversationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteConversation, request, options: options);
  }

  /// Health check
  $grpc.ResponseFuture<$1.HealthStatus> health(
    $0.HealthRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$health, request, options: options);
  }

  // method descriptors

  static final _$sendMessage =
      $grpc.ClientMethod<$0.SendMessageRequest, $0.SendMessageResponse>(
          '/guardyn.messaging.MessagingService/SendMessage',
          ($0.SendMessageRequest value) => value.writeToBuffer(),
          $0.SendMessageResponse.fromBuffer);
  static final _$receiveMessages =
      $grpc.ClientMethod<$0.ReceiveMessagesRequest, $0.Message>(
          '/guardyn.messaging.MessagingService/ReceiveMessages',
          ($0.ReceiveMessagesRequest value) => value.writeToBuffer(),
          $0.Message.fromBuffer);
  static final _$getMessages =
      $grpc.ClientMethod<$0.GetMessagesRequest, $0.GetMessagesResponse>(
          '/guardyn.messaging.MessagingService/GetMessages',
          ($0.GetMessagesRequest value) => value.writeToBuffer(),
          $0.GetMessagesResponse.fromBuffer);
  static final _$getConversations = $grpc.ClientMethod<
          $0.GetConversationsRequest, $0.GetConversationsResponse>(
      '/guardyn.messaging.MessagingService/GetConversations',
      ($0.GetConversationsRequest value) => value.writeToBuffer(),
      $0.GetConversationsResponse.fromBuffer);
  static final _$markAsRead =
      $grpc.ClientMethod<$0.MarkAsReadRequest, $0.MarkAsReadResponse>(
          '/guardyn.messaging.MessagingService/MarkAsRead',
          ($0.MarkAsReadRequest value) => value.writeToBuffer(),
          $0.MarkAsReadResponse.fromBuffer);
  static final _$deleteMessage =
      $grpc.ClientMethod<$0.DeleteMessageRequest, $0.DeleteMessageResponse>(
          '/guardyn.messaging.MessagingService/DeleteMessage',
          ($0.DeleteMessageRequest value) => value.writeToBuffer(),
          $0.DeleteMessageResponse.fromBuffer);
  static final _$sendTypingIndicator =
      $grpc.ClientMethod<$0.TypingIndicatorRequest, $0.TypingIndicatorResponse>(
          '/guardyn.messaging.MessagingService/SendTypingIndicator',
          ($0.TypingIndicatorRequest value) => value.writeToBuffer(),
          $0.TypingIndicatorResponse.fromBuffer);
  static final _$createGroup =
      $grpc.ClientMethod<$0.CreateGroupRequest, $0.CreateGroupResponse>(
          '/guardyn.messaging.MessagingService/CreateGroup',
          ($0.CreateGroupRequest value) => value.writeToBuffer(),
          $0.CreateGroupResponse.fromBuffer);
  static final _$addGroupMember =
      $grpc.ClientMethod<$0.AddGroupMemberRequest, $0.AddGroupMemberResponse>(
          '/guardyn.messaging.MessagingService/AddGroupMember',
          ($0.AddGroupMemberRequest value) => value.writeToBuffer(),
          $0.AddGroupMemberResponse.fromBuffer);
  static final _$removeGroupMember = $grpc.ClientMethod<
          $0.RemoveGroupMemberRequest, $0.RemoveGroupMemberResponse>(
      '/guardyn.messaging.MessagingService/RemoveGroupMember',
      ($0.RemoveGroupMemberRequest value) => value.writeToBuffer(),
      $0.RemoveGroupMemberResponse.fromBuffer);
  static final _$changeMemberRole = $grpc.ClientMethod<
          $0.ChangeMemberRoleRequest, $0.ChangeMemberRoleResponse>(
      '/guardyn.messaging.MessagingService/ChangeMemberRole',
      ($0.ChangeMemberRoleRequest value) => value.writeToBuffer(),
      $0.ChangeMemberRoleResponse.fromBuffer);
  static final _$sendGroupMessage = $grpc.ClientMethod<
          $0.SendGroupMessageRequest, $0.SendGroupMessageResponse>(
      '/guardyn.messaging.MessagingService/SendGroupMessage',
      ($0.SendGroupMessageRequest value) => value.writeToBuffer(),
      $0.SendGroupMessageResponse.fromBuffer);
  static final _$getGroupMessages = $grpc.ClientMethod<
          $0.GetGroupMessagesRequest, $0.GetGroupMessagesResponse>(
      '/guardyn.messaging.MessagingService/GetGroupMessages',
      ($0.GetGroupMessagesRequest value) => value.writeToBuffer(),
      $0.GetGroupMessagesResponse.fromBuffer);
  static final _$getGroups =
      $grpc.ClientMethod<$0.GetGroupsRequest, $0.GetGroupsResponse>(
          '/guardyn.messaging.MessagingService/GetGroups',
          ($0.GetGroupsRequest value) => value.writeToBuffer(),
          $0.GetGroupsResponse.fromBuffer);
  static final _$getGroupById =
      $grpc.ClientMethod<$0.GetGroupByIdRequest, $0.GetGroupByIdResponse>(
          '/guardyn.messaging.MessagingService/GetGroupById',
          ($0.GetGroupByIdRequest value) => value.writeToBuffer(),
          $0.GetGroupByIdResponse.fromBuffer);
  static final _$updateGroup =
      $grpc.ClientMethod<$0.UpdateGroupRequest, $0.UpdateGroupResponse>(
          '/guardyn.messaging.MessagingService/UpdateGroup',
          ($0.UpdateGroupRequest value) => value.writeToBuffer(),
          $0.UpdateGroupResponse.fromBuffer);
  static final _$leaveGroup =
      $grpc.ClientMethod<$0.LeaveGroupRequest, $0.LeaveGroupResponse>(
          '/guardyn.messaging.MessagingService/LeaveGroup',
          ($0.LeaveGroupRequest value) => value.writeToBuffer(),
          $0.LeaveGroupResponse.fromBuffer);
  static final _$deleteGroup =
      $grpc.ClientMethod<$0.DeleteGroupRequest, $0.DeleteGroupResponse>(
          '/guardyn.messaging.MessagingService/DeleteGroup',
          ($0.DeleteGroupRequest value) => value.writeToBuffer(),
          $0.DeleteGroupResponse.fromBuffer);
  static final _$clearChat =
      $grpc.ClientMethod<$0.ClearChatRequest, $0.ClearChatResponse>(
          '/guardyn.messaging.MessagingService/ClearChat',
          ($0.ClearChatRequest value) => value.writeToBuffer(),
          $0.ClearChatResponse.fromBuffer);
  static final _$addReaction =
      $grpc.ClientMethod<$0.AddReactionRequest, $0.AddReactionResponse>(
          '/guardyn.messaging.MessagingService/AddReaction',
          ($0.AddReactionRequest value) => value.writeToBuffer(),
          $0.AddReactionResponse.fromBuffer);
  static final _$removeReaction =
      $grpc.ClientMethod<$0.RemoveReactionRequest, $0.RemoveReactionResponse>(
          '/guardyn.messaging.MessagingService/RemoveReaction',
          ($0.RemoveReactionRequest value) => value.writeToBuffer(),
          $0.RemoveReactionResponse.fromBuffer);
  static final _$getReactions =
      $grpc.ClientMethod<$0.GetReactionsRequest, $0.GetReactionsResponse>(
          '/guardyn.messaging.MessagingService/GetReactions',
          ($0.GetReactionsRequest value) => value.writeToBuffer(),
          $0.GetReactionsResponse.fromBuffer);
  static final _$sendReadReceipt =
      $grpc.ClientMethod<$0.SendReadReceiptRequest, $0.SendReadReceiptResponse>(
          '/guardyn.messaging.MessagingService/SendReadReceipt',
          ($0.SendReadReceiptRequest value) => value.writeToBuffer(),
          $0.SendReadReceiptResponse.fromBuffer);
  static final _$getReadReceipts =
      $grpc.ClientMethod<$0.GetReadReceiptsRequest, $0.GetReadReceiptsResponse>(
          '/guardyn.messaging.MessagingService/GetReadReceipts',
          ($0.GetReadReceiptsRequest value) => value.writeToBuffer(),
          $0.GetReadReceiptsResponse.fromBuffer);
  static final _$forwardMessage =
      $grpc.ClientMethod<$0.ForwardMessageRequest, $0.ForwardMessageResponse>(
          '/guardyn.messaging.MessagingService/ForwardMessage',
          ($0.ForwardMessageRequest value) => value.writeToBuffer(),
          $0.ForwardMessageResponse.fromBuffer);
  static final _$editMessage =
      $grpc.ClientMethod<$0.EditMessageRequest, $0.EditMessageResponse>(
          '/guardyn.messaging.MessagingService/EditMessage',
          ($0.EditMessageRequest value) => value.writeToBuffer(),
          $0.EditMessageResponse.fromBuffer);
  static final _$searchMessages =
      $grpc.ClientMethod<$0.SearchMessagesRequest, $0.SearchMessagesResponse>(
          '/guardyn.messaging.MessagingService/SearchMessages',
          ($0.SearchMessagesRequest value) => value.writeToBuffer(),
          $0.SearchMessagesResponse.fromBuffer);
  static final _$setDisappearingMessages = $grpc.ClientMethod<
          $0.SetDisappearingMessagesRequest,
          $0.SetDisappearingMessagesResponse>(
      '/guardyn.messaging.MessagingService/SetDisappearingMessages',
      ($0.SetDisappearingMessagesRequest value) => value.writeToBuffer(),
      $0.SetDisappearingMessagesResponse.fromBuffer);
  static final _$getDisappearingConfig = $grpc.ClientMethod<
          $0.GetDisappearingConfigRequest, $0.GetDisappearingConfigResponse>(
      '/guardyn.messaging.MessagingService/GetDisappearingConfig',
      ($0.GetDisappearingConfigRequest value) => value.writeToBuffer(),
      $0.GetDisappearingConfigResponse.fromBuffer);
  static final _$blockUser =
      $grpc.ClientMethod<$0.BlockUserRequest, $0.BlockUserResponse>(
          '/guardyn.messaging.MessagingService/BlockUser',
          ($0.BlockUserRequest value) => value.writeToBuffer(),
          $0.BlockUserResponse.fromBuffer);
  static final _$unblockUser =
      $grpc.ClientMethod<$0.UnblockUserRequest, $0.UnblockUserResponse>(
          '/guardyn.messaging.MessagingService/UnblockUser',
          ($0.UnblockUserRequest value) => value.writeToBuffer(),
          $0.UnblockUserResponse.fromBuffer);
  static final _$getBlockedUsers =
      $grpc.ClientMethod<$0.GetBlockedUsersRequest, $0.GetBlockedUsersResponse>(
          '/guardyn.messaging.MessagingService/GetBlockedUsers',
          ($0.GetBlockedUsersRequest value) => value.writeToBuffer(),
          $0.GetBlockedUsersResponse.fromBuffer);
  static final _$deleteConversation = $grpc.ClientMethod<
          $0.DeleteConversationRequest, $0.DeleteConversationResponse>(
      '/guardyn.messaging.MessagingService/DeleteConversation',
      ($0.DeleteConversationRequest value) => value.writeToBuffer(),
      $0.DeleteConversationResponse.fromBuffer);
  static final _$health = $grpc.ClientMethod<$0.HealthRequest, $1.HealthStatus>(
      '/guardyn.messaging.MessagingService/Health',
      ($0.HealthRequest value) => value.writeToBuffer(),
      $1.HealthStatus.fromBuffer);
}

@$pb.GrpcServiceName('guardyn.messaging.MessagingService')
abstract class MessagingServiceBase extends $grpc.Service {
  $core.String get $name => 'guardyn.messaging.MessagingService';

  MessagingServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.SendMessageRequest, $0.SendMessageResponse>(
            'SendMessage',
            sendMessage_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SendMessageRequest.fromBuffer(value),
            ($0.SendMessageResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ReceiveMessagesRequest, $0.Message>(
        'ReceiveMessages',
        receiveMessages_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.ReceiveMessagesRequest.fromBuffer(value),
        ($0.Message value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetMessagesRequest, $0.GetMessagesResponse>(
            'GetMessages',
            getMessages_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetMessagesRequest.fromBuffer(value),
            ($0.GetMessagesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetConversationsRequest,
            $0.GetConversationsResponse>(
        'GetConversations',
        getConversations_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetConversationsRequest.fromBuffer(value),
        ($0.GetConversationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.MarkAsReadRequest, $0.MarkAsReadResponse>(
        'MarkAsRead',
        markAsRead_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.MarkAsReadRequest.fromBuffer(value),
        ($0.MarkAsReadResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DeleteMessageRequest, $0.DeleteMessageResponse>(
            'DeleteMessage',
            deleteMessage_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DeleteMessageRequest.fromBuffer(value),
            ($0.DeleteMessageResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TypingIndicatorRequest,
            $0.TypingIndicatorResponse>(
        'SendTypingIndicator',
        sendTypingIndicator_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TypingIndicatorRequest.fromBuffer(value),
        ($0.TypingIndicatorResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.CreateGroupRequest, $0.CreateGroupResponse>(
            'CreateGroup',
            createGroup_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CreateGroupRequest.fromBuffer(value),
            ($0.CreateGroupResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddGroupMemberRequest,
            $0.AddGroupMemberResponse>(
        'AddGroupMember',
        addGroupMember_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AddGroupMemberRequest.fromBuffer(value),
        ($0.AddGroupMemberResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RemoveGroupMemberRequest,
            $0.RemoveGroupMemberResponse>(
        'RemoveGroupMember',
        removeGroupMember_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RemoveGroupMemberRequest.fromBuffer(value),
        ($0.RemoveGroupMemberResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeMemberRoleRequest,
            $0.ChangeMemberRoleResponse>(
        'ChangeMemberRole',
        changeMemberRole_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChangeMemberRoleRequest.fromBuffer(value),
        ($0.ChangeMemberRoleResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SendGroupMessageRequest,
            $0.SendGroupMessageResponse>(
        'SendGroupMessage',
        sendGroupMessage_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SendGroupMessageRequest.fromBuffer(value),
        ($0.SendGroupMessageResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetGroupMessagesRequest,
            $0.GetGroupMessagesResponse>(
        'GetGroupMessages',
        getGroupMessages_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetGroupMessagesRequest.fromBuffer(value),
        ($0.GetGroupMessagesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetGroupsRequest, $0.GetGroupsResponse>(
        'GetGroups',
        getGroups_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetGroupsRequest.fromBuffer(value),
        ($0.GetGroupsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetGroupByIdRequest, $0.GetGroupByIdResponse>(
            'GetGroupById',
            getGroupById_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetGroupByIdRequest.fromBuffer(value),
            ($0.GetGroupByIdResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UpdateGroupRequest, $0.UpdateGroupResponse>(
            'UpdateGroup',
            updateGroup_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UpdateGroupRequest.fromBuffer(value),
            ($0.UpdateGroupResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LeaveGroupRequest, $0.LeaveGroupResponse>(
        'LeaveGroup',
        leaveGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LeaveGroupRequest.fromBuffer(value),
        ($0.LeaveGroupResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DeleteGroupRequest, $0.DeleteGroupResponse>(
            'DeleteGroup',
            deleteGroup_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DeleteGroupRequest.fromBuffer(value),
            ($0.DeleteGroupResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ClearChatRequest, $0.ClearChatResponse>(
        'ClearChat',
        clearChat_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ClearChatRequest.fromBuffer(value),
        ($0.ClearChatResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AddReactionRequest, $0.AddReactionResponse>(
            'AddReaction',
            addReaction_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AddReactionRequest.fromBuffer(value),
            ($0.AddReactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RemoveReactionRequest,
            $0.RemoveReactionResponse>(
        'RemoveReaction',
        removeReaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RemoveReactionRequest.fromBuffer(value),
        ($0.RemoveReactionResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetReactionsRequest, $0.GetReactionsResponse>(
            'GetReactions',
            getReactions_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetReactionsRequest.fromBuffer(value),
            ($0.GetReactionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SendReadReceiptRequest,
            $0.SendReadReceiptResponse>(
        'SendReadReceipt',
        sendReadReceipt_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SendReadReceiptRequest.fromBuffer(value),
        ($0.SendReadReceiptResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetReadReceiptsRequest,
            $0.GetReadReceiptsResponse>(
        'GetReadReceipts',
        getReadReceipts_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetReadReceiptsRequest.fromBuffer(value),
        ($0.GetReadReceiptsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ForwardMessageRequest,
            $0.ForwardMessageResponse>(
        'ForwardMessage',
        forwardMessage_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ForwardMessageRequest.fromBuffer(value),
        ($0.ForwardMessageResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.EditMessageRequest, $0.EditMessageResponse>(
            'EditMessage',
            editMessage_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.EditMessageRequest.fromBuffer(value),
            ($0.EditMessageResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SearchMessagesRequest,
            $0.SearchMessagesResponse>(
        'SearchMessages',
        searchMessages_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SearchMessagesRequest.fromBuffer(value),
        ($0.SearchMessagesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetDisappearingMessagesRequest,
            $0.SetDisappearingMessagesResponse>(
        'SetDisappearingMessages',
        setDisappearingMessages_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetDisappearingMessagesRequest.fromBuffer(value),
        ($0.SetDisappearingMessagesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetDisappearingConfigRequest,
            $0.GetDisappearingConfigResponse>(
        'GetDisappearingConfig',
        getDisappearingConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetDisappearingConfigRequest.fromBuffer(value),
        ($0.GetDisappearingConfigResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BlockUserRequest, $0.BlockUserResponse>(
        'BlockUser',
        blockUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BlockUserRequest.fromBuffer(value),
        ($0.BlockUserResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UnblockUserRequest, $0.UnblockUserResponse>(
            'UnblockUser',
            unblockUser_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UnblockUserRequest.fromBuffer(value),
            ($0.UnblockUserResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetBlockedUsersRequest,
            $0.GetBlockedUsersResponse>(
        'GetBlockedUsers',
        getBlockedUsers_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetBlockedUsersRequest.fromBuffer(value),
        ($0.GetBlockedUsersResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteConversationRequest,
            $0.DeleteConversationResponse>(
        'DeleteConversation',
        deleteConversation_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteConversationRequest.fromBuffer(value),
        ($0.DeleteConversationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HealthRequest, $1.HealthStatus>(
        'Health',
        health_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HealthRequest.fromBuffer(value),
        ($1.HealthStatus value) => value.writeToBuffer()));
  }

  $async.Future<$0.SendMessageResponse> sendMessage_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SendMessageRequest> $request) async {
    return sendMessage($call, await $request);
  }

  $async.Future<$0.SendMessageResponse> sendMessage(
      $grpc.ServiceCall call, $0.SendMessageRequest request);

  $async.Stream<$0.Message> receiveMessages_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ReceiveMessagesRequest> $request) async* {
    yield* receiveMessages($call, await $request);
  }

  $async.Stream<$0.Message> receiveMessages(
      $grpc.ServiceCall call, $0.ReceiveMessagesRequest request);

  $async.Future<$0.GetMessagesResponse> getMessages_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetMessagesRequest> $request) async {
    return getMessages($call, await $request);
  }

  $async.Future<$0.GetMessagesResponse> getMessages(
      $grpc.ServiceCall call, $0.GetMessagesRequest request);

  $async.Future<$0.GetConversationsResponse> getConversations_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetConversationsRequest> $request) async {
    return getConversations($call, await $request);
  }

  $async.Future<$0.GetConversationsResponse> getConversations(
      $grpc.ServiceCall call, $0.GetConversationsRequest request);

  $async.Future<$0.MarkAsReadResponse> markAsRead_Pre($grpc.ServiceCall $call,
      $async.Future<$0.MarkAsReadRequest> $request) async {
    return markAsRead($call, await $request);
  }

  $async.Future<$0.MarkAsReadResponse> markAsRead(
      $grpc.ServiceCall call, $0.MarkAsReadRequest request);

  $async.Future<$0.DeleteMessageResponse> deleteMessage_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteMessageRequest> $request) async {
    return deleteMessage($call, await $request);
  }

  $async.Future<$0.DeleteMessageResponse> deleteMessage(
      $grpc.ServiceCall call, $0.DeleteMessageRequest request);

  $async.Future<$0.TypingIndicatorResponse> sendTypingIndicator_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.TypingIndicatorRequest> $request) async {
    return sendTypingIndicator($call, await $request);
  }

  $async.Future<$0.TypingIndicatorResponse> sendTypingIndicator(
      $grpc.ServiceCall call, $0.TypingIndicatorRequest request);

  $async.Future<$0.CreateGroupResponse> createGroup_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateGroupRequest> $request) async {
    return createGroup($call, await $request);
  }

  $async.Future<$0.CreateGroupResponse> createGroup(
      $grpc.ServiceCall call, $0.CreateGroupRequest request);

  $async.Future<$0.AddGroupMemberResponse> addGroupMember_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AddGroupMemberRequest> $request) async {
    return addGroupMember($call, await $request);
  }

  $async.Future<$0.AddGroupMemberResponse> addGroupMember(
      $grpc.ServiceCall call, $0.AddGroupMemberRequest request);

  $async.Future<$0.RemoveGroupMemberResponse> removeGroupMember_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RemoveGroupMemberRequest> $request) async {
    return removeGroupMember($call, await $request);
  }

  $async.Future<$0.RemoveGroupMemberResponse> removeGroupMember(
      $grpc.ServiceCall call, $0.RemoveGroupMemberRequest request);

  $async.Future<$0.ChangeMemberRoleResponse> changeMemberRole_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ChangeMemberRoleRequest> $request) async {
    return changeMemberRole($call, await $request);
  }

  $async.Future<$0.ChangeMemberRoleResponse> changeMemberRole(
      $grpc.ServiceCall call, $0.ChangeMemberRoleRequest request);

  $async.Future<$0.SendGroupMessageResponse> sendGroupMessage_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SendGroupMessageRequest> $request) async {
    return sendGroupMessage($call, await $request);
  }

  $async.Future<$0.SendGroupMessageResponse> sendGroupMessage(
      $grpc.ServiceCall call, $0.SendGroupMessageRequest request);

  $async.Future<$0.GetGroupMessagesResponse> getGroupMessages_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetGroupMessagesRequest> $request) async {
    return getGroupMessages($call, await $request);
  }

  $async.Future<$0.GetGroupMessagesResponse> getGroupMessages(
      $grpc.ServiceCall call, $0.GetGroupMessagesRequest request);

  $async.Future<$0.GetGroupsResponse> getGroups_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetGroupsRequest> $request) async {
    return getGroups($call, await $request);
  }

  $async.Future<$0.GetGroupsResponse> getGroups(
      $grpc.ServiceCall call, $0.GetGroupsRequest request);

  $async.Future<$0.GetGroupByIdResponse> getGroupById_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetGroupByIdRequest> $request) async {
    return getGroupById($call, await $request);
  }

  $async.Future<$0.GetGroupByIdResponse> getGroupById(
      $grpc.ServiceCall call, $0.GetGroupByIdRequest request);

  $async.Future<$0.UpdateGroupResponse> updateGroup_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateGroupRequest> $request) async {
    return updateGroup($call, await $request);
  }

  $async.Future<$0.UpdateGroupResponse> updateGroup(
      $grpc.ServiceCall call, $0.UpdateGroupRequest request);

  $async.Future<$0.LeaveGroupResponse> leaveGroup_Pre($grpc.ServiceCall $call,
      $async.Future<$0.LeaveGroupRequest> $request) async {
    return leaveGroup($call, await $request);
  }

  $async.Future<$0.LeaveGroupResponse> leaveGroup(
      $grpc.ServiceCall call, $0.LeaveGroupRequest request);

  $async.Future<$0.DeleteGroupResponse> deleteGroup_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteGroupRequest> $request) async {
    return deleteGroup($call, await $request);
  }

  $async.Future<$0.DeleteGroupResponse> deleteGroup(
      $grpc.ServiceCall call, $0.DeleteGroupRequest request);

  $async.Future<$0.ClearChatResponse> clearChat_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ClearChatRequest> $request) async {
    return clearChat($call, await $request);
  }

  $async.Future<$0.ClearChatResponse> clearChat(
      $grpc.ServiceCall call, $0.ClearChatRequest request);

  $async.Future<$0.AddReactionResponse> addReaction_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AddReactionRequest> $request) async {
    return addReaction($call, await $request);
  }

  $async.Future<$0.AddReactionResponse> addReaction(
      $grpc.ServiceCall call, $0.AddReactionRequest request);

  $async.Future<$0.RemoveReactionResponse> removeReaction_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RemoveReactionRequest> $request) async {
    return removeReaction($call, await $request);
  }

  $async.Future<$0.RemoveReactionResponse> removeReaction(
      $grpc.ServiceCall call, $0.RemoveReactionRequest request);

  $async.Future<$0.GetReactionsResponse> getReactions_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetReactionsRequest> $request) async {
    return getReactions($call, await $request);
  }

  $async.Future<$0.GetReactionsResponse> getReactions(
      $grpc.ServiceCall call, $0.GetReactionsRequest request);

  $async.Future<$0.SendReadReceiptResponse> sendReadReceipt_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SendReadReceiptRequest> $request) async {
    return sendReadReceipt($call, await $request);
  }

  $async.Future<$0.SendReadReceiptResponse> sendReadReceipt(
      $grpc.ServiceCall call, $0.SendReadReceiptRequest request);

  $async.Future<$0.GetReadReceiptsResponse> getReadReceipts_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetReadReceiptsRequest> $request) async {
    return getReadReceipts($call, await $request);
  }

  $async.Future<$0.GetReadReceiptsResponse> getReadReceipts(
      $grpc.ServiceCall call, $0.GetReadReceiptsRequest request);

  $async.Future<$0.ForwardMessageResponse> forwardMessage_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ForwardMessageRequest> $request) async {
    return forwardMessage($call, await $request);
  }

  $async.Future<$0.ForwardMessageResponse> forwardMessage(
      $grpc.ServiceCall call, $0.ForwardMessageRequest request);

  $async.Future<$0.EditMessageResponse> editMessage_Pre($grpc.ServiceCall $call,
      $async.Future<$0.EditMessageRequest> $request) async {
    return editMessage($call, await $request);
  }

  $async.Future<$0.EditMessageResponse> editMessage(
      $grpc.ServiceCall call, $0.EditMessageRequest request);

  $async.Future<$0.SearchMessagesResponse> searchMessages_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SearchMessagesRequest> $request) async {
    return searchMessages($call, await $request);
  }

  $async.Future<$0.SearchMessagesResponse> searchMessages(
      $grpc.ServiceCall call, $0.SearchMessagesRequest request);

  $async.Future<$0.SetDisappearingMessagesResponse> setDisappearingMessages_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SetDisappearingMessagesRequest> $request) async {
    return setDisappearingMessages($call, await $request);
  }

  $async.Future<$0.SetDisappearingMessagesResponse> setDisappearingMessages(
      $grpc.ServiceCall call, $0.SetDisappearingMessagesRequest request);

  $async.Future<$0.GetDisappearingConfigResponse> getDisappearingConfig_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetDisappearingConfigRequest> $request) async {
    return getDisappearingConfig($call, await $request);
  }

  $async.Future<$0.GetDisappearingConfigResponse> getDisappearingConfig(
      $grpc.ServiceCall call, $0.GetDisappearingConfigRequest request);

  $async.Future<$0.BlockUserResponse> blockUser_Pre($grpc.ServiceCall $call,
      $async.Future<$0.BlockUserRequest> $request) async {
    return blockUser($call, await $request);
  }

  $async.Future<$0.BlockUserResponse> blockUser(
      $grpc.ServiceCall call, $0.BlockUserRequest request);

  $async.Future<$0.UnblockUserResponse> unblockUser_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UnblockUserRequest> $request) async {
    return unblockUser($call, await $request);
  }

  $async.Future<$0.UnblockUserResponse> unblockUser(
      $grpc.ServiceCall call, $0.UnblockUserRequest request);

  $async.Future<$0.GetBlockedUsersResponse> getBlockedUsers_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetBlockedUsersRequest> $request) async {
    return getBlockedUsers($call, await $request);
  }

  $async.Future<$0.GetBlockedUsersResponse> getBlockedUsers(
      $grpc.ServiceCall call, $0.GetBlockedUsersRequest request);

  $async.Future<$0.DeleteConversationResponse> deleteConversation_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteConversationRequest> $request) async {
    return deleteConversation($call, await $request);
  }

  $async.Future<$0.DeleteConversationResponse> deleteConversation(
      $grpc.ServiceCall call, $0.DeleteConversationRequest request);

  $async.Future<$1.HealthStatus> health_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.HealthRequest> $request) async {
    return health($call, await $request);
  }

  $async.Future<$1.HealthStatus> health(
      $grpc.ServiceCall call, $0.HealthRequest request);
}
