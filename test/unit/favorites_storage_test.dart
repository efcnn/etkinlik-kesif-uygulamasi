import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/models/event_model.dart';
import 'package:etkinlik_kesif_uygulamasi/features/favorites/data/favorites_local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleEvent = const EventModel(
    id: 'fav-1',
    title: 'Flutter Gece Kodu',
    category: 'Hackathon',
    startDate: '2026-10-30',
    location: 'Davutpaşa',
    organizer: 'Sky Lab',
    imageUrl: 'https://example.com/image.png',
    capacity: 100,
    registeredCount: 80,
    isOnline: false,
    tags: ['hackathon'],
  );

  group('FavoritesLocalStorage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('starts with empty list when no preferences saved', () async {
      final storage = FavoritesLocalStorage();
      final list = await storage.getFavorites();
      expect(list, isEmpty);
      expect(await storage.isFavorite('fav-1'), false);
    });

    test('adds event as JSON and persists across instances', () async {
      final storage1 = FavoritesLocalStorage();
      await storage1.addFavorite(sampleEvent);

      expect(await storage1.isFavorite('fav-1'), true);

      // Simulate app restart by instantiating a new storage object
      final storage2 = FavoritesLocalStorage();
      final list = await storage2.getFavorites();

      expect(list.length, 1);
      expect(list.first.id, 'fav-1');
      expect(list.first.title, 'Flutter Gece Kodu');
      expect(list.first.category, 'Hackathon');
    });

    test('removes event by ID and updates storage', () async {
      final storage = FavoritesLocalStorage();
      await storage.addFavorite(sampleEvent);

      expect(await storage.isFavorite('fav-1'), true);

      await storage.removeFavorite('fav-1');
      expect(await storage.isFavorite('fav-1'), false);

      final list = await storage.getFavorites();
      expect(list, isEmpty);
    });

    test('handles corrupted JSON string in SharedPreferences gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'favorite_events_json_list': [
          '{"invalid_json":',
          jsonEncode(sampleEvent.toJson()),
        ],
      });

      final storage = FavoritesLocalStorage();
      final list = await storage.getFavorites();

      // Corrupted item was skipped, valid item was loaded
      expect(list.length, 1);
      expect(list.first.id, 'fav-1');
    });
  });
}

