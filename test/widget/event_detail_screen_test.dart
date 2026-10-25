import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:etkinlik_kesif_uygulamasi/core/network/api_exception.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/models/event_model.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/repositories/event_repository.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/presentation/screens/event_detail_screen.dart';

class MockEventRepository implements EventRepository {
  bool shouldFail = false;

  @override
  Future<EventModel> getEventDetail(String eventId) async {
    if (shouldFail) {
      throw const ServerSideException(message: 'Açıklama alınamadı.');
    }
    return const EventModel(
      id: 'evt-test-10',
      title: 'Hackathon 2026',
      description: 'Yazılım maratonu tüm hızıyla başlıyor!',
      category: 'Hackathon',
      startDate: '2026-10-30T20:00:00+03:00',
      location: 'Kongre Merkezi',
      organizer: 'Sky Lab',
      imageUrl: '',
      capacity: 100,
      registeredCount: 85,
      isOnline: false,
      tags: ['kodlama'],
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
  const initialEvent = EventModel(
    id: 'evt-test-10',
    title: 'Hackathon 2026',
    category: 'Hackathon',
    startDate: '2026-10-30T20:00:00+03:00',
    location: 'Kongre Merkezi',
    organizer: 'Sky Lab',
    imageUrl: '',
    capacity: 100,
    registeredCount: 85,
    isOnline: false,
    tags: ['kodlama'],
  );

  testWidgets('EventDetailScreen immediately renders initial details',
      (WidgetTester tester) async {
    final mockRepo = MockEventRepository();

    await tester.pumpWidget(
      Provider<EventRepository>.value(
        value: mockRepo,
        child: const MaterialApp(
          home: EventDetailScreen(initialEvent: initialEvent),
        ),
      ),
    );

    // Initial render before network completes
    expect(find.text('Hackathon 2026'), findsWidgets);
    expect(find.text('Kongre Merkezi'), findsOneWidget);
    expect(find.text('Sky Lab'), findsOneWidget);
    expect(find.text('#kodlama'), findsOneWidget);

    // Let the async fetch complete
    await tester.pumpAndSettle();

    expect(find.text('Yazılım maratonu tüm hızıyla başlıyor!'), findsOneWidget);
  });

  testWidgets('EventDetailScreen keeps main details visible and shows isolated retry if description fails',
      (WidgetTester tester) async {
    final mockRepo = MockEventRepository();
    mockRepo.shouldFail = true;

    await tester.pumpWidget(
      Provider<EventRepository>.value(
        value: mockRepo,
        child: const MaterialApp(
          home: EventDetailScreen(initialEvent: initialEvent),
        ),
      ),
    );

    // Settle to let the failed description call return
    await tester.pumpAndSettle();

    // Event title and details remain intact!
    expect(find.text('Hackathon 2026'), findsWidgets);
    expect(find.text('Kongre Merkezi'), findsOneWidget);
    expect(find.text('Sky Lab'), findsOneWidget);

    // Only the description section shows the error and retry button
    expect(find.text('Açıklama alınamadı.'), findsOneWidget);
    expect(find.text('Tekrar Dene'), findsOneWidget);

    // Scroll until retry button is visible, then tap
    await tester.scrollUntilVisible(find.text('Tekrar Dene'), 50.0);
    mockRepo.shouldFail = false;
    await tester.tap(find.text('Tekrar Dene'));
    await tester.pumpAndSettle();

    // Error is gone, description is now displayed!
    expect(find.text('Açıklama alınamadı.'), findsNothing);
    expect(find.text('Yazılım maratonu tüm hızıyla başlıyor!'), findsOneWidget);
  });
}

