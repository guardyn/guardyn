/// Incoming Call Service
///
/// Listens for incoming calls and shows UI notifications/dialogs.
/// This service runs globally at app level to catch calls at any time.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/call_repository.dart';
import '../../presentation/bloc/call_bloc.dart';
import '../../presentation/bloc/call_event.dart';
import '../../presentation/pages/call_page.dart';

/// Global service that listens for incoming calls and shows UI
@lazySingleton
class IncomingCallService {
  final CallRepository _callRepository;
  final Logger _logger;

  StreamSubscription<Call>? _incomingCallsSubscription;
  StreamSubscription<Call>? _callStateChangesSubscription;
  BuildContext? _appContext;
  bool _isShowingIncomingCall = false;
  String? _currentIncomingCallId;

  IncomingCallService({
    required CallRepository callRepository,
    required Logger logger,
  }) : _callRepository = callRepository,
       _logger = logger;

  /// Set the app context for showing dialogs
  void setAppContext(BuildContext context) {
    _appContext = context;
  }

  /// Start listening for incoming calls
  void startListening() {
    _logger.i('🔔 IncomingCallService: Starting to listen for incoming calls on repository stream');
    _incomingCallsSubscription?.cancel();
    _incomingCallsSubscription = _callRepository.incomingCalls.listen(
      _handleIncomingCall,
      onError: (error) {
        _logger.e(
          '🔔 IncomingCallService: Error in incoming calls stream',
          error: error,
        );
      },
    );

    // Also listen for call state changes to close dialog when caller cancels
    _callStateChangesSubscription?.cancel();
    _callStateChangesSubscription = _callRepository.callStateChanges.listen(
      _handleCallStateChange,
      onError: (error) {
        _logger.e(
          '🔔 IncomingCallService: Error in call state changes stream',
          error: error,
        );
      },
    );

    _logger.i('🔔 IncomingCallService: Listening started successfully');
  }

  /// Stop listening for incoming calls
  void stopListening() {
    _logger.i('🔔 IncomingCallService: Stopping incoming call listener');
    _incomingCallsSubscription?.cancel();
    _incomingCallsSubscription = null;
    _callStateChangesSubscription?.cancel();
    _callStateChangesSubscription = null;
  }

  /// Handle call state changes - close dialog if caller cancelled
  void _handleCallStateChange(Call call) {
    _logger.i(
      '🔔 IncomingCallService: Call state changed: '
      'call_id=${call.id}, status=${call.status}, showing=$_isShowingIncomingCall, currentCallId=$_currentIncomingCallId',
    );

    // If we're showing an incoming call dialog and the call ended, close it
    if (_isShowingIncomingCall &&
        _currentIncomingCallId == call.id &&
        (call.status == CallStatus.ended || call.status == CallStatus.failed)) {
      _logger.i('🔔 IncomingCallService: Caller cancelled - closing incoming call dialog');
      _closeIncomingCallDialog();
    }
  }

  /// Close the incoming call dialog programmatically
  void _closeIncomingCallDialog() {
    if (_appContext == null || !_isShowingIncomingCall) return;

    try {
      // Pop the dialog
      Navigator.of(_appContext!, rootNavigator: true).pop(null);
      _isShowingIncomingCall = false;
      _currentIncomingCallId = null;
      _logger.i('🔔 IncomingCallService: Incoming call dialog closed');
    } catch (e) {
      _logger.e('🔔 IncomingCallService: Failed to close dialog', error: e);
    }
  }

  /// Handle an incoming call
  void _handleIncomingCall(Call call) {
    _logger.i(
      '🔔 IncomingCallService: RECEIVED incoming call event: '
      'call_id=${call.id}, from=${call.remoteUserName ?? call.remoteUserId}',
    );

    if (_isShowingIncomingCall) {
      _logger.w('🔔 IncomingCallService: Already showing incoming call UI, ignoring');
      return;
    }

    if (_appContext == null) {
      _logger.w('🔔 IncomingCallService: No app context available, cannot show UI!');
      return;
    }

    _logger.i('🔔 IncomingCallService: Showing incoming call dialog...');
    _showIncomingCallDialog(call);
  }

  /// Show the incoming call dialog
  void _showIncomingCallDialog(Call call) {
    if (_appContext == null) return;

    _isShowingIncomingCall = true;
    _currentIncomingCallId = call.id;

    final context = _appContext!;
    final navigator = Navigator.of(context, rootNavigator: true);

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _IncomingCallDialog(
        call: call,
        onAccept: () {
          navigator.pop(true);
        },
        onReject: () {
          navigator.pop(false);
        },
      ),
    ).then((accepted) {
      _isShowingIncomingCall = false;
      _currentIncomingCallId = null;

      if (accepted == true) {
        _navigateToCallScreen(call);
      } else {
        // Reject the call
        _callRepository.rejectCall(call.id);
      }
    });
  }

  /// Navigate to the call screen
  void _navigateToCallScreen(Call call) {
    if (_appContext == null) return;

    Navigator.of(_appContext!).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => getIt<CallBloc>()
            ..add(IncomingCallEvent(call))
            ..add(AcceptCallEvent(call.id)),
          child: const CallPage(),
        ),
      ),
    );
  }

  /// Dispose resources
  void dispose() {
    _incomingCallsSubscription?.cancel();
    _callStateChangesSubscription?.cancel();
    _appContext = null;
  }
}

/// Dialog for incoming call
class _IncomingCallDialog extends StatelessWidget {
  final Call call;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _IncomingCallDialog({
    required this.call,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVideo = call.type == CallType.video;
    final callerName = call.remoteUserName ?? 'Unknown';
    final callerAvatar = call.remoteUserAvatar;

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Caller avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            backgroundImage: callerAvatar != null
                ? NetworkImage(callerAvatar)
                : null,
            child: callerAvatar == null
                ? Text(
                    callerName.isNotEmpty ? callerName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // Caller name
          Text(
            callerName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Call type
          Text(
            isVideo ? 'Incoming video call' : 'Incoming voice call',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Reject button
              _CallActionButton(
                icon: Icons.call_end,
                color: Colors.red,
                label: 'Decline',
                onTap: onReject,
              ),

              // Accept button
              _CallActionButton(
                icon: isVideo ? Icons.videocam : Icons.call,
                color: Colors.green,
                label: 'Accept',
                onTap: onAccept,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Action button for incoming call dialog
class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
