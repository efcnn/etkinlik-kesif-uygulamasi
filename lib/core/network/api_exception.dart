/// İnternet koptuğunda veya sunucu çöktüğünde Flutter'ın karmaşık İngilizce hatalarını kullanıcıya göstermemek için kendi hata sınıflarımızı yazdık:
//Tüm hatalarımızın ата sınıfıdır (abstract class). İçinde Türkçe message ve HTTP statusCode (404, 500 vb.) tutar.
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

// Kullanıcının interneti kapalıysa fırlatılır
class NetworkConnectionException extends ApiException {
  const NetworkConnectionException([
    super.message = 'İnternet bağlantısı kurulamadı. Lütfen bağlantınızı kontrol edin.',
  ]);
}

//Sunucu 10 saniye içinde cevap vermezse fırlatılır
class ApiTimeoutException extends ApiException {
  const ApiTimeoutException([
    super.message = 'Sunucu yanıt vermedi, istek zaman aşımına uğradı. Lütfen tekrar deneyin.',
  ]);
}

//MOBILAB sunucusu rastgele 500 hatası verdiğinde fırlatılır.
class ServerSideException extends ApiException {
  const ServerSideException({
    String message = 'Sunucuda geçici bir hata oluştu. Lütfen tekrar deneyin.',
    int statusCode = 500,
  }) : super(message, statusCode: statusCode);
}

//404 (Etkinlik bulunamadı) durumunda fırlatılır.
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
