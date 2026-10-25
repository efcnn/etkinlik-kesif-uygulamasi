import 'package:flutter_test/flutter_test.dart';
import 'package:etkinlik_kesif_uygulamasi/core/network/api_exception.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/models/event_model.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/repositories/event_repository.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/presentation/providers/event_list_provider.dart';

class MockEventRepository implements EventRepository {
  List<EventModel> eventsToReturn = [];
  Map<int, List<EventModel>> pagedEvents = {};
  bool hasMoreToReturn = false;
  int totalToReturn = 0;
  Exception? exceptionToThrow;
  Duration delay = Duration.zero;
  String? lastPassedCategory;
  String? lastPassedQuery;
  int? lastPassedPage;
  int? lastPassedLimit;

  @override
  Future<EventListResponse> getEvents({
    String? query,
    String? category,
    bool? isOnline,
    int page = 1,
    int limit = 50,
  }) async {
    lastPassedQuery = query;
    lastPassedCategory = category;
    lastPassedPage = page;
    lastPassedLimit = limit;
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    final items = pagedEvents.containsKey(page) ? pagedEvents[page]! : eventsToReturn;
    return EventListResponse(
      items: items,
      page: page,
      limit: limit,
      total: totalToReturn > 0 ? totalToReturn : items.length,
      hasMore: hasMoreToReturn,
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

  tearDown(() {
    provider.dispose();
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

    test('fetches and populates categories', () async {
      await provider.fetchCategories();
      expect(provider.categories, ['Workshop', 'Sosyal']);
    });

    test('category selection triggers event fetch with category parameter', () async {
      provider.setCategory('Workshop');
      await Future.delayed(Duration.zero);

      expect(provider.selectedCategory, 'Workshop');
      expect(mockRepository.lastPassedCategory, 'Workshop');

      // Selecting 'Tümü' passes null to repository
      provider.setCategory('Tümü');
      await Future.delayed(Duration.zero);
      expect(provider.selectedCategory, isNull);
      expect(mockRepository.lastPassedCategory, isNull);
    });

    test('onSearchChanged debounces input before querying repository', () async {
      mockRepository.eventsToReturn = [sampleEvent];

      provider.onSearchChanged('flut', debounceDuration: const Duration(milliseconds: 50));
      // Immediately before debounce fires
      expect(provider.searchQuery, '');

      // Wait for debounce timer to fire
      await Future.delayed(const Duration(milliseconds: 60));
      expect(provider.searchQuery, 'flut');
      expect(mockRepository.lastPassedQuery, 'flut');
    });

    test('clearFilters resets search and category and refetches', () async {
      provider.setCategory('Sosyal');
      provider.setSearchQuery('kahvaltı');

      expect(provider.isFiltering, true);

      provider.clearFilters();

      expect(provider.searchQuery, '');
      expect(provider.selectedCategory, isNull);
      expect(provider.isFiltering, false);
    });

    test('loadMoreEvents appends next page and updates hasMore', () async {
      final event2 = sampleEvent.copyWith(id: 'evt-2', title: 'Second Page Event');
      mockRepository.pagedEvents = {
        1: [sampleEvent],
        2: [event2],
      };
      mockRepository.hasMoreToReturn = true;
      mockRepository.totalToReturn = 2;

      await provider.fetchEvents();
      expect(provider.events.length, 1);
      expect(provider.currentPage, 1);
      expect(provider.hasMore, true);

      // Now load page 2 where hasMore becomes false
      mockRepository.hasMoreToReturn = false;
      await provider.loadMoreEvents();

      expect(provider.events.length, 2);
      expect(provider.events.last.id, 'evt-2');
      expect(provider.currentPage, 2);
      expect(provider.hasMore, false);
      expect(provider.totalCount, 2);
    });

    test('loadMoreEvents keeps existing events and sets loadMoreError if page 2 fails', () async {
      mockRepository.eventsToReturn = [sampleEvent];
      mockRepository.hasMoreToReturn = true;

      await provider.fetchEvents();
      expect(provider.events.length, 1);

      // Simulate server error on page 2
      mockRepository.exceptionToThrow = const ServerSideException(
        message: 'Sayfa 2 yüklenemedi',
      );
      await provider.loadMoreEvents();

      // Page 1 events remain intact, status is still success, loadMoreError is populated
      expect(provider.status, EventListStatus.success);
      expect(provider.events.length, 1);
      expect(provider.loadMoreError, 'Sayfa 2 yüklenemedi');
    });
  });
}
