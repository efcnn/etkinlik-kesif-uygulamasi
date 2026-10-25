import 'package:flutter_test/flutter_test.dart';
import 'package:etkinlik_kesif_uygulamasi/core/network/api_exception.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/models/event_model.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/repositories/event_repository.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/presentation/providers/event_detail_provider.dart';

class MockEventRepository implements EventRepository {
  EventModel? detailToReturn;
  Exception? exceptionToThrow;

  @override
  Future<EventModel> getEventDetail(String eventId) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return detailToReturn ??
        EventModel(
          id: eventId,
          title: 'Detay Başlık',
          description: 'Apiden gelen detay açıklama',
          category: 'Workshop',
          startDate: '2026-10-21',
          location: 'Salon B',
          organizer: 'MOBILAB',
          imageUrl: '',
          capacity: 50,
          registeredCount: 10,
          isOnline: false,
          tags: [],
        );
  }

  @override
  Future<List<String>> getCategories() async => [];

  @override
  Future<EventListResponse> getEvents({
    String? query,
    String? category,
    bool? isOnline,
    int page = 1,
    int limit = 50,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  late MockEventRepository mockRepository;
  const initialEvent = EventModel(
    id: 'evt-001',
    title: 'İlk Başlık',
    category: 'Workshop',
    startDate: '2026-10-21',
    location: 'Salon A',
    organizer: 'MOBILAB',
    imageUrl: '',
    capacity: 40,
    registeredCount: 20,
    isOnline: false,
    tags: ['tag1'],
  );

  setUp(() {
    mockRepository = MockEventRepository();
  });

  group('EventDetailProvider Tests', () {
    test('initial state has event without description', () {
      final provider = EventDetailProvider(
        repository: mockRepository,
        initialEvent: initialEvent,
      );

      expect(provider.event.id, 'evt-001');
      expect(provider.event.title, 'İlk Başlık');
      expect(provider.event.description, isNull);
      expect(provider.isLoadingDescription, false);
      expect(provider.descriptionError, isNull);
    });

    test('fetchDescription populates description on success', () async {
      final provider = EventDetailProvider(
        repository: mockRepository,
        initialEvent: initialEvent,
      );

      await provider.fetchDescription();

      expect(provider.isLoadingDescription, false);
      expect(provider.descriptionError, isNull);
      expect(provider.event.description, 'Apiden gelen detay açıklama');
      // Preserves original fields
      expect(provider.event.title, 'İlk Başlık');
    });

    test('fetchDescription keeps original event and sets descriptionError on failure', () async {
      mockRepository.exceptionToThrow = const ServerSideException(
        message: 'Açıklama sunucu hatası',
      );

      final provider = EventDetailProvider(
        repository: mockRepository,
        initialEvent: initialEvent,
      );

      await provider.fetchDescription();

      expect(provider.isLoadingDescription, false);
      expect(provider.descriptionError, 'Açıklama sunucu hatası');
      // Event itself is intact!
      expect(provider.event.title, 'İlk Başlık');
      expect(provider.event.location, 'Salon A');
    });

    test('toggleDescriptionExpanded toggles boolean state', () {
      final provider = EventDetailProvider(
        repository: mockRepository,
        initialEvent: initialEvent,
      );

      expect(provider.isDescriptionExpanded, false);
      provider.toggleDescriptionExpanded();
      expect(provider.isDescriptionExpanded, true);
      provider.toggleDescriptionExpanded();
      expect(provider.isDescriptionExpanded, false);
    });
  });
}

