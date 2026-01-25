// This is a generated file - do not edit.
//
// Generated from calls.proto.

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

import 'calls.pb.dart' as $0;
import 'common.pb.dart' as $1;

export 'calls.pb.dart';

@$pb.GrpcServiceName('guardyn.calls.CallService')
class CallServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  CallServiceClient(super.channel, {super.options, super.interceptors});

  /// Initiate a call (1-on-1 or group)
  $grpc.ResponseFuture<$0.InitiateCallResponse> initiateCall(
    $0.InitiateCallRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$initiateCall, request, options: options);
  }

  /// Accept an incoming call
  $grpc.ResponseFuture<$0.AcceptCallResponse> acceptCall(
    $0.AcceptCallRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$acceptCall, request, options: options);
  }

  /// Reject an incoming call
  $grpc.ResponseFuture<$0.RejectCallResponse> rejectCall(
    $0.RejectCallRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$rejectCall, request, options: options);
  }

  /// End an active call
  $grpc.ResponseFuture<$0.EndCallResponse> endCall(
    $0.EndCallRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$endCall, request, options: options);
  }

  /// Join an ongoing group call
  $grpc.ResponseFuture<$0.JoinCallResponse> joinCall(
    $0.JoinCallRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$joinCall, request, options: options);
  }

  /// Leave a group call (without ending it)
  $grpc.ResponseFuture<$0.LeaveCallResponse> leaveCall(
    $0.LeaveCallRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$leaveCall, request, options: options);
  }

  /// Mute/unmute audio
  $grpc.ResponseFuture<$0.SetMuteResponse> setMute(
    $0.SetMuteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setMute, request, options: options);
  }

  /// Enable/disable video
  $grpc.ResponseFuture<$0.SetVideoResponse> setVideo(
    $0.SetVideoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setVideo, request, options: options);
  }

  /// Screen sharing
  $grpc.ResponseFuture<$0.SetScreenShareResponse> setScreenShare(
    $0.SetScreenShareRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setScreenShare, request, options: options);
  }

  /// Exchange ICE candidates (WebRTC signaling)
  $grpc.ResponseFuture<$0.ExchangeIceCandidateResponse> exchangeIceCandidate(
    $0.ExchangeIceCandidateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$exchangeIceCandidate, request, options: options);
  }

  /// Exchange SDP offer/answer (WebRTC signaling)
  $grpc.ResponseFuture<$0.ExchangeSdpResponse> exchangeSdp(
    $0.ExchangeSdpRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$exchangeSdp, request, options: options);
  }

  /// Get current call state
  $grpc.ResponseFuture<$0.GetCallStateResponse> getCallState(
    $0.GetCallStateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getCallState, request, options: options);
  }

  /// Get call history
  $grpc.ResponseFuture<$0.GetCallHistoryResponse> getCallHistory(
    $0.GetCallHistoryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getCallHistory, request, options: options);
  }

  /// Stream call events (participant joined/left, state changes)
  $grpc.ResponseStream<$0.CallEvent> streamCallEvents(
    $0.StreamCallEventsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamCallEvents, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Subscribe to incoming call notifications for the current user
  $grpc.ResponseStream<$0.IncomingCallNotification> subscribeToIncomingCalls(
    $0.SubscribeToIncomingCallsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$subscribeToIncomingCalls, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Exchange SFrame encryption keys
  $grpc.ResponseFuture<$0.ExchangeSFrameKeyResponse> exchangeSFrameKey(
    $0.ExchangeSFrameKeyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$exchangeSFrameKey, request, options: options);
  }

  /// Rotate SFrame encryption key
  $grpc.ResponseFuture<$0.RotateSFrameKeyResponse> rotateSFrameKey(
    $0.RotateSFrameKeyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$rotateSFrameKey, request, options: options);
  }

  /// Health check
  $grpc.ResponseFuture<$1.HealthStatus> health(
    $0.HealthRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$health, request, options: options);
  }

  // method descriptors

  static final _$initiateCall =
      $grpc.ClientMethod<$0.InitiateCallRequest, $0.InitiateCallResponse>(
          '/guardyn.calls.CallService/InitiateCall',
          ($0.InitiateCallRequest value) => value.writeToBuffer(),
          $0.InitiateCallResponse.fromBuffer);
  static final _$acceptCall =
      $grpc.ClientMethod<$0.AcceptCallRequest, $0.AcceptCallResponse>(
          '/guardyn.calls.CallService/AcceptCall',
          ($0.AcceptCallRequest value) => value.writeToBuffer(),
          $0.AcceptCallResponse.fromBuffer);
  static final _$rejectCall =
      $grpc.ClientMethod<$0.RejectCallRequest, $0.RejectCallResponse>(
          '/guardyn.calls.CallService/RejectCall',
          ($0.RejectCallRequest value) => value.writeToBuffer(),
          $0.RejectCallResponse.fromBuffer);
  static final _$endCall =
      $grpc.ClientMethod<$0.EndCallRequest, $0.EndCallResponse>(
          '/guardyn.calls.CallService/EndCall',
          ($0.EndCallRequest value) => value.writeToBuffer(),
          $0.EndCallResponse.fromBuffer);
  static final _$joinCall =
      $grpc.ClientMethod<$0.JoinCallRequest, $0.JoinCallResponse>(
          '/guardyn.calls.CallService/JoinCall',
          ($0.JoinCallRequest value) => value.writeToBuffer(),
          $0.JoinCallResponse.fromBuffer);
  static final _$leaveCall =
      $grpc.ClientMethod<$0.LeaveCallRequest, $0.LeaveCallResponse>(
          '/guardyn.calls.CallService/LeaveCall',
          ($0.LeaveCallRequest value) => value.writeToBuffer(),
          $0.LeaveCallResponse.fromBuffer);
  static final _$setMute =
      $grpc.ClientMethod<$0.SetMuteRequest, $0.SetMuteResponse>(
          '/guardyn.calls.CallService/SetMute',
          ($0.SetMuteRequest value) => value.writeToBuffer(),
          $0.SetMuteResponse.fromBuffer);
  static final _$setVideo =
      $grpc.ClientMethod<$0.SetVideoRequest, $0.SetVideoResponse>(
          '/guardyn.calls.CallService/SetVideo',
          ($0.SetVideoRequest value) => value.writeToBuffer(),
          $0.SetVideoResponse.fromBuffer);
  static final _$setScreenShare =
      $grpc.ClientMethod<$0.SetScreenShareRequest, $0.SetScreenShareResponse>(
          '/guardyn.calls.CallService/SetScreenShare',
          ($0.SetScreenShareRequest value) => value.writeToBuffer(),
          $0.SetScreenShareResponse.fromBuffer);
  static final _$exchangeIceCandidate = $grpc.ClientMethod<
          $0.ExchangeIceCandidateRequest, $0.ExchangeIceCandidateResponse>(
      '/guardyn.calls.CallService/ExchangeIceCandidate',
      ($0.ExchangeIceCandidateRequest value) => value.writeToBuffer(),
      $0.ExchangeIceCandidateResponse.fromBuffer);
  static final _$exchangeSdp =
      $grpc.ClientMethod<$0.ExchangeSdpRequest, $0.ExchangeSdpResponse>(
          '/guardyn.calls.CallService/ExchangeSdp',
          ($0.ExchangeSdpRequest value) => value.writeToBuffer(),
          $0.ExchangeSdpResponse.fromBuffer);
  static final _$getCallState =
      $grpc.ClientMethod<$0.GetCallStateRequest, $0.GetCallStateResponse>(
          '/guardyn.calls.CallService/GetCallState',
          ($0.GetCallStateRequest value) => value.writeToBuffer(),
          $0.GetCallStateResponse.fromBuffer);
  static final _$getCallHistory =
      $grpc.ClientMethod<$0.GetCallHistoryRequest, $0.GetCallHistoryResponse>(
          '/guardyn.calls.CallService/GetCallHistory',
          ($0.GetCallHistoryRequest value) => value.writeToBuffer(),
          $0.GetCallHistoryResponse.fromBuffer);
  static final _$streamCallEvents =
      $grpc.ClientMethod<$0.StreamCallEventsRequest, $0.CallEvent>(
          '/guardyn.calls.CallService/StreamCallEvents',
          ($0.StreamCallEventsRequest value) => value.writeToBuffer(),
          $0.CallEvent.fromBuffer);
  static final _$subscribeToIncomingCalls = $grpc.ClientMethod<
          $0.SubscribeToIncomingCallsRequest, $0.IncomingCallNotification>(
      '/guardyn.calls.CallService/SubscribeToIncomingCalls',
      ($0.SubscribeToIncomingCallsRequest value) => value.writeToBuffer(),
      $0.IncomingCallNotification.fromBuffer);
  static final _$exchangeSFrameKey = $grpc.ClientMethod<
          $0.ExchangeSFrameKeyRequest, $0.ExchangeSFrameKeyResponse>(
      '/guardyn.calls.CallService/ExchangeSFrameKey',
      ($0.ExchangeSFrameKeyRequest value) => value.writeToBuffer(),
      $0.ExchangeSFrameKeyResponse.fromBuffer);
  static final _$rotateSFrameKey =
      $grpc.ClientMethod<$0.RotateSFrameKeyRequest, $0.RotateSFrameKeyResponse>(
          '/guardyn.calls.CallService/RotateSFrameKey',
          ($0.RotateSFrameKeyRequest value) => value.writeToBuffer(),
          $0.RotateSFrameKeyResponse.fromBuffer);
  static final _$health = $grpc.ClientMethod<$0.HealthRequest, $1.HealthStatus>(
      '/guardyn.calls.CallService/Health',
      ($0.HealthRequest value) => value.writeToBuffer(),
      $1.HealthStatus.fromBuffer);
}

@$pb.GrpcServiceName('guardyn.calls.CallService')
abstract class CallServiceBase extends $grpc.Service {
  $core.String get $name => 'guardyn.calls.CallService';

  CallServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.InitiateCallRequest, $0.InitiateCallResponse>(
            'InitiateCall',
            initiateCall_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.InitiateCallRequest.fromBuffer(value),
            ($0.InitiateCallResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AcceptCallRequest, $0.AcceptCallResponse>(
        'AcceptCall',
        acceptCall_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AcceptCallRequest.fromBuffer(value),
        ($0.AcceptCallResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RejectCallRequest, $0.RejectCallResponse>(
        'RejectCall',
        rejectCall_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RejectCallRequest.fromBuffer(value),
        ($0.RejectCallResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EndCallRequest, $0.EndCallResponse>(
        'EndCall',
        endCall_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EndCallRequest.fromBuffer(value),
        ($0.EndCallResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.JoinCallRequest, $0.JoinCallResponse>(
        'JoinCall',
        joinCall_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.JoinCallRequest.fromBuffer(value),
        ($0.JoinCallResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LeaveCallRequest, $0.LeaveCallResponse>(
        'LeaveCall',
        leaveCall_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LeaveCallRequest.fromBuffer(value),
        ($0.LeaveCallResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetMuteRequest, $0.SetMuteResponse>(
        'SetMute',
        setMute_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetMuteRequest.fromBuffer(value),
        ($0.SetMuteResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetVideoRequest, $0.SetVideoResponse>(
        'SetVideo',
        setVideo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetVideoRequest.fromBuffer(value),
        ($0.SetVideoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetScreenShareRequest,
            $0.SetScreenShareResponse>(
        'SetScreenShare',
        setScreenShare_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetScreenShareRequest.fromBuffer(value),
        ($0.SetScreenShareResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ExchangeIceCandidateRequest,
            $0.ExchangeIceCandidateResponse>(
        'ExchangeIceCandidate',
        exchangeIceCandidate_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ExchangeIceCandidateRequest.fromBuffer(value),
        ($0.ExchangeIceCandidateResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ExchangeSdpRequest, $0.ExchangeSdpResponse>(
            'ExchangeSdp',
            exchangeSdp_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ExchangeSdpRequest.fromBuffer(value),
            ($0.ExchangeSdpResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetCallStateRequest, $0.GetCallStateResponse>(
            'GetCallState',
            getCallState_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetCallStateRequest.fromBuffer(value),
            ($0.GetCallStateResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetCallHistoryRequest,
            $0.GetCallHistoryResponse>(
        'GetCallHistory',
        getCallHistory_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetCallHistoryRequest.fromBuffer(value),
        ($0.GetCallHistoryResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamCallEventsRequest, $0.CallEvent>(
        'StreamCallEvents',
        streamCallEvents_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamCallEventsRequest.fromBuffer(value),
        ($0.CallEvent value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SubscribeToIncomingCallsRequest,
            $0.IncomingCallNotification>(
        'SubscribeToIncomingCalls',
        subscribeToIncomingCalls_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.SubscribeToIncomingCallsRequest.fromBuffer(value),
        ($0.IncomingCallNotification value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ExchangeSFrameKeyRequest,
            $0.ExchangeSFrameKeyResponse>(
        'ExchangeSFrameKey',
        exchangeSFrameKey_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ExchangeSFrameKeyRequest.fromBuffer(value),
        ($0.ExchangeSFrameKeyResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RotateSFrameKeyRequest,
            $0.RotateSFrameKeyResponse>(
        'RotateSFrameKey',
        rotateSFrameKey_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RotateSFrameKeyRequest.fromBuffer(value),
        ($0.RotateSFrameKeyResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HealthRequest, $1.HealthStatus>(
        'Health',
        health_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HealthRequest.fromBuffer(value),
        ($1.HealthStatus value) => value.writeToBuffer()));
  }

  $async.Future<$0.InitiateCallResponse> initiateCall_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.InitiateCallRequest> $request) async {
    return initiateCall($call, await $request);
  }

  $async.Future<$0.InitiateCallResponse> initiateCall(
      $grpc.ServiceCall call, $0.InitiateCallRequest request);

  $async.Future<$0.AcceptCallResponse> acceptCall_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AcceptCallRequest> $request) async {
    return acceptCall($call, await $request);
  }

  $async.Future<$0.AcceptCallResponse> acceptCall(
      $grpc.ServiceCall call, $0.AcceptCallRequest request);

  $async.Future<$0.RejectCallResponse> rejectCall_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RejectCallRequest> $request) async {
    return rejectCall($call, await $request);
  }

  $async.Future<$0.RejectCallResponse> rejectCall(
      $grpc.ServiceCall call, $0.RejectCallRequest request);

  $async.Future<$0.EndCallResponse> endCall_Pre($grpc.ServiceCall $call,
      $async.Future<$0.EndCallRequest> $request) async {
    return endCall($call, await $request);
  }

  $async.Future<$0.EndCallResponse> endCall(
      $grpc.ServiceCall call, $0.EndCallRequest request);

  $async.Future<$0.JoinCallResponse> joinCall_Pre($grpc.ServiceCall $call,
      $async.Future<$0.JoinCallRequest> $request) async {
    return joinCall($call, await $request);
  }

  $async.Future<$0.JoinCallResponse> joinCall(
      $grpc.ServiceCall call, $0.JoinCallRequest request);

  $async.Future<$0.LeaveCallResponse> leaveCall_Pre($grpc.ServiceCall $call,
      $async.Future<$0.LeaveCallRequest> $request) async {
    return leaveCall($call, await $request);
  }

  $async.Future<$0.LeaveCallResponse> leaveCall(
      $grpc.ServiceCall call, $0.LeaveCallRequest request);

  $async.Future<$0.SetMuteResponse> setMute_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetMuteRequest> $request) async {
    return setMute($call, await $request);
  }

  $async.Future<$0.SetMuteResponse> setMute(
      $grpc.ServiceCall call, $0.SetMuteRequest request);

  $async.Future<$0.SetVideoResponse> setVideo_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetVideoRequest> $request) async {
    return setVideo($call, await $request);
  }

  $async.Future<$0.SetVideoResponse> setVideo(
      $grpc.ServiceCall call, $0.SetVideoRequest request);

  $async.Future<$0.SetScreenShareResponse> setScreenShare_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SetScreenShareRequest> $request) async {
    return setScreenShare($call, await $request);
  }

  $async.Future<$0.SetScreenShareResponse> setScreenShare(
      $grpc.ServiceCall call, $0.SetScreenShareRequest request);

  $async.Future<$0.ExchangeIceCandidateResponse> exchangeIceCandidate_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ExchangeIceCandidateRequest> $request) async {
    return exchangeIceCandidate($call, await $request);
  }

  $async.Future<$0.ExchangeIceCandidateResponse> exchangeIceCandidate(
      $grpc.ServiceCall call, $0.ExchangeIceCandidateRequest request);

  $async.Future<$0.ExchangeSdpResponse> exchangeSdp_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ExchangeSdpRequest> $request) async {
    return exchangeSdp($call, await $request);
  }

  $async.Future<$0.ExchangeSdpResponse> exchangeSdp(
      $grpc.ServiceCall call, $0.ExchangeSdpRequest request);

  $async.Future<$0.GetCallStateResponse> getCallState_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetCallStateRequest> $request) async {
    return getCallState($call, await $request);
  }

  $async.Future<$0.GetCallStateResponse> getCallState(
      $grpc.ServiceCall call, $0.GetCallStateRequest request);

  $async.Future<$0.GetCallHistoryResponse> getCallHistory_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetCallHistoryRequest> $request) async {
    return getCallHistory($call, await $request);
  }

  $async.Future<$0.GetCallHistoryResponse> getCallHistory(
      $grpc.ServiceCall call, $0.GetCallHistoryRequest request);

  $async.Stream<$0.CallEvent> streamCallEvents_Pre($grpc.ServiceCall $call,
      $async.Future<$0.StreamCallEventsRequest> $request) async* {
    yield* streamCallEvents($call, await $request);
  }

  $async.Stream<$0.CallEvent> streamCallEvents(
      $grpc.ServiceCall call, $0.StreamCallEventsRequest request);

  $async.Stream<$0.IncomingCallNotification> subscribeToIncomingCalls_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SubscribeToIncomingCallsRequest> $request) async* {
    yield* subscribeToIncomingCalls($call, await $request);
  }

  $async.Stream<$0.IncomingCallNotification> subscribeToIncomingCalls(
      $grpc.ServiceCall call, $0.SubscribeToIncomingCallsRequest request);

  $async.Future<$0.ExchangeSFrameKeyResponse> exchangeSFrameKey_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ExchangeSFrameKeyRequest> $request) async {
    return exchangeSFrameKey($call, await $request);
  }

  $async.Future<$0.ExchangeSFrameKeyResponse> exchangeSFrameKey(
      $grpc.ServiceCall call, $0.ExchangeSFrameKeyRequest request);

  $async.Future<$0.RotateSFrameKeyResponse> rotateSFrameKey_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RotateSFrameKeyRequest> $request) async {
    return rotateSFrameKey($call, await $request);
  }

  $async.Future<$0.RotateSFrameKeyResponse> rotateSFrameKey(
      $grpc.ServiceCall call, $0.RotateSFrameKeyRequest request);

  $async.Future<$1.HealthStatus> health_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.HealthRequest> $request) async {
    return health($call, await $request);
  }

  $async.Future<$1.HealthStatus> health(
      $grpc.ServiceCall call, $0.HealthRequest request);
}
