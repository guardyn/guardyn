/// WebRTC DataSource
///
/// Manages WebRTC peer connections for voice and video calls.
/// Handles media streams, ICE candidates, and peer connection lifecycle.
library;

import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
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
class WebRTCDataSourceImpl implements WebRTCDataSource {
  final Logger _logger;
  WebRTCConfig _config;

  final _eventsController = StreamController<WebRTCEvent>.broadcast();

  PeerConnectionState _connectionState = PeerConnectionState.idle;
  MediaStreamInfo? _localStream;
  final List<MediaStreamInfo> _remoteStreams = [];

  // Real flutter_webrtc objects
  RTCPeerConnection? _peerConnection;
  MediaStream? _localMediaStream;
  bool _isAudioEnabled = true;
  bool _isVideoEnabled = true;
  bool _isFrontCamera = true;
  bool _isSpeakerEnabled = false;
  bool _isInitialized = false;

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
    _config = config;

    try {
      // Initialize RTCPeerConnection with flutter_webrtc
      _peerConnection = await createPeerConnection(
        config.toRTCConfiguration(),
        _getOfferSdpConstraints(),
      );

      _setupPeerConnectionCallbacks();
      _isInitialized = true;
      _updateConnectionState(PeerConnectionState.idle);
      _logger.i('WebRTC initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize WebRTC', error: e, stackTrace: stackTrace);
      _eventsController.add(WebRTCError('Failed to initialize WebRTC', e));
      rethrow;
    }
  }

  /// Set up all RTCPeerConnection event callbacks
  void _setupPeerConnectionCallbacks() {
    if (_peerConnection == null) return;

    // ICE candidate generation
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      _logger.d('ICE candidate generated: ${candidate.candidate?.substring(0, 50)}...');
      _eventsController.add(WebRTCIceCandidateGenerated(IceCandidate(
        candidate: candidate.candidate ?? '',
        sdpMid: candidate.sdpMid,
        sdpMLineIndex: candidate.sdpMLineIndex,
      )));
    };

    // ICE connection state changes
    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      _logger.i('ICE connection state: $state');
      final newState = switch (state) {
        RTCIceConnectionState.RTCIceConnectionStateNew => PeerConnectionState.idle,
        RTCIceConnectionState.RTCIceConnectionStateChecking => PeerConnectionState.connecting,
        RTCIceConnectionState.RTCIceConnectionStateConnected => PeerConnectionState.connected,
        RTCIceConnectionState.RTCIceConnectionStateCompleted => PeerConnectionState.connected,
        RTCIceConnectionState.RTCIceConnectionStateDisconnected => PeerConnectionState.disconnected,
        RTCIceConnectionState.RTCIceConnectionStateFailed => PeerConnectionState.failed,
        RTCIceConnectionState.RTCIceConnectionStateClosed => PeerConnectionState.closed,
        RTCIceConnectionState.RTCIceConnectionStateCount => PeerConnectionState.idle,
      };
      _updateConnectionState(newState);
    };

    // Peer connection state changes
    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      _logger.i('Peer connection state: $state');
      final newState = switch (state) {
        RTCPeerConnectionState.RTCPeerConnectionStateNew => PeerConnectionState.idle,
        RTCPeerConnectionState.RTCPeerConnectionStateConnecting => PeerConnectionState.connecting,
        RTCPeerConnectionState.RTCPeerConnectionStateConnected => PeerConnectionState.connected,
        RTCPeerConnectionState.RTCPeerConnectionStateDisconnected => PeerConnectionState.disconnected,
        RTCPeerConnectionState.RTCPeerConnectionStateFailed => PeerConnectionState.failed,
        RTCPeerConnectionState.RTCPeerConnectionStateClosed => PeerConnectionState.closed,
      };
      _updateConnectionState(newState);
    };

    // Track added event (remote streams)
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      _logger.i('Remote track added: ${event.track.kind}');
      if (event.streams.isNotEmpty) {
        final remoteStream = event.streams.first;
        final streamInfo = MediaStreamInfo(
          id: remoteStream.id,
          stream: remoteStream,
          isLocal: false,
          hasAudio: remoteStream.getAudioTracks().isNotEmpty,
          hasVideo: remoteStream.getVideoTracks().isNotEmpty,
        );

        // Check if stream already exists
        final existingIndex = _remoteStreams.indexWhere((s) => s.id == remoteStream.id);
        if (existingIndex >= 0) {
          _remoteStreams[existingIndex] = streamInfo;
        } else {
          _remoteStreams.add(streamInfo);
          _eventsController.add(WebRTCRemoteStreamAdded(streamInfo));
        }
      }
    };

    // Remote stream removed
    _peerConnection!.onRemoveStream = (MediaStream stream) {
      _logger.i('Remote stream removed: ${stream.id}');
      _remoteStreams.removeWhere((s) => s.id == stream.id);
      _eventsController.add(WebRTCRemoteStreamRemoved(stream.id));
    };

    // ICE gathering state
    _peerConnection!.onIceGatheringState = (RTCIceGatheringState state) {
      _logger.d('ICE gathering state: $state');
    };

    // Signaling state
    _peerConnection!.onSignalingState = (RTCSignalingState state) {
      _logger.d('Signaling state: $state');
    };

    // Renegotiation needed
    _peerConnection!.onRenegotiationNeeded = () {
      _logger.d('Renegotiation needed');
    };
  }

  Map<String, dynamic> _getOfferSdpConstraints() => {
        'mandatory': {
          'OfferToReceiveAudio': true,
          'OfferToReceiveVideo': true,
        },
        'optional': [],
      };

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

      // Build media constraints for getUserMedia
      final mediaConstraints = <String, dynamic>{
        'audio': enableAudio
            ? {
                'echoCancellation': true,
                'noiseSuppression': true,
                'autoGainControl': true,
              }
            : false,
        'video': enableVideo
            ? {
                'facingMode': facingMode,
                'width': {'ideal': 1280, 'max': 1920},
                'height': {'ideal': 720, 'max': 1080},
                'frameRate': {'ideal': 30, 'max': 60},
              }
            : false,
      };

      // Get user media using flutter_webrtc
      _localMediaStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

      _localStream = MediaStreamInfo(
        id: _localMediaStream!.id,
        stream: _localMediaStream,
        isLocal: true,
        hasAudio: _localMediaStream!.getAudioTracks().isNotEmpty,
        hasVideo: _localMediaStream!.getVideoTracks().isNotEmpty,
      );

      // Add tracks to peer connection if initialized
      if (_peerConnection != null && _localMediaStream != null) {
        for (final track in _localMediaStream!.getTracks()) {
          await _peerConnection!.addTrack(track, _localMediaStream!);
          _logger.d('Added ${track.kind} track to peer connection');
        }
      }

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

    if (_localMediaStream != null) {
      // Stop all tracks
      for (final track in _localMediaStream!.getTracks()) {
        await track.stop();
        _logger.d('Stopped ${track.kind} track');
      }
      await _localMediaStream!.dispose();
      _localMediaStream = null;
      _localStream = null;
    }
  }

  @override
  Future<SessionDescription> createOffer() async {
    _logger.i('Creating SDP offer');

    _ensureInitialized();

    try {
      final offer = await _peerConnection!.createOffer(_getOfferSdpConstraints());

      // Apply bitrate constraints
      final modifiedSdp = _applyBitrateConstraints(offer.sdp ?? '');

      return SessionDescription(
        type: offer.type ?? 'offer',
        sdp: modifiedSdp,
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to create offer', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<SessionDescription> createAnswer() async {
    _logger.i('Creating SDP answer');

    _ensureInitialized();

    try {
      final answer = await _peerConnection!.createAnswer();

      // Apply bitrate constraints
      final modifiedSdp = _applyBitrateConstraints(answer.sdp ?? '');

      return SessionDescription(
        type: answer.type ?? 'answer',
        sdp: modifiedSdp,
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to create answer', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> setLocalDescription(SessionDescription description) async {
    _logger.i('Setting local description: ${description.type}');

    _ensureInitialized();

    await _peerConnection!.setLocalDescription(RTCSessionDescription(
      description.sdp,
      description.type,
    ));
  }

  @override
  Future<void> setRemoteDescription(SessionDescription description) async {
    _logger.i('Setting remote description: ${description.type}');

    _ensureInitialized();

    await _peerConnection!.setRemoteDescription(RTCSessionDescription(
      description.sdp,
      description.type,
    ));

    _updateConnectionState(PeerConnectionState.connecting);
  }

  @override
  Future<void> addIceCandidate(IceCandidate candidate) async {
    _logger.d('Adding ICE candidate: ${candidate.candidate.substring(0, 50.clamp(0, candidate.candidate.length))}...');

    _ensureInitialized();

    await _peerConnection!.addCandidate(RTCIceCandidate(
      candidate.candidate,
      candidate.sdpMid,
      candidate.sdpMLineIndex,
    ));
  }

  @override
  Future<void> setAudioEnabled(bool enabled) async {
    _logger.i('Setting audio enabled: $enabled');
    _isAudioEnabled = enabled;

    if (_localMediaStream != null) {
      final audioTracks = _localMediaStream!.getAudioTracks();
      for (final track in audioTracks) {
        track.enabled = enabled;
        _logger.d('Audio track ${track.id} enabled: $enabled');
      }
    }
  }

  @override
  Future<void> setVideoEnabled(bool enabled) async {
    _logger.i('Setting video enabled: $enabled');
    _isVideoEnabled = enabled;

    if (_localMediaStream != null) {
      final videoTracks = _localMediaStream!.getVideoTracks();
      for (final track in videoTracks) {
        track.enabled = enabled;
        _logger.d('Video track ${track.id} enabled: $enabled');
      }
    }
  }

  @override
  Future<void> switchCamera() async {
    _logger.i('Switching camera');
    _isFrontCamera = !_isFrontCamera;

    if (_localMediaStream != null) {
      final videoTracks = _localMediaStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        await Helper.switchCamera(videoTracks.first);
        _logger.i('Camera switched to ${_isFrontCamera ? "front" : "back"}');
      }
    }
  }

  @override
  Future<void> setSpeakerEnabled(bool enabled) async {
    _logger.i('Setting speaker enabled: $enabled');
    _isSpeakerEnabled = enabled;

    await Helper.setSpeakerphoneOn(enabled);
  }

  @override
  Future<double> getAudioLevel() async {
    // Get audio level from WebRTC stats
    if (_peerConnection == null) return 0.0;

    try {
      final stats = await _peerConnection!.getStats();
      for (final report in stats) {
        if (report.type == 'inbound-rtp' || report.type == 'outbound-rtp') {
          final audioLevel = report.values['audioLevel'];
          if (audioLevel != null) {
            return (audioLevel as num).toDouble();
          }
        }
      }
    } catch (e) {
      _logger.w('Failed to get audio level', error: e);
    }

    return 0.0;
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    _logger.d('Getting connection stats');

    if (_peerConnection == null) {
      return {
        'connectionState': _connectionState.name,
        'hasLocalStream': _localStream != null,
        'remoteStreamCount': _remoteStreams.length,
        'audioEnabled': _isAudioEnabled,
        'videoEnabled': _isVideoEnabled,
        'speakerEnabled': _isSpeakerEnabled,
        'frontCamera': _isFrontCamera,
        'initialized': _isInitialized,
      };
    }

    try {
      final stats = await _peerConnection!.getStats();
      final statsMap = <String, dynamic>{
        'connectionState': _connectionState.name,
        'hasLocalStream': _localStream != null,
        'remoteStreamCount': _remoteStreams.length,
        'audioEnabled': _isAudioEnabled,
        'videoEnabled': _isVideoEnabled,
        'speakerEnabled': _isSpeakerEnabled,
        'frontCamera': _isFrontCamera,
        'initialized': _isInitialized,
        'reports': <Map<String, dynamic>>[],
      };

      for (final report in stats) {
        if (report.type == 'candidate-pair' && report.values['selected'] == true) {
          statsMap['selectedCandidatePair'] = {
            'localCandidateId': report.values['localCandidateId'],
            'remoteCandidateId': report.values['remoteCandidateId'],
            'currentRoundTripTime': report.values['currentRoundTripTime'],
            'availableOutgoingBitrate': report.values['availableOutgoingBitrate'],
          };
        } else if (report.type == 'inbound-rtp') {
          (statsMap['reports'] as List).add({
            'type': 'inbound',
            'kind': report.values['kind'],
            'packetsReceived': report.values['packetsReceived'],
            'bytesReceived': report.values['bytesReceived'],
            'packetsLost': report.values['packetsLost'],
            'jitter': report.values['jitter'],
          });
        } else if (report.type == 'outbound-rtp') {
          (statsMap['reports'] as List).add({
            'type': 'outbound',
            'kind': report.values['kind'],
            'packetsSent': report.values['packetsSent'],
            'bytesSent': report.values['bytesSent'],
          });
        }
      }

      return statsMap;
    } catch (e) {
      _logger.w('Failed to get detailed stats', error: e);
      return {
        'connectionState': _connectionState.name,
        'hasLocalStream': _localStream != null,
        'remoteStreamCount': _remoteStreams.length,
        'audioEnabled': _isAudioEnabled,
        'videoEnabled': _isVideoEnabled,
        'initialized': _isInitialized,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<void> close() async {
    _logger.i('Closing WebRTC connection');

    await stopLocalMedia();

    if (_peerConnection != null) {
      await _peerConnection!.close();
      _peerConnection = null;
    }

    _remoteStreams.clear();
    _isInitialized = false;
    _updateConnectionState(PeerConnectionState.closed);
  }

  @override
  Future<void> dispose() async {
    _logger.i('Disposing WebRTC datasource');
    await close();
    await _eventsController.close();
  }

  // Private helpers

  void _ensureInitialized() {
    if (!_isInitialized || _peerConnection == null) {
      throw StateError('WebRTC not initialized. Call initialize() first.');
    }
  }

  void _updateConnectionState(PeerConnectionState state) {
    if (_connectionState != state) {
      _connectionState = state;
      _eventsController.add(WebRTCConnectionStateChanged(state));
      _logger.i('Connection state changed: $state');
    }
  }

  /// Apply bitrate constraints to SDP for bandwidth management
  String _applyBitrateConstraints(String sdp) {
    var modifiedSdp = sdp;

    // Apply video bitrate constraint
    if (_config.maxVideoBitrate > 0) {
      modifiedSdp = _setBitrate(modifiedSdp, 'video', _config.maxVideoBitrate);
    }

    // Apply audio bitrate constraint
    if (_config.maxAudioBitrate > 0) {
      modifiedSdp = _setBitrate(modifiedSdp, 'audio', _config.maxAudioBitrate);
    }

    return modifiedSdp;
  }

  /// Set bitrate in SDP for a specific media type
  String _setBitrate(String sdp, String mediaType, int bitrate) {
    final lines = sdp.split('\n');
    final result = <String>[];
    var foundMedia = false;

    for (var i = 0; i < lines.length; i++) {
      result.add(lines[i]);

      if (lines[i].startsWith('m=$mediaType')) {
        foundMedia = true;
      } else if (foundMedia && lines[i].startsWith('m=')) {
        foundMedia = false;
      }

      // Add bitrate constraint after connection line
      if (foundMedia && lines[i].startsWith('c=')) {
        result.add('b=AS:$bitrate');
        result.add('b=TIAS:${bitrate * 1000}');
      }
    }

    return result.join('\n');
  }
}
