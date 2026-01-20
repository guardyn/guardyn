/// Ringtone Datasource
///
/// Manages audio playback for incoming calls, dial tones, and call events.
library;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Audio source for ringtones
enum RingtoneType {
  /// Incoming call ringtone
  incoming,

  /// Outgoing call dial tone
  outgoing,

  /// Call connected beep
  connected,

  /// Call ended beep
  ended,

  /// Busy signal
  busy,
}

/// Service for playing call-related audio
class RingtoneDatasource {
  RingtoneDatasource._();

  static RingtoneDatasource? _instance;

  /// Singleton instance
  static RingtoneDatasource get instance {
    _instance ??= RingtoneDatasource._();
    return _instance!;
  }

  AudioPlayer? _ringtonePlayer;
  AudioPlayer? _tonePlayer;
  bool _isPlaying = false;

  /// Whether ringtone is currently playing
  bool get isPlaying => _isPlaying;

  /// Initialize the audio players
  Future<void> initialize() async {
    try {
      _ringtonePlayer = AudioPlayer();
      _tonePlayer = AudioPlayer();

      // Configure ringtone player for looping
      await _ringtonePlayer?.setReleaseMode(ReleaseMode.loop);

      // Configure tone player for single play
      await _tonePlayer?.setReleaseMode(ReleaseMode.release);
    } catch (e) {
      debugPrint('RingtoneDatasource: Error initializing audio players: $e');
    }
  }

  /// Play ringtone for incoming call
  Future<void> playIncomingRingtone() async {
    if (_isPlaying) return;

    try {
      _isPlaying = true;

      // Use system default ringtone asset or bundled ringtone
      // For now, use a bundled ringtone asset
      await _ringtonePlayer?.setSource(
        AssetSource('audio/ringtone_incoming.mp3'),
      );
      await _ringtonePlayer?.setVolume(1.0);
      await _ringtonePlayer?.resume();

      debugPrint('RingtoneDatasource: Playing incoming ringtone');
    } catch (e) {
      debugPrint('RingtoneDatasource: Error playing incoming ringtone: $e');
      _isPlaying = false;
    }
  }

  /// Play dial tone for outgoing call
  Future<void> playOutgoingTone() async {
    if (_isPlaying) return;

    try {
      _isPlaying = true;

      await _ringtonePlayer?.setSource(
        AssetSource('audio/dial_tone.mp3'),
      );
      await _ringtonePlayer?.setVolume(0.5);
      await _ringtonePlayer?.resume();

      debugPrint('RingtoneDatasource: Playing outgoing dial tone');
    } catch (e) {
      debugPrint('RingtoneDatasource: Error playing dial tone: $e');
      _isPlaying = false;
    }
  }

  /// Play connected beep
  Future<void> playConnectedTone() async {
    try {
      await _tonePlayer?.setSource(
        AssetSource('audio/call_connected.mp3'),
      );
      await _tonePlayer?.setVolume(0.5);
      await _tonePlayer?.resume();

      debugPrint('RingtoneDatasource: Playing connected tone');
    } catch (e) {
      debugPrint('RingtoneDatasource: Error playing connected tone: $e');
    }
  }

  /// Play call ended beep
  Future<void> playEndedTone() async {
    try {
      await _tonePlayer?.setSource(
        AssetSource('audio/call_ended.mp3'),
      );
      await _tonePlayer?.setVolume(0.5);
      await _tonePlayer?.resume();

      debugPrint('RingtoneDatasource: Playing ended tone');
    } catch (e) {
      debugPrint('RingtoneDatasource: Error playing ended tone: $e');
    }
  }

  /// Play busy signal
  Future<void> playBusyTone() async {
    try {
      await _tonePlayer?.setSource(
        AssetSource('audio/busy_tone.mp3'),
      );
      await _tonePlayer?.setVolume(0.5);
      await _tonePlayer?.resume();

      debugPrint('RingtoneDatasource: Playing busy tone');
    } catch (e) {
      debugPrint('RingtoneDatasource: Error playing busy tone: $e');
    }
  }

  /// Stop all ringtone playback
  Future<void> stop() async {
    try {
      await _ringtonePlayer?.stop();
      _isPlaying = false;
      debugPrint('RingtoneDatasource: Stopped ringtone');
    } catch (e) {
      debugPrint('RingtoneDatasource: Error stopping ringtone: $e');
    }
  }

  /// Pause ringtone (for temporary interruption)
  Future<void> pause() async {
    try {
      await _ringtonePlayer?.pause();
      debugPrint('RingtoneDatasource: Paused ringtone');
    } catch (e) {
      debugPrint('RingtoneDatasource: Error pausing ringtone: $e');
    }
  }

  /// Resume ringtone after pause
  Future<void> resume() async {
    try {
      await _ringtonePlayer?.resume();
      debugPrint('RingtoneDatasource: Resumed ringtone');
    } catch (e) {
      debugPrint('RingtoneDatasource: Error resuming ringtone: $e');
    }
  }

  /// Set ringtone volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _ringtonePlayer?.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('RingtoneDatasource: Error setting volume: $e');
    }
  }

  /// Dispose of audio players
  Future<void> dispose() async {
    try {
      await _ringtonePlayer?.dispose();
      await _tonePlayer?.dispose();
      _ringtonePlayer = null;
      _tonePlayer = null;
      _isPlaying = false;
      debugPrint('RingtoneDatasource: Disposed audio players');
    } catch (e) {
      debugPrint('RingtoneDatasource: Error disposing: $e');
    }
  }
}
