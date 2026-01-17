// This is a generated file - do not edit.
//
// Generated from presence.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $1;
import 'presence.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'presence.pbenum.dart';

class UpdateStatusRequest extends $pb.GeneratedMessage {
  factory UpdateStatusRequest({
    $core.String? accessToken,
    UserStatus? status,
    $core.String? customStatusText,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (status != null) result.status = status;
    if (customStatusText != null) result.customStatusText = customStatusText;
    return result;
  }

  UpdateStatusRequest._();

  factory UpdateStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateStatusRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aE<UserStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: UserStatus.values)
    ..aOS(3, _omitFieldNames ? '' : 'customStatusText')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateStatusRequest copyWith(void Function(UpdateStatusRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateStatusRequest))
          as UpdateStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateStatusRequest create() => UpdateStatusRequest._();
  @$core.override
  UpdateStatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateStatusRequest>(create);
  static UpdateStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  UserStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(UserStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get customStatusText => $_getSZ(2);
  @$pb.TagNumber(3)
  set customStatusText($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCustomStatusText() => $_has(2);
  @$pb.TagNumber(3)
  void clearCustomStatusText() => $_clearField(3);
}

enum UpdateStatusResponse_Result { success, error, notSet }

class UpdateStatusResponse extends $pb.GeneratedMessage {
  factory UpdateStatusResponse({
    UpdateStatusSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  UpdateStatusResponse._();

  factory UpdateStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, UpdateStatusResponse_Result>
      _UpdateStatusResponse_ResultByTag = {
    1: UpdateStatusResponse_Result.success,
    2: UpdateStatusResponse_Result.error,
    0: UpdateStatusResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateStatusResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<UpdateStatusSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: UpdateStatusSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateStatusResponse copyWith(void Function(UpdateStatusResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateStatusResponse))
          as UpdateStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateStatusResponse create() => UpdateStatusResponse._();
  @$core.override
  UpdateStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateStatusResponse>(create);
  static UpdateStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  UpdateStatusResponse_Result whichResult() =>
      _UpdateStatusResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  UpdateStatusSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(UpdateStatusSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  UpdateStatusSuccess ensureSuccess() => $_ensure(0);

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

class UpdateStatusSuccess extends $pb.GeneratedMessage {
  factory UpdateStatusSuccess({
    UserStatus? status,
    $1.Timestamp? updatedAt,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  UpdateStatusSuccess._();

  factory UpdateStatusSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateStatusSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateStatusSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..aE<UserStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: UserStatus.values)
    ..aOM<$1.Timestamp>(2, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateStatusSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateStatusSuccess copyWith(void Function(UpdateStatusSuccess) updates) =>
      super.copyWith((message) => updates(message as UpdateStatusSuccess))
          as UpdateStatusSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateStatusSuccess create() => UpdateStatusSuccess._();
  @$core.override
  UpdateStatusSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateStatusSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateStatusSuccess>(create);
  static UpdateStatusSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  UserStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(UserStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Timestamp get updatedAt => $_getN(1);
  @$pb.TagNumber(2)
  set updatedAt($1.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUpdatedAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpdatedAt() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Timestamp ensureUpdatedAt() => $_ensure(1);
}

class GetStatusRequest extends $pb.GeneratedMessage {
  factory GetStatusRequest({
    $core.String? accessToken,
    $core.String? userId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (userId != null) result.userId = userId;
    return result;
  }

  GetStatusRequest._();

  factory GetStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStatusRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatusRequest copyWith(void Function(GetStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetStatusRequest))
          as GetStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatusRequest create() => GetStatusRequest._();
  @$core.override
  GetStatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStatusRequest>(create);
  static GetStatusRequest? _defaultInstance;

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

enum GetStatusResponse_Result { success, error, notSet }

class GetStatusResponse extends $pb.GeneratedMessage {
  factory GetStatusResponse({
    GetStatusSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetStatusResponse._();

  factory GetStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetStatusResponse_Result>
      _GetStatusResponse_ResultByTag = {
    1: GetStatusResponse_Result.success,
    2: GetStatusResponse_Result.error,
    0: GetStatusResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStatusResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetStatusSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: GetStatusSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatusResponse copyWith(void Function(GetStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetStatusResponse))
          as GetStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatusResponse create() => GetStatusResponse._();
  @$core.override
  GetStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStatusResponse>(create);
  static GetStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetStatusResponse_Result whichResult() =>
      _GetStatusResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetStatusSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(GetStatusSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  GetStatusSuccess ensureSuccess() => $_ensure(0);

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

class GetStatusSuccess extends $pb.GeneratedMessage {
  factory GetStatusSuccess({
    $core.String? userId,
    UserStatus? status,
    $core.String? customStatusText,
    $1.Timestamp? lastSeen,
    $core.bool? isTyping,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (status != null) result.status = status;
    if (customStatusText != null) result.customStatusText = customStatusText;
    if (lastSeen != null) result.lastSeen = lastSeen;
    if (isTyping != null) result.isTyping = isTyping;
    return result;
  }

  GetStatusSuccess._();

  factory GetStatusSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetStatusSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStatusSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aE<UserStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: UserStatus.values)
    ..aOS(3, _omitFieldNames ? '' : 'customStatusText')
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'lastSeen',
        subBuilder: $1.Timestamp.create)
    ..aOB(5, _omitFieldNames ? '' : 'isTyping')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatusSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatusSuccess copyWith(void Function(GetStatusSuccess) updates) =>
      super.copyWith((message) => updates(message as GetStatusSuccess))
          as GetStatusSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatusSuccess create() => GetStatusSuccess._();
  @$core.override
  GetStatusSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetStatusSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStatusSuccess>(create);
  static GetStatusSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  UserStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(UserStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get customStatusText => $_getSZ(2);
  @$pb.TagNumber(3)
  set customStatusText($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCustomStatusText() => $_has(2);
  @$pb.TagNumber(3)
  void clearCustomStatusText() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Timestamp get lastSeen => $_getN(3);
  @$pb.TagNumber(4)
  set lastSeen($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLastSeen() => $_has(3);
  @$pb.TagNumber(4)
  void clearLastSeen() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureLastSeen() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.bool get isTyping => $_getBF(4);
  @$pb.TagNumber(5)
  set isTyping($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsTyping() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsTyping() => $_clearField(5);
}

class SubscribeRequest extends $pb.GeneratedMessage {
  factory SubscribeRequest({
    $core.String? accessToken,
    $core.Iterable<$core.String>? userIds,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (userIds != null) result.userIds.addAll(userIds);
    return result;
  }

  SubscribeRequest._();

  factory SubscribeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubscribeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribeRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..pPS(2, _omitFieldNames ? '' : 'userIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeRequest copyWith(void Function(SubscribeRequest) updates) =>
      super.copyWith((message) => updates(message as SubscribeRequest))
          as SubscribeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeRequest create() => SubscribeRequest._();
  @$core.override
  SubscribeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubscribeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribeRequest>(create);
  static SubscribeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get userIds => $_getList(1);
}

class PresenceUpdate extends $pb.GeneratedMessage {
  factory PresenceUpdate({
    $core.String? userId,
    UserStatus? status,
    $core.String? customStatusText,
    $1.Timestamp? lastSeen,
    $1.Timestamp? updatedAt,
    $core.bool? isTyping,
    $core.String? typingInConversationWith,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (status != null) result.status = status;
    if (customStatusText != null) result.customStatusText = customStatusText;
    if (lastSeen != null) result.lastSeen = lastSeen;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (isTyping != null) result.isTyping = isTyping;
    if (typingInConversationWith != null)
      result.typingInConversationWith = typingInConversationWith;
    return result;
  }

  PresenceUpdate._();

  factory PresenceUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PresenceUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PresenceUpdate',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aE<UserStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: UserStatus.values)
    ..aOS(3, _omitFieldNames ? '' : 'customStatusText')
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'lastSeen',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(5, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $1.Timestamp.create)
    ..aOB(6, _omitFieldNames ? '' : 'isTyping')
    ..aOS(7, _omitFieldNames ? '' : 'typingInConversationWith')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceUpdate copyWith(void Function(PresenceUpdate) updates) =>
      super.copyWith((message) => updates(message as PresenceUpdate))
          as PresenceUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresenceUpdate create() => PresenceUpdate._();
  @$core.override
  PresenceUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PresenceUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PresenceUpdate>(create);
  static PresenceUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  UserStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(UserStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get customStatusText => $_getSZ(2);
  @$pb.TagNumber(3)
  set customStatusText($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCustomStatusText() => $_has(2);
  @$pb.TagNumber(3)
  void clearCustomStatusText() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Timestamp get lastSeen => $_getN(3);
  @$pb.TagNumber(4)
  set lastSeen($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLastSeen() => $_has(3);
  @$pb.TagNumber(4)
  void clearLastSeen() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureLastSeen() => $_ensure(3);

  @$pb.TagNumber(5)
  $1.Timestamp get updatedAt => $_getN(4);
  @$pb.TagNumber(5)
  set updatedAt($1.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasUpdatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearUpdatedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.Timestamp ensureUpdatedAt() => $_ensure(4);

  /// Typing indicator (only for 1-on-1 conversations)
  @$pb.TagNumber(6)
  $core.bool get isTyping => $_getBF(5);
  @$pb.TagNumber(6)
  set isTyping($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsTyping() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsTyping() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get typingInConversationWith => $_getSZ(6);
  @$pb.TagNumber(7)
  set typingInConversationWith($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTypingInConversationWith() => $_has(6);
  @$pb.TagNumber(7)
  void clearTypingInConversationWith() => $_clearField(7);
}

class UpdateLastSeenRequest extends $pb.GeneratedMessage {
  factory UpdateLastSeenRequest({
    $core.String? accessToken,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    return result;
  }

  UpdateLastSeenRequest._();

  factory UpdateLastSeenRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateLastSeenRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateLastSeenRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLastSeenRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLastSeenRequest copyWith(
          void Function(UpdateLastSeenRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateLastSeenRequest))
          as UpdateLastSeenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateLastSeenRequest create() => UpdateLastSeenRequest._();
  @$core.override
  UpdateLastSeenRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateLastSeenRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateLastSeenRequest>(create);
  static UpdateLastSeenRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);
}

enum UpdateLastSeenResponse_Result { success, error, notSet }

class UpdateLastSeenResponse extends $pb.GeneratedMessage {
  factory UpdateLastSeenResponse({
    UpdateLastSeenSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  UpdateLastSeenResponse._();

  factory UpdateLastSeenResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateLastSeenResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, UpdateLastSeenResponse_Result>
      _UpdateLastSeenResponse_ResultByTag = {
    1: UpdateLastSeenResponse_Result.success,
    2: UpdateLastSeenResponse_Result.error,
    0: UpdateLastSeenResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateLastSeenResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<UpdateLastSeenSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: UpdateLastSeenSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLastSeenResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLastSeenResponse copyWith(
          void Function(UpdateLastSeenResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateLastSeenResponse))
          as UpdateLastSeenResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateLastSeenResponse create() => UpdateLastSeenResponse._();
  @$core.override
  UpdateLastSeenResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateLastSeenResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateLastSeenResponse>(create);
  static UpdateLastSeenResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  UpdateLastSeenResponse_Result whichResult() =>
      _UpdateLastSeenResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  UpdateLastSeenSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(UpdateLastSeenSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  UpdateLastSeenSuccess ensureSuccess() => $_ensure(0);

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

class UpdateLastSeenSuccess extends $pb.GeneratedMessage {
  factory UpdateLastSeenSuccess({
    $1.Timestamp? lastSeen,
  }) {
    final result = create();
    if (lastSeen != null) result.lastSeen = lastSeen;
    return result;
  }

  UpdateLastSeenSuccess._();

  factory UpdateLastSeenSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateLastSeenSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateLastSeenSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..aOM<$1.Timestamp>(1, _omitFieldNames ? '' : 'lastSeen',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLastSeenSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLastSeenSuccess copyWith(
          void Function(UpdateLastSeenSuccess) updates) =>
      super.copyWith((message) => updates(message as UpdateLastSeenSuccess))
          as UpdateLastSeenSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateLastSeenSuccess create() => UpdateLastSeenSuccess._();
  @$core.override
  UpdateLastSeenSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateLastSeenSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateLastSeenSuccess>(create);
  static UpdateLastSeenSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Timestamp get lastSeen => $_getN(0);
  @$pb.TagNumber(1)
  set lastSeen($1.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasLastSeen() => $_has(0);
  @$pb.TagNumber(1)
  void clearLastSeen() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Timestamp ensureLastSeen() => $_ensure(0);
}

class GetBulkStatusRequest extends $pb.GeneratedMessage {
  factory GetBulkStatusRequest({
    $core.String? accessToken,
    $core.Iterable<$core.String>? userIds,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (userIds != null) result.userIds.addAll(userIds);
    return result;
  }

  GetBulkStatusRequest._();

  factory GetBulkStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBulkStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBulkStatusRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..pPS(2, _omitFieldNames ? '' : 'userIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBulkStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBulkStatusRequest copyWith(void Function(GetBulkStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetBulkStatusRequest))
          as GetBulkStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBulkStatusRequest create() => GetBulkStatusRequest._();
  @$core.override
  GetBulkStatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetBulkStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBulkStatusRequest>(create);
  static GetBulkStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get userIds => $_getList(1);
}

enum GetBulkStatusResponse_Result { success, error, notSet }

class GetBulkStatusResponse extends $pb.GeneratedMessage {
  factory GetBulkStatusResponse({
    GetBulkStatusSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetBulkStatusResponse._();

  factory GetBulkStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBulkStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetBulkStatusResponse_Result>
      _GetBulkStatusResponse_ResultByTag = {
    1: GetBulkStatusResponse_Result.success,
    2: GetBulkStatusResponse_Result.error,
    0: GetBulkStatusResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBulkStatusResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetBulkStatusSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: GetBulkStatusSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBulkStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBulkStatusResponse copyWith(
          void Function(GetBulkStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetBulkStatusResponse))
          as GetBulkStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBulkStatusResponse create() => GetBulkStatusResponse._();
  @$core.override
  GetBulkStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetBulkStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBulkStatusResponse>(create);
  static GetBulkStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetBulkStatusResponse_Result whichResult() =>
      _GetBulkStatusResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetBulkStatusSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(GetBulkStatusSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  GetBulkStatusSuccess ensureSuccess() => $_ensure(0);

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

class GetBulkStatusSuccess extends $pb.GeneratedMessage {
  factory GetBulkStatusSuccess({
    $core.Iterable<UserPresence>? presences,
  }) {
    final result = create();
    if (presences != null) result.presences.addAll(presences);
    return result;
  }

  GetBulkStatusSuccess._();

  factory GetBulkStatusSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBulkStatusSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBulkStatusSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..pPM<UserPresence>(1, _omitFieldNames ? '' : 'presences',
        subBuilder: UserPresence.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBulkStatusSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBulkStatusSuccess copyWith(void Function(GetBulkStatusSuccess) updates) =>
      super.copyWith((message) => updates(message as GetBulkStatusSuccess))
          as GetBulkStatusSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBulkStatusSuccess create() => GetBulkStatusSuccess._();
  @$core.override
  GetBulkStatusSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetBulkStatusSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBulkStatusSuccess>(create);
  static GetBulkStatusSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<UserPresence> get presences => $_getList(0);
}

class UserPresence extends $pb.GeneratedMessage {
  factory UserPresence({
    $core.String? userId,
    UserStatus? status,
    $core.String? customStatusText,
    $1.Timestamp? lastSeen,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (status != null) result.status = status;
    if (customStatusText != null) result.customStatusText = customStatusText;
    if (lastSeen != null) result.lastSeen = lastSeen;
    return result;
  }

  UserPresence._();

  factory UserPresence.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserPresence.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserPresence',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aE<UserStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: UserStatus.values)
    ..aOS(3, _omitFieldNames ? '' : 'customStatusText')
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'lastSeen',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserPresence clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserPresence copyWith(void Function(UserPresence) updates) =>
      super.copyWith((message) => updates(message as UserPresence))
          as UserPresence;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserPresence create() => UserPresence._();
  @$core.override
  UserPresence createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserPresence getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserPresence>(create);
  static UserPresence? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  UserStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(UserStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get customStatusText => $_getSZ(2);
  @$pb.TagNumber(3)
  set customStatusText($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCustomStatusText() => $_has(2);
  @$pb.TagNumber(3)
  void clearCustomStatusText() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Timestamp get lastSeen => $_getN(3);
  @$pb.TagNumber(4)
  set lastSeen($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLastSeen() => $_has(3);
  @$pb.TagNumber(4)
  void clearLastSeen() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureLastSeen() => $_ensure(3);
}

class SetTypingRequest extends $pb.GeneratedMessage {
  factory SetTypingRequest({
    $core.String? accessToken,
    $core.String? conversationUserId,
    $core.bool? isTyping,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (conversationUserId != null)
      result.conversationUserId = conversationUserId;
    if (isTyping != null) result.isTyping = isTyping;
    return result;
  }

  SetTypingRequest._();

  factory SetTypingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetTypingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetTypingRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'conversationUserId')
    ..aOB(3, _omitFieldNames ? '' : 'isTyping')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTypingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTypingRequest copyWith(void Function(SetTypingRequest) updates) =>
      super.copyWith((message) => updates(message as SetTypingRequest))
          as SetTypingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetTypingRequest create() => SetTypingRequest._();
  @$core.override
  SetTypingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetTypingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetTypingRequest>(create);
  static SetTypingRequest? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.bool get isTyping => $_getBF(2);
  @$pb.TagNumber(3)
  set isTyping($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsTyping() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsTyping() => $_clearField(3);
}

enum SetTypingResponse_Result { success, error, notSet }

class SetTypingResponse extends $pb.GeneratedMessage {
  factory SetTypingResponse({
    SetTypingSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  SetTypingResponse._();

  factory SetTypingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetTypingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SetTypingResponse_Result>
      _SetTypingResponse_ResultByTag = {
    1: SetTypingResponse_Result.success,
    2: SetTypingResponse_Result.error,
    0: SetTypingResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetTypingResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<SetTypingSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: SetTypingSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTypingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTypingResponse copyWith(void Function(SetTypingResponse) updates) =>
      super.copyWith((message) => updates(message as SetTypingResponse))
          as SetTypingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetTypingResponse create() => SetTypingResponse._();
  @$core.override
  SetTypingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetTypingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetTypingResponse>(create);
  static SetTypingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  SetTypingResponse_Result whichResult() =>
      _SetTypingResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SetTypingSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(SetTypingSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  SetTypingSuccess ensureSuccess() => $_ensure(0);

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

class SetTypingSuccess extends $pb.GeneratedMessage {
  factory SetTypingSuccess({
    $core.bool? acknowledged,
  }) {
    final result = create();
    if (acknowledged != null) result.acknowledged = acknowledged;
    return result;
  }

  SetTypingSuccess._();

  factory SetTypingSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetTypingSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetTypingSuccess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'acknowledged')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTypingSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTypingSuccess copyWith(void Function(SetTypingSuccess) updates) =>
      super.copyWith((message) => updates(message as SetTypingSuccess))
          as SetTypingSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetTypingSuccess create() => SetTypingSuccess._();
  @$core.override
  SetTypingSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetTypingSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetTypingSuccess>(create);
  static SetTypingSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get acknowledged => $_getBF(0);
  @$pb.TagNumber(1)
  set acknowledged($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAcknowledged() => $_has(0);
  @$pb.TagNumber(1)
  void clearAcknowledged() => $_clearField(1);
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
          const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.presence'),
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
