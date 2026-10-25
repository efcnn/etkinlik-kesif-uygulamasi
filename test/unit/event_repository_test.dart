import 'package:flutter_test/flutter_test.dart';
import 'package:etkinlik_kesif_uygulamasi/core/network/api_client.dart';
import 'package:etkinlik_kesif_uygulamasi/core/network/api_exception.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/repositories/event_repository.dart';

class FakeApiClient extends ApiClient {
  dynamic responseToReturn;
  ApiException? exceptionToThrow;
  Uri? lastUri;

  @override
  Future<dynamic> get(Uri uri) async {
    lastUri = uri;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return responseToReturn;
  }
}

void main() {
  late FakeApiClient fakeClient;
  late EventRepository repository;

  setUp(() {
    fakeClient = FakeApiClient();
    repository = EventRepository(apiClient: fakeClient);
  });

  group('EventRepository Tests', () {
    test('getCategories returns list of category strings', () async {
      fakeClient.responseToReturn = {
        'items': ['Workshop', 'Hackathon', 'Panel']
      };

      final categories = await repository.getCategories();

      expect(categories, ['Workshop', 'Hackathon', 'Panel']);
      expect(fakeClient.lastUri?.path, contains('/categories'));
    });

    test('getCategories throws DataParseException on invalid format', () async {
      fakeClient.responseToReturn = 'not a map';

      expect(
        () => repository.getCategories(),
        throwsA(isA<DataParseException>()),
      );
    });

    test('getEvents builds correct query parameters and parses response', () async {
      fakeClient.responseToReturn = {
        'items': [
          {
            'id': 'evt-1',
            'title': 'Test Etkinlik',
            'category': 'Workshop',
            'startDate': '2026-10-21',
            'location': 'Davutpaşa',
            'organizer': 'MOBILAB',
            'imageUrl': '',
            'capacity': 50,
            'registeredCount': 25,
            'isOnline': false,
            'tags': ['flutter'],
          }
        ],
        'page': 1,
        'limit': 50,
        'total': 1,
        'hasMore': false,
      };

      final response = await repository.getEvents(
        query: 'flutter',
        category: 'Workshop',
        isOnline: true,
        limit: 50,
      );

      expect(response.items.length, 1);
      expect(response.items.first.title, 'Test Etkinlik');
      expect(fakeClient.lastUri?.queryParameters['q'], 'flutter');
      expect(fakeClient.lastUri?.queryParameters['category'], 'Workshop');
      expect(fakeClient.lastUri?.queryParameters['online'], 'true');
      expect(fakeClient.lastUri?.queryParameters['limit'], '50');
    });

    test('getEventDetail fetches and parses single event detail', () async {
      fakeClient.responseToReturn = {
        'id': 'evt-99',
        'title': 'Detaylı Etkinlik',
        'description': 'Uzun etkinlik açıklaması',
        'category': 'Seminer',
        'startDate': '2026-11-01',
        'location': 'Kongre',
        'organizer': 'Sky Lab',
        'imageUrl': '',
        'capacity': 100,
        'registeredCount': 80,
        'isOnline': false,
        'tags': ['seminer'],
      };

      final event = await repository.getEventDetail('evt-99');

      expect(event.id, 'evt-99');
      expect(event.description, 'Uzun etkinlik açıklaması');
      expect(fakeClient.lastUri?.path, contains('/events/evt-99'));
    });
  });
}

