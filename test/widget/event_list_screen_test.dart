import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:etkinlik_kesif_uygulamasi/core/network/api_exception.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/models/event_model.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/repositories/event_repository.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/presentation/providers/event_list_provider.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/presentation/screens/event_list_screen.dart';

class MockEventRepository implements EventRepository {
  bool shouldFail = false;
  int fetchCount = 0;

  @override
  Future<EventListResponse> getEvents({
    String? query,
    String? category,
    bool? isOnline,
    int page = 1,
    int limit = 50,
  }) async {
    fetchCount++;
    if (shouldFail) {
      throw const ServerSideException(message: 'Sunucu hatası oluştu');
    }
    return const EventListResponse(
      items: [
        EventModel(
          id: 'test-1',
          title: 'Mobilab Tanışma',
          category: 'Sosyal',
          startDate: '2026-10-21T18:00:00+03:00',
          location: 'Davutpaşa',
          organizer: 'MOBILAB',
          imageUrl: '',
          capacity: 50,
          registeredCount: 10,
          isOnline: false,
          tags: ['tanışma'],
        ),
      ],
      page: 1,
      limit: 50,
      total: 1,
      hasMore: false,
    );
  }

  @override
  Future<List<String>> getCategories() async => ['Sosyal'];

  @override
  Future<EventModel> getEventDetail(String eventId) async {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('EventListScreen displays error view and retries on button press',
      (WidgetTester tester) async {
    final mockRepo = MockEventRepository();
    mockRepo.shouldFail = true;

    final provider = EventListProvider(repository: mockRepo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<EventRepository>.value(value: mockRepo),
          ChangeNotifierProvider<EventListProvider>.value(value: provider),
        ],
        child: const MaterialApp(
          home: EventListScreen(),
        ),
      ),
    );

    // Initial pump and microtasks
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify error message and retry button are visible
    expect(find.text('Bir Sorun Oluştu'), findsOneWidget);
    expect(find.text('Sunucu hatası oluştu'), findsOneWidget);
    expect(find.text('Tekrar Dene'), findsOneWidget);

    // Now make repo succeed and tap Retry
    mockRepo.shouldFail = false;
    await tester.tap(find.text('Tekrar Dene'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify event is loaded and error is gone
    expect(find.text('Mobilab Tanışma'), findsOneWidget);
    expect(find.text('Bir Sorun Oluştu'), findsNothing);
  });
}
