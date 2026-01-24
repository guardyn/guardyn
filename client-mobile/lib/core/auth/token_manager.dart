import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:guardyn_client/core/network/grpc_clients.dart';
import 'package:guardyn_client/core/storage/secure_storage.dart';
import 'package:guardyn_client/generated/auth.pbgrpc.dart';
import 'package:logger/logger.dart';

/// Manages authentication tokens with automatic refresh
///
/// This service handles:
/// - Storing access and refresh tokens securely
/// - Automatically refreshing access tokens before they expire
/// - Providing valid tokens for gRPC requests
/// - Token expiration tracking
class TokenManager {
  final SecureStorage _secureStorage;
  final GrpcClients _grpcClients;
  final Logger _logger = Logger();

  /// Buffer time before token expiration to trigger refresh (2 minutes)
  static const Duration _refreshBuffer = Duration(minutes: 2);

  /// Access token expiry duration from server (15 minutes)
  static const Duration _accessTokenDuration = Duration(minutes: 15);

  /// Cached access token
  String? _accessToken;

  /// Cached refresh token
  String? _refreshToken;

  /// Time when access token was last refreshed
  DateTime? _tokenRefreshedAt;

  /// Lock to prevent concurrent refresh requests
  Completer<String?>? _refreshLock;

  /// Callback when tokens are invalidated (e.g., refresh token expired)
  void Function()? onTokensInvalidated;

  TokenManager(this._secureStorage, this._grpcClients);

  /// Initialize token manager by loading cached tokens
  Future<void> initialize() async {
    _accessToken = await _secureStorage.getAccessToken();
    _refreshToken = await _secureStorage.getRefreshToken();
    _logger.d(
      'TokenManager initialized: hasAccessToken=${_accessToken != null}',
    );
  }

  /// Save new tokens after login/register
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _tokenRefreshedAt = DateTime.now();

    await _secureStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    _logger.i('Tokens saved successfully');
  }

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _tokenRefreshedAt = null;

    await _secureStorage.clearTokens();
    _logger.i('Tokens cleared');
  }

  /// Check if user has valid tokens
  bool get hasTokens => _accessToken != null && _refreshToken != null;

  /// Get current access token (without refresh check)
  String? get currentAccessToken => _accessToken;

  /// Get a valid access token, refreshing if necessary
  ///
  /// This method will:
  /// 1. Return cached token if still valid
  /// 2. Refresh the token if expired or about to expire
  /// 3. Return null if refresh fails (triggers re-login)
  Future<String?> getValidAccessToken() async {
    // No tokens available
    if (_accessToken == null || _refreshToken == null) {
      _logger.w('No tokens available');
      return null;
    }

    // Check if token needs refresh
    if (_shouldRefreshToken()) {
      _logger.d('Token needs refresh, refreshing...');
      return await _refreshAccessToken();
    }

    return _accessToken;
  }

  /// Check if access token should be refreshed
  bool _shouldRefreshToken() {
    if (_tokenRefreshedAt == null) {
      // If we don't know when token was refreshed, assume it might be expired
      // This happens on app restart - we'll try to use it and refresh on failure
      return false;
    }

    final tokenAge = DateTime.now().difference(_tokenRefreshedAt!);
    final shouldRefresh = tokenAge > (_accessTokenDuration - _refreshBuffer);

    if (shouldRefresh) {
      _logger.d('Token age: ${tokenAge.inMinutes}m, needs refresh');
    }

    return shouldRefresh;
  }

  /// Refresh the access token using refresh token
  ///
  /// Uses a lock to prevent multiple concurrent refresh requests
  Future<String?> _refreshAccessToken() async {
    // If already refreshing, wait for that to complete
    if (_refreshLock != null) {
      _logger.d('Waiting for ongoing refresh...');
      return await _refreshLock!.future;
    }

    // Create lock
    _refreshLock = Completer<String?>();

    try {
      final refreshToken = _refreshToken;
      if (refreshToken == null) {
        _logger.w('No refresh token available');
        _refreshLock!.complete(null);
        return null;
      }

      _logger.i('Refreshing access token...');

      final request = RefreshTokenRequest()..refreshToken = refreshToken;

      final response = await _grpcClients.authClient.refreshToken(request);

      if (response.hasSuccess()) {
        final success = response.success;

        // Save new tokens
        _accessToken = success.accessToken;
        _refreshToken = success.refreshToken;
        _tokenRefreshedAt = DateTime.now();

        await _secureStorage.saveTokens(
          accessToken: success.accessToken,
          refreshToken: success.refreshToken,
        );

        _logger.i('Token refreshed successfully');
        _refreshLock!.complete(_accessToken);
        return _accessToken;
      } else if (response.hasError()) {
        _logger.e('Token refresh failed: ${response.error.message}');

        // Clear tokens if refresh failed (session expired)
        await clearTokens();
        onTokensInvalidated?.call();

        _refreshLock!.complete(null);
        return null;
      } else {
        _logger.e('Unknown refresh response');
        _refreshLock!.complete(null);
        return null;
      }
    } on GrpcError catch (e) {
      _logger.e('gRPC error during token refresh: ${e.message}');

      // If unauthorized, clear tokens
      if (e.code == StatusCode.unauthenticated) {
        await clearTokens();
        onTokensInvalidated?.call();
      }

      _refreshLock!.complete(null);
      return null;
    } catch (e) {
      _logger.e('Error during token refresh: $e');
      _refreshLock!.complete(null);
      return null;
    } finally {
      _refreshLock = null;
    }
  }

  /// Force refresh the token (e.g., after getting 401 from a service)
  Future<String?> forceRefresh() async {
    _tokenRefreshedAt = null; // Force refresh check
    return await _refreshAccessToken();
  }

  /// Get CallOptions with valid authorization header for gRPC calls
  ///
  /// This is the main method to use for authenticated gRPC calls.
  /// It automatically handles token refresh.
  Future<CallOptions> getAuthCallOptions({Duration? timeout}) async {
    final token = await getValidAccessToken();

    if (token == null) {
      throw TokenException('No valid access token available');
    }

    return CallOptions(
      metadata: {'authorization': 'Bearer $token'},
      timeout: timeout ?? const Duration(seconds: 15),
    );
  }

  /// Execute a gRPC call with automatic token refresh on 401
  ///
  /// If the call fails with UNAUTHENTICATED, it will refresh the token
  /// and retry once.
  Future<T> executeWithAuth<T>(
    Future<T> Function(CallOptions options) grpcCall, {
    Duration? timeout,
  }) async {
    try {
      final options = await getAuthCallOptions(timeout: timeout);
      return await grpcCall(options);
    } on GrpcError catch (e) {
      if (e.code == StatusCode.unauthenticated) {
        _logger.w('Got 401, attempting token refresh...');

        // Try to refresh token
        final newToken = await forceRefresh();

        if (newToken == null) {
          _logger.e('Token refresh failed, re-authentication required');
          throw TokenException('Session expired, please log in again');
        }

        // Retry with new token
        _logger.i('Retrying with refreshed token');
        final options = await getAuthCallOptions(timeout: timeout);
        return await grpcCall(options);
      }
      rethrow;
    }
  }
}

/// Exception thrown when token operations fail
class TokenException implements Exception {
  final String message;

  TokenException(this.message);

  @override
  String toString() => 'TokenException: $message';
}
