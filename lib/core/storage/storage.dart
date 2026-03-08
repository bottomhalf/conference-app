import 'hive_storage_service.dart';
import 'secure_storage_service.dart';

/// Unified storage facade — single entry point for all local storage.
///
/// Delegates to [SecureStorageService] for sensitive data (tokens) and
/// [HiveStorageService] for app state (user profile, preferences, cache).
///
/// ```dart
/// await StorageService.instance.initialize();
/// await StorageService.instance.setToken('jwt...');
/// final token = await StorageService.instance.getToken();
/// await StorageService.instance.setValue('theme', 'dark');
/// final theme = StorageService.instance.getValue<String>('theme');
/// ```
class StorageService {
  StorageService._();
  static final StorageService _instance = StorageService._();
  static StorageService get instance => _instance;

  final SecureStorageService _secure = SecureStorageService.instance;
  final HiveStorageService _hive = HiveStorageService.instance;

  /// Initialize Hive. Call once in `main()` before `runApp`.
  /// (SecureStorage doesn't need explicit initialization.)
  Future<void> initialize() async {
    await _hive.initialize();
  }

  // ─── Token (secure) ────────────────────────────────────────────

  /// Store the auth token securely.
  Future<void> setToken(String token) => _secure.setToken(token);

  /// Retrieve the auth token.
  Future<String?> getToken() => _secure.getToken();

  /// Delete the auth token.
  Future<void> deleteToken() => _secure.deleteToken();

  /// Store the refresh token securely.
  Future<void> setRefreshToken(String token) => _secure.setRefreshToken(token);

  /// Retrieve the refresh token.
  Future<String?> getRefreshToken() => _secure.getRefreshToken();

  // ─── Key-Value (Hive) ──────────────────────────────────────────

  /// Store a value (primitives, List, Map).
  Future<void> setValue(String key, dynamic value) =>
      _hive.setValue(key, value);

  /// Retrieve a value by key.
  T? getValue<T>(String key) => _hive.getValue<T>(key);

  /// Remove a value by key.
  Future<void> deleteValue(String key) => _hive.deleteValue(key);

  /// Check if a key exists.
  bool containsKey(String key) => _hive.containsKey(key);

  // ─── JSON Object (Hive) ────────────────────────────────────────

  /// Store a JSON-serializable object.
  Future<void> setObject(String key, Map<String, dynamic> object) =>
      _hive.setObject(key, object);

  /// Retrieve a previously stored JSON object.
  Map<String, dynamic>? getObject(String key) => _hive.getObject(key);

  // ─── Logout ────────────────────────────────────────────────────

  /// Wipe all local data (tokens + app state).
  Future<void> clearAll() async {
    await _secure.clearAll();
    await _hive.clearAll();
  }
}
