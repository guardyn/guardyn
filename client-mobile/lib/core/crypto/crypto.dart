/// E2EE Cryptography module for Guardyn
///
/// Provides X3DH key exchange and Double Ratchet encryption
/// Compatible with Guardyn backend Rust implementation
///
/// The module supports two backends:
/// - Pure Dart (cryptography, pointycastle, pinenacl) - works on all platforms including Web
/// - Native Rust FFI (via flutter_rust_bridge) - provides post-quantum crypto and hardware acceleration
///
/// ## Architecture
///
/// ```
/// CryptoPrimitives ← Low-level ops (key gen, HKDF, AES-GCM, Ed25519)
///       ↓
/// CryptoBridge     ← Platform abstraction (Rust FFI or Dart fallback)
///       ↓
/// X3DH / DoubleRatchet ← Protocol implementations
///       ↓
/// CryptoService    ← High-level session management
/// ```
library;

// Exceptions
export 'crypto_exceptions.dart';
// Low-level crypto primitives (prefer using this)
export 'crypto_primitives.dart';
// High-level service
export 'crypto_service.dart';
// Protocol implementations
export 'double_ratchet.dart';
// Native bridge (for advanced usage)
export 'native_crypto_bridge.dart';
export 'x3dh.dart';
