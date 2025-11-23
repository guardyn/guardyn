import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/message.dart';
import '../repositories/message_repository.dart';

@injectable
class ReceiveMessages {
  final MessageRepository repository;

  ReceiveMessages(this.repository);

  Stream<Either<Failure, Message>> call() {
    return repository.receiveMessages();
  }
}
