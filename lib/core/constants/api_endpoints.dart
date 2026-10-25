class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://mobilab-task-api.vercel.app';
  static const String categories = '$baseUrl/categories';
  static const String events = '$baseUrl/events';

  static String eventDetail(String id) => '$baseUrl/events/$id';
}
