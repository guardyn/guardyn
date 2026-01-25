// This is a generated file - do not edit.
//
// Generated from calls.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'calls.pbenum.dart';
import 'common.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'calls.pbenum.dart';

enum InitiateCallRequest_Target { userId, groupId, notSet }

class InitiateCallRequest extends $pb.GeneratedMessage {
  factory InitiateCallRequest({
    $core.String? accessToken,
    $core.String? userId,
    $core.String? groupId,
    CallType? callType,
    ClientCapabilities? capabilities,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (userId != null) result.userId = userId;
    if (groupId != null) result.groupId = groupId;
    if (callType != null) result.callType = callType;
    if (capabilities != null) result.capabilities = capabilities;
    return result;
  }

  InitiateCallRequest._();

  factory InitiateCallRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InitiateCallRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, InitiateCallRequest_Target>
      _InitiateCallRequest_TargetByTag = {
    2: InitiateCallRequest_Target.userId,
    3: InitiateCallRequest_Target.groupId,
    0: InitiateCallRequest_Target.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InitiateCallRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [2, 3])
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'groupId')
    ..aE<CallType>(4, _omitFieldNames ? '' : 'callType',
        enumValues: CallType.values)
    ..aOM<ClientCapabilities>(5, _omitFieldNames ? '' : 'capabilities',
        subBuilder: ClientCapabilities.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitiateCallRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitiateCallRequest copyWith(void Function(InitiateCallRequest) updates) =>
      super.copyWith((message) => updates(message as InitiateCallRequest))
          as InitiateCallRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InitiateCallRequest create() => InitiateCallRequest._();
  @$core.override
  InitiateCallRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InitiateCallRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InitiateCallRequest>(create);
  static InitiateCallRequest? _defaultInstance;

  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  InitiateCallRequest_Target whichTarget() =>
      _InitiateCallRequest_TargetByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearTarget() => $_clearField($_whichOneof(0));

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

  @$pb.TagNumber(3)
  $core.String get groupId => $_getSZ(2);
  @$pb.TagNumber(3)
  set groupId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGroupId() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroupId() => $_clearField(3);

  @$pb.TagNumber(4)
  CallType get callType => $_getN(3);
  @$pb.TagNumber(4)
  set callType(CallType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCallType() => $_has(3);
  @$pb.TagNumber(4)
  void clearCallType() => $_clearField(4);

  /// Client capabilities
  @$pb.TagNumber(5)
  ClientCapabilities get capabilities => $_getN(4);
  @$pb.TagNumber(5)
  set capabilities(ClientCapabilities value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCapabilities() => $_has(4);
  @$pb.TagNumber(5)
  void clearCapabilities() => $_clearField(5);
  @$pb.TagNumber(5)
  ClientCapabilities ensureCapabilities() => $_ensure(4);
}

class ClientCapabilities extends $pb.GeneratedMessage {
  factory ClientCapabilities({
    $core.bool? supportsVideo,
    $core.bool? supportsScreenShare,
    $core.bool? supportsSframe,
    $core.Iterable<$core.String>? supportedCodecs,
    $core.int? maxVideoWidth,
    $core.int? maxVideoHeight,
    $core.int? maxVideoFps,
  }) {
    final result = create();
    if (supportsVideo != null) result.supportsVideo = supportsVideo;
    if (supportsScreenShare != null)
      result.supportsScreenShare = supportsScreenShare;
    if (supportsSframe != null) result.supportsSframe = supportsSframe;
    if (supportedCodecs != null) result.supportedCodecs.addAll(supportedCodecs);
    if (maxVideoWidth != null) result.maxVideoWidth = maxVideoWidth;
    if (maxVideoHeight != null) result.maxVideoHeight = maxVideoHeight;
    if (maxVideoFps != null) result.maxVideoFps = maxVideoFps;
    return result;
  }

  ClientCapabilities._();

  factory ClientCapabilities.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClientCapabilities.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientCapabilities',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'supportsVideo')
    ..aOB(2, _omitFieldNames ? '' : 'supportsScreenShare')
    ..aOB(3, _omitFieldNames ? '' : 'supportsSframe')
    ..pPS(4, _omitFieldNames ? '' : 'supportedCodecs')
    ..aI(5, _omitFieldNames ? '' : 'maxVideoWidth')
    ..aI(6, _omitFieldNames ? '' : 'maxVideoHeight')
    ..aI(7, _omitFieldNames ? '' : 'maxVideoFps')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientCapabilities clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientCapabilities copyWith(void Function(ClientCapabilities) updates) =>
      super.copyWith((message) => updates(message as ClientCapabilities))
          as ClientCapabilities;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientCapabilities create() => ClientCapabilities._();
  @$core.override
  ClientCapabilities createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClientCapabilities getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientCapabilities>(create);
  static ClientCapabilities? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get supportsVideo => $_getBF(0);
  @$pb.TagNumber(1)
  set supportsVideo($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSupportsVideo() => $_has(0);
  @$pb.TagNumber(1)
  void clearSupportsVideo() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get supportsScreenShare => $_getBF(1);
  @$pb.TagNumber(2)
  set supportsScreenShare($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSupportsScreenShare() => $_has(1);
  @$pb.TagNumber(2)
  void clearSupportsScreenShare() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get supportsSframe => $_getBF(2);
  @$pb.TagNumber(3)
  set supportsSframe($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSupportsSframe() => $_has(2);
  @$pb.TagNumber(3)
  void clearSupportsSframe() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get supportedCodecs => $_getList(3);

  @$pb.TagNumber(5)
  $core.int get maxVideoWidth => $_getIZ(4);
  @$pb.TagNumber(5)
  set maxVideoWidth($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMaxVideoWidth() => $_has(4);
  @$pb.TagNumber(5)
  void clearMaxVideoWidth() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get maxVideoHeight => $_getIZ(5);
  @$pb.TagNumber(6)
  set maxVideoHeight($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxVideoHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxVideoHeight() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get maxVideoFps => $_getIZ(6);
  @$pb.TagNumber(7)
  set maxVideoFps($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMaxVideoFps() => $_has(6);
  @$pb.TagNumber(7)
  void clearMaxVideoFps() => $_clearField(7);
}

enum InitiateCallResponse_Result { success, error, notSet }

class InitiateCallResponse extends $pb.GeneratedMessage {
  factory InitiateCallResponse({
    InitiateCallSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  InitiateCallResponse._();

  factory InitiateCallResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InitiateCallResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, InitiateCallResponse_Result>
      _InitiateCallResponse_ResultByTag = {
    1: InitiateCallResponse_Result.success,
    2: InitiateCallResponse_Result.error,
    0: InitiateCallResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InitiateCallResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<InitiateCallSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: InitiateCallSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitiateCallResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitiateCallResponse copyWith(void Function(InitiateCallResponse) updates) =>
      super.copyWith((message) => updates(message as InitiateCallResponse))
          as InitiateCallResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InitiateCallResponse create() => InitiateCallResponse._();
  @$core.override
  InitiateCallResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InitiateCallResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InitiateCallResponse>(create);
  static InitiateCallResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  InitiateCallResponse_Result whichResult() =>
      _InitiateCallResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  InitiateCallSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(InitiateCallSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  InitiateCallSuccess ensureSuccess() => $_ensure(0);

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

class InitiateCallSuccess extends $pb.GeneratedMessage {
  factory InitiateCallSuccess({
    $core.String? callId,
    CallState? state,
    $1.Timestamp? createdAt,
    $core.Iterable<IceServer>? iceServers,
    $core.List<$core.int>? sframeKeyMaterial,
    $core.int? sframeKeyId,
  }) {
    final result = create();
    if (callId != null) result.callId = callId;
    if (state != null) result.state = state;
    if (createdAt != null) result.createdAt = createdAt;
    if (iceServers != null) result.iceServers.addAll(iceServers);
    if (sframeKeyMaterial != null) result.sframeKeyMaterial = sframeKeyMaterial;
    if (sframeKeyId != null) result.sframeKeyId = sframeKeyId;
    return result;
  }

  InitiateCallSuccess._();

  factory InitiateCallSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InitiateCallSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InitiateCallSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callId')
    ..aE<CallState>(2, _omitFieldNames ? '' : 'state',
        enumValues: CallState.values)
    ..aOM<$1.Timestamp>(3, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..pPM<IceServer>(4, _omitFieldNames ? '' : 'iceServers',
        subBuilder: IceServer.create)
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'sframeKeyMaterial', $pb.PbFieldType.OY)
    ..aI(6, _omitFieldNames ? '' : 'sframeKeyId',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitiateCallSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitiateCallSuccess copyWith(void Function(InitiateCallSuccess) updates) =>
      super.copyWith((message) => updates(message as InitiateCallSuccess))
          as InitiateCallSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InitiateCallSuccess create() => InitiateCallSuccess._();
  @$core.override
  InitiateCallSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InitiateCallSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InitiateCallSuccess>(create);
  static InitiateCallSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get callId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallId() => $_clearField(1);

  @$pb.TagNumber(2)
  CallState get state => $_getN(1);
  @$pb.TagNumber(2)
  set state(CallState value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasState() => $_has(1);
  @$pb.TagNumber(2)
  void clearState() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.Timestamp get createdAt => $_getN(2);
  @$pb.TagNumber(3)
  set createdAt($1.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCreatedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreatedAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Timestamp ensureCreatedAt() => $_ensure(2);

  /// TURN/STUN server configuration
  @$pb.TagNumber(4)
  $pb.PbList<IceServer> get iceServers => $_getList(3);

  /// SFrame key material for E2EE
  @$pb.TagNumber(5)
  $core.List<$core.int> get sframeKeyMaterial => $_getN(4);
  @$pb.TagNumber(5)
  set sframeKeyMaterial($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSframeKeyMaterial() => $_has(4);
  @$pb.TagNumber(5)
  void clearSframeKeyMaterial() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get sframeKeyId => $_getIZ(5);
  @$pb.TagNumber(6)
  set sframeKeyId($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSframeKeyId() => $_has(5);
  @$pb.TagNumber(6)
  void clearSframeKeyId() => $_clearField(6);
}

class IceServer extends $pb.GeneratedMessage {
  factory IceServer({
    $core.Iterable<$core.String>? urls,
    $core.String? username,
    $core.String? credential,
  }) {
    final result = create();
    if (urls != null) result.urls.addAll(urls);
    if (username != null) result.username = username;
    if (credential != null) result.credential = credential;
    return result;
  }

  IceServer._();

  factory IceServer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IceServer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IceServer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'urls')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'credential')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IceServer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IceServer copyWith(void Function(IceServer) updates) =>
      super.copyWith((message) => updates(message as IceServer)) as IceServer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IceServer create() => IceServer._();
  @$core.override
  IceServer createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IceServer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IceServer>(create);
  static IceServer? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get urls => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get credential => $_getSZ(2);
  @$pb.TagNumber(3)
  set credential($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCredential() => $_has(2);
  @$pb.TagNumber(3)
  void clearCredential() => $_clearField(3);
}

class AcceptCallRequest extends $pb.GeneratedMessage {
  factory AcceptCallRequest({
    $core.String? accessToken,
    $core.String? callId,
    ClientCapabilities? capabilities,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (callId != null) result.callId = callId;
    if (capabilities != null) result.capabilities = capabilities;
    return result;
  }

  AcceptCallRequest._();

  factory AcceptCallRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AcceptCallRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AcceptCallRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'callId')
    ..aOM<ClientCapabilities>(3, _omitFieldNames ? '' : 'capabilities',
        subBuilder: ClientCapabilities.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptCallRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptCallRequest copyWith(void Function(AcceptCallRequest) updates) =>
      super.copyWith((message) => updates(message as AcceptCallRequest))
          as AcceptCallRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AcceptCallRequest create() => AcceptCallRequest._();
  @$core.override
  AcceptCallRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AcceptCallRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AcceptCallRequest>(create);
  static AcceptCallRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get callId => $_getSZ(1);
  @$pb.TagNumber(2)
  set callId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCallId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallId() => $_clearField(2);

  @$pb.TagNumber(3)
  ClientCapabilities get capabilities => $_getN(2);
  @$pb.TagNumber(3)
  set capabilities(ClientCapabilities value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCapabilities() => $_has(2);
  @$pb.TagNumber(3)
  void clearCapabilities() => $_clearField(3);
  @$pb.TagNumber(3)
  ClientCapabilities ensureCapabilities() => $_ensure(2);
}

enum AcceptCallResponse_Result { success, error, notSet }

class AcceptCallResponse extends $pb.GeneratedMessage {
  factory AcceptCallResponse({
    AcceptCallSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  AcceptCallResponse._();

  factory AcceptCallResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AcceptCallResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, AcceptCallResponse_Result>
      _AcceptCallResponse_ResultByTag = {
    1: AcceptCallResponse_Result.success,
    2: AcceptCallResponse_Result.error,
    0: AcceptCallResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AcceptCallResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<AcceptCallSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: AcceptCallSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptCallResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptCallResponse copyWith(void Function(AcceptCallResponse) updates) =>
      super.copyWith((message) => updates(message as AcceptCallResponse))
          as AcceptCallResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AcceptCallResponse create() => AcceptCallResponse._();
  @$core.override
  AcceptCallResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AcceptCallResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AcceptCallResponse>(create);
  static AcceptCallResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  AcceptCallResponse_Result whichResult() =>
      _AcceptCallResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  AcceptCallSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(AcceptCallSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  AcceptCallSuccess ensureSuccess() => $_ensure(0);

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

class AcceptCallSuccess extends $pb.GeneratedMessage {
  factory AcceptCallSuccess({
    $core.String? callId,
    CallState? state,
    $core.Iterable<IceServer>? iceServers,
    $core.List<$core.int>? sframeKeyMaterial,
    $core.int? sframeKeyId,
  }) {
    final result = create();
    if (callId != null) result.callId = callId;
    if (state != null) result.state = state;
    if (iceServers != null) result.iceServers.addAll(iceServers);
    if (sframeKeyMaterial != null) result.sframeKeyMaterial = sframeKeyMaterial;
    if (sframeKeyId != null) result.sframeKeyId = sframeKeyId;
    return result;
  }

  AcceptCallSuccess._();

  factory AcceptCallSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AcceptCallSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AcceptCallSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callId')
    ..aE<CallState>(2, _omitFieldNames ? '' : 'state',
        enumValues: CallState.values)
    ..pPM<IceServer>(3, _omitFieldNames ? '' : 'iceServers',
        subBuilder: IceServer.create)
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'sframeKeyMaterial', $pb.PbFieldType.OY)
    ..aI(5, _omitFieldNames ? '' : 'sframeKeyId',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptCallSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptCallSuccess copyWith(void Function(AcceptCallSuccess) updates) =>
      super.copyWith((message) => updates(message as AcceptCallSuccess))
          as AcceptCallSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AcceptCallSuccess create() => AcceptCallSuccess._();
  @$core.override
  AcceptCallSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AcceptCallSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AcceptCallSuccess>(create);
  static AcceptCallSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get callId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallId() => $_clearField(1);

  @$pb.TagNumber(2)
  CallState get state => $_getN(1);
  @$pb.TagNumber(2)
  set state(CallState value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasState() => $_has(1);
  @$pb.TagNumber(2)
  void clearState() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<IceServer> get iceServers => $_getList(2);

  @$pb.TagNumber(4)
  $core.List<$core.int> get sframeKeyMaterial => $_getN(3);
  @$pb.TagNumber(4)
  set sframeKeyMaterial($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSframeKeyMaterial() => $_has(3);
  @$pb.TagNumber(4)
  void clearSframeKeyMaterial() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get sframeKeyId => $_getIZ(4);
  @$pb.TagNumber(5)
  set sframeKeyId($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSframeKeyId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSframeKeyId() => $_clearField(5);
}

class RejectCallRequest extends $pb.GeneratedMessage {
  factory RejectCallRequest({
    $core.String? accessToken,
    $core.String? callId,
    $core.String? reason,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (callId != null) result.callId = callId;
    if (reason != null) result.reason = reason;
    return result;
  }

  RejectCallRequest._();

  factory RejectCallRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RejectCallRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RejectCallRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'callId')
    ..aOS(3, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RejectCallRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RejectCallRequest copyWith(void Function(RejectCallRequest) updates) =>
      super.copyWith((message) => updates(message as RejectCallRequest))
          as RejectCallRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RejectCallRequest create() => RejectCallRequest._();
  @$core.override
  RejectCallRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RejectCallRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RejectCallRequest>(create);
  static RejectCallRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get callId => $_getSZ(1);
  @$pb.TagNumber(2)
  set callId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCallId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get reason => $_getSZ(2);
  @$pb.TagNumber(3)
  set reason($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => $_clearField(3);
}

enum RejectCallResponse_Result { success, error, notSet }

class RejectCallResponse extends $pb.GeneratedMessage {
  factory RejectCallResponse({
    RejectCallSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  RejectCallResponse._();

  factory RejectCallResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RejectCallResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, RejectCallResponse_Result>
      _RejectCallResponse_ResultByTag = {
    1: RejectCallResponse_Result.success,
    2: RejectCallResponse_Result.error,
    0: RejectCallResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RejectCallResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<RejectCallSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: RejectCallSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RejectCallResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RejectCallResponse copyWith(void Function(RejectCallResponse) updates) =>
      super.copyWith((message) => updates(message as RejectCallResponse))
          as RejectCallResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RejectCallResponse create() => RejectCallResponse._();
  @$core.override
  RejectCallResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RejectCallResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RejectCallResponse>(create);
  static RejectCallResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  RejectCallResponse_Result whichResult() =>
      _RejectCallResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  RejectCallSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(RejectCallSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  RejectCallSuccess ensureSuccess() => $_ensure(0);

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

class RejectCallSuccess extends $pb.GeneratedMessage {
  factory RejectCallSuccess({
    $core.bool? rejected,
  }) {
    final result = create();
    if (rejected != null) result.rejected = rejected;
    return result;
  }

  RejectCallSuccess._();

  factory RejectCallSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RejectCallSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RejectCallSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'rejected')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RejectCallSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RejectCallSuccess copyWith(void Function(RejectCallSuccess) updates) =>
      super.copyWith((message) => updates(message as RejectCallSuccess))
          as RejectCallSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RejectCallSuccess create() => RejectCallSuccess._();
  @$core.override
  RejectCallSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RejectCallSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RejectCallSuccess>(create);
  static RejectCallSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get rejected => $_getBF(0);
  @$pb.TagNumber(1)
  set rejected($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRejected() => $_has(0);
  @$pb.TagNumber(1)
  void clearRejected() => $_clearField(1);
}

class EndCallRequest extends $pb.GeneratedMessage {
  factory EndCallRequest({
    $core.String? accessToken,
    $core.String? callId,
    CallEndReason? reason,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (callId != null) result.callId = callId;
    if (reason != null) result.reason = reason;
    return result;
  }

  EndCallRequest._();

  factory EndCallRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EndCallRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EndCallRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'callId')
    ..aE<CallEndReason>(3, _omitFieldNames ? '' : 'reason',
        enumValues: CallEndReason.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EndCallRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EndCallRequest copyWith(void Function(EndCallRequest) updates) =>
      super.copyWith((message) => updates(message as EndCallRequest))
          as EndCallRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EndCallRequest create() => EndCallRequest._();
  @$core.override
  EndCallRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EndCallRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EndCallRequest>(create);
  static EndCallRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get callId => $_getSZ(1);
  @$pb.TagNumber(2)
  set callId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCallId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallId() => $_clearField(2);

  @$pb.TagNumber(3)
  CallEndReason get reason => $_getN(2);
  @$pb.TagNumber(3)
  set reason(CallEndReason value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearReason() => $_clearField(3);
}

enum EndCallResponse_Result { success, error, notSet }

class EndCallResponse extends $pb.GeneratedMessage {
  factory EndCallResponse({
    EndCallSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  EndCallResponse._();

  factory EndCallResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EndCallResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, EndCallResponse_Result>
      _EndCallResponse_ResultByTag = {
    1: EndCallResponse_Result.success,
    2: EndCallResponse_Result.error,
    0: EndCallResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EndCallResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<EndCallSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: EndCallSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EndCallResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EndCallResponse copyWith(void Function(EndCallResponse) updates) =>
      super.copyWith((message) => updates(message as EndCallResponse))
          as EndCallResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EndCallResponse create() => EndCallResponse._();
  @$core.override
  EndCallResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EndCallResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EndCallResponse>(create);
  static EndCallResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  EndCallResponse_Result whichResult() =>
      _EndCallResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  EndCallSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(EndCallSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  EndCallSuccess ensureSuccess() => $_ensure(0);

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

class EndCallSuccess extends $pb.GeneratedMessage {
  factory EndCallSuccess({
    $core.bool? ended,
    $core.int? durationSeconds,
  }) {
    final result = create();
    if (ended != null) result.ended = ended;
    if (durationSeconds != null) result.durationSeconds = durationSeconds;
    return result;
  }

  EndCallSuccess._();

  factory EndCallSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EndCallSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EndCallSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'ended')
    ..aI(2, _omitFieldNames ? '' : 'durationSeconds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EndCallSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EndCallSuccess copyWith(void Function(EndCallSuccess) updates) =>
      super.copyWith((message) => updates(message as EndCallSuccess))
          as EndCallSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EndCallSuccess create() => EndCallSuccess._();
  @$core.override
  EndCallSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EndCallSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EndCallSuccess>(create);
  static EndCallSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get ended => $_getBF(0);
  @$pb.TagNumber(1)
  set ended($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEnded() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnded() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get durationSeconds => $_getIZ(1);
  @$pb.TagNumber(2)
  set durationSeconds($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDurationSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearDurationSeconds() => $_clearField(2);
}

class LeaveCallRequest extends $pb.GeneratedMessage {
  factory LeaveCallRequest({
    $core.String? accessToken,
    $core.String? callId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (callId != null) result.callId = callId;
    return result;
  }

  LeaveCallRequest._();

  factory LeaveCallRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LeaveCallRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LeaveCallRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'callId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveCallRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveCallRequest copyWith(void Function(LeaveCallRequest) updates) =>
      super.copyWith((message) => updates(message as LeaveCallRequest))
          as LeaveCallRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaveCallRequest create() => LeaveCallRequest._();
  @$core.override
  LeaveCallRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LeaveCallRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LeaveCallRequest>(create);
  static LeaveCallRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get callId => $_getSZ(1);
  @$pb.TagNumber(2)
  set callId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCallId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallId() => $_clearField(2);
}

enum LeaveCallResponse_Result { success, error, notSet }

class LeaveCallResponse extends $pb.GeneratedMessage {
  factory LeaveCallResponse({
    LeaveCallSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  LeaveCallResponse._();

  factory LeaveCallResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LeaveCallResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, LeaveCallResponse_Result>
      _LeaveCallResponse_ResultByTag = {
    1: LeaveCallResponse_Result.success,
    2: LeaveCallResponse_Result.error,
    0: LeaveCallResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LeaveCallResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<LeaveCallSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: LeaveCallSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveCallResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveCallResponse copyWith(void Function(LeaveCallResponse) updates) =>
      super.copyWith((message) => updates(message as LeaveCallResponse))
          as LeaveCallResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaveCallResponse create() => LeaveCallResponse._();
  @$core.override
  LeaveCallResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LeaveCallResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LeaveCallResponse>(create);
  static LeaveCallResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  LeaveCallResponse_Result whichResult() =>
      _LeaveCallResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  LeaveCallSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(LeaveCallSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  LeaveCallSuccess ensureSuccess() => $_ensure(0);

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

class LeaveCallSuccess extends $pb.GeneratedMessage {
  factory LeaveCallSuccess({
    $core.bool? left,
  }) {
    final result = create();
    if (left != null) result.left = left;
    return result;
  }

  LeaveCallSuccess._();

  factory LeaveCallSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LeaveCallSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LeaveCallSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'left')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveCallSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaveCallSuccess copyWith(void Function(LeaveCallSuccess) updates) =>
      super.copyWith((message) => updates(message as LeaveCallSuccess))
          as LeaveCallSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaveCallSuccess create() => LeaveCallSuccess._();
  @$core.override
  LeaveCallSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LeaveCallSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LeaveCallSuccess>(create);
  static LeaveCallSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get left => $_getBF(0);
  @$pb.TagNumber(1)
  set left($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLeft() => $_has(0);
  @$pb.TagNumber(1)
  void clearLeft() => $_clearField(1);
}

class JoinCallRequest extends $pb.GeneratedMessage {
  factory JoinCallRequest({
    $core.String? accessToken,
    $core.String? callId,
    ClientCapabilities? capabilities,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (callId != null) result.callId = callId;
    if (capabilities != null) result.capabilities = capabilities;
    return result;
  }

  JoinCallRequest._();

  factory JoinCallRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinCallRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinCallRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'callId')
    ..aOM<ClientCapabilities>(3, _omitFieldNames ? '' : 'capabilities',
        subBuilder: ClientCapabilities.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinCallRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinCallRequest copyWith(void Function(JoinCallRequest) updates) =>
      super.copyWith((message) => updates(message as JoinCallRequest))
          as JoinCallRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinCallRequest create() => JoinCallRequest._();
  @$core.override
  JoinCallRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JoinCallRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinCallRequest>(create);
  static JoinCallRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get callId => $_getSZ(1);
  @$pb.TagNumber(2)
  set callId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCallId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallId() => $_clearField(2);

  @$pb.TagNumber(3)
  ClientCapabilities get capabilities => $_getN(2);
  @$pb.TagNumber(3)
  set capabilities(ClientCapabilities value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCapabilities() => $_has(2);
  @$pb.TagNumber(3)
  void clearCapabilities() => $_clearField(3);
  @$pb.TagNumber(3)
  ClientCapabilities ensureCapabilities() => $_ensure(2);
}

enum JoinCallResponse_Result { success, error, notSet }

class JoinCallResponse extends $pb.GeneratedMessage {
  factory JoinCallResponse({
    JoinCallSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  JoinCallResponse._();

  factory JoinCallResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinCallResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, JoinCallResponse_Result>
      _JoinCallResponse_ResultByTag = {
    1: JoinCallResponse_Result.success,
    2: JoinCallResponse_Result.error,
    0: JoinCallResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinCallResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<JoinCallSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: JoinCallSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinCallResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinCallResponse copyWith(void Function(JoinCallResponse) updates) =>
      super.copyWith((message) => updates(message as JoinCallResponse))
          as JoinCallResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinCallResponse create() => JoinCallResponse._();
  @$core.override
  JoinCallResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JoinCallResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinCallResponse>(create);
  static JoinCallResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  JoinCallResponse_Result whichResult() =>
      _JoinCallResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  JoinCallSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(JoinCallSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  JoinCallSuccess ensureSuccess() => $_ensure(0);

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

class JoinCallSuccess extends $pb.GeneratedMessage {
  factory JoinCallSuccess({
    $core.String? callId,
    CallState? state,
    $core.Iterable<CallParticipant>? participants,
    $core.Iterable<IceServer>? iceServers,
    $core.List<$core.int>? sframeKeyMaterial,
    $core.int? sframeKeyId,
  }) {
    final result = create();
    if (callId != null) result.callId = callId;
    if (state != null) result.state = state;
    if (participants != null) result.participants.addAll(participants);
    if (iceServers != null) result.iceServers.addAll(iceServers);
    if (sframeKeyMaterial != null) result.sframeKeyMaterial = sframeKeyMaterial;
    if (sframeKeyId != null) result.sframeKeyId = sframeKeyId;
    return result;
  }

  JoinCallSuccess._();

  factory JoinCallSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JoinCallSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JoinCallSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callId')
    ..aE<CallState>(2, _omitFieldNames ? '' : 'state',
        enumValues: CallState.values)
    ..pPM<CallParticipant>(3, _omitFieldNames ? '' : 'participants',
        subBuilder: CallParticipant.create)
    ..pPM<IceServer>(4, _omitFieldNames ? '' : 'iceServers',
        subBuilder: IceServer.create)
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'sframeKeyMaterial', $pb.PbFieldType.OY)
    ..aI(6, _omitFieldNames ? '' : 'sframeKeyId',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinCallSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JoinCallSuccess copyWith(void Function(JoinCallSuccess) updates) =>
      super.copyWith((message) => updates(message as JoinCallSuccess))
          as JoinCallSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinCallSuccess create() => JoinCallSuccess._();
  @$core.override
  JoinCallSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JoinCallSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JoinCallSuccess>(create);
  static JoinCallSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get callId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallId() => $_clearField(1);

  @$pb.TagNumber(2)
  CallState get state => $_getN(1);
  @$pb.TagNumber(2)
  set state(CallState value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasState() => $_has(1);
  @$pb.TagNumber(2)
  void clearState() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<CallParticipant> get participants => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<IceServer> get iceServers => $_getList(3);

  @$pb.TagNumber(5)
  $core.List<$core.int> get sframeKeyMaterial => $_getN(4);
  @$pb.TagNumber(5)
  set sframeKeyMaterial($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSframeKeyMaterial() => $_has(4);
  @$pb.TagNumber(5)
  void clearSframeKeyMaterial() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get sframeKeyId => $_getIZ(5);
  @$pb.TagNumber(6)
  set sframeKeyId($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSframeKeyId() => $_has(5);
  @$pb.TagNumber(6)
  void clearSframeKeyId() => $_clearField(6);
}

class CallParticipant extends $pb.GeneratedMessage {
  factory CallParticipant({
    $core.String? userId,
    $core.String? displayName,
    $core.bool? isMuted,
    $core.bool? hasVideo,
    $core.bool? isScreenSharing,
    $core.bool? isSpeaking,
    $1.Timestamp? joinedAt,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (displayName != null) result.displayName = displayName;
    if (isMuted != null) result.isMuted = isMuted;
    if (hasVideo != null) result.hasVideo = hasVideo;
    if (isScreenSharing != null) result.isScreenSharing = isScreenSharing;
    if (isSpeaking != null) result.isSpeaking = isSpeaking;
    if (joinedAt != null) result.joinedAt = joinedAt;
    return result;
  }

  CallParticipant._();

  factory CallParticipant.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CallParticipant.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CallParticipant',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOB(3, _omitFieldNames ? '' : 'isMuted')
    ..aOB(4, _omitFieldNames ? '' : 'hasVideo')
    ..aOB(5, _omitFieldNames ? '' : 'isScreenSharing')
    ..aOB(6, _omitFieldNames ? '' : 'isSpeaking')
    ..aOM<$1.Timestamp>(7, _omitFieldNames ? '' : 'joinedAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallParticipant clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallParticipant copyWith(void Function(CallParticipant) updates) =>
      super.copyWith((message) => updates(message as CallParticipant))
          as CallParticipant;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CallParticipant create() => CallParticipant._();
  @$core.override
  CallParticipant createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CallParticipant getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CallParticipant>(create);
  static CallParticipant? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isMuted => $_getBF(2);
  @$pb.TagNumber(3)
  set isMuted($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsMuted() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsMuted() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get hasVideo => $_getBF(3);
  @$pb.TagNumber(4)
  set hasVideo($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHasVideo() => $_has(3);
  @$pb.TagNumber(4)
  void clearHasVideo() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isScreenSharing => $_getBF(4);
  @$pb.TagNumber(5)
  set isScreenSharing($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsScreenSharing() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsScreenSharing() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isSpeaking => $_getBF(5);
  @$pb.TagNumber(6)
  set isSpeaking($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsSpeaking() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsSpeaking() => $_clearField(6);

  @$pb.TagNumber(7)
  $1.Timestamp get joinedAt => $_getN(6);
  @$pb.TagNumber(7)
  set joinedAt($1.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasJoinedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearJoinedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.Timestamp ensureJoinedAt() => $_ensure(6);
}

class SetMuteRequest extends $pb.GeneratedMessage {
  factory SetMuteRequest({
    $core.String? accessToken,
    $core.String? callId,
    $core.bool? muted,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (callId != null) result.callId = callId;
    if (muted != null) result.muted = muted;
    return result;
  }

  SetMuteRequest._();

  factory SetMuteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetMuteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetMuteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'callId')
    ..aOB(3, _omitFieldNames ? '' : 'muted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMuteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMuteRequest copyWith(void Function(SetMuteRequest) updates) =>
      super.copyWith((message) => updates(message as SetMuteRequest))
          as SetMuteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetMuteRequest create() => SetMuteRequest._();
  @$core.override
  SetMuteRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetMuteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetMuteRequest>(create);
  static SetMuteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get callId => $_getSZ(1);
  @$pb.TagNumber(2)
  set callId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCallId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get muted => $_getBF(2);
  @$pb.TagNumber(3)
  set muted($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMuted() => $_has(2);
  @$pb.TagNumber(3)
  void clearMuted() => $_clearField(3);
}

enum SetMuteResponse_Result { success, error, notSet }

class SetMuteResponse extends $pb.GeneratedMessage {
  factory SetMuteResponse({
    SetMuteSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  SetMuteResponse._();

  factory SetMuteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetMuteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SetMuteResponse_Result>
      _SetMuteResponse_ResultByTag = {
    1: SetMuteResponse_Result.success,
    2: SetMuteResponse_Result.error,
    0: SetMuteResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetMuteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<SetMuteSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: SetMuteSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMuteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMuteResponse copyWith(void Function(SetMuteResponse) updates) =>
      super.copyWith((message) => updates(message as SetMuteResponse))
          as SetMuteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetMuteResponse create() => SetMuteResponse._();
  @$core.override
  SetMuteResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetMuteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetMuteResponse>(create);
  static SetMuteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  SetMuteResponse_Result whichResult() =>
      _SetMuteResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SetMuteSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(SetMuteSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  SetMuteSuccess ensureSuccess() => $_ensure(0);

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

class SetMuteSuccess extends $pb.GeneratedMessage {
  factory SetMuteSuccess({
    $core.bool? muted,
  }) {
    final result = create();
    if (muted != null) result.muted = muted;
    return result;
  }

  SetMuteSuccess._();

  factory SetMuteSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetMuteSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetMuteSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'muted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMuteSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMuteSuccess copyWith(void Function(SetMuteSuccess) updates) =>
      super.copyWith((message) => updates(message as SetMuteSuccess))
          as SetMuteSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetMuteSuccess create() => SetMuteSuccess._();
  @$core.override
  SetMuteSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetMuteSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetMuteSuccess>(create);
  static SetMuteSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get muted => $_getBF(0);
  @$pb.TagNumber(1)
  set muted($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMuted() => $_has(0);
  @$pb.TagNumber(1)
  void clearMuted() => $_clearField(1);
}

class SetVideoRequest extends $pb.GeneratedMessage {
  factory SetVideoRequest({
    $core.String? accessToken,
    $core.String? callId,
    $core.bool? videoEnabled,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (callId != null) result.callId = callId;
    if (videoEnabled != null) result.videoEnabled = videoEnabled;
    return result;
  }

  SetVideoRequest._();

  factory SetVideoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetVideoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetVideoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'callId')
    ..aOB(3, _omitFieldNames ? '' : 'videoEnabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetVideoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetVideoRequest copyWith(void Function(SetVideoRequest) updates) =>
      super.copyWith((message) => updates(message as SetVideoRequest))
          as SetVideoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetVideoRequest create() => SetVideoRequest._();
  @$core.override
  SetVideoRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetVideoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetVideoRequest>(create);
  static SetVideoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get callId => $_getSZ(1);
  @$pb.TagNumber(2)
  set callId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCallId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get videoEnabled => $_getBF(2);
  @$pb.TagNumber(3)
  set videoEnabled($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVideoEnabled() => $_has(2);
  @$pb.TagNumber(3)
  void clearVideoEnabled() => $_clearField(3);
}

enum SetVideoResponse_Result { success, error, notSet }

class SetVideoResponse extends $pb.GeneratedMessage {
  factory SetVideoResponse({
    SetVideoSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  SetVideoResponse._();

  factory SetVideoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetVideoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SetVideoResponse_Result>
      _SetVideoResponse_ResultByTag = {
    1: SetVideoResponse_Result.success,
    2: SetVideoResponse_Result.error,
    0: SetVideoResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetVideoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<SetVideoSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: SetVideoSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetVideoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetVideoResponse copyWith(void Function(SetVideoResponse) updates) =>
      super.copyWith((message) => updates(message as SetVideoResponse))
          as SetVideoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetVideoResponse create() => SetVideoResponse._();
  @$core.override
  SetVideoResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetVideoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetVideoResponse>(create);
  static SetVideoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  SetVideoResponse_Result whichResult() =>
      _SetVideoResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SetVideoSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(SetVideoSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  SetVideoSuccess ensureSuccess() => $_ensure(0);

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

class SetVideoSuccess extends $pb.GeneratedMessage {
  factory SetVideoSuccess({
    $core.bool? videoEnabled,
  }) {
    final result = create();
    if (videoEnabled != null) result.videoEnabled = videoEnabled;
    return result;
  }

  SetVideoSuccess._();

  factory SetVideoSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetVideoSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetVideoSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'videoEnabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetVideoSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetVideoSuccess copyWith(void Function(SetVideoSuccess) updates) =>
      super.copyWith((message) => updates(message as SetVideoSuccess))
          as SetVideoSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetVideoSuccess create() => SetVideoSuccess._();
  @$core.override
  SetVideoSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetVideoSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetVideoSuccess>(create);
  static SetVideoSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get videoEnabled => $_getBF(0);
  @$pb.TagNumber(1)
  set videoEnabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVideoEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearVideoEnabled() => $_clearField(1);
}

class SetScreenShareRequest extends $pb.GeneratedMessage {
  factory SetScreenShareRequest({
    $core.String? accessToken,
    $core.String? callId,
    $core.bool? screenShareEnabled,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (callId != null) result.callId = callId;
    if (screenShareEnabled != null)
      result.screenShareEnabled = screenShareEnabled;
    return result;
  }

  SetScreenShareRequest._();

  factory SetScreenShareRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetScreenShareRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetScreenShareRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'callId')
    ..aOB(3, _omitFieldNames ? '' : 'screenShareEnabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetScreenShareRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetScreenShareRequest copyWith(
          void Function(SetScreenShareRequest) updates) =>
      super.copyWith((message) => updates(message as SetScreenShareRequest))
          as SetScreenShareRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetScreenShareRequest create() => SetScreenShareRequest._();
  @$core.override
  SetScreenShareRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetScreenShareRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetScreenShareRequest>(create);
  static SetScreenShareRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get callId => $_getSZ(1);
  @$pb.TagNumber(2)
  set callId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCallId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get screenShareEnabled => $_getBF(2);
  @$pb.TagNumber(3)
  set screenShareEnabled($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScreenShareEnabled() => $_has(2);
  @$pb.TagNumber(3)
  void clearScreenShareEnabled() => $_clearField(3);
}

enum SetScreenShareResponse_Result { success, error, notSet }

class SetScreenShareResponse extends $pb.GeneratedMessage {
  factory SetScreenShareResponse({
    SetScreenShareSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  SetScreenShareResponse._();

  factory SetScreenShareResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetScreenShareResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SetScreenShareResponse_Result>
      _SetScreenShareResponse_ResultByTag = {
    1: SetScreenShareResponse_Result.success,
    2: SetScreenShareResponse_Result.error,
    0: SetScreenShareResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetScreenShareResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<SetScreenShareSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: SetScreenShareSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetScreenShareResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetScreenShareResponse copyWith(
          void Function(SetScreenShareResponse) updates) =>
      super.copyWith((message) => updates(message as SetScreenShareResponse))
          as SetScreenShareResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetScreenShareResponse create() => SetScreenShareResponse._();
  @$core.override
  SetScreenShareResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetScreenShareResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetScreenShareResponse>(create);
  static SetScreenShareResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  SetScreenShareResponse_Result whichResult() =>
      _SetScreenShareResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SetScreenShareSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(SetScreenShareSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  SetScreenShareSuccess ensureSuccess() => $_ensure(0);

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

class SetScreenShareSuccess extends $pb.GeneratedMessage {
  factory SetScreenShareSuccess({
    $core.bool? screenShareEnabled,
  }) {
    final result = create();
    if (screenShareEnabled != null)
      result.screenShareEnabled = screenShareEnabled;
    return result;
  }

  SetScreenShareSuccess._();

  factory SetScreenShareSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetScreenShareSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetScreenShareSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'screenShareEnabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetScreenShareSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetScreenShareSuccess copyWith(
          void Function(SetScreenShareSuccess) updates) =>
      super.copyWith((message) => updates(message as SetScreenShareSuccess))
          as SetScreenShareSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetScreenShareSuccess create() => SetScreenShareSuccess._();
  @$core.override
  SetScreenShareSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetScreenShareSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetScreenShareSuccess>(create);
  static SetScreenShareSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get screenShareEnabled => $_getBF(0);
  @$pb.TagNumber(1)
  set screenShareEnabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasScreenShareEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearScreenShareEnabled() => $_clearField(1);
}

class ExchangeIceCandidateRequest extends $pb.GeneratedMessage {
  factory ExchangeIceCandidateRequest({
    $core.String? accessToken,
    $core.String? callId,
    $core.String? targetUserId,
    IceCandidate? candidate,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (callId != null) result.callId = callId;
    if (targetUserId != null) result.targetUserId = targetUserId;
    if (candidate != null) result.candidate = candidate;
    return result;
  }

  ExchangeIceCandidateRequest._();

  factory ExchangeIceCandidateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExchangeIceCandidateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExchangeIceCandidateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'callId')
    ..aOS(3, _omitFieldNames ? '' : 'targetUserId')
    ..aOM<IceCandidate>(4, _omitFieldNames ? '' : 'candidate',
        subBuilder: IceCandidate.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeIceCandidateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeIceCandidateRequest copyWith(
          void Function(ExchangeIceCandidateRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ExchangeIceCandidateRequest))
          as ExchangeIceCandidateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExchangeIceCandidateRequest create() =>
      ExchangeIceCandidateRequest._();
  @$core.override
  ExchangeIceCandidateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExchangeIceCandidateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExchangeIceCandidateRequest>(create);
  static ExchangeIceCandidateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get callId => $_getSZ(1);
  @$pb.TagNumber(2)
  set callId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCallId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get targetUserId => $_getSZ(2);
  @$pb.TagNumber(3)
  set targetUserId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTargetUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTargetUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  IceCandidate get candidate => $_getN(3);
  @$pb.TagNumber(4)
  set candidate(IceCandidate value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCandidate() => $_has(3);
  @$pb.TagNumber(4)
  void clearCandidate() => $_clearField(4);
  @$pb.TagNumber(4)
  IceCandidate ensureCandidate() => $_ensure(3);
}

class IceCandidate extends $pb.GeneratedMessage {
  factory IceCandidate({
    $core.String? candidate,
    $core.String? sdpMid,
    $core.int? sdpMlineIndex,
    $core.String? usernameFragment,
  }) {
    final result = create();
    if (candidate != null) result.candidate = candidate;
    if (sdpMid != null) result.sdpMid = sdpMid;
    if (sdpMlineIndex != null) result.sdpMlineIndex = sdpMlineIndex;
    if (usernameFragment != null) result.usernameFragment = usernameFragment;
    return result;
  }

  IceCandidate._();

  factory IceCandidate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IceCandidate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IceCandidate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'candidate')
    ..aOS(2, _omitFieldNames ? '' : 'sdpMid')
    ..aI(3, _omitFieldNames ? '' : 'sdpMlineIndex')
    ..aOS(4, _omitFieldNames ? '' : 'usernameFragment')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IceCandidate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IceCandidate copyWith(void Function(IceCandidate) updates) =>
      super.copyWith((message) => updates(message as IceCandidate))
          as IceCandidate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IceCandidate create() => IceCandidate._();
  @$core.override
  IceCandidate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IceCandidate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IceCandidate>(create);
  static IceCandidate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get candidate => $_getSZ(0);
  @$pb.TagNumber(1)
  set candidate($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCandidate() => $_has(0);
  @$pb.TagNumber(1)
  void clearCandidate() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sdpMid => $_getSZ(1);
  @$pb.TagNumber(2)
  set sdpMid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSdpMid() => $_has(1);
  @$pb.TagNumber(2)
  void clearSdpMid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get sdpMlineIndex => $_getIZ(2);
  @$pb.TagNumber(3)
  set sdpMlineIndex($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSdpMlineIndex() => $_has(2);
  @$pb.TagNumber(3)
  void clearSdpMlineIndex() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get usernameFragment => $_getSZ(3);
  @$pb.TagNumber(4)
  set usernameFragment($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUsernameFragment() => $_has(3);
  @$pb.TagNumber(4)
  void clearUsernameFragment() => $_clearField(4);
}

enum ExchangeIceCandidateResponse_Result { success, error, notSet }

class ExchangeIceCandidateResponse extends $pb.GeneratedMessage {
  factory ExchangeIceCandidateResponse({
    ExchangeIceCandidateSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  ExchangeIceCandidateResponse._();

  factory ExchangeIceCandidateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExchangeIceCandidateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ExchangeIceCandidateResponse_Result>
      _ExchangeIceCandidateResponse_ResultByTag = {
    1: ExchangeIceCandidateResponse_Result.success,
    2: ExchangeIceCandidateResponse_Result.error,
    0: ExchangeIceCandidateResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExchangeIceCandidateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<ExchangeIceCandidateSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: ExchangeIceCandidateSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeIceCandidateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeIceCandidateResponse copyWith(
          void Function(ExchangeIceCandidateResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ExchangeIceCandidateResponse))
          as ExchangeIceCandidateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExchangeIceCandidateResponse create() =>
      ExchangeIceCandidateResponse._();
  @$core.override
  ExchangeIceCandidateResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExchangeIceCandidateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExchangeIceCandidateResponse>(create);
  static ExchangeIceCandidateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  ExchangeIceCandidateResponse_Result whichResult() =>
      _ExchangeIceCandidateResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ExchangeIceCandidateSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(ExchangeIceCandidateSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  ExchangeIceCandidateSuccess ensureSuccess() => $_ensure(0);

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

class ExchangeIceCandidateSuccess extends $pb.GeneratedMessage {
  factory ExchangeIceCandidateSuccess({
    $core.bool? sent,
  }) {
    final result = create();
    if (sent != null) result.sent = sent;
    return result;
  }

  ExchangeIceCandidateSuccess._();

  factory ExchangeIceCandidateSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExchangeIceCandidateSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExchangeIceCandidateSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'sent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeIceCandidateSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeIceCandidateSuccess copyWith(
          void Function(ExchangeIceCandidateSuccess) updates) =>
      super.copyWith(
              (message) => updates(message as ExchangeIceCandidateSuccess))
          as ExchangeIceCandidateSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExchangeIceCandidateSuccess create() =>
      ExchangeIceCandidateSuccess._();
  @$core.override
  ExchangeIceCandidateSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExchangeIceCandidateSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExchangeIceCandidateSuccess>(create);
  static ExchangeIceCandidateSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get sent => $_getBF(0);
  @$pb.TagNumber(1)
  set sent($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSent() => $_has(0);
  @$pb.TagNumber(1)
  void clearSent() => $_clearField(1);
}

class ExchangeSdpRequest extends $pb.GeneratedMessage {
  factory ExchangeSdpRequest({
    $core.String? accessToken,
    $core.String? callId,
    $core.String? targetUserId,
    SdpMessage? sdp,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (callId != null) result.callId = callId;
    if (targetUserId != null) result.targetUserId = targetUserId;
    if (sdp != null) result.sdp = sdp;
    return result;
  }

  ExchangeSdpRequest._();

  factory ExchangeSdpRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExchangeSdpRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExchangeSdpRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'callId')
    ..aOS(3, _omitFieldNames ? '' : 'targetUserId')
    ..aOM<SdpMessage>(4, _omitFieldNames ? '' : 'sdp',
        subBuilder: SdpMessage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeSdpRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeSdpRequest copyWith(void Function(ExchangeSdpRequest) updates) =>
      super.copyWith((message) => updates(message as ExchangeSdpRequest))
          as ExchangeSdpRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExchangeSdpRequest create() => ExchangeSdpRequest._();
  @$core.override
  ExchangeSdpRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExchangeSdpRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExchangeSdpRequest>(create);
  static ExchangeSdpRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get callId => $_getSZ(1);
  @$pb.TagNumber(2)
  set callId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCallId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get targetUserId => $_getSZ(2);
  @$pb.TagNumber(3)
  set targetUserId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTargetUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTargetUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  SdpMessage get sdp => $_getN(3);
  @$pb.TagNumber(4)
  set sdp(SdpMessage value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSdp() => $_has(3);
  @$pb.TagNumber(4)
  void clearSdp() => $_clearField(4);
  @$pb.TagNumber(4)
  SdpMessage ensureSdp() => $_ensure(3);
}

class SdpMessage extends $pb.GeneratedMessage {
  factory SdpMessage({
    SdpType? type,
    $core.String? sdp,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (sdp != null) result.sdp = sdp;
    return result;
  }

  SdpMessage._();

  factory SdpMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SdpMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SdpMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aE<SdpType>(1, _omitFieldNames ? '' : 'type', enumValues: SdpType.values)
    ..aOS(2, _omitFieldNames ? '' : 'sdp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdpMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdpMessage copyWith(void Function(SdpMessage) updates) =>
      super.copyWith((message) => updates(message as SdpMessage)) as SdpMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SdpMessage create() => SdpMessage._();
  @$core.override
  SdpMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SdpMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SdpMessage>(create);
  static SdpMessage? _defaultInstance;

  @$pb.TagNumber(1)
  SdpType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(SdpType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sdp => $_getSZ(1);
  @$pb.TagNumber(2)
  set sdp($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSdp() => $_has(1);
  @$pb.TagNumber(2)
  void clearSdp() => $_clearField(2);
}

enum ExchangeSdpResponse_Result { success, error, notSet }

class ExchangeSdpResponse extends $pb.GeneratedMessage {
  factory ExchangeSdpResponse({
    ExchangeSdpSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  ExchangeSdpResponse._();

  factory ExchangeSdpResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExchangeSdpResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ExchangeSdpResponse_Result>
      _ExchangeSdpResponse_ResultByTag = {
    1: ExchangeSdpResponse_Result.success,
    2: ExchangeSdpResponse_Result.error,
    0: ExchangeSdpResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExchangeSdpResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<ExchangeSdpSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: ExchangeSdpSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeSdpResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeSdpResponse copyWith(void Function(ExchangeSdpResponse) updates) =>
      super.copyWith((message) => updates(message as ExchangeSdpResponse))
          as ExchangeSdpResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExchangeSdpResponse create() => ExchangeSdpResponse._();
  @$core.override
  ExchangeSdpResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExchangeSdpResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExchangeSdpResponse>(create);
  static ExchangeSdpResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  ExchangeSdpResponse_Result whichResult() =>
      _ExchangeSdpResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ExchangeSdpSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(ExchangeSdpSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  ExchangeSdpSuccess ensureSuccess() => $_ensure(0);

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

class ExchangeSdpSuccess extends $pb.GeneratedMessage {
  factory ExchangeSdpSuccess({
    $core.bool? sent,
  }) {
    final result = create();
    if (sent != null) result.sent = sent;
    return result;
  }

  ExchangeSdpSuccess._();

  factory ExchangeSdpSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExchangeSdpSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExchangeSdpSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'sent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeSdpSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeSdpSuccess copyWith(void Function(ExchangeSdpSuccess) updates) =>
      super.copyWith((message) => updates(message as ExchangeSdpSuccess))
          as ExchangeSdpSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExchangeSdpSuccess create() => ExchangeSdpSuccess._();
  @$core.override
  ExchangeSdpSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExchangeSdpSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExchangeSdpSuccess>(create);
  static ExchangeSdpSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get sent => $_getBF(0);
  @$pb.TagNumber(1)
  set sent($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSent() => $_has(0);
  @$pb.TagNumber(1)
  void clearSent() => $_clearField(1);
}

class GetCallStateRequest extends $pb.GeneratedMessage {
  factory GetCallStateRequest({
    $core.String? accessToken,
    $core.String? callId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (callId != null) result.callId = callId;
    return result;
  }

  GetCallStateRequest._();

  factory GetCallStateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCallStateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCallStateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'callId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCallStateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCallStateRequest copyWith(void Function(GetCallStateRequest) updates) =>
      super.copyWith((message) => updates(message as GetCallStateRequest))
          as GetCallStateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCallStateRequest create() => GetCallStateRequest._();
  @$core.override
  GetCallStateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCallStateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCallStateRequest>(create);
  static GetCallStateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get callId => $_getSZ(1);
  @$pb.TagNumber(2)
  set callId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCallId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallId() => $_clearField(2);
}

enum GetCallStateResponse_Result { success, error, notSet }

class GetCallStateResponse extends $pb.GeneratedMessage {
  factory GetCallStateResponse({
    GetCallStateSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetCallStateResponse._();

  factory GetCallStateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCallStateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetCallStateResponse_Result>
      _GetCallStateResponse_ResultByTag = {
    1: GetCallStateResponse_Result.success,
    2: GetCallStateResponse_Result.error,
    0: GetCallStateResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCallStateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetCallStateSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: GetCallStateSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCallStateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCallStateResponse copyWith(void Function(GetCallStateResponse) updates) =>
      super.copyWith((message) => updates(message as GetCallStateResponse))
          as GetCallStateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCallStateResponse create() => GetCallStateResponse._();
  @$core.override
  GetCallStateResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCallStateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCallStateResponse>(create);
  static GetCallStateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetCallStateResponse_Result whichResult() =>
      _GetCallStateResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetCallStateSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(GetCallStateSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  GetCallStateSuccess ensureSuccess() => $_ensure(0);

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

class GetCallStateSuccess extends $pb.GeneratedMessage {
  factory GetCallStateSuccess({
    $core.String? callId,
    CallType? callType,
    CallState? state,
    $core.bool? isGroupCall,
    $core.String? initiatorId,
    $core.Iterable<CallParticipant>? participants,
    $1.Timestamp? startedAt,
    $core.int? durationSeconds,
  }) {
    final result = create();
    if (callId != null) result.callId = callId;
    if (callType != null) result.callType = callType;
    if (state != null) result.state = state;
    if (isGroupCall != null) result.isGroupCall = isGroupCall;
    if (initiatorId != null) result.initiatorId = initiatorId;
    if (participants != null) result.participants.addAll(participants);
    if (startedAt != null) result.startedAt = startedAt;
    if (durationSeconds != null) result.durationSeconds = durationSeconds;
    return result;
  }

  GetCallStateSuccess._();

  factory GetCallStateSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCallStateSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCallStateSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callId')
    ..aE<CallType>(2, _omitFieldNames ? '' : 'callType',
        enumValues: CallType.values)
    ..aE<CallState>(3, _omitFieldNames ? '' : 'state',
        enumValues: CallState.values)
    ..aOB(4, _omitFieldNames ? '' : 'isGroupCall')
    ..aOS(5, _omitFieldNames ? '' : 'initiatorId')
    ..pPM<CallParticipant>(6, _omitFieldNames ? '' : 'participants',
        subBuilder: CallParticipant.create)
    ..aOM<$1.Timestamp>(7, _omitFieldNames ? '' : 'startedAt',
        subBuilder: $1.Timestamp.create)
    ..aI(8, _omitFieldNames ? '' : 'durationSeconds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCallStateSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCallStateSuccess copyWith(void Function(GetCallStateSuccess) updates) =>
      super.copyWith((message) => updates(message as GetCallStateSuccess))
          as GetCallStateSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCallStateSuccess create() => GetCallStateSuccess._();
  @$core.override
  GetCallStateSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCallStateSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCallStateSuccess>(create);
  static GetCallStateSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get callId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallId() => $_clearField(1);

  @$pb.TagNumber(2)
  CallType get callType => $_getN(1);
  @$pb.TagNumber(2)
  set callType(CallType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCallType() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallType() => $_clearField(2);

  @$pb.TagNumber(3)
  CallState get state => $_getN(2);
  @$pb.TagNumber(3)
  set state(CallState value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasState() => $_has(2);
  @$pb.TagNumber(3)
  void clearState() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isGroupCall => $_getBF(3);
  @$pb.TagNumber(4)
  set isGroupCall($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsGroupCall() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsGroupCall() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get initiatorId => $_getSZ(4);
  @$pb.TagNumber(5)
  set initiatorId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasInitiatorId() => $_has(4);
  @$pb.TagNumber(5)
  void clearInitiatorId() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<CallParticipant> get participants => $_getList(5);

  @$pb.TagNumber(7)
  $1.Timestamp get startedAt => $_getN(6);
  @$pb.TagNumber(7)
  set startedAt($1.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStartedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearStartedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.Timestamp ensureStartedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.int get durationSeconds => $_getIZ(7);
  @$pb.TagNumber(8)
  set durationSeconds($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDurationSeconds() => $_has(7);
  @$pb.TagNumber(8)
  void clearDurationSeconds() => $_clearField(8);
}

class GetCallHistoryRequest extends $pb.GeneratedMessage {
  factory GetCallHistoryRequest({
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

  GetCallHistoryRequest._();

  factory GetCallHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCallHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCallHistoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aI(2, _omitFieldNames ? '' : 'limit')
    ..aOS(3, _omitFieldNames ? '' : 'cursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCallHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCallHistoryRequest copyWith(
          void Function(GetCallHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as GetCallHistoryRequest))
          as GetCallHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCallHistoryRequest create() => GetCallHistoryRequest._();
  @$core.override
  GetCallHistoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCallHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCallHistoryRequest>(create);
  static GetCallHistoryRequest? _defaultInstance;

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

enum GetCallHistoryResponse_Result { success, error, notSet }

class GetCallHistoryResponse extends $pb.GeneratedMessage {
  factory GetCallHistoryResponse({
    GetCallHistorySuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetCallHistoryResponse._();

  factory GetCallHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCallHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetCallHistoryResponse_Result>
      _GetCallHistoryResponse_ResultByTag = {
    1: GetCallHistoryResponse_Result.success,
    2: GetCallHistoryResponse_Result.error,
    0: GetCallHistoryResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCallHistoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetCallHistorySuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: GetCallHistorySuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCallHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCallHistoryResponse copyWith(
          void Function(GetCallHistoryResponse) updates) =>
      super.copyWith((message) => updates(message as GetCallHistoryResponse))
          as GetCallHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCallHistoryResponse create() => GetCallHistoryResponse._();
  @$core.override
  GetCallHistoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCallHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCallHistoryResponse>(create);
  static GetCallHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetCallHistoryResponse_Result whichResult() =>
      _GetCallHistoryResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetCallHistorySuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(GetCallHistorySuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  GetCallHistorySuccess ensureSuccess() => $_ensure(0);

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

class GetCallHistorySuccess extends $pb.GeneratedMessage {
  factory GetCallHistorySuccess({
    $core.Iterable<CallHistoryEntry>? calls,
    $core.String? nextCursor,
  }) {
    final result = create();
    if (calls != null) result.calls.addAll(calls);
    if (nextCursor != null) result.nextCursor = nextCursor;
    return result;
  }

  GetCallHistorySuccess._();

  factory GetCallHistorySuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCallHistorySuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCallHistorySuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..pPM<CallHistoryEntry>(1, _omitFieldNames ? '' : 'calls',
        subBuilder: CallHistoryEntry.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextCursor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCallHistorySuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCallHistorySuccess copyWith(
          void Function(GetCallHistorySuccess) updates) =>
      super.copyWith((message) => updates(message as GetCallHistorySuccess))
          as GetCallHistorySuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCallHistorySuccess create() => GetCallHistorySuccess._();
  @$core.override
  GetCallHistorySuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCallHistorySuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCallHistorySuccess>(create);
  static GetCallHistorySuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CallHistoryEntry> get calls => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextCursor => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextCursor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextCursor() => $_clearField(2);
}

class CallHistoryEntry extends $pb.GeneratedMessage {
  factory CallHistoryEntry({
    $core.String? callId,
    CallType? callType,
    $core.bool? isGroupCall,
    $core.String? groupId,
    $core.String? otherUserId,
    $core.String? otherUserName,
    $core.bool? isOutgoing,
    CallEndReason? endReason,
    $1.Timestamp? startedAt,
    $core.int? durationSeconds,
  }) {
    final result = create();
    if (callId != null) result.callId = callId;
    if (callType != null) result.callType = callType;
    if (isGroupCall != null) result.isGroupCall = isGroupCall;
    if (groupId != null) result.groupId = groupId;
    if (otherUserId != null) result.otherUserId = otherUserId;
    if (otherUserName != null) result.otherUserName = otherUserName;
    if (isOutgoing != null) result.isOutgoing = isOutgoing;
    if (endReason != null) result.endReason = endReason;
    if (startedAt != null) result.startedAt = startedAt;
    if (durationSeconds != null) result.durationSeconds = durationSeconds;
    return result;
  }

  CallHistoryEntry._();

  factory CallHistoryEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CallHistoryEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CallHistoryEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callId')
    ..aE<CallType>(2, _omitFieldNames ? '' : 'callType',
        enumValues: CallType.values)
    ..aOB(3, _omitFieldNames ? '' : 'isGroupCall')
    ..aOS(4, _omitFieldNames ? '' : 'groupId')
    ..aOS(5, _omitFieldNames ? '' : 'otherUserId')
    ..aOS(6, _omitFieldNames ? '' : 'otherUserName')
    ..aOB(7, _omitFieldNames ? '' : 'isOutgoing')
    ..aE<CallEndReason>(8, _omitFieldNames ? '' : 'endReason',
        enumValues: CallEndReason.values)
    ..aOM<$1.Timestamp>(9, _omitFieldNames ? '' : 'startedAt',
        subBuilder: $1.Timestamp.create)
    ..aI(10, _omitFieldNames ? '' : 'durationSeconds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallHistoryEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallHistoryEntry copyWith(void Function(CallHistoryEntry) updates) =>
      super.copyWith((message) => updates(message as CallHistoryEntry))
          as CallHistoryEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CallHistoryEntry create() => CallHistoryEntry._();
  @$core.override
  CallHistoryEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CallHistoryEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CallHistoryEntry>(create);
  static CallHistoryEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get callId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallId() => $_clearField(1);

  @$pb.TagNumber(2)
  CallType get callType => $_getN(1);
  @$pb.TagNumber(2)
  set callType(CallType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCallType() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isGroupCall => $_getBF(2);
  @$pb.TagNumber(3)
  set isGroupCall($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsGroupCall() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsGroupCall() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get groupId => $_getSZ(3);
  @$pb.TagNumber(4)
  set groupId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGroupId() => $_has(3);
  @$pb.TagNumber(4)
  void clearGroupId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get otherUserId => $_getSZ(4);
  @$pb.TagNumber(5)
  set otherUserId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOtherUserId() => $_has(4);
  @$pb.TagNumber(5)
  void clearOtherUserId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get otherUserName => $_getSZ(5);
  @$pb.TagNumber(6)
  set otherUserName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasOtherUserName() => $_has(5);
  @$pb.TagNumber(6)
  void clearOtherUserName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isOutgoing => $_getBF(6);
  @$pb.TagNumber(7)
  set isOutgoing($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsOutgoing() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsOutgoing() => $_clearField(7);

  @$pb.TagNumber(8)
  CallEndReason get endReason => $_getN(7);
  @$pb.TagNumber(8)
  set endReason(CallEndReason value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasEndReason() => $_has(7);
  @$pb.TagNumber(8)
  void clearEndReason() => $_clearField(8);

  @$pb.TagNumber(9)
  $1.Timestamp get startedAt => $_getN(8);
  @$pb.TagNumber(9)
  set startedAt($1.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasStartedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearStartedAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $1.Timestamp ensureStartedAt() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.int get durationSeconds => $_getIZ(9);
  @$pb.TagNumber(10)
  set durationSeconds($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDurationSeconds() => $_has(9);
  @$pb.TagNumber(10)
  void clearDurationSeconds() => $_clearField(10);
}

class StreamCallEventsRequest extends $pb.GeneratedMessage {
  factory StreamCallEventsRequest({
    $core.String? accessToken,
    $core.String? callId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (callId != null) result.callId = callId;
    return result;
  }

  StreamCallEventsRequest._();

  factory StreamCallEventsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamCallEventsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamCallEventsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'callId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamCallEventsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamCallEventsRequest copyWith(
          void Function(StreamCallEventsRequest) updates) =>
      super.copyWith((message) => updates(message as StreamCallEventsRequest))
          as StreamCallEventsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamCallEventsRequest create() => StreamCallEventsRequest._();
  @$core.override
  StreamCallEventsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamCallEventsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamCallEventsRequest>(create);
  static StreamCallEventsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get callId => $_getSZ(1);
  @$pb.TagNumber(2)
  set callId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCallId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallId() => $_clearField(2);
}

/// Request to subscribe to incoming call notifications
class SubscribeToIncomingCallsRequest extends $pb.GeneratedMessage {
  factory SubscribeToIncomingCallsRequest({
    $core.String? accessToken,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    return result;
  }

  SubscribeToIncomingCallsRequest._();

  factory SubscribeToIncomingCallsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubscribeToIncomingCallsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribeToIncomingCallsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeToIncomingCallsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeToIncomingCallsRequest copyWith(
          void Function(SubscribeToIncomingCallsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SubscribeToIncomingCallsRequest))
          as SubscribeToIncomingCallsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeToIncomingCallsRequest create() =>
      SubscribeToIncomingCallsRequest._();
  @$core.override
  SubscribeToIncomingCallsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubscribeToIncomingCallsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribeToIncomingCallsRequest>(
          create);
  static SubscribeToIncomingCallsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);
}

/// Notification about an incoming call
class IncomingCallNotification extends $pb.GeneratedMessage {
  factory IncomingCallNotification({
    $core.String? callId,
    CallType? callType,
    $core.bool? isGroupCall,
    $core.String? groupId,
    $core.String? callerId,
    $core.String? callerDisplayName,
    $core.String? callerAvatarUrl,
    $core.Iterable<IceServer>? iceServers,
    $1.Timestamp? createdAt,
  }) {
    final result = create();
    if (callId != null) result.callId = callId;
    if (callType != null) result.callType = callType;
    if (isGroupCall != null) result.isGroupCall = isGroupCall;
    if (groupId != null) result.groupId = groupId;
    if (callerId != null) result.callerId = callerId;
    if (callerDisplayName != null) result.callerDisplayName = callerDisplayName;
    if (callerAvatarUrl != null) result.callerAvatarUrl = callerAvatarUrl;
    if (iceServers != null) result.iceServers.addAll(iceServers);
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  IncomingCallNotification._();

  factory IncomingCallNotification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IncomingCallNotification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IncomingCallNotification',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'callId')
    ..aE<CallType>(2, _omitFieldNames ? '' : 'callType',
        enumValues: CallType.values)
    ..aOB(3, _omitFieldNames ? '' : 'isGroupCall')
    ..aOS(4, _omitFieldNames ? '' : 'groupId')
    ..aOS(5, _omitFieldNames ? '' : 'callerId')
    ..aOS(6, _omitFieldNames ? '' : 'callerDisplayName')
    ..aOS(7, _omitFieldNames ? '' : 'callerAvatarUrl')
    ..pPM<IceServer>(8, _omitFieldNames ? '' : 'iceServers',
        subBuilder: IceServer.create)
    ..aOM<$1.Timestamp>(9, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IncomingCallNotification clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IncomingCallNotification copyWith(
          void Function(IncomingCallNotification) updates) =>
      super.copyWith((message) => updates(message as IncomingCallNotification))
          as IncomingCallNotification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IncomingCallNotification create() => IncomingCallNotification._();
  @$core.override
  IncomingCallNotification createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IncomingCallNotification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IncomingCallNotification>(create);
  static IncomingCallNotification? _defaultInstance;

  /// Unique call ID
  @$pb.TagNumber(1)
  $core.String get callId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallId() => $_clearField(1);

  /// Type of call (voice or video)
  @$pb.TagNumber(2)
  CallType get callType => $_getN(1);
  @$pb.TagNumber(2)
  set callType(CallType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCallType() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallType() => $_clearField(2);

  /// Whether this is a group call
  @$pb.TagNumber(3)
  $core.bool get isGroupCall => $_getBF(2);
  @$pb.TagNumber(3)
  set isGroupCall($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsGroupCall() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsGroupCall() => $_clearField(3);

  /// Group ID if it's a group call
  @$pb.TagNumber(4)
  $core.String get groupId => $_getSZ(3);
  @$pb.TagNumber(4)
  set groupId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGroupId() => $_has(3);
  @$pb.TagNumber(4)
  void clearGroupId() => $_clearField(4);

  /// Caller information
  @$pb.TagNumber(5)
  $core.String get callerId => $_getSZ(4);
  @$pb.TagNumber(5)
  set callerId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCallerId() => $_has(4);
  @$pb.TagNumber(5)
  void clearCallerId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get callerDisplayName => $_getSZ(5);
  @$pb.TagNumber(6)
  set callerDisplayName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCallerDisplayName() => $_has(5);
  @$pb.TagNumber(6)
  void clearCallerDisplayName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get callerAvatarUrl => $_getSZ(6);
  @$pb.TagNumber(7)
  set callerAvatarUrl($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCallerAvatarUrl() => $_has(6);
  @$pb.TagNumber(7)
  void clearCallerAvatarUrl() => $_clearField(7);

  /// ICE servers for WebRTC connection
  @$pb.TagNumber(8)
  $pb.PbList<IceServer> get iceServers => $_getList(7);

  /// When the call was initiated
  @$pb.TagNumber(9)
  $1.Timestamp get createdAt => $_getN(8);
  @$pb.TagNumber(9)
  set createdAt($1.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $1.Timestamp ensureCreatedAt() => $_ensure(8);
}

enum CallEvent_Event {
  stateChanged,
  participantJoined,
  participantLeft,
  participantMuted,
  participantVideoChanged,
  participantScreenShareChanged,
  participantSpeaking,
  iceCandidateReceived,
  sdpReceived,
  sframeKeyRotated,
  qualityChanged,
  notSet
}

class CallEvent extends $pb.GeneratedMessage {
  factory CallEvent({
    $core.String? callId,
    $1.Timestamp? timestamp,
    CallStateChanged? stateChanged,
    ParticipantJoined? participantJoined,
    ParticipantLeft? participantLeft,
    ParticipantMuted? participantMuted,
    ParticipantVideoChanged? participantVideoChanged,
    ParticipantScreenShareChanged? participantScreenShareChanged,
    ParticipantSpeaking? participantSpeaking,
    IceCandidateReceived? iceCandidateReceived,
    SdpReceived? sdpReceived,
    SFrameKeyRotated? sframeKeyRotated,
    CallQualityChanged? qualityChanged,
  }) {
    final result = create();
    if (callId != null) result.callId = callId;
    if (timestamp != null) result.timestamp = timestamp;
    if (stateChanged != null) result.stateChanged = stateChanged;
    if (participantJoined != null) result.participantJoined = participantJoined;
    if (participantLeft != null) result.participantLeft = participantLeft;
    if (participantMuted != null) result.participantMuted = participantMuted;
    if (participantVideoChanged != null)
      result.participantVideoChanged = participantVideoChanged;
    if (participantScreenShareChanged != null)
      result.participantScreenShareChanged = participantScreenShareChanged;
    if (participantSpeaking != null)
      result.participantSpeaking = participantSpeaking;
    if (iceCandidateReceived != null)
      result.iceCandidateReceived = iceCandidateReceived;
    if (sdpReceived != null) result.sdpReceived = sdpReceived;
    if (sframeKeyRotated != null) result.sframeKeyRotated = sframeKeyRotated;
    if (qualityChanged != null) result.qualityChanged = qualityChanged;
    return result;
  }

  CallEvent._();

  factory CallEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CallEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, CallEvent_Event> _CallEvent_EventByTag = {
    3: CallEvent_Event.stateChanged,
    4: CallEvent_Event.participantJoined,
    5: CallEvent_Event.participantLeft,
    6: CallEvent_Event.participantMuted,
    7: CallEvent_Event.participantVideoChanged,
    8: CallEvent_Event.participantScreenShareChanged,
    9: CallEvent_Event.participantSpeaking,
    10: CallEvent_Event.iceCandidateReceived,
    11: CallEvent_Event.sdpReceived,
    12: CallEvent_Event.sframeKeyRotated,
    13: CallEvent_Event.qualityChanged,
    0: CallEvent_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CallEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13])
    ..aOS(1, _omitFieldNames ? '' : 'callId')
    ..aOM<$1.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $1.Timestamp.create)
    ..aOM<CallStateChanged>(3, _omitFieldNames ? '' : 'stateChanged',
        subBuilder: CallStateChanged.create)
    ..aOM<ParticipantJoined>(4, _omitFieldNames ? '' : 'participantJoined',
        subBuilder: ParticipantJoined.create)
    ..aOM<ParticipantLeft>(5, _omitFieldNames ? '' : 'participantLeft',
        subBuilder: ParticipantLeft.create)
    ..aOM<ParticipantMuted>(6, _omitFieldNames ? '' : 'participantMuted',
        subBuilder: ParticipantMuted.create)
    ..aOM<ParticipantVideoChanged>(
        7, _omitFieldNames ? '' : 'participantVideoChanged',
        subBuilder: ParticipantVideoChanged.create)
    ..aOM<ParticipantScreenShareChanged>(
        8, _omitFieldNames ? '' : 'participantScreenShareChanged',
        subBuilder: ParticipantScreenShareChanged.create)
    ..aOM<ParticipantSpeaking>(9, _omitFieldNames ? '' : 'participantSpeaking',
        subBuilder: ParticipantSpeaking.create)
    ..aOM<IceCandidateReceived>(
        10, _omitFieldNames ? '' : 'iceCandidateReceived',
        subBuilder: IceCandidateReceived.create)
    ..aOM<SdpReceived>(11, _omitFieldNames ? '' : 'sdpReceived',
        subBuilder: SdpReceived.create)
    ..aOM<SFrameKeyRotated>(12, _omitFieldNames ? '' : 'sframeKeyRotated',
        subBuilder: SFrameKeyRotated.create)
    ..aOM<CallQualityChanged>(13, _omitFieldNames ? '' : 'qualityChanged',
        subBuilder: CallQualityChanged.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallEvent copyWith(void Function(CallEvent) updates) =>
      super.copyWith((message) => updates(message as CallEvent)) as CallEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CallEvent create() => CallEvent._();
  @$core.override
  CallEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CallEvent getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CallEvent>(create);
  static CallEvent? _defaultInstance;

  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  CallEvent_Event whichEvent() => _CallEvent_EventByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  void clearEvent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get callId => $_getSZ(0);
  @$pb.TagNumber(1)
  set callId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCallId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCallId() => $_clearField(1);

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

  @$pb.TagNumber(3)
  CallStateChanged get stateChanged => $_getN(2);
  @$pb.TagNumber(3)
  set stateChanged(CallStateChanged value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStateChanged() => $_has(2);
  @$pb.TagNumber(3)
  void clearStateChanged() => $_clearField(3);
  @$pb.TagNumber(3)
  CallStateChanged ensureStateChanged() => $_ensure(2);

  @$pb.TagNumber(4)
  ParticipantJoined get participantJoined => $_getN(3);
  @$pb.TagNumber(4)
  set participantJoined(ParticipantJoined value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasParticipantJoined() => $_has(3);
  @$pb.TagNumber(4)
  void clearParticipantJoined() => $_clearField(4);
  @$pb.TagNumber(4)
  ParticipantJoined ensureParticipantJoined() => $_ensure(3);

  @$pb.TagNumber(5)
  ParticipantLeft get participantLeft => $_getN(4);
  @$pb.TagNumber(5)
  set participantLeft(ParticipantLeft value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasParticipantLeft() => $_has(4);
  @$pb.TagNumber(5)
  void clearParticipantLeft() => $_clearField(5);
  @$pb.TagNumber(5)
  ParticipantLeft ensureParticipantLeft() => $_ensure(4);

  @$pb.TagNumber(6)
  ParticipantMuted get participantMuted => $_getN(5);
  @$pb.TagNumber(6)
  set participantMuted(ParticipantMuted value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasParticipantMuted() => $_has(5);
  @$pb.TagNumber(6)
  void clearParticipantMuted() => $_clearField(6);
  @$pb.TagNumber(6)
  ParticipantMuted ensureParticipantMuted() => $_ensure(5);

  @$pb.TagNumber(7)
  ParticipantVideoChanged get participantVideoChanged => $_getN(6);
  @$pb.TagNumber(7)
  set participantVideoChanged(ParticipantVideoChanged value) =>
      $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasParticipantVideoChanged() => $_has(6);
  @$pb.TagNumber(7)
  void clearParticipantVideoChanged() => $_clearField(7);
  @$pb.TagNumber(7)
  ParticipantVideoChanged ensureParticipantVideoChanged() => $_ensure(6);

  @$pb.TagNumber(8)
  ParticipantScreenShareChanged get participantScreenShareChanged => $_getN(7);
  @$pb.TagNumber(8)
  set participantScreenShareChanged(ParticipantScreenShareChanged value) =>
      $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasParticipantScreenShareChanged() => $_has(7);
  @$pb.TagNumber(8)
  void clearParticipantScreenShareChanged() => $_clearField(8);
  @$pb.TagNumber(8)
  ParticipantScreenShareChanged ensureParticipantScreenShareChanged() =>
      $_ensure(7);

  @$pb.TagNumber(9)
  ParticipantSpeaking get participantSpeaking => $_getN(8);
  @$pb.TagNumber(9)
  set participantSpeaking(ParticipantSpeaking value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasParticipantSpeaking() => $_has(8);
  @$pb.TagNumber(9)
  void clearParticipantSpeaking() => $_clearField(9);
  @$pb.TagNumber(9)
  ParticipantSpeaking ensureParticipantSpeaking() => $_ensure(8);

  @$pb.TagNumber(10)
  IceCandidateReceived get iceCandidateReceived => $_getN(9);
  @$pb.TagNumber(10)
  set iceCandidateReceived(IceCandidateReceived value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasIceCandidateReceived() => $_has(9);
  @$pb.TagNumber(10)
  void clearIceCandidateReceived() => $_clearField(10);
  @$pb.TagNumber(10)
  IceCandidateReceived ensureIceCandidateReceived() => $_ensure(9);

  @$pb.TagNumber(11)
  SdpReceived get sdpReceived => $_getN(10);
  @$pb.TagNumber(11)
  set sdpReceived(SdpReceived value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasSdpReceived() => $_has(10);
  @$pb.TagNumber(11)
  void clearSdpReceived() => $_clearField(11);
  @$pb.TagNumber(11)
  SdpReceived ensureSdpReceived() => $_ensure(10);

  @$pb.TagNumber(12)
  SFrameKeyRotated get sframeKeyRotated => $_getN(11);
  @$pb.TagNumber(12)
  set sframeKeyRotated(SFrameKeyRotated value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasSframeKeyRotated() => $_has(11);
  @$pb.TagNumber(12)
  void clearSframeKeyRotated() => $_clearField(12);
  @$pb.TagNumber(12)
  SFrameKeyRotated ensureSframeKeyRotated() => $_ensure(11);

  @$pb.TagNumber(13)
  CallQualityChanged get qualityChanged => $_getN(12);
  @$pb.TagNumber(13)
  set qualityChanged(CallQualityChanged value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasQualityChanged() => $_has(12);
  @$pb.TagNumber(13)
  void clearQualityChanged() => $_clearField(13);
  @$pb.TagNumber(13)
  CallQualityChanged ensureQualityChanged() => $_ensure(12);
}

class CallStateChanged extends $pb.GeneratedMessage {
  factory CallStateChanged({
    CallState? oldState,
    CallState? newState,
    CallEndReason? endReason,
  }) {
    final result = create();
    if (oldState != null) result.oldState = oldState;
    if (newState != null) result.newState = newState;
    if (endReason != null) result.endReason = endReason;
    return result;
  }

  CallStateChanged._();

  factory CallStateChanged.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CallStateChanged.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CallStateChanged',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aE<CallState>(1, _omitFieldNames ? '' : 'oldState',
        enumValues: CallState.values)
    ..aE<CallState>(2, _omitFieldNames ? '' : 'newState',
        enumValues: CallState.values)
    ..aE<CallEndReason>(3, _omitFieldNames ? '' : 'endReason',
        enumValues: CallEndReason.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallStateChanged clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallStateChanged copyWith(void Function(CallStateChanged) updates) =>
      super.copyWith((message) => updates(message as CallStateChanged))
          as CallStateChanged;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CallStateChanged create() => CallStateChanged._();
  @$core.override
  CallStateChanged createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CallStateChanged getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CallStateChanged>(create);
  static CallStateChanged? _defaultInstance;

  @$pb.TagNumber(1)
  CallState get oldState => $_getN(0);
  @$pb.TagNumber(1)
  set oldState(CallState value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOldState() => $_has(0);
  @$pb.TagNumber(1)
  void clearOldState() => $_clearField(1);

  @$pb.TagNumber(2)
  CallState get newState => $_getN(1);
  @$pb.TagNumber(2)
  set newState(CallState value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasNewState() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewState() => $_clearField(2);

  @$pb.TagNumber(3)
  CallEndReason get endReason => $_getN(2);
  @$pb.TagNumber(3)
  set endReason(CallEndReason value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEndReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndReason() => $_clearField(3);
}

class ParticipantJoined extends $pb.GeneratedMessage {
  factory ParticipantJoined({
    CallParticipant? participant,
  }) {
    final result = create();
    if (participant != null) result.participant = participant;
    return result;
  }

  ParticipantJoined._();

  factory ParticipantJoined.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ParticipantJoined.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ParticipantJoined',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOM<CallParticipant>(1, _omitFieldNames ? '' : 'participant',
        subBuilder: CallParticipant.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantJoined clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantJoined copyWith(void Function(ParticipantJoined) updates) =>
      super.copyWith((message) => updates(message as ParticipantJoined))
          as ParticipantJoined;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParticipantJoined create() => ParticipantJoined._();
  @$core.override
  ParticipantJoined createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ParticipantJoined getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ParticipantJoined>(create);
  static ParticipantJoined? _defaultInstance;

  @$pb.TagNumber(1)
  CallParticipant get participant => $_getN(0);
  @$pb.TagNumber(1)
  set participant(CallParticipant value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasParticipant() => $_has(0);
  @$pb.TagNumber(1)
  void clearParticipant() => $_clearField(1);
  @$pb.TagNumber(1)
  CallParticipant ensureParticipant() => $_ensure(0);
}

class ParticipantLeft extends $pb.GeneratedMessage {
  factory ParticipantLeft({
    $core.String? userId,
    $core.String? reason,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (reason != null) result.reason = reason;
    return result;
  }

  ParticipantLeft._();

  factory ParticipantLeft.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ParticipantLeft.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ParticipantLeft',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantLeft clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantLeft copyWith(void Function(ParticipantLeft) updates) =>
      super.copyWith((message) => updates(message as ParticipantLeft))
          as ParticipantLeft;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParticipantLeft create() => ParticipantLeft._();
  @$core.override
  ParticipantLeft createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ParticipantLeft getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ParticipantLeft>(create);
  static ParticipantLeft? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class ParticipantMuted extends $pb.GeneratedMessage {
  factory ParticipantMuted({
    $core.String? userId,
    $core.bool? isMuted,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (isMuted != null) result.isMuted = isMuted;
    return result;
  }

  ParticipantMuted._();

  factory ParticipantMuted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ParticipantMuted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ParticipantMuted',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOB(2, _omitFieldNames ? '' : 'isMuted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantMuted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantMuted copyWith(void Function(ParticipantMuted) updates) =>
      super.copyWith((message) => updates(message as ParticipantMuted))
          as ParticipantMuted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParticipantMuted create() => ParticipantMuted._();
  @$core.override
  ParticipantMuted createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ParticipantMuted getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ParticipantMuted>(create);
  static ParticipantMuted? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isMuted => $_getBF(1);
  @$pb.TagNumber(2)
  set isMuted($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsMuted() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsMuted() => $_clearField(2);
}

class ParticipantVideoChanged extends $pb.GeneratedMessage {
  factory ParticipantVideoChanged({
    $core.String? userId,
    $core.bool? hasVideo,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (hasVideo != null) result.hasVideo = hasVideo;
    return result;
  }

  ParticipantVideoChanged._();

  factory ParticipantVideoChanged.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ParticipantVideoChanged.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ParticipantVideoChanged',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOB(2, _omitFieldNames ? '' : 'hasVideo')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantVideoChanged clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantVideoChanged copyWith(
          void Function(ParticipantVideoChanged) updates) =>
      super.copyWith((message) => updates(message as ParticipantVideoChanged))
          as ParticipantVideoChanged;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParticipantVideoChanged create() => ParticipantVideoChanged._();
  @$core.override
  ParticipantVideoChanged createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ParticipantVideoChanged getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ParticipantVideoChanged>(create);
  static ParticipantVideoChanged? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get hasVideo => $_getBF(1);
  @$pb.TagNumber(2)
  set hasVideo($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHasVideo() => $_has(1);
  @$pb.TagNumber(2)
  void clearHasVideo() => $_clearField(2);
}

class ParticipantScreenShareChanged extends $pb.GeneratedMessage {
  factory ParticipantScreenShareChanged({
    $core.String? userId,
    $core.bool? isScreenSharing,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (isScreenSharing != null) result.isScreenSharing = isScreenSharing;
    return result;
  }

  ParticipantScreenShareChanged._();

  factory ParticipantScreenShareChanged.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ParticipantScreenShareChanged.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ParticipantScreenShareChanged',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOB(2, _omitFieldNames ? '' : 'isScreenSharing')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantScreenShareChanged clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantScreenShareChanged copyWith(
          void Function(ParticipantScreenShareChanged) updates) =>
      super.copyWith(
              (message) => updates(message as ParticipantScreenShareChanged))
          as ParticipantScreenShareChanged;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParticipantScreenShareChanged create() =>
      ParticipantScreenShareChanged._();
  @$core.override
  ParticipantScreenShareChanged createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ParticipantScreenShareChanged getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ParticipantScreenShareChanged>(create);
  static ParticipantScreenShareChanged? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isScreenSharing => $_getBF(1);
  @$pb.TagNumber(2)
  set isScreenSharing($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsScreenSharing() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsScreenSharing() => $_clearField(2);
}

class ParticipantSpeaking extends $pb.GeneratedMessage {
  factory ParticipantSpeaking({
    $core.String? userId,
    $core.bool? isSpeaking,
    $core.double? audioLevel,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (isSpeaking != null) result.isSpeaking = isSpeaking;
    if (audioLevel != null) result.audioLevel = audioLevel;
    return result;
  }

  ParticipantSpeaking._();

  factory ParticipantSpeaking.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ParticipantSpeaking.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ParticipantSpeaking',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOB(2, _omitFieldNames ? '' : 'isSpeaking')
    ..aD(3, _omitFieldNames ? '' : 'audioLevel', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantSpeaking clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantSpeaking copyWith(void Function(ParticipantSpeaking) updates) =>
      super.copyWith((message) => updates(message as ParticipantSpeaking))
          as ParticipantSpeaking;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParticipantSpeaking create() => ParticipantSpeaking._();
  @$core.override
  ParticipantSpeaking createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ParticipantSpeaking getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ParticipantSpeaking>(create);
  static ParticipantSpeaking? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isSpeaking => $_getBF(1);
  @$pb.TagNumber(2)
  set isSpeaking($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsSpeaking() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsSpeaking() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get audioLevel => $_getN(2);
  @$pb.TagNumber(3)
  set audioLevel($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAudioLevel() => $_has(2);
  @$pb.TagNumber(3)
  void clearAudioLevel() => $_clearField(3);
}

class IceCandidateReceived extends $pb.GeneratedMessage {
  factory IceCandidateReceived({
    $core.String? fromUserId,
    IceCandidate? candidate,
  }) {
    final result = create();
    if (fromUserId != null) result.fromUserId = fromUserId;
    if (candidate != null) result.candidate = candidate;
    return result;
  }

  IceCandidateReceived._();

  factory IceCandidateReceived.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IceCandidateReceived.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IceCandidateReceived',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fromUserId')
    ..aOM<IceCandidate>(2, _omitFieldNames ? '' : 'candidate',
        subBuilder: IceCandidate.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IceCandidateReceived clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IceCandidateReceived copyWith(void Function(IceCandidateReceived) updates) =>
      super.copyWith((message) => updates(message as IceCandidateReceived))
          as IceCandidateReceived;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IceCandidateReceived create() => IceCandidateReceived._();
  @$core.override
  IceCandidateReceived createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IceCandidateReceived getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IceCandidateReceived>(create);
  static IceCandidateReceived? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fromUserId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fromUserId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  IceCandidate get candidate => $_getN(1);
  @$pb.TagNumber(2)
  set candidate(IceCandidate value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCandidate() => $_has(1);
  @$pb.TagNumber(2)
  void clearCandidate() => $_clearField(2);
  @$pb.TagNumber(2)
  IceCandidate ensureCandidate() => $_ensure(1);
}

class SdpReceived extends $pb.GeneratedMessage {
  factory SdpReceived({
    $core.String? fromUserId,
    SdpMessage? sdp,
  }) {
    final result = create();
    if (fromUserId != null) result.fromUserId = fromUserId;
    if (sdp != null) result.sdp = sdp;
    return result;
  }

  SdpReceived._();

  factory SdpReceived.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SdpReceived.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SdpReceived',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fromUserId')
    ..aOM<SdpMessage>(2, _omitFieldNames ? '' : 'sdp',
        subBuilder: SdpMessage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdpReceived clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdpReceived copyWith(void Function(SdpReceived) updates) =>
      super.copyWith((message) => updates(message as SdpReceived))
          as SdpReceived;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SdpReceived create() => SdpReceived._();
  @$core.override
  SdpReceived createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SdpReceived getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SdpReceived>(create);
  static SdpReceived? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fromUserId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fromUserId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  SdpMessage get sdp => $_getN(1);
  @$pb.TagNumber(2)
  set sdp(SdpMessage value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSdp() => $_has(1);
  @$pb.TagNumber(2)
  void clearSdp() => $_clearField(2);
  @$pb.TagNumber(2)
  SdpMessage ensureSdp() => $_ensure(1);
}

class SFrameKeyRotated extends $pb.GeneratedMessage {
  factory SFrameKeyRotated({
    $core.String? fromUserId,
    $core.int? newKeyId,
    $core.List<$core.int>? encryptedKeyMaterial,
  }) {
    final result = create();
    if (fromUserId != null) result.fromUserId = fromUserId;
    if (newKeyId != null) result.newKeyId = newKeyId;
    if (encryptedKeyMaterial != null)
      result.encryptedKeyMaterial = encryptedKeyMaterial;
    return result;
  }

  SFrameKeyRotated._();

  factory SFrameKeyRotated.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SFrameKeyRotated.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SFrameKeyRotated',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fromUserId')
    ..aI(2, _omitFieldNames ? '' : 'newKeyId', fieldType: $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'encryptedKeyMaterial', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SFrameKeyRotated clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SFrameKeyRotated copyWith(void Function(SFrameKeyRotated) updates) =>
      super.copyWith((message) => updates(message as SFrameKeyRotated))
          as SFrameKeyRotated;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SFrameKeyRotated create() => SFrameKeyRotated._();
  @$core.override
  SFrameKeyRotated createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SFrameKeyRotated getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SFrameKeyRotated>(create);
  static SFrameKeyRotated? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fromUserId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fromUserId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get newKeyId => $_getIZ(1);
  @$pb.TagNumber(2)
  set newKeyId($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewKeyId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewKeyId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get encryptedKeyMaterial => $_getN(2);
  @$pb.TagNumber(3)
  set encryptedKeyMaterial($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEncryptedKeyMaterial() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncryptedKeyMaterial() => $_clearField(3);
}

class CallQualityChanged extends $pb.GeneratedMessage {
  factory CallQualityChanged({
    CallQuality? quality,
  }) {
    final result = create();
    if (quality != null) result.quality = quality;
    return result;
  }

  CallQualityChanged._();

  factory CallQualityChanged.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CallQualityChanged.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CallQualityChanged',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aE<CallQuality>(1, _omitFieldNames ? '' : 'quality',
        enumValues: CallQuality.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallQualityChanged clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallQualityChanged copyWith(void Function(CallQualityChanged) updates) =>
      super.copyWith((message) => updates(message as CallQualityChanged))
          as CallQualityChanged;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CallQualityChanged create() => CallQualityChanged._();
  @$core.override
  CallQualityChanged createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CallQualityChanged getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CallQualityChanged>(create);
  static CallQualityChanged? _defaultInstance;

  @$pb.TagNumber(1)
  CallQuality get quality => $_getN(0);
  @$pb.TagNumber(1)
  set quality(CallQuality value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasQuality() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuality() => $_clearField(1);
}

class ExchangeSFrameKeyRequest extends $pb.GeneratedMessage {
  factory ExchangeSFrameKeyRequest({
    $core.String? accessToken,
    $core.String? callId,
    $core.Iterable<ParticipantKeyPackage>? keyPackages,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (callId != null) result.callId = callId;
    if (keyPackages != null) result.keyPackages.addAll(keyPackages);
    return result;
  }

  ExchangeSFrameKeyRequest._();

  factory ExchangeSFrameKeyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExchangeSFrameKeyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExchangeSFrameKeyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'callId')
    ..pPM<ParticipantKeyPackage>(3, _omitFieldNames ? '' : 'keyPackages',
        subBuilder: ParticipantKeyPackage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeSFrameKeyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeSFrameKeyRequest copyWith(
          void Function(ExchangeSFrameKeyRequest) updates) =>
      super.copyWith((message) => updates(message as ExchangeSFrameKeyRequest))
          as ExchangeSFrameKeyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExchangeSFrameKeyRequest create() => ExchangeSFrameKeyRequest._();
  @$core.override
  ExchangeSFrameKeyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExchangeSFrameKeyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExchangeSFrameKeyRequest>(create);
  static ExchangeSFrameKeyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get callId => $_getSZ(1);
  @$pb.TagNumber(2)
  set callId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCallId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallId() => $_clearField(2);

  /// Key material encrypted for each participant
  @$pb.TagNumber(3)
  $pb.PbList<ParticipantKeyPackage> get keyPackages => $_getList(2);
}

class ParticipantKeyPackage extends $pb.GeneratedMessage {
  factory ParticipantKeyPackage({
    $core.String? userId,
    $core.List<$core.int>? encryptedKeyMaterial,
    $core.int? keyId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (encryptedKeyMaterial != null)
      result.encryptedKeyMaterial = encryptedKeyMaterial;
    if (keyId != null) result.keyId = keyId;
    return result;
  }

  ParticipantKeyPackage._();

  factory ParticipantKeyPackage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ParticipantKeyPackage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ParticipantKeyPackage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'encryptedKeyMaterial', $pb.PbFieldType.OY)
    ..aI(3, _omitFieldNames ? '' : 'keyId', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantKeyPackage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantKeyPackage copyWith(
          void Function(ParticipantKeyPackage) updates) =>
      super.copyWith((message) => updates(message as ParticipantKeyPackage))
          as ParticipantKeyPackage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParticipantKeyPackage create() => ParticipantKeyPackage._();
  @$core.override
  ParticipantKeyPackage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ParticipantKeyPackage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ParticipantKeyPackage>(create);
  static ParticipantKeyPackage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get encryptedKeyMaterial => $_getN(1);
  @$pb.TagNumber(2)
  set encryptedKeyMaterial($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEncryptedKeyMaterial() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptedKeyMaterial() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get keyId => $_getIZ(2);
  @$pb.TagNumber(3)
  set keyId($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKeyId() => $_has(2);
  @$pb.TagNumber(3)
  void clearKeyId() => $_clearField(3);
}

enum ExchangeSFrameKeyResponse_Result { success, error, notSet }

class ExchangeSFrameKeyResponse extends $pb.GeneratedMessage {
  factory ExchangeSFrameKeyResponse({
    ExchangeSFrameKeySuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  ExchangeSFrameKeyResponse._();

  factory ExchangeSFrameKeyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExchangeSFrameKeyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ExchangeSFrameKeyResponse_Result>
      _ExchangeSFrameKeyResponse_ResultByTag = {
    1: ExchangeSFrameKeyResponse_Result.success,
    2: ExchangeSFrameKeyResponse_Result.error,
    0: ExchangeSFrameKeyResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExchangeSFrameKeyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<ExchangeSFrameKeySuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: ExchangeSFrameKeySuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeSFrameKeyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeSFrameKeyResponse copyWith(
          void Function(ExchangeSFrameKeyResponse) updates) =>
      super.copyWith((message) => updates(message as ExchangeSFrameKeyResponse))
          as ExchangeSFrameKeyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExchangeSFrameKeyResponse create() => ExchangeSFrameKeyResponse._();
  @$core.override
  ExchangeSFrameKeyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExchangeSFrameKeyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExchangeSFrameKeyResponse>(create);
  static ExchangeSFrameKeyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  ExchangeSFrameKeyResponse_Result whichResult() =>
      _ExchangeSFrameKeyResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ExchangeSFrameKeySuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(ExchangeSFrameKeySuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  ExchangeSFrameKeySuccess ensureSuccess() => $_ensure(0);

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

class ExchangeSFrameKeySuccess extends $pb.GeneratedMessage {
  factory ExchangeSFrameKeySuccess({
    $core.bool? distributed,
    $core.int? participantsCount,
  }) {
    final result = create();
    if (distributed != null) result.distributed = distributed;
    if (participantsCount != null) result.participantsCount = participantsCount;
    return result;
  }

  ExchangeSFrameKeySuccess._();

  factory ExchangeSFrameKeySuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExchangeSFrameKeySuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExchangeSFrameKeySuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'distributed')
    ..aI(2, _omitFieldNames ? '' : 'participantsCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeSFrameKeySuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeSFrameKeySuccess copyWith(
          void Function(ExchangeSFrameKeySuccess) updates) =>
      super.copyWith((message) => updates(message as ExchangeSFrameKeySuccess))
          as ExchangeSFrameKeySuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExchangeSFrameKeySuccess create() => ExchangeSFrameKeySuccess._();
  @$core.override
  ExchangeSFrameKeySuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExchangeSFrameKeySuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExchangeSFrameKeySuccess>(create);
  static ExchangeSFrameKeySuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get distributed => $_getBF(0);
  @$pb.TagNumber(1)
  set distributed($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDistributed() => $_has(0);
  @$pb.TagNumber(1)
  void clearDistributed() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get participantsCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set participantsCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasParticipantsCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearParticipantsCount() => $_clearField(2);
}

class RotateSFrameKeyRequest extends $pb.GeneratedMessage {
  factory RotateSFrameKeyRequest({
    $core.String? accessToken,
    $core.String? callId,
    $core.Iterable<ParticipantKeyPackage>? keyPackages,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (callId != null) result.callId = callId;
    if (keyPackages != null) result.keyPackages.addAll(keyPackages);
    return result;
  }

  RotateSFrameKeyRequest._();

  factory RotateSFrameKeyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RotateSFrameKeyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RotateSFrameKeyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'callId')
    ..pPM<ParticipantKeyPackage>(3, _omitFieldNames ? '' : 'keyPackages',
        subBuilder: ParticipantKeyPackage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RotateSFrameKeyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RotateSFrameKeyRequest copyWith(
          void Function(RotateSFrameKeyRequest) updates) =>
      super.copyWith((message) => updates(message as RotateSFrameKeyRequest))
          as RotateSFrameKeyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RotateSFrameKeyRequest create() => RotateSFrameKeyRequest._();
  @$core.override
  RotateSFrameKeyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RotateSFrameKeyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RotateSFrameKeyRequest>(create);
  static RotateSFrameKeyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get callId => $_getSZ(1);
  @$pb.TagNumber(2)
  set callId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCallId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCallId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<ParticipantKeyPackage> get keyPackages => $_getList(2);
}

enum RotateSFrameKeyResponse_Result { success, error, notSet }

class RotateSFrameKeyResponse extends $pb.GeneratedMessage {
  factory RotateSFrameKeyResponse({
    RotateSFrameKeySuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  RotateSFrameKeyResponse._();

  factory RotateSFrameKeyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RotateSFrameKeyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, RotateSFrameKeyResponse_Result>
      _RotateSFrameKeyResponse_ResultByTag = {
    1: RotateSFrameKeyResponse_Result.success,
    2: RotateSFrameKeyResponse_Result.error,
    0: RotateSFrameKeyResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RotateSFrameKeyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<RotateSFrameKeySuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: RotateSFrameKeySuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RotateSFrameKeyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RotateSFrameKeyResponse copyWith(
          void Function(RotateSFrameKeyResponse) updates) =>
      super.copyWith((message) => updates(message as RotateSFrameKeyResponse))
          as RotateSFrameKeyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RotateSFrameKeyResponse create() => RotateSFrameKeyResponse._();
  @$core.override
  RotateSFrameKeyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RotateSFrameKeyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RotateSFrameKeyResponse>(create);
  static RotateSFrameKeyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  RotateSFrameKeyResponse_Result whichResult() =>
      _RotateSFrameKeyResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  RotateSFrameKeySuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(RotateSFrameKeySuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  RotateSFrameKeySuccess ensureSuccess() => $_ensure(0);

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

class RotateSFrameKeySuccess extends $pb.GeneratedMessage {
  factory RotateSFrameKeySuccess({
    $core.int? newKeyId,
    $core.bool? distributed,
  }) {
    final result = create();
    if (newKeyId != null) result.newKeyId = newKeyId;
    if (distributed != null) result.distributed = distributed;
    return result;
  }

  RotateSFrameKeySuccess._();

  factory RotateSFrameKeySuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RotateSFrameKeySuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RotateSFrameKeySuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'newKeyId', fieldType: $pb.PbFieldType.OU3)
    ..aOB(2, _omitFieldNames ? '' : 'distributed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RotateSFrameKeySuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RotateSFrameKeySuccess copyWith(
          void Function(RotateSFrameKeySuccess) updates) =>
      super.copyWith((message) => updates(message as RotateSFrameKeySuccess))
          as RotateSFrameKeySuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RotateSFrameKeySuccess create() => RotateSFrameKeySuccess._();
  @$core.override
  RotateSFrameKeySuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RotateSFrameKeySuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RotateSFrameKeySuccess>(create);
  static RotateSFrameKeySuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get newKeyId => $_getIZ(0);
  @$pb.TagNumber(1)
  set newKeyId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNewKeyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNewKeyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get distributed => $_getBF(1);
  @$pb.TagNumber(2)
  set distributed($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDistributed() => $_has(1);
  @$pb.TagNumber(2)
  void clearDistributed() => $_clearField(2);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.calls'),
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
