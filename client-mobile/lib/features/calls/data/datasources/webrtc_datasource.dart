/// WebRTC DataSource
///
/// Manages WebRTC peer connections for voice and video calls.
/// Handles media streams, ICE candidates, and peer connection lifecycle.
library;

import 'dart:async';

import 'package:logger/logger.dart';

/// Configuration for WebRTC peer connections
class WebRTCConfig {
  /// ICE servers (STUN/TURN)
  final List<Map<String, dynamic>> iceServers;

  /// Enable SRTP for secure media
  final bool enableSrtp;

  /// Enable DTLS for secure signaling
  final bool enableDtls;

  /// Max bitrate for video (kbps)
  final int maxVideoBitrate;

  /// Max bitrate for audio (kbps)
  final int maxAudioBitrate;

  const WebRTCConfig({
    this.iceServers = const [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
    this.enableSrtp = true,
    this.enableDtls = true,
    this.maxVideoBitrate = 2500,
    this.maxAudioBitrate = 128,
  });

  /// Convert to RTCConfiguration map
  Map<String, dynamic> toRTCConfiguration() => {
        'iceServers': iceServers,
        'sdpSemantics': 'unified-plan',
      };
}

/// Media stream wrapper with metadata
class MediaStreamInfo {
  final String id;
  final dynamic stream; // RTCMediaStream when flutter_webrtc is integrated
  final bool isLocal;
  final bool hasAudio;
  final bool hasVideo;

  const MediaStreamInfo({
    required this.id,
    required this.stream,
    required this.isLocal,
    required this.hasAudio,
    required this.hasVideo,
  });
}

/// ICE candidate wrapper
class IceCandidate {
  final String candidate;
  final String? sdpMid;
  final int? sdpMLineIndex;

  const IceCandidate({
    required this.candidate,
    this.sdpMid,
    this.sdpMLineIndex,
  });

  Map<String, dynamic> toMap() => {
        'candidate': candidate,
        'sdpMid': sdpMid,
        'sdpMLineIndex': sdpMLineIndex,
      };

  factory IceCandidate.fromMap(Map<String, dynamic> map) => IceCandidate(
        candidate: map['candidate'] as String,
        sdpMid: map['sdpMid'] as String?,
        sdpMLineIndex: map['sdpMLineIndex'] as int?,
      );
}

/// Session Description Protocol (SDP) wrapper
class SessionDescription {
  final String type; // 'offer' or 'answer'
  final String sdp;

  const SessionDescription({
    required this.type,
    required this.sdp,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'sdp': sdp,
      };

  factory SessionDescription.fromMap(Map<String, dynamic> map) =>
      SessionDescription(
        type: map['type'] as String,
        sdp: map['sdp'] as String,
      );
}

/// Connection state for WebRTC peer connection
enum PeerConnectionState {
  idle,
  connecting,
  connected,
  disconnected,
  failed,
  closed,
}

/// Events emitted by WebRTC datasource
abstract class WebRTCEvent {}

class WebRTCLocalStreamReady extends WebRTCEvent {
  final MediaStreamInfo stream;
  WebRTCLocalStreamReady(this.stream);
}

class WebRTCRemoteStreamAdded extends WebRTCEvent {
  final MediaStreamInfo stream;
  WebRTCRemoteStreamAdded(this.stream);
}

class WebRTCRemoteStreamRemoved extends WebRTCEvent {
  final String streamId;
  WebRTCRemoteStreamRemoved(this.streamId);
}

class WebRTCIceCandidateGenerated extends WebRTCEvent {
  final IceCandidate candidate;
  WebRTCIceCandidateGenerated(this.candidate);
}

class WebRTCConnectionStateChanged extends WebRTCEvent {
  final PeerConnectionState state;
  WebRTCConnectionStateChanged(this.state);
}

class WebRTCError extends WebRTCEvent {
  final String message;
  final Object? error;
  WebRTCError(this.message, [this.error]);
}

/// WebRTC DataSource Interface
///
/// Abstraction for WebRTC operations. Implementation will use flutter_webrtc.
abstract class WebRTCDataSource {
  /// Stream of WebRTC events
  Stream<WebRTCEvent> get events;

  /// Current connection state
  PeerConnectionState get connectionState;

  /// Local media stream (if any)
  MediaStreamInfo? get localStream;

  /// Remote media streams
  List<MediaStreamInfo> get remoteStreams;

  /// Initialize WebRTC with configuration
  Future<void> initialize(WebRTCConfig config);

  /// Start local media capture
  ///
  /// [enableVideo] - Whether to capture video
  /// [enableAudio] - Whether to capture audio
  /// [facingMode] - Camera facing mode ('user' or 'environment')
  Future<MediaStreamInfo> startLocalMedia({
    required bool enableVideo,
    required bool enableAudio,
    String facingMode = 'user',
  });

  /// Stop local media capture
  Future<void> stopLocalMedia();

  /// Create an SDP offer
  Future<SessionDescription> createOffer();

  /// Create an SDP answer
  Future<SessionDescription> createAnswer();

  /// Set local description (our SDP)
  Future<void> setLocalDescription(SessionDescription description);

  /// Set remote description (their SDP)
  Future<void> setRemoteDescription(SessionDescription description);

  /// Add ICE candidate from remote peer
  Future<void> addIceCandidate(IceCandidate candidate);

  /// Toggle local audio mute
  Future<void> setAudioEnabled(bool enabled);

  /// Toggle local video
  Future<void> setVideoEnabled(bool enabled);

  /// Switch between front and back camera
  Future<void> switchCamera();

  /// Enable/disable speaker output
  Future<void> setSpeakerEnabled(bool enabled);

  /// Get current audio level (0.0 - 1.0)
  Future<double> getAudioLevel();

  /// Get connection stats (for quality monitoring)
  Future<Map<String, dynamic>> getStats();

  /// Close peer connection and release resources
  Future<void> close();

  /// Dispose all resources
  Future<void> dispose();
}

/// WebRTC DataSource Implementation
///
/// Uses flutter_webrtc package for actual WebRTC functionality.
/// Falls back to mock implementation when not available.
class WebRTCDataSourceImpl implements WebRTCDataSource {
  final Logger _logger;
  final WebRTCConfig _config;

  final _eventsController = StreamController<WebRTCEvent>.broadcast();

  PeerConnectionState _connectionState = PeerConnectionState.idle;
  MediaStreamInfo? _localStream;
  final List<MediaStreamInfo> _remoteStreams = [];

  // Placeholders for flutter_webrtc objects
  // These will be actual RTCPeerConnection and RTCMediaStream when integrated
  dynamic _peerConnection;
  bool _isAudioEnabled = true;
  bool _isVideoEnabled = true;
  bool _isFrontCamera = true;
  bool _isSpeakerEnabled = false;

  WebRTCDataSourceImpl({
    required Logger logger,
    WebRTCConfig config = const WebRTCConfig(),
  })  : _logger = logger,
        _config = config;

  @override
  Stream<WebRTCEvent> get events => _eventsController.stream;

  @override
  PeerConnectionState get connectionState => _connectionState;

  @override
  MediaStreamInfo? get localStream => _localStream;

  @override
  List<MediaStreamInfo> get remoteStreams => List.unmodifiable(_remoteStreams);

  @override
  Future<void> initialize(WebRTCConfig config) async {
    _logger.i('Initializing WebRTC with config: ${config.toRTCConfiguration()}');

    try {
      // TODO: Initialize RTCPeerConnection when flutter_webrtc is added
      // _peerConnection = await createPeerConnection(config.toRTCConfiguration());
      // _setupPeerConnectionCallbacks();

      _updateConnectionState(PeerConnectionState.idle);
      _logger.i('WebRTC initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize WebRTC', error: e, stackTrace: stackTrace);
      _eventsController.add(WebRTCError('Failed to initialize WebRTC', e));
      rethrow;
    }
  }

  @override
  Future<MediaStreamInfo> startLocalMedia({
    required bool enableVideo,
    required bool enableAudio,
    String facingMode = 'user',
  }) async {
    _logger.i(
        'Starting local media: video=$enableVideo, audio=$enableAudio, facing=$facingMode');

    try {
      _isAudioEnabled = enableAudio;
      _isVideoEnabled = enableVideo;
      _isFrontCamera = facingMode == 'user';

      // TODO: Get user media when flutter_webrtc is added
      // final mediaConstraints = {
      //   'audio': enableAudio,
      //   'video': enableVideo ? {
      //     'facingMode': facingMode,
      //     'width': {'ideal': 1280},
      //     'height': {'ideal': 720},
      //   } : false,
      // };
      // final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

      // Mock stream for now
      _localStream = MediaStreamInfo(
        id: 'local-stream-${DateTime.now().millisecondsSinceEpoch}',
        stream: null, // Will be RTCMediaStream
        isLocal: true,
        hasAudio: enableAudio,
        hasVideo: enableVideo,
      );

      _eventsController.add(WebRTCLocalStreamReady(_localStream!));
      _logger.i('Local media started: ${_localStream!.id}');

      return _localStream!;
    } catch (e, stackTrace) {
      _logger.e('Failed to start local media', error: e, stackTrace: stackTrace);
      _eventsController.add(WebRTCError('Failed to start local media', e));
      rethrow;
    }
  }

  @override
  Future<void> stopLocalMedia() async {
    _logger.i('Stopping local media');

    if (_localStream != null) {
      // TODO: Stop tracks when flutter_webrtc is added
      // final stream = _localStream!.stream as RTCMediaStream;
      // stream.getTracks().forEach((track) => track.stop());
      // await stream.dispose();

      _localStream = null;
    }
  }

  @override
  Future<SessionDescription> createOffer() async {
    _logger.i('Creating SDP offer');

    try {
      // TODO: Create offer when flutter_webrtc is added
      // final offer = await _peerConnection.createOffer({
      //   'offerToReceiveAudio': true,
      //   'offerToReceiveVideo': true,
      // });

      // Mock offer
      return SessionDescription(
        type: 'offer',
        sdp: _generateMockSdp('offer'),
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to create offer', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<SessionDescription> createAnswer() async {
    _logger.i('Creating SDP answer');

    try {
      // TODO: Create answer when flutter_webrtc is added
      // final answer = await _peerConnection.createAnswer();

      return SessionDescription(
        type: 'answer',
        sdp: _generateMockSdp('answer'),
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to create answer', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> setLocalDescription(SessionDescription description) async {
    _logger.i('Setting local description: ${description.type}');

    // TODO: Set local description when flutter_webrtc is added
    // await _peerConnection.setLocalDescription(RTCSessionDescription(
    //   description.sdp,
    //   description.type,
    // ));
  }

  @override
  Future<void> setRemoteDescription(SessionDescription description) async {
    _logger.i('Setting remote description: ${description.type}');

    // TODO: Set remote description when flutter_webrtc is added
    // await _peerConnection.setRemoteDescription(RTCSessionDescription(
    //   description.sdp,
    //   description.type,
    // ));

    _updateConnectionState(PeerConnectionState.connecting);
  }

  @override
  Future<void> addIceCandidate(IceCandidate candidate) async {
    _logger.d('Adding ICE candidate: ${candidate.candidate.substring(0, 50)}...');

    // TODO: Add ICE candidate when flutter_webrtc is added
    // await _peerConnection.addCandidate(RTCIceCandidate(
    //   candidate.candidate,
    //   candidate.sdpMid,
    //   candidate.sdpMLineIndex,
    // ));
  }

  @override
  Future<void> setAudioEnabled(bool enabled) async {
    _logger.i('Setting audio enabled: $enabled');
    _isAudioEnabled = enabled;

    // TODO: Toggle audio track when flutter_webrtc is added
    // final audioTracks = _localStream?.stream?.getAudioTracks();
    // audioTracks?.forEach((track) => track.enabled = enabled);
  }

  @override
  Future<void> setVideoEnabled(bool enabled) async {
    _logger.i('Setting video enabled: $enabled');
    _isVideoEnabled = enabled;

    // TODO: Toggle video track when flutter_webrtc is added
    // final videoTracks = _localStream?.stream?.getVideoTracks();
    // videoTracks?.forEach((track) => track.enabled = enabled);
  }

  @override
  Future<void> switchCamera() async {
    _logger.i('Switching camera');
    _isFrontCamera = !_isFrontCamera;

    // TODO: Switch camera when flutter_webrtc is added
    // final videoTracks = _localStream?.stream?.getVideoTracks();
    // if (videoTracks != null && videoTracks.isNotEmpty) {
    //   await Helper.switchCamera(videoTracks.first);
    // }
  }

  @override
  Future<void> setSpeakerEnabled(bool enabled) async {
    _logger.i('Setting speaker enabled: $enabled');
    _isSpeakerEnabled = enabled;

    // TODO: Toggle speaker when flutter_webrtc is added
    // await Helper.setSpeakerphoneOn(enabled);
  }

  @override
  Future<double> getAudioLevel() async {
    // TODO: Get audio level from WebRTC stats
    return 0.0;
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    _logger.d('Getting connection stats');

    // TODO: Get stats when flutter_webrtc is added
    // final stats = await _peerConnection?.getStats();
    // return _parseStats(stats);

    return {
      'connectionState': _connectionState.name,
      'hasLocalStream': _localStream != null,
      'remoteStreamCount': _remoteStreams.length,
      'audioEnabled': _isAudioEnabled,
      'videoEnabled': _isVideoEnabled,
    };
  }

  @override
  Future<void> close() async {
    _logger.i('Closing WebRTC connection');

    await stopLocalMedia();

    // TODO: Close peer connection when flutter_webrtc is added
    // await _peerConnection?.close();
    _peerConnection = null;

    _remoteStreams.clear();
    _updateConnectionState(PeerConnectionState.closed);
  }

  @override
  Future<void> dispose() async {
    _logger.i('Disposing WebRTC datasource');
    await close();
    await _eventsController.close();
  }

  // Private helpers

  void _updateConnectionState(PeerConnectionState state) {
    if (_connectionState != state) {
      _connectionState = state;
      _eventsController.add(WebRTCConnectionStateChanged(state));
      _logger.i('Connection state changed: $state');
    }
  }

  String _generateMockSdp(String type) {
    // Generate a mock SDP for testing purposes
    return '''v=0
o=- ${DateTime.now().millisecondsSinceEpoch} 2 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE audio video
a=msid-semantic: WMS
m=audio 9 UDP/TLS/RTP/SAVPF 111
c=IN IP4 0.0.0.0
a=rtcp:9 IN IP4 0.0.0.0
a=ice-ufrag:mock
a=ice-pwd:mockpassword123456789012
a=$type
a=mid:audio
a=sendrecv
m=video 9 UDP/TLS/RTP/SAVPF 96
c=IN IP4 0.0.0.0
a=rtcp:9 IN IP4 0.0.0.0
a=ice-ufrag:mock
a=ice-pwd:mockpassword123456789012
a=$type
a=mid:video
a=sendrecv
''';
  }

  // Callback methods for RTCPeerConnection events
  // These will be wired up when flutter_webrtc is integrated

  void _onIceCandidate(dynamic candidate) {
    // Called when a new ICE candidate is generated
    if (candidate != null) {
      _eventsController.add(WebRTCIceCandidateGenerated(IceCandidate(
        candidate: candidate.candidate,
        sdpMid: candidate.sdpMid,
        sdpMLineIndex: candidate.sdpMLineIndex,
      )));
    }
  }

  void _onTrack(dynamic event) {
    // Called when a remote track is added
    _logger.i('Remote track added');
    final stream = MediaStreamInfo(
      id: 'remote-${DateTime.now().millisecondsSinceEpoch}',
      stream: event.streams.first,
      isLocal: false,
      hasAudio: true,
      hasVideo: true,
    );
    _remoteStreams.add(stream);
    _eventsController.add(WebRTCRemoteStreamAdded(stream));
  }

  void _onConnectionState(dynamic state) {
    // Called when connection state changes
    final newState = switch (state.toString()) {
      'new' => PeerConnectionState.idle,
      'connecting' => PeerConnectionState.connecting,
      'connected' => PeerConnectionState.connected,
      'disconnected' => PeerConnectionState.disconnected,
      'failed' => PeerConnectionState.failed,
      'closed' => PeerConnectionState.closed,
      _ => PeerConnectionState.idle,
    };
    _updateConnectionState(newState);
  }
}
