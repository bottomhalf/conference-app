import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Service for storing non-sensitive app state (user profile, meeting
/// preferences, cached API data) using Hive.
class HiveStorageService {
  HiveStorageService._();
  static final HiveStorageService _instance = HiveStorageService._();
  static HiveStorageService get instance => _instance;

  static const String _appBoxName = 'app_storage';

  late Box _appBox;

  /// Must be called once before accessing storage, typically in `main()`.
  Future<void> initialize() async {
    await Hive.initFlutter();
    _appBox = await Hive.openBox(_appBoxName);
  }

  // ─── Generic key-value ─────────────────────────────────────────

  /// Store a value (primitives, List, Map are supported natively).
  Future<void> setValue(String key, dynamic value) => _appBox.put(key, value);

  /// Retrieve a value by key.
  T? getValue<T>(String key) => _appBox.get(key) as T?;

  /// Remove a value by key.
  Future<void> deleteValue(String key) => _appBox.delete(key);

  /// Check if a key exists.
  bool containsKey(String key) => _appBox.containsKey(key);

  // ─── JSON object helpers ───────────────────────────────────────
  // Hive stores Maps natively, but these helpers ensure consistent
  // JSON string serialization for complex model objects.

  /// Store a JSON-serializable object as a JSON string.
  Future<void> setObject(String key, Map<String, dynamic> object) =>
      _appBox.put(key, jsonEncode(object));

  /// Retrieve a previously stored JSON object.
  Map<String, dynamic>? getObject(String key) {
    final raw = _appBox.get(key);
    if (raw == null) return null;
    if (raw is String) return jsonDecode(raw) as Map<String, dynamic>;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  /// Wipe all app data (logout).
  Future<void> clearAll() => _appBox.clear();
}
