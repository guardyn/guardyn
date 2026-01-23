// This is a generated file - do not edit.
//
// Generated from notifications.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $1;
import 'notifications.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'notifications.pbenum.dart';

class RegisterDeviceRequest extends $pb.GeneratedMessage {
  factory RegisterDeviceRequest({
    $core.String? accessToken,
    $core.String? deviceId,
    $core.String? pushToken,
    PushPlatform? platform,
    $core.String? deviceName,
    $core.String? appVersion,
    $core.String? osVersion,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (deviceId != null) result.deviceId = deviceId;
    if (pushToken != null) result.pushToken = pushToken;
    if (platform != null) result.platform = platform;
    if (deviceName != null) result.deviceName = deviceName;
    if (appVersion != null) result.appVersion = appVersion;
    if (osVersion != null) result.osVersion = osVersion;
    return result;
  }

  RegisterDeviceRequest._();

  factory RegisterDeviceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterDeviceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterDeviceRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..aOS(3, _omitFieldNames ? '' : 'pushToken')
    ..aE<PushPlatform>(4, _omitFieldNames ? '' : 'platform',
        enumValues: PushPlatform.values)
    ..aOS(5, _omitFieldNames ? '' : 'deviceName')
    ..aOS(6, _omitFieldNames ? '' : 'appVersion')
    ..aOS(7, _omitFieldNames ? '' : 'osVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterDeviceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterDeviceRequest copyWith(
          void Function(RegisterDeviceRequest) updates) =>
      super.copyWith((message) => updates(message as RegisterDeviceRequest))
          as RegisterDeviceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterDeviceRequest create() => RegisterDeviceRequest._();
  @$core.override
  RegisterDeviceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterDeviceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterDeviceRequest>(create);
  static RegisterDeviceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get pushToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set pushToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPushToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearPushToken() => $_clearField(3);

  @$pb.TagNumber(4)
  PushPlatform get platform => $_getN(3);
  @$pb.TagNumber(4)
  set platform(PushPlatform value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPlatform() => $_has(3);
  @$pb.TagNumber(4)
  void clearPlatform() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get deviceName => $_getSZ(4);
  @$pb.TagNumber(5)
  set deviceName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDeviceName() => $_has(4);
  @$pb.TagNumber(5)
  void clearDeviceName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get appVersion => $_getSZ(5);
  @$pb.TagNumber(6)
  set appVersion($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAppVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearAppVersion() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get osVersion => $_getSZ(6);
  @$pb.TagNumber(7)
  set osVersion($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOsVersion() => $_has(6);
  @$pb.TagNumber(7)
  void clearOsVersion() => $_clearField(7);
}

enum RegisterDeviceResponse_Result { success, error, notSet }

class RegisterDeviceResponse extends $pb.GeneratedMessage {
  factory RegisterDeviceResponse({
    RegisterDeviceSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  RegisterDeviceResponse._();

  factory RegisterDeviceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterDeviceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, RegisterDeviceResponse_Result>
      _RegisterDeviceResponse_ResultByTag = {
    1: RegisterDeviceResponse_Result.success,
    2: RegisterDeviceResponse_Result.error,
    0: RegisterDeviceResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterDeviceResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<RegisterDeviceSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: RegisterDeviceSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterDeviceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterDeviceResponse copyWith(
          void Function(RegisterDeviceResponse) updates) =>
      super.copyWith((message) => updates(message as RegisterDeviceResponse))
          as RegisterDeviceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterDeviceResponse create() => RegisterDeviceResponse._();
  @$core.override
  RegisterDeviceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterDeviceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterDeviceResponse>(create);
  static RegisterDeviceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  RegisterDeviceResponse_Result whichResult() =>
      _RegisterDeviceResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  RegisterDeviceSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(RegisterDeviceSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  RegisterDeviceSuccess ensureSuccess() => $_ensure(0);

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

class RegisterDeviceSuccess extends $pb.GeneratedMessage {
  factory RegisterDeviceSuccess({
    $core.String? registrationId,
    $1.Timestamp? registeredAt,
  }) {
    final result = create();
    if (registrationId != null) result.registrationId = registrationId;
    if (registeredAt != null) result.registeredAt = registeredAt;
    return result;
  }

  RegisterDeviceSuccess._();

  factory RegisterDeviceSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterDeviceSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterDeviceSuccess',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'registrationId')
    ..aOM<$1.Timestamp>(2, _omitFieldNames ? '' : 'registeredAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterDeviceSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterDeviceSuccess copyWith(
          void Function(RegisterDeviceSuccess) updates) =>
      super.copyWith((message) => updates(message as RegisterDeviceSuccess))
          as RegisterDeviceSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterDeviceSuccess create() => RegisterDeviceSuccess._();
  @$core.override
  RegisterDeviceSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterDeviceSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterDeviceSuccess>(create);
  static RegisterDeviceSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get registrationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set registrationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRegistrationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRegistrationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Timestamp get registeredAt => $_getN(1);
  @$pb.TagNumber(2)
  set registeredAt($1.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRegisteredAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearRegisteredAt() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Timestamp ensureRegisteredAt() => $_ensure(1);
}

class UnregisterDeviceRequest extends $pb.GeneratedMessage {
  factory UnregisterDeviceRequest({
    $core.String? accessToken,
    $core.String? deviceId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (deviceId != null) result.deviceId = deviceId;
    return result;
  }

  UnregisterDeviceRequest._();

  factory UnregisterDeviceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnregisterDeviceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnregisterDeviceRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnregisterDeviceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnregisterDeviceRequest copyWith(
          void Function(UnregisterDeviceRequest) updates) =>
      super.copyWith((message) => updates(message as UnregisterDeviceRequest))
          as UnregisterDeviceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnregisterDeviceRequest create() => UnregisterDeviceRequest._();
  @$core.override
  UnregisterDeviceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnregisterDeviceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnregisterDeviceRequest>(create);
  static UnregisterDeviceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);
}

enum UnregisterDeviceResponse_Result { success, error, notSet }

class UnregisterDeviceResponse extends $pb.GeneratedMessage {
  factory UnregisterDeviceResponse({
    UnregisterDeviceSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  UnregisterDeviceResponse._();

  factory UnregisterDeviceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnregisterDeviceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, UnregisterDeviceResponse_Result>
      _UnregisterDeviceResponse_ResultByTag = {
    1: UnregisterDeviceResponse_Result.success,
    2: UnregisterDeviceResponse_Result.error,
    0: UnregisterDeviceResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnregisterDeviceResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<UnregisterDeviceSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: UnregisterDeviceSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnregisterDeviceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnregisterDeviceResponse copyWith(
          void Function(UnregisterDeviceResponse) updates) =>
      super.copyWith((message) => updates(message as UnregisterDeviceResponse))
          as UnregisterDeviceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnregisterDeviceResponse create() => UnregisterDeviceResponse._();
  @$core.override
  UnregisterDeviceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnregisterDeviceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnregisterDeviceResponse>(create);
  static UnregisterDeviceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  UnregisterDeviceResponse_Result whichResult() =>
      _UnregisterDeviceResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  UnregisterDeviceSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(UnregisterDeviceSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  UnregisterDeviceSuccess ensureSuccess() => $_ensure(0);

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

class UnregisterDeviceSuccess extends $pb.GeneratedMessage {
  factory UnregisterDeviceSuccess({
    $core.bool? unregistered,
  }) {
    final result = create();
    if (unregistered != null) result.unregistered = unregistered;
    return result;
  }

  UnregisterDeviceSuccess._();

  factory UnregisterDeviceSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnregisterDeviceSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnregisterDeviceSuccess',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'unregistered')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnregisterDeviceSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnregisterDeviceSuccess copyWith(
          void Function(UnregisterDeviceSuccess) updates) =>
      super.copyWith((message) => updates(message as UnregisterDeviceSuccess))
          as UnregisterDeviceSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnregisterDeviceSuccess create() => UnregisterDeviceSuccess._();
  @$core.override
  UnregisterDeviceSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnregisterDeviceSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnregisterDeviceSuccess>(create);
  static UnregisterDeviceSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get unregistered => $_getBF(0);
  @$pb.TagNumber(1)
  set unregistered($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUnregistered() => $_has(0);
  @$pb.TagNumber(1)
  void clearUnregistered() => $_clearField(1);
}

class UpdatePushTokenRequest extends $pb.GeneratedMessage {
  factory UpdatePushTokenRequest({
    $core.String? accessToken,
    $core.String? deviceId,
    $core.String? newPushToken,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (deviceId != null) result.deviceId = deviceId;
    if (newPushToken != null) result.newPushToken = newPushToken;
    return result;
  }

  UpdatePushTokenRequest._();

  factory UpdatePushTokenRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdatePushTokenRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdatePushTokenRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..aOS(3, _omitFieldNames ? '' : 'newPushToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePushTokenRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePushTokenRequest copyWith(
          void Function(UpdatePushTokenRequest) updates) =>
      super.copyWith((message) => updates(message as UpdatePushTokenRequest))
          as UpdatePushTokenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdatePushTokenRequest create() => UpdatePushTokenRequest._();
  @$core.override
  UpdatePushTokenRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdatePushTokenRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdatePushTokenRequest>(create);
  static UpdatePushTokenRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get newPushToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set newPushToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNewPushToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewPushToken() => $_clearField(3);
}

enum UpdatePushTokenResponse_Result { success, error, notSet }

class UpdatePushTokenResponse extends $pb.GeneratedMessage {
  factory UpdatePushTokenResponse({
    UpdatePushTokenSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  UpdatePushTokenResponse._();

  factory UpdatePushTokenResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdatePushTokenResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, UpdatePushTokenResponse_Result>
      _UpdatePushTokenResponse_ResultByTag = {
    1: UpdatePushTokenResponse_Result.success,
    2: UpdatePushTokenResponse_Result.error,
    0: UpdatePushTokenResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdatePushTokenResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<UpdatePushTokenSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: UpdatePushTokenSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePushTokenResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePushTokenResponse copyWith(
          void Function(UpdatePushTokenResponse) updates) =>
      super.copyWith((message) => updates(message as UpdatePushTokenResponse))
          as UpdatePushTokenResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdatePushTokenResponse create() => UpdatePushTokenResponse._();
  @$core.override
  UpdatePushTokenResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdatePushTokenResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdatePushTokenResponse>(create);
  static UpdatePushTokenResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  UpdatePushTokenResponse_Result whichResult() =>
      _UpdatePushTokenResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  UpdatePushTokenSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(UpdatePushTokenSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  UpdatePushTokenSuccess ensureSuccess() => $_ensure(0);

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

class UpdatePushTokenSuccess extends $pb.GeneratedMessage {
  factory UpdatePushTokenSuccess({
    $core.bool? updated,
  }) {
    final result = create();
    if (updated != null) result.updated = updated;
    return result;
  }

  UpdatePushTokenSuccess._();

  factory UpdatePushTokenSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdatePushTokenSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdatePushTokenSuccess',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'updated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePushTokenSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePushTokenSuccess copyWith(
          void Function(UpdatePushTokenSuccess) updates) =>
      super.copyWith((message) => updates(message as UpdatePushTokenSuccess))
          as UpdatePushTokenSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdatePushTokenSuccess create() => UpdatePushTokenSuccess._();
  @$core.override
  UpdatePushTokenSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdatePushTokenSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdatePushTokenSuccess>(create);
  static UpdatePushTokenSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get updated => $_getBF(0);
  @$pb.TagNumber(1)
  set updated($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUpdated() => $_has(0);
  @$pb.TagNumber(1)
  void clearUpdated() => $_clearField(1);
}

class NotificationSettings extends $pb.GeneratedMessage {
  factory NotificationSettings({
    $core.bool? notificationsEnabled,
    $core.bool? soundEnabled,
    $core.bool? vibrationEnabled,
    $core.bool? showPreview,
    $core.bool? showSender,
    $core.bool? quietHoursEnabled,
    $core.int? quietHoursStart,
    $core.int? quietHoursEnd,
    $core.String? quietHoursTimezone,
    $core.bool? notifyMessages,
    $core.bool? notifyReactions,
    $core.bool? notifyMentions,
    $core.bool? notifyCalls,
    $core.bool? notifyGroupMessages,
  }) {
    final result = create();
    if (notificationsEnabled != null)
      result.notificationsEnabled = notificationsEnabled;
    if (soundEnabled != null) result.soundEnabled = soundEnabled;
    if (vibrationEnabled != null) result.vibrationEnabled = vibrationEnabled;
    if (showPreview != null) result.showPreview = showPreview;
    if (showSender != null) result.showSender = showSender;
    if (quietHoursEnabled != null) result.quietHoursEnabled = quietHoursEnabled;
    if (quietHoursStart != null) result.quietHoursStart = quietHoursStart;
    if (quietHoursEnd != null) result.quietHoursEnd = quietHoursEnd;
    if (quietHoursTimezone != null)
      result.quietHoursTimezone = quietHoursTimezone;
    if (notifyMessages != null) result.notifyMessages = notifyMessages;
    if (notifyReactions != null) result.notifyReactions = notifyReactions;
    if (notifyMentions != null) result.notifyMentions = notifyMentions;
    if (notifyCalls != null) result.notifyCalls = notifyCalls;
    if (notifyGroupMessages != null)
      result.notifyGroupMessages = notifyGroupMessages;
    return result;
  }

  NotificationSettings._();

  factory NotificationSettings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationSettings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationSettings',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'notificationsEnabled')
    ..aOB(2, _omitFieldNames ? '' : 'soundEnabled')
    ..aOB(3, _omitFieldNames ? '' : 'vibrationEnabled')
    ..aOB(4, _omitFieldNames ? '' : 'showPreview')
    ..aOB(5, _omitFieldNames ? '' : 'showSender')
    ..aOB(6, _omitFieldNames ? '' : 'quietHoursEnabled')
    ..aI(7, _omitFieldNames ? '' : 'quietHoursStart')
    ..aI(8, _omitFieldNames ? '' : 'quietHoursEnd')
    ..aOS(9, _omitFieldNames ? '' : 'quietHoursTimezone')
    ..aOB(10, _omitFieldNames ? '' : 'notifyMessages')
    ..aOB(11, _omitFieldNames ? '' : 'notifyReactions')
    ..aOB(12, _omitFieldNames ? '' : 'notifyMentions')
    ..aOB(13, _omitFieldNames ? '' : 'notifyCalls')
    ..aOB(14, _omitFieldNames ? '' : 'notifyGroupMessages')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationSettings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationSettings copyWith(void Function(NotificationSettings) updates) =>
      super.copyWith((message) => updates(message as NotificationSettings))
          as NotificationSettings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationSettings create() => NotificationSettings._();
  @$core.override
  NotificationSettings createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationSettings getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationSettings>(create);
  static NotificationSettings? _defaultInstance;

  /// Global settings
  @$pb.TagNumber(1)
  $core.bool get notificationsEnabled => $_getBF(0);
  @$pb.TagNumber(1)
  set notificationsEnabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNotificationsEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearNotificationsEnabled() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get soundEnabled => $_getBF(1);
  @$pb.TagNumber(2)
  set soundEnabled($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSoundEnabled() => $_has(1);
  @$pb.TagNumber(2)
  void clearSoundEnabled() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get vibrationEnabled => $_getBF(2);
  @$pb.TagNumber(3)
  set vibrationEnabled($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVibrationEnabled() => $_has(2);
  @$pb.TagNumber(3)
  void clearVibrationEnabled() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get showPreview => $_getBF(3);
  @$pb.TagNumber(4)
  set showPreview($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasShowPreview() => $_has(3);
  @$pb.TagNumber(4)
  void clearShowPreview() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get showSender => $_getBF(4);
  @$pb.TagNumber(5)
  set showSender($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasShowSender() => $_has(4);
  @$pb.TagNumber(5)
  void clearShowSender() => $_clearField(5);

  /// Quiet hours
  @$pb.TagNumber(6)
  $core.bool get quietHoursEnabled => $_getBF(5);
  @$pb.TagNumber(6)
  set quietHoursEnabled($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasQuietHoursEnabled() => $_has(5);
  @$pb.TagNumber(6)
  void clearQuietHoursEnabled() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get quietHoursStart => $_getIZ(6);
  @$pb.TagNumber(7)
  set quietHoursStart($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasQuietHoursStart() => $_has(6);
  @$pb.TagNumber(7)
  void clearQuietHoursStart() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get quietHoursEnd => $_getIZ(7);
  @$pb.TagNumber(8)
  set quietHoursEnd($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasQuietHoursEnd() => $_has(7);
  @$pb.TagNumber(8)
  void clearQuietHoursEnd() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get quietHoursTimezone => $_getSZ(8);
  @$pb.TagNumber(9)
  set quietHoursTimezone($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasQuietHoursTimezone() => $_has(8);
  @$pb.TagNumber(9)
  void clearQuietHoursTimezone() => $_clearField(9);

  /// Category settings
  @$pb.TagNumber(10)
  $core.bool get notifyMessages => $_getBF(9);
  @$pb.TagNumber(10)
  set notifyMessages($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNotifyMessages() => $_has(9);
  @$pb.TagNumber(10)
  void clearNotifyMessages() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get notifyReactions => $_getBF(10);
  @$pb.TagNumber(11)
  set notifyReactions($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasNotifyReactions() => $_has(10);
  @$pb.TagNumber(11)
  void clearNotifyReactions() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get notifyMentions => $_getBF(11);
  @$pb.TagNumber(12)
  set notifyMentions($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasNotifyMentions() => $_has(11);
  @$pb.TagNumber(12)
  void clearNotifyMentions() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get notifyCalls => $_getBF(12);
  @$pb.TagNumber(13)
  set notifyCalls($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasNotifyCalls() => $_has(12);
  @$pb.TagNumber(13)
  void clearNotifyCalls() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get notifyGroupMessages => $_getBF(13);
  @$pb.TagNumber(14)
  set notifyGroupMessages($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasNotifyGroupMessages() => $_has(13);
  @$pb.TagNumber(14)
  void clearNotifyGroupMessages() => $_clearField(14);
}

class GetNotificationSettingsRequest extends $pb.GeneratedMessage {
  factory GetNotificationSettingsRequest({
    $core.String? accessToken,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    return result;
  }

  GetNotificationSettingsRequest._();

  factory GetNotificationSettingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNotificationSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNotificationSettingsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNotificationSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNotificationSettingsRequest copyWith(
          void Function(GetNotificationSettingsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetNotificationSettingsRequest))
          as GetNotificationSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNotificationSettingsRequest create() =>
      GetNotificationSettingsRequest._();
  @$core.override
  GetNotificationSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNotificationSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNotificationSettingsRequest>(create);
  static GetNotificationSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);
}

enum GetNotificationSettingsResponse_Result { success, error, notSet }

class GetNotificationSettingsResponse extends $pb.GeneratedMessage {
  factory GetNotificationSettingsResponse({
    GetNotificationSettingsSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetNotificationSettingsResponse._();

  factory GetNotificationSettingsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNotificationSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetNotificationSettingsResponse_Result>
      _GetNotificationSettingsResponse_ResultByTag = {
    1: GetNotificationSettingsResponse_Result.success,
    2: GetNotificationSettingsResponse_Result.error,
    0: GetNotificationSettingsResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNotificationSettingsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetNotificationSettingsSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: GetNotificationSettingsSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNotificationSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNotificationSettingsResponse copyWith(
          void Function(GetNotificationSettingsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetNotificationSettingsResponse))
          as GetNotificationSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNotificationSettingsResponse create() =>
      GetNotificationSettingsResponse._();
  @$core.override
  GetNotificationSettingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNotificationSettingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNotificationSettingsResponse>(
          create);
  static GetNotificationSettingsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetNotificationSettingsResponse_Result whichResult() =>
      _GetNotificationSettingsResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetNotificationSettingsSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(GetNotificationSettingsSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  GetNotificationSettingsSuccess ensureSuccess() => $_ensure(0);

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

class GetNotificationSettingsSuccess extends $pb.GeneratedMessage {
  factory GetNotificationSettingsSuccess({
    NotificationSettings? settings,
  }) {
    final result = create();
    if (settings != null) result.settings = settings;
    return result;
  }

  GetNotificationSettingsSuccess._();

  factory GetNotificationSettingsSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNotificationSettingsSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNotificationSettingsSuccess',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..aOM<NotificationSettings>(1, _omitFieldNames ? '' : 'settings',
        subBuilder: NotificationSettings.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNotificationSettingsSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNotificationSettingsSuccess copyWith(
          void Function(GetNotificationSettingsSuccess) updates) =>
      super.copyWith(
              (message) => updates(message as GetNotificationSettingsSuccess))
          as GetNotificationSettingsSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNotificationSettingsSuccess create() =>
      GetNotificationSettingsSuccess._();
  @$core.override
  GetNotificationSettingsSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNotificationSettingsSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNotificationSettingsSuccess>(create);
  static GetNotificationSettingsSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  NotificationSettings get settings => $_getN(0);
  @$pb.TagNumber(1)
  set settings(NotificationSettings value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSettings() => $_has(0);
  @$pb.TagNumber(1)
  void clearSettings() => $_clearField(1);
  @$pb.TagNumber(1)
  NotificationSettings ensureSettings() => $_ensure(0);
}

class UpdateNotificationSettingsRequest extends $pb.GeneratedMessage {
  factory UpdateNotificationSettingsRequest({
    $core.String? accessToken,
    NotificationSettings? settings,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (settings != null) result.settings = settings;
    return result;
  }

  UpdateNotificationSettingsRequest._();

  factory UpdateNotificationSettingsRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateNotificationSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateNotificationSettingsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOM<NotificationSettings>(2, _omitFieldNames ? '' : 'settings',
        subBuilder: NotificationSettings.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNotificationSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNotificationSettingsRequest copyWith(
          void Function(UpdateNotificationSettingsRequest) updates) =>
      super.copyWith((message) =>
              updates(message as UpdateNotificationSettingsRequest))
          as UpdateNotificationSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateNotificationSettingsRequest create() =>
      UpdateNotificationSettingsRequest._();
  @$core.override
  UpdateNotificationSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateNotificationSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateNotificationSettingsRequest>(
          create);
  static UpdateNotificationSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  NotificationSettings get settings => $_getN(1);
  @$pb.TagNumber(2)
  set settings(NotificationSettings value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSettings() => $_has(1);
  @$pb.TagNumber(2)
  void clearSettings() => $_clearField(2);
  @$pb.TagNumber(2)
  NotificationSettings ensureSettings() => $_ensure(1);
}

enum UpdateNotificationSettingsResponse_Result { success, error, notSet }

class UpdateNotificationSettingsResponse extends $pb.GeneratedMessage {
  factory UpdateNotificationSettingsResponse({
    UpdateNotificationSettingsSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  UpdateNotificationSettingsResponse._();

  factory UpdateNotificationSettingsResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateNotificationSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, UpdateNotificationSettingsResponse_Result>
      _UpdateNotificationSettingsResponse_ResultByTag = {
    1: UpdateNotificationSettingsResponse_Result.success,
    2: UpdateNotificationSettingsResponse_Result.error,
    0: UpdateNotificationSettingsResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateNotificationSettingsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<UpdateNotificationSettingsSuccess>(
        1, _omitFieldNames ? '' : 'success',
        subBuilder: UpdateNotificationSettingsSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNotificationSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNotificationSettingsResponse copyWith(
          void Function(UpdateNotificationSettingsResponse) updates) =>
      super.copyWith((message) =>
              updates(message as UpdateNotificationSettingsResponse))
          as UpdateNotificationSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateNotificationSettingsResponse create() =>
      UpdateNotificationSettingsResponse._();
  @$core.override
  UpdateNotificationSettingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateNotificationSettingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateNotificationSettingsResponse>(
          create);
  static UpdateNotificationSettingsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  UpdateNotificationSettingsResponse_Result whichResult() =>
      _UpdateNotificationSettingsResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  UpdateNotificationSettingsSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(UpdateNotificationSettingsSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  UpdateNotificationSettingsSuccess ensureSuccess() => $_ensure(0);

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

class UpdateNotificationSettingsSuccess extends $pb.GeneratedMessage {
  factory UpdateNotificationSettingsSuccess({
    $core.bool? updated,
  }) {
    final result = create();
    if (updated != null) result.updated = updated;
    return result;
  }

  UpdateNotificationSettingsSuccess._();

  factory UpdateNotificationSettingsSuccess.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateNotificationSettingsSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateNotificationSettingsSuccess',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'updated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNotificationSettingsSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNotificationSettingsSuccess copyWith(
          void Function(UpdateNotificationSettingsSuccess) updates) =>
      super.copyWith((message) =>
              updates(message as UpdateNotificationSettingsSuccess))
          as UpdateNotificationSettingsSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateNotificationSettingsSuccess create() =>
      UpdateNotificationSettingsSuccess._();
  @$core.override
  UpdateNotificationSettingsSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateNotificationSettingsSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateNotificationSettingsSuccess>(
          create);
  static UpdateNotificationSettingsSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get updated => $_getBF(0);
  @$pb.TagNumber(1)
  set updated($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUpdated() => $_has(0);
  @$pb.TagNumber(1)
  void clearUpdated() => $_clearField(1);
}

class MuteConversationRequest extends $pb.GeneratedMessage {
  factory MuteConversationRequest({
    $core.String? accessToken,
    $core.String? conversationId,
    $core.bool? isGroup,
    MuteDuration? duration,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (conversationId != null) result.conversationId = conversationId;
    if (isGroup != null) result.isGroup = isGroup;
    if (duration != null) result.duration = duration;
    return result;
  }

  MuteConversationRequest._();

  factory MuteConversationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MuteConversationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MuteConversationRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOB(3, _omitFieldNames ? '' : 'isGroup')
    ..aE<MuteDuration>(4, _omitFieldNames ? '' : 'duration',
        enumValues: MuteDuration.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MuteConversationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MuteConversationRequest copyWith(
          void Function(MuteConversationRequest) updates) =>
      super.copyWith((message) => updates(message as MuteConversationRequest))
          as MuteConversationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MuteConversationRequest create() => MuteConversationRequest._();
  @$core.override
  MuteConversationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MuteConversationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MuteConversationRequest>(create);
  static MuteConversationRequest? _defaultInstance;

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
  MuteDuration get duration => $_getN(3);
  @$pb.TagNumber(4)
  set duration(MuteDuration value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasDuration() => $_has(3);
  @$pb.TagNumber(4)
  void clearDuration() => $_clearField(4);
}

enum MuteConversationResponse_Result { success, error, notSet }

class MuteConversationResponse extends $pb.GeneratedMessage {
  factory MuteConversationResponse({
    MuteConversationSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  MuteConversationResponse._();

  factory MuteConversationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MuteConversationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, MuteConversationResponse_Result>
      _MuteConversationResponse_ResultByTag = {
    1: MuteConversationResponse_Result.success,
    2: MuteConversationResponse_Result.error,
    0: MuteConversationResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MuteConversationResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<MuteConversationSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: MuteConversationSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MuteConversationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MuteConversationResponse copyWith(
          void Function(MuteConversationResponse) updates) =>
      super.copyWith((message) => updates(message as MuteConversationResponse))
          as MuteConversationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MuteConversationResponse create() => MuteConversationResponse._();
  @$core.override
  MuteConversationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MuteConversationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MuteConversationResponse>(create);
  static MuteConversationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  MuteConversationResponse_Result whichResult() =>
      _MuteConversationResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  MuteConversationSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(MuteConversationSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  MuteConversationSuccess ensureSuccess() => $_ensure(0);

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

class MuteConversationSuccess extends $pb.GeneratedMessage {
  factory MuteConversationSuccess({
    $core.bool? muted,
    $1.Timestamp? mutedUntil,
  }) {
    final result = create();
    if (muted != null) result.muted = muted;
    if (mutedUntil != null) result.mutedUntil = mutedUntil;
    return result;
  }

  MuteConversationSuccess._();

  factory MuteConversationSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MuteConversationSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MuteConversationSuccess',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'muted')
    ..aOM<$1.Timestamp>(2, _omitFieldNames ? '' : 'mutedUntil',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MuteConversationSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MuteConversationSuccess copyWith(
          void Function(MuteConversationSuccess) updates) =>
      super.copyWith((message) => updates(message as MuteConversationSuccess))
          as MuteConversationSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MuteConversationSuccess create() => MuteConversationSuccess._();
  @$core.override
  MuteConversationSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MuteConversationSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MuteConversationSuccess>(create);
  static MuteConversationSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get muted => $_getBF(0);
  @$pb.TagNumber(1)
  set muted($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMuted() => $_has(0);
  @$pb.TagNumber(1)
  void clearMuted() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Timestamp get mutedUntil => $_getN(1);
  @$pb.TagNumber(2)
  set mutedUntil($1.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMutedUntil() => $_has(1);
  @$pb.TagNumber(2)
  void clearMutedUntil() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Timestamp ensureMutedUntil() => $_ensure(1);
}

class SendTestNotificationRequest extends $pb.GeneratedMessage {
  factory SendTestNotificationRequest({
    $core.String? accessToken,
    $core.String? deviceId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (deviceId != null) result.deviceId = deviceId;
    return result;
  }

  SendTestNotificationRequest._();

  factory SendTestNotificationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendTestNotificationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendTestNotificationRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTestNotificationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTestNotificationRequest copyWith(
          void Function(SendTestNotificationRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SendTestNotificationRequest))
          as SendTestNotificationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendTestNotificationRequest create() =>
      SendTestNotificationRequest._();
  @$core.override
  SendTestNotificationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendTestNotificationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendTestNotificationRequest>(create);
  static SendTestNotificationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);
}

enum SendTestNotificationResponse_Result { success, error, notSet }

class SendTestNotificationResponse extends $pb.GeneratedMessage {
  factory SendTestNotificationResponse({
    SendTestNotificationSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  SendTestNotificationResponse._();

  factory SendTestNotificationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendTestNotificationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SendTestNotificationResponse_Result>
      _SendTestNotificationResponse_ResultByTag = {
    1: SendTestNotificationResponse_Result.success,
    2: SendTestNotificationResponse_Result.error,
    0: SendTestNotificationResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendTestNotificationResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<SendTestNotificationSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: SendTestNotificationSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTestNotificationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTestNotificationResponse copyWith(
          void Function(SendTestNotificationResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SendTestNotificationResponse))
          as SendTestNotificationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendTestNotificationResponse create() =>
      SendTestNotificationResponse._();
  @$core.override
  SendTestNotificationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendTestNotificationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendTestNotificationResponse>(create);
  static SendTestNotificationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  SendTestNotificationResponse_Result whichResult() =>
      _SendTestNotificationResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SendTestNotificationSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(SendTestNotificationSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  SendTestNotificationSuccess ensureSuccess() => $_ensure(0);

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

class SendTestNotificationSuccess extends $pb.GeneratedMessage {
  factory SendTestNotificationSuccess({
    $core.int? devicesNotified,
  }) {
    final result = create();
    if (devicesNotified != null) result.devicesNotified = devicesNotified;
    return result;
  }

  SendTestNotificationSuccess._();

  factory SendTestNotificationSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendTestNotificationSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendTestNotificationSuccess',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'devicesNotified')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTestNotificationSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTestNotificationSuccess copyWith(
          void Function(SendTestNotificationSuccess) updates) =>
      super.copyWith(
              (message) => updates(message as SendTestNotificationSuccess))
          as SendTestNotificationSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendTestNotificationSuccess create() =>
      SendTestNotificationSuccess._();
  @$core.override
  SendTestNotificationSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SendTestNotificationSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendTestNotificationSuccess>(create);
  static SendTestNotificationSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get devicesNotified => $_getIZ(0);
  @$pb.TagNumber(1)
  set devicesNotified($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDevicesNotified() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevicesNotified() => $_clearField(1);
}

class PushNotificationPayload extends $pb.GeneratedMessage {
  factory PushNotificationPayload({
    $core.String? notificationId,
    $core.String? recipientUserId,
    NotificationType? type,
    $core.String? title,
    $core.String? body,
    $core.String? imageUrl,
    $core.String? conversationId,
    $core.bool? isGroup,
    $core.String? messageId,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? data,
    NotificationPriority? priority,
    $core.int? ttlSeconds,
  }) {
    final result = create();
    if (notificationId != null) result.notificationId = notificationId;
    if (recipientUserId != null) result.recipientUserId = recipientUserId;
    if (type != null) result.type = type;
    if (title != null) result.title = title;
    if (body != null) result.body = body;
    if (imageUrl != null) result.imageUrl = imageUrl;
    if (conversationId != null) result.conversationId = conversationId;
    if (isGroup != null) result.isGroup = isGroup;
    if (messageId != null) result.messageId = messageId;
    if (data != null) result.data.addEntries(data);
    if (priority != null) result.priority = priority;
    if (ttlSeconds != null) result.ttlSeconds = ttlSeconds;
    return result;
  }

  PushNotificationPayload._();

  factory PushNotificationPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PushNotificationPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PushNotificationPayload',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'notificationId')
    ..aOS(2, _omitFieldNames ? '' : 'recipientUserId')
    ..aE<NotificationType>(3, _omitFieldNames ? '' : 'type',
        enumValues: NotificationType.values)
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aOS(5, _omitFieldNames ? '' : 'body')
    ..aOS(6, _omitFieldNames ? '' : 'imageUrl')
    ..aOS(7, _omitFieldNames ? '' : 'conversationId')
    ..aOB(8, _omitFieldNames ? '' : 'isGroup')
    ..aOS(9, _omitFieldNames ? '' : 'messageId')
    ..m<$core.String, $core.String>(10, _omitFieldNames ? '' : 'data',
        entryClassName: 'PushNotificationPayload.DataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('guardyn.notifications'))
    ..aE<NotificationPriority>(11, _omitFieldNames ? '' : 'priority',
        enumValues: NotificationPriority.values)
    ..aI(12, _omitFieldNames ? '' : 'ttlSeconds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushNotificationPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PushNotificationPayload copyWith(
          void Function(PushNotificationPayload) updates) =>
      super.copyWith((message) => updates(message as PushNotificationPayload))
          as PushNotificationPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PushNotificationPayload create() => PushNotificationPayload._();
  @$core.override
  PushNotificationPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PushNotificationPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PushNotificationPayload>(create);
  static PushNotificationPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get notificationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set notificationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNotificationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNotificationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get recipientUserId => $_getSZ(1);
  @$pb.TagNumber(2)
  set recipientUserId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRecipientUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecipientUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  NotificationType get type => $_getN(2);
  @$pb.TagNumber(3)
  set type(NotificationType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  /// Content (encrypted on client, plaintext here for push)
  @$pb.TagNumber(4)
  $core.String get title => $_getSZ(3);
  @$pb.TagNumber(4)
  set title($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get body => $_getSZ(4);
  @$pb.TagNumber(5)
  set body($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBody() => $_has(4);
  @$pb.TagNumber(5)
  void clearBody() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get imageUrl => $_getSZ(5);
  @$pb.TagNumber(6)
  set imageUrl($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasImageUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearImageUrl() => $_clearField(6);

  /// Deep link data
  @$pb.TagNumber(7)
  $core.String get conversationId => $_getSZ(6);
  @$pb.TagNumber(7)
  set conversationId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasConversationId() => $_has(6);
  @$pb.TagNumber(7)
  void clearConversationId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isGroup => $_getBF(7);
  @$pb.TagNumber(8)
  set isGroup($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIsGroup() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsGroup() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get messageId => $_getSZ(8);
  @$pb.TagNumber(9)
  set messageId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMessageId() => $_has(8);
  @$pb.TagNumber(9)
  void clearMessageId() => $_clearField(9);

  /// Metadata
  @$pb.TagNumber(10)
  $pb.PbMap<$core.String, $core.String> get data => $_getMap(9);

  /// Priority
  @$pb.TagNumber(11)
  NotificationPriority get priority => $_getN(10);
  @$pb.TagNumber(11)
  set priority(NotificationPriority value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasPriority() => $_has(10);
  @$pb.TagNumber(11)
  void clearPriority() => $_clearField(11);

  /// TTL (time-to-live for push delivery)
  @$pb.TagNumber(12)
  $core.int get ttlSeconds => $_getIZ(11);
  @$pb.TagNumber(12)
  set ttlSeconds($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasTtlSeconds() => $_has(11);
  @$pb.TagNumber(12)
  void clearTtlSeconds() => $_clearField(12);
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
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'guardyn.notifications'),
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
