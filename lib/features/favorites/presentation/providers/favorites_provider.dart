import 'package:flutter/foundation.dart';

import '../../../events/data/models/event_model.dart';
import '../../data/favorites_local_storage.dart';

/// Provider for managing favorite events and synchronizing with local storage.
class FavoritesProvider extends ChangeNotifier {
  final FavoritesLocalStorage storage;

  List<EventModel> _favorites = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  FavoritesProvider({required this.storage});

  List<EventModel> get favorites => List.unmodifiable(_favorites);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isEmpty => _favorites.isEmpty;
  int get count => _favorites.length;

  /// Loads saved favorites from SharedPreferences.
  Future<void> loadFavorites({bool force = false}) async {
    if (_isInitialized && !force) return;

    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await storage.getFavorites();
      _isInitialized = true;
    } catch (_) {
      _favorites = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Checks if an event is in the favorites list.
  bool isFavorite(String eventId) {
    return _favorites.any((e) => e.id == eventId);
  }

  /// Toggles favorite status for an event (adds if not present, removes if present).
  Future<void> toggleFavorite(EventModel event) async {
    if (!_isInitialized) {
      await loadFavorites();
    }

    final alreadyFav = isFavorite(event.id);

    if (alreadyFav) {
      _favorites.removeWhere((e) => e.id == event.id);
      notifyListeners();
      await storage.removeFavorite(event.id);
    } else {
      _favorites.insert(0, event);
      notifyListeners();
      await storage.addFavorite(event);
    }
  }
}
