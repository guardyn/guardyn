/// Call Page
///
/// Full-screen call UI with video/audio controls.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/entities.dart';
import '../bloc/call_bloc.dart';
import '../bloc/call_event.dart';
import '../bloc/call_state.dart' as call_state;
import '../widgets/call_controls.dart';
import '../widgets/call_timer.dart';
import '../widgets/connection_quality_indicator.dart';
import '../widgets/participant_tile.dart';

/// Full-screen call page
class CallPage extends StatefulWidget {
  const CallPage({super.key});

  static const routeName = '/call';

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    // Lock to portrait for now, could support landscape for video
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // Hide status bar during call
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallBloc, call_state.CallState>(
      listener: (context, state) {
        // Navigate back when call ends
        if (state is call_state.CallEnded ||
            state is call_state.CallFailed ||
            state is call_state.CallInitial) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: _toggleControls,
            child: Stack(
              children: [
                // Background / Video area
                _buildCallBackground(state),

                // Call info overlay
                AnimatedOpacity(
                  opacity: _controlsVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: _buildCallInfo(state),
                ),

                // Controls at bottom
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  left: 0,
                  right: 0,
                  bottom: _controlsVisible ? 0 : -120,
                  child: _buildControls(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build call background (video or avatar)
  Widget _buildCallBackground(call_state.CallState state) {
    final call = _getCall(state);
    if (call == null) {
      return const SizedBox.expand(
        child: ColoredBox(color: Colors.black),
      );
    }

    // For video calls, show video feed
    if (call.isVideoCall && call.status == CallStatus.connected) {
      return Stack(
        children: [
          // Remote video (full screen)
          const ParticipantTile(
            isLocal: false,
            isVideoEnabled: true,
            displayName: '',
            isMuted: false,
          ),
          // Local video (picture-in-picture)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: SizedBox(
              width: 120,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ParticipantTile(
                  isLocal: true,
                  isVideoEnabled: call.isLocalVideoEnabled,
                  displayName: 'You',
                  isMuted: call.isLocalMuted,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // For audio calls or connecting state, show avatar
    return _buildAudioOnlyBackground(call);
  }

  /// Build audio-only call background with avatar
  Widget _buildAudioOnlyBackground(Call call) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f3460),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 67,
                backgroundColor: Colors.blue.shade700,
                backgroundImage: call.remoteUserAvatar != null
                    ? NetworkImage(call.remoteUserAvatar!)
                    : null,
                child: call.remoteUserAvatar == null
                    ? Text(
                        _getInitials(call.remoteUserName ?? 'Unknown'),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            // Name
            Text(
              call.remoteUserName ?? 'Unknown',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build call info overlay (status, timer, quality)
  Widget _buildCallInfo(call_state.CallState state) {
    final call = _getCall(state);
    if (call == null) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Connection quality indicator (shown when connected)
            if (state is call_state.CallConnected) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConnectionQualityIndicator(
                    qualityScore: call.qualityScore,
                    showLabel: true,
                    size: ConnectionQualitySize.medium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            // Status text
            Text(
              _getStatusText(state),
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            // Timer (only when connected)
            if (state is call_state.CallConnected) ...[
              const SizedBox(height: 8),
              CallTimer(duration: state.duration),
            ],
          ],
        ),
      ),
    );
  }

  /// Build call controls
  Widget _buildControls(BuildContext context, call_state.CallState state) {
    final call = _getCall(state);
    if (call == null) return const SizedBox.shrink();

    return CallControls(
      isMuted: call.isLocalMuted,
      isVideoEnabled: call.isLocalVideoEnabled,
      isSpeakerOn: call.isSpeakerOn,
      isVideoCall: call.isVideoCall,
      onMutePressed: () {
        context.read<CallBloc>().add(const ToggleMuteEvent());
      },
      onVideoPressed: () {
        context.read<CallBloc>().add(const ToggleVideoEvent());
      },
      onSpeakerPressed: () {
        context.read<CallBloc>().add(const ToggleSpeakerEvent());
      },
      onSwitchCameraPressed: () {
        context.read<CallBloc>().add(const SwitchCameraEvent());
      },
      onEndCallPressed: () {
        context.read<CallBloc>().add(EndCallEvent(call.id));
      },
    );
  }

  /// Get call from state
  Call? _getCall(call_state.CallState state) {
    return switch (state) {
      call_state.CallRinging(call: final call) => call,
      call_state.CallInitiating(call: final call) => call,
      call_state.CallConnecting(call: final call) => call,
      call_state.CallConnected(call: final call) => call,
      call_state.CallEnded(call: final call) => call,
      call_state.CallFailed(call: final call) => call,
      _ => null,
    };
  }

  /// Get status text for state
  String _getStatusText(call_state.CallState state) {
    return switch (state) {
      call_state.CallRinging() => 'Incoming call...',
      call_state.CallInitiating() => 'Calling...',
      call_state.CallConnecting() => 'Connecting...',
      call_state.CallConnected() => 'Connected',
      call_state.CallEnded(reason: final reason) => reason.message,
      call_state.CallFailed(message: final msg) => msg,
      _ => '',
    };
  }

  /// Get initials from name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}
