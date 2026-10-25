import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../events/data/models/event_model.dart';

/// Handles offline local persistence of favorite events in SharedPreferences as JSON strings.
class FavoritesLocalStorage {
  static const String _key = 'favorite_events_json_list';
  final SharedPreferences? prefs;

  FavoritesLocalStorage({this.prefs});

  Future<SharedPreferences> get _instance async =>
      prefs ?? await SharedPreferences.getInstance();

  /// Loads all saved favorite events from local storage.
  /// Works completely offline without needing the API.
  Future<List<EventModel>> getFavorites() async {
    final prefs = await _instance;
    final jsonList = prefs.getStringList(_key) ?? [];

    final events = <EventModel>[];
    for (final jsonStr in jsonList) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        events.add(EventModel.fromJson(map));
      } catch (_) {
        // Skip malformed entries safely
      }
    }
    return events;
  }

  /// Adds an event to local favorites.
  Future<void> addFavorite(EventModel event) async {
    final prefs = await _instance;
    final events = await getFavorites();

    // Avoid duplicate IDs
    events.removeWhere((e) => e.id == event.id);
    events.insert(0, event);

    final rawList = events.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, rawList);
  }

  /// Removes an event from local favorites by ID.
  Future<void> removeFavorite(String eventId) async {
    final prefs = await _instance;
    final events = await getFavorites();

    events.removeWhere((e) => e.id == eventId);

    final rawList = events.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, rawList);
  }

  /// Checks if an event is currently favorited.
  Future<bool> isFavorite(String eventId) async {
    final events = await getFavorites();
    return events.any((e) => e.id == eventId);
  }
}
