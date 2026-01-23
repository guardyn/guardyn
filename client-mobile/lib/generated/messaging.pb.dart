// This is a generated file - do not edit.
//
// Generated from messaging.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

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
    $core.String? x3dhPrekey,
    ThreadReference? threadReference,
    VoiceMessageMetadata? voiceMetadata,
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
    if (x3dhPrekey != null) result.x3dhPrekey = x3dhPrekey;
    if (threadReference != null) result.threadReference = threadReference;
    if (voiceMetadata != null) result.voiceMetadata = voiceMetadata;
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
    ..aOS(10, _omitFieldNames ? '' : 'x3dhPrekey')
    ..aOM<ThreadReference>(11, _omitFieldNames ? '' : 'threadReference',
        subBuilder: ThreadReference.create)
    ..aOM<VoiceMessageMetadata>(12, _omitFieldNames ? '' : 'voiceMetadata',
        subBuilder: VoiceMessageMetadata.create)
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

  /// X3DH prekey data for first message (allows recipient to create responder session)
  /// Base64-encoded X3DHPrekeyMessage containing: sender_identity_key, ephemeral_key, used_otpk_id
  @$pb.TagNumber(10)
  $core.String get x3dhPrekey => $_getSZ(9);
  @$pb.TagNumber(10)
  set x3dhPrekey($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasX3dhPrekey() => $_has(9);
  @$pb.TagNumber(10)
  void clearX3dhPrekey() => $_clearField(10);

  /// Phase 2: Reply/Quote support
  @$pb.TagNumber(11)
  ThreadReference get threadReference => $_getN(10);
  @$pb.TagNumber(11)
  set threadReference(ThreadReference value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasThreadReference() => $_has(10);
  @$pb.TagNumber(11)
  void clearThreadReference() => $_clearField(11);
  @$pb.TagNumber(11)
  ThreadReference ensureThreadReference() => $_ensure(10);

  /// Phase 2: Voice message metadata
  @$pb.TagNumber(12)
  VoiceMessageMetadata get voiceMetadata => $_getN(11);
  @$pb.TagNumber(12)
  set voiceMetadata(VoiceMessageMetadata value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasVoiceMetadata() => $_has(11);
  @$pb.TagNumber(12)
  void clearVoiceMetadata() => $_clearField(12);
  @$pb.TagNumber(12)
  VoiceMessageMetadata ensureVoiceMetadata() => $_ensure(11);
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
    $core.String? x3dhPrekey,
    ThreadReference? threadReference,
    ForwardInfo? forwardInfo,
    $core.int? editVersion,
    $1.Timestamp? lastEditedAt,
    VoiceMessageMetadata? voiceMetadata,
    $core.Iterable<ReactionSummary>? reactionSummaries,
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
    if (x3dhPrekey != null) result.x3dhPrekey = x3dhPrekey;
    if (threadReference != null) result.threadReference = threadReference;
    if (forwardInfo != null) result.forwardInfo = forwardInfo;
    if (editVersion != null) result.editVersion = editVersion;
    if (lastEditedAt != null) result.lastEditedAt = lastEditedAt;
    if (voiceMetadata != null) result.voiceMetadata = voiceMetadata;
    if (reactionSummaries != null)
      result.reactionSummaries.addAll(reactionSummaries);
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
    ..aOS(14, _omitFieldNames ? '' : 'x3dhPrekey')
    ..aOM<ThreadReference>(15, _omitFieldNames ? '' : 'threadReference',
        subBuilder: ThreadReference.create)
    ..aOM<ForwardInfo>(16, _omitFieldNames ? '' : 'forwardInfo',
        subBuilder: ForwardInfo.create)
    ..aI(17, _omitFieldNames ? '' : 'editVersion')
    ..aOM<$1.Timestamp>(18, _omitFieldNames ? '' : 'lastEditedAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<VoiceMessageMetadata>(19, _omitFieldNames ? '' : 'voiceMetadata',
        subBuilder: VoiceMessageMetadata.create)
    ..pPM<ReactionSummary>(20, _omitFieldNames ? '' : 'reactionSummaries',
        subBuilder: ReactionSummary.create)
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

  /// X3DH prekey data for first message (allows recipient to create responder session)
  @$pb.TagNumber(14)
  $core.String get x3dhPrekey => $_getSZ(13);
  @$pb.TagNumber(14)
  set x3dhPrekey($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasX3dhPrekey() => $_has(13);
  @$pb.TagNumber(14)
  void clearX3dhPrekey() => $_clearField(14);

  /// Phase 2: Reply/Quote support
  @$pb.TagNumber(15)
  ThreadReference get threadReference => $_getN(14);
  @$pb.TagNumber(15)
  set threadReference(ThreadReference value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasThreadReference() => $_has(14);
  @$pb.TagNumber(15)
  void clearThreadReference() => $_clearField(15);
  @$pb.TagNumber(15)
  ThreadReference ensureThreadReference() => $_ensure(14);

  /// Phase 2: Forward support
  @$pb.TagNumber(16)
  ForwardInfo get forwardInfo => $_getN(15);
  @$pb.TagNumber(16)
  set forwardInfo(ForwardInfo value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasForwardInfo() => $_has(15);
  @$pb.TagNumber(16)
  void clearForwardInfo() => $_clearField(16);
  @$pb.TagNumber(16)
  ForwardInfo ensureForwardInfo() => $_ensure(15);

  /// Phase 2: Edit tracking
  @$pb.TagNumber(17)
  $core.int get editVersion => $_getIZ(16);
  @$pb.TagNumber(17)
  set editVersion($core.int value) => $_setSignedInt32(16, value);
  @$pb.TagNumber(17)
  $core.bool hasEditVersion() => $_has(16);
  @$pb.TagNumber(17)
  void clearEditVersion() => $_clearField(17);

  @$pb.TagNumber(18)
  $1.Timestamp get lastEditedAt => $_getN(17);
  @$pb.TagNumber(18)
  set lastEditedAt($1.Timestamp value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasLastEditedAt() => $_has(17);
  @$pb.TagNumber(18)
  void clearLastEditedAt() => $_clearField(18);
  @$pb.TagNumber(18)
  $1.Timestamp ensureLastEditedAt() => $_ensure(17);

  /// Phase 2: Voice message metadata
  @$pb.TagNumber(19)
  VoiceMessageMetadata get voiceMetadata => $_getN(18);
  @$pb.TagNumber(19)
  set voiceMetadata(VoiceMessageMetadata value) => $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasVoiceMetadata() => $_has(18);
  @$pb.TagNumber(19)
  void clearVoiceMetadata() => $_clearField(19);
  @$pb.TagNumber(19)
  VoiceMessageMetadata ensureVoiceMetadata() => $_ensure(18);

  /// Phase 2: Reactions summary (aggregated)
  @$pb.TagNumber(20)
  $pb.PbList<ReactionSummary> get reactionSummaries => $_getList(19);
}

/// Aggregated reaction count for UI display
class ReactionSummary extends $pb.GeneratedMessage {
  factory ReactionSummary({
    $core.String? emoji,
    $core.int? count,
    $core.bool? userReacted,
  }) {
    final result = create();
    if (emoji != null) result.emoji = emoji;
    if (count != null) result.count = count;
    if (userReacted != null) result.userReacted = userReacted;
    return result;
  }

  ReactionSummary._();

  factory ReactionSummary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReactionSummary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReactionSummary',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'emoji')
    ..aI(2, _omitFieldNames ? '' : 'count')
    ..aOB(3, _omitFieldNames ? '' : 'userReacted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReactionSummary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReactionSummary copyWith(void Function(ReactionSummary) updates) =>
      super.copyWith((message) => updates(message as ReactionSummary))
          as ReactionSummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReactionSummary create() => ReactionSummary._();
  @$core.override
  ReactionSummary createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReactionSummary getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReactionSummary>(create);
  static ReactionSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get emoji => $_getSZ(0);
  @$pb.TagNumber(1)
  set emoji($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEmoji() => $_has(0);
  @$pb.TagNumber(1)
  void clearEmoji() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get count => $_getIZ(1);
  @$pb.TagNumber(2)
  set count($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get userReacted => $_getBF(2);
  @$pb.TagNumber(3)
  set userReacted($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserReacted() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserReacted() => $_clearField(3);
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

class ClearChatRequest extends $pb.GeneratedMessage {
  factory ClearChatRequest({
    $core.String? accessToken,
    $core.String? conversationId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (conversationId != null) result.conversationId = conversationId;
    return result;
  }

  ClearChatRequest._();

  factory ClearChatRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClearChatRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClearChatRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearChatRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearChatRequest copyWith(void Function(ClearChatRequest) updates) =>
      super.copyWith((message) => updates(message as ClearChatRequest))
          as ClearChatRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClearChatRequest create() => ClearChatRequest._();
  @$core.override
  ClearChatRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClearChatRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClearChatRequest>(create);
  static ClearChatRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);
}

enum ClearChatResponse_Result { success, error, notSet }

class ClearChatResponse extends $pb.GeneratedMessage {
  factory ClearChatResponse({
    ClearChatSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  ClearChatResponse._();

  factory ClearChatResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClearChatResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ClearChatResponse_Result>
      _ClearChatResponse_ResultByTag = {
    1: ClearChatResponse_Result.success,
    2: ClearChatResponse_Result.error,
    0: ClearChatResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClearChatResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<ClearChatSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: ClearChatSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearChatResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearChatResponse copyWith(void Function(ClearChatResponse) updates) =>
      super.copyWith((message) => updates(message as ClearChatResponse))
          as ClearChatResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClearChatResponse create() => ClearChatResponse._();
  @$core.override
  ClearChatResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClearChatResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClearChatResponse>(create);
  static ClearChatResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  ClearChatResponse_Result whichResult() =>
      _ClearChatResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ClearChatSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(ClearChatSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  ClearChatSuccess ensureSuccess() => $_ensure(0);

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

class ClearChatSuccess extends $pb.GeneratedMessage {
  factory ClearChatSuccess({
    $core.int? deletedCount,
    $1.Timestamp? timestamp,
  }) {
    final result = create();
    if (deletedCount != null) result.deletedCount = deletedCount;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ClearChatSuccess._();

  factory ClearChatSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClearChatSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClearChatSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'deletedCount',
        fieldType: $pb.PbFieldType.OU3)
    ..aOM<$1.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearChatSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearChatSuccess copyWith(void Function(ClearChatSuccess) updates) =>
      super.copyWith((message) => updates(message as ClearChatSuccess))
          as ClearChatSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClearChatSuccess create() => ClearChatSuccess._();
  @$core.override
  ClearChatSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClearChatSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClearChatSuccess>(create);
  static ClearChatSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get deletedCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set deletedCount($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeletedCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeletedCount() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($1.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Timestamp ensureTimestamp() => $_ensure(1);
}

class TypingIndicatorRequest extends $pb.GeneratedMessage {
  factory TypingIndicatorRequest({
    $core.String? accessToken,
    $core.String? recipientUserId,
    $core.bool? isTyping,
    $core.String? groupId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (recipientUserId != null) result.recipientUserId = recipientUserId;
    if (isTyping != null) result.isTyping = isTyping;
    if (groupId != null) result.groupId = groupId;
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
    ..aOS(4, _omitFieldNames ? '' : 'groupId')
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

  @$pb.TagNumber(4)
  $core.String get groupId => $_getSZ(3);
  @$pb.TagNumber(4)
  set groupId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGroupId() => $_has(3);
  @$pb.TagNumber(4)
  void clearGroupId() => $_clearField(4);
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
    $core.String? iconMediaId,
    $core.String? description,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (groupName != null) result.groupName = groupName;
    if (memberUserIds != null) result.memberUserIds.addAll(memberUserIds);
    if (mlsGroupState != null) result.mlsGroupState = mlsGroupState;
    if (iconMediaId != null) result.iconMediaId = iconMediaId;
    if (description != null) result.description = description;
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
    ..aOS(5, _omitFieldNames ? '' : 'iconMediaId')
    ..aOS(6, _omitFieldNames ? '' : 'description')
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

  /// Optional: group icon and description
  @$pb.TagNumber(5)
  $core.String get iconMediaId => $_getSZ(4);
  @$pb.TagNumber(5)
  set iconMediaId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIconMediaId() => $_has(4);
  @$pb.TagNumber(5)
  void clearIconMediaId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);
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

class ChangeMemberRoleRequest extends $pb.GeneratedMessage {
  factory ChangeMemberRoleRequest({
    $core.String? accessToken,
    $core.String? groupId,
    $core.String? targetUserId,
    $core.String? newRole,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (groupId != null) result.groupId = groupId;
    if (targetUserId != null) result.targetUserId = targetUserId;
    if (newRole != null) result.newRole = newRole;
    return result;
  }

  ChangeMemberRoleRequest._();

  factory ChangeMemberRoleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChangeMemberRoleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChangeMemberRoleRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'targetUserId')
    ..aOS(4, _omitFieldNames ? '' : 'newRole')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeMemberRoleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeMemberRoleRequest copyWith(
          void Function(ChangeMemberRoleRequest) updates) =>
      super.copyWith((message) => updates(message as ChangeMemberRoleRequest))
          as ChangeMemberRoleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangeMemberRoleRequest create() => ChangeMemberRoleRequest._();
  @$core.override
  ChangeMemberRoleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChangeMemberRoleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChangeMemberRoleRequest>(create);
  static ChangeMemberRoleRequest? _defaultInstance;

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
  $core.String get targetUserId => $_getSZ(2);
  @$pb.TagNumber(3)
  set targetUserId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTargetUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTargetUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get newRole => $_getSZ(3);
  @$pb.TagNumber(4)
  set newRole($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNewRole() => $_has(3);
  @$pb.TagNumber(4)
  void clearNewRole() => $_clearField(4);
}

enum ChangeMemberRoleResponse_Result { success, error, notSet }

class ChangeMemberRoleResponse extends $pb.GeneratedMessage {
  factory ChangeMemberRoleResponse({
    ChangeMemberRoleSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  ChangeMemberRoleResponse._();

  factory ChangeMemberRoleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChangeMemberRoleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ChangeMemberRoleResponse_Result>
      _ChangeMemberRoleResponse_ResultByTag = {
    1: ChangeMemberRoleResponse_Result.success,
    2: ChangeMemberRoleResponse_Result.error,
    0: ChangeMemberRoleResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChangeMemberRoleResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<ChangeMemberRoleSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: ChangeMemberRoleSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeMemberRoleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeMemberRoleResponse copyWith(
          void Function(ChangeMemberRoleResponse) updates) =>
      super.copyWith((message) => updates(message as ChangeMemberRoleResponse))
          as ChangeMemberRoleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangeMemberRoleResponse create() => ChangeMemberRoleResponse._();
  @$core.override
  ChangeMemberRoleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChangeMemberRoleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChangeMemberRoleResponse>(create);
  static ChangeMemberRoleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  ChangeMemberRoleResponse_Result whichResult() =>
      _ChangeMemberRoleResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ChangeMemberRoleSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(ChangeMemberRoleSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  ChangeMemberRoleSuccess ensureSuccess() => $_ensure(0);

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

class ChangeMemberRoleSuccess extends $pb.GeneratedMessage {
  factory ChangeMemberRoleSuccess({
    $core.bool? changed,
    $core.String? newRole,
  }) {
    final result = create();
    if (changed != null) result.changed = changed;
    if (newRole != null) result.newRole = newRole;
    return result;
  }

  ChangeMemberRoleSuccess._();

  factory ChangeMemberRoleSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChangeMemberRoleSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChangeMemberRoleSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'changed')
    ..aOS(2, _omitFieldNames ? '' : 'newRole')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeMemberRoleSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeMemberRoleSuccess copyWith(
          void Function(ChangeMemberRoleSuccess) updates) =>
      super.copyWith((message) => updates(message as ChangeMemberRoleSuccess))
          as ChangeMemberRoleSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangeMemberRoleSuccess create() => ChangeMemberRoleSuccess._();
  @$core.override
  ChangeMemberRoleSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChangeMemberRoleSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChangeMemberRoleSuccess>(create);
  static ChangeMemberRoleSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get changed => $_getBF(0);
  @$pb.TagNumber(1)
  set changed($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChanged() => $_has(0);
  @$pb.TagNumber(1)
  void clearChanged() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get newRole => $_getSZ(1);
  @$pb.TagNumber(2)
  set newRole($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewRole() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewRole() => $_clearField(2);
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
    ThreadReference? threadReference,
    VoiceMessageMetadata? voiceMetadata,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (groupId != null) result.groupId = groupId;
    if (encryptedContent != null) result.encryptedContent = encryptedContent;
    if (messageType != null) result.messageType = messageType;
    if (clientMessageId != null) result.clientMessageId = clientMessageId;
    if (clientTimestamp != null) result.clientTimestamp = clientTimestamp;
    if (mediaId != null) result.mediaId = mediaId;
    if (threadReference != null) result.threadReference = threadReference;
    if (voiceMetadata != null) result.voiceMetadata = voiceMetadata;
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
    ..aOM<ThreadReference>(8, _omitFieldNames ? '' : 'threadReference',
        subBuilder: ThreadReference.create)
    ..aOM<VoiceMessageMetadata>(9, _omitFieldNames ? '' : 'voiceMetadata',
        subBuilder: VoiceMessageMetadata.create)
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

  /// Phase 2: Reply/Quote support
  @$pb.TagNumber(8)
  ThreadReference get threadReference => $_getN(7);
  @$pb.TagNumber(8)
  set threadReference(ThreadReference value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasThreadReference() => $_has(7);
  @$pb.TagNumber(8)
  void clearThreadReference() => $_clearField(8);
  @$pb.TagNumber(8)
  ThreadReference ensureThreadReference() => $_ensure(7);

  /// Phase 2: Voice message metadata
  @$pb.TagNumber(9)
  VoiceMessageMetadata get voiceMetadata => $_getN(8);
  @$pb.TagNumber(9)
  set voiceMetadata(VoiceMessageMetadata value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasVoiceMetadata() => $_has(8);
  @$pb.TagNumber(9)
  void clearVoiceMetadata() => $_clearField(9);
  @$pb.TagNumber(9)
  VoiceMessageMetadata ensureVoiceMetadata() => $_ensure(8);
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
    ThreadReference? threadReference,
    ForwardInfo? forwardInfo,
    $core.int? editVersion,
    $1.Timestamp? lastEditedAt,
    VoiceMessageMetadata? voiceMetadata,
    $core.Iterable<ReactionSummary>? reactionSummaries,
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
    if (threadReference != null) result.threadReference = threadReference;
    if (forwardInfo != null) result.forwardInfo = forwardInfo;
    if (editVersion != null) result.editVersion = editVersion;
    if (lastEditedAt != null) result.lastEditedAt = lastEditedAt;
    if (voiceMetadata != null) result.voiceMetadata = voiceMetadata;
    if (reactionSummaries != null)
      result.reactionSummaries.addAll(reactionSummaries);
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
    ..aOM<ThreadReference>(13, _omitFieldNames ? '' : 'threadReference',
        subBuilder: ThreadReference.create)
    ..aOM<ForwardInfo>(14, _omitFieldNames ? '' : 'forwardInfo',
        subBuilder: ForwardInfo.create)
    ..aI(15, _omitFieldNames ? '' : 'editVersion')
    ..aOM<$1.Timestamp>(16, _omitFieldNames ? '' : 'lastEditedAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<VoiceMessageMetadata>(17, _omitFieldNames ? '' : 'voiceMetadata',
        subBuilder: VoiceMessageMetadata.create)
    ..pPM<ReactionSummary>(18, _omitFieldNames ? '' : 'reactionSummaries',
        subBuilder: ReactionSummary.create)
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

  /// Phase 2: Reply/Quote support
  @$pb.TagNumber(13)
  ThreadReference get threadReference => $_getN(12);
  @$pb.TagNumber(13)
  set threadReference(ThreadReference value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasThreadReference() => $_has(12);
  @$pb.TagNumber(13)
  void clearThreadReference() => $_clearField(13);
  @$pb.TagNumber(13)
  ThreadReference ensureThreadReference() => $_ensure(12);

  /// Phase 2: Forward support
  @$pb.TagNumber(14)
  ForwardInfo get forwardInfo => $_getN(13);
  @$pb.TagNumber(14)
  set forwardInfo(ForwardInfo value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasForwardInfo() => $_has(13);
  @$pb.TagNumber(14)
  void clearForwardInfo() => $_clearField(14);
  @$pb.TagNumber(14)
  ForwardInfo ensureForwardInfo() => $_ensure(13);

  /// Phase 2: Edit tracking
  @$pb.TagNumber(15)
  $core.int get editVersion => $_getIZ(14);
  @$pb.TagNumber(15)
  set editVersion($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasEditVersion() => $_has(14);
  @$pb.TagNumber(15)
  void clearEditVersion() => $_clearField(15);

  @$pb.TagNumber(16)
  $1.Timestamp get lastEditedAt => $_getN(15);
  @$pb.TagNumber(16)
  set lastEditedAt($1.Timestamp value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasLastEditedAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearLastEditedAt() => $_clearField(16);
  @$pb.TagNumber(16)
  $1.Timestamp ensureLastEditedAt() => $_ensure(15);

  /// Phase 2: Voice message metadata
  @$pb.TagNumber(17)
  VoiceMessageMetadata get voiceMetadata => $_getN(16);
  @$pb.TagNumber(17)
  set voiceMetadata(VoiceMessageMetadata value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasVoiceMetadata() => $_has(16);
  @$pb.TagNumber(17)
  void clearVoiceMetadata() => $_clearField(17);
  @$pb.TagNumber(17)
  VoiceMessageMetadata ensureVoiceMetadata() => $_ensure(16);

  /// Phase 2: Reactions summary (aggregated)
  @$pb.TagNumber(18)
  $pb.PbList<ReactionSummary> get reactionSummaries => $_getList(17);
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
    $core.String? iconMediaId,
    $core.String? description,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (name != null) result.name = name;
    if (creatorUserId != null) result.creatorUserId = creatorUserId;
    if (members != null) result.members.addAll(members);
    if (createdAt != null) result.createdAt = createdAt;
    if (memberCount != null) result.memberCount = memberCount;
    if (lastMessage != null) result.lastMessage = lastMessage;
    if (iconMediaId != null) result.iconMediaId = iconMediaId;
    if (description != null) result.description = description;
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
    ..aOS(8, _omitFieldNames ? '' : 'iconMediaId')
    ..aOS(9, _omitFieldNames ? '' : 'description')
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

  @$pb.TagNumber(8)
  $core.String get iconMediaId => $_getSZ(7);
  @$pb.TagNumber(8)
  set iconMediaId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIconMediaId() => $_has(7);
  @$pb.TagNumber(8)
  void clearIconMediaId() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get description => $_getSZ(8);
  @$pb.TagNumber(9)
  set description($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDescription() => $_has(8);
  @$pb.TagNumber(9)
  void clearDescription() => $_clearField(9);
}

class GroupMemberInfo extends $pb.GeneratedMessage {
  factory GroupMemberInfo({
    $core.String? userId,
    $core.String? username,
    $core.String? deviceId,
    $core.String? role,
    $1.Timestamp? joinedAt,
    $core.String? avatarMediaId,
    $core.String? displayName,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (username != null) result.username = username;
    if (deviceId != null) result.deviceId = deviceId;
    if (role != null) result.role = role;
    if (joinedAt != null) result.joinedAt = joinedAt;
    if (avatarMediaId != null) result.avatarMediaId = avatarMediaId;
    if (displayName != null) result.displayName = displayName;
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
    ..aOS(6, _omitFieldNames ? '' : 'avatarMediaId')
    ..aOS(7, _omitFieldNames ? '' : 'displayName')
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

  @$pb.TagNumber(6)
  $core.String get avatarMediaId => $_getSZ(5);
  @$pb.TagNumber(6)
  set avatarMediaId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAvatarMediaId() => $_has(5);
  @$pb.TagNumber(6)
  void clearAvatarMediaId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get displayName => $_getSZ(6);
  @$pb.TagNumber(7)
  set displayName($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDisplayName() => $_has(6);
  @$pb.TagNumber(7)
  void clearDisplayName() => $_clearField(7);
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

class UpdateGroupRequest extends $pb.GeneratedMessage {
  factory UpdateGroupRequest({
    $core.String? accessToken,
    $core.String? groupId,
    $core.String? name,
    $core.String? iconMediaId,
    $core.String? description,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (groupId != null) result.groupId = groupId;
    if (name != null) result.name = name;
    if (iconMediaId != null) result.iconMediaId = iconMediaId;
    if (description != null) result.description = description;
    return result;
  }

  UpdateGroupRequest._();

  factory UpdateGroupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateGroupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateGroupRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'iconMediaId')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupRequest copyWith(void Function(UpdateGroupRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateGroupRequest))
          as UpdateGroupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGroupRequest create() => UpdateGroupRequest._();
  @$core.override
  UpdateGroupRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateGroupRequest>(create);
  static UpdateGroupRequest? _defaultInstance;

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
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get iconMediaId => $_getSZ(3);
  @$pb.TagNumber(4)
  set iconMediaId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIconMediaId() => $_has(3);
  @$pb.TagNumber(4)
  void clearIconMediaId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);
}

enum UpdateGroupResponse_Result { success, error, notSet }

class UpdateGroupResponse extends $pb.GeneratedMessage {
  factory UpdateGroupResponse({
    UpdateGroupSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  UpdateGroupResponse._();

  factory UpdateGroupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateGroupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, UpdateGroupResponse_Result>
      _UpdateGroupResponse_ResultByTag = {
    1: UpdateGroupResponse_Result.success,
    2: UpdateGroupResponse_Result.error,
    0: UpdateGroupResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateGroupResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<UpdateGroupSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: UpdateGroupSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupResponse copyWith(void Function(UpdateGroupResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateGroupResponse))
          as UpdateGroupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGroupResponse create() => UpdateGroupResponse._();
  @$core.override
  UpdateGroupResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateGroupResponse>(create);
  static UpdateGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  UpdateGroupResponse_Result whichResult() =>
      _UpdateGroupResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  UpdateGroupSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(UpdateGroupSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  UpdateGroupSuccess ensureSuccess() => $_ensure(0);

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

class UpdateGroupSuccess extends $pb.GeneratedMessage {
  factory UpdateGroupSuccess({
    GroupInfo? group,
  }) {
    final result = create();
    if (group != null) result.group = group;
    return result;
  }

  UpdateGroupSuccess._();

  factory UpdateGroupSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateGroupSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateGroupSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOM<GroupInfo>(1, _omitFieldNames ? '' : 'group',
        subBuilder: GroupInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGroupSuccess copyWith(void Function(UpdateGroupSuccess) updates) =>
      super.copyWith((message) => updates(message as UpdateGroupSuccess))
          as UpdateGroupSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGroupSuccess create() => UpdateGroupSuccess._();
  @$core.override
  UpdateGroupSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateGroupSuccess>(create);
  static UpdateGroupSuccess? _defaultInstance;

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

class Reaction extends $pb.GeneratedMessage {
  factory Reaction({
    $core.String? reactionId,
    $core.String? messageId,
    $core.String? userId,
    $core.String? emoji,
    $1.Timestamp? createdAt,
  }) {
    final result = create();
    if (reactionId != null) result.reactionId = reactionId;
    if (messageId != null) result.messageId = messageId;
    if (userId != null) result.userId = userId;
    if (emoji != null) result.emoji = emoji;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  Reaction._();

  factory Reaction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Reaction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Reaction',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'reactionId')
    ..aOS(2, _omitFieldNames ? '' : 'messageId')
    ..aOS(3, _omitFieldNames ? '' : 'userId')
    ..aOS(4, _omitFieldNames ? '' : 'emoji')
    ..aOM<$1.Timestamp>(5, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Reaction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Reaction copyWith(void Function(Reaction) updates) =>
      super.copyWith((message) => updates(message as Reaction)) as Reaction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Reaction create() => Reaction._();
  @$core.override
  Reaction createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Reaction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Reaction>(create);
  static Reaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get reactionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set reactionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReactionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearReactionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get messageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set messageId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get userId => $_getSZ(2);
  @$pb.TagNumber(3)
  set userId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get emoji => $_getSZ(3);
  @$pb.TagNumber(4)
  set emoji($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEmoji() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmoji() => $_clearField(4);

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
}

class AddReactionRequest extends $pb.GeneratedMessage {
  factory AddReactionRequest({
    $core.String? accessToken,
    $core.String? messageId,
    $core.String? conversationId,
    $core.String? emoji,
    $core.bool? isGroup,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (messageId != null) result.messageId = messageId;
    if (conversationId != null) result.conversationId = conversationId;
    if (emoji != null) result.emoji = emoji;
    if (isGroup != null) result.isGroup = isGroup;
    return result;
  }

  AddReactionRequest._();

  factory AddReactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddReactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddReactionRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'messageId')
    ..aOS(3, _omitFieldNames ? '' : 'conversationId')
    ..aOS(4, _omitFieldNames ? '' : 'emoji')
    ..aOB(5, _omitFieldNames ? '' : 'isGroup')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddReactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddReactionRequest copyWith(void Function(AddReactionRequest) updates) =>
      super.copyWith((message) => updates(message as AddReactionRequest))
          as AddReactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddReactionRequest create() => AddReactionRequest._();
  @$core.override
  AddReactionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddReactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddReactionRequest>(create);
  static AddReactionRequest? _defaultInstance;

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
  $core.String get conversationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set conversationId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConversationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversationId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get emoji => $_getSZ(3);
  @$pb.TagNumber(4)
  set emoji($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEmoji() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmoji() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isGroup => $_getBF(4);
  @$pb.TagNumber(5)
  set isGroup($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsGroup() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsGroup() => $_clearField(5);
}

enum AddReactionResponse_Result { success, error, notSet }

class AddReactionResponse extends $pb.GeneratedMessage {
  factory AddReactionResponse({
    AddReactionSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  AddReactionResponse._();

  factory AddReactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddReactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, AddReactionResponse_Result>
      _AddReactionResponse_ResultByTag = {
    1: AddReactionResponse_Result.success,
    2: AddReactionResponse_Result.error,
    0: AddReactionResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddReactionResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<AddReactionSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: AddReactionSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddReactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddReactionResponse copyWith(void Function(AddReactionResponse) updates) =>
      super.copyWith((message) => updates(message as AddReactionResponse))
          as AddReactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddReactionResponse create() => AddReactionResponse._();
  @$core.override
  AddReactionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddReactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddReactionResponse>(create);
  static AddReactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  AddReactionResponse_Result whichResult() =>
      _AddReactionResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  AddReactionSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(AddReactionSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  AddReactionSuccess ensureSuccess() => $_ensure(0);

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

class AddReactionSuccess extends $pb.GeneratedMessage {
  factory AddReactionSuccess({
    Reaction? reaction,
  }) {
    final result = create();
    if (reaction != null) result.reaction = reaction;
    return result;
  }

  AddReactionSuccess._();

  factory AddReactionSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddReactionSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddReactionSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOM<Reaction>(1, _omitFieldNames ? '' : 'reaction',
        subBuilder: Reaction.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddReactionSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddReactionSuccess copyWith(void Function(AddReactionSuccess) updates) =>
      super.copyWith((message) => updates(message as AddReactionSuccess))
          as AddReactionSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddReactionSuccess create() => AddReactionSuccess._();
  @$core.override
  AddReactionSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddReactionSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddReactionSuccess>(create);
  static AddReactionSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  Reaction get reaction => $_getN(0);
  @$pb.TagNumber(1)
  set reaction(Reaction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReaction() => $_has(0);
  @$pb.TagNumber(1)
  void clearReaction() => $_clearField(1);
  @$pb.TagNumber(1)
  Reaction ensureReaction() => $_ensure(0);
}

class RemoveReactionRequest extends $pb.GeneratedMessage {
  factory RemoveReactionRequest({
    $core.String? accessToken,
    $core.String? messageId,
    $core.String? conversationId,
    $core.String? emoji,
    $core.bool? isGroup,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (messageId != null) result.messageId = messageId;
    if (conversationId != null) result.conversationId = conversationId;
    if (emoji != null) result.emoji = emoji;
    if (isGroup != null) result.isGroup = isGroup;
    return result;
  }

  RemoveReactionRequest._();

  factory RemoveReactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveReactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveReactionRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'messageId')
    ..aOS(3, _omitFieldNames ? '' : 'conversationId')
    ..aOS(4, _omitFieldNames ? '' : 'emoji')
    ..aOB(5, _omitFieldNames ? '' : 'isGroup')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveReactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveReactionRequest copyWith(
          void Function(RemoveReactionRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveReactionRequest))
          as RemoveReactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveReactionRequest create() => RemoveReactionRequest._();
  @$core.override
  RemoveReactionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveReactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveReactionRequest>(create);
  static RemoveReactionRequest? _defaultInstance;

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
  $core.String get conversationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set conversationId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConversationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversationId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get emoji => $_getSZ(3);
  @$pb.TagNumber(4)
  set emoji($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEmoji() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmoji() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isGroup => $_getBF(4);
  @$pb.TagNumber(5)
  set isGroup($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsGroup() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsGroup() => $_clearField(5);
}

enum RemoveReactionResponse_Result { success, error, notSet }

class RemoveReactionResponse extends $pb.GeneratedMessage {
  factory RemoveReactionResponse({
    RemoveReactionSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  RemoveReactionResponse._();

  factory RemoveReactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveReactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, RemoveReactionResponse_Result>
      _RemoveReactionResponse_ResultByTag = {
    1: RemoveReactionResponse_Result.success,
    2: RemoveReactionResponse_Result.error,
    0: RemoveReactionResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveReactionResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<RemoveReactionSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: RemoveReactionSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveReactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveReactionResponse copyWith(
          void Function(RemoveReactionResponse) updates) =>
      super.copyWith((message) => updates(message as RemoveReactionResponse))
          as RemoveReactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveReactionResponse create() => RemoveReactionResponse._();
  @$core.override
  RemoveReactionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveReactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveReactionResponse>(create);
  static RemoveReactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  RemoveReactionResponse_Result whichResult() =>
      _RemoveReactionResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  RemoveReactionSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(RemoveReactionSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  RemoveReactionSuccess ensureSuccess() => $_ensure(0);

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

class RemoveReactionSuccess extends $pb.GeneratedMessage {
  factory RemoveReactionSuccess({
    $core.bool? removed,
  }) {
    final result = create();
    if (removed != null) result.removed = removed;
    return result;
  }

  RemoveReactionSuccess._();

  factory RemoveReactionSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveReactionSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveReactionSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'removed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveReactionSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveReactionSuccess copyWith(
          void Function(RemoveReactionSuccess) updates) =>
      super.copyWith((message) => updates(message as RemoveReactionSuccess))
          as RemoveReactionSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveReactionSuccess create() => RemoveReactionSuccess._();
  @$core.override
  RemoveReactionSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveReactionSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveReactionSuccess>(create);
  static RemoveReactionSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get removed => $_getBF(0);
  @$pb.TagNumber(1)
  set removed($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRemoved() => $_has(0);
  @$pb.TagNumber(1)
  void clearRemoved() => $_clearField(1);
}

class GetReactionsRequest extends $pb.GeneratedMessage {
  factory GetReactionsRequest({
    $core.String? accessToken,
    $core.String? messageId,
    $core.String? conversationId,
    $core.bool? isGroup,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (messageId != null) result.messageId = messageId;
    if (conversationId != null) result.conversationId = conversationId;
    if (isGroup != null) result.isGroup = isGroup;
    return result;
  }

  GetReactionsRequest._();

  factory GetReactionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReactionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReactionsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'messageId')
    ..aOS(3, _omitFieldNames ? '' : 'conversationId')
    ..aOB(4, _omitFieldNames ? '' : 'isGroup')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReactionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReactionsRequest copyWith(void Function(GetReactionsRequest) updates) =>
      super.copyWith((message) => updates(message as GetReactionsRequest))
          as GetReactionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReactionsRequest create() => GetReactionsRequest._();
  @$core.override
  GetReactionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReactionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReactionsRequest>(create);
  static GetReactionsRequest? _defaultInstance;

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
  $core.String get conversationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set conversationId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConversationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversationId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isGroup => $_getBF(3);
  @$pb.TagNumber(4)
  set isGroup($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsGroup() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsGroup() => $_clearField(4);
}

enum GetReactionsResponse_Result { success, error, notSet }

class GetReactionsResponse extends $pb.GeneratedMessage {
  factory GetReactionsResponse({
    GetReactionsSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetReactionsResponse._();

  factory GetReactionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReactionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetReactionsResponse_Result>
      _GetReactionsResponse_ResultByTag = {
    1: GetReactionsResponse_Result.success,
    2: GetReactionsResponse_Result.error,
    0: GetReactionsResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReactionsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetReactionsSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: GetReactionsSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReactionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReactionsResponse copyWith(void Function(GetReactionsResponse) updates) =>
      super.copyWith((message) => updates(message as GetReactionsResponse))
          as GetReactionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReactionsResponse create() => GetReactionsResponse._();
  @$core.override
  GetReactionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReactionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReactionsResponse>(create);
  static GetReactionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetReactionsResponse_Result whichResult() =>
      _GetReactionsResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetReactionsSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(GetReactionsSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  GetReactionsSuccess ensureSuccess() => $_ensure(0);

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

class GetReactionsSuccess extends $pb.GeneratedMessage {
  factory GetReactionsSuccess({
    $core.Iterable<Reaction>? reactions,
  }) {
    final result = create();
    if (reactions != null) result.reactions.addAll(reactions);
    return result;
  }

  GetReactionsSuccess._();

  factory GetReactionsSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReactionsSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReactionsSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..pPM<Reaction>(1, _omitFieldNames ? '' : 'reactions',
        subBuilder: Reaction.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReactionsSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReactionsSuccess copyWith(void Function(GetReactionsSuccess) updates) =>
      super.copyWith((message) => updates(message as GetReactionsSuccess))
          as GetReactionsSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReactionsSuccess create() => GetReactionsSuccess._();
  @$core.override
  GetReactionsSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReactionsSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReactionsSuccess>(create);
  static GetReactionsSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Reaction> get reactions => $_getList(0);
}

class ReadReceipt extends $pb.GeneratedMessage {
  factory ReadReceipt({
    $core.String? conversationId,
    $core.String? userId,
    $core.String? lastReadMessageId,
    $1.Timestamp? timestamp,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (userId != null) result.userId = userId;
    if (lastReadMessageId != null) result.lastReadMessageId = lastReadMessageId;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ReadReceipt._();

  factory ReadReceipt.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReadReceipt.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReadReceipt',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'lastReadMessageId')
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadReceipt clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReadReceipt copyWith(void Function(ReadReceipt) updates) =>
      super.copyWith((message) => updates(message as ReadReceipt))
          as ReadReceipt;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReadReceipt create() => ReadReceipt._();
  @$core.override
  ReadReceipt createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReadReceipt getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReadReceipt>(create);
  static ReadReceipt? _defaultInstance;

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
  $core.String get lastReadMessageId => $_getSZ(2);
  @$pb.TagNumber(3)
  set lastReadMessageId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLastReadMessageId() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastReadMessageId() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Timestamp get timestamp => $_getN(3);
  @$pb.TagNumber(4)
  set timestamp($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureTimestamp() => $_ensure(3);
}

class SendReadReceiptRequest extends $pb.GeneratedMessage {
  factory SendReadReceiptRequest({
    $core.String? accessToken,
    $core.String? conversationId,
    $core.String? lastReadMessageId,
    $core.bool? isGroup,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (conversationId != null) result.conversationId = conversationId;
    if (lastReadMessageId != null) result.lastReadMessageId = lastReadMessageId;
    if (isGroup != null) result.isGroup = isGroup;
    return result;
  }

  SendReadReceiptRequest._();

  factory SendReadReceiptRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendReadReceiptRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendReadReceiptRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOS(3, _omitFieldNames ? '' : 'lastReadMessageId')
    ..aOB(4, _omitFieldNames ? '' : 'isGroup')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendReadReceiptRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendReadReceiptRequest copyWith(
          void Function(SendReadReceiptRequest) updates) =>
      super.copyWith((message) => updates(message as SendReadReceiptRequest))
          as SendReadReceiptRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendReadReceiptRequest create() => SendReadReceiptRequest._();
  @$core.override
  SendReadReceiptRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendReadReceiptRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendReadReceiptRequest>(create);
  static SendReadReceiptRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get lastReadMessageId => $_getSZ(2);
  @$pb.TagNumber(3)
  set lastReadMessageId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLastReadMessageId() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastReadMessageId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isGroup => $_getBF(3);
  @$pb.TagNumber(4)
  set isGroup($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsGroup() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsGroup() => $_clearField(4);
}

enum SendReadReceiptResponse_Result { success, error, notSet }

class SendReadReceiptResponse extends $pb.GeneratedMessage {
  factory SendReadReceiptResponse({
    SendReadReceiptSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  SendReadReceiptResponse._();

  factory SendReadReceiptResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendReadReceiptResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SendReadReceiptResponse_Result>
      _SendReadReceiptResponse_ResultByTag = {
    1: SendReadReceiptResponse_Result.success,
    2: SendReadReceiptResponse_Result.error,
    0: SendReadReceiptResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendReadReceiptResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<SendReadReceiptSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: SendReadReceiptSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendReadReceiptResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendReadReceiptResponse copyWith(
          void Function(SendReadReceiptResponse) updates) =>
      super.copyWith((message) => updates(message as SendReadReceiptResponse))
          as SendReadReceiptResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendReadReceiptResponse create() => SendReadReceiptResponse._();
  @$core.override
  SendReadReceiptResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendReadReceiptResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendReadReceiptResponse>(create);
  static SendReadReceiptResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  SendReadReceiptResponse_Result whichResult() =>
      _SendReadReceiptResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SendReadReceiptSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(SendReadReceiptSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  SendReadReceiptSuccess ensureSuccess() => $_ensure(0);

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

class SendReadReceiptSuccess extends $pb.GeneratedMessage {
  factory SendReadReceiptSuccess({
    $1.Timestamp? timestamp,
  }) {
    final result = create();
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  SendReadReceiptSuccess._();

  factory SendReadReceiptSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendReadReceiptSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendReadReceiptSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOM<$1.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendReadReceiptSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendReadReceiptSuccess copyWith(
          void Function(SendReadReceiptSuccess) updates) =>
      super.copyWith((message) => updates(message as SendReadReceiptSuccess))
          as SendReadReceiptSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendReadReceiptSuccess create() => SendReadReceiptSuccess._();
  @$core.override
  SendReadReceiptSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendReadReceiptSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendReadReceiptSuccess>(create);
  static SendReadReceiptSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Timestamp get timestamp => $_getN(0);
  @$pb.TagNumber(1)
  set timestamp($1.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Timestamp ensureTimestamp() => $_ensure(0);
}

class GetReadReceiptsRequest extends $pb.GeneratedMessage {
  factory GetReadReceiptsRequest({
    $core.String? accessToken,
    $core.String? conversationId,
    $core.bool? isGroup,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (conversationId != null) result.conversationId = conversationId;
    if (isGroup != null) result.isGroup = isGroup;
    return result;
  }

  GetReadReceiptsRequest._();

  factory GetReadReceiptsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReadReceiptsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReadReceiptsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOB(3, _omitFieldNames ? '' : 'isGroup')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReadReceiptsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReadReceiptsRequest copyWith(
          void Function(GetReadReceiptsRequest) updates) =>
      super.copyWith((message) => updates(message as GetReadReceiptsRequest))
          as GetReadReceiptsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReadReceiptsRequest create() => GetReadReceiptsRequest._();
  @$core.override
  GetReadReceiptsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReadReceiptsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReadReceiptsRequest>(create);
  static GetReadReceiptsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isGroup => $_getBF(2);
  @$pb.TagNumber(3)
  set isGroup($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsGroup() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsGroup() => $_clearField(3);
}

enum GetReadReceiptsResponse_Result { success, error, notSet }

class GetReadReceiptsResponse extends $pb.GeneratedMessage {
  factory GetReadReceiptsResponse({
    GetReadReceiptsSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetReadReceiptsResponse._();

  factory GetReadReceiptsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReadReceiptsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetReadReceiptsResponse_Result>
      _GetReadReceiptsResponse_ResultByTag = {
    1: GetReadReceiptsResponse_Result.success,
    2: GetReadReceiptsResponse_Result.error,
    0: GetReadReceiptsResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReadReceiptsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetReadReceiptsSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: GetReadReceiptsSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReadReceiptsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReadReceiptsResponse copyWith(
          void Function(GetReadReceiptsResponse) updates) =>
      super.copyWith((message) => updates(message as GetReadReceiptsResponse))
          as GetReadReceiptsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReadReceiptsResponse create() => GetReadReceiptsResponse._();
  @$core.override
  GetReadReceiptsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReadReceiptsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReadReceiptsResponse>(create);
  static GetReadReceiptsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetReadReceiptsResponse_Result whichResult() =>
      _GetReadReceiptsResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetReadReceiptsSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(GetReadReceiptsSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  GetReadReceiptsSuccess ensureSuccess() => $_ensure(0);

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

class GetReadReceiptsSuccess extends $pb.GeneratedMessage {
  factory GetReadReceiptsSuccess({
    $core.Iterable<ReadReceipt>? receipts,
  }) {
    final result = create();
    if (receipts != null) result.receipts.addAll(receipts);
    return result;
  }

  GetReadReceiptsSuccess._();

  factory GetReadReceiptsSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReadReceiptsSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReadReceiptsSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..pPM<ReadReceipt>(1, _omitFieldNames ? '' : 'receipts',
        subBuilder: ReadReceipt.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReadReceiptsSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReadReceiptsSuccess copyWith(
          void Function(GetReadReceiptsSuccess) updates) =>
      super.copyWith((message) => updates(message as GetReadReceiptsSuccess))
          as GetReadReceiptsSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReadReceiptsSuccess create() => GetReadReceiptsSuccess._();
  @$core.override
  GetReadReceiptsSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReadReceiptsSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReadReceiptsSuccess>(create);
  static GetReadReceiptsSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ReadReceipt> get receipts => $_getList(0);
}

/// Thread reference for replies/quotes
class ThreadReference extends $pb.GeneratedMessage {
  factory ThreadReference({
    $core.String? replyToMessageId,
    $core.String? quotedContentHash,
    $core.String? quotedSenderId,
    $core.String? quotedSenderName,
    $core.List<$core.int>? encryptedQuotePreview,
  }) {
    final result = create();
    if (replyToMessageId != null) result.replyToMessageId = replyToMessageId;
    if (quotedContentHash != null) result.quotedContentHash = quotedContentHash;
    if (quotedSenderId != null) result.quotedSenderId = quotedSenderId;
    if (quotedSenderName != null) result.quotedSenderName = quotedSenderName;
    if (encryptedQuotePreview != null)
      result.encryptedQuotePreview = encryptedQuotePreview;
    return result;
  }

  ThreadReference._();

  factory ThreadReference.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ThreadReference.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ThreadReference',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'replyToMessageId')
    ..aOS(2, _omitFieldNames ? '' : 'quotedContentHash')
    ..aOS(3, _omitFieldNames ? '' : 'quotedSenderId')
    ..aOS(4, _omitFieldNames ? '' : 'quotedSenderName')
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'encryptedQuotePreview', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ThreadReference clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ThreadReference copyWith(void Function(ThreadReference) updates) =>
      super.copyWith((message) => updates(message as ThreadReference))
          as ThreadReference;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ThreadReference create() => ThreadReference._();
  @$core.override
  ThreadReference createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ThreadReference getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ThreadReference>(create);
  static ThreadReference? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get replyToMessageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set replyToMessageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReplyToMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearReplyToMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get quotedContentHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set quotedContentHash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuotedContentHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuotedContentHash() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get quotedSenderId => $_getSZ(2);
  @$pb.TagNumber(3)
  set quotedSenderId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuotedSenderId() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuotedSenderId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get quotedSenderName => $_getSZ(3);
  @$pb.TagNumber(4)
  set quotedSenderName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasQuotedSenderName() => $_has(3);
  @$pb.TagNumber(4)
  void clearQuotedSenderName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get encryptedQuotePreview => $_getN(4);
  @$pb.TagNumber(5)
  set encryptedQuotePreview($core.List<$core.int> value) =>
      $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEncryptedQuotePreview() => $_has(4);
  @$pb.TagNumber(5)
  void clearEncryptedQuotePreview() => $_clearField(5);
}

/// Forward metadata
class ForwardInfo extends $pb.GeneratedMessage {
  factory ForwardInfo({
    $core.String? originalMessageId,
    $core.String? originalSenderId,
    $core.String? originalSenderName,
    $1.Timestamp? originalTimestamp,
    $core.int? forwardCount,
  }) {
    final result = create();
    if (originalMessageId != null) result.originalMessageId = originalMessageId;
    if (originalSenderId != null) result.originalSenderId = originalSenderId;
    if (originalSenderName != null)
      result.originalSenderName = originalSenderName;
    if (originalTimestamp != null) result.originalTimestamp = originalTimestamp;
    if (forwardCount != null) result.forwardCount = forwardCount;
    return result;
  }

  ForwardInfo._();

  factory ForwardInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ForwardInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ForwardInfo',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'originalMessageId')
    ..aOS(2, _omitFieldNames ? '' : 'originalSenderId')
    ..aOS(3, _omitFieldNames ? '' : 'originalSenderName')
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'originalTimestamp',
        subBuilder: $1.Timestamp.create)
    ..aI(5, _omitFieldNames ? '' : 'forwardCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardInfo copyWith(void Function(ForwardInfo) updates) =>
      super.copyWith((message) => updates(message as ForwardInfo))
          as ForwardInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForwardInfo create() => ForwardInfo._();
  @$core.override
  ForwardInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ForwardInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ForwardInfo>(create);
  static ForwardInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get originalMessageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set originalMessageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOriginalMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOriginalMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get originalSenderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set originalSenderId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOriginalSenderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOriginalSenderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get originalSenderName => $_getSZ(2);
  @$pb.TagNumber(3)
  set originalSenderName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOriginalSenderName() => $_has(2);
  @$pb.TagNumber(3)
  void clearOriginalSenderName() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Timestamp get originalTimestamp => $_getN(3);
  @$pb.TagNumber(4)
  set originalTimestamp($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasOriginalTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearOriginalTimestamp() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureOriginalTimestamp() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.int get forwardCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set forwardCount($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasForwardCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearForwardCount() => $_clearField(5);
}

class ForwardMessageRequest extends $pb.GeneratedMessage {
  factory ForwardMessageRequest({
    $core.String? accessToken,
    $core.String? sourceMessageId,
    $core.String? sourceConversationId,
    $core.bool? sourceIsGroup,
    $core.String? targetConversationId,
    $core.bool? targetIsGroup,
    $core.String? targetUserId,
    $core.List<$core.int>? encryptedContent,
    $core.String? clientMessageId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (sourceMessageId != null) result.sourceMessageId = sourceMessageId;
    if (sourceConversationId != null)
      result.sourceConversationId = sourceConversationId;
    if (sourceIsGroup != null) result.sourceIsGroup = sourceIsGroup;
    if (targetConversationId != null)
      result.targetConversationId = targetConversationId;
    if (targetIsGroup != null) result.targetIsGroup = targetIsGroup;
    if (targetUserId != null) result.targetUserId = targetUserId;
    if (encryptedContent != null) result.encryptedContent = encryptedContent;
    if (clientMessageId != null) result.clientMessageId = clientMessageId;
    return result;
  }

  ForwardMessageRequest._();

  factory ForwardMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ForwardMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ForwardMessageRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'sourceMessageId')
    ..aOS(3, _omitFieldNames ? '' : 'sourceConversationId')
    ..aOB(4, _omitFieldNames ? '' : 'sourceIsGroup')
    ..aOS(5, _omitFieldNames ? '' : 'targetConversationId')
    ..aOB(6, _omitFieldNames ? '' : 'targetIsGroup')
    ..aOS(7, _omitFieldNames ? '' : 'targetUserId')
    ..a<$core.List<$core.int>>(
        8, _omitFieldNames ? '' : 'encryptedContent', $pb.PbFieldType.OY)
    ..aOS(9, _omitFieldNames ? '' : 'clientMessageId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardMessageRequest copyWith(
          void Function(ForwardMessageRequest) updates) =>
      super.copyWith((message) => updates(message as ForwardMessageRequest))
          as ForwardMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForwardMessageRequest create() => ForwardMessageRequest._();
  @$core.override
  ForwardMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ForwardMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ForwardMessageRequest>(create);
  static ForwardMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sourceMessageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sourceMessageId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSourceMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSourceMessageId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sourceConversationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sourceConversationId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSourceConversationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourceConversationId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get sourceIsGroup => $_getBF(3);
  @$pb.TagNumber(4)
  set sourceIsGroup($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSourceIsGroup() => $_has(3);
  @$pb.TagNumber(4)
  void clearSourceIsGroup() => $_clearField(4);

  /// Target destination
  @$pb.TagNumber(5)
  $core.String get targetConversationId => $_getSZ(4);
  @$pb.TagNumber(5)
  set targetConversationId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTargetConversationId() => $_has(4);
  @$pb.TagNumber(5)
  void clearTargetConversationId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get targetIsGroup => $_getBF(5);
  @$pb.TagNumber(6)
  set targetIsGroup($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTargetIsGroup() => $_has(5);
  @$pb.TagNumber(6)
  void clearTargetIsGroup() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get targetUserId => $_getSZ(6);
  @$pb.TagNumber(7)
  set targetUserId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTargetUserId() => $_has(6);
  @$pb.TagNumber(7)
  void clearTargetUserId() => $_clearField(7);

  /// Re-encrypted content for target
  @$pb.TagNumber(8)
  $core.List<$core.int> get encryptedContent => $_getN(7);
  @$pb.TagNumber(8)
  set encryptedContent($core.List<$core.int> value) => $_setBytes(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEncryptedContent() => $_has(7);
  @$pb.TagNumber(8)
  void clearEncryptedContent() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get clientMessageId => $_getSZ(8);
  @$pb.TagNumber(9)
  set clientMessageId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasClientMessageId() => $_has(8);
  @$pb.TagNumber(9)
  void clearClientMessageId() => $_clearField(9);
}

enum ForwardMessageResponse_Result { success, error, notSet }

class ForwardMessageResponse extends $pb.GeneratedMessage {
  factory ForwardMessageResponse({
    ForwardMessageSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  ForwardMessageResponse._();

  factory ForwardMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ForwardMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ForwardMessageResponse_Result>
      _ForwardMessageResponse_ResultByTag = {
    1: ForwardMessageResponse_Result.success,
    2: ForwardMessageResponse_Result.error,
    0: ForwardMessageResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ForwardMessageResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<ForwardMessageSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: ForwardMessageSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardMessageResponse copyWith(
          void Function(ForwardMessageResponse) updates) =>
      super.copyWith((message) => updates(message as ForwardMessageResponse))
          as ForwardMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForwardMessageResponse create() => ForwardMessageResponse._();
  @$core.override
  ForwardMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ForwardMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ForwardMessageResponse>(create);
  static ForwardMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  ForwardMessageResponse_Result whichResult() =>
      _ForwardMessageResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ForwardMessageSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(ForwardMessageSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  ForwardMessageSuccess ensureSuccess() => $_ensure(0);

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

class ForwardMessageSuccess extends $pb.GeneratedMessage {
  factory ForwardMessageSuccess({
    $core.String? messageId,
    $1.Timestamp? serverTimestamp,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (serverTimestamp != null) result.serverTimestamp = serverTimestamp;
    return result;
  }

  ForwardMessageSuccess._();

  factory ForwardMessageSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ForwardMessageSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ForwardMessageSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOM<$1.Timestamp>(2, _omitFieldNames ? '' : 'serverTimestamp',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardMessageSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ForwardMessageSuccess copyWith(
          void Function(ForwardMessageSuccess) updates) =>
      super.copyWith((message) => updates(message as ForwardMessageSuccess))
          as ForwardMessageSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ForwardMessageSuccess create() => ForwardMessageSuccess._();
  @$core.override
  ForwardMessageSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ForwardMessageSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ForwardMessageSuccess>(create);
  static ForwardMessageSuccess? _defaultInstance;

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

class EditMessageRequest extends $pb.GeneratedMessage {
  factory EditMessageRequest({
    $core.String? accessToken,
    $core.String? messageId,
    $core.String? conversationId,
    $core.bool? isGroup,
    $core.List<$core.int>? encryptedContent,
    $1.Timestamp? clientTimestamp,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (messageId != null) result.messageId = messageId;
    if (conversationId != null) result.conversationId = conversationId;
    if (isGroup != null) result.isGroup = isGroup;
    if (encryptedContent != null) result.encryptedContent = encryptedContent;
    if (clientTimestamp != null) result.clientTimestamp = clientTimestamp;
    return result;
  }

  EditMessageRequest._();

  factory EditMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EditMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EditMessageRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'messageId')
    ..aOS(3, _omitFieldNames ? '' : 'conversationId')
    ..aOB(4, _omitFieldNames ? '' : 'isGroup')
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'encryptedContent', $pb.PbFieldType.OY)
    ..aOM<$1.Timestamp>(6, _omitFieldNames ? '' : 'clientTimestamp',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EditMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EditMessageRequest copyWith(void Function(EditMessageRequest) updates) =>
      super.copyWith((message) => updates(message as EditMessageRequest))
          as EditMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EditMessageRequest create() => EditMessageRequest._();
  @$core.override
  EditMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EditMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EditMessageRequest>(create);
  static EditMessageRequest? _defaultInstance;

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
  $core.String get conversationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set conversationId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConversationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversationId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isGroup => $_getBF(3);
  @$pb.TagNumber(4)
  set isGroup($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsGroup() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsGroup() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get encryptedContent => $_getN(4);
  @$pb.TagNumber(5)
  set encryptedContent($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEncryptedContent() => $_has(4);
  @$pb.TagNumber(5)
  void clearEncryptedContent() => $_clearField(5);

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
}

enum EditMessageResponse_Result { success, error, notSet }

class EditMessageResponse extends $pb.GeneratedMessage {
  factory EditMessageResponse({
    EditMessageSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  EditMessageResponse._();

  factory EditMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EditMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, EditMessageResponse_Result>
      _EditMessageResponse_ResultByTag = {
    1: EditMessageResponse_Result.success,
    2: EditMessageResponse_Result.error,
    0: EditMessageResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EditMessageResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<EditMessageSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: EditMessageSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EditMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EditMessageResponse copyWith(void Function(EditMessageResponse) updates) =>
      super.copyWith((message) => updates(message as EditMessageResponse))
          as EditMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EditMessageResponse create() => EditMessageResponse._();
  @$core.override
  EditMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EditMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EditMessageResponse>(create);
  static EditMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  EditMessageResponse_Result whichResult() =>
      _EditMessageResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  EditMessageSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(EditMessageSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  EditMessageSuccess ensureSuccess() => $_ensure(0);

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

class EditMessageSuccess extends $pb.GeneratedMessage {
  factory EditMessageSuccess({
    $core.String? messageId,
    $core.int? editVersion,
    $1.Timestamp? serverTimestamp,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (editVersion != null) result.editVersion = editVersion;
    if (serverTimestamp != null) result.serverTimestamp = serverTimestamp;
    return result;
  }

  EditMessageSuccess._();

  factory EditMessageSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EditMessageSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EditMessageSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aI(2, _omitFieldNames ? '' : 'editVersion')
    ..aOM<$1.Timestamp>(3, _omitFieldNames ? '' : 'serverTimestamp',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EditMessageSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EditMessageSuccess copyWith(void Function(EditMessageSuccess) updates) =>
      super.copyWith((message) => updates(message as EditMessageSuccess))
          as EditMessageSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EditMessageSuccess create() => EditMessageSuccess._();
  @$core.override
  EditMessageSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EditMessageSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EditMessageSuccess>(create);
  static EditMessageSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get editVersion => $_getIZ(1);
  @$pb.TagNumber(2)
  set editVersion($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEditVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearEditVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.Timestamp get serverTimestamp => $_getN(2);
  @$pb.TagNumber(3)
  set serverTimestamp($1.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasServerTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearServerTimestamp() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Timestamp ensureServerTimestamp() => $_ensure(2);
}

class MessageEdit extends $pb.GeneratedMessage {
  factory MessageEdit({
    $core.String? messageId,
    $core.List<$core.int>? encryptedContent,
    $core.int? editVersion,
    $1.Timestamp? editTimestamp,
    $core.String? editedBy,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (encryptedContent != null) result.encryptedContent = encryptedContent;
    if (editVersion != null) result.editVersion = editVersion;
    if (editTimestamp != null) result.editTimestamp = editTimestamp;
    if (editedBy != null) result.editedBy = editedBy;
    return result;
  }

  MessageEdit._();

  factory MessageEdit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageEdit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageEdit',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'encryptedContent', $pb.PbFieldType.OY)
    ..aI(3, _omitFieldNames ? '' : 'editVersion')
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'editTimestamp',
        subBuilder: $1.Timestamp.create)
    ..aOS(5, _omitFieldNames ? '' : 'editedBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageEdit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageEdit copyWith(void Function(MessageEdit) updates) =>
      super.copyWith((message) => updates(message as MessageEdit))
          as MessageEdit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageEdit create() => MessageEdit._();
  @$core.override
  MessageEdit createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageEdit getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageEdit>(create);
  static MessageEdit? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get encryptedContent => $_getN(1);
  @$pb.TagNumber(2)
  set encryptedContent($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEncryptedContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptedContent() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get editVersion => $_getIZ(2);
  @$pb.TagNumber(3)
  set editVersion($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEditVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearEditVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Timestamp get editTimestamp => $_getN(3);
  @$pb.TagNumber(4)
  set editTimestamp($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasEditTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearEditTimestamp() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureEditTimestamp() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.String get editedBy => $_getSZ(4);
  @$pb.TagNumber(5)
  set editedBy($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEditedBy() => $_has(4);
  @$pb.TagNumber(5)
  void clearEditedBy() => $_clearField(5);
}

class VoiceMessageMetadata extends $pb.GeneratedMessage {
  factory VoiceMessageMetadata({
    $core.String? mediaId,
    $core.int? durationMs,
    $core.List<$core.int>? waveform,
    $core.String? codec,
    $core.int? sampleRate,
    $core.int? bitrate,
  }) {
    final result = create();
    if (mediaId != null) result.mediaId = mediaId;
    if (durationMs != null) result.durationMs = durationMs;
    if (waveform != null) result.waveform = waveform;
    if (codec != null) result.codec = codec;
    if (sampleRate != null) result.sampleRate = sampleRate;
    if (bitrate != null) result.bitrate = bitrate;
    return result;
  }

  VoiceMessageMetadata._();

  factory VoiceMessageMetadata.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VoiceMessageMetadata.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VoiceMessageMetadata',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mediaId')
    ..aI(2, _omitFieldNames ? '' : 'durationMs')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'waveform', $pb.PbFieldType.OY)
    ..aOS(4, _omitFieldNames ? '' : 'codec')
    ..aI(5, _omitFieldNames ? '' : 'sampleRate')
    ..aI(6, _omitFieldNames ? '' : 'bitrate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoiceMessageMetadata clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoiceMessageMetadata copyWith(void Function(VoiceMessageMetadata) updates) =>
      super.copyWith((message) => updates(message as VoiceMessageMetadata))
          as VoiceMessageMetadata;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoiceMessageMetadata create() => VoiceMessageMetadata._();
  @$core.override
  VoiceMessageMetadata createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VoiceMessageMetadata getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VoiceMessageMetadata>(create);
  static VoiceMessageMetadata? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mediaId => $_getSZ(0);
  @$pb.TagNumber(1)
  set mediaId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMediaId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMediaId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get durationMs => $_getIZ(1);
  @$pb.TagNumber(2)
  set durationMs($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDurationMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearDurationMs() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get waveform => $_getN(2);
  @$pb.TagNumber(3)
  set waveform($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWaveform() => $_has(2);
  @$pb.TagNumber(3)
  void clearWaveform() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get codec => $_getSZ(3);
  @$pb.TagNumber(4)
  set codec($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCodec() => $_has(3);
  @$pb.TagNumber(4)
  void clearCodec() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get sampleRate => $_getIZ(4);
  @$pb.TagNumber(5)
  set sampleRate($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSampleRate() => $_has(4);
  @$pb.TagNumber(5)
  void clearSampleRate() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get bitrate => $_getIZ(5);
  @$pb.TagNumber(6)
  set bitrate($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBitrate() => $_has(5);
  @$pb.TagNumber(6)
  void clearBitrate() => $_clearField(6);
}

class SearchMessagesRequest extends $pb.GeneratedMessage {
  factory SearchMessagesRequest({
    $core.String? accessToken,
    $core.String? query,
    $core.String? conversationId,
    $core.bool? isGroup,
    $1.Timestamp? startTime,
    $1.Timestamp? endTime,
    $core.Iterable<MessageType>? messageTypes,
    $core.int? limit,
    $core.String? cursor,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (query != null) result.query = query;
    if (conversationId != null) result.conversationId = conversationId;
    if (isGroup != null) result.isGroup = isGroup;
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    if (messageTypes != null) result.messageTypes.addAll(messageTypes);
    if (limit != null) result.limit = limit;
    if (cursor != null) result.cursor = cursor;
    return result;
  }

  SearchMessagesRequest._();

  factory SearchMessagesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchMessagesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchMessagesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'query')
    ..aOS(3, _omitFieldNames ? '' : 'conversationId')
    ..aOB(4, _omitFieldNames ? '' : 'isGroup')
    ..aOM<$1.Timestamp>(5, _omitFieldNames ? '' : 'startTime',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(6, _omitFieldNames ? '' : 'endTime',
        subBuilder: $1.Timestamp.create)
    ..pc<MessageType>(
        7, _omitFieldNames ? '' : 'messageTypes', $pb.PbFieldType.KE,
        valueOf: MessageType.valueOf,
        enumValues: MessageType.values,
        defaultEnumValue: MessageType.TEXT)
    ..aI(8, _omitFieldNames ? '' : 'limit')
    ..aOS(9, _omitFieldNames ? '' : 'cursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchMessagesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchMessagesRequest copyWith(
          void Function(SearchMessagesRequest) updates) =>
      super.copyWith((message) => updates(message as SearchMessagesRequest))
          as SearchMessagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchMessagesRequest create() => SearchMessagesRequest._();
  @$core.override
  SearchMessagesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchMessagesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchMessagesRequest>(create);
  static SearchMessagesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get query => $_getSZ(1);
  @$pb.TagNumber(2)
  set query($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuery() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuery() => $_clearField(2);

  /// Filter options
  @$pb.TagNumber(3)
  $core.String get conversationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set conversationId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConversationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversationId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isGroup => $_getBF(3);
  @$pb.TagNumber(4)
  set isGroup($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsGroup() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsGroup() => $_clearField(4);

  @$pb.TagNumber(5)
  $1.Timestamp get startTime => $_getN(4);
  @$pb.TagNumber(5)
  set startTime($1.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStartTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearStartTime() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.Timestamp ensureStartTime() => $_ensure(4);

  @$pb.TagNumber(6)
  $1.Timestamp get endTime => $_getN(5);
  @$pb.TagNumber(6)
  set endTime($1.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasEndTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearEndTime() => $_clearField(6);
  @$pb.TagNumber(6)
  $1.Timestamp ensureEndTime() => $_ensure(5);

  @$pb.TagNumber(7)
  $pb.PbList<MessageType> get messageTypes => $_getList(6);

  /// Pagination
  @$pb.TagNumber(8)
  $core.int get limit => $_getIZ(7);
  @$pb.TagNumber(8)
  set limit($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLimit() => $_has(7);
  @$pb.TagNumber(8)
  void clearLimit() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get cursor => $_getSZ(8);
  @$pb.TagNumber(9)
  set cursor($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCursor() => $_has(8);
  @$pb.TagNumber(9)
  void clearCursor() => $_clearField(9);
}

enum SearchMessagesResponse_Result { success, error, notSet }

class SearchMessagesResponse extends $pb.GeneratedMessage {
  factory SearchMessagesResponse({
    SearchMessagesSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  SearchMessagesResponse._();

  factory SearchMessagesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchMessagesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SearchMessagesResponse_Result>
      _SearchMessagesResponse_ResultByTag = {
    1: SearchMessagesResponse_Result.success,
    2: SearchMessagesResponse_Result.error,
    0: SearchMessagesResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchMessagesResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<SearchMessagesSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: SearchMessagesSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchMessagesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchMessagesResponse copyWith(
          void Function(SearchMessagesResponse) updates) =>
      super.copyWith((message) => updates(message as SearchMessagesResponse))
          as SearchMessagesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchMessagesResponse create() => SearchMessagesResponse._();
  @$core.override
  SearchMessagesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchMessagesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchMessagesResponse>(create);
  static SearchMessagesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  SearchMessagesResponse_Result whichResult() =>
      _SearchMessagesResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SearchMessagesSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(SearchMessagesSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  SearchMessagesSuccess ensureSuccess() => $_ensure(0);

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

class SearchMessagesSuccess extends $pb.GeneratedMessage {
  factory SearchMessagesSuccess({
    $core.Iterable<SearchResult>? results,
    $core.String? nextCursor,
    $core.bool? hasMore,
    $core.int? totalCount,
  }) {
    final result = create();
    if (results != null) result.results.addAll(results);
    if (nextCursor != null) result.nextCursor = nextCursor;
    if (hasMore != null) result.hasMore = hasMore;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  SearchMessagesSuccess._();

  factory SearchMessagesSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchMessagesSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchMessagesSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..pPM<SearchResult>(1, _omitFieldNames ? '' : 'results',
        subBuilder: SearchResult.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextCursor')
    ..aOB(3, _omitFieldNames ? '' : 'hasMore')
    ..aI(4, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchMessagesSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchMessagesSuccess copyWith(
          void Function(SearchMessagesSuccess) updates) =>
      super.copyWith((message) => updates(message as SearchMessagesSuccess))
          as SearchMessagesSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchMessagesSuccess create() => SearchMessagesSuccess._();
  @$core.override
  SearchMessagesSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchMessagesSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchMessagesSuccess>(create);
  static SearchMessagesSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SearchResult> get results => $_getList(0);

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

  @$pb.TagNumber(4)
  $core.int get totalCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set totalCount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalCount() => $_clearField(4);
}

class SearchResult extends $pb.GeneratedMessage {
  factory SearchResult({
    $core.String? messageId,
    $core.String? conversationId,
    $core.bool? isGroup,
    $core.String? senderUserId,
    $core.List<$core.int>? encryptedContent,
    $1.Timestamp? serverTimestamp,
    MessageType? messageType,
    $core.String? conversationName,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (conversationId != null) result.conversationId = conversationId;
    if (isGroup != null) result.isGroup = isGroup;
    if (senderUserId != null) result.senderUserId = senderUserId;
    if (encryptedContent != null) result.encryptedContent = encryptedContent;
    if (serverTimestamp != null) result.serverTimestamp = serverTimestamp;
    if (messageType != null) result.messageType = messageType;
    if (conversationName != null) result.conversationName = conversationName;
    return result;
  }

  SearchResult._();

  factory SearchResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchResult',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOB(3, _omitFieldNames ? '' : 'isGroup')
    ..aOS(4, _omitFieldNames ? '' : 'senderUserId')
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'encryptedContent', $pb.PbFieldType.OY)
    ..aOM<$1.Timestamp>(6, _omitFieldNames ? '' : 'serverTimestamp',
        subBuilder: $1.Timestamp.create)
    ..aE<MessageType>(7, _omitFieldNames ? '' : 'messageType',
        enumValues: MessageType.values)
    ..aOS(8, _omitFieldNames ? '' : 'conversationName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchResult copyWith(void Function(SearchResult) updates) =>
      super.copyWith((message) => updates(message as SearchResult))
          as SearchResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchResult create() => SearchResult._();
  @$core.override
  SearchResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchResult>(create);
  static SearchResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isGroup => $_getBF(2);
  @$pb.TagNumber(3)
  set isGroup($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsGroup() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsGroup() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get senderUserId => $_getSZ(3);
  @$pb.TagNumber(4)
  set senderUserId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSenderUserId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSenderUserId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get encryptedContent => $_getN(4);
  @$pb.TagNumber(5)
  set encryptedContent($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEncryptedContent() => $_has(4);
  @$pb.TagNumber(5)
  void clearEncryptedContent() => $_clearField(5);

  @$pb.TagNumber(6)
  $1.Timestamp get serverTimestamp => $_getN(5);
  @$pb.TagNumber(6)
  set serverTimestamp($1.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasServerTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearServerTimestamp() => $_clearField(6);
  @$pb.TagNumber(6)
  $1.Timestamp ensureServerTimestamp() => $_ensure(5);

  @$pb.TagNumber(7)
  MessageType get messageType => $_getN(6);
  @$pb.TagNumber(7)
  set messageType(MessageType value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasMessageType() => $_has(6);
  @$pb.TagNumber(7)
  void clearMessageType() => $_clearField(7);

  /// Context for search highlighting (client will decrypt and highlight)
  @$pb.TagNumber(8)
  $core.String get conversationName => $_getSZ(7);
  @$pb.TagNumber(8)
  set conversationName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasConversationName() => $_has(7);
  @$pb.TagNumber(8)
  void clearConversationName() => $_clearField(8);
}

class DisappearingConfig extends $pb.GeneratedMessage {
  factory DisappearingConfig({
    $core.String? conversationId,
    $core.int? ttlSeconds,
    $core.String? setByUserId,
    $1.Timestamp? updatedAt,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (ttlSeconds != null) result.ttlSeconds = ttlSeconds;
    if (setByUserId != null) result.setByUserId = setByUserId;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  DisappearingConfig._();

  factory DisappearingConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DisappearingConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DisappearingConfig',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aI(2, _omitFieldNames ? '' : 'ttlSeconds')
    ..aOS(3, _omitFieldNames ? '' : 'setByUserId')
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisappearingConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisappearingConfig copyWith(void Function(DisappearingConfig) updates) =>
      super.copyWith((message) => updates(message as DisappearingConfig))
          as DisappearingConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisappearingConfig create() => DisappearingConfig._();
  @$core.override
  DisappearingConfig createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DisappearingConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DisappearingConfig>(create);
  static DisappearingConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get ttlSeconds => $_getIZ(1);
  @$pb.TagNumber(2)
  set ttlSeconds($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTtlSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearTtlSeconds() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get setByUserId => $_getSZ(2);
  @$pb.TagNumber(3)
  set setByUserId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSetByUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSetByUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Timestamp get updatedAt => $_getN(3);
  @$pb.TagNumber(4)
  set updatedAt($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasUpdatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearUpdatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureUpdatedAt() => $_ensure(3);
}

class SetDisappearingMessagesRequest extends $pb.GeneratedMessage {
  factory SetDisappearingMessagesRequest({
    $core.String? accessToken,
    $core.String? conversationId,
    $core.bool? isGroup,
    $core.int? ttlSeconds,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (conversationId != null) result.conversationId = conversationId;
    if (isGroup != null) result.isGroup = isGroup;
    if (ttlSeconds != null) result.ttlSeconds = ttlSeconds;
    return result;
  }

  SetDisappearingMessagesRequest._();

  factory SetDisappearingMessagesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetDisappearingMessagesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetDisappearingMessagesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOB(3, _omitFieldNames ? '' : 'isGroup')
    ..aI(4, _omitFieldNames ? '' : 'ttlSeconds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetDisappearingMessagesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetDisappearingMessagesRequest copyWith(
          void Function(SetDisappearingMessagesRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SetDisappearingMessagesRequest))
          as SetDisappearingMessagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetDisappearingMessagesRequest create() =>
      SetDisappearingMessagesRequest._();
  @$core.override
  SetDisappearingMessagesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetDisappearingMessagesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetDisappearingMessagesRequest>(create);
  static SetDisappearingMessagesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isGroup => $_getBF(2);
  @$pb.TagNumber(3)
  set isGroup($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsGroup() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsGroup() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get ttlSeconds => $_getIZ(3);
  @$pb.TagNumber(4)
  set ttlSeconds($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTtlSeconds() => $_has(3);
  @$pb.TagNumber(4)
  void clearTtlSeconds() => $_clearField(4);
}

enum SetDisappearingMessagesResponse_Result { success, error, notSet }

class SetDisappearingMessagesResponse extends $pb.GeneratedMessage {
  factory SetDisappearingMessagesResponse({
    SetDisappearingMessagesSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  SetDisappearingMessagesResponse._();

  factory SetDisappearingMessagesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetDisappearingMessagesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SetDisappearingMessagesResponse_Result>
      _SetDisappearingMessagesResponse_ResultByTag = {
    1: SetDisappearingMessagesResponse_Result.success,
    2: SetDisappearingMessagesResponse_Result.error,
    0: SetDisappearingMessagesResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetDisappearingMessagesResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<SetDisappearingMessagesSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: SetDisappearingMessagesSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetDisappearingMessagesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetDisappearingMessagesResponse copyWith(
          void Function(SetDisappearingMessagesResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SetDisappearingMessagesResponse))
          as SetDisappearingMessagesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetDisappearingMessagesResponse create() =>
      SetDisappearingMessagesResponse._();
  @$core.override
  SetDisappearingMessagesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetDisappearingMessagesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetDisappearingMessagesResponse>(
          create);
  static SetDisappearingMessagesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  SetDisappearingMessagesResponse_Result whichResult() =>
      _SetDisappearingMessagesResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SetDisappearingMessagesSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(SetDisappearingMessagesSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  SetDisappearingMessagesSuccess ensureSuccess() => $_ensure(0);

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

class SetDisappearingMessagesSuccess extends $pb.GeneratedMessage {
  factory SetDisappearingMessagesSuccess({
    DisappearingConfig? config,
  }) {
    final result = create();
    if (config != null) result.config = config;
    return result;
  }

  SetDisappearingMessagesSuccess._();

  factory SetDisappearingMessagesSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetDisappearingMessagesSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetDisappearingMessagesSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOM<DisappearingConfig>(1, _omitFieldNames ? '' : 'config',
        subBuilder: DisappearingConfig.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetDisappearingMessagesSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetDisappearingMessagesSuccess copyWith(
          void Function(SetDisappearingMessagesSuccess) updates) =>
      super.copyWith(
              (message) => updates(message as SetDisappearingMessagesSuccess))
          as SetDisappearingMessagesSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetDisappearingMessagesSuccess create() =>
      SetDisappearingMessagesSuccess._();
  @$core.override
  SetDisappearingMessagesSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetDisappearingMessagesSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetDisappearingMessagesSuccess>(create);
  static SetDisappearingMessagesSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  DisappearingConfig get config => $_getN(0);
  @$pb.TagNumber(1)
  set config(DisappearingConfig value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasConfig() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfig() => $_clearField(1);
  @$pb.TagNumber(1)
  DisappearingConfig ensureConfig() => $_ensure(0);
}

class GetDisappearingConfigRequest extends $pb.GeneratedMessage {
  factory GetDisappearingConfigRequest({
    $core.String? accessToken,
    $core.String? conversationId,
    $core.bool? isGroup,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (conversationId != null) result.conversationId = conversationId;
    if (isGroup != null) result.isGroup = isGroup;
    return result;
  }

  GetDisappearingConfigRequest._();

  factory GetDisappearingConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDisappearingConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDisappearingConfigRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOB(3, _omitFieldNames ? '' : 'isGroup')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDisappearingConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDisappearingConfigRequest copyWith(
          void Function(GetDisappearingConfigRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetDisappearingConfigRequest))
          as GetDisappearingConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDisappearingConfigRequest create() =>
      GetDisappearingConfigRequest._();
  @$core.override
  GetDisappearingConfigRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDisappearingConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDisappearingConfigRequest>(create);
  static GetDisappearingConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isGroup => $_getBF(2);
  @$pb.TagNumber(3)
  set isGroup($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsGroup() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsGroup() => $_clearField(3);
}

enum GetDisappearingConfigResponse_Result { success, error, notSet }

class GetDisappearingConfigResponse extends $pb.GeneratedMessage {
  factory GetDisappearingConfigResponse({
    GetDisappearingConfigSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetDisappearingConfigResponse._();

  factory GetDisappearingConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDisappearingConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetDisappearingConfigResponse_Result>
      _GetDisappearingConfigResponse_ResultByTag = {
    1: GetDisappearingConfigResponse_Result.success,
    2: GetDisappearingConfigResponse_Result.error,
    0: GetDisappearingConfigResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDisappearingConfigResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetDisappearingConfigSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: GetDisappearingConfigSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDisappearingConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDisappearingConfigResponse copyWith(
          void Function(GetDisappearingConfigResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetDisappearingConfigResponse))
          as GetDisappearingConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDisappearingConfigResponse create() =>
      GetDisappearingConfigResponse._();
  @$core.override
  GetDisappearingConfigResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDisappearingConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDisappearingConfigResponse>(create);
  static GetDisappearingConfigResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetDisappearingConfigResponse_Result whichResult() =>
      _GetDisappearingConfigResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetDisappearingConfigSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(GetDisappearingConfigSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  GetDisappearingConfigSuccess ensureSuccess() => $_ensure(0);

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

class GetDisappearingConfigSuccess extends $pb.GeneratedMessage {
  factory GetDisappearingConfigSuccess({
    DisappearingConfig? config,
  }) {
    final result = create();
    if (config != null) result.config = config;
    return result;
  }

  GetDisappearingConfigSuccess._();

  factory GetDisappearingConfigSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDisappearingConfigSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDisappearingConfigSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOM<DisappearingConfig>(1, _omitFieldNames ? '' : 'config',
        subBuilder: DisappearingConfig.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDisappearingConfigSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDisappearingConfigSuccess copyWith(
          void Function(GetDisappearingConfigSuccess) updates) =>
      super.copyWith(
              (message) => updates(message as GetDisappearingConfigSuccess))
          as GetDisappearingConfigSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDisappearingConfigSuccess create() =>
      GetDisappearingConfigSuccess._();
  @$core.override
  GetDisappearingConfigSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDisappearingConfigSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDisappearingConfigSuccess>(create);
  static GetDisappearingConfigSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  DisappearingConfig get config => $_getN(0);
  @$pb.TagNumber(1)
  set config(DisappearingConfig value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasConfig() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfig() => $_clearField(1);
  @$pb.TagNumber(1)
  DisappearingConfig ensureConfig() => $_ensure(0);
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

class BlockUserRequest extends $pb.GeneratedMessage {
  factory BlockUserRequest({
    $core.String? accessToken,
    $core.String? blockedUserId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (blockedUserId != null) result.blockedUserId = blockedUserId;
    return result;
  }

  BlockUserRequest._();

  factory BlockUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockUserRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'blockedUserId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockUserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockUserRequest copyWith(void Function(BlockUserRequest) updates) =>
      super.copyWith((message) => updates(message as BlockUserRequest))
          as BlockUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockUserRequest create() => BlockUserRequest._();
  @$core.override
  BlockUserRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockUserRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockUserRequest>(create);
  static BlockUserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get blockedUserId => $_getSZ(1);
  @$pb.TagNumber(2)
  set blockedUserId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockedUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockedUserId() => $_clearField(2);
}

enum BlockUserResponse_Result { success, error, notSet }

class BlockUserResponse extends $pb.GeneratedMessage {
  factory BlockUserResponse({
    BlockUserSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  BlockUserResponse._();

  factory BlockUserResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockUserResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, BlockUserResponse_Result>
      _BlockUserResponse_ResultByTag = {
    1: BlockUserResponse_Result.success,
    2: BlockUserResponse_Result.error,
    0: BlockUserResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockUserResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<BlockUserSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: BlockUserSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockUserResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockUserResponse copyWith(void Function(BlockUserResponse) updates) =>
      super.copyWith((message) => updates(message as BlockUserResponse))
          as BlockUserResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockUserResponse create() => BlockUserResponse._();
  @$core.override
  BlockUserResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockUserResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockUserResponse>(create);
  static BlockUserResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  BlockUserResponse_Result whichResult() =>
      _BlockUserResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  BlockUserSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(BlockUserSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  BlockUserSuccess ensureSuccess() => $_ensure(0);

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

class BlockUserSuccess extends $pb.GeneratedMessage {
  factory BlockUserSuccess({
    $core.String? blockedUserId,
    $1.Timestamp? blockedAt,
  }) {
    final result = create();
    if (blockedUserId != null) result.blockedUserId = blockedUserId;
    if (blockedAt != null) result.blockedAt = blockedAt;
    return result;
  }

  BlockUserSuccess._();

  factory BlockUserSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockUserSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockUserSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'blockedUserId')
    ..aOM<$1.Timestamp>(2, _omitFieldNames ? '' : 'blockedAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockUserSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockUserSuccess copyWith(void Function(BlockUserSuccess) updates) =>
      super.copyWith((message) => updates(message as BlockUserSuccess))
          as BlockUserSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockUserSuccess create() => BlockUserSuccess._();
  @$core.override
  BlockUserSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockUserSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockUserSuccess>(create);
  static BlockUserSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get blockedUserId => $_getSZ(0);
  @$pb.TagNumber(1)
  set blockedUserId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockedUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockedUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Timestamp get blockedAt => $_getN(1);
  @$pb.TagNumber(2)
  set blockedAt($1.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockedAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockedAt() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Timestamp ensureBlockedAt() => $_ensure(1);
}

class UnblockUserRequest extends $pb.GeneratedMessage {
  factory UnblockUserRequest({
    $core.String? accessToken,
    $core.String? userId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (userId != null) result.userId = userId;
    return result;
  }

  UnblockUserRequest._();

  factory UnblockUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnblockUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnblockUserRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnblockUserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnblockUserRequest copyWith(void Function(UnblockUserRequest) updates) =>
      super.copyWith((message) => updates(message as UnblockUserRequest))
          as UnblockUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnblockUserRequest create() => UnblockUserRequest._();
  @$core.override
  UnblockUserRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnblockUserRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnblockUserRequest>(create);
  static UnblockUserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);
}

enum UnblockUserResponse_Result { success, error, notSet }

class UnblockUserResponse extends $pb.GeneratedMessage {
  factory UnblockUserResponse({
    UnblockUserSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  UnblockUserResponse._();

  factory UnblockUserResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnblockUserResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, UnblockUserResponse_Result>
      _UnblockUserResponse_ResultByTag = {
    1: UnblockUserResponse_Result.success,
    2: UnblockUserResponse_Result.error,
    0: UnblockUserResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnblockUserResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<UnblockUserSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: UnblockUserSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnblockUserResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnblockUserResponse copyWith(void Function(UnblockUserResponse) updates) =>
      super.copyWith((message) => updates(message as UnblockUserResponse))
          as UnblockUserResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnblockUserResponse create() => UnblockUserResponse._();
  @$core.override
  UnblockUserResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnblockUserResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnblockUserResponse>(create);
  static UnblockUserResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  UnblockUserResponse_Result whichResult() =>
      _UnblockUserResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  UnblockUserSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(UnblockUserSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  UnblockUserSuccess ensureSuccess() => $_ensure(0);

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

class UnblockUserSuccess extends $pb.GeneratedMessage {
  factory UnblockUserSuccess({
    $core.String? userId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    return result;
  }

  UnblockUserSuccess._();

  factory UnblockUserSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnblockUserSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnblockUserSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnblockUserSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnblockUserSuccess copyWith(void Function(UnblockUserSuccess) updates) =>
      super.copyWith((message) => updates(message as UnblockUserSuccess))
          as UnblockUserSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnblockUserSuccess create() => UnblockUserSuccess._();
  @$core.override
  UnblockUserSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnblockUserSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnblockUserSuccess>(create);
  static UnblockUserSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
}

class GetBlockedUsersRequest extends $pb.GeneratedMessage {
  factory GetBlockedUsersRequest({
    $core.String? accessToken,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    return result;
  }

  GetBlockedUsersRequest._();

  factory GetBlockedUsersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBlockedUsersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBlockedUsersRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockedUsersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockedUsersRequest copyWith(
          void Function(GetBlockedUsersRequest) updates) =>
      super.copyWith((message) => updates(message as GetBlockedUsersRequest))
          as GetBlockedUsersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockedUsersRequest create() => GetBlockedUsersRequest._();
  @$core.override
  GetBlockedUsersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetBlockedUsersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockedUsersRequest>(create);
  static GetBlockedUsersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);
}

enum GetBlockedUsersResponse_Result { success, error, notSet }

class GetBlockedUsersResponse extends $pb.GeneratedMessage {
  factory GetBlockedUsersResponse({
    GetBlockedUsersSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetBlockedUsersResponse._();

  factory GetBlockedUsersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBlockedUsersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetBlockedUsersResponse_Result>
      _GetBlockedUsersResponse_ResultByTag = {
    1: GetBlockedUsersResponse_Result.success,
    2: GetBlockedUsersResponse_Result.error,
    0: GetBlockedUsersResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBlockedUsersResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetBlockedUsersSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: GetBlockedUsersSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockedUsersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockedUsersResponse copyWith(
          void Function(GetBlockedUsersResponse) updates) =>
      super.copyWith((message) => updates(message as GetBlockedUsersResponse))
          as GetBlockedUsersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockedUsersResponse create() => GetBlockedUsersResponse._();
  @$core.override
  GetBlockedUsersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetBlockedUsersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockedUsersResponse>(create);
  static GetBlockedUsersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetBlockedUsersResponse_Result whichResult() =>
      _GetBlockedUsersResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetBlockedUsersSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(GetBlockedUsersSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  GetBlockedUsersSuccess ensureSuccess() => $_ensure(0);

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

class GetBlockedUsersSuccess extends $pb.GeneratedMessage {
  factory GetBlockedUsersSuccess({
    $core.Iterable<BlockedUser>? blockedUsers,
  }) {
    final result = create();
    if (blockedUsers != null) result.blockedUsers.addAll(blockedUsers);
    return result;
  }

  GetBlockedUsersSuccess._();

  factory GetBlockedUsersSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBlockedUsersSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBlockedUsersSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..pPM<BlockedUser>(1, _omitFieldNames ? '' : 'blockedUsers',
        subBuilder: BlockedUser.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockedUsersSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockedUsersSuccess copyWith(
          void Function(GetBlockedUsersSuccess) updates) =>
      super.copyWith((message) => updates(message as GetBlockedUsersSuccess))
          as GetBlockedUsersSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockedUsersSuccess create() => GetBlockedUsersSuccess._();
  @$core.override
  GetBlockedUsersSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetBlockedUsersSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockedUsersSuccess>(create);
  static GetBlockedUsersSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<BlockedUser> get blockedUsers => $_getList(0);
}

class BlockedUser extends $pb.GeneratedMessage {
  factory BlockedUser({
    $core.String? userId,
    $core.String? username,
    $1.Timestamp? blockedAt,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (username != null) result.username = username;
    if (blockedAt != null) result.blockedAt = blockedAt;
    return result;
  }

  BlockedUser._();

  factory BlockedUser.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockedUser.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockedUser',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOM<$1.Timestamp>(3, _omitFieldNames ? '' : 'blockedAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockedUser clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockedUser copyWith(void Function(BlockedUser) updates) =>
      super.copyWith((message) => updates(message as BlockedUser))
          as BlockedUser;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockedUser create() => BlockedUser._();
  @$core.override
  BlockedUser createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockedUser getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockedUser>(create);
  static BlockedUser? _defaultInstance;

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
  $1.Timestamp get blockedAt => $_getN(2);
  @$pb.TagNumber(3)
  set blockedAt($1.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBlockedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlockedAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Timestamp ensureBlockedAt() => $_ensure(2);
}

class DeleteConversationRequest extends $pb.GeneratedMessage {
  factory DeleteConversationRequest({
    $core.String? accessToken,
    $core.String? conversationId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (conversationId != null) result.conversationId = conversationId;
    return result;
  }

  DeleteConversationRequest._();

  factory DeleteConversationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteConversationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteConversationRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteConversationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteConversationRequest copyWith(
          void Function(DeleteConversationRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteConversationRequest))
          as DeleteConversationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteConversationRequest create() => DeleteConversationRequest._();
  @$core.override
  DeleteConversationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteConversationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteConversationRequest>(create);
  static DeleteConversationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);
}

enum DeleteConversationResponse_Result { success, error, notSet }

class DeleteConversationResponse extends $pb.GeneratedMessage {
  factory DeleteConversationResponse({
    DeleteConversationSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  DeleteConversationResponse._();

  factory DeleteConversationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteConversationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, DeleteConversationResponse_Result>
      _DeleteConversationResponse_ResultByTag = {
    1: DeleteConversationResponse_Result.success,
    2: DeleteConversationResponse_Result.error,
    0: DeleteConversationResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteConversationResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<DeleteConversationSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: DeleteConversationSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteConversationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteConversationResponse copyWith(
          void Function(DeleteConversationResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteConversationResponse))
          as DeleteConversationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteConversationResponse create() => DeleteConversationResponse._();
  @$core.override
  DeleteConversationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteConversationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteConversationResponse>(create);
  static DeleteConversationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  DeleteConversationResponse_Result whichResult() =>
      _DeleteConversationResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  DeleteConversationSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(DeleteConversationSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  DeleteConversationSuccess ensureSuccess() => $_ensure(0);

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

class DeleteConversationSuccess extends $pb.GeneratedMessage {
  factory DeleteConversationSuccess({
    $core.String? conversationId,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    return result;
  }

  DeleteConversationSuccess._();

  factory DeleteConversationSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteConversationSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteConversationSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.messaging'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteConversationSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteConversationSuccess copyWith(
          void Function(DeleteConversationSuccess) updates) =>
      super.copyWith((message) => updates(message as DeleteConversationSuccess))
          as DeleteConversationSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteConversationSuccess create() => DeleteConversationSuccess._();
  @$core.override
  DeleteConversationSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteConversationSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteConversationSuccess>(create);
  static DeleteConversationSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
