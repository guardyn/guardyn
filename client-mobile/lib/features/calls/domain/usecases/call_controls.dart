/// Call Controls Use Cases
///
/// Use cases for controlling call media settings.
library;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/call_repository.dart';

/// Use case for toggling mute
@injectable
class ToggleMute {
  final CallRepository repository;

  ToggleMute(this.repository);

  Future<Either<Failure, void>> call(ToggleMuteParams params) async {
    return repository.setMuted(params.callId, params.muted);
  }
}

class ToggleMuteParams {
  final String callId;
  final bool muted;

  const ToggleMuteParams({required this.callId, required this.muted});
}

/// Use case for toggling video
@injectable
class ToggleVideo {
  final CallRepository repository;

  ToggleVideo(this.repository);

  Future<Either<Failure, void>> call(ToggleVideoParams params) async {
    return repository.setVideoEnabled(params.callId, params.enabled);
  }
}

class ToggleVideoParams {
  final String callId;
  final bool enabled;

  const ToggleVideoParams({required this.callId, required this.enabled});
}

/// Use case for toggling speaker
@injectable
class ToggleSpeaker {
  final CallRepository repository;

  ToggleSpeaker(this.repository);

  Future<Either<Failure, void>> call(ToggleSpeakerParams params) async {
    return repository.setSpeakerEnabled(params.callId, params.enabled);
  }
}

class ToggleSpeakerParams {
  final String callId;
  final bool enabled;

  const ToggleSpeakerParams({required this.callId, required this.enabled});
}

/// Use case for switching camera
@injectable
class SwitchCamera {
  final CallRepository repository;

  SwitchCamera(this.repository);

  Future<Either<Failure, void>> call(String callId) async {
    return repository.switchCamera(callId);
  }
}
