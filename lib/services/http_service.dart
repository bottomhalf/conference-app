import 'dart:async';
import 'dart:convert';
import 'package:conference/core/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/api_exception.dart';
import '../models/api_response.dart';

/// Centralized HTTP service — all REST calls go through here.
///
/// Every public method (`get`, `post`, `put`, `delete`) automatically:
/// 1. Prepends [AppConfig.apiBaseUrl]
/// 2. Attaches JSON headers + auth token
/// 3. Parses the response through [ApiResponse]
/// 4. Returns only [ApiResponse.responseBody] on success
/// 5. Throws [ApiException] on failure
class HttpService {
  // ─── Singleton ──────────────────────────────────────────────────
  HttpService._();
  static final HttpService _instance = HttpService._();
  static HttpService get instance => _instance;

  // ─── State ──────────────────────────────────────────────────────
  String? _authToken;
  late final http.Client _client = http.Client();
  final SecureStorageService _secureStorage = SecureStorageService.instance;

  /// Load token from secure storage into memory.
  /// Call once at app startup (in `main()`).
  Future<void> initialize() async {
    _authToken = await _secureStorage.getToken();
  }

  /// Store the auth token — saves to both memory and secure storage.
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    await _secureStorage.setToken(token);
  }

  /// Clear the auth token (on logout).
  Future<void> clearAuthToken() async {
    _authToken = null;
    await _secureStorage.deleteToken();
  }

  /// Whether the user is currently authenticated.
  bool get isAuthenticated => _authToken != null;

  /// Current auth token (read-only, synchronous).
  String? get authToken => _authToken;

  // ─── Helpers ────────────────────────────────────────────────────
  String get _baseUrl => AppConfig.instance.apiBaseUrl;

  Duration get _timeout =>
      Duration(seconds: AppConfig.instance.connectionTimeout);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Uri _uri(String path, [Map<String, String>? queryParams]) =>
      Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);

  void _log(String method, String path, int statusCode) {
    if (AppConfig.instance.enableLogs) {
      debugPrint('[$method] $path → $statusCode');
    }
  }

  /// Parse the raw [http.Response] into an [ApiResponse], validate success,
  /// and return only the `ResponseBody`.
  ///
  /// Throws [ApiException] if the HTTP status is not 200 or if
  /// `IsSuccess` is explicitly `false`.
  ApiResponse _processResponse(
    http.Response response,
    String method,
    String path,
  ) {
    _log(method, path, response.statusCode);

    // Non-200 HTTP status — network / server error
    if (response.statusCode != 200) {
      // Try to parse the body for error details
      try {
        final apiResponse = ApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        throw ApiException(
          message: apiResponse.error,
          statusCode: response.statusCode,
          errorCode: apiResponse.errorCode,
          apiResponse: apiResponse,
        );
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(
          message: 'Server error (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    }

    // 200 — parse the standard response envelope
    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse.fromJson(json);

    // If the backend explicitly says it's not successful
    if (apiResponse.isSuccess == false) {
      throw ApiException(
        message: apiResponse.error,
        statusCode: apiResponse.httpStatusCode,
        errorCode: apiResponse.errorCode,
        apiResponse: apiResponse,
      );
    }

    return apiResponse;
  }

  // ─── Public API ─────────────────────────────────────────────────

  Future<String> getMeetingToken(
    String roomName,
    String participantName,
  ) async {
    var response = await post(
      'conference/token',
      body: {'roomName': roomName, 'participantName': participantName},
    );
    return response.accessToken;
  }

  /// HTTP POST (LOGIN) — returns `ResponseBody` on success.
  ///
  /// Throws [ApiException] on failure.
  Future<dynamic> login(String path, {Object? body}) async {
    final response = await _client
        .post(
          _uri(path),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_timeout);
    var apiResponse = _processResponse(response, 'POST', path);

    // Auto-store the access token if present
    if (apiResponse.accessToken != null &&
        apiResponse.accessToken!.isNotEmpty) {
      setAuthToken(apiResponse.accessToken!);
      _secureStorage.setToken(apiResponse.accessToken!);
    }

    return apiResponse.responseBody;
  }

  /// HTTP GET — returns `ResponseBody` on success.
  ///
  /// Throws [ApiException] on failure.
  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final response = await _client
        .get(_uri(path, queryParams), headers: _headers)
        .timeout(_timeout);
    return _processResponse(response, 'GET', path);
  }

  /// HTTP POST — returns `ResponseBody` on success.
  ///
  /// Throws [ApiException] on failure.
  Future<dynamic> post(String path, {Object? body}) async {
    final response = await _client
        .post(
          _uri(path),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_timeout);
    return _processResponse(response, 'POST', path);
  }

  /// HTTP PUT — returns `ResponseBody` on success.
  ///
  /// Throws [ApiException] on failure.
  Future<dynamic> put(String path, {Object? body}) async {
    final response = await _client
        .put(
          _uri(path),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_timeout);
    return _processResponse(response, 'PUT', path);
  }

  /// HTTP DELETE — returns `ResponseBody` on success.
  ///
  /// Throws [ApiException] on failure.
  Future<dynamic> delete(String path) async {
    final response = await _client
        .delete(_uri(path), headers: _headers)
        .timeout(_timeout);
    return _processResponse(response, 'DELETE', path);
  }

  /// Dispose the underlying HTTP client.
  void dispose() => _client.close();
}
