/// Call gRPC Remote DataSource
///
/// Handles gRPC communication with the Call Service for voice/video calls.
library;

import 'package:grpc/grpc.dart';
import 'package:guardyn_client/generated/calls.pb.dart' as proto;
import 'package:guardyn_client/generated/calls.pbgrpc.dart';
import 'package:logger/logger.dart';

/// gRPC DataSource for call operations
class CallRemoteDatasource {
  final CallServiceClient _client;
  final Logger _logger;

  CallRemoteDatasource({
    required CallServiceClient client,
    required Logger logger,
  }) : _client = client,
       _logger = logger;

  /// Create call metadata with authorization
  CallOptions _createOptions(String accessToken) {
    return CallOptions(metadata: {'authorization': 'Bearer $accessToken'});
  }

  /// Initiate a call to a user
  Future<CallInitiatedResult> initiateCall({
    required String accessToken,
    required String userId,
    required bool isVideo,
  }) async {
    _logger.i('Initiating ${isVideo ? "video" : "voice"} call to $userId');

    try {
      final request = proto.InitiateCallRequest()
        ..accessToken = accessToken
        ..userId = userId
        ..callType = isVideo ? proto.CallType.VIDEO : proto.CallType.VOICE
        ..capabilities = (proto.ClientCapabilities()
          ..supportsVideo = true
          ..supportsScreenShare = true
          ..supportsSframe = true
          ..supportedCodecs.addAll(['opus', 'VP8', 'VP9'])
          ..maxVideoWidth = 1920
          ..maxVideoHeight = 1080
          ..maxVideoFps = 30);

      final response = await _client.initiateCall(
        request,
        options: _createOptions(accessToken),
      );

      if (response.hasSuccess()) {
        final success = response.success;
        _logger.i('Call initiated: ${success.callId}');
        return CallInitiatedResult(
          callId: success.callId,
          state: _mapCallState(success.state),
          iceServers: success.iceServers
              .map(
                (s) => IceServerInfo(
                  urls: s.urls,
                  username: s.username.isEmpty ? null : s.username,
                  credential: s.credential.isEmpty ? null : s.credential,
                ),
              )
              .toList(),
          sframeKeyMaterial: success.sframeKeyMaterial,
          sframeKeyId: success.sframeKeyId,
        );
      } else if (response.hasError()) {
        throw GrpcCallException(response.error.message);
      } else {
        throw GrpcCallException('Empty response');
      }
    } on GrpcError catch (e) {
      _logger.e('gRPC error initiating call: ${e.message}');
      throw GrpcCallException(e.message ?? 'Unknown gRPC error');
    }
  }

  /// Accept an incoming call
  Future<CallInitiatedResult> acceptCall({
    required String accessToken,
    required String callId,
  }) async {
    _logger.i('Accepting call: $callId');

    try {
      final request = proto.AcceptCallRequest()
        ..accessToken = accessToken
        ..callId = callId
        ..capabilities = (proto.ClientCapabilities()
          ..supportsVideo = true
          ..supportsScreenShare = true
          ..supportsSframe = true
          ..supportedCodecs.addAll(['opus', 'VP8', 'VP9'])
          ..maxVideoWidth = 1920
          ..maxVideoHeight = 1080
          ..maxVideoFps = 30);

      final response = await _client.acceptCall(
        request,
        options: _createOptions(accessToken),
      );

      if (response.hasSuccess()) {
        final success = response.success;
        _logger.i('Call accepted: ${success.callId}');
        return CallInitiatedResult(
          callId: success.callId,
          state: _mapCallState(success.state),
          iceServers: success.iceServers
              .map(
                (s) => IceServerInfo(
                  urls: s.urls,
                  username: s.username.isEmpty ? null : s.username,
                  credential: s.credential.isEmpty ? null : s.credential,
                ),
              )
              .toList(),
          sframeKeyMaterial: success.sframeKeyMaterial,
          sframeKeyId: success.sframeKeyId,
        );
      } else if (response.hasError()) {
        throw GrpcCallException(response.error.message);
      } else {
        throw GrpcCallException('Empty response');
      }
    } on GrpcError catch (e) {
      _logger.e('gRPC error accepting call: ${e.message}');
      throw GrpcCallException(e.message ?? 'Unknown gRPC error');
    }
  }

  /// Reject an incoming call
  Future<void> rejectCall({
    required String accessToken,
    required String callId,
    String? reason,
  }) async {
    _logger.i('Rejecting call: $callId');

    try {
      final request = proto.RejectCallRequest()
        ..accessToken = accessToken
        ..callId = callId
        ..reason = reason ?? '';

      final response = await _client.rejectCall(
        request,
        options: _createOptions(accessToken),
      );

      if (response.hasError()) {
        throw GrpcCallException(response.error.message);
      }
      _logger.i('Call rejected');
    } on GrpcError catch (e) {
      _logger.e('gRPC error rejecting call: ${e.message}');
      throw GrpcCallException(e.message ?? 'Unknown gRPC error');
    }
  }

  /// End an active call
  Future<EndCallResult> endCall({
    required String accessToken,
    required String callId,
    CallEndReasonType reason = CallEndReasonType.completed,
  }) async {
    _logger.i('Ending call: $callId');

    try {
      final request = proto.EndCallRequest()
        ..accessToken = accessToken
        ..callId = callId
        ..reason = _mapEndReasonToProto(reason);

      final response = await _client.endCall(
        request,
        options: _createOptions(accessToken),
      );

      if (response.hasSuccess()) {
        _logger.i('Call ended, duration: ${response.success.durationSeconds}s');
        return EndCallResult(
          ended: response.success.ended,
          durationSeconds: response.success.durationSeconds,
        );
      } else if (response.hasError()) {
        throw GrpcCallException(response.error.message);
      } else {
        throw GrpcCallException('Empty response');
      }
    } on GrpcError catch (e) {
      _logger.e('gRPC error ending call: ${e.message}');
      throw GrpcCallException(e.message ?? 'Unknown gRPC error');
    }
  }

  /// Exchange SDP (offer/answer)
  Future<void> exchangeSdp({
    required String accessToken,
    required String callId,
    required String targetUserId,
    required SdpMessageType type,
    required String sdp,
  }) async {
    _logger.d('Exchanging SDP: $type');

    try {
      final request = proto.ExchangeSdpRequest()
        ..accessToken = accessToken
        ..callId = callId
        ..targetUserId = targetUserId
        ..sdp = (proto.SdpMessage()
          ..type = _mapSdpTypeToProto(type)
          ..sdp = sdp);

      final response = await _client.exchangeSdp(
        request,
        options: _createOptions(accessToken),
      );

      if (response.hasError()) {
        throw GrpcCallException(response.error.message);
      }
      _logger.d('SDP exchanged successfully');
    } on GrpcError catch (e) {
      _logger.e('gRPC error exchanging SDP: ${e.message}');
      throw GrpcCallException(e.message ?? 'Unknown gRPC error');
    }
  }

  /// Exchange ICE candidate
  Future<void> exchangeIceCandidate({
    required String accessToken,
    required String callId,
    required String targetUserId,
    required String candidate,
    required String sdpMid,
    required int sdpMLineIndex,
    String? usernameFragment,
  }) async {
    _logger.d('Exchanging ICE candidate');

    try {
      final request = proto.ExchangeIceCandidateRequest()
        ..accessToken = accessToken
        ..callId = callId
        ..targetUserId = targetUserId
        ..candidate = (proto.IceCandidate()
          ..candidate = candidate
          ..sdpMid = sdpMid
          ..sdpMlineIndex = sdpMLineIndex
          ..usernameFragment = usernameFragment ?? '');

      final response = await _client.exchangeIceCandidate(
        request,
        options: _createOptions(accessToken),
      );

      if (response.hasError()) {
        throw GrpcCallException(response.error.message);
      }
    } on GrpcError catch (e) {
      _logger.e('gRPC error exchanging ICE candidate: ${e.message}');
      throw GrpcCallException(e.message ?? 'Unknown gRPC error');
    }
  }

  /// Set mute state
  Future<bool> setMute({
    required String accessToken,
    required String callId,
    required bool muted,
  }) async {
    _logger.i('Setting mute: $muted');

    try {
      final request = proto.SetMuteRequest()
        ..accessToken = accessToken
        ..callId = callId
        ..muted = muted;

      final response = await _client.setMute(
        request,
        options: _createOptions(accessToken),
      );

      if (response.hasSuccess()) {
        return response.success.muted;
      } else if (response.hasError()) {
        throw GrpcCallException(response.error.message);
      }
      return muted;
    } on GrpcError catch (e) {
      _logger.e('gRPC error setting mute: ${e.message}');
      throw GrpcCallException(e.message ?? 'Unknown gRPC error');
    }
  }

  /// Set video state
  Future<bool> setVideo({
    required String accessToken,
    required String callId,
    required bool enabled,
  }) async {
    _logger.i('Setting video: $enabled');

    try {
      final request = proto.SetVideoRequest()
        ..accessToken = accessToken
        ..callId = callId
        ..videoEnabled = enabled;

      final response = await _client.setVideo(
        request,
        options: _createOptions(accessToken),
      );

      if (response.hasSuccess()) {
        return response.success.videoEnabled;
      } else if (response.hasError()) {
        throw GrpcCallException(response.error.message);
      }
      return enabled;
    } on GrpcError catch (e) {
      _logger.e('gRPC error setting video: ${e.message}');
      throw GrpcCallException(e.message ?? 'Unknown gRPC error');
    }
  }

  /// Stream call events
  Stream<CallEventData> streamCallEvents({
    required String accessToken,
    required String callId,
  }) async* {
    _logger.i('Starting call events stream for $callId');

    try {
      final request = proto.StreamCallEventsRequest()
        ..accessToken = accessToken
        ..callId = callId;

      await for (final event in _client.streamCallEvents(
        request,
        options: _createOptions(accessToken),
      )) {
        yield _mapCallEvent(event);
      }
    } on GrpcError catch (e) {
      _logger.e('gRPC error in call events stream: ${e.message}');
      throw GrpcCallException(e.message ?? 'Unknown gRPC error');
    }
  }

  /// Subscribe to incoming call notifications
  Stream<IncomingCallData> subscribeToIncomingCalls({
    required String accessToken,
  }) async* {
    _logger.i('🔔 SUBSCRIBING to incoming call notifications via gRPC stream');

    try {
      final request = proto.SubscribeToIncomingCallsRequest()
        ..accessToken = accessToken;

      _logger.i('🔔 Created SubscribeToIncomingCallsRequest, calling gRPC...');

      await for (final notification in _client.subscribeToIncomingCalls(
        request,
        options: _createOptions(accessToken),
      )) {
        _logger.i(
          '🔔 RECEIVED incoming call notification from gRPC: '
          'call_id=${notification.callId}, '
          'caller_id=${notification.callerId}, '
          'caller_name=${notification.callerDisplayName}',
        );
        yield IncomingCallData(
          callId: notification.callId,
          isVideo: notification.callType == proto.CallType.VIDEO,
          isGroupCall: notification.isGroupCall,
          groupId: notification.hasGroupId() ? notification.groupId : null,
          callerId: notification.callerId,
          callerDisplayName: notification.callerDisplayName,
          callerAvatarUrl: notification.hasCallerAvatarUrl()
              ? notification.callerAvatarUrl
              : null,
          iceServers: notification.iceServers
              .map(
                (s) => IceServerInfo(
                  urls: s.urls,
                  username: s.username.isEmpty ? null : s.username,
                  credential: s.credential.isEmpty ? null : s.credential,
                ),
              )
              .toList(),
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            notification.createdAt.seconds.toInt() * 1000,
          ),
        );
      }
    } on GrpcError catch (e) {
      _logger.e('gRPC error subscribing to incoming calls: ${e.message}');
      throw GrpcCallException(e.message ?? 'Unknown gRPC error');
    }
  }

  /// Get call history
  Future<List<CallHistoryEntryData>> getCallHistory({
    required String accessToken,
    int limit = 50,
    String? cursor,
  }) async {
    _logger.i('Getting call history');

    try {
      final request = proto.GetCallHistoryRequest()
        ..accessToken = accessToken
        ..limit = limit
        ..cursor = cursor ?? '';

      final response = await _client.getCallHistory(
        request,
        options: _createOptions(accessToken),
      );

      if (response.hasSuccess()) {
        return response.success.calls
            .map(
              (c) => CallHistoryEntryData(
                callId: c.callId,
                callType: c.callType == proto.CallType.VIDEO
                    ? CallTypeData.video
                    : CallTypeData.voice,
                isGroupCall: c.isGroupCall,
                groupId: c.groupId.isEmpty ? null : c.groupId,
                otherUserId: c.otherUserId,
                otherUserName: c.otherUserName,
                isOutgoing: c.isOutgoing,
                endReason: _mapEndReason(c.endReason),
                startedAt: DateTime.fromMillisecondsSinceEpoch(
                  c.startedAt.seconds.toInt() * 1000,
                ),
                durationSeconds: c.durationSeconds,
              ),
            )
            .toList();
      } else if (response.hasError()) {
        throw GrpcCallException(response.error.message);
      }
      return [];
    } on GrpcError catch (e) {
      _logger.e('gRPC error getting call history: ${e.message}');
      throw GrpcCallException(e.message ?? 'Unknown gRPC error');
    }
  }

  // Helper methods for mapping proto types

  CallStateType _mapCallState(proto.CallState state) {
    switch (state) {
      case proto.CallState.INITIATING:
        return CallStateType.initiating;
      case proto.CallState.RINGING:
        return CallStateType.ringing;
      case proto.CallState.CONNECTING:
        return CallStateType.connecting;
      case proto.CallState.CONNECTED:
        return CallStateType.connected;
      case proto.CallState.ON_HOLD:
        return CallStateType.onHold;
      case proto.CallState.ENDED:
        return CallStateType.ended;
      case proto.CallState.FAILED:
        return CallStateType.failed;
      default:
        return CallStateType.unknown;
    }
  }

  proto.CallEndReason _mapEndReasonToProto(CallEndReasonType reason) {
    switch (reason) {
      case CallEndReasonType.completed:
        return proto.CallEndReason.COMPLETED;
      case CallEndReasonType.declined:
        return proto.CallEndReason.DECLINED;
      case CallEndReasonType.missed:
        return proto.CallEndReason.MISSED;
      case CallEndReasonType.busy:
        return proto.CallEndReason.BUSY;
      case CallEndReasonType.failedConnection:
        return proto.CallEndReason.FAILED_CONNECTION;
      case CallEndReasonType.cancelled:
        return proto.CallEndReason.CANCELLED;
      default:
        return proto.CallEndReason.UNKNOWN_REASON;
    }
  }

  CallEndReasonType _mapEndReason(proto.CallEndReason reason) {
    switch (reason) {
      case proto.CallEndReason.COMPLETED:
        return CallEndReasonType.completed;
      case proto.CallEndReason.DECLINED:
        return CallEndReasonType.declined;
      case proto.CallEndReason.MISSED:
        return CallEndReasonType.missed;
      case proto.CallEndReason.BUSY:
        return CallEndReasonType.busy;
      case proto.CallEndReason.FAILED_CONNECTION:
        return CallEndReasonType.failedConnection;
      case proto.CallEndReason.CANCELLED:
        return CallEndReasonType.cancelled;
      default:
        return CallEndReasonType.unknown;
    }
  }

  proto.SdpType _mapSdpTypeToProto(SdpMessageType type) {
    switch (type) {
      case SdpMessageType.offer:
        return proto.SdpType.OFFER;
      case SdpMessageType.answer:
        return proto.SdpType.ANSWER;
      case SdpMessageType.pranswer:
        return proto.SdpType.PRANSWER;
      case SdpMessageType.rollback:
        return proto.SdpType.ROLLBACK;
    }
  }

  CallEventData _mapCallEvent(proto.CallEvent event) {
    if (event.hasStateChanged()) {
      return CallStateChangedEvent(
        callId: event.callId,
        oldState: _mapCallState(event.stateChanged.oldState),
        newState: _mapCallState(event.stateChanged.newState),
        endReason: _mapEndReason(event.stateChanged.endReason),
      );
    } else if (event.hasIceCandidateReceived()) {
      return IceCandidateReceivedEvent(
        callId: event.callId,
        fromUserId: event.iceCandidateReceived.fromUserId,
        candidate: event.iceCandidateReceived.candidate.candidate,
        sdpMid: event.iceCandidateReceived.candidate.sdpMid,
        sdpMLineIndex: event.iceCandidateReceived.candidate.sdpMlineIndex,
      );
    } else if (event.hasSdpReceived()) {
      return SdpReceivedEvent(
        callId: event.callId,
        fromUserId: event.sdpReceived.fromUserId,
        sdpType: _mapSdpType(event.sdpReceived.sdp.type),
        sdp: event.sdpReceived.sdp.sdp,
      );
    } else if (event.hasParticipantJoined()) {
      return ParticipantJoinedEvent(
        callId: event.callId,
        userId: event.participantJoined.participant.userId,
        displayName: event.participantJoined.participant.displayName,
      );
    } else if (event.hasParticipantLeft()) {
      return ParticipantLeftEvent(
        callId: event.callId,
        userId: event.participantLeft.userId,
        reason: event.participantLeft.reason,
      );
    } else {
      return UnknownCallEvent(callId: event.callId);
    }
  }

  SdpMessageType _mapSdpType(proto.SdpType type) {
    switch (type) {
      case proto.SdpType.OFFER:
        return SdpMessageType.offer;
      case proto.SdpType.ANSWER:
        return SdpMessageType.answer;
      case proto.SdpType.PRANSWER:
        return SdpMessageType.pranswer;
      case proto.SdpType.ROLLBACK:
        return SdpMessageType.rollback;
      default:
        return SdpMessageType.offer;
    }
  }
}

// Data classes

class CallInitiatedResult {
  final String callId;
  final CallStateType state;
  final List<IceServerInfo> iceServers;
  final List<int> sframeKeyMaterial;
  final int sframeKeyId;

  CallInitiatedResult({
    required this.callId,
    required this.state,
    required this.iceServers,
    required this.sframeKeyMaterial,
    required this.sframeKeyId,
  });
}

class IceServerInfo {
  final List<String> urls;
  final String? username;
  final String? credential;

  IceServerInfo({required this.urls, this.username, this.credential});
}

class EndCallResult {
  final bool ended;
  final int durationSeconds;

  EndCallResult({required this.ended, required this.durationSeconds});
}

class CallHistoryEntryData {
  final String callId;
  final CallTypeData callType;
  final bool isGroupCall;
  final String? groupId;
  final String otherUserId;
  final String otherUserName;
  final bool isOutgoing;
  final CallEndReasonType endReason;
  final DateTime startedAt;
  final int durationSeconds;

  CallHistoryEntryData({
    required this.callId,
    required this.callType,
    required this.isGroupCall,
    this.groupId,
    required this.otherUserId,
    required this.otherUserName,
    required this.isOutgoing,
    required this.endReason,
    required this.startedAt,
    required this.durationSeconds,
  });
}

// Enums

enum CallStateType {
  unknown,
  initiating,
  ringing,
  connecting,
  connected,
  onHold,
  ended,
  failed,
}

enum CallTypeData { voice, video }

enum CallEndReasonType {
  unknown,
  completed,
  declined,
  missed,
  busy,
  failedConnection,
  cancelled,
}

enum SdpMessageType { offer, answer, pranswer, rollback }

// Events

abstract class CallEventData {
  final String callId;
  CallEventData({required this.callId});
}

class CallStateChangedEvent extends CallEventData {
  final CallStateType oldState;
  final CallStateType newState;
  final CallEndReasonType endReason;

  CallStateChangedEvent({
    required super.callId,
    required this.oldState,
    required this.newState,
    required this.endReason,
  });
}

class IceCandidateReceivedEvent extends CallEventData {
  final String fromUserId;
  final String candidate;
  final String sdpMid;
  final int sdpMLineIndex;

  IceCandidateReceivedEvent({
    required super.callId,
    required this.fromUserId,
    required this.candidate,
    required this.sdpMid,
    required this.sdpMLineIndex,
  });
}

class SdpReceivedEvent extends CallEventData {
  final String fromUserId;
  final SdpMessageType sdpType;
  final String sdp;

  SdpReceivedEvent({
    required super.callId,
    required this.fromUserId,
    required this.sdpType,
    required this.sdp,
  });
}

class ParticipantJoinedEvent extends CallEventData {
  final String userId;
  final String displayName;

  ParticipantJoinedEvent({
    required super.callId,
    required this.userId,
    required this.displayName,
  });
}

class ParticipantLeftEvent extends CallEventData {
  final String userId;
  final String reason;

  ParticipantLeftEvent({
    required super.callId,
    required this.userId,
    required this.reason,
  });
}

class UnknownCallEvent extends CallEventData {
  UnknownCallEvent({required super.callId});
}

/// Incoming call notification data
class IncomingCallData {
  final String callId;
  final bool isVideo;
  final bool isGroupCall;
  final String? groupId;
  final String callerId;
  final String callerDisplayName;
  final String? callerAvatarUrl;
  final List<IceServerInfo> iceServers;
  final DateTime createdAt;

  IncomingCallData({
    required this.callId,
    required this.isVideo,
    required this.isGroupCall,
    this.groupId,
    required this.callerId,
    required this.callerDisplayName,
    this.callerAvatarUrl,
    required this.iceServers,
    required this.createdAt,
  });
}

// Exception

class GrpcCallException implements Exception {
  final String message;
  GrpcCallException(this.message);

  @override
  String toString() => 'GrpcCallException: $message';
}
