// This is a generated file - do not edit.
//
// Generated from auth.proto.

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

import 'auth.pb.dart' as $0;
import 'common.pb.dart' as $1;

export 'auth.pb.dart';

@$pb.GrpcServiceName('guardyn.auth.AuthService')
class AuthServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AuthServiceClient(super.channel, {super.options, super.interceptors});

  /// User registration with E2EE key bundle
  $grpc.ResponseFuture<$0.RegisterResponse> register(
    $0.RegisterRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$register, request, options: options);
  }

  /// User login (device authentication)
  $grpc.ResponseFuture<$0.LoginResponse> login(
    $0.LoginRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$login, request, options: options);
  }

  /// User logout (invalidate session)
  $grpc.ResponseFuture<$0.LogoutResponse> logout(
    $0.LogoutRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$logout, request, options: options);
  }

  /// Refresh access token using refresh token
  $grpc.ResponseFuture<$0.RefreshTokenResponse> refreshToken(
    $0.RefreshTokenRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$refreshToken, request, options: options);
  }

  /// Validate JWT token (internal service-to-service)
  $grpc.ResponseFuture<$0.ValidateTokenResponse> validateToken(
    $0.ValidateTokenRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$validateToken, request, options: options);
  }

  /// Get user's key bundle for E2EE initiation
  $grpc.ResponseFuture<$0.GetKeyBundleResponse> getKeyBundle(
    $0.GetKeyBundleRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getKeyBundle, request, options: options);
  }

  /// Upload new pre-keys (key rotation)
  $grpc.ResponseFuture<$0.UploadPreKeysResponse> uploadPreKeys(
    $0.UploadPreKeysRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$uploadPreKeys, request, options: options);
  }

  /// Upload MLS key package for group chat (MLS Protocol)
  $grpc.ResponseFuture<$0.UploadMlsKeyPackageResponse> uploadMlsKeyPackage(
    $0.UploadMlsKeyPackageRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$uploadMlsKeyPackage, request, options: options);
  }

  /// Get MLS key package for a user (used when adding to group)
  $grpc.ResponseFuture<$0.GetMlsKeyPackageResponse> getMlsKeyPackage(
    $0.GetMlsKeyPackageRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getMlsKeyPackage, request, options: options);
  }

  /// Search for users by username
  $grpc.ResponseFuture<$0.SearchUsersResponse> searchUsers(
    $0.SearchUsersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$searchUsers, request, options: options);
  }

  /// Get user profile by user ID (internal service-to-service)
  $grpc.ResponseFuture<$0.GetUserProfileResponse> getUserProfile(
    $0.GetUserProfileRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getUserProfile, request, options: options);
  }

  /// Delete user account and all associated data
  $grpc.ResponseFuture<$0.DeleteAccountResponse> deleteAccount(
    $0.DeleteAccountRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteAccount, request, options: options);
  }

  /// Health check
  $grpc.ResponseFuture<$1.HealthStatus> health(
    $0.HealthRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$health, request, options: options);
  }

  // method descriptors

  static final _$register =
      $grpc.ClientMethod<$0.RegisterRequest, $0.RegisterResponse>(
          '/guardyn.auth.AuthService/Register',
          ($0.RegisterRequest value) => value.writeToBuffer(),
          $0.RegisterResponse.fromBuffer);
  static final _$login = $grpc.ClientMethod<$0.LoginRequest, $0.LoginResponse>(
      '/guardyn.auth.AuthService/Login',
      ($0.LoginRequest value) => value.writeToBuffer(),
      $0.LoginResponse.fromBuffer);
  static final _$logout =
      $grpc.ClientMethod<$0.LogoutRequest, $0.LogoutResponse>(
          '/guardyn.auth.AuthService/Logout',
          ($0.LogoutRequest value) => value.writeToBuffer(),
          $0.LogoutResponse.fromBuffer);
  static final _$refreshToken =
      $grpc.ClientMethod<$0.RefreshTokenRequest, $0.RefreshTokenResponse>(
          '/guardyn.auth.AuthService/RefreshToken',
          ($0.RefreshTokenRequest value) => value.writeToBuffer(),
          $0.RefreshTokenResponse.fromBuffer);
  static final _$validateToken =
      $grpc.ClientMethod<$0.ValidateTokenRequest, $0.ValidateTokenResponse>(
          '/guardyn.auth.AuthService/ValidateToken',
          ($0.ValidateTokenRequest value) => value.writeToBuffer(),
          $0.ValidateTokenResponse.fromBuffer);
  static final _$getKeyBundle =
      $grpc.ClientMethod<$0.GetKeyBundleRequest, $0.GetKeyBundleResponse>(
          '/guardyn.auth.AuthService/GetKeyBundle',
          ($0.GetKeyBundleRequest value) => value.writeToBuffer(),
          $0.GetKeyBundleResponse.fromBuffer);
  static final _$uploadPreKeys =
      $grpc.ClientMethod<$0.UploadPreKeysRequest, $0.UploadPreKeysResponse>(
          '/guardyn.auth.AuthService/UploadPreKeys',
          ($0.UploadPreKeysRequest value) => value.writeToBuffer(),
          $0.UploadPreKeysResponse.fromBuffer);
  static final _$uploadMlsKeyPackage = $grpc.ClientMethod<
          $0.UploadMlsKeyPackageRequest, $0.UploadMlsKeyPackageResponse>(
      '/guardyn.auth.AuthService/UploadMlsKeyPackage',
      ($0.UploadMlsKeyPackageRequest value) => value.writeToBuffer(),
      $0.UploadMlsKeyPackageResponse.fromBuffer);
  static final _$getMlsKeyPackage = $grpc.ClientMethod<
          $0.GetMlsKeyPackageRequest, $0.GetMlsKeyPackageResponse>(
      '/guardyn.auth.AuthService/GetMlsKeyPackage',
      ($0.GetMlsKeyPackageRequest value) => value.writeToBuffer(),
      $0.GetMlsKeyPackageResponse.fromBuffer);
  static final _$searchUsers =
      $grpc.ClientMethod<$0.SearchUsersRequest, $0.SearchUsersResponse>(
          '/guardyn.auth.AuthService/SearchUsers',
          ($0.SearchUsersRequest value) => value.writeToBuffer(),
          $0.SearchUsersResponse.fromBuffer);
  static final _$getUserProfile =
      $grpc.ClientMethod<$0.GetUserProfileRequest, $0.GetUserProfileResponse>(
          '/guardyn.auth.AuthService/GetUserProfile',
          ($0.GetUserProfileRequest value) => value.writeToBuffer(),
          $0.GetUserProfileResponse.fromBuffer);
  static final _$deleteAccount =
      $grpc.ClientMethod<$0.DeleteAccountRequest, $0.DeleteAccountResponse>(
          '/guardyn.auth.AuthService/DeleteAccount',
          ($0.DeleteAccountRequest value) => value.writeToBuffer(),
          $0.DeleteAccountResponse.fromBuffer);
  static final _$health = $grpc.ClientMethod<$0.HealthRequest, $1.HealthStatus>(
      '/guardyn.auth.AuthService/Health',
      ($0.HealthRequest value) => value.writeToBuffer(),
      $1.HealthStatus.fromBuffer);
}

@$pb.GrpcServiceName('guardyn.auth.AuthService')
abstract class AuthServiceBase extends $grpc.Service {
  $core.String get $name => 'guardyn.auth.AuthService';

  AuthServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.RegisterRequest, $0.RegisterResponse>(
        'Register',
        register_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RegisterRequest.fromBuffer(value),
        ($0.RegisterResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LoginRequest, $0.LoginResponse>(
        'Login',
        login_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LoginRequest.fromBuffer(value),
        ($0.LoginResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LogoutRequest, $0.LogoutResponse>(
        'Logout',
        logout_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LogoutRequest.fromBuffer(value),
        ($0.LogoutResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.RefreshTokenRequest, $0.RefreshTokenResponse>(
            'RefreshToken',
            refreshToken_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.RefreshTokenRequest.fromBuffer(value),
            ($0.RefreshTokenResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ValidateTokenRequest, $0.ValidateTokenResponse>(
            'ValidateToken',
            validateToken_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ValidateTokenRequest.fromBuffer(value),
            ($0.ValidateTokenResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetKeyBundleRequest, $0.GetKeyBundleResponse>(
            'GetKeyBundle',
            getKeyBundle_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetKeyBundleRequest.fromBuffer(value),
            ($0.GetKeyBundleResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UploadPreKeysRequest, $0.UploadPreKeysResponse>(
            'UploadPreKeys',
            uploadPreKeys_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UploadPreKeysRequest.fromBuffer(value),
            ($0.UploadPreKeysResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UploadMlsKeyPackageRequest,
            $0.UploadMlsKeyPackageResponse>(
        'UploadMlsKeyPackage',
        uploadMlsKeyPackage_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UploadMlsKeyPackageRequest.fromBuffer(value),
        ($0.UploadMlsKeyPackageResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetMlsKeyPackageRequest,
            $0.GetMlsKeyPackageResponse>(
        'GetMlsKeyPackage',
        getMlsKeyPackage_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetMlsKeyPackageRequest.fromBuffer(value),
        ($0.GetMlsKeyPackageResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SearchUsersRequest, $0.SearchUsersResponse>(
            'SearchUsers',
            searchUsers_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SearchUsersRequest.fromBuffer(value),
            ($0.SearchUsersResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetUserProfileRequest,
            $0.GetUserProfileResponse>(
        'GetUserProfile',
        getUserProfile_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetUserProfileRequest.fromBuffer(value),
        ($0.GetUserProfileResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DeleteAccountRequest, $0.DeleteAccountResponse>(
            'DeleteAccount',
            deleteAccount_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DeleteAccountRequest.fromBuffer(value),
            ($0.DeleteAccountResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HealthRequest, $1.HealthStatus>(
        'Health',
        health_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HealthRequest.fromBuffer(value),
        ($1.HealthStatus value) => value.writeToBuffer()));
  }

  $async.Future<$0.RegisterResponse> register_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RegisterRequest> $request) async {
    return register($call, await $request);
  }

  $async.Future<$0.RegisterResponse> register(
      $grpc.ServiceCall call, $0.RegisterRequest request);

  $async.Future<$0.LoginResponse> login_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LoginRequest> $request) async {
    return login($call, await $request);
  }

  $async.Future<$0.LoginResponse> login(
      $grpc.ServiceCall call, $0.LoginRequest request);

  $async.Future<$0.LogoutResponse> logout_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LogoutRequest> $request) async {
    return logout($call, await $request);
  }

  $async.Future<$0.LogoutResponse> logout(
      $grpc.ServiceCall call, $0.LogoutRequest request);

  $async.Future<$0.RefreshTokenResponse> refreshToken_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RefreshTokenRequest> $request) async {
    return refreshToken($call, await $request);
  }

  $async.Future<$0.RefreshTokenResponse> refreshToken(
      $grpc.ServiceCall call, $0.RefreshTokenRequest request);

  $async.Future<$0.ValidateTokenResponse> validateToken_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ValidateTokenRequest> $request) async {
    return validateToken($call, await $request);
  }

  $async.Future<$0.ValidateTokenResponse> validateToken(
      $grpc.ServiceCall call, $0.ValidateTokenRequest request);

  $async.Future<$0.GetKeyBundleResponse> getKeyBundle_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetKeyBundleRequest> $request) async {
    return getKeyBundle($call, await $request);
  }

  $async.Future<$0.GetKeyBundleResponse> getKeyBundle(
      $grpc.ServiceCall call, $0.GetKeyBundleRequest request);

  $async.Future<$0.UploadPreKeysResponse> uploadPreKeys_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UploadPreKeysRequest> $request) async {
    return uploadPreKeys($call, await $request);
  }

  $async.Future<$0.UploadPreKeysResponse> uploadPreKeys(
      $grpc.ServiceCall call, $0.UploadPreKeysRequest request);

  $async.Future<$0.UploadMlsKeyPackageResponse> uploadMlsKeyPackage_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UploadMlsKeyPackageRequest> $request) async {
    return uploadMlsKeyPackage($call, await $request);
  }

  $async.Future<$0.UploadMlsKeyPackageResponse> uploadMlsKeyPackage(
      $grpc.ServiceCall call, $0.UploadMlsKeyPackageRequest request);

  $async.Future<$0.GetMlsKeyPackageResponse> getMlsKeyPackage_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetMlsKeyPackageRequest> $request) async {
    return getMlsKeyPackage($call, await $request);
  }

  $async.Future<$0.GetMlsKeyPackageResponse> getMlsKeyPackage(
      $grpc.ServiceCall call, $0.GetMlsKeyPackageRequest request);

  $async.Future<$0.SearchUsersResponse> searchUsers_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SearchUsersRequest> $request) async {
    return searchUsers($call, await $request);
  }

  $async.Future<$0.SearchUsersResponse> searchUsers(
      $grpc.ServiceCall call, $0.SearchUsersRequest request);

  $async.Future<$0.GetUserProfileResponse> getUserProfile_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetUserProfileRequest> $request) async {
    return getUserProfile($call, await $request);
  }

  $async.Future<$0.GetUserProfileResponse> getUserProfile(
      $grpc.ServiceCall call, $0.GetUserProfileRequest request);

  $async.Future<$0.DeleteAccountResponse> deleteAccount_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteAccountRequest> $request) async {
    return deleteAccount($call, await $request);
  }

  $async.Future<$0.DeleteAccountResponse> deleteAccount(
      $grpc.ServiceCall call, $0.DeleteAccountRequest request);

  $async.Future<$1.HealthStatus> health_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.HealthRequest> $request) async {
    return health($call, await $request);
  }

  $async.Future<$1.HealthStatus> health(
      $grpc.ServiceCall call, $0.HealthRequest request);
}
