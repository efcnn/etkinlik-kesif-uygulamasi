import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/models/event_model.dart';
import 'package:etkinlik_kesif_uygulamasi/features/favorites/data/favorites_local_storage.dart';
import 'package:etkinlik_kesif_uygulamasi/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:etkinlik_kesif_uygulamasi/features/favorites/presentation/screens/favorites_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleEvent = const EventModel(
    id: 'evt-fav-test',
    title: 'Mobil Yaz Kampı',
    category: 'Workshop',
    startDate: '2026-10-25',
    location: 'Lab 1',
    organizer: 'MOBILAB',
    imageUrl: '',
    capacity: 30,
    registeredCount: 15,
    isOnline: false,
    tags: [],
  );

  testWidgets('FavoritesScreen displays empty state when no favorites exist',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = FavoritesLocalStorage();
    final provider = FavoritesProvider(storage: storage);
    await provider.loadFavorites();

    await tester.pumpWidget(
      ChangeNotifierProvider<FavoritesProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: FavoritesScreen(),
        ),
      ),
    );

    expect(find.text('Henüz Favori Etkinliğiniz Yok'), findsOneWidget);
  });

  testWidgets('FavoritesScreen displays favorite card and allows removing it',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = FavoritesLocalStorage();
    final provider = FavoritesProvider(storage: storage);
    await provider.toggleFavorite(sampleEvent);

    await tester.pumpWidget(
      ChangeNotifierProvider<FavoritesProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: FavoritesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initial render
    expect(find.text('Mobil Yaz Kampı'), findsOneWidget);
    expect(find.text('Henüz Favori Etkinliğiniz Yok'), findsNothing);

    // Tap favorite icon to remove
    await tester.tap(find.byIcon(Icons.favorite_rounded));
    await tester.pumpAndSettle();

    // Now empty view appears
    expect(find.text('Henüz Favori Etkinliğiniz Yok'), findsOneWidget);
    expect(find.text('Mobil Yaz Kampı'), findsNothing);
  });
}

