// This is a generated file - do not edit.
//
// Generated from notifications.proto.

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
import 'notifications.pb.dart' as $0;

export 'notifications.pb.dart';

@$pb.GrpcServiceName('guardyn.notifications.NotificationService')
class NotificationServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  NotificationServiceClient(super.channel, {super.options, super.interceptors});

  /// Register a device for push notifications
  $grpc.ResponseFuture<$0.RegisterDeviceResponse> registerDevice(
    $0.RegisterDeviceRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$registerDevice, request, options: options);
  }

  /// Unregister a device (on logout or token refresh)
  $grpc.ResponseFuture<$0.UnregisterDeviceResponse> unregisterDevice(
    $0.UnregisterDeviceRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unregisterDevice, request, options: options);
  }

  /// Update push token (when FCM/APNs token refreshes)
  $grpc.ResponseFuture<$0.UpdatePushTokenResponse> updatePushToken(
    $0.UpdatePushTokenRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updatePushToken, request, options: options);
  }

  /// Get user's notification preferences
  $grpc.ResponseFuture<$0.GetNotificationSettingsResponse>
      getNotificationSettings(
    $0.GetNotificationSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getNotificationSettings, request,
        options: options);
  }

  /// Update notification preferences
  $grpc.ResponseFuture<$0.UpdateNotificationSettingsResponse>
      updateNotificationSettings(
    $0.UpdateNotificationSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateNotificationSettings, request,
        options: options);
  }

  /// Mute/unmute a conversation
  $grpc.ResponseFuture<$0.MuteConversationResponse> muteConversation(
    $0.MuteConversationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$muteConversation, request, options: options);
  }

  /// Send a test notification (for debugging)
  $grpc.ResponseFuture<$0.SendTestNotificationResponse> sendTestNotification(
    $0.SendTestNotificationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sendTestNotification, request, options: options);
  }

  /// Health check
  $grpc.ResponseFuture<$1.HealthStatus> health(
    $0.HealthRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$health, request, options: options);
  }

  // method descriptors

  static final _$registerDevice =
      $grpc.ClientMethod<$0.RegisterDeviceRequest, $0.RegisterDeviceResponse>(
          '/guardyn.notifications.NotificationService/RegisterDevice',
          ($0.RegisterDeviceRequest value) => value.writeToBuffer(),
          $0.RegisterDeviceResponse.fromBuffer);
  static final _$unregisterDevice = $grpc.ClientMethod<
          $0.UnregisterDeviceRequest, $0.UnregisterDeviceResponse>(
      '/guardyn.notifications.NotificationService/UnregisterDevice',
      ($0.UnregisterDeviceRequest value) => value.writeToBuffer(),
      $0.UnregisterDeviceResponse.fromBuffer);
  static final _$updatePushToken =
      $grpc.ClientMethod<$0.UpdatePushTokenRequest, $0.UpdatePushTokenResponse>(
          '/guardyn.notifications.NotificationService/UpdatePushToken',
          ($0.UpdatePushTokenRequest value) => value.writeToBuffer(),
          $0.UpdatePushTokenResponse.fromBuffer);
  static final _$getNotificationSettings = $grpc.ClientMethod<
          $0.GetNotificationSettingsRequest,
          $0.GetNotificationSettingsResponse>(
      '/guardyn.notifications.NotificationService/GetNotificationSettings',
      ($0.GetNotificationSettingsRequest value) => value.writeToBuffer(),
      $0.GetNotificationSettingsResponse.fromBuffer);
  static final _$updateNotificationSettings = $grpc.ClientMethod<
          $0.UpdateNotificationSettingsRequest,
          $0.UpdateNotificationSettingsResponse>(
      '/guardyn.notifications.NotificationService/UpdateNotificationSettings',
      ($0.UpdateNotificationSettingsRequest value) => value.writeToBuffer(),
      $0.UpdateNotificationSettingsResponse.fromBuffer);
  static final _$muteConversation = $grpc.ClientMethod<
          $0.MuteConversationRequest, $0.MuteConversationResponse>(
      '/guardyn.notifications.NotificationService/MuteConversation',
      ($0.MuteConversationRequest value) => value.writeToBuffer(),
      $0.MuteConversationResponse.fromBuffer);
  static final _$sendTestNotification = $grpc.ClientMethod<
          $0.SendTestNotificationRequest, $0.SendTestNotificationResponse>(
      '/guardyn.notifications.NotificationService/SendTestNotification',
      ($0.SendTestNotificationRequest value) => value.writeToBuffer(),
      $0.SendTestNotificationResponse.fromBuffer);
  static final _$health = $grpc.ClientMethod<$0.HealthRequest, $1.HealthStatus>(
      '/guardyn.notifications.NotificationService/Health',
      ($0.HealthRequest value) => value.writeToBuffer(),
      $1.HealthStatus.fromBuffer);
}

@$pb.GrpcServiceName('guardyn.notifications.NotificationService')
abstract class NotificationServiceBase extends $grpc.Service {
  $core.String get $name => 'guardyn.notifications.NotificationService';

  NotificationServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.RegisterDeviceRequest,
            $0.RegisterDeviceResponse>(
        'RegisterDevice',
        registerDevice_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RegisterDeviceRequest.fromBuffer(value),
        ($0.RegisterDeviceResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UnregisterDeviceRequest,
            $0.UnregisterDeviceResponse>(
        'UnregisterDevice',
        unregisterDevice_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UnregisterDeviceRequest.fromBuffer(value),
        ($0.UnregisterDeviceResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdatePushTokenRequest,
            $0.UpdatePushTokenResponse>(
        'UpdatePushToken',
        updatePushToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdatePushTokenRequest.fromBuffer(value),
        ($0.UpdatePushTokenResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetNotificationSettingsRequest,
            $0.GetNotificationSettingsResponse>(
        'GetNotificationSettings',
        getNotificationSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetNotificationSettingsRequest.fromBuffer(value),
        ($0.GetNotificationSettingsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateNotificationSettingsRequest,
            $0.UpdateNotificationSettingsResponse>(
        'UpdateNotificationSettings',
        updateNotificationSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateNotificationSettingsRequest.fromBuffer(value),
        ($0.UpdateNotificationSettingsResponse value) =>
            value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.MuteConversationRequest,
            $0.MuteConversationResponse>(
        'MuteConversation',
        muteConversation_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.MuteConversationRequest.fromBuffer(value),
        ($0.MuteConversationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SendTestNotificationRequest,
            $0.SendTestNotificationResponse>(
        'SendTestNotification',
        sendTestNotification_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SendTestNotificationRequest.fromBuffer(value),
        ($0.SendTestNotificationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HealthRequest, $1.HealthStatus>(
        'Health',
        health_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HealthRequest.fromBuffer(value),
        ($1.HealthStatus value) => value.writeToBuffer()));
  }

  $async.Future<$0.RegisterDeviceResponse> registerDevice_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RegisterDeviceRequest> $request) async {
    return registerDevice($call, await $request);
  }

  $async.Future<$0.RegisterDeviceResponse> registerDevice(
      $grpc.ServiceCall call, $0.RegisterDeviceRequest request);

  $async.Future<$0.UnregisterDeviceResponse> unregisterDevice_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UnregisterDeviceRequest> $request) async {
    return unregisterDevice($call, await $request);
  }

  $async.Future<$0.UnregisterDeviceResponse> unregisterDevice(
      $grpc.ServiceCall call, $0.UnregisterDeviceRequest request);

  $async.Future<$0.UpdatePushTokenResponse> updatePushToken_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdatePushTokenRequest> $request) async {
    return updatePushToken($call, await $request);
  }

  $async.Future<$0.UpdatePushTokenResponse> updatePushToken(
      $grpc.ServiceCall call, $0.UpdatePushTokenRequest request);

  $async.Future<$0.GetNotificationSettingsResponse> getNotificationSettings_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetNotificationSettingsRequest> $request) async {
    return getNotificationSettings($call, await $request);
  }

  $async.Future<$0.GetNotificationSettingsResponse> getNotificationSettings(
      $grpc.ServiceCall call, $0.GetNotificationSettingsRequest request);

  $async.Future<$0.UpdateNotificationSettingsResponse>
      updateNotificationSettings_Pre($grpc.ServiceCall $call,
          $async.Future<$0.UpdateNotificationSettingsRequest> $request) async {
    return updateNotificationSettings($call, await $request);
  }

  $async.Future<$0.UpdateNotificationSettingsResponse>
      updateNotificationSettings(
          $grpc.ServiceCall call, $0.UpdateNotificationSettingsRequest request);

  $async.Future<$0.MuteConversationResponse> muteConversation_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.MuteConversationRequest> $request) async {
    return muteConversation($call, await $request);
  }

  $async.Future<$0.MuteConversationResponse> muteConversation(
      $grpc.ServiceCall call, $0.MuteConversationRequest request);

  $async.Future<$0.SendTestNotificationResponse> sendTestNotification_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SendTestNotificationRequest> $request) async {
    return sendTestNotification($call, await $request);
  }

  $async.Future<$0.SendTestNotificationResponse> sendTestNotification(
      $grpc.ServiceCall call, $0.SendTestNotificationRequest request);

  $async.Future<$1.HealthStatus> health_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.HealthRequest> $request) async {
    return health($call, await $request);
  }

  $async.Future<$1.HealthStatus> health(
      $grpc.ServiceCall call, $0.HealthRequest request);
}
