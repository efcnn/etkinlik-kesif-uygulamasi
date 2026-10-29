import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:etkinlik_kesif_uygulamasi/core/theme/app_colors.dart';
import 'package:etkinlik_kesif_uygulamasi/core/theme/theme_provider.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/models/event_model.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/repositories/event_repository.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/presentation/providers/event_list_provider.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/presentation/screens/event_detail_screen.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/presentation/screens/event_list_screen.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/presentation/widgets/skeleton_loading_view.dart';
import 'package:etkinlik_kesif_uygulamasi/features/favorites/data/favorites_local_storage.dart';
import 'package:etkinlik_kesif_uygulamasi/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:etkinlik_kesif_uygulamasi/shared/widgets/animated_favorite_button.dart';
import 'package:etkinlik_kesif_uygulamasi/shared/widgets/event_network_image.dart';

class LongTextMockRepository implements EventRepository {
  @override
  Future<List<String>> getCategories() async => [
        'Çok Uzun Bir Kategori İsmi Testi',
        'Workshop',
      ];

  @override
  Future<EventListResponse> getEvents({
    String? query,
    String? category,
    bool? isOnline,
    int page = 1,
    int limit = 50,
  }) async {
    return const EventListResponse(
      items: [
        EventModel(
          id: 'evt-long-1',
          title:
              'Çok Uzun Bir Etkinlik Başlığı Taşma Kontrolü İçin Özel Olarak Oluşturuldu Ve Test Ediliyor',
          category: 'Çok Uzun Bir Kategori İsmi Testi',
          startDate: '2026-10-21T18:00:00+03:00',
          endDate: '2026-10-21T20:00:00+03:00',
          location:
              'Davutpaşa Kampüsü Elektrik Elektronik Fakültesi Büyük Konferans Salonu Kat 3 Oda 302',
          organizer: 'Uluslararası Mobil Uygulama Geliştirme Kulübü Topluluğu',
          imageUrl: '',
          capacity: 500,
          registeredCount: 450,
          isOnline: true,
          tags: ['uzunetiket1', 'uzunetiket2', 'flutter_overflow_test'],
        ),
      ],
      page: 1,
      limit: 50,
      total: 1,
      hasMore: false,
    );
  }

  @override
  Future<EventModel> getEventDetail(String eventId) async {
    return const EventModel(
      id: 'evt-long-1',
      title: 'Uzun Başlık',
      description: 'Açıklama metni detayı.',
      category: 'Workshop',
      startDate: '2026-10-21T18:00:00+03:00',
      location: 'Davutpaşa',
      organizer: 'MOBILAB',
      imageUrl: '',
      capacity: 100,
      registeredCount: 50,
      isOnline: true,
      tags: [],
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('EventSkeletonView renders shimmer placeholders cleanly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EventSkeletonView(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(EventSkeletonView), findsOneWidget);
  });

  testWidgets('EventNetworkImage displays fallback icon when URL is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EventNetworkImage(
            imageUrl: '',
            width: 100,
            height: 100,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.event_available_rounded), findsOneWidget);
  });

  testWidgets('Small screen (320x568) renders EventListScreen with long texts without overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = LongTextMockRepository();
    final listProvider = EventListProvider(repository: repo);
    final favProvider = FavoritesProvider(storage: FavoritesLocalStorage());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<EventRepository>.value(value: repo),
          ChangeNotifierProvider<EventListProvider>.value(value: listProvider),
          ChangeNotifierProvider<FavoritesProvider>.value(value: favProvider),
        ],
        child: const MaterialApp(
          home: EventListScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify no overflow exceptions occurred and content is rendered
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Çok Uzun Bir Etkinlik Başlığı'), findsWidgets);
  });

  testWidgets('Small screen (320x568) renders EventDetailScreen with long texts without overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = LongTextMockRepository();
    final favProvider = FavoritesProvider(storage: FavoritesLocalStorage());
    final longEvent = (await repo.getEvents()).items.first;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<EventRepository>.value(value: repo),
          ChangeNotifierProvider<FavoritesProvider>.value(value: favProvider),
        ],
        child: MaterialApp(
          home: EventDetailScreen(initialEvent: longEvent),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });

  testWidgets('AnimatedFavoriteButton animates icon change on toggle',
      (WidgetTester tester) async {
    bool isFav = false;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Scaffold(
              body: AnimatedFavoriteButton(
                isFavorite: isFav,
                onTap: () => setState(() => isFav = !isFav),
              ),
            ),
          );
        },
      ),
    );

    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

    await tester.tap(find.byType(AnimatedFavoriteButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });

  testWidgets('Tapping theme toggle button immediately updates EventListScreen background color',
      (WidgetTester tester) async {
    final repo = LongTextMockRepository();
    final listProvider = EventListProvider(repository: repo);
    final favProvider = FavoritesProvider(storage: FavoritesLocalStorage());
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<EventRepository>.value(value: repo),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider<EventListProvider>.value(value: listProvider),
          ChangeNotifierProvider<FavoritesProvider>.value(value: favProvider),
        ],
        child: const MaterialApp(
          home: EventListScreen(),
        ),
      ),
    );

    await tester.pump();

    // Initially Dark Mode
    Scaffold scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppColors.darkBackground);

    // Tap the theme toggle icon button
    await tester.tap(find.byIcon(Icons.light_mode_rounded));
    await tester.pump();

    // Verify EventListScreen immediately rebuilt with Light Mode background
    scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppColors.lightBackground);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
  });
}

