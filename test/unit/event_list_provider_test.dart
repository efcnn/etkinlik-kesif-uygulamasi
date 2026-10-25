import 'package:flutter_test/flutter_test.dart';
import 'package:etkinlik_kesif_uygulamasi/core/network/api_exception.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/models/event_model.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/repositories/event_repository.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/presentation/providers/event_list_provider.dart';

class MockEventRepository implements EventRepository {
  List<EventModel> eventsToReturn = [];
  Exception? exceptionToThrow;
  Duration delay = Duration.zero;

  @override
  Future<EventListResponse> getEvents({
    String? query,
    String? category,
    bool? isOnline,
    int page = 1,
    int limit = 50,
  }) async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return EventListResponse(
      items: eventsToReturn,
      page: 1,
      limit: limit,
      total: eventsToReturn.length,
      hasMore: false,
    );
  }

  @override
  Future<List<String>> getCategories() async => ['Workshop', 'Sosyal'];

  @override
  Future<EventModel> getEventDetail(String eventId) async {
    return eventsToReturn.firstWhere((e) => e.id == eventId);
  }
}

void main() {
  late MockEventRepository mockRepository;
  late EventListProvider provider;

  final sampleEvent = const EventModel(
    id: 'evt-1',
    title: 'Flutter Test Event',
    category: 'Workshop',
    startDate: '2026-10-21T18:00:00+03:00',
    location: 'Davutpaşa',
    organizer: 'MOBILAB',
    imageUrl: '',
    capacity: 50,
    registeredCount: 20,
    isOnline: false,
    tags: ['flutter'],
  );

  setUp(() {
    mockRepository = MockEventRepository();
    provider = EventListProvider(repository: mockRepository);
  });

  group('EventListProvider Tests', () {
    test('initial state is correct', () {
      expect(provider.status, EventListStatus.initial);
      expect(provider.events, isEmpty);
      expect(provider.errorMessage, isNull);
    });

    test('sets success state when repository returns events', () async {
      mockRepository.eventsToReturn = [sampleEvent];

      await provider.fetchEvents();

      expect(provider.status, EventListStatus.success);
      expect(provider.events.length, 1);
      expect(provider.events.first.id, 'evt-1');
      expect(provider.errorMessage, isNull);
    });

    test('sets empty state when repository returns no events', () async {
      mockRepository.eventsToReturn = [];

      await provider.fetchEvents();

      expect(provider.status, EventListStatus.empty);
      expect(provider.events, isEmpty);
    });

    test('sets error state when repository throws an exception', () async {
      mockRepository.exceptionToThrow = const ServerSideException(
        message: 'Sunucu hatası',
      );

      await provider.fetchEvents();

      expect(provider.status, EventListStatus.error);
      expect(provider.errorMessage, 'Sunucu hatası');
    });

    test('stale response protection drops outdated network responses', () async {
      // First slow request that takes 50ms
      mockRepository.delay = const Duration(milliseconds: 50);
      mockRepository.eventsToReturn = [sampleEvent];

      final firstCall = provider.fetchEvents();

      // Immediately trigger a second faster request with different data
      mockRepository.delay = Duration.zero;
      final fastEvent = sampleEvent.copyWith(id: 'evt-2', title: 'Newer Event');
      mockRepository.eventsToReturn = [fastEvent];

      await provider.fetchEvents();
      await firstCall; // Wait for first call to finish

      // Verify that the newer event is what stays in the provider
      expect(provider.events.first.id, 'evt-2');
      expect(provider.events.first.title, 'Newer Event');
    });
  });
}
