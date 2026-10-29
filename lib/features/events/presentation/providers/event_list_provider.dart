////Ekranlarımız (EventListScreen) doğrudan API ile konuşmaz veya veriyi kendi içinde tutmaz. Bunun yerine EventListProvider tüm veriyi, aramayı, filtrelemeyi ve sayfalama (pagination) işlemlerini yönetir; bir şey değiştiğinde notifyListeners() diyerek ekranın otomatik güncellenmesini sağlar.

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
/// categories, searching with debounce, category filtering,
/// pagination (infinite scroll), loading, error, empty states,
/// and stale response protection.
class EventListProvider extends ChangeNotifier {
  final EventRepository repository;
  final int pageSize;

  EventListStatus _status = EventListStatus.initial;
  List<EventModel> _events = [];
  List<String> _categories = [];
  String? _errorMessage;
  String? _selectedCategory;
  String _searchQuery = '';

  int _currentPage = 1;
  bool _hasMore = false;
  bool _isLoadingMore = false;
  String? _loadMoreError;
  int _totalCount = 0;

  Timer? _debounceTimer;

  /// Request counter to protect against stale/out-of-order network responses.
  int _latestRequestId = 0;

  EventListProvider({
    required this.repository,
    this.pageSize = 6,
  });

  EventListStatus get status => _status;
  List<EventModel> get events => List.unmodifiable(_events);
  List<String> get categories => List.unmodifiable(_categories);
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  String? get loadMoreError => _loadMoreError;
  int get totalCount => _totalCount > 0 ? _totalCount : _events.length;

  bool get isLoading => _status == EventListStatus.loading;
  bool get hasError => _status == EventListStatus.error;
  bool get isEmpty => _status == EventListStatus.empty;
  bool get isSuccess => _status == EventListStatus.success;

  bool get isFiltering =>
      _searchQuery.isNotEmpty || (_selectedCategory != null && _selectedCategory != 'Tümü');

  /// Fetches categories from `/categories`.
  Future<void> fetchCategories() async {
    try {
      final list = await repository.getCategories();
      _categories = list;
      notifyListeners();
    } catch (_) {
      // Fallback categories if server fails, won't break the UI
      if (_categories.isEmpty) {
        _categories = ['Hackathon', 'Panel', 'Seminer', 'Sosyal', 'Workshop', 'Yarışma'];
        notifyListeners();
      }
    }
  }

  /// Fetches the first page of events from repository.
  /// Automatically drops responses if a newer request was dispatched while waiting.
  Future<void> fetchEvents({bool isRefresh = false}) async {
    final requestId = ++_latestRequestId;

    _currentPage = 1;
    _hasMore = false;
    _isLoadingMore = false;
    _loadMoreError = null;

    if (!isRefresh) {
      _status = EventListStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final categoryParam = (_selectedCategory == 'Tümü') ? null : _selectedCategory;
      final response = await repository.getEvents(
        query: _searchQuery,
        category: categoryParam,
        page: 1,
        limit: pageSize,
      );

      // If a newer request has already been sent, discard this response
      if (requestId != _latestRequestId) return;

      _events = response.items;
      _currentPage = response.page;
      _hasMore = response.hasMore;
      _totalCount = response.total;

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

  /// Loads the next page of events and appends them to the current list.
  Future<void> loadMoreEvents() async {
    if (_isLoadingMore || !_hasMore || _status != EventListStatus.success) {
      return;
    }

    final activeRequestId = _latestRequestId;
    _isLoadingMore = true;
    _loadMoreError = null;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final categoryParam = (_selectedCategory == 'Tümü') ? null : _selectedCategory;
      final response = await repository.getEvents(
        query: _searchQuery,
        category: categoryParam,
        page: nextPage,
        limit: pageSize,
      );

      // Discard if a new search, filter, or refresh occurred while loading more
      if (activeRequestId != _latestRequestId) return;

      final existingIds = _events.map((e) => e.id).toSet();
      final newItems = response.items.where((e) => !existingIds.contains(e.id)).toList();

      _events = [..._events, ...newItems];
      _currentPage = response.page;
      _hasMore = response.hasMore;
      _totalCount = response.total;
      _loadMoreError = null;
    } on ApiException catch (e) {
      if (activeRequestId != _latestRequestId) return;
      _loadMoreError = e.message;
    } catch (_) {
      if (activeRequestId != _latestRequestId) return;
      _loadMoreError = 'Daha fazla etkinlik yüklenirken hata oluştu.';
    } finally {
      if (activeRequestId == _latestRequestId) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  /// Retries the current fetch operation.
  void retry() {
    fetchEvents();
  }

  /// Sets category filter and refreshes the list with stale response protection.
  void setCategory(String? category) {
    final normalized = (category == 'Tümü' || category == null) ? null : category;
    if (_selectedCategory == normalized) return;
    _selectedCategory = normalized;
    fetchEvents();
  }

  /// Sets search query directly and triggers fetch.
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    fetchEvents();
  }

  /// Handles search input with a debounce delay to avoid spamming the API.
  void onSearchChanged(String query, {Duration debounceDuration = const Duration(milliseconds: 400)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      setSearchQuery(query);
    });
  }

  /// Clears the search query immediately.
  void clearSearch() {
    _debounceTimer?.cancel();
    setSearchQuery('');
  }

  /// Clears all filters (both search and category).
  void clearFilters() {
    _debounceTimer?.cancel();
    _searchQuery = '';
    _selectedCategory = null;
    fetchEvents();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
