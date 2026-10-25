import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';

/// Manages the state of an individual event detail screen.
/// Immediately provides the basic [event] data while asynchronously
/// fetching the full [description] from `/events/{id}`.
class EventDetailProvider extends ChangeNotifier {
  final EventRepository repository;
  EventModel _event;

  bool _isLoadingDescription = false;
  String? _descriptionError;
  bool _isDescriptionExpanded = false;

  EventDetailProvider({
    required this.repository,
    required EventModel initialEvent,
  }) : _event = initialEvent;

  EventModel get event => _event;
  bool get isLoadingDescription => _isLoadingDescription;
  String? get descriptionError => _descriptionError;
  bool get isDescriptionExpanded => _isDescriptionExpanded;

  /// Toggles the "Show More / Show Less" description state.
  void toggleDescriptionExpanded() {
    _isDescriptionExpanded = !_isDescriptionExpanded;
    notifyListeners();
  }

  /// Fetches the event description from the server.
  /// If the event already has a description, it will not re-fetch unless [force] is true.
  Future<void> fetchDescription({bool force = false}) async {
    if (!force && _event.description != null && _event.description!.isNotEmpty) {
      return;
    }

    _isLoadingDescription = true;
    _descriptionError = null;
    notifyListeners();

    try {
      final detail = await repository.getEventDetail(_event.id);
      _event = _event.copyWith(
        description: detail.description,
      );
      _descriptionError = null;
    } on ApiException catch (e) {
      _descriptionError = e.message;
    } catch (_) {
      _descriptionError = 'Açıklama yüklenirken bir sorun oluştu.';
    } finally {
      _isLoadingDescription = false;
      notifyListeners();
    }
  }

  /// Retries fetching only the description if it failed.
  void retryDescription() {
    fetchDescription(force: true);
  }
}

