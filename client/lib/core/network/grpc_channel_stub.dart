/// Stub for GrpcWebClientChannel - only used on non-web platforms
/// This file should never be executed on non-web platforms,
/// it's only here to satisfy the conditional import
library;

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_connection_interface.dart';

/// Stub class for GrpcWebClientChannel - throws error if called on non-web platforms
class GrpcWebClientChannel implements ClientChannelBase {
  /// Factory for creating xhr transport (web only)
  static ClientChannelBase xhr(Uri uri) {
    throw UnsupportedError(
      'GrpcWebClientChannel.xhr() is only supported on web platforms. '
      'This code should not be reachable on native platforms.',
    );
  }

  @override
  ClientCall<Q, R> createCall<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
  ) {
    throw UnimplementedError('Stub implementation');
  }

  @override
  ClientConnection createConnection() {
    throw UnimplementedError('Stub implementation');
  }

  @override
  Future<void> shutdown() async {
    throw UnimplementedError('Stub implementation');
  }

  @override
  Future<void> terminate() async {
    throw UnimplementedError('Stub implementation');
  }

  @override
  Future<ClientConnection> getConnection() async {
    throw UnimplementedError('Stub implementation');
  }

  @override
  Stream<ConnectionState> get onConnectionStateChanged {
    throw UnimplementedError('Stub implementation');
  }
}
