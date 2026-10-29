////ApiEndpoints, ApiClient ve EventModel parçalarını birleştiren dosyadır:
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/event_model.dart';

class EventRepository {
  final ApiClient _apiClient;

  EventRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches all categories from `/categories`.
  Future<List<String>> getCategories() async {
    final uri = Uri.parse(ApiEndpoints.categories);
    final response = await _apiClient.get(uri);

    if (response is Map<String, dynamic> && response['items'] is List) {
      return (response['items'] as List)
          .map((e) => e.toString())
          .toList();
    }
    throw const DataParseException('Kategori listesi beklenmeyen bir formatta döndü.');
  }

  /// Fetches events from `/events` with optional search, category, online filters,
  /// and pagination parameters (defaults to limit=50 in Phase 1 to fetch all events).
  Future<EventListResponse> getEvents({
    String? query,
    String? category,
    bool? isOnline,
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (query != null && query.trim().isNotEmpty) {
      queryParams['q'] = query.trim();
    }

    if (category != null && category.trim().isNotEmpty && category.trim() != 'Tümü') {
      queryParams['category'] = category.trim();
    }

    if (isOnline != null) {
      queryParams['online'] = isOnline.toString();
    }

    final uri = Uri.parse(ApiEndpoints.events).replace(queryParameters: queryParams);
    final response = await _apiClient.get(uri);

    if (response is Map<String, dynamic>) {
      return EventListResponse.fromJson(response);
    }
    throw const DataParseException('Etkinlik listesi beklenmeyen bir formatta döndü.');
  }

  /// Fetches a single event's details (including [description]) from `/events/{id}`.
  Future<EventModel> getEventDetail(String eventId) async {
    final uri = Uri.parse(ApiEndpoints.eventDetail(eventId));
    final response = await _apiClient.get(uri);

    if (response is Map<String, dynamic>) {
      return EventModel.fromJson(response);
    }
    throw const DataParseException('Etkinlik detayı beklenmeyen bir formatta döndü.');
  }
}

