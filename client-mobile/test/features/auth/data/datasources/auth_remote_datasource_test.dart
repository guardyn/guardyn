/// Proves what actually goes on the wire when a device publishes its key bundle.
///
/// The assertion that matters is not "post-quantum works" - it is that tags 6 and 7 are either
/// both present or both absent. `auth-service` refuses a bundle carrying one without the other
/// and that refusal discards the **whole** bundle, classical keys included, while `register`
/// still reports success to the client. A half pair therefore produces an account that looks
/// registered and holds nothing the server will serve, which no amount of client-side retry
/// recovers from.
///
/// The second assertion is that tags 1-5 are untouched. Every peer in production today takes
/// the classical branch, so a regression there breaks messaging outright rather than merely
/// giving up the post-quantum half.
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:guardyn_client/core/crypto/crypto_service.dart';
import 'package:guardyn_client/core/crypto/x3dh.dart';
import 'package:guardyn_client/core/network/grpc_clients.dart';
import 'package:guardyn_client/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:guardyn_client/generated/auth.pbgrpc.dart';
import 'package:guardyn_client/generated/common.pb.dart';
import 'package:mocktail/mocktail.dart';

class MockGrpcClients extends Mock implements GrpcClients {}

class MockAuthServiceClient extends Mock implements AuthServiceClient {}

class MockCryptoService extends Mock implements CryptoService {}

class FakeRegisterRequest extends Fake implements RegisterRequest {}

class FakeLoginRequest extends Fake implements LoginRequest {}

/// Mock ResponseFuture for gRPC calls
class MockResponseFuture<T> extends Mock implements ResponseFuture<T> {
  final T _value;

  MockResponseFuture(this._value);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) {
    return Future.value(_value).then(onValue, onError: onError);
  }

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) {
    return Future.value(_value).catchError(onError, test: test);
  }

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) {
    return Future.value(_value).whenComplete(action);
  }
}

Uint8List _bytes(int fill, int length) =>
    Uint8List.fromList(List<int>.filled(length, fill));

/// The classical half every bundle carries, hybrid or not.
final _identityKey = _bytes(0x11, 32);
final _signedPreKey = _bytes(0x22, 32);
final _signedPreKeySignature = _bytes(0x33, 64);
final _oneTimePreKey = _bytes(0x44, 32);

/// A stand-in encapsulation key. The real one comes from the FFI and is asserted on a device
/// in `integration_test/crypto/rust_ffi_test.dart`; what this file checks is the plumbing.
final _mlKemPublic = _bytes(0x55, 1184);
final _mlKemSignature = _bytes(0x66, 64);

void main() {
  late MockGrpcClients grpcClients;
  late MockAuthServiceClient authClient;
  late MockCryptoService cryptoService;
  late AuthRemoteDatasource datasource;

  setUpAll(() {
    registerFallbackValue(FakeRegisterRequest());
    registerFallbackValue(FakeLoginRequest());
  });

  setUp(() {
    grpcClients = MockGrpcClients();
    authClient = MockAuthServiceClient();
    cryptoService = MockCryptoService();

    when(() => grpcClients.authClient).thenReturn(authClient);
    when(
      () => cryptoService.generateKeyBundleAsync(
        oneTimePreKeyCount: any(named: 'oneTimePreKeyCount'),
      ),
    ).thenAnswer(
      (_) async => X3DHKeyBundle(
        identityKey: _identityKey,
        signedPreKey: _signedPreKey,
        signedPreKeySignature: _signedPreKeySignature,
        signedPreKeyId: 1,
        oneTimePreKey: _oneTimePreKey,
        oneTimePreKeyId: 0,
      ),
    );

    when(() => authClient.register(any())).thenAnswer(
      (_) => MockResponseFuture(
        RegisterResponse()
          ..success = (RegisterSuccess()
            ..userId = 'user-1'
            ..deviceId = 'device-1'
            ..accessToken = 'access'
            ..refreshToken = 'refresh'),
      ),
    );
    when(() => authClient.login(any())).thenAnswer(
      (_) => MockResponseFuture(
        LoginResponse()
          ..success = (LoginSuccess()
            ..userId = 'user-1'
            ..deviceId = 'device-1'
            ..accessToken = 'access'
            ..refreshToken = 'refresh'),
      ),
    );

    datasource = AuthRemoteDatasource(grpcClients, cryptoService);
  });

  /// The bundle `register` actually put on the wire.
  Future<KeyBundle> registeredBundle() async {
    await datasource.register(
      username: 'alice',
      password: 'correct horse battery staple',
      deviceName: 'Pixel',
    );
    final request =
        verify(() => authClient.register(captureAny())).captured.single
            as RegisterRequest;
    return request.keyBundle;
  }

  /// The bundle `login` actually put on the wire.
  Future<KeyBundle> loggedInBundle() async {
    await datasource.login(username: 'alice', password: 'hunter2');
    final request =
        verify(() => authClient.login(captureAny())).captured.single
            as LoginRequest;
    return request.keyBundle;
  }

  void expectClassicalHalfIntact(KeyBundle bundle) {
    expect(bundle.identityKey, equals(_identityKey));
    expect(bundle.signedPreKey, equals(_signedPreKey));
    expect(bundle.signedPreKeySignature, equals(_signedPreKeySignature));
    expect(bundle.oneTimePreKeys, equals([_oneTimePreKey]));
    expect(bundle.hasCreatedAt(), isTrue);
  }

  group('AuthRemoteDatasource key bundle', () {
    group('on a device with no ML-KEM pre-key', () {
      setUp(() {
        when(
          () => cryptoService.mlKemPreKeyForPublication(),
        ).thenAnswer((_) async => null);
      });

      test('register publishes a complete classical bundle', () async {
        final bundle = await registeredBundle();

        expectClassicalHalfIntact(bundle);
        expect(bundle.hasMlKemPublic(), isFalse);
        expect(bundle.hasMlKemPublicSignature(), isFalse);
      });

      test('login publishes a complete classical bundle', () async {
        final bundle = await loggedInBundle();

        expectClassicalHalfIntact(bundle);
        expect(bundle.hasMlKemPublic(), isFalse);
        expect(bundle.hasMlKemPublicSignature(), isFalse);
      });
    });

    group('on a device holding an ML-KEM pre-key', () {
      setUp(() {
        when(() => cryptoService.mlKemPreKeyForPublication()).thenAnswer(
          (_) async =>
              MlKemPreKey(publicKey: _mlKemPublic, signature: _mlKemSignature),
        );
      });

      test('register publishes the hybrid bundle without disturbing tags 1-5', () async {
        final bundle = await registeredBundle();

        expectClassicalHalfIntact(bundle);
        expect(bundle.mlKemPublic, equals(_mlKemPublic));
        expect(bundle.mlKemPublicSignature, equals(_mlKemSignature));
      });

      test('login publishes the hybrid bundle without disturbing tags 1-5', () async {
        final bundle = await loggedInBundle();

        expectClassicalHalfIntact(bundle);
        expect(bundle.mlKemPublic, equals(_mlKemPublic));
        expect(bundle.mlKemPublicSignature, equals(_mlKemSignature));
      });

      test('the published bundle survives a serialisation round trip', () async {
        // The server parses bytes, not this object. `optional` keeps "not published" and
        // "published empty" distinct, and that distinction only exists on the wire.
        final bundle = await registeredBundle();
        final decoded = KeyBundle.fromBuffer(bundle.writeToBuffer());

        expect(decoded.mlKemPublic, equals(_mlKemPublic));
        expect(decoded.mlKemPublicSignature, equals(_mlKemSignature));
        expect(decoded.identityKey, equals(_identityKey));
      });
    });

    test('tags 6 and 7 are never published one without the other', () async {
      // The half-pair rule, asserted over both device shapes rather than trusted to the
      // branch that implements it. A bundle carrying one field is rejected in whole by
      // `KeyBundle::validate_for_store`, and the caller is told the registration succeeded.
      for (final preKey in [
        null,
        MlKemPreKey(publicKey: _mlKemPublic, signature: _mlKemSignature),
      ]) {
        when(
          () => cryptoService.mlKemPreKeyForPublication(),
        ).thenAnswer((_) async => preKey);

        final bundle = await registeredBundle();

        expect(
          bundle.hasMlKemPublic(),
          equals(bundle.hasMlKemPublicSignature()),
          reason: 'a half pair discards the whole bundle server-side',
        );
        clearInteractions(authClient);
      }
    });
  });
}
