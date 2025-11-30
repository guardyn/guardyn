// This is a generated file - do not edit.
//
// Generated from messaging.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $1;
import 'messaging.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'messaging.pbenum.dart';

class SendMessageRequest extends $pb.GeneratedMessage {
  factory SendMessageRequest({
    $core.String? accessToken,
    $core.String? recipientUserId,
    $core.String? recipientDeviceId,
    $core.List<$core.int>? encryptedContent,
    MessageType? messageType,
    $core.String? clientMessageId,
    $1.Timestamp? clientTimestamp,
    $core.String? mediaId,
    $core.String? recipientUsername,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (recipientUserId != null) result.recipientUserId = recipientUserId;
    if (recipientDeviceId != null) result.recipientDeviceId = recipientDeviceId;
    if (encryptedContent != null) result.encryptedContent = encryptedContent;
    if (messageType != null) result.messageType = messageType;
    if (clientMessageId != null) result.clientMessageId = clientMessageId;
    if (clientTimestamp != null) result.clientTimestamp = clientTimestamp;
    if (mediaId != null) result.mediaId = mediaId;
    if (recipientUsername != null) result.recipientUsername = recipientUsername;
    return result;
  }

  SendMessageRequest._();

  factory SendMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendMessageRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'recipientUserId')
    ..aOS(3, _omitFieldNames ? '' : 'recipientDeviceId')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'encryptedContent', $pb.PbFieldType.OY)
    ..aE<MessageType>(5, _omitFieldNames ? '' : 'messageType',
        enumValues: MessageType.values)
    ..aOS(6, _omitFieldNames ? '' : 'clientMessageId')
    ..aOM<$1.Timestamp>(7, _omitFieldNames ? '' : 'clientTimestamp',
        subBuilder: $1.Timestamp.create)
    ..aOS(8, _omitFieldNames ? '' : 'mediaId')
    ..aOS(9, _omitFieldNames ? '' : 'recipientUsername')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageRequest copyWith(void Function(SendMessageRequest) updates) =>
      super.copyWith((message) => updates(message as SendMessageRequest))
          as SendMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendMessageRequest create() => SendMessageRequest._();
  @$core.override
  SendMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendMessageRequest>(create);
  static SendMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get recipientUserId => $_getSZ(1);
  @$pb.TagNumber(2)
  set recipientUserId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRecipientUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecipientUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get recipientDeviceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set recipientDeviceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRecipientDeviceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRecipientDeviceId() => $_clearField(3);

  /// Encrypted message content (Double Ratchet encrypted)
  @$pb.TagNumber(4)
  $core.List<$core.int> get encryptedContent => $_getN(3);
  @$pb.TagNumber(4)
  set encryptedContent($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEncryptedContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearEncryptedContent() => $_clearField(4);

  /// Message metadata
  @$pb.TagNumber(5)
  MessageType get messageType => $_getN(4);
  @$pb.TagNumber(5)
  set messageType(MessageType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasMessageType() => $_has(4);
  @$pb.TagNumber(5)
  void clearMessageType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get clientMessageId => $_getSZ(5);
  @$pb.TagNumber(6)
  set clientMessageId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasClientMessageId() => $_has(5);
  @$pb.TagNumber(6)
  void clearClientMessageId() => $_clearField(6);

  @$pb.TagNumber(7)
  $1.Timestamp get clientTimestamp => $_getN(6);
  @$pb.TagNumber(7)
  set clientTimestamp($1.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasClientTimestamp() => $_has(6);
  @$pb.TagNumber(7)
  void clearClientTimestamp() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.Timestamp ensureClientTimestamp() => $_ensure(6);

  /// Optional: media attachment reference
  @$pb.TagNumber(8)
  $core.String get mediaId => $_getSZ(7);
  @$pb.TagNumber(8)
  set mediaId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMediaId() => $_has(7);
  @$pb.TagNumber(8)
  void clearMediaId() => $_clearField(8);

  /// Recipient username for display (used in conversation list)
  @$pb.TagNumber(9)
  $core.String get recipientUsername => $_getSZ(8);
  @$pb.TagNumber(9)
  set recipientUsername($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasRecipientUsername() => $_has(8);
  @$pb.TagNumber(9)
  void clearRecipientUsername() => $_clearField(9);
}

enum SendMessageResponse_Result { success, error, notSet }

class SendMessageResponse extends $pb.GeneratedMessage {
  factory SendMessageResponse({
    SendMessageSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  SendMessageResponse._();

  factory SendMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SendMessageResponse_Result>
      _SendMessageResponse_ResultByTag = {
    1: SendMessageResponse_Result.success,
    2: SendMessageResponse_Result.error,
    0: SendMessageResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendMessageResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<SendMessageSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: SendMessageSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageResponse copyWith(void Function(SendMessageResponse) updates) =>
      super.copyWith((message) => updates(message as SendMessageResponse))
          as SendMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendMessageResponse create() => SendMessageResponse._();
  @$core.override
  SendMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendMessageResponse>(create);
  static SendMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  SendMessageResponse_Result whichResult() =>
      _SendMessageResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SendMessageSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(SendMessageSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  SendMessageSuccess ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($1.ErrorResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ErrorResponse ensureError() => $_ensure(1);
}

class SendMessageSuccess extends $pb.GeneratedMessage {
  factory SendMessageSuccess({
    $core.String? messageId,
    $1.Timestamp? serverTimestamp,
    DeliveryStatus? deliveryStatus,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (serverTimestamp != null) result.serverTimestamp = serverTimestamp;
    if (deliveryStatus != null) result.deliveryStatus = deliveryStatus;
    return result;
  }

  SendMessageSuccess._();

  factory SendMessageSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendMessageSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendMessageSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOM<$1.Timestamp>(2, _omitFieldNames ? '' : 'serverTimestamp',
        subBuilder: $1.Timestamp.create)
    ..aE<DeliveryStatus>(3, _omitFieldNames ? '' : 'deliveryStatus',
        enumValues: DeliveryStatus.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessageSuccess copyWith(void Function(SendMessageSuccess) updates) =>
      super.copyWith((message) => updates(message as SendMessageSuccess))
          as SendMessageSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendMessageSuccess create() => SendMessageSuccess._();
  @$core.override
  SendMessageSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendMessageSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendMessageSuccess>(create);
  static SendMessageSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Timestamp get serverTimestamp => $_getN(1);
  @$pb.TagNumber(2)
  set serverTimestamp($1.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasServerTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearServerTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Timestamp ensureServerTimestamp() => $_ensure(1);

  @$pb.TagNumber(3)
  DeliveryStatus get deliveryStatus => $_getN(2);
  @$pb.TagNumber(3)
  set deliveryStatus(DeliveryStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDeliveryStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeliveryStatus() => $_clearField(3);
}

class ReceiveMessagesRequest extends $pb.GeneratedMessage {
  factory ReceiveMessagesRequest({
    $core.String? accessToken,
    $core.bool? includeHistory,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (includeHistory != null) result.includeHistory = includeHistory;
    return result;
  }

  ReceiveMessagesRequest._();

  factory ReceiveMessagesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReceiveMessagesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReceiveMessagesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOB(2, _omitFieldNames ? '' : 'includeHistory')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReceiveMessagesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReceiveMessagesRequest copyWith(
          void Function(ReceiveMessagesRequest) updates) =>
      super.copyWith((message) => updates(message as ReceiveMessagesRequest))
          as ReceiveMessagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReceiveMessagesRequest create() => ReceiveMessagesRequest._();
  @$core.override
  ReceiveMessagesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReceiveMessagesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReceiveMessagesRequest>(create);
  static ReceiveMessagesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get includeHistory => $_getBF(1);
  @$pb.TagNumber(2)
  set includeHistory($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIncludeHistory() => $_has(1);
  @$pb.TagNumber(2)
  void clearIncludeHistory() => $_clearField(2);
}

class Message extends $pb.GeneratedMessage {
  factory Message({
    $core.String? messageId,
    $core.String? senderUserId,
    $core.String? senderDeviceId,
    $core.String? recipientUserId,
    $core.String? recipientDeviceId,
    $core.List<$core.int>? encryptedContent,
    MessageType? messageType,
    $core.String? clientMessageId,
    $1.Timestamp? clientTimestamp,
    $1.Timestamp? serverTimestamp,
    DeliveryStatus? deliveryStatus,
    $core.String? mediaId,
    $core.bool? isDeleted,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (senderUserId != null) result.senderUserId = senderUserId;
    if (senderDeviceId != null) result.senderDeviceId = senderDeviceId;
    if (recipientUserId != null) result.recipientUserId = recipientUserId;
    if (recipientDeviceId != null) result.recipientDeviceId = recipientDeviceId;
    if (encryptedContent != null) result.encryptedContent = encryptedContent;
    if (messageType != null) result.messageType = messageType;
    if (clientMessageId != null) result.clientMessageId = clientMessageId;
    if (clientTimestamp != null) result.clientTimestamp = clientTimestamp;
    if (serverTimestamp != null) result.serverTimestamp = serverTimestamp;
    if (deliveryStatus != null) result.deliveryStatus = deliveryStatus;
    if (mediaId != null) result.mediaId = mediaId;
    if (isDeleted != null) result.isDeleted = isDeleted;
    return result;
  }

  Message._();

  factory Message.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Message.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Message',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'senderUserId')
    ..aOS(3, _omitFieldNames ? '' : 'senderDeviceId')
    ..aOS(4, _omitFieldNames ? '' : 'recipientUserId')
    ..aOS(5, _omitFieldNames ? '' : 'recipientDeviceId')
    ..a<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'encryptedContent', $pb.PbFieldType.OY)
    ..aE<MessageType>(7, _omitFieldNames ? '' : 'messageType',
        enumValues: MessageType.values)
    ..aOS(8, _omitFieldNames ? '' : 'clientMessageId')
    ..aOM<$1.Timestamp>(9, _omitFieldNames ? '' : 'clientTimestamp',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(10, _omitFieldNames ? '' : 'serverTimestamp',
        subBuilder: $1.Timestamp.create)
    ..aE<DeliveryStatus>(11, _omitFieldNames ? '' : 'deliveryStatus',
        enumValues: DeliveryStatus.values)
    ..aOS(12, _omitFieldNames ? '' : 'mediaId')
    ..aOB(13, _omitFieldNames ? '' : 'isDeleted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Message clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Message copyWith(void Function(Message) updates) =>
      super.copyWith((message) => updates(message as Message)) as Message;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Message create() => Message._();
  @$core.override
  Message createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Message getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Message>(create);
  static Message? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get senderUserId => $_getSZ(1);
  @$pb.TagNumber(2)
  set senderUserId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSenderUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSenderUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get senderDeviceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set senderDeviceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSenderDeviceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSenderDeviceId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get recipientUserId => $_getSZ(3);
  @$pb.TagNumber(4)
  set recipientUserId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRecipientUserId() => $_has(3);
  @$pb.TagNumber(4)
  void clearRecipientUserId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get recipientDeviceId => $_getSZ(4);
  @$pb.TagNumber(5)
  set recipientDeviceId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRecipientDeviceId() => $_has(4);
  @$pb.TagNumber(5)
  void clearRecipientDeviceId() => $_clearField(5);

  /// Encrypted content
  @$pb.TagNumber(6)
  $core.List<$core.int> get encryptedContent => $_getN(5);
  @$pb.TagNumber(6)
  set encryptedContent($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEncryptedContent() => $_has(5);
  @$pb.TagNumber(6)
  void clearEncryptedContent() => $_clearField(6);

  /// Metadata
  @$pb.TagNumber(7)
  MessageType get messageType => $_getN(6);
  @$pb.TagNumber(7)
  set messageType(MessageType value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasMessageType() => $_has(6);
  @$pb.TagNumber(7)
  void clearMessageType() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get clientMessageId => $_getSZ(7);
  @$pb.TagNumber(8)
  set clientMessageId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasClientMessageId() => $_has(7);
  @$pb.TagNumber(8)
  void clearClientMessageId() => $_clearField(8);

  @$pb.TagNumber(9)
  $1.Timestamp get clientTimestamp => $_getN(8);
  @$pb.TagNumber(9)
  set clientTimestamp($1.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasClientTimestamp() => $_has(8);
  @$pb.TagNumber(9)
  void clearClientTimestamp() => $_clearField(9);
  @$pb.TagNumber(9)
  $1.Timestamp ensureClientTimestamp() => $_ensure(8);

  @$pb.TagNumber(10)
  $1.Timestamp get serverTimestamp => $_getN(9);
  @$pb.TagNumber(10)
  set serverTimestamp($1.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasServerTimestamp() => $_has(9);
  @$pb.TagNumber(10)
  void clearServerTimestamp() => $_clearField(10);
  @$pb.TagNumber(10)
  $1.Timestamp ensureServerTimestamp() => $_ensure(9);

  /// Delivery tracking
  @$pb.TagNumber(11)
  DeliveryStatus get deliveryStatus => $_getN(10);
  @$pb.TagNumber(11)
  set deliveryStatus(DeliveryStatus value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasDeliveryStatus() => $_has(10);
  @$pb.TagNumber(11)
  void clearDeliveryStatus() => $_clearField(11);

  /// Media reference
  @$pb.TagNumber(12)
  $core.String get mediaId => $_getSZ(11);
  @$pb.TagNumber(12)
  set mediaId($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasMediaId() => $_has(11);
  @$pb.TagNumber(12)
  void clearMediaId() => $_clearField(12);

  /// Deletion flag
  @$pb.TagNumber(13)
  $core.bool get isDeleted => $_getBF(12);
  @$pb.TagNumber(13)
  set isDeleted($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasIsDeleted() => $_has(12);
  @$pb.TagNumber(13)
  void clearIsDeleted() => $_clearField(13);
}

class GetMessagesRequest extends $pb.GeneratedMessage {
  factory GetMessagesRequest({
    $core.String? accessToken,
    $core.String? conversationUserId,
    $1.PaginationRequest? pagination,
    $1.Timestamp? startTime,
    $1.Timestamp? endTime,
    $core.String? conversationId,
    $core.int? limit,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (conversationUserId != null)
      result.conversationUserId = conversationUserId;
    if (pagination != null) result.pagination = pagination;
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    if (conversationId != null) result.conversationId = conversationId;
    if (limit != null) result.limit = limit;
    return result;
  }

  GetMessagesRequest._();

  factory GetMessagesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMessagesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMessagesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'conversationUserId')
    ..aOM<$1.PaginationRequest>(3, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.PaginationRequest.create)
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'startTime',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(5, _omitFieldNames ? '' : 'endTime',
        subBuilder: $1.Timestamp.create)
    ..aOS(6, _omitFieldNames ? '' : 'conversationId')
    ..aI(7, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessagesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessagesRequest copyWith(void Function(GetMessagesRequest) updates) =>
      super.copyWith((message) => updates(message as GetMessagesRequest))
          as GetMessagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMessagesRequest create() => GetMessagesRequest._();
  @$core.override
  GetMessagesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMessagesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMessagesRequest>(create);
  static GetMessagesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationUserId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationUserId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationUserId() => $_clearField(2);

  /// Pagination
  @$pb.TagNumber(3)
  $1.PaginationRequest get pagination => $_getN(2);
  @$pb.TagNumber(3)
  set pagination($1.PaginationRequest value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPagination() => $_has(2);
  @$pb.TagNumber(3)
  void clearPagination() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.PaginationRequest ensurePagination() => $_ensure(2);

  /// Time range filtering
  @$pb.TagNumber(4)
  $1.Timestamp get startTime => $_getN(3);
  @$pb.TagNumber(4)
  set startTime($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStartTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearStartTime() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureStartTime() => $_ensure(3);

  @$pb.TagNumber(5)
  $1.Timestamp get endTime => $_getN(4);
  @$pb.TagNumber(5)
  set endTime($1.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasEndTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearEndTime() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.Timestamp ensureEndTime() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get conversationId => $_getSZ(5);
  @$pb.TagNumber(6)
  set conversationId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasConversationId() => $_has(5);
  @$pb.TagNumber(6)
  void clearConversationId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get limit => $_getIZ(6);
  @$pb.TagNumber(7)
  set limit($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLimit() => $_has(6);
  @$pb.TagNumber(7)
  void clearLimit() => $_clearField(7);
}

enum GetMessagesResponse_Result { success, error, notSet }

class GetMessagesResponse extends $pb.GeneratedMessage {
  factory GetMessagesResponse({
    GetMessagesSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetMessagesResponse._();

  factory GetMessagesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMessagesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetMessagesResponse_Result>
      _GetMessagesResponse_ResultByTag = {
    1: GetMessagesResponse_Result.success,
    2: GetMessagesResponse_Result.error,
    0: GetMessagesResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMessagesResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetMessagesSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: GetMessagesSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessagesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessagesResponse copyWith(void Function(GetMessagesResponse) updates) =>
      super.copyWith((message) => updates(message as GetMessagesResponse))
          as GetMessagesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMessagesResponse create() => GetMessagesResponse._();
  @$core.override
  GetMessagesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMessagesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMessagesResponse>(create);
  static GetMessagesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetMessagesResponse_Result whichResult() =>
      _GetMessagesResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetMessagesSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(GetMessagesSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  GetMessagesSuccess ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($1.ErrorResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ErrorResponse ensureError() => $_ensure(1);
}

class GetMessagesSuccess extends $pb.GeneratedMessage {
  factory GetMessagesSuccess({
    $core.Iterable<Message>? messages,
    $1.PaginationResponse? pagination,
    $core.bool? hasMore,
  }) {
    final result = create();
    if (messages != null) result.messages.addAll(messages);
    if (pagination != null) result.pagination = pagination;
    if (hasMore != null) result.hasMore = hasMore;
    return result;
  }

  GetMessagesSuccess._();

  factory GetMessagesSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMessagesSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMessagesSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..pPM<Message>(1, _omitFieldNames ? '' : 'messages',
        subBuilder: Message.create)
    ..aOM<$1.PaginationResponse>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.PaginationResponse.create)
    ..aOB(3, _omitFieldNames ? '' : 'hasMore')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessagesSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMessagesSuccess copyWith(void Function(GetMessagesSuccess) updates) =>
      super.copyWith((message) => updates(message as GetMessagesSuccess))
          as GetMessagesSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMessagesSuccess create() => GetMessagesSuccess._();
  @$core.override
  GetMessagesSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMessagesSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMessagesSuccess>(create);
  static GetMessagesSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Message> get messages => $_getList(0);

  @$pb.TagNumber(2)
  $1.PaginationResponse get pagination => $_getN(1);
  @$pb.TagNumber(2)
  set pagination($1.PaginationResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPagination() => $_has(1);
  @$pb.TagNumber(2)
  void clearPagination() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.PaginationResponse ensurePagination() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.bool get hasMore => $_getBF(2);
  @$pb.TagNumber(3)
  set hasMore($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHasMore() => $_has(2);
  @$pb.TagNumber(3)
  void clearHasMore() => $_clearField(3);
}

class GetConversationsRequest extends $pb.GeneratedMessage {
  factory GetConversationsRequest({
    $core.String? accessToken,
    $core.int? limit,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (limit != null) result.limit = limit;
    return result;
  }

  GetConversationsRequest._();

  factory GetConversationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetConversationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetConversationsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aI(2, _omitFieldNames ? '' : 'limit', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConversationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConversationsRequest copyWith(
          void Function(GetConversationsRequest) updates) =>
      super.copyWith((message) => updates(message as GetConversationsRequest))
          as GetConversationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetConversationsRequest create() => GetConversationsRequest._();
  @$core.override
  GetConversationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetConversationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetConversationsRequest>(create);
  static GetConversationsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);
}

enum GetConversationsResponse_Result { success, error, notSet }

class GetConversationsResponse extends $pb.GeneratedMessage {
  factory GetConversationsResponse({
    GetConversationsSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetConversationsResponse._();

  factory GetConversationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetConversationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetConversationsResponse_Result>
      _GetConversationsResponse_ResultByTag = {
    1: GetConversationsResponse_Result.success,
    2: GetConversationsResponse_Result.error,
    0: GetConversationsResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetConversationsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetConversationsSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: GetConversationsSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConversationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConversationsResponse copyWith(
          void Function(GetConversationsResponse) updates) =>
      super.copyWith((message) => updates(message as GetConversationsResponse))
          as GetConversationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetConversationsResponse create() => GetConversationsResponse._();
  @$core.override
  GetConversationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetConversationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetConversationsResponse>(create);
  static GetConversationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetConversationsResponse_Result whichResult() =>
      _GetConversationsResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetConversationsSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(GetConversationsSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  GetConversationsSuccess ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($1.ErrorResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ErrorResponse ensureError() => $_ensure(1);
}

class GetConversationsSuccess extends $pb.GeneratedMessage {
  factory GetConversationsSuccess({
    $core.Iterable<Conversation>? conversations,
  }) {
    final result = create();
    if (conversations != null) result.conversations.addAll(conversations);
    return result;
  }

  GetConversationsSuccess._();

  factory GetConversationsSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetConversationsSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetConversationsSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..pPM<Conversation>(1, _omitFieldNames ? '' : 'conversations',
        subBuilder: Conversation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConversationsSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConversationsSuccess copyWith(
          void Function(GetConversationsSuccess) updates) =>
      super.copyWith((message) => updates(message as GetConversationsSuccess))
          as GetConversationsSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetConversationsSuccess create() => GetConversationsSuccess._();
  @$core.override
  GetConversationsSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetConversationsSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetConversationsSuccess>(create);
  static GetConversationsSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Conversation> get conversations => $_getList(0);
}

class Conversation extends $pb.GeneratedMessage {
  factory Conversation({
    $core.String? conversationId,
    $core.String? userId,
    $core.String? username,
    Message? lastMessage,
    $core.int? unreadCount,
    $1.Timestamp? updatedAt,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (userId != null) result.userId = userId;
    if (username != null) result.username = username;
    if (lastMessage != null) result.lastMessage = lastMessage;
    if (unreadCount != null) result.unreadCount = unreadCount;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  Conversation._();

  factory Conversation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Conversation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Conversation',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'username')
    ..aOM<Message>(4, _omitFieldNames ? '' : 'lastMessage',
        subBuilder: Message.create)
    ..aI(5, _omitFieldNames ? '' : 'unreadCount',
        fieldType: $pb.PbFieldType.OU3)
    ..aOM<$1.Timestamp>(6, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Conversation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Conversation copyWith(void Function(Conversation) updates) =>
      super.copyWith((message) => updates(message as Conversation))
          as Conversation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Conversation create() => Conversation._();
  @$core.override
  Conversation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Conversation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Conversation>(create);
  static Conversation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get username => $_getSZ(2);
  @$pb.TagNumber(3)
  set username($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUsername() => $_has(2);
  @$pb.TagNumber(3)
  void clearUsername() => $_clearField(3);

  @$pb.TagNumber(4)
  Message get lastMessage => $_getN(3);
  @$pb.TagNumber(4)
  set lastMessage(Message value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLastMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearLastMessage() => $_clearField(4);
  @$pb.TagNumber(4)
  Message ensureLastMessage() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.int get unreadCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set unreadCount($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUnreadCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearUnreadCount() => $_clearField(5);

  @$pb.TagNumber(6)
  $1.Timestamp get updatedAt => $_getN(5);
  @$pb.TagNumber(6)
  set updatedAt($1.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasUpdatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearUpdatedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $1.Timestamp ensureUpdatedAt() => $_ensure(5);
}

class MarkAsReadRequest extends $pb.GeneratedMessage {
  factory MarkAsReadRequest({
    $core.String? accessToken,
    $core.Iterable<$core.String>? messageIds,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (messageIds != null) result.messageIds.addAll(messageIds);
    return result;
  }

  MarkAsReadRequest._();

  factory MarkAsReadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarkAsReadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkAsReadRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..pPS(2, _omitFieldNames ? '' : 'messageIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAsReadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAsReadRequest copyWith(void Function(MarkAsReadRequest) updates) =>
      super.copyWith((message) => updates(message as MarkAsReadRequest))
          as MarkAsReadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarkAsReadRequest create() => MarkAsReadRequest._();
  @$core.override
  MarkAsReadRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarkAsReadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarkAsReadRequest>(create);
  static MarkAsReadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get messageIds => $_getList(1);
}

enum MarkAsReadResponse_Result { success, error, notSet }

class MarkAsReadResponse extends $pb.GeneratedMessage {
  factory MarkAsReadResponse({
    MarkAsReadSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  MarkAsReadResponse._();

  factory MarkAsReadResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarkAsReadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, MarkAsReadResponse_Result>
      _MarkAsReadResponse_ResultByTag = {
    1: MarkAsReadResponse_Result.success,
    2: MarkAsReadResponse_Result.error,
    0: MarkAsReadResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkAsReadResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<MarkAsReadSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: MarkAsReadSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAsReadResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAsReadResponse copyWith(void Function(MarkAsReadResponse) updates) =>
      super.copyWith((message) => updates(message as MarkAsReadResponse))
          as MarkAsReadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarkAsReadResponse create() => MarkAsReadResponse._();
  @$core.override
  MarkAsReadResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarkAsReadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarkAsReadResponse>(create);
  static MarkAsReadResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  MarkAsReadResponse_Result whichResult() =>
      _MarkAsReadResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  MarkAsReadSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(MarkAsReadSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  MarkAsReadSuccess ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($1.ErrorResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ErrorResponse ensureError() => $_ensure(1);
}

class MarkAsReadSuccess extends $pb.GeneratedMessage {
  factory MarkAsReadSuccess({
    $core.int? messagesMarked,
    $core.int? markedCount,
    $1.Timestamp? timestamp,
  }) {
    final result = create();
    if (messagesMarked != null) result.messagesMarked = messagesMarked;
    if (markedCount != null) result.markedCount = markedCount;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  MarkAsReadSuccess._();

  factory MarkAsReadSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarkAsReadSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkAsReadSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'messagesMarked',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'markedCount')
    ..aOM<$1.Timestamp>(3, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAsReadSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAsReadSuccess copyWith(void Function(MarkAsReadSuccess) updates) =>
      super.copyWith((message) => updates(message as MarkAsReadSuccess))
          as MarkAsReadSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarkAsReadSuccess create() => MarkAsReadSuccess._();
  @$core.override
  MarkAsReadSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarkAsReadSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarkAsReadSuccess>(create);
  static MarkAsReadSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get messagesMarked => $_getIZ(0);
  @$pb.TagNumber(1)
  set messagesMarked($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessagesMarked() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessagesMarked() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get markedCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set markedCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMarkedCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearMarkedCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.Timestamp get timestamp => $_getN(2);
  @$pb.TagNumber(3)
  set timestamp($1.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Timestamp ensureTimestamp() => $_ensure(2);
}

class DeleteMessageRequest extends $pb.GeneratedMessage {
  factory DeleteMessageRequest({
    $core.String? accessToken,
    $core.String? messageId,
    $core.bool? deleteForEveryone,
    $core.String? conversationId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (messageId != null) result.messageId = messageId;
    if (deleteForEveryone != null) result.deleteForEveryone = deleteForEveryone;
    if (conversationId != null) result.conversationId = conversationId;
    return result;
  }

  DeleteMessageRequest._();

  factory DeleteMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteMessageRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'messageId')
    ..aOB(3, _omitFieldNames ? '' : 'deleteForEveryone')
    ..aOS(4, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteMessageRequest copyWith(void Function(DeleteMessageRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteMessageRequest))
          as DeleteMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteMessageRequest create() => DeleteMessageRequest._();
  @$core.override
  DeleteMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteMessageRequest>(create);
  static DeleteMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get messageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set messageId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get deleteForEveryone => $_getBF(2);
  @$pb.TagNumber(3)
  set deleteForEveryone($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeleteForEveryone() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeleteForEveryone() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get conversationId => $_getSZ(3);
  @$pb.TagNumber(4)
  set conversationId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConversationId() => $_has(3);
  @$pb.TagNumber(4)
  void clearConversationId() => $_clearField(4);
}

enum DeleteMessageResponse_Result { success, error, notSet }

class DeleteMessageResponse extends $pb.GeneratedMessage {
  factory DeleteMessageResponse({
    DeleteMessageSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  DeleteMessageResponse._();

  factory DeleteMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, DeleteMessageResponse_Result>
      _DeleteMessageResponse_ResultByTag = {
    1: DeleteMessageResponse_Result.success,
    2: DeleteMessageResponse_Result.error,
    0: DeleteMessageResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteMessageResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<DeleteMessageSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: DeleteMessageSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteMessageResponse copyWith(
          void Function(DeleteMessageResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteMessageResponse))
          as DeleteMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteMessageResponse create() => DeleteMessageResponse._();
  @$core.override
  DeleteMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteMessageResponse>(create);
  static DeleteMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  DeleteMessageResponse_Result whichResult() =>
      _DeleteMessageResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  DeleteMessageSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(DeleteMessageSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  DeleteMessageSuccess ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($1.ErrorResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ErrorResponse ensureError() => $_ensure(1);
}

class DeleteMessageSuccess extends $pb.GeneratedMessage {
  factory DeleteMessageSuccess({
    $core.bool? deleted,
    $core.String? messageId,
    $1.Timestamp? timestamp,
  }) {
    final result = create();
    if (deleted != null) result.deleted = deleted;
    if (messageId != null) result.messageId = messageId;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  DeleteMessageSuccess._();

  factory DeleteMessageSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteMessageSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteMessageSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'deleted')
    ..aOS(2, _omitFieldNames ? '' : 'messageId')
    ..aOM<$1.Timestamp>(3, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteMessageSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteMessageSuccess copyWith(void Function(DeleteMessageSuccess) updates) =>
      super.copyWith((message) => updates(message as DeleteMessageSuccess))
          as DeleteMessageSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteMessageSuccess create() => DeleteMessageSuccess._();
  @$core.override
  DeleteMessageSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteMessageSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteMessageSuccess>(create);
  static DeleteMessageSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get deleted => $_getBF(0);
  @$pb.TagNumber(1)
  set deleted($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeleted() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeleted() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get messageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set messageId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageId() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.Timestamp get timestamp => $_getN(2);
  @$pb.TagNumber(3)
  set timestamp($1.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Timestamp ensureTimestamp() => $_ensure(2);
}

class TypingIndicatorRequest extends $pb.GeneratedMessage {
  factory TypingIndicatorRequest({
    $core.String? accessToken,
    $core.String? recipientUserId,
    $core.bool? isTyping,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (recipientUserId != null) result.recipientUserId = recipientUserId;
    if (isTyping != null) result.isTyping = isTyping;
    return result;
  }

  TypingIndicatorRequest._();

  factory TypingIndicatorRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TypingIndicatorRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TypingIndicatorRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'recipientUserId')
    ..aOB(3, _omitFieldNames ? '' : 'isTyping')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingIndicatorRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingIndicatorRequest copyWith(
          void Function(TypingIndicatorRequest) updates) =>
      super.copyWith((message) => updates(message as TypingIndicatorRequest))
          as TypingIndicatorRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TypingIndicatorRequest create() => TypingIndicatorRequest._();
  @$core.override
  TypingIndicatorRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TypingIndicatorRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TypingIndicatorRequest>(create);
  static TypingIndicatorRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get recipientUserId => $_getSZ(1);
  @$pb.TagNumber(2)
  set recipientUserId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRecipientUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecipientUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isTyping => $_getBF(2);
  @$pb.TagNumber(3)
  set isTyping($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsTyping() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsTyping() => $_clearField(3);
}

enum TypingIndicatorResponse_Result { success, error, notSet }

class TypingIndicatorResponse extends $pb.GeneratedMessage {
  factory TypingIndicatorResponse({
    TypingIndicatorSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  TypingIndicatorResponse._();

  factory TypingIndicatorResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TypingIndicatorResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, TypingIndicatorResponse_Result>
      _TypingIndicatorResponse_ResultByTag = {
    1: TypingIndicatorResponse_Result.success,
    2: TypingIndicatorResponse_Result.error,
    0: TypingIndicatorResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TypingIndicatorResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<TypingIndicatorSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: TypingIndicatorSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingIndicatorResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingIndicatorResponse copyWith(
          void Function(TypingIndicatorResponse) updates) =>
      super.copyWith((message) => updates(message as TypingIndicatorResponse))
          as TypingIndicatorResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TypingIndicatorResponse create() => TypingIndicatorResponse._();
  @$core.override
  TypingIndicatorResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TypingIndicatorResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TypingIndicatorResponse>(create);
  static TypingIndicatorResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  TypingIndicatorResponse_Result whichResult() =>
      _TypingIndicatorResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  TypingIndicatorSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(TypingIndicatorSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  TypingIndicatorSuccess ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($1.ErrorResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ErrorResponse ensureError() => $_ensure(1);
}

class TypingIndicatorSuccess extends $pb.GeneratedMessage {
  factory TypingIndicatorSuccess({
    $core.bool? sent,
  }) {
    final result = create();
    if (sent != null) result.sent = sent;
    return result;
  }

  TypingIndicatorSuccess._();

  factory TypingIndicatorSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TypingIndicatorSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TypingIndicatorSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'sent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingIndicatorSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TypingIndicatorSuccess copyWith(
          void Function(TypingIndicatorSuccess) updates) =>
      super.copyWith((message) => updates(message as TypingIndicatorSuccess))
          as TypingIndicatorSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TypingIndicatorSuccess create() => TypingIndicatorSuccess._();
  @$core.override
  TypingIndicatorSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TypingIndicatorSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TypingIndicatorSuccess>(create);
  static TypingIndicatorSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get sent => $_getBF(0);
  @$pb.TagNumber(1)
  set sent($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSent() => $_has(0);
  @$pb.TagNumber(1)
  void clearSent() => $_clearField(1);
}

class CreateGroupRequest extends $pb.GeneratedMessage {
  factory CreateGroupRequest({
    $core.String? accessToken,
    $core.String? groupName,
    $core.Iterable<$core.String>? memberUserIds,
    $core.List<$core.int>? mlsGroupState,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (groupName != null) result.groupName = groupName;
    if (memberUserIds != null) result.memberUserIds.addAll(memberUserIds);
    if (mlsGroupState != null) result.mlsGroupState = mlsGroupState;
    return result;
  }

  CreateGroupRequest._();

  factory CreateGroupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateGroupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateGroupRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'groupName')
    ..pPS(3, _omitFieldNames ? '' : 'memberUserIds')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'mlsGroupState', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateGroupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateGroupRequest copyWith(void Function(CreateGroupRequest) updates) =>
      super.copyWith((message) => updates(message as CreateGroupRequest))
          as CreateGroupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateGroupRequest create() => CreateGroupRequest._();
  @$core.override
  CreateGroupRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateGroupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateGroupRequest>(create);
  static CreateGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupName => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupName() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupName() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get memberUserIds => $_getList(2);

  /// MLS group state (encrypted with OpenMLS)
  @$pb.TagNumber(4)
  $core.List<$core.int> get mlsGroupState => $_getN(3);
  @$pb.TagNumber(4)
  set mlsGroupState($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMlsGroupState() => $_has(3);
  @$pb.TagNumber(4)
  void clearMlsGroupState() => $_clearField(4);
}

enum CreateGroupResponse_Result { success, error, notSet }

class CreateGroupResponse extends $pb.GeneratedMessage {
  factory CreateGroupResponse({
    CreateGroupSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  CreateGroupResponse._();

  factory CreateGroupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateGroupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, CreateGroupResponse_Result>
      _CreateGroupResponse_ResultByTag = {
    1: CreateGroupResponse_Result.success,
    2: CreateGroupResponse_Result.error,
    0: CreateGroupResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateGroupResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<CreateGroupSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: CreateGroupSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateGroupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateGroupResponse copyWith(void Function(CreateGroupResponse) updates) =>
      super.copyWith((message) => updates(message as CreateGroupResponse))
          as CreateGroupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateGroupResponse create() => CreateGroupResponse._();
  @$core.override
  CreateGroupResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateGroupResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateGroupResponse>(create);
  static CreateGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  CreateGroupResponse_Result whichResult() =>
      _CreateGroupResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  CreateGroupSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(CreateGroupSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  CreateGroupSuccess ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($1.ErrorResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ErrorResponse ensureError() => $_ensure(1);
}

class CreateGroupSuccess extends $pb.GeneratedMessage {
  factory CreateGroupSuccess({
    $core.String? groupId,
    $1.Timestamp? createdAt,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  CreateGroupSuccess._();

  factory CreateGroupSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateGroupSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateGroupSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupId')
    ..aOM<$1.Timestamp>(2, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateGroupSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateGroupSuccess copyWith(void Function(CreateGroupSuccess) updates) =>
      super.copyWith((message) => updates(message as CreateGroupSuccess))
          as CreateGroupSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateGroupSuccess create() => CreateGroupSuccess._();
  @$core.override
  CreateGroupSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateGroupSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateGroupSuccess>(create);
  static CreateGroupSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Timestamp get createdAt => $_getN(1);
  @$pb.TagNumber(2)
  set createdAt($1.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCreatedAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearCreatedAt() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Timestamp ensureCreatedAt() => $_ensure(1);
}

class AddGroupMemberRequest extends $pb.GeneratedMessage {
  factory AddGroupMemberRequest({
    $core.String? accessToken,
    $core.String? groupId,
    $core.String? memberUserId,
    $core.String? memberDeviceId,
    $core.List<$core.int>? mlsGroupState,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (groupId != null) result.groupId = groupId;
    if (memberUserId != null) result.memberUserId = memberUserId;
    if (memberDeviceId != null) result.memberDeviceId = memberDeviceId;
    if (mlsGroupState != null) result.mlsGroupState = mlsGroupState;
    return result;
  }

  AddGroupMemberRequest._();

  factory AddGroupMemberRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddGroupMemberRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddGroupMemberRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'memberUserId')
    ..aOS(4, _omitFieldNames ? '' : 'memberDeviceId')
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'mlsGroupState', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGroupMemberRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGroupMemberRequest copyWith(
          void Function(AddGroupMemberRequest) updates) =>
      super.copyWith((message) => updates(message as AddGroupMemberRequest))
          as AddGroupMemberRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddGroupMemberRequest create() => AddGroupMemberRequest._();
  @$core.override
  AddGroupMemberRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddGroupMemberRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddGroupMemberRequest>(create);
  static AddGroupMemberRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get memberUserId => $_getSZ(2);
  @$pb.TagNumber(3)
  set memberUserId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMemberUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemberUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get memberDeviceId => $_getSZ(3);
  @$pb.TagNumber(4)
  set memberDeviceId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMemberDeviceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearMemberDeviceId() => $_clearField(4);

  /// Updated MLS group state
  @$pb.TagNumber(5)
  $core.List<$core.int> get mlsGroupState => $_getN(4);
  @$pb.TagNumber(5)
  set mlsGroupState($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMlsGroupState() => $_has(4);
  @$pb.TagNumber(5)
  void clearMlsGroupState() => $_clearField(5);
}

enum AddGroupMemberResponse_Result { success, error, notSet }

class AddGroupMemberResponse extends $pb.GeneratedMessage {
  factory AddGroupMemberResponse({
    AddGroupMemberSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  AddGroupMemberResponse._();

  factory AddGroupMemberResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddGroupMemberResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, AddGroupMemberResponse_Result>
      _AddGroupMemberResponse_ResultByTag = {
    1: AddGroupMemberResponse_Result.success,
    2: AddGroupMemberResponse_Result.error,
    0: AddGroupMemberResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddGroupMemberResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<AddGroupMemberSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: AddGroupMemberSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGroupMemberResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGroupMemberResponse copyWith(
          void Function(AddGroupMemberResponse) updates) =>
      super.copyWith((message) => updates(message as AddGroupMemberResponse))
          as AddGroupMemberResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddGroupMemberResponse create() => AddGroupMemberResponse._();
  @$core.override
  AddGroupMemberResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddGroupMemberResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddGroupMemberResponse>(create);
  static AddGroupMemberResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  AddGroupMemberResponse_Result whichResult() =>
      _AddGroupMemberResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  AddGroupMemberSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(AddGroupMemberSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  AddGroupMemberSuccess ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($1.ErrorResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ErrorResponse ensureError() => $_ensure(1);
}

class AddGroupMemberSuccess extends $pb.GeneratedMessage {
  factory AddGroupMemberSuccess({
    $core.bool? added,
  }) {
    final result = create();
    if (added != null) result.added = added;
    return result;
  }

  AddGroupMemberSuccess._();

  factory AddGroupMemberSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddGroupMemberSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddGroupMemberSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'added')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGroupMemberSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddGroupMemberSuccess copyWith(
          void Function(AddGroupMemberSuccess) updates) =>
      super.copyWith((message) => updates(message as AddGroupMemberSuccess))
          as AddGroupMemberSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddGroupMemberSuccess create() => AddGroupMemberSuccess._();
  @$core.override
  AddGroupMemberSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddGroupMemberSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddGroupMemberSuccess>(create);
  static AddGroupMemberSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get added => $_getBF(0);
  @$pb.TagNumber(1)
  set added($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAdded() => $_has(0);
  @$pb.TagNumber(1)
  void clearAdded() => $_clearField(1);
}

class RemoveGroupMemberRequest extends $pb.GeneratedMessage {
  factory RemoveGroupMemberRequest({
    $core.String? accessToken,
    $core.String? groupId,
    $core.String? memberUserId,
    $core.List<$core.int>? mlsGroupState,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (groupId != null) result.groupId = groupId;
    if (memberUserId != null) result.memberUserId = memberUserId;
    if (mlsGroupState != null) result.mlsGroupState = mlsGroupState;
    return result;
  }

  RemoveGroupMemberRequest._();

  factory RemoveGroupMemberRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveGroupMemberRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveGroupMemberRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'memberUserId')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'mlsGroupState', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveGroupMemberRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveGroupMemberRequest copyWith(
          void Function(RemoveGroupMemberRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveGroupMemberRequest))
          as RemoveGroupMemberRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveGroupMemberRequest create() => RemoveGroupMemberRequest._();
  @$core.override
  RemoveGroupMemberRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveGroupMemberRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveGroupMemberRequest>(create);
  static RemoveGroupMemberRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get memberUserId => $_getSZ(2);
  @$pb.TagNumber(3)
  set memberUserId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMemberUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemberUserId() => $_clearField(3);

  /// Updated MLS group state
  @$pb.TagNumber(4)
  $core.List<$core.int> get mlsGroupState => $_getN(3);
  @$pb.TagNumber(4)
  set mlsGroupState($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMlsGroupState() => $_has(3);
  @$pb.TagNumber(4)
  void clearMlsGroupState() => $_clearField(4);
}

enum RemoveGroupMemberResponse_Result { success, error, notSet }

class RemoveGroupMemberResponse extends $pb.GeneratedMessage {
  factory RemoveGroupMemberResponse({
    RemoveGroupMemberSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  RemoveGroupMemberResponse._();

  factory RemoveGroupMemberResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveGroupMemberResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, RemoveGroupMemberResponse_Result>
      _RemoveGroupMemberResponse_ResultByTag = {
    1: RemoveGroupMemberResponse_Result.success,
    2: RemoveGroupMemberResponse_Result.error,
    0: RemoveGroupMemberResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveGroupMemberResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<RemoveGroupMemberSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: RemoveGroupMemberSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveGroupMemberResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveGroupMemberResponse copyWith(
          void Function(RemoveGroupMemberResponse) updates) =>
      super.copyWith((message) => updates(message as RemoveGroupMemberResponse))
          as RemoveGroupMemberResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveGroupMemberResponse create() => RemoveGroupMemberResponse._();
  @$core.override
  RemoveGroupMemberResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveGroupMemberResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveGroupMemberResponse>(create);
  static RemoveGroupMemberResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  RemoveGroupMemberResponse_Result whichResult() =>
      _RemoveGroupMemberResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  RemoveGroupMemberSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(RemoveGroupMemberSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  RemoveGroupMemberSuccess ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($1.ErrorResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ErrorResponse ensureError() => $_ensure(1);
}

class RemoveGroupMemberSuccess extends $pb.GeneratedMessage {
  factory RemoveGroupMemberSuccess({
    $core.bool? removed,
  }) {
    final result = create();
    if (removed != null) result.removed = removed;
    return result;
  }

  RemoveGroupMemberSuccess._();

  factory RemoveGroupMemberSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveGroupMemberSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveGroupMemberSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'removed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveGroupMemberSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveGroupMemberSuccess copyWith(
          void Function(RemoveGroupMemberSuccess) updates) =>
      super.copyWith((message) => updates(message as RemoveGroupMemberSuccess))
          as RemoveGroupMemberSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveGroupMemberSuccess create() => RemoveGroupMemberSuccess._();
  @$core.override
  RemoveGroupMemberSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveGroupMemberSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveGroupMemberSuccess>(create);
  static RemoveGroupMemberSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get removed => $_getBF(0);
  @$pb.TagNumber(1)
  set removed($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRemoved() => $_has(0);
  @$pb.TagNumber(1)
  void clearRemoved() => $_clearField(1);
}

class SendGroupMessageRequest extends $pb.GeneratedMessage {
  factory SendGroupMessageRequest({
    $core.String? accessToken,
    $core.String? groupId,
    $core.List<$core.int>? encryptedContent,
    MessageType? messageType,
    $core.String? clientMessageId,
    $1.Timestamp? clientTimestamp,
    $core.String? mediaId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (groupId != null) result.groupId = groupId;
    if (encryptedContent != null) result.encryptedContent = encryptedContent;
    if (messageType != null) result.messageType = messageType;
    if (clientMessageId != null) result.clientMessageId = clientMessageId;
    if (clientTimestamp != null) result.clientTimestamp = clientTimestamp;
    if (mediaId != null) result.mediaId = mediaId;
    return result;
  }

  SendGroupMessageRequest._();

  factory SendGroupMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendGroupMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendGroupMessageRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'encryptedContent', $pb.PbFieldType.OY)
    ..aE<MessageType>(4, _omitFieldNames ? '' : 'messageType',
        enumValues: MessageType.values)
    ..aOS(5, _omitFieldNames ? '' : 'clientMessageId')
    ..aOM<$1.Timestamp>(6, _omitFieldNames ? '' : 'clientTimestamp',
        subBuilder: $1.Timestamp.create)
    ..aOS(7, _omitFieldNames ? '' : 'mediaId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendGroupMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendGroupMessageRequest copyWith(
          void Function(SendGroupMessageRequest) updates) =>
      super.copyWith((message) => updates(message as SendGroupMessageRequest))
          as SendGroupMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendGroupMessageRequest create() => SendGroupMessageRequest._();
  @$core.override
  SendGroupMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendGroupMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendGroupMessageRequest>(create);
  static SendGroupMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  /// MLS encrypted content
  @$pb.TagNumber(3)
  $core.List<$core.int> get encryptedContent => $_getN(2);
  @$pb.TagNumber(3)
  set encryptedContent($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEncryptedContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncryptedContent() => $_clearField(3);

  @$pb.TagNumber(4)
  MessageType get messageType => $_getN(3);
  @$pb.TagNumber(4)
  set messageType(MessageType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasMessageType() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessageType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get clientMessageId => $_getSZ(4);
  @$pb.TagNumber(5)
  set clientMessageId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasClientMessageId() => $_has(4);
  @$pb.TagNumber(5)
  void clearClientMessageId() => $_clearField(5);

  @$pb.TagNumber(6)
  $1.Timestamp get clientTimestamp => $_getN(5);
  @$pb.TagNumber(6)
  set clientTimestamp($1.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasClientTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearClientTimestamp() => $_clearField(6);
  @$pb.TagNumber(6)
  $1.Timestamp ensureClientTimestamp() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get mediaId => $_getSZ(6);
  @$pb.TagNumber(7)
  set mediaId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMediaId() => $_has(6);
  @$pb.TagNumber(7)
  void clearMediaId() => $_clearField(7);
}

enum SendGroupMessageResponse_Result { success, error, notSet }

class SendGroupMessageResponse extends $pb.GeneratedMessage {
  factory SendGroupMessageResponse({
    SendGroupMessageSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  SendGroupMessageResponse._();

  factory SendGroupMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendGroupMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SendGroupMessageResponse_Result>
      _SendGroupMessageResponse_ResultByTag = {
    1: SendGroupMessageResponse_Result.success,
    2: SendGroupMessageResponse_Result.error,
    0: SendGroupMessageResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendGroupMessageResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<SendGroupMessageSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: SendGroupMessageSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendGroupMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendGroupMessageResponse copyWith(
          void Function(SendGroupMessageResponse) updates) =>
      super.copyWith((message) => updates(message as SendGroupMessageResponse))
          as SendGroupMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendGroupMessageResponse create() => SendGroupMessageResponse._();
  @$core.override
  SendGroupMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendGroupMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendGroupMessageResponse>(create);
  static SendGroupMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  SendGroupMessageResponse_Result whichResult() =>
      _SendGroupMessageResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SendGroupMessageSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(SendGroupMessageSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  SendGroupMessageSuccess ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($1.ErrorResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ErrorResponse ensureError() => $_ensure(1);
}

class SendGroupMessageSuccess extends $pb.GeneratedMessage {
  factory SendGroupMessageSuccess({
    $core.String? messageId,
    $1.Timestamp? serverTimestamp,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (serverTimestamp != null) result.serverTimestamp = serverTimestamp;
    return result;
  }

  SendGroupMessageSuccess._();

  factory SendGroupMessageSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendGroupMessageSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendGroupMessageSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOM<$1.Timestamp>(2, _omitFieldNames ? '' : 'serverTimestamp',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendGroupMessageSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendGroupMessageSuccess copyWith(
          void Function(SendGroupMessageSuccess) updates) =>
      super.copyWith((message) => updates(message as SendGroupMessageSuccess))
          as SendGroupMessageSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendGroupMessageSuccess create() => SendGroupMessageSuccess._();
  @$core.override
  SendGroupMessageSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendGroupMessageSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendGroupMessageSuccess>(create);
  static SendGroupMessageSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Timestamp get serverTimestamp => $_getN(1);
  @$pb.TagNumber(2)
  set serverTimestamp($1.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasServerTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearServerTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Timestamp ensureServerTimestamp() => $_ensure(1);
}

class GetGroupMessagesRequest extends $pb.GeneratedMessage {
  factory GetGroupMessagesRequest({
    $core.String? accessToken,
    $core.String? groupId,
    $1.PaginationRequest? pagination,
    $1.Timestamp? startTime,
    $1.Timestamp? endTime,
    $core.int? limit,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (groupId != null) result.groupId = groupId;
    if (pagination != null) result.pagination = pagination;
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    if (limit != null) result.limit = limit;
    return result;
  }

  GetGroupMessagesRequest._();

  factory GetGroupMessagesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGroupMessagesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGroupMessagesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOM<$1.PaginationRequest>(3, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.PaginationRequest.create)
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'startTime',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(5, _omitFieldNames ? '' : 'endTime',
        subBuilder: $1.Timestamp.create)
    ..aI(6, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMessagesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMessagesRequest copyWith(
          void Function(GetGroupMessagesRequest) updates) =>
      super.copyWith((message) => updates(message as GetGroupMessagesRequest))
          as GetGroupMessagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupMessagesRequest create() => GetGroupMessagesRequest._();
  @$core.override
  GetGroupMessagesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGroupMessagesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGroupMessagesRequest>(create);
  static GetGroupMessagesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.PaginationRequest get pagination => $_getN(2);
  @$pb.TagNumber(3)
  set pagination($1.PaginationRequest value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPagination() => $_has(2);
  @$pb.TagNumber(3)
  void clearPagination() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.PaginationRequest ensurePagination() => $_ensure(2);

  @$pb.TagNumber(4)
  $1.Timestamp get startTime => $_getN(3);
  @$pb.TagNumber(4)
  set startTime($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStartTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearStartTime() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureStartTime() => $_ensure(3);

  @$pb.TagNumber(5)
  $1.Timestamp get endTime => $_getN(4);
  @$pb.TagNumber(5)
  set endTime($1.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasEndTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearEndTime() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.Timestamp ensureEndTime() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.int get limit => $_getIZ(5);
  @$pb.TagNumber(6)
  set limit($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLimit() => $_has(5);
  @$pb.TagNumber(6)
  void clearLimit() => $_clearField(6);
}

enum GetGroupMessagesResponse_Result { success, error, notSet }

class GetGroupMessagesResponse extends $pb.GeneratedMessage {
  factory GetGroupMessagesResponse({
    GetGroupMessagesSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetGroupMessagesResponse._();

  factory GetGroupMessagesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGroupMessagesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetGroupMessagesResponse_Result>
      _GetGroupMessagesResponse_ResultByTag = {
    1: GetGroupMessagesResponse_Result.success,
    2: GetGroupMessagesResponse_Result.error,
    0: GetGroupMessagesResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGroupMessagesResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetGroupMessagesSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: GetGroupMessagesSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMessagesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMessagesResponse copyWith(
          void Function(GetGroupMessagesResponse) updates) =>
      super.copyWith((message) => updates(message as GetGroupMessagesResponse))
          as GetGroupMessagesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupMessagesResponse create() => GetGroupMessagesResponse._();
  @$core.override
  GetGroupMessagesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGroupMessagesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGroupMessagesResponse>(create);
  static GetGroupMessagesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetGroupMessagesResponse_Result whichResult() =>
      _GetGroupMessagesResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetGroupMessagesSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(GetGroupMessagesSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  GetGroupMessagesSuccess ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($1.ErrorResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ErrorResponse ensureError() => $_ensure(1);
}

class GetGroupMessagesSuccess extends $pb.GeneratedMessage {
  factory GetGroupMessagesSuccess({
    $core.Iterable<GroupMessage>? messages,
    $1.PaginationResponse? pagination,
  }) {
    final result = create();
    if (messages != null) result.messages.addAll(messages);
    if (pagination != null) result.pagination = pagination;
    return result;
  }

  GetGroupMessagesSuccess._();

  factory GetGroupMessagesSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGroupMessagesSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGroupMessagesSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..pPM<GroupMessage>(1, _omitFieldNames ? '' : 'messages',
        subBuilder: GroupMessage.create)
    ..aOM<$1.PaginationResponse>(2, _omitFieldNames ? '' : 'pagination',
        subBuilder: $1.PaginationResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMessagesSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupMessagesSuccess copyWith(
          void Function(GetGroupMessagesSuccess) updates) =>
      super.copyWith((message) => updates(message as GetGroupMessagesSuccess))
          as GetGroupMessagesSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupMessagesSuccess create() => GetGroupMessagesSuccess._();
  @$core.override
  GetGroupMessagesSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGroupMessagesSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGroupMessagesSuccess>(create);
  static GetGroupMessagesSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GroupMessage> get messages => $_getList(0);

  @$pb.TagNumber(2)
  $1.PaginationResponse get pagination => $_getN(1);
  @$pb.TagNumber(2)
  set pagination($1.PaginationResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPagination() => $_has(1);
  @$pb.TagNumber(2)
  void clearPagination() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.PaginationResponse ensurePagination() => $_ensure(1);
}

class GroupMessage extends $pb.GeneratedMessage {
  factory GroupMessage({
    $core.String? messageId,
    $core.String? groupId,
    $core.String? senderUserId,
    $core.String? senderDeviceId,
    $core.List<$core.int>? encryptedContent,
    MessageType? messageType,
    $core.String? clientMessageId,
    $1.Timestamp? clientTimestamp,
    $1.Timestamp? serverTimestamp,
    $core.String? mediaId,
    $core.bool? isDeleted,
    $core.String? senderUsername,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (groupId != null) result.groupId = groupId;
    if (senderUserId != null) result.senderUserId = senderUserId;
    if (senderDeviceId != null) result.senderDeviceId = senderDeviceId;
    if (encryptedContent != null) result.encryptedContent = encryptedContent;
    if (messageType != null) result.messageType = messageType;
    if (clientMessageId != null) result.clientMessageId = clientMessageId;
    if (clientTimestamp != null) result.clientTimestamp = clientTimestamp;
    if (serverTimestamp != null) result.serverTimestamp = serverTimestamp;
    if (mediaId != null) result.mediaId = mediaId;
    if (isDeleted != null) result.isDeleted = isDeleted;
    if (senderUsername != null) result.senderUsername = senderUsername;
    return result;
  }

  GroupMessage._();

  factory GroupMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GroupMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GroupMessage',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'senderUserId')
    ..aOS(4, _omitFieldNames ? '' : 'senderDeviceId')
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'encryptedContent', $pb.PbFieldType.OY)
    ..aE<MessageType>(6, _omitFieldNames ? '' : 'messageType',
        enumValues: MessageType.values)
    ..aOS(7, _omitFieldNames ? '' : 'clientMessageId')
    ..aOM<$1.Timestamp>(8, _omitFieldNames ? '' : 'clientTimestamp',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(9, _omitFieldNames ? '' : 'serverTimestamp',
        subBuilder: $1.Timestamp.create)
    ..aOS(10, _omitFieldNames ? '' : 'mediaId')
    ..aOB(11, _omitFieldNames ? '' : 'isDeleted')
    ..aOS(12, _omitFieldNames ? '' : 'senderUsername')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupMessage copyWith(void Function(GroupMessage) updates) =>
      super.copyWith((message) => updates(message as GroupMessage))
          as GroupMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupMessage create() => GroupMessage._();
  @$core.override
  GroupMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GroupMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GroupMessage>(create);
  static GroupMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get senderUserId => $_getSZ(2);
  @$pb.TagNumber(3)
  set senderUserId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSenderUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSenderUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get senderDeviceId => $_getSZ(3);
  @$pb.TagNumber(4)
  set senderDeviceId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSenderDeviceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSenderDeviceId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get encryptedContent => $_getN(4);
  @$pb.TagNumber(5)
  set encryptedContent($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEncryptedContent() => $_has(4);
  @$pb.TagNumber(5)
  void clearEncryptedContent() => $_clearField(5);

  @$pb.TagNumber(6)
  MessageType get messageType => $_getN(5);
  @$pb.TagNumber(6)
  set messageType(MessageType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasMessageType() => $_has(5);
  @$pb.TagNumber(6)
  void clearMessageType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get clientMessageId => $_getSZ(6);
  @$pb.TagNumber(7)
  set clientMessageId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasClientMessageId() => $_has(6);
  @$pb.TagNumber(7)
  void clearClientMessageId() => $_clearField(7);

  @$pb.TagNumber(8)
  $1.Timestamp get clientTimestamp => $_getN(7);
  @$pb.TagNumber(8)
  set clientTimestamp($1.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasClientTimestamp() => $_has(7);
  @$pb.TagNumber(8)
  void clearClientTimestamp() => $_clearField(8);
  @$pb.TagNumber(8)
  $1.Timestamp ensureClientTimestamp() => $_ensure(7);

  @$pb.TagNumber(9)
  $1.Timestamp get serverTimestamp => $_getN(8);
  @$pb.TagNumber(9)
  set serverTimestamp($1.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasServerTimestamp() => $_has(8);
  @$pb.TagNumber(9)
  void clearServerTimestamp() => $_clearField(9);
  @$pb.TagNumber(9)
  $1.Timestamp ensureServerTimestamp() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.String get mediaId => $_getSZ(9);
  @$pb.TagNumber(10)
  set mediaId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMediaId() => $_has(9);
  @$pb.TagNumber(10)
  void clearMediaId() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get isDeleted => $_getBF(10);
  @$pb.TagNumber(11)
  set isDeleted($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasIsDeleted() => $_has(10);
  @$pb.TagNumber(11)
  void clearIsDeleted() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get senderUsername => $_getSZ(11);
  @$pb.TagNumber(12)
  set senderUsername($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasSenderUsername() => $_has(11);
  @$pb.TagNumber(12)
  void clearSenderUsername() => $_clearField(12);
}

class GetGroupsRequest extends $pb.GeneratedMessage {
  factory GetGroupsRequest({
    $core.String? accessToken,
    $core.int? limit,
    $core.String? cursor,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (limit != null) result.limit = limit;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  GetGroupsRequest._();

  factory GetGroupsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGroupsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGroupsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aI(2, _omitFieldNames ? '' : 'limit')
    ..aOS(3, _omitFieldNames ? '' : 'cursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupsRequest copyWith(void Function(GetGroupsRequest) updates) =>
      super.copyWith((message) => updates(message as GetGroupsRequest))
          as GetGroupsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupsRequest create() => GetGroupsRequest._();
  @$core.override
  GetGroupsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGroupsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGroupsRequest>(create);
  static GetGroupsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get cursor => $_getSZ(2);
  @$pb.TagNumber(3)
  set cursor($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCursor() => $_has(2);
  @$pb.TagNumber(3)
  void clearCursor() => $_clearField(3);
}

enum GetGroupsResponse_Result { success, error, notSet }

class GetGroupsResponse extends $pb.GeneratedMessage {
  factory GetGroupsResponse({
    GetGroupsSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetGroupsResponse._();

  factory GetGroupsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGroupsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetGroupsResponse_Result>
      _GetGroupsResponse_ResultByTag = {
    1: GetGroupsResponse_Result.success,
    2: GetGroupsResponse_Result.error,
    0: GetGroupsResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGroupsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetGroupsSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: GetGroupsSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupsResponse copyWith(void Function(GetGroupsResponse) updates) =>
      super.copyWith((message) => updates(message as GetGroupsResponse))
          as GetGroupsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupsResponse create() => GetGroupsResponse._();
  @$core.override
  GetGroupsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGroupsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGroupsResponse>(create);
  static GetGroupsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetGroupsResponse_Result whichResult() =>
      _GetGroupsResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetGroupsSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(GetGroupsSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  GetGroupsSuccess ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($1.ErrorResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ErrorResponse ensureError() => $_ensure(1);
}

class GetGroupsSuccess extends $pb.GeneratedMessage {
  factory GetGroupsSuccess({
    $core.Iterable<GroupInfo>? groups,
    $core.String? nextCursor,
    $core.bool? hasMore,
  }) {
    final result = create();
    if (groups != null) result.groups.addAll(groups);
    if (nextCursor != null) result.nextCursor = nextCursor;
    if (hasMore != null) result.hasMore = hasMore;
    return result;
  }

  GetGroupsSuccess._();

  factory GetGroupsSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGroupsSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGroupsSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..pPM<GroupInfo>(1, _omitFieldNames ? '' : 'groups',
        subBuilder: GroupInfo.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextCursor')
    ..aOB(3, _omitFieldNames ? '' : 'hasMore')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupsSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupsSuccess copyWith(void Function(GetGroupsSuccess) updates) =>
      super.copyWith((message) => updates(message as GetGroupsSuccess))
          as GetGroupsSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupsSuccess create() => GetGroupsSuccess._();
  @$core.override
  GetGroupsSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGroupsSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGroupsSuccess>(create);
  static GetGroupsSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GroupInfo> get groups => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextCursor => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextCursor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextCursor() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get hasMore => $_getBF(2);
  @$pb.TagNumber(3)
  set hasMore($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHasMore() => $_has(2);
  @$pb.TagNumber(3)
  void clearHasMore() => $_clearField(3);
}

class GroupInfo extends $pb.GeneratedMessage {
  factory GroupInfo({
    $core.String? groupId,
    $core.String? name,
    $core.String? creatorUserId,
    $core.Iterable<GroupMemberInfo>? members,
    $1.Timestamp? createdAt,
    $core.int? memberCount,
    GroupMessage? lastMessage,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (name != null) result.name = name;
    if (creatorUserId != null) result.creatorUserId = creatorUserId;
    if (members != null) result.members.addAll(members);
    if (createdAt != null) result.createdAt = createdAt;
    if (memberCount != null) result.memberCount = memberCount;
    if (lastMessage != null) result.lastMessage = lastMessage;
    return result;
  }

  GroupInfo._();

  factory GroupInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GroupInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GroupInfo',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'creatorUserId')
    ..pPM<GroupMemberInfo>(4, _omitFieldNames ? '' : 'members',
        subBuilder: GroupMemberInfo.create)
    ..aOM<$1.Timestamp>(5, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..aI(6, _omitFieldNames ? '' : 'memberCount')
    ..aOM<GroupMessage>(7, _omitFieldNames ? '' : 'lastMessage',
        subBuilder: GroupMessage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupInfo copyWith(void Function(GroupInfo) updates) =>
      super.copyWith((message) => updates(message as GroupInfo)) as GroupInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupInfo create() => GroupInfo._();
  @$core.override
  GroupInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GroupInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupInfo>(create);
  static GroupInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get creatorUserId => $_getSZ(2);
  @$pb.TagNumber(3)
  set creatorUserId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCreatorUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreatorUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<GroupMemberInfo> get members => $_getList(3);

  @$pb.TagNumber(5)
  $1.Timestamp get createdAt => $_getN(4);
  @$pb.TagNumber(5)
  set createdAt($1.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.Timestamp ensureCreatedAt() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.int get memberCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set memberCount($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMemberCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearMemberCount() => $_clearField(6);

  @$pb.TagNumber(7)
  GroupMessage get lastMessage => $_getN(6);
  @$pb.TagNumber(7)
  set lastMessage(GroupMessage value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasLastMessage() => $_has(6);
  @$pb.TagNumber(7)
  void clearLastMessage() => $_clearField(7);
  @$pb.TagNumber(7)
  GroupMessage ensureLastMessage() => $_ensure(6);
}

class GroupMemberInfo extends $pb.GeneratedMessage {
  factory GroupMemberInfo({
    $core.String? userId,
    $core.String? username,
    $core.String? deviceId,
    $core.String? role,
    $1.Timestamp? joinedAt,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (username != null) result.username = username;
    if (deviceId != null) result.deviceId = deviceId;
    if (role != null) result.role = role;
    if (joinedAt != null) result.joinedAt = joinedAt;
    return result;
  }

  GroupMemberInfo._();

  factory GroupMemberInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GroupMemberInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GroupMemberInfo',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'deviceId')
    ..aOS(4, _omitFieldNames ? '' : 'role')
    ..aOM<$1.Timestamp>(5, _omitFieldNames ? '' : 'joinedAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupMemberInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupMemberInfo copyWith(void Function(GroupMemberInfo) updates) =>
      super.copyWith((message) => updates(message as GroupMemberInfo))
          as GroupMemberInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupMemberInfo create() => GroupMemberInfo._();
  @$core.override
  GroupMemberInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GroupMemberInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GroupMemberInfo>(create);
  static GroupMemberInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get deviceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get role => $_getSZ(3);
  @$pb.TagNumber(4)
  set role($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRole() => $_has(3);
  @$pb.TagNumber(4)
  void clearRole() => $_clearField(4);

  @$pb.TagNumber(5)
  $1.Timestamp get joinedAt => $_getN(4);
  @$pb.TagNumber(5)
  set joinedAt($1.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasJoinedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearJoinedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.Timestamp ensureJoinedAt() => $_ensure(4);
}

class GetGroupByIdRequest extends $pb.GeneratedMessage {
  factory GetGroupByIdRequest({
    $core.String? accessToken,
    $core.String? groupId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (groupId != null) result.groupId = groupId;
    return result;
  }

  GetGroupByIdRequest._();

  factory GetGroupByIdRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGroupByIdRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGroupByIdRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupByIdRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupByIdRequest copyWith(void Function(GetGroupByIdRequest) updates) =>
      super.copyWith((message) => updates(message as GetGroupByIdRequest))
          as GetGroupByIdRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupByIdRequest create() => GetGroupByIdRequest._();
  @$core.override
  GetGroupByIdRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGroupByIdRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGroupByIdRequest>(create);
  static GetGroupByIdRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);
}

enum GetGroupByIdResponse_Result { success, error, notSet }

class GetGroupByIdResponse extends $pb.GeneratedMessage {
  factory GetGroupByIdResponse({
    GetGroupByIdSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetGroupByIdResponse._();

  factory GetGroupByIdResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGroupByIdResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetGroupByIdResponse_Result>
      _GetGroupByIdResponse_ResultByTag = {
    1: GetGroupByIdResponse_Result.success,
    2: GetGroupByIdResponse_Result.error,
    0: GetGroupByIdResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGroupByIdResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetGroupByIdSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: GetGroupByIdSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupByIdResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupByIdResponse copyWith(void Function(GetGroupByIdResponse) updates) =>
      super.copyWith((message) => updates(message as GetGroupByIdResponse))
          as GetGroupByIdResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupByIdResponse create() => GetGroupByIdResponse._();
  @$core.override
  GetGroupByIdResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGroupByIdResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGroupByIdResponse>(create);
  static GetGroupByIdResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetGroupByIdResponse_Result whichResult() =>
      _GetGroupByIdResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetGroupByIdSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(GetGroupByIdSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  GetGroupByIdSuccess ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($1.ErrorResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ErrorResponse ensureError() => $_ensure(1);
}

class GetGroupByIdSuccess extends $pb.GeneratedMessage {
  factory GetGroupByIdSuccess({
    GroupInfo? group,
  }) {
    final result = create();
    if (group != null) result.group = group;
    return result;
  }

  GetGroupByIdSuccess._();

  factory GetGroupByIdSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGroupByIdSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGroupByIdSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOM<GroupInfo>(1, _omitFieldNames ? '' : 'group',
        subBuilder: GroupInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupByIdSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGroupByIdSuccess copyWith(void Function(GetGroupByIdSuccess) updates) =>
      super.copyWith((message) => updates(message as GetGroupByIdSuccess))
          as GetGroupByIdSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupByIdSuccess create() => GetGroupByIdSuccess._();
  @$core.override
  GetGroupByIdSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGroupByIdSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGroupByIdSuccess>(create);
  static GetGroupByIdSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  GroupInfo get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(GroupInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => $_clearField(1);
  @$pb.TagNumber(1)
  GroupInfo ensureGroup() => $_ensure(0);
}

class LeaveGroupRequest extends $pb.GeneratedMessage {
  factory LeaveGroupRequest({
    $core.String? accessToken,
    $core.String? groupId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (groupId != null) result.groupId = groupId;
    return result;
  }

  LeaveGroupRequest._();

  factory LeaveGroupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LeaveGroupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LeaveGroupRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveGroupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveGroupRequest copyWith(void Function(LeaveGroupRequest) updates) =>
      super.copyWith((message) => updates(message as LeaveGroupRequest))
          as LeaveGroupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaveGroupRequest create() => LeaveGroupRequest._();
  @$core.override
  LeaveGroupRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LeaveGroupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LeaveGroupRequest>(create);
  static LeaveGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);
}

enum LeaveGroupResponse_Result { success, error, notSet }

class LeaveGroupResponse extends $pb.GeneratedMessage {
  factory LeaveGroupResponse({
    LeaveGroupSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  LeaveGroupResponse._();

  factory LeaveGroupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LeaveGroupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, LeaveGroupResponse_Result>
      _LeaveGroupResponse_ResultByTag = {
    1: LeaveGroupResponse_Result.success,
    2: LeaveGroupResponse_Result.error,
    0: LeaveGroupResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LeaveGroupResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<LeaveGroupSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: LeaveGroupSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveGroupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveGroupResponse copyWith(void Function(LeaveGroupResponse) updates) =>
      super.copyWith((message) => updates(message as LeaveGroupResponse))
          as LeaveGroupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaveGroupResponse create() => LeaveGroupResponse._();
  @$core.override
  LeaveGroupResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LeaveGroupResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LeaveGroupResponse>(create);
  static LeaveGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  LeaveGroupResponse_Result whichResult() =>
      _LeaveGroupResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  LeaveGroupSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(LeaveGroupSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  LeaveGroupSuccess ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($1.ErrorResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ErrorResponse ensureError() => $_ensure(1);
}

class LeaveGroupSuccess extends $pb.GeneratedMessage {
  factory LeaveGroupSuccess({
    $core.bool? left,
  }) {
    final result = create();
    if (left != null) result.left = left;
    return result;
  }

  LeaveGroupSuccess._();

  factory LeaveGroupSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LeaveGroupSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LeaveGroupSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'left')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveGroupSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveGroupSuccess copyWith(void Function(LeaveGroupSuccess) updates) =>
      super.copyWith((message) => updates(message as LeaveGroupSuccess))
          as LeaveGroupSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaveGroupSuccess create() => LeaveGroupSuccess._();
  @$core.override
  LeaveGroupSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LeaveGroupSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LeaveGroupSuccess>(create);
  static LeaveGroupSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get left => $_getBF(0);
  @$pb.TagNumber(1)
  set left($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLeft() => $_has(0);
  @$pb.TagNumber(1)
  void clearLeft() => $_clearField(1);
}

class HealthRequest extends $pb.GeneratedMessage {
  factory HealthRequest() => create();

  HealthRequest._();

  factory HealthRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HealthRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HealthRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HealthRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HealthRequest copyWith(void Function(HealthRequest) updates) =>
      super.copyWith((message) => updates(message as HealthRequest))
          as HealthRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HealthRequest create() => HealthRequest._();
  @$core.override
  HealthRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HealthRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HealthRequest>(create);
  static HealthRequest? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
