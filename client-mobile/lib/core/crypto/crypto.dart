/// E2EE Cryptography module for Guardyn
///
/// Provides X3DH key exchange and Double Ratchet encryption
/// Compatible with Guardyn backend Rust implementation
///
/// The module supports two backends:
/// - Pure Dart (cryptography, pointycastle, pinenacl) - works on all platforms including Web
/// - Native Rust FFI (via flutter_rust_bridge) - provides post-quantum crypto and hardware acceleration
library;

export 'crypto_exceptions.dart';
export 'crypto_service.dart';
export 'double_ratchet.dart';
export 'native_crypto_bridge.dart';
export 'x3dh.dart';
