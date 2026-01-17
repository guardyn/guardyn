// This is a generated file - do not edit.
//
// Generated from messaging.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

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

  /// Leave a group
  $grpc.ResponseFuture<$0.LeaveGroupResponse> leaveGroup(
    $0.LeaveGroupRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$leaveGroup, request, options: options);
  }

  /// Clear all messages in a conversation (local delete for current user)
  $grpc.ResponseFuture<$0.ClearChatResponse> clearChat(
    $0.ClearChatRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$clearChat, request, options: options);
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
  static final _$leaveGroup =
      $grpc.ClientMethod<$0.LeaveGroupRequest, $0.LeaveGroupResponse>(
          '/guardyn.messaging.MessagingService/LeaveGroup',
          ($0.LeaveGroupRequest value) => value.writeToBuffer(),
          $0.LeaveGroupResponse.fromBuffer);
  static final _$clearChat =
      $grpc.ClientMethod<$0.ClearChatRequest, $0.ClearChatResponse>(
          '/guardyn.messaging.MessagingService/ClearChat',
          ($0.ClearChatRequest value) => value.writeToBuffer(),
          $0.ClearChatResponse.fromBuffer);
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
    $addMethod($grpc.ServiceMethod<$0.LeaveGroupRequest, $0.LeaveGroupResponse>(
        'LeaveGroup',
        leaveGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LeaveGroupRequest.fromBuffer(value),
        ($0.LeaveGroupResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ClearChatRequest, $0.ClearChatResponse>(
        'ClearChat',
        clearChat_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ClearChatRequest.fromBuffer(value),
        ($0.ClearChatResponse value) => value.writeToBuffer()));
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

  $async.Future<$0.LeaveGroupResponse> leaveGroup_Pre($grpc.ServiceCall $call,
      $async.Future<$0.LeaveGroupRequest> $request) async {
    return leaveGroup($call, await $request);
  }

  $async.Future<$0.LeaveGroupResponse> leaveGroup(
      $grpc.ServiceCall call, $0.LeaveGroupRequest request);

  $async.Future<$0.ClearChatResponse> clearChat_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ClearChatRequest> $request) async {
    return clearChat($call, await $request);
  }

  $async.Future<$0.ClearChatResponse> clearChat(
      $grpc.ServiceCall call, $0.ClearChatRequest request);

  $async.Future<$1.HealthStatus> health_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.HealthRequest> $request) async {
    return health($call, await $request);
  }

  $async.Future<$1.HealthStatus> health(
      $grpc.ServiceCall call, $0.HealthRequest request);
}
