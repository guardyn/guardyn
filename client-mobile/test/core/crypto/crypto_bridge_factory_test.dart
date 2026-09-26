/// Unit tests for CryptoBridgeFactory and native bridge selection
///
/// Run with:
/// ```bash
/// flutter test test/core/crypto/crypto_bridge_factory_test.dart
/// ```
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:guardyn_client/core/crypto/native/dart_crypto_bridge.dart';
import 'package:guardyn_client/core/crypto/native_crypto_bridge.dart';

void main() {
  group('CryptoBridgeFactory', () {
    setUp(() {
      CryptoBridgeFactory.reset();
      CryptoBridgeFactory.allowInsecureDartFallback = false;
    });

    tearDown(() {
      CryptoBridgeFactory.reset();
      CryptoBridgeFactory.allowInsecureDartFallback = false;
    });

    test('refuses to establish a bridge when the native library is missing', () async {
      // The #230 regression test, and the reason the three tests that used to live here were
      // rewritten: they asserted `expect(bridge, isNotNull)` under the title "factory returns
      // native bridge on supported platforms". That passed on DartCryptoBridge just as happily
      // as on the real one, so it certified precisely the downgrade it was named after.
      //
      // There is no FFI in a headless test VM, so this exercises the missing-library path.
      //
      // The refusal is asserted on `ensureInstance` rather than on `instance` because #366
      // moved it there. Construction no longer probes the library - it cannot, nothing has
      // started flutter_rust_bridge yet - so initialisation is where the answer is found and
      // where the refusal now belongs. The guarantee is unchanged: no silent downgrade, ever.
      await expectLater(
        CryptoBridgeFactory.ensureInstance(),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            contains('Refusing to fall back'),
          ),
        ),
        reason: 'a missing native library must fail loudly, never downgrade silently',
      );
    });

    test('a failed attempt caches nothing, so the next one fails the same way', () async {
      // This is #366 itself, and the assertion the old code made impossible to write.
      //
      // Availability used to be decided by a probe whose answer was cached in a private static
      // with no seam and no invalidation - not even `reset()` cleared it. One premature call
      // pinned "unavailable" for the life of the process, which is how a transient ordering
      // problem became a permanent one and took application startup down with it.
      //
      // `ensureInstance` assigns `_instance` only after `initialize` returns, so there is
      // nowhere for a negative to be recorded. A second attempt must reach the library again
      // and fail on its own merits rather than be answered from a poisoned cache.
      Future<void> attempt() => CryptoBridgeFactory.ensureInstance();

      await expectLater(attempt(), throwsA(isA<UnsupportedError>()));
      await expectLater(
        attempt(),
        throwsA(isA<UnsupportedError>()),
        reason: 'a failure must not be remembered; the retry must be a real attempt',
      );

      // And with the grant in place the very next call succeeds - which it could not do if the
      // two failures above had left anything behind.
      CryptoBridgeFactory.allowInsecureDartFallback = true;
      expect(await CryptoBridgeFactory.ensureInstance(), isA<DartCryptoBridge>());
    });

    test('an unestablished bridge is never handed out', () {
      // `instance` throws rather than building one on demand. An uninitialised bridge cannot
      // report whether the native library works, so returning one would put the caller back in
      // exactly the state #366 describes: holding a bridge whose capabilities are a guess.
      expect(() => CryptoBridgeFactory.instance, throwsStateError);
    });

    test('uses the Dart bridge only when the fallback is granted explicitly', () async {
      CryptoBridgeFactory.allowInsecureDartFallback = true;

      expect(await CryptoBridgeFactory.ensureInstance(), isA<DartCryptoBridge>());
    });

    test('instance returns singleton', () async {
      CryptoBridgeFactory.allowInsecureDartFallback = true;

      final bridge1 = await CryptoBridgeFactory.ensureInstance();
      final bridge2 = await CryptoBridgeFactory.ensureInstance();

      expect(
        identical(bridge1, bridge2),
        isTrue,
        reason: 'Factory should return same instance',
      );
      expect(identical(CryptoBridgeFactory.instance, bridge1), isTrue);
    });

    test('concurrent callers share a single initialisation', () async {
      // flutter_rust_bridge permits exactly one `init()` per process and throws on the second,
      // so two bridges initialising at once is a real hazard rather than a theoretical one.
      CryptoBridgeFactory.allowInsecureDartFallback = true;

      final bridges = await Future.wait([
        CryptoBridgeFactory.ensureInstance(),
        CryptoBridgeFactory.ensureInstance(),
        CryptoBridgeFactory.ensureInstance(),
      ]);

      expect(
        bridges.every((b) => identical(b, bridges.first)),
        isTrue,
        reason: 'a concurrent race must not produce a second bridge',
      );
    });

    test('reset clears singleton', () async {
      CryptoBridgeFactory.allowInsecureDartFallback = true;

      final bridge1 = await CryptoBridgeFactory.ensureInstance();
      CryptoBridgeFactory.reset();
      final bridge2 = await CryptoBridgeFactory.ensureInstance();

      expect(
        identical(bridge1, bridge2),
        isFalse,
        reason: 'Reset should clear the singleton',
      );
    });

    test('revoking the grant makes the next build refuse again', () async {
      // The permission is not sticky: it gates each construction, so a test that granted it
      // cannot leave the application permanently downgraded.
      CryptoBridgeFactory.allowInsecureDartFallback = true;
      expect(await CryptoBridgeFactory.ensureInstance(), isA<DartCryptoBridge>());

      CryptoBridgeFactory.reset();
      CryptoBridgeFactory.allowInsecureDartFallback = false;

      await expectLater(
        CryptoBridgeFactory.ensureInstance(),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('NativeCryptoConfig', () {
    test('default config has expected values', () {
      const config = NativeCryptoConfig.defaultConfig;

      expect(config.preferNative, isTrue);
      expect(
        config.enablePostQuantum,
        isTrue,
        reason: 'PR-98c publishes ML-KEM pre-keys, so PQ is on by default. A build '
            'without the native `pq` feature still reports postQuantumAvailable=false '
            'and stays classical.',
      );
    });

    test('post-quantum can still be turned off explicitly', () {
      // Not a supported configuration - it gives up the post-quantum half of I-3 - but the
      // flag has to remain honest for diagnosing a native build.
      const config = NativeCryptoConfig(enablePostQuantum: false);

      expect(config.enablePostQuantum, isFalse);
    });

    test('config is immutable', () {
      const config1 = NativeCryptoConfig.defaultConfig;
      const config2 = NativeCryptoConfig.defaultConfig;

      expect(config1.preferNative, equals(config2.preferNative));
      expect(config1.enablePostQuantum, equals(config2.enablePostQuantum));
    });
  });

}
