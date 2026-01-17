import 'dart:io';

import 'package:flutter/services.dart';

import 'hardware_key_storage.dart';

/// Android implementation using KeyStore with StrongBox/TEE.
///
/// Uses Android Keystore system with the following priority:
/// 1. StrongBox (dedicated secure processor, Android 9+)
/// 2. TEE (Trusted Execution Environment)
/// 3. Software fallback
class AndroidKeyStoreStorage implements HardwareKeyStorage {
  static const MethodChannel _channel = MethodChannel(
    'io.guardyn/android_keystore',
  );

  /// Check if running on Android.
  static bool get isSupported => Platform.isAndroid;

  @override
  Future<bool> isHardwareBackedAvailable() async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>(
        'isHardwareBackedAvailable',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      print('KeyStore hardware check failed: ${e.message}');
      return false;
    }
  }

  /// Check if StrongBox is available (Android 9+).
  Future<bool> isStrongBoxAvailable() async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>('isStrongBoxAvailable');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<Uint8List> generateKeyPair(String keyId) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Android KeyStore is only available on Android');
    }

    try {
      // Try StrongBox first, then TEE, then software
      final useStrongBox = await isStrongBoxAvailable();

      final result = await _channel.invokeMethod<Uint8List>('generateKeyPair', {
        'keyId': keyId,
        'useStrongBox': useStrongBox,
        'algorithm': 'EC', // ECDSA P-256
        'purposes': ['SIGN', 'VERIFY'],
        'userAuthenticationRequired': true,
        'userAuthenticationValidityDurationSeconds': 30,
      });

      if (result == null) {
        throw StateError('Failed to generate key pair');
      }

      return result;
    } on PlatformException catch (e) {
      throw StateError('Android KeyStore key generation failed: ${e.message}');
    }
  }

  @override
  Future<Uint8List> sign(String keyId, Uint8List data) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Android KeyStore is only available on Android');
    }

    try {
      final result = await _channel.invokeMethod<Uint8List>('sign', {
        'keyId': keyId,
        'data': data,
        'algorithm': 'SHA256withECDSA',
      });

      if (result == null) {
        throw StateError('Signing failed');
      }

      return result;
    } on PlatformException catch (e) {
      throw StateError('Android KeyStore signing failed: ${e.message}');
    }
  }

  @override
  Future<Uint8List?> getPublicKey(String keyId) async {
    if (!Platform.isAndroid) return null;

    try {
      return await _channel.invokeMethod<Uint8List>('getPublicKey', {
        'keyId': keyId,
      });
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<bool> keyExists(String keyId) async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>('keyExists', {
        'keyId': keyId,
      });
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> deleteKey(String keyId) async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod<void>('deleteKey', {'keyId': keyId});
    } on PlatformException catch (e) {
      print('Failed to delete key: ${e.message}');
    }
  }

  @override
  Future<List<String>> listKeyIds() async {
    if (!Platform.isAndroid) return [];

    try {
      final result = await _channel.invokeMethod<List<dynamic>>('listKeyIds');
      return result?.cast<String>() ?? [];
    } on PlatformException {
      return [];
    }
  }

  @override
  Future<HardwareSecurityInfo> getSecurityInfo() async {
    if (!Platform.isAndroid) {
      return const HardwareSecurityInfo(
        isHardwareBacked: false,
        hardwareType: SecureHardwareType.unknown,
        securityLevel: SecurityLevel.unknown,
        description: 'Not running on Android',
      );
    }

    try {
      final info = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getSecurityInfo',
      );

      if (info == null) {
        return const HardwareSecurityInfo(
          isHardwareBacked: false,
          hardwareType: SecureHardwareType.androidSoftware,
          securityLevel: SecurityLevel.software,
          description: 'Android KeyStore (software)',
        );
      }

      final hasStrongBox = info['hasStrongBox'] as bool? ?? false;
      final hasTee = info['hasTee'] as bool? ?? false;
      // Security level from Android KeyInfo
      // ignore: unused_local_variable
      final securityLevel = info['securityLevel'] as int? ?? 0;

      SecureHardwareType hardwareType;
      SecurityLevel level;
      String description;

      if (hasStrongBox) {
        hardwareType = SecureHardwareType.strongBox;
        level = SecurityLevel.hardware;
        description = 'Android StrongBox (dedicated secure processor)';
      } else if (hasTee) {
        hardwareType = SecureHardwareType.tee;
        level = SecurityLevel.firmware;
        description = 'Android TEE (Trusted Execution Environment)';
      } else {
        hardwareType = SecureHardwareType.androidSoftware;
        level = SecurityLevel.software;
        description = 'Android KeyStore (software)';
      }

      return HardwareSecurityInfo(
        isHardwareBacked: hasStrongBox || hasTee,
        hardwareType: hardwareType,
        securityLevel: level,
        description: description,
      );
    } on PlatformException {
      return const HardwareSecurityInfo(
        isHardwareBacked: false,
        hardwareType: SecureHardwareType.androidSoftware,
        securityLevel: SecurityLevel.software,
        description: 'Android KeyStore (software)',
      );
    }
  }
}

/// Kotlin native code should implement:
///
/// ```kotlin
/// package io.guardyn.keystore
///
/// import android.os.Build
/// import android.security.keystore.KeyGenParameterSpec
/// import android.security.keystore.KeyInfo
/// import android.security.keystore.KeyProperties
/// import io.flutter.plugin.common.MethodCall
/// import io.flutter.plugin.common.MethodChannel
/// import java.security.KeyFactory
/// import java.security.KeyPairGenerator
/// import java.security.KeyStore
/// import java.security.Signature
/// import java.security.spec.ECGenParameterSpec
///
/// class AndroidKeyStorePlugin : MethodChannel.MethodCallHandler {
///     private val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
///
///     override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
///         when (call.method) {
///             "isHardwareBackedAvailable" -> result.success(isHardwareBacked())
///             "isStrongBoxAvailable" -> result.success(isStrongBoxSupported())
///             "generateKeyPair" -> {
///                 val keyId = call.argument<String>("keyId") ?: return result.error("INVALID_ARGS", null, null)
///                 val useStrongBox = call.argument<Boolean>("useStrongBox") ?: false
///                 generateKeyPair(keyId, useStrongBox, result)
///             }
///             "sign" -> {
///                 val keyId = call.argument<String>("keyId") ?: return result.error("INVALID_ARGS", null, null)
///                 val data = call.argument<ByteArray>("data") ?: return result.error("INVALID_ARGS", null, null)
///                 sign(keyId, data, result)
///             }
///             else -> result.notImplemented()
///         }
///     }
///
///     private fun isHardwareBacked(): Boolean {
///         return Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
///     }
///
///     private fun isStrongBoxSupported(): Boolean {
///         return Build.VERSION.SDK_INT >= Build.VERSION_CODES.P &&
///                packageManager.hasSystemFeature(PackageManager.FEATURE_STRONGBOX_KEYSTORE)
///     }
///
///     private fun generateKeyPair(keyId: String, useStrongBox: Boolean, result: MethodChannel.Result) {
///         try {
///             val spec = KeyGenParameterSpec.Builder(
///                 keyId,
///                 KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
///             )
///                 .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
///                 .setDigests(KeyProperties.DIGEST_SHA256)
///                 .setUserAuthenticationRequired(true)
///                 .setUserAuthenticationValidityDurationSeconds(30)
///                 .apply {
///                     if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && useStrongBox) {
///                         setIsStrongBoxBacked(true)
///                     }
///                 }
///                 .build()
///
///             val keyPairGenerator = KeyPairGenerator.getInstance(
///                 KeyProperties.KEY_ALGORITHM_EC,
///                 "AndroidKeyStore"
///             )
///             keyPairGenerator.initialize(spec)
///             val keyPair = keyPairGenerator.generateKeyPair()
///
///             result.success(keyPair.public.encoded)
///         } catch (e: Exception) {
///             result.error("KEY_GEN_FAILED", e.message, null)
///         }
///     }
///
///     private fun sign(keyId: String, data: ByteArray, result: MethodChannel.Result) {
///         try {
///             val privateKey = keyStore.getKey(keyId, null) as java.security.PrivateKey
///             val signature = Signature.getInstance("SHA256withECDSA")
///             signature.initSign(privateKey)
///             signature.update(data)
///             result.success(signature.sign())
///         } catch (e: Exception) {
///             result.error("SIGN_FAILED", e.message, null)
///         }
///     }
/// }
/// ```
