/// Typed model matching the backend's standard `ResponseModel`.
///
/// Every API endpoint returns this wrapper. The actual payload lives
/// in [responseBody]. Optional error fields are populated on failure.
class ApiResponse {
  final String? accessToken;
  final int httpStatusCode;
  final String httpStatusMessage;
  final dynamic responseBody;
  final String? errorCode;
  final String? errorMessage;
  final bool? isSuccess;
  final String? message;

  ApiResponse({
    this.accessToken,
    required this.httpStatusCode,
    required this.httpStatusMessage,
    this.responseBody,
    this.errorCode,
    this.errorMessage,
    this.isSuccess,
    this.message,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var statusCode = json['HttpStatusCode'] as int?;
    int code = 0;
    try {
      code = statusCode != null && statusCode == 200 ? 200 : 400;
    } catch (e) {
      code = 400;
    }
    return ApiResponse(
      accessToken: json['AccessToken'] as String?,
      httpStatusCode: code,
      httpStatusMessage: json['HttpStatusMessage'] as String? ?? '',
      responseBody: json['ResponseBody'],
      errorCode: json['ErrorCode'] as String?,
      errorMessage: json['ErrorMessage'] as String?,
      isSuccess: code == 200,
      message: json['Message'] as String?,
    );
  }

  /// Whether the API call was logically successful.
  bool get success => isSuccess == true;

  /// Human-readable error string — prefers [errorMessage], falls back to
  /// [message], then [httpStatusMessage].
  String get error =>
      (errorMessage?.isNotEmpty == true ? errorMessage : null) ??
      (message?.isNotEmpty == true ? message : null) ??
      httpStatusMessage;
}
