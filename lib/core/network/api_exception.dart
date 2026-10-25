/// Base class for all API-related exceptions.
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Thrown when there is no internet connection or socket failure.
class NetworkConnectionException extends ApiException {
  const NetworkConnectionException([
    super.message = 'İnternet bağlantısı kurulamadı. Lütfen bağlantınızı kontrol edin.',
  ]);
}

/// Thrown when a request exceeds the time limit.
class ApiTimeoutException extends ApiException {
  const ApiTimeoutException([
    super.message = 'Sunucu yanıt vermedi, istek zaman aşımına uğradı. Lütfen tekrar deneyin.',
  ]);
}

/// Thrown when the server responds with 5xx or unexpected server error.
class ServerSideException extends ApiException {
  const ServerSideException({
    String message = 'Sunucuda geçici bir hata oluştu. Lütfen tekrar deneyin.',
    int statusCode = 500,
  }) : super(message, statusCode: statusCode);
}

/// Thrown when a resource (e.g. event) is not found (404).
class NotFoundException extends ApiException {
  const NotFoundException([
    super.message = 'Aradığınız etkinlik bulunamadı.',
  ]) : super(statusCode: 404);
}

/// Thrown when response parsing fails.
class DataParseException extends ApiException {
  const DataParseException([
    super.message = 'Sunucudan gelen veri işlenirken bir sorun oluştu.',
  ]);
}
