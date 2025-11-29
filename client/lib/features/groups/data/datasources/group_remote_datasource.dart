import 'dart:convert';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/grpc_clients.dart';
import '../../../../generated/common.pb.dart' as proto_common;
import '../../../../generated/messaging.pb.dart' as proto;
import '../../../../generated/messaging.pbgrpc.dart' hide MessageType;
import '../../domain/entities/group.dart';
import '../models/group_model.dart';

/// Remote datasource for group operations via gRPC
@injectable
class GroupRemoteDatasource {
  final GrpcClients _grpcClients;
  final _uuid = const Uuid();

  GroupRemoteDatasource(this._grpcClients);

  MessagingServiceClient get _messagingClient => _grpcClients.messagingClient;

  /// Create a new group via gRPC
  Future<GroupModel> createGroup({
    required String accessToken,
    required String name,
    required List<String> memberUserIds,
  }) async {
    final request = proto.CreateGroupRequest(
      accessToken: accessToken,
      groupName: name,
      memberUserIds: memberUserIds,
    );

    final response = await _messagingClient.createGroup(request);

    if (response.hasError()) {
      throw GrpcError.custom(response.error.code.value, response.error.message);
    }

    // Return minimal group info - details will be fetched via getGroups
    return GroupModel(
      groupId: response.success.groupId,
      name: name,
      creatorUserId: '', // Will be filled by repository
      members: [], // Will be filled when fetching group details
      createdAt: _timestampFromProto(response.success.createdAt),
      memberCount: memberUserIds.length + 1, // +1 for creator
    );
  }

  /// Send a message to a group via gRPC
  Future<GroupMessageModel> sendGroupMessage({
    required String accessToken,
    required String groupId,
    required String textContent,
    required String currentUserId,
    proto.MessageType messageType = proto.MessageType.TEXT,
  }) async {
    final clientMessageId = _uuid.v4();
    final clientTimestamp = DateTime.now();

    final request = proto.SendGroupMessageRequest(
      accessToken: accessToken,
      groupId: groupId,
      encryptedContent: utf8.encode(textContent),
      messageType: messageType,
      clientMessageId: clientMessageId,
      clientTimestamp: _createTimestamp(clientTimestamp),
    );

    final response = await _messagingClient.sendGroupMessage(request);

    if (response.hasError()) {
      throw GrpcError.custom(response.error.code.value, response.error.message);
    }

    return GroupMessageModel(
      messageId: response.success.messageId,
      groupId: groupId,
      senderUserId: currentUserId,
      senderDeviceId: '', // Will be filled by repository
      senderUsername: '', // Will be filled by repository
      messageType: _messageTypeFromProto(messageType),
      textContent: textContent,
      clientTimestamp: clientTimestamp,
      serverTimestamp: _timestampFromProto(response.success.serverTimestamp),
      currentUserId: currentUserId,
    );
  }

  /// Get group messages via gRPC
  Future<List<GroupMessageModel>> getGroupMessages({
    required String accessToken,
    required String groupId,
    String? currentUserId,
    int limit = 50,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final request = proto.GetGroupMessagesRequest(
      accessToken: accessToken,
      groupId: groupId,
      limit: limit,
    );

    if (startTime != null) {
      request.startTime = _createTimestamp(startTime);
    }
    if (endTime != null) {
      request.endTime = _createTimestamp(endTime);
    }

    final response = await _messagingClient.getGroupMessages(request);

    if (response.hasError()) {
      throw GrpcError.custom(response.error.code.value, response.error.message);
    }

    return response.success.messages
        .map((msg) => _groupMessageFromProto(msg, currentUserId: currentUserId))
        .toList();
  }

  /// Add a member to a group via gRPC
  Future<bool> addGroupMember({
    required String accessToken,
    required String groupId,
    required String memberUserId,
    required String memberDeviceId,
  }) async {
    final request = proto.AddGroupMemberRequest(
      accessToken: accessToken,
      groupId: groupId,
      memberUserId: memberUserId,
      memberDeviceId: memberDeviceId,
    );

    final response = await _messagingClient.addGroupMember(request);

    if (response.hasError()) {
      throw GrpcError.custom(response.error.code.value, response.error.message);
    }

    return response.success.added;
  }

  /// Remove a member from a group via gRPC
  Future<bool> removeGroupMember({
    required String accessToken,
    required String groupId,
    required String memberUserId,
  }) async {
    final request = proto.RemoveGroupMemberRequest(
      accessToken: accessToken,
      groupId: groupId,
      memberUserId: memberUserId,
    );

    final response = await _messagingClient.removeGroupMember(request);

    if (response.hasError()) {
      throw GrpcError.custom(response.error.code.value, response.error.message);
    }

    return response.success.removed;
  }

  // Helper methods

  proto_common.Timestamp _createTimestamp(DateTime dt) {
    final millis = dt.millisecondsSinceEpoch;
    return proto_common.Timestamp(
      seconds: Int64(millis ~/ 1000),
      nanos: (millis % 1000) * 1000000,
    );
  }

  DateTime _timestampFromProto(proto_common.Timestamp ts) {
    return DateTime.fromMillisecondsSinceEpoch(
      ts.seconds.toInt() * 1000 + ts.nanos ~/ 1000000,
    );
  }

  GroupMessageType _messageTypeFromProto(proto.MessageType type) {
    switch (type) {
      case proto.MessageType.TEXT:
        return GroupMessageType.text;
      case proto.MessageType.IMAGE:
        return GroupMessageType.image;
      case proto.MessageType.VIDEO:
        return GroupMessageType.video;
      case proto.MessageType.AUDIO:
        return GroupMessageType.audio;
      case proto.MessageType.FILE:
        return GroupMessageType.file;
      default:
        return GroupMessageType.text;
    }
  }

  GroupMessageModel _groupMessageFromProto(
    proto.GroupMessage msg, {
    String? currentUserId,
  }) {
    return GroupMessageModel(
      messageId: msg.messageId,
      groupId: msg.groupId,
      senderUserId: msg.senderUserId,
      senderDeviceId: msg.senderDeviceId,
      senderUsername: msg.senderUserId, // TODO: Fetch username from user cache
      messageType: _messageTypeFromProto(msg.messageType),
      textContent: utf8.decode(msg.encryptedContent, allowMalformed: true),
      clientTimestamp: msg.hasClientTimestamp()
          ? _timestampFromProto(msg.clientTimestamp)
          : DateTime.now(),
      serverTimestamp: msg.hasServerTimestamp()
          ? _timestampFromProto(msg.serverTimestamp)
          : DateTime.now(),
      isDeleted: msg.isDeleted,
      currentUserId: currentUserId,
    );
  }
}
