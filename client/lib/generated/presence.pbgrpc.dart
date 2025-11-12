// This is a generated file - do not edit.
//
// Generated from presence.proto.

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
import 'presence.pb.dart' as $0;

export 'presence.pb.dart';

@$pb.GrpcServiceName('guardyn.presence.PresenceService')
class PresenceServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  PresenceServiceClient(super.channel, {super.options, super.interceptors});

  /// Update user's online status
  $grpc.ResponseFuture<$0.UpdateStatusResponse> updateStatus(
    $0.UpdateStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateStatus, request, options: options);
  }

  /// Get user's current status
  $grpc.ResponseFuture<$0.GetStatusResponse> getStatus(
    $0.GetStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getStatus, request, options: options);
  }

  /// Subscribe to presence updates (streaming)
  $grpc.ResponseStream<$0.PresenceUpdate> subscribe(
    $0.SubscribeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$subscribe, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Update last seen timestamp
  $grpc.ResponseFuture<$0.UpdateLastSeenResponse> updateLastSeen(
    $0.UpdateLastSeenRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateLastSeen, request, options: options);
  }

  /// Health check
  $grpc.ResponseFuture<$1.HealthStatus> health(
    $0.HealthRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$health, request, options: options);
  }

  // method descriptors

  static final _$updateStatus =
      $grpc.ClientMethod<$0.UpdateStatusRequest, $0.UpdateStatusResponse>(
          '/guardyn.presence.PresenceService/UpdateStatus',
          ($0.UpdateStatusRequest value) => value.writeToBuffer(),
          $0.UpdateStatusResponse.fromBuffer);
  static final _$getStatus =
      $grpc.ClientMethod<$0.GetStatusRequest, $0.GetStatusResponse>(
          '/guardyn.presence.PresenceService/GetStatus',
          ($0.GetStatusRequest value) => value.writeToBuffer(),
          $0.GetStatusResponse.fromBuffer);
  static final _$subscribe =
      $grpc.ClientMethod<$0.SubscribeRequest, $0.PresenceUpdate>(
          '/guardyn.presence.PresenceService/Subscribe',
          ($0.SubscribeRequest value) => value.writeToBuffer(),
          $0.PresenceUpdate.fromBuffer);
  static final _$updateLastSeen =
      $grpc.ClientMethod<$0.UpdateLastSeenRequest, $0.UpdateLastSeenResponse>(
          '/guardyn.presence.PresenceService/UpdateLastSeen',
          ($0.UpdateLastSeenRequest value) => value.writeToBuffer(),
          $0.UpdateLastSeenResponse.fromBuffer);
  static final _$health = $grpc.ClientMethod<$0.HealthRequest, $1.HealthStatus>(
      '/guardyn.presence.PresenceService/Health',
      ($0.HealthRequest value) => value.writeToBuffer(),
      $1.HealthStatus.fromBuffer);
}

@$pb.GrpcServiceName('guardyn.presence.PresenceService')
abstract class PresenceServiceBase extends $grpc.Service {
  $core.String get $name => 'guardyn.presence.PresenceService';

  PresenceServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.UpdateStatusRequest, $0.UpdateStatusResponse>(
            'UpdateStatus',
            updateStatus_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UpdateStatusRequest.fromBuffer(value),
            ($0.UpdateStatusResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetStatusRequest, $0.GetStatusResponse>(
        'GetStatus',
        getStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetStatusRequest.fromBuffer(value),
        ($0.GetStatusResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SubscribeRequest, $0.PresenceUpdate>(
        'Subscribe',
        subscribe_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.SubscribeRequest.fromBuffer(value),
        ($0.PresenceUpdate value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateLastSeenRequest,
            $0.UpdateLastSeenResponse>(
        'UpdateLastSeen',
        updateLastSeen_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateLastSeenRequest.fromBuffer(value),
        ($0.UpdateLastSeenResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HealthRequest, $1.HealthStatus>(
        'Health',
        health_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HealthRequest.fromBuffer(value),
        ($1.HealthStatus value) => value.writeToBuffer()));
  }

  $async.Future<$0.UpdateStatusResponse> updateStatus_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateStatusRequest> $request) async {
    return updateStatus($call, await $request);
  }

  $async.Future<$0.UpdateStatusResponse> updateStatus(
      $grpc.ServiceCall call, $0.UpdateStatusRequest request);

  $async.Future<$0.GetStatusResponse> getStatus_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetStatusRequest> $request) async {
    return getStatus($call, await $request);
  }

  $async.Future<$0.GetStatusResponse> getStatus(
      $grpc.ServiceCall call, $0.GetStatusRequest request);

  $async.Stream<$0.PresenceUpdate> subscribe_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SubscribeRequest> $request) async* {
    yield* subscribe($call, await $request);
  }

  $async.Stream<$0.PresenceUpdate> subscribe(
      $grpc.ServiceCall call, $0.SubscribeRequest request);

  $async.Future<$0.UpdateLastSeenResponse> updateLastSeen_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateLastSeenRequest> $request) async {
    return updateLastSeen($call, await $request);
  }

  $async.Future<$0.UpdateLastSeenResponse> updateLastSeen(
      $grpc.ServiceCall call, $0.UpdateLastSeenRequest request);

  $async.Future<$1.HealthStatus> health_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.HealthRequest> $request) async {
    return health($call, await $request);
  }

  $async.Future<$1.HealthStatus> health(
      $grpc.ServiceCall call, $0.HealthRequest request);
}
