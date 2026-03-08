import 'api_response.dart';

/// Exception thrown when the API returns a non-success response.
///
/// Controllers can catch this to display the [message] to the user,
/// or let the global error handler deal with it.
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? errorCode;
  final ApiResponse? apiResponse;

  ApiException({
    required this.message,
    required this.statusCode,
    this.errorCode,
    this.apiResponse,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}
