// This is a generated file - do not edit.
//
// Generated from auth.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class RegisterRequest extends $pb.GeneratedMessage {
  factory RegisterRequest({
    $core.String? username,
    $core.String? password,
    $core.String? email,
    $core.String? deviceName,
    $core.String? deviceType,
    $1.KeyBundle? keyBundle,
  }) {
    final result = create();
    if (username != null) result.username = username;
    if (password != null) result.password = password;
    if (email != null) result.email = email;
    if (deviceName != null) result.deviceName = deviceName;
    if (deviceType != null) result.deviceType = deviceType;
    if (keyBundle != null) result.keyBundle = keyBundle;
    return result;
  }

  RegisterRequest._();

  factory RegisterRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..aOS(3, _omitFieldNames ? '' : 'email')
    ..aOS(4, _omitFieldNames ? '' : 'deviceName')
    ..aOS(5, _omitFieldNames ? '' : 'deviceType')
    ..aOM<$1.KeyBundle>(6, _omitFieldNames ? '' : 'keyBundle',
        subBuilder: $1.KeyBundle.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterRequest copyWith(void Function(RegisterRequest) updates) =>
      super.copyWith((message) => updates(message as RegisterRequest))
          as RegisterRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterRequest create() => RegisterRequest._();
  @$core.override
  RegisterRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterRequest>(create);
  static RegisterRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get email => $_getSZ(2);
  @$pb.TagNumber(3)
  set email($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEmail() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmail() => $_clearField(3);

  /// Device information
  @$pb.TagNumber(4)
  $core.String get deviceName => $_getSZ(3);
  @$pb.TagNumber(4)
  set deviceName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDeviceName() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeviceName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get deviceType => $_getSZ(4);
  @$pb.TagNumber(5)
  set deviceType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDeviceType() => $_has(4);
  @$pb.TagNumber(5)
  void clearDeviceType() => $_clearField(5);

  /// E2EE key bundle for this device
  @$pb.TagNumber(6)
  $1.KeyBundle get keyBundle => $_getN(5);
  @$pb.TagNumber(6)
  set keyBundle($1.KeyBundle value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasKeyBundle() => $_has(5);
  @$pb.TagNumber(6)
  void clearKeyBundle() => $_clearField(6);
  @$pb.TagNumber(6)
  $1.KeyBundle ensureKeyBundle() => $_ensure(5);
}

enum RegisterResponse_Result { success, error, notSet }

class RegisterResponse extends $pb.GeneratedMessage {
  factory RegisterResponse({
    RegisterSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  RegisterResponse._();

  factory RegisterResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, RegisterResponse_Result>
      _RegisterResponse_ResultByTag = {
    1: RegisterResponse_Result.success,
    2: RegisterResponse_Result.error,
    0: RegisterResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<RegisterSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: RegisterSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterResponse copyWith(void Function(RegisterResponse) updates) =>
      super.copyWith((message) => updates(message as RegisterResponse))
          as RegisterResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterResponse create() => RegisterResponse._();
  @$core.override
  RegisterResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterResponse>(create);
  static RegisterResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  RegisterResponse_Result whichResult() =>
      _RegisterResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  RegisterSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(RegisterSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  RegisterSuccess ensureSuccess() => $_ensure(0);

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

class RegisterSuccess extends $pb.GeneratedMessage {
  factory RegisterSuccess({
    $core.String? userId,
    $core.String? deviceId,
    $core.String? accessToken,
    $core.int? accessTokenExpiresIn,
    $core.String? refreshToken,
    $core.int? refreshTokenExpiresIn,
    $1.Timestamp? createdAt,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceId != null) result.deviceId = deviceId;
    if (accessToken != null) result.accessToken = accessToken;
    if (accessTokenExpiresIn != null)
      result.accessTokenExpiresIn = accessTokenExpiresIn;
    if (refreshToken != null) result.refreshToken = refreshToken;
    if (refreshTokenExpiresIn != null)
      result.refreshTokenExpiresIn = refreshTokenExpiresIn;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  RegisterSuccess._();

  factory RegisterSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..aOS(3, _omitFieldNames ? '' : 'accessToken')
    ..aI(4, _omitFieldNames ? '' : 'accessTokenExpiresIn',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(5, _omitFieldNames ? '' : 'refreshToken')
    ..aI(6, _omitFieldNames ? '' : 'refreshTokenExpiresIn',
        fieldType: $pb.PbFieldType.OU3)
    ..aOM<$1.Timestamp>(7, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterSuccess copyWith(void Function(RegisterSuccess) updates) =>
      super.copyWith((message) => updates(message as RegisterSuccess))
          as RegisterSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterSuccess create() => RegisterSuccess._();
  @$core.override
  RegisterSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterSuccess>(create);
  static RegisterSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get accessToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set accessToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAccessToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccessToken() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get accessTokenExpiresIn => $_getIZ(3);
  @$pb.TagNumber(4)
  set accessTokenExpiresIn($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAccessTokenExpiresIn() => $_has(3);
  @$pb.TagNumber(4)
  void clearAccessTokenExpiresIn() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get refreshToken => $_getSZ(4);
  @$pb.TagNumber(5)
  set refreshToken($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRefreshToken() => $_has(4);
  @$pb.TagNumber(5)
  void clearRefreshToken() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get refreshTokenExpiresIn => $_getIZ(5);
  @$pb.TagNumber(6)
  set refreshTokenExpiresIn($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRefreshTokenExpiresIn() => $_has(5);
  @$pb.TagNumber(6)
  void clearRefreshTokenExpiresIn() => $_clearField(6);

  @$pb.TagNumber(7)
  $1.Timestamp get createdAt => $_getN(6);
  @$pb.TagNumber(7)
  set createdAt($1.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.Timestamp ensureCreatedAt() => $_ensure(6);
}

class LoginRequest extends $pb.GeneratedMessage {
  factory LoginRequest({
    $core.String? username,
    $core.String? password,
    $core.String? deviceId,
    $core.String? deviceName,
    $core.String? deviceType,
    $1.KeyBundle? keyBundle,
  }) {
    final result = create();
    if (username != null) result.username = username;
    if (password != null) result.password = password;
    if (deviceId != null) result.deviceId = deviceId;
    if (deviceName != null) result.deviceName = deviceName;
    if (deviceType != null) result.deviceType = deviceType;
    if (keyBundle != null) result.keyBundle = keyBundle;
    return result;
  }

  LoginRequest._();

  factory LoginRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LoginRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoginRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..aOS(3, _omitFieldNames ? '' : 'deviceId')
    ..aOS(4, _omitFieldNames ? '' : 'deviceName')
    ..aOS(5, _omitFieldNames ? '' : 'deviceType')
    ..aOM<$1.KeyBundle>(6, _omitFieldNames ? '' : 'keyBundle',
        subBuilder: $1.KeyBundle.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginRequest copyWith(void Function(LoginRequest) updates) =>
      super.copyWith((message) => updates(message as LoginRequest))
          as LoginRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginRequest create() => LoginRequest._();
  @$core.override
  LoginRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LoginRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoginRequest>(create);
  static LoginRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);

  /// Device information (new or existing)
  @$pb.TagNumber(3)
  $core.String get deviceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get deviceName => $_getSZ(3);
  @$pb.TagNumber(4)
  set deviceName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDeviceName() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeviceName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get deviceType => $_getSZ(4);
  @$pb.TagNumber(5)
  set deviceType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDeviceType() => $_has(4);
  @$pb.TagNumber(5)
  void clearDeviceType() => $_clearField(5);

  /// E2EE key bundle for this device (required if new device)
  @$pb.TagNumber(6)
  $1.KeyBundle get keyBundle => $_getN(5);
  @$pb.TagNumber(6)
  set keyBundle($1.KeyBundle value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasKeyBundle() => $_has(5);
  @$pb.TagNumber(6)
  void clearKeyBundle() => $_clearField(6);
  @$pb.TagNumber(6)
  $1.KeyBundle ensureKeyBundle() => $_ensure(5);
}

enum LoginResponse_Result { success, error, notSet }

class LoginResponse extends $pb.GeneratedMessage {
  factory LoginResponse({
    LoginSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  LoginResponse._();

  factory LoginResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LoginResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, LoginResponse_Result>
      _LoginResponse_ResultByTag = {
    1: LoginResponse_Result.success,
    2: LoginResponse_Result.error,
    0: LoginResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoginResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<LoginSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: LoginSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginResponse copyWith(void Function(LoginResponse) updates) =>
      super.copyWith((message) => updates(message as LoginResponse))
          as LoginResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginResponse create() => LoginResponse._();
  @$core.override
  LoginResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LoginResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoginResponse>(create);
  static LoginResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  LoginResponse_Result whichResult() =>
      _LoginResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  LoginSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(LoginSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  LoginSuccess ensureSuccess() => $_ensure(0);

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

class LoginSuccess extends $pb.GeneratedMessage {
  factory LoginSuccess({
    $core.String? userId,
    $core.String? deviceId,
    $core.String? accessToken,
    $core.int? accessTokenExpiresIn,
    $core.String? refreshToken,
    $core.int? refreshTokenExpiresIn,
    UserProfile? profile,
    $core.Iterable<DeviceInfo>? devices,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceId != null) result.deviceId = deviceId;
    if (accessToken != null) result.accessToken = accessToken;
    if (accessTokenExpiresIn != null)
      result.accessTokenExpiresIn = accessTokenExpiresIn;
    if (refreshToken != null) result.refreshToken = refreshToken;
    if (refreshTokenExpiresIn != null)
      result.refreshTokenExpiresIn = refreshTokenExpiresIn;
    if (profile != null) result.profile = profile;
    if (devices != null) result.devices.addAll(devices);
    return result;
  }

  LoginSuccess._();

  factory LoginSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LoginSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LoginSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..aOS(3, _omitFieldNames ? '' : 'accessToken')
    ..aI(4, _omitFieldNames ? '' : 'accessTokenExpiresIn',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(5, _omitFieldNames ? '' : 'refreshToken')
    ..aI(6, _omitFieldNames ? '' : 'refreshTokenExpiresIn',
        fieldType: $pb.PbFieldType.OU3)
    ..aOM<UserProfile>(7, _omitFieldNames ? '' : 'profile',
        subBuilder: UserProfile.create)
    ..pPM<DeviceInfo>(8, _omitFieldNames ? '' : 'devices',
        subBuilder: DeviceInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoginSuccess copyWith(void Function(LoginSuccess) updates) =>
      super.copyWith((message) => updates(message as LoginSuccess))
          as LoginSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoginSuccess create() => LoginSuccess._();
  @$core.override
  LoginSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LoginSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LoginSuccess>(create);
  static LoginSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get accessToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set accessToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAccessToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccessToken() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get accessTokenExpiresIn => $_getIZ(3);
  @$pb.TagNumber(4)
  set accessTokenExpiresIn($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAccessTokenExpiresIn() => $_has(3);
  @$pb.TagNumber(4)
  void clearAccessTokenExpiresIn() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get refreshToken => $_getSZ(4);
  @$pb.TagNumber(5)
  set refreshToken($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRefreshToken() => $_has(4);
  @$pb.TagNumber(5)
  void clearRefreshToken() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get refreshTokenExpiresIn => $_getIZ(5);
  @$pb.TagNumber(6)
  set refreshTokenExpiresIn($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRefreshTokenExpiresIn() => $_has(5);
  @$pb.TagNumber(6)
  void clearRefreshTokenExpiresIn() => $_clearField(6);

  /// User profile
  @$pb.TagNumber(7)
  UserProfile get profile => $_getN(6);
  @$pb.TagNumber(7)
  set profile(UserProfile value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasProfile() => $_has(6);
  @$pb.TagNumber(7)
  void clearProfile() => $_clearField(7);
  @$pb.TagNumber(7)
  UserProfile ensureProfile() => $_ensure(6);

  /// All user's devices
  @$pb.TagNumber(8)
  $pb.PbList<DeviceInfo> get devices => $_getList(7);
}

class UserProfile extends $pb.GeneratedMessage {
  factory UserProfile({
    $core.String? userId,
    $core.String? username,
    $core.String? email,
    $1.Timestamp? createdAt,
    $1.Timestamp? lastSeen,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (username != null) result.username = username;
    if (email != null) result.email = email;
    if (createdAt != null) result.createdAt = createdAt;
    if (lastSeen != null) result.lastSeen = lastSeen;
    return result;
  }

  UserProfile._();

  factory UserProfile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserProfile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserProfile',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'email')
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(5, _omitFieldNames ? '' : 'lastSeen',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserProfile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserProfile copyWith(void Function(UserProfile) updates) =>
      super.copyWith((message) => updates(message as UserProfile))
          as UserProfile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserProfile create() => UserProfile._();
  @$core.override
  UserProfile createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserProfile getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserProfile>(create);
  static UserProfile? _defaultInstance;

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
  $core.String get email => $_getSZ(2);
  @$pb.TagNumber(3)
  set email($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEmail() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmail() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Timestamp get createdAt => $_getN(3);
  @$pb.TagNumber(4)
  set createdAt($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureCreatedAt() => $_ensure(3);

  @$pb.TagNumber(5)
  $1.Timestamp get lastSeen => $_getN(4);
  @$pb.TagNumber(5)
  set lastSeen($1.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLastSeen() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastSeen() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.Timestamp ensureLastSeen() => $_ensure(4);
}

class DeviceInfo extends $pb.GeneratedMessage {
  factory DeviceInfo({
    $core.String? deviceId,
    $core.String? deviceName,
    $core.String? deviceType,
    $1.Timestamp? createdAt,
    $1.Timestamp? lastSeen,
    $core.bool? isCurrent,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (deviceName != null) result.deviceName = deviceName;
    if (deviceType != null) result.deviceType = deviceType;
    if (createdAt != null) result.createdAt = createdAt;
    if (lastSeen != null) result.lastSeen = lastSeen;
    if (isCurrent != null) result.isCurrent = isCurrent;
    return result;
  }

  DeviceInfo._();

  factory DeviceInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeviceInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeviceInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceName')
    ..aOS(3, _omitFieldNames ? '' : 'deviceType')
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(5, _omitFieldNames ? '' : 'lastSeen',
        subBuilder: $1.Timestamp.create)
    ..aOB(6, _omitFieldNames ? '' : 'isCurrent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceInfo copyWith(void Function(DeviceInfo) updates) =>
      super.copyWith((message) => updates(message as DeviceInfo)) as DeviceInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeviceInfo create() => DeviceInfo._();
  @$core.override
  DeviceInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeviceInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeviceInfo>(create);
  static DeviceInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceName => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get deviceType => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceType() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceType() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.Timestamp get createdAt => $_getN(3);
  @$pb.TagNumber(4)
  set createdAt($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureCreatedAt() => $_ensure(3);

  @$pb.TagNumber(5)
  $1.Timestamp get lastSeen => $_getN(4);
  @$pb.TagNumber(5)
  set lastSeen($1.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLastSeen() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastSeen() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.Timestamp ensureLastSeen() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.bool get isCurrent => $_getBF(5);
  @$pb.TagNumber(6)
  set isCurrent($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsCurrent() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsCurrent() => $_clearField(6);
}

class LogoutRequest extends $pb.GeneratedMessage {
  factory LogoutRequest({
    $core.String? accessToken,
    $core.bool? allDevices,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (allDevices != null) result.allDevices = allDevices;
    return result;
  }

  LogoutRequest._();

  factory LogoutRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogoutRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogoutRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOB(2, _omitFieldNames ? '' : 'allDevices')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogoutRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogoutRequest copyWith(void Function(LogoutRequest) updates) =>
      super.copyWith((message) => updates(message as LogoutRequest))
          as LogoutRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogoutRequest create() => LogoutRequest._();
  @$core.override
  LogoutRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogoutRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogoutRequest>(create);
  static LogoutRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get allDevices => $_getBF(1);
  @$pb.TagNumber(2)
  set allDevices($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAllDevices() => $_has(1);
  @$pb.TagNumber(2)
  void clearAllDevices() => $_clearField(2);
}

enum LogoutResponse_Result { success, error, notSet }

class LogoutResponse extends $pb.GeneratedMessage {
  factory LogoutResponse({
    LogoutSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  LogoutResponse._();

  factory LogoutResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogoutResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, LogoutResponse_Result>
      _LogoutResponse_ResultByTag = {
    1: LogoutResponse_Result.success,
    2: LogoutResponse_Result.error,
    0: LogoutResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogoutResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<LogoutSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: LogoutSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogoutResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogoutResponse copyWith(void Function(LogoutResponse) updates) =>
      super.copyWith((message) => updates(message as LogoutResponse))
          as LogoutResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogoutResponse create() => LogoutResponse._();
  @$core.override
  LogoutResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogoutResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogoutResponse>(create);
  static LogoutResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  LogoutResponse_Result whichResult() =>
      _LogoutResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  LogoutSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(LogoutSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  LogoutSuccess ensureSuccess() => $_ensure(0);

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

class LogoutSuccess extends $pb.GeneratedMessage {
  factory LogoutSuccess({
    $core.int? sessionsInvalidated,
  }) {
    final result = create();
    if (sessionsInvalidated != null)
      result.sessionsInvalidated = sessionsInvalidated;
    return result;
  }

  LogoutSuccess._();

  factory LogoutSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogoutSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogoutSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'sessionsInvalidated',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogoutSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogoutSuccess copyWith(void Function(LogoutSuccess) updates) =>
      super.copyWith((message) => updates(message as LogoutSuccess))
          as LogoutSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogoutSuccess create() => LogoutSuccess._();
  @$core.override
  LogoutSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogoutSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogoutSuccess>(create);
  static LogoutSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get sessionsInvalidated => $_getIZ(0);
  @$pb.TagNumber(1)
  set sessionsInvalidated($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionsInvalidated() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionsInvalidated() => $_clearField(1);
}

class RefreshTokenRequest extends $pb.GeneratedMessage {
  factory RefreshTokenRequest({
    $core.String? refreshToken,
  }) {
    final result = create();
    if (refreshToken != null) result.refreshToken = refreshToken;
    return result;
  }

  RefreshTokenRequest._();

  factory RefreshTokenRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RefreshTokenRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RefreshTokenRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'refreshToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshTokenRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshTokenRequest copyWith(void Function(RefreshTokenRequest) updates) =>
      super.copyWith((message) => updates(message as RefreshTokenRequest))
          as RefreshTokenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RefreshTokenRequest create() => RefreshTokenRequest._();
  @$core.override
  RefreshTokenRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RefreshTokenRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RefreshTokenRequest>(create);
  static RefreshTokenRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get refreshToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set refreshToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRefreshToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearRefreshToken() => $_clearField(1);
}

enum RefreshTokenResponse_Result { success, error, notSet }

class RefreshTokenResponse extends $pb.GeneratedMessage {
  factory RefreshTokenResponse({
    RefreshTokenSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  RefreshTokenResponse._();

  factory RefreshTokenResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RefreshTokenResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, RefreshTokenResponse_Result>
      _RefreshTokenResponse_ResultByTag = {
    1: RefreshTokenResponse_Result.success,
    2: RefreshTokenResponse_Result.error,
    0: RefreshTokenResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RefreshTokenResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<RefreshTokenSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: RefreshTokenSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshTokenResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshTokenResponse copyWith(void Function(RefreshTokenResponse) updates) =>
      super.copyWith((message) => updates(message as RefreshTokenResponse))
          as RefreshTokenResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RefreshTokenResponse create() => RefreshTokenResponse._();
  @$core.override
  RefreshTokenResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RefreshTokenResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RefreshTokenResponse>(create);
  static RefreshTokenResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  RefreshTokenResponse_Result whichResult() =>
      _RefreshTokenResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  RefreshTokenSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(RefreshTokenSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  RefreshTokenSuccess ensureSuccess() => $_ensure(0);

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

class RefreshTokenSuccess extends $pb.GeneratedMessage {
  factory RefreshTokenSuccess({
    $core.String? accessToken,
    $core.int? accessTokenExpiresIn,
    $core.String? refreshToken,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (accessTokenExpiresIn != null)
      result.accessTokenExpiresIn = accessTokenExpiresIn;
    if (refreshToken != null) result.refreshToken = refreshToken;
    return result;
  }

  RefreshTokenSuccess._();

  factory RefreshTokenSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RefreshTokenSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RefreshTokenSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aI(2, _omitFieldNames ? '' : 'accessTokenExpiresIn',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'refreshToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshTokenSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshTokenSuccess copyWith(void Function(RefreshTokenSuccess) updates) =>
      super.copyWith((message) => updates(message as RefreshTokenSuccess))
          as RefreshTokenSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RefreshTokenSuccess create() => RefreshTokenSuccess._();
  @$core.override
  RefreshTokenSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RefreshTokenSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RefreshTokenSuccess>(create);
  static RefreshTokenSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get accessTokenExpiresIn => $_getIZ(1);
  @$pb.TagNumber(2)
  set accessTokenExpiresIn($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAccessTokenExpiresIn() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccessTokenExpiresIn() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get refreshToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set refreshToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRefreshToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearRefreshToken() => $_clearField(3);
}

class ValidateTokenRequest extends $pb.GeneratedMessage {
  factory ValidateTokenRequest({
    $core.String? accessToken,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    return result;
  }

  ValidateTokenRequest._();

  factory ValidateTokenRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ValidateTokenRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ValidateTokenRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateTokenRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateTokenRequest copyWith(void Function(ValidateTokenRequest) updates) =>
      super.copyWith((message) => updates(message as ValidateTokenRequest))
          as ValidateTokenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateTokenRequest create() => ValidateTokenRequest._();
  @$core.override
  ValidateTokenRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ValidateTokenRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateTokenRequest>(create);
  static ValidateTokenRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);
}

enum ValidateTokenResponse_Result { success, error, notSet }

class ValidateTokenResponse extends $pb.GeneratedMessage {
  factory ValidateTokenResponse({
    ValidateTokenSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  ValidateTokenResponse._();

  factory ValidateTokenResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ValidateTokenResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ValidateTokenResponse_Result>
      _ValidateTokenResponse_ResultByTag = {
    1: ValidateTokenResponse_Result.success,
    2: ValidateTokenResponse_Result.error,
    0: ValidateTokenResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ValidateTokenResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<ValidateTokenSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: ValidateTokenSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateTokenResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateTokenResponse copyWith(
          void Function(ValidateTokenResponse) updates) =>
      super.copyWith((message) => updates(message as ValidateTokenResponse))
          as ValidateTokenResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateTokenResponse create() => ValidateTokenResponse._();
  @$core.override
  ValidateTokenResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ValidateTokenResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateTokenResponse>(create);
  static ValidateTokenResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  ValidateTokenResponse_Result whichResult() =>
      _ValidateTokenResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ValidateTokenSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(ValidateTokenSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  ValidateTokenSuccess ensureSuccess() => $_ensure(0);

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

class ValidateTokenSuccess extends $pb.GeneratedMessage {
  factory ValidateTokenSuccess({
    $core.String? userId,
    $core.String? deviceId,
    $1.Timestamp? expiresAt,
    $core.Iterable<$core.String>? permissions,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceId != null) result.deviceId = deviceId;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (permissions != null) result.permissions.addAll(permissions);
    return result;
  }

  ValidateTokenSuccess._();

  factory ValidateTokenSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ValidateTokenSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ValidateTokenSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..aOM<$1.Timestamp>(3, _omitFieldNames ? '' : 'expiresAt',
        subBuilder: $1.Timestamp.create)
    ..pPS(4, _omitFieldNames ? '' : 'permissions')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateTokenSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateTokenSuccess copyWith(void Function(ValidateTokenSuccess) updates) =>
      super.copyWith((message) => updates(message as ValidateTokenSuccess))
          as ValidateTokenSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateTokenSuccess create() => ValidateTokenSuccess._();
  @$core.override
  ValidateTokenSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ValidateTokenSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateTokenSuccess>(create);
  static ValidateTokenSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.Timestamp get expiresAt => $_getN(2);
  @$pb.TagNumber(3)
  set expiresAt($1.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasExpiresAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpiresAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Timestamp ensureExpiresAt() => $_ensure(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get permissions => $_getList(3);
}

class GetKeyBundleRequest extends $pb.GeneratedMessage {
  factory GetKeyBundleRequest({
    $core.String? userId,
    $core.String? deviceId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceId != null) result.deviceId = deviceId;
    return result;
  }

  GetKeyBundleRequest._();

  factory GetKeyBundleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetKeyBundleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetKeyBundleRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetKeyBundleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetKeyBundleRequest copyWith(void Function(GetKeyBundleRequest) updates) =>
      super.copyWith((message) => updates(message as GetKeyBundleRequest))
          as GetKeyBundleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetKeyBundleRequest create() => GetKeyBundleRequest._();
  @$core.override
  GetKeyBundleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetKeyBundleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetKeyBundleRequest>(create);
  static GetKeyBundleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);
}

enum GetKeyBundleResponse_Result { success, error, notSet }

class GetKeyBundleResponse extends $pb.GeneratedMessage {
  factory GetKeyBundleResponse({
    GetKeyBundleSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetKeyBundleResponse._();

  factory GetKeyBundleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetKeyBundleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetKeyBundleResponse_Result>
      _GetKeyBundleResponse_ResultByTag = {
    1: GetKeyBundleResponse_Result.success,
    2: GetKeyBundleResponse_Result.error,
    0: GetKeyBundleResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetKeyBundleResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetKeyBundleSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: GetKeyBundleSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetKeyBundleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetKeyBundleResponse copyWith(void Function(GetKeyBundleResponse) updates) =>
      super.copyWith((message) => updates(message as GetKeyBundleResponse))
          as GetKeyBundleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetKeyBundleResponse create() => GetKeyBundleResponse._();
  @$core.override
  GetKeyBundleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetKeyBundleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetKeyBundleResponse>(create);
  static GetKeyBundleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetKeyBundleResponse_Result whichResult() =>
      _GetKeyBundleResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetKeyBundleSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(GetKeyBundleSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  GetKeyBundleSuccess ensureSuccess() => $_ensure(0);

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

class GetKeyBundleSuccess extends $pb.GeneratedMessage {
  factory GetKeyBundleSuccess({
    $core.String? userId,
    $core.String? deviceId,
    $1.KeyBundle? keyBundle,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceId != null) result.deviceId = deviceId;
    if (keyBundle != null) result.keyBundle = keyBundle;
    return result;
  }

  GetKeyBundleSuccess._();

  factory GetKeyBundleSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetKeyBundleSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetKeyBundleSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..aOM<$1.KeyBundle>(3, _omitFieldNames ? '' : 'keyBundle',
        subBuilder: $1.KeyBundle.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetKeyBundleSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetKeyBundleSuccess copyWith(void Function(GetKeyBundleSuccess) updates) =>
      super.copyWith((message) => updates(message as GetKeyBundleSuccess))
          as GetKeyBundleSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetKeyBundleSuccess create() => GetKeyBundleSuccess._();
  @$core.override
  GetKeyBundleSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetKeyBundleSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetKeyBundleSuccess>(create);
  static GetKeyBundleSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.KeyBundle get keyBundle => $_getN(2);
  @$pb.TagNumber(3)
  set keyBundle($1.KeyBundle value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasKeyBundle() => $_has(2);
  @$pb.TagNumber(3)
  void clearKeyBundle() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.KeyBundle ensureKeyBundle() => $_ensure(2);
}

class UploadPreKeysRequest extends $pb.GeneratedMessage {
  factory UploadPreKeysRequest({
    $core.String? accessToken,
    $core.Iterable<$core.List<$core.int>>? oneTimePreKeys,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (oneTimePreKeys != null) result.oneTimePreKeys.addAll(oneTimePreKeys);
    return result;
  }

  UploadPreKeysRequest._();

  factory UploadPreKeysRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadPreKeysRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadPreKeysRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..p<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'oneTimePreKeys', $pb.PbFieldType.PY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadPreKeysRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadPreKeysRequest copyWith(void Function(UploadPreKeysRequest) updates) =>
      super.copyWith((message) => updates(message as UploadPreKeysRequest))
          as UploadPreKeysRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadPreKeysRequest create() => UploadPreKeysRequest._();
  @$core.override
  UploadPreKeysRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadPreKeysRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadPreKeysRequest>(create);
  static UploadPreKeysRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.List<$core.int>> get oneTimePreKeys => $_getList(1);
}

enum UploadPreKeysResponse_Result { success, error, notSet }

class UploadPreKeysResponse extends $pb.GeneratedMessage {
  factory UploadPreKeysResponse({
    UploadPreKeysSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  UploadPreKeysResponse._();

  factory UploadPreKeysResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadPreKeysResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, UploadPreKeysResponse_Result>
      _UploadPreKeysResponse_ResultByTag = {
    1: UploadPreKeysResponse_Result.success,
    2: UploadPreKeysResponse_Result.error,
    0: UploadPreKeysResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadPreKeysResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<UploadPreKeysSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: UploadPreKeysSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadPreKeysResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadPreKeysResponse copyWith(
          void Function(UploadPreKeysResponse) updates) =>
      super.copyWith((message) => updates(message as UploadPreKeysResponse))
          as UploadPreKeysResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadPreKeysResponse create() => UploadPreKeysResponse._();
  @$core.override
  UploadPreKeysResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadPreKeysResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadPreKeysResponse>(create);
  static UploadPreKeysResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  UploadPreKeysResponse_Result whichResult() =>
      _UploadPreKeysResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  UploadPreKeysSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(UploadPreKeysSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  UploadPreKeysSuccess ensureSuccess() => $_ensure(0);

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

class UploadPreKeysSuccess extends $pb.GeneratedMessage {
  factory UploadPreKeysSuccess({
    $core.int? keysUploaded,
    $core.int? totalKeysAvailable,
  }) {
    final result = create();
    if (keysUploaded != null) result.keysUploaded = keysUploaded;
    if (totalKeysAvailable != null)
      result.totalKeysAvailable = totalKeysAvailable;
    return result;
  }

  UploadPreKeysSuccess._();

  factory UploadPreKeysSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadPreKeysSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadPreKeysSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'keysUploaded',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'totalKeysAvailable',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadPreKeysSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadPreKeysSuccess copyWith(void Function(UploadPreKeysSuccess) updates) =>
      super.copyWith((message) => updates(message as UploadPreKeysSuccess))
          as UploadPreKeysSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadPreKeysSuccess create() => UploadPreKeysSuccess._();
  @$core.override
  UploadPreKeysSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadPreKeysSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadPreKeysSuccess>(create);
  static UploadPreKeysSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get keysUploaded => $_getIZ(0);
  @$pb.TagNumber(1)
  set keysUploaded($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKeysUploaded() => $_has(0);
  @$pb.TagNumber(1)
  void clearKeysUploaded() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get totalKeysAvailable => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalKeysAvailable($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalKeysAvailable() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalKeysAvailable() => $_clearField(2);
}

class UploadMlsKeyPackageRequest extends $pb.GeneratedMessage {
  factory UploadMlsKeyPackageRequest({
    $core.String? accessToken,
    $core.List<$core.int>? keyPackage,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (keyPackage != null) result.keyPackage = keyPackage;
    return result;
  }

  UploadMlsKeyPackageRequest._();

  factory UploadMlsKeyPackageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadMlsKeyPackageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadMlsKeyPackageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'keyPackage', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadMlsKeyPackageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadMlsKeyPackageRequest copyWith(
          void Function(UploadMlsKeyPackageRequest) updates) =>
      super.copyWith(
              (message) => updates(message as UploadMlsKeyPackageRequest))
          as UploadMlsKeyPackageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadMlsKeyPackageRequest create() => UploadMlsKeyPackageRequest._();
  @$core.override
  UploadMlsKeyPackageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadMlsKeyPackageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadMlsKeyPackageRequest>(create);
  static UploadMlsKeyPackageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get keyPackage => $_getN(1);
  @$pb.TagNumber(2)
  set keyPackage($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKeyPackage() => $_has(1);
  @$pb.TagNumber(2)
  void clearKeyPackage() => $_clearField(2);
}

enum UploadMlsKeyPackageResponse_Result { success, error, notSet }

class UploadMlsKeyPackageResponse extends $pb.GeneratedMessage {
  factory UploadMlsKeyPackageResponse({
    UploadMlsKeyPackageSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  UploadMlsKeyPackageResponse._();

  factory UploadMlsKeyPackageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadMlsKeyPackageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, UploadMlsKeyPackageResponse_Result>
      _UploadMlsKeyPackageResponse_ResultByTag = {
    1: UploadMlsKeyPackageResponse_Result.success,
    2: UploadMlsKeyPackageResponse_Result.error,
    0: UploadMlsKeyPackageResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadMlsKeyPackageResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<UploadMlsKeyPackageSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: UploadMlsKeyPackageSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadMlsKeyPackageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadMlsKeyPackageResponse copyWith(
          void Function(UploadMlsKeyPackageResponse) updates) =>
      super.copyWith(
              (message) => updates(message as UploadMlsKeyPackageResponse))
          as UploadMlsKeyPackageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadMlsKeyPackageResponse create() =>
      UploadMlsKeyPackageResponse._();
  @$core.override
  UploadMlsKeyPackageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadMlsKeyPackageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadMlsKeyPackageResponse>(create);
  static UploadMlsKeyPackageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  UploadMlsKeyPackageResponse_Result whichResult() =>
      _UploadMlsKeyPackageResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  UploadMlsKeyPackageSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(UploadMlsKeyPackageSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  UploadMlsKeyPackageSuccess ensureSuccess() => $_ensure(0);

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

class UploadMlsKeyPackageSuccess extends $pb.GeneratedMessage {
  factory UploadMlsKeyPackageSuccess({
    $core.String? packageId,
    $1.Timestamp? uploadedAt,
  }) {
    final result = create();
    if (packageId != null) result.packageId = packageId;
    if (uploadedAt != null) result.uploadedAt = uploadedAt;
    return result;
  }

  UploadMlsKeyPackageSuccess._();

  factory UploadMlsKeyPackageSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadMlsKeyPackageSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadMlsKeyPackageSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'packageId')
    ..aOM<$1.Timestamp>(2, _omitFieldNames ? '' : 'uploadedAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadMlsKeyPackageSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadMlsKeyPackageSuccess copyWith(
          void Function(UploadMlsKeyPackageSuccess) updates) =>
      super.copyWith(
              (message) => updates(message as UploadMlsKeyPackageSuccess))
          as UploadMlsKeyPackageSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadMlsKeyPackageSuccess create() => UploadMlsKeyPackageSuccess._();
  @$core.override
  UploadMlsKeyPackageSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadMlsKeyPackageSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadMlsKeyPackageSuccess>(create);
  static UploadMlsKeyPackageSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get packageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set packageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPackageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPackageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Timestamp get uploadedAt => $_getN(1);
  @$pb.TagNumber(2)
  set uploadedAt($1.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUploadedAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearUploadedAt() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Timestamp ensureUploadedAt() => $_ensure(1);
}

class GetMlsKeyPackageRequest extends $pb.GeneratedMessage {
  factory GetMlsKeyPackageRequest({
    $core.String? userId,
    $core.String? deviceId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceId != null) result.deviceId = deviceId;
    return result;
  }

  GetMlsKeyPackageRequest._();

  factory GetMlsKeyPackageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMlsKeyPackageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMlsKeyPackageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMlsKeyPackageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMlsKeyPackageRequest copyWith(
          void Function(GetMlsKeyPackageRequest) updates) =>
      super.copyWith((message) => updates(message as GetMlsKeyPackageRequest))
          as GetMlsKeyPackageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMlsKeyPackageRequest create() => GetMlsKeyPackageRequest._();
  @$core.override
  GetMlsKeyPackageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMlsKeyPackageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMlsKeyPackageRequest>(create);
  static GetMlsKeyPackageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);
}

enum GetMlsKeyPackageResponse_Result { success, error, notSet }

class GetMlsKeyPackageResponse extends $pb.GeneratedMessage {
  factory GetMlsKeyPackageResponse({
    GetMlsKeyPackageSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetMlsKeyPackageResponse._();

  factory GetMlsKeyPackageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMlsKeyPackageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetMlsKeyPackageResponse_Result>
      _GetMlsKeyPackageResponse_ResultByTag = {
    1: GetMlsKeyPackageResponse_Result.success,
    2: GetMlsKeyPackageResponse_Result.error,
    0: GetMlsKeyPackageResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMlsKeyPackageResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetMlsKeyPackageSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: GetMlsKeyPackageSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMlsKeyPackageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMlsKeyPackageResponse copyWith(
          void Function(GetMlsKeyPackageResponse) updates) =>
      super.copyWith((message) => updates(message as GetMlsKeyPackageResponse))
          as GetMlsKeyPackageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMlsKeyPackageResponse create() => GetMlsKeyPackageResponse._();
  @$core.override
  GetMlsKeyPackageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMlsKeyPackageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMlsKeyPackageResponse>(create);
  static GetMlsKeyPackageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetMlsKeyPackageResponse_Result whichResult() =>
      _GetMlsKeyPackageResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetMlsKeyPackageSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(GetMlsKeyPackageSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  GetMlsKeyPackageSuccess ensureSuccess() => $_ensure(0);

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

class GetMlsKeyPackageSuccess extends $pb.GeneratedMessage {
  factory GetMlsKeyPackageSuccess({
    $core.String? userId,
    $core.String? deviceId,
    $core.List<$core.int>? keyPackage,
    $core.String? packageId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (deviceId != null) result.deviceId = deviceId;
    if (keyPackage != null) result.keyPackage = keyPackage;
    if (packageId != null) result.packageId = packageId;
    return result;
  }

  GetMlsKeyPackageSuccess._();

  factory GetMlsKeyPackageSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMlsKeyPackageSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMlsKeyPackageSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'keyPackage', $pb.PbFieldType.OY)
    ..aOS(4, _omitFieldNames ? '' : 'packageId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMlsKeyPackageSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMlsKeyPackageSuccess copyWith(
          void Function(GetMlsKeyPackageSuccess) updates) =>
      super.copyWith((message) => updates(message as GetMlsKeyPackageSuccess))
          as GetMlsKeyPackageSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMlsKeyPackageSuccess create() => GetMlsKeyPackageSuccess._();
  @$core.override
  GetMlsKeyPackageSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMlsKeyPackageSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMlsKeyPackageSuccess>(create);
  static GetMlsKeyPackageSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get keyPackage => $_getN(2);
  @$pb.TagNumber(3)
  set keyPackage($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKeyPackage() => $_has(2);
  @$pb.TagNumber(3)
  void clearKeyPackage() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get packageId => $_getSZ(3);
  @$pb.TagNumber(4)
  set packageId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPackageId() => $_has(3);
  @$pb.TagNumber(4)
  void clearPackageId() => $_clearField(4);
}

class SearchUsersRequest extends $pb.GeneratedMessage {
  factory SearchUsersRequest({
    $core.String? accessToken,
    $core.String? query,
    $core.int? limit,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (query != null) result.query = query;
    if (limit != null) result.limit = limit;
    return result;
  }

  SearchUsersRequest._();

  factory SearchUsersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchUsersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchUsersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'query')
    ..aI(3, _omitFieldNames ? '' : 'limit', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUsersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUsersRequest copyWith(void Function(SearchUsersRequest) updates) =>
      super.copyWith((message) => updates(message as SearchUsersRequest))
          as SearchUsersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchUsersRequest create() => SearchUsersRequest._();
  @$core.override
  SearchUsersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchUsersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchUsersRequest>(create);
  static SearchUsersRequest? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);
}

enum SearchUsersResponse_Result { success, error, notSet }

class SearchUsersResponse extends $pb.GeneratedMessage {
  factory SearchUsersResponse({
    SearchUsersSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  SearchUsersResponse._();

  factory SearchUsersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchUsersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SearchUsersResponse_Result>
      _SearchUsersResponse_ResultByTag = {
    1: SearchUsersResponse_Result.success,
    2: SearchUsersResponse_Result.error,
    0: SearchUsersResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchUsersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<SearchUsersSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: SearchUsersSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUsersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUsersResponse copyWith(void Function(SearchUsersResponse) updates) =>
      super.copyWith((message) => updates(message as SearchUsersResponse))
          as SearchUsersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchUsersResponse create() => SearchUsersResponse._();
  @$core.override
  SearchUsersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchUsersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchUsersResponse>(create);
  static SearchUsersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  SearchUsersResponse_Result whichResult() =>
      _SearchUsersResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SearchUsersSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(SearchUsersSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  SearchUsersSuccess ensureSuccess() => $_ensure(0);

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

class SearchUsersSuccess extends $pb.GeneratedMessage {
  factory SearchUsersSuccess({
    $core.Iterable<UserSearchResult>? users,
  }) {
    final result = create();
    if (users != null) result.users.addAll(users);
    return result;
  }

  SearchUsersSuccess._();

  factory SearchUsersSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchUsersSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchUsersSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..pPM<UserSearchResult>(1, _omitFieldNames ? '' : 'users',
        subBuilder: UserSearchResult.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUsersSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchUsersSuccess copyWith(void Function(SearchUsersSuccess) updates) =>
      super.copyWith((message) => updates(message as SearchUsersSuccess))
          as SearchUsersSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchUsersSuccess create() => SearchUsersSuccess._();
  @$core.override
  SearchUsersSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchUsersSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchUsersSuccess>(create);
  static SearchUsersSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<UserSearchResult> get users => $_getList(0);
}

class UserSearchResult extends $pb.GeneratedMessage {
  factory UserSearchResult({
    $core.String? userId,
    $core.String? username,
    $1.Timestamp? createdAt,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (username != null) result.username = username;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  UserSearchResult._();

  factory UserSearchResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserSearchResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserSearchResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOM<$1.Timestamp>(3, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserSearchResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserSearchResult copyWith(void Function(UserSearchResult) updates) =>
      super.copyWith((message) => updates(message as UserSearchResult))
          as UserSearchResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserSearchResult create() => UserSearchResult._();
  @$core.override
  UserSearchResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserSearchResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserSearchResult>(create);
  static UserSearchResult? _defaultInstance;

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
  $1.Timestamp get createdAt => $_getN(2);
  @$pb.TagNumber(3)
  set createdAt($1.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCreatedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreatedAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Timestamp ensureCreatedAt() => $_ensure(2);
}

class GetUserProfileRequest extends $pb.GeneratedMessage {
  factory GetUserProfileRequest({
    $core.String? userId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    return result;
  }

  GetUserProfileRequest._();

  factory GetUserProfileRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUserProfileRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUserProfileRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserProfileRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserProfileRequest copyWith(
          void Function(GetUserProfileRequest) updates) =>
      super.copyWith((message) => updates(message as GetUserProfileRequest))
          as GetUserProfileRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUserProfileRequest create() => GetUserProfileRequest._();
  @$core.override
  GetUserProfileRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUserProfileRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUserProfileRequest>(create);
  static GetUserProfileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
}

enum GetUserProfileResponse_Result { success, error, notSet }

class GetUserProfileResponse extends $pb.GeneratedMessage {
  factory GetUserProfileResponse({
    UserProfile? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  GetUserProfileResponse._();

  factory GetUserProfileResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUserProfileResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetUserProfileResponse_Result>
      _GetUserProfileResponse_ResultByTag = {
    1: GetUserProfileResponse_Result.success,
    2: GetUserProfileResponse_Result.error,
    0: GetUserProfileResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUserProfileResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<UserProfile>(1, _omitFieldNames ? '' : 'success',
        subBuilder: UserProfile.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserProfileResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUserProfileResponse copyWith(
          void Function(GetUserProfileResponse) updates) =>
      super.copyWith((message) => updates(message as GetUserProfileResponse))
          as GetUserProfileResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUserProfileResponse create() => GetUserProfileResponse._();
  @$core.override
  GetUserProfileResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUserProfileResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUserProfileResponse>(create);
  static GetUserProfileResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetUserProfileResponse_Result whichResult() =>
      _GetUserProfileResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  UserProfile get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(UserProfile value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  UserProfile ensureSuccess() => $_ensure(0);

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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
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

class DeleteAccountRequest extends $pb.GeneratedMessage {
  factory DeleteAccountRequest({
    $core.String? accessToken,
    $core.String? password,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (password != null) result.password = password;
    return result;
  }

  DeleteAccountRequest._();

  factory DeleteAccountRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteAccountRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteAccountRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAccountRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAccountRequest copyWith(void Function(DeleteAccountRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteAccountRequest))
          as DeleteAccountRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteAccountRequest create() => DeleteAccountRequest._();
  @$core.override
  DeleteAccountRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteAccountRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteAccountRequest>(create);
  static DeleteAccountRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);
}

enum DeleteAccountResponse_Result { success, error, notSet }

class DeleteAccountResponse extends $pb.GeneratedMessage {
  factory DeleteAccountResponse({
    DeleteAccountSuccess? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  DeleteAccountResponse._();

  factory DeleteAccountResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteAccountResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, DeleteAccountResponse_Result>
      _DeleteAccountResponse_ResultByTag = {
    1: DeleteAccountResponse_Result.success,
    2: DeleteAccountResponse_Result.error,
    0: DeleteAccountResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteAccountResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<DeleteAccountSuccess>(1, _omitFieldNames ? '' : 'success',
        subBuilder: DeleteAccountSuccess.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAccountResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAccountResponse copyWith(
          void Function(DeleteAccountResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteAccountResponse))
          as DeleteAccountResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteAccountResponse create() => DeleteAccountResponse._();
  @$core.override
  DeleteAccountResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteAccountResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteAccountResponse>(create);
  static DeleteAccountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  DeleteAccountResponse_Result whichResult() =>
      _DeleteAccountResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  DeleteAccountSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(DeleteAccountSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  DeleteAccountSuccess ensureSuccess() => $_ensure(0);

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

class DeleteAccountSuccess extends $pb.GeneratedMessage {
  factory DeleteAccountSuccess({
    $core.String? userId,
    $core.String? message,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (message != null) result.message = message;
    return result;
  }

  DeleteAccountSuccess._();

  factory DeleteAccountSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteAccountSuccess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteAccountSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.auth'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAccountSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAccountSuccess copyWith(void Function(DeleteAccountSuccess) updates) =>
      super.copyWith((message) => updates(message as DeleteAccountSuccess))
          as DeleteAccountSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteAccountSuccess create() => DeleteAccountSuccess._();
  @$core.override
  DeleteAccountSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteAccountSuccess getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteAccountSuccess>(create);
  static DeleteAccountSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
