import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';

enum EventListStatus {
  initial,
  loading,
  success,
  error,
  empty,
}

/// Manages state for the event discovery list screen, including
/// loading, error, empty states, and stale response protection.
class EventListProvider extends ChangeNotifier {
  final EventRepository repository;

  EventListStatus _status = EventListStatus.initial;
  List<EventModel> _events = [];
  String? _errorMessage;
  String? _selectedCategory;
  String _searchQuery = '';

  /// Request counter to protect against stale/out-of-order network responses.
  int _latestRequestId = 0;

  EventListProvider({required this.repository});

  EventListStatus get status => _status;
  List<EventModel> get events => List.unmodifiable(_events);
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  bool get isLoading => _status == EventListStatus.loading;
  bool get hasError => _status == EventListStatus.error;
  bool get isEmpty => _status == EventListStatus.empty;
  bool get isSuccess => _status == EventListStatus.success;

  /// Fetches events from repository.
  /// Automatically drops responses if a newer request was dispatched while waiting.
  Future<void> fetchEvents({bool isRefresh = false}) async {
    final requestId = ++_latestRequestId;

    if (!isRefresh) {
      _status = EventListStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await repository.getEvents(
        query: _searchQuery,
        category: _selectedCategory,
        limit: 50, // Phase 1 requirement: fetch all events
      );

      // If a newer request has already been sent, discard this response
      if (requestId != _latestRequestId) return;

      _events = response.items;
      if (_events.isEmpty) {
        _status = EventListStatus.empty;
      } else {
        _status = EventListStatus.success;
      }
      _errorMessage = null;
    } on ApiException catch (e) {
      if (requestId != _latestRequestId) return;
      _status = EventListStatus.error;
      _errorMessage = e.message;
    } catch (_) {
      if (requestId != _latestRequestId) return;
      _status = EventListStatus.error;
      _errorMessage = 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
    } finally {
      if (requestId == _latestRequestId) {
        notifyListeners();
      }
    }
  }

  /// Retries the current fetch operation.
  void retry() {
    fetchEvents();
  }

  /// Sets category filter and refreshes the list.
  void setCategory(String? category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchEvents();
  }

  /// Sets search query and refreshes the list.
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    fetchEvents();
  }
}
