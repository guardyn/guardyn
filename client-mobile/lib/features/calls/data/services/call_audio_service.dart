/// Call Audio Service
///
/// Handles playback of call-related audio sounds (ringtones, dial tones, etc.)
library;

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';

/// Audio types for call sounds
enum CallAudioType {
  /// Dial tone when initiating an outgoing call
  dialTone,

  /// Incoming call ringtone
  incomingRingtone,

  /// Sound when call is connected
  callConnected,

  /// Sound when call ends
  callEnded,

  /// Busy tone when recipient is busy
  busyTone,
}

/// Service for managing call-related audio playback
class CallAudioService {
  final Logger _logger;
  final AudioPlayer _dialTonePlayer;
  final AudioPlayer _ringtonePlayer;
  final AudioPlayer _effectPlayer;

  bool _isInitialized = false;
  CallAudioType? _currentlyPlaying;

  /// Asset paths for audio files
  static const Map<CallAudioType, String> _assetPaths = {
    CallAudioType.dialTone: 'audio/dial_tone.mp3',
    CallAudioType.incomingRingtone: 'audio/ringtone_incoming.mp3',
    CallAudioType.callConnected: 'audio/call_connected.mp3',
    CallAudioType.callEnded: 'audio/call_ended.mp3',
    CallAudioType.busyTone: 'audio/busy_tone.mp3',
  };

  CallAudioService({
    required Logger logger,
    AudioPlayer? dialTonePlayer,
    AudioPlayer? ringtonePlayer,
    AudioPlayer? effectPlayer,
  }) : _logger = logger,
       _dialTonePlayer = dialTonePlayer ?? AudioPlayer(),
       _ringtonePlayer = ringtonePlayer ?? AudioPlayer(),
       _effectPlayer = effectPlayer ?? AudioPlayer();

  /// Initialize audio players
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set up dial tone player for looping
      await _dialTonePlayer.setReleaseMode(ReleaseMode.loop);

      // Set up ringtone player for looping
      await _ringtonePlayer.setReleaseMode(ReleaseMode.loop);

      // Set up effect player for one-shot playback
      await _effectPlayer.setReleaseMode(ReleaseMode.release);

      _isInitialized = true;
      _logger.i('CallAudioService initialized');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize CallAudioService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Play a specific audio type
  Future<void> play(CallAudioType type) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Stop any currently playing sound of the same category
    await _stopCurrentIfSameCategory(type);

    try {
      final assetPath = _assetPaths[type];
      if (assetPath == null) {
        _logger.w('No asset path for audio type: $type');
        return;
      }

      final player = _getPlayerForType(type);
      await player.setSource(AssetSource(assetPath));
      await player.resume();

      _currentlyPlaying = type;
      _logger.d('Playing call audio: $type');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to play audio: $type',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Stop a specific audio type
  Future<void> stop(CallAudioType type) async {
    try {
      final player = _getPlayerForType(type);
      await player.stop();

      if (_currentlyPlaying == type) {
        _currentlyPlaying = null;
      }
      _logger.d('Stopped call audio: $type');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to stop audio: $type',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Stop all audio playback
  Future<void> stopAll() async {
    try {
      await Future.wait([
        _dialTonePlayer.stop(),
        _ringtonePlayer.stop(),
        _effectPlayer.stop(),
      ]);
      _currentlyPlaying = null;
      _logger.d('Stopped all call audio');
    } catch (e, stackTrace) {
      _logger.e('Failed to stop all audio', error: e, stackTrace: stackTrace);
    }
  }

  /// Set volume for all players (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await Future.wait([
        _dialTonePlayer.setVolume(volume),
        _ringtonePlayer.setVolume(volume),
        _effectPlayer.setVolume(volume),
      ]);
    } catch (e) {
      _logger.e('Failed to set volume', error: e);
    }
  }

  /// Play dial tone for outgoing call
  Future<void> playDialTone() => play(CallAudioType.dialTone);

  /// Stop dial tone
  Future<void> stopDialTone() => stop(CallAudioType.dialTone);

  /// Play incoming call ringtone
  Future<void> playIncomingRingtone() => play(CallAudioType.incomingRingtone);

  /// Stop incoming ringtone
  Future<void> stopIncomingRingtone() => stop(CallAudioType.incomingRingtone);

  /// Play call connected sound
  Future<void> playCallConnected() => play(CallAudioType.callConnected);

  /// Play call ended sound
  Future<void> playCallEnded() => play(CallAudioType.callEnded);

  /// Play busy tone
  Future<void> playBusyTone() => play(CallAudioType.busyTone);

  /// Get the appropriate player for an audio type
  AudioPlayer _getPlayerForType(CallAudioType type) {
    switch (type) {
      case CallAudioType.dialTone:
        return _dialTonePlayer;
      case CallAudioType.incomingRingtone:
        return _ringtonePlayer;
      case CallAudioType.callConnected:
      case CallAudioType.callEnded:
      case CallAudioType.busyTone:
        return _effectPlayer;
    }
  }

  /// Stop current playback if same category (looping sounds)
  Future<void> _stopCurrentIfSameCategory(CallAudioType newType) async {
    if (_currentlyPlaying == null) return;

    // Stop dial tone when starting ringtone or vice versa
    if (newType == CallAudioType.dialTone &&
        _currentlyPlaying == CallAudioType.incomingRingtone) {
      await stop(CallAudioType.incomingRingtone);
    } else if (newType == CallAudioType.incomingRingtone &&
        _currentlyPlaying == CallAudioType.dialTone) {
      await stop(CallAudioType.dialTone);
    }
  }

  /// Dispose of all audio players
  Future<void> dispose() async {
    try {
      await Future.wait([
        _dialTonePlayer.dispose(),
        _ringtonePlayer.dispose(),
        _effectPlayer.dispose(),
      ]);
      _isInitialized = false;
      _logger.i('CallAudioService disposed');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to dispose CallAudioService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
