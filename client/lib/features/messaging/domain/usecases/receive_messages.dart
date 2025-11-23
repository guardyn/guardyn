import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/message.dart';
import '../repositories/message_repository.dart';
import '../../../../core/error/failures.dart';

@injectable
class ReceiveMessages {
  final MessageRepository repository;

  ReceiveMessages(this.repository);

  Stream<Either<Failure, Message>> call() {
    return repository.receiveMessages();
  }
}
