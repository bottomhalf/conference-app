import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for storing sensitive data (tokens, secrets) using
/// platform-level encryption (Keychain on iOS, EncryptedSharedPreferences
/// on Android, DPAPI on Windows).
class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService _instance = SecureStorageService._();
  static SecureStorageService get instance => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ─── Token helpers ─────────────────────────────────────────────

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> setToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  Future<void> setRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> deleteRefreshToken() => _storage.delete(key: _refreshTokenKey);

  // ─── Generic secure key-value ──────────────────────────────────

  Future<void> setSecure(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> getSecure(String key) => _storage.read(key: key);

  Future<void> deleteSecure(String key) => _storage.delete(key: key);

  /// Wipe all secure data (logout).
  Future<void> clearAll() => _storage.deleteAll();
}
