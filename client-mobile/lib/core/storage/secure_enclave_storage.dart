import 'dart:io';

import 'package:flutter/services.dart';

import 'hardware_key_storage.dart';

/// iOS implementation using Secure Enclave.
///
/// Uses P-256 (secp256r1) keys as Secure Enclave only supports this curve.
/// For Ed25519 keys, falls back to Keychain with secure access control.
class SecureEnclaveStorage implements HardwareKeyStorage {
  static const MethodChannel _channel = MethodChannel(
    'io.guardyn/secure_enclave',
  );

  // Key types
  static const String _keyTypeSecureEnclave = 'secure_enclave';
  // ignore: unused_field
  static const String _keyTypeKeychain = 'keychain';

  /// Check if running on iOS with Secure Enclave support.
  static bool get isSupported => Platform.isIOS;

  @override
  Future<bool> isHardwareBackedAvailable() async {
    if (!Platform.isIOS) return false;

    try {
      final result = await _channel.invokeMethod<bool>(
        'isSecureEnclaveAvailable',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      print('SecureEnclave check failed: ${e.message}');
      return false;
    }
  }

  @override
  Future<Uint8List> generateKeyPair(String keyId) async {
    if (!Platform.isIOS) {
      throw UnsupportedError('Secure Enclave is only available on iOS');
    }

    try {
      final result = await _channel.invokeMethod<Uint8List>('generateKeyPair', {
        'keyId': keyId,
        'keyType': _keyTypeSecureEnclave,
        'accessControl': 'userPresence', // Require biometric/passcode
      });

      if (result == null) {
        throw StateError('Failed to generate key pair');
      }

      return result;
    } on PlatformException catch (e) {
      throw StateError('Secure Enclave key generation failed: ${e.message}');
    }
  }

  @override
  Future<Uint8List> sign(String keyId, Uint8List data) async {
    if (!Platform.isIOS) {
      throw UnsupportedError('Secure Enclave is only available on iOS');
    }

    try {
      final result = await _channel.invokeMethod<Uint8List>('sign', {
        'keyId': keyId,
        'data': data,
      });

      if (result == null) {
        throw StateError('Signing failed');
      }

      return result;
    } on PlatformException catch (e) {
      throw StateError('Secure Enclave signing failed: ${e.message}');
    }
  }

  @override
  Future<Uint8List?> getPublicKey(String keyId) async {
    if (!Platform.isIOS) return null;

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
    if (!Platform.isIOS) return false;

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
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod<void>('deleteKey', {'keyId': keyId});
    } on PlatformException catch (e) {
      print('Failed to delete key: ${e.message}');
    }
  }

  @override
  Future<List<String>> listKeyIds() async {
    if (!Platform.isIOS) return [];

    try {
      final result = await _channel.invokeMethod<List<dynamic>>('listKeyIds');
      return result?.cast<String>() ?? [];
    } on PlatformException {
      return [];
    }
  }

  @override
  Future<HardwareSecurityInfo> getSecurityInfo() async {
    if (!Platform.isIOS) {
      return const HardwareSecurityInfo(
        isHardwareBacked: false,
        hardwareType: SecureHardwareType.unknown,
        securityLevel: SecurityLevel.unknown,
        description: 'Not running on iOS',
      );
    }

    final isAvailable = await isHardwareBackedAvailable();

    return HardwareSecurityInfo(
      isHardwareBacked: isAvailable,
      hardwareType: isAvailable
          ? SecureHardwareType.secureEnclave
          : SecureHardwareType.softwareFallback,
      securityLevel: isAvailable
          ? SecurityLevel.hardware
          : SecurityLevel.software,
      description: isAvailable
          ? 'iOS Secure Enclave (A7+ chip)'
          : 'iOS Keychain (software)',
    );
  }
}

/// Swift/Objective-C native code should implement:
///
/// ```swift
/// import Security
/// import LocalAuthentication
///
/// @objc class SecureEnclavePlugin: NSObject, FlutterPlugin {
///     static func register(with registrar: FlutterPluginRegistrar) {
///         let channel = FlutterMethodChannel(
///             name: "io.guardyn/secure_enclave",
///             binaryMessenger: registrar.messenger()
///         )
///         let instance = SecureEnclavePlugin()
///         registrar.addMethodCallDelegate(instance, channel: channel)
///     }
///
///     func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
///         switch call.method {
///         case "isSecureEnclaveAvailable":
///             result(isSecureEnclaveAvailable())
///         case "generateKeyPair":
///             guard let args = call.arguments as? [String: Any],
///                   let keyId = args["keyId"] as? String else {
///                 result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
///                 return
///             }
///             generateKeyPair(keyId: keyId, result: result)
///         case "sign":
///             guard let args = call.arguments as? [String: Any],
///                   let keyId = args["keyId"] as? String,
///                   let data = args["data"] as? FlutterStandardTypedData else {
///                 result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
///                 return
///             }
///             sign(keyId: keyId, data: data.data, result: result)
///         // ... other methods
///         default:
///             result(FlutterMethodNotImplemented)
///         }
///     }
///
///     private func isSecureEnclaveAvailable() -> Bool {
///         let context = LAContext()
///         var error: NSError?
///         // Secure Enclave requires A7 chip or later (iPhone 5s+)
///         return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
///     }
///
///     private func generateKeyPair(keyId: String, result: @escaping FlutterResult) {
///         let access = SecAccessControlCreateWithFlags(
///             kCFAllocatorDefault,
///             kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
///             [.privateKeyUsage, .userPresence],
///             nil
///         )!
///
///         let attributes: [String: Any] = [
///             kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
///             kSecAttrKeySizeInBits as String: 256,
///             kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
///             kSecPrivateKeyAttrs as String: [
///                 kSecAttrIsPermanent as String: true,
///                 kSecAttrApplicationTag as String: keyId.data(using: .utf8)!,
///                 kSecAttrAccessControl as String: access
///             ]
///         ]
///
///         var error: Unmanaged<CFError>?
///         guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error),
///               let publicKey = SecKeyCopyPublicKey(privateKey) else {
///             result(FlutterError(code: "KEY_GEN_FAILED", message: nil, details: nil))
///             return
///         }
///
///         guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
///             result(FlutterError(code: "KEY_EXPORT_FAILED", message: nil, details: nil))
///             return
///         }
///
///         result(FlutterStandardTypedData(bytes: publicKeyData))
///     }
/// }
/// ```
