import 'dart:async'; //Zaman aşımı hatasını (TimeoutException) ve Future.delayed (bekleme) fonksiyonunu kullanmak için.
import 'dart:convert'; //Sunucudan gelen JSON metnini Dart nesnesine çeviren
import 'dart:io';//İnternet bağlantısı koptuğunda işletim sisteminin fırlattığı SocketException hatasını yakalamak için.

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Lightweight HTTP client wrapper with configurable timeout, automatic retry on 500 errors,
/// and mapping to user-friendly [ApiException]s.
class ApiClient {
  final http.Client _client;
  final Duration timeoutDuration;
  final int maxRetries;

  ApiClient({
    http.Client? client,
    this.timeoutDuration = const Duration(seconds: 10),
    this.maxRetries = 2,
  }) : _client = client ?? http.Client();

  /// Performs a GET request with auto-retry on 500 errors.
  Future<dynamic> get(Uri uri) async {
    int attempts = 0;

    while (true) {
      attempts++;
      try {
        final response = await _client
            .get(
              uri,
              headers: {'Accept': 'application/json'},
            )
            .timeout(timeoutDuration);

        final statusCode = response.statusCode;

        if (statusCode >= 200 && statusCode < 300) {
          return _decodeBody(response.body);
        }

        // If the server returns a 500 error, try again if retries left
        if (statusCode >= 500 && attempts <= maxRetries) {
          await Future.delayed(Duration(milliseconds: 400 * attempts));
          continue;
        }

        if (statusCode == 404) {
          throw const NotFoundException();
        }

        if (statusCode >= 500) {
          throw const ServerSideException();
        }

        throw ServerSideException(
          message: 'Beklenmeyen bir sunucu yanıtı alındı ($statusCode).',
          statusCode: statusCode,
        );
      } on SocketException {
        throw const NetworkConnectionException();
      } on http.ClientException {
        throw const NetworkConnectionException();
      } on TimeoutException {
        // If we still have retry attempts for timeouts, we could retry or fail
        if (attempts <= maxRetries) {
          await Future.delayed(Duration(milliseconds: 400 * attempts));
          continue;
        }
        throw const ApiTimeoutException();
      } on FormatException {
        throw const DataParseException();
      }
    }
  }

  dynamic _decodeBody(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      throw const DataParseException();
    }
  }

  void close() {
    _client.close();
  }
}

