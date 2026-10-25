import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/models/event_model.dart';
import 'package:etkinlik_kesif_uygulamasi/features/favorites/data/favorites_local_storage.dart';
import 'package:etkinlik_kesif_uygulamasi/features/favorites/presentation/providers/favorites_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleEvent = const EventModel(
    id: 'fav-2',
    title: 'Seminer Etkinliği',
    category: 'Seminer',
    startDate: '2026-11-05',
    location: 'A-201',
    organizer: 'MOBILAB',
    imageUrl: '',
    capacity: 60,
    registeredCount: 40,
    isOnline: false,
    tags: ['seminer'],
  );

  group('FavoritesProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('toggling favorite adds and removes properly', () async {
      final storage = FavoritesLocalStorage();
      final provider = FavoritesProvider(storage: storage);

      await provider.loadFavorites();
      expect(provider.isEmpty, true);
      expect(provider.count, 0);

      // Add to favorites
      await provider.toggleFavorite(sampleEvent);
      expect(provider.isFavorite('fav-2'), true);
      expect(provider.count, 1);
      expect(provider.favorites.first.title, 'Seminer Etkinliği');

      // Remove from favorites
      await provider.toggleFavorite(sampleEvent);
      expect(provider.isFavorite('fav-2'), false);
      expect(provider.count, 0);
      expect(provider.isEmpty, true);
    });
  });
}

