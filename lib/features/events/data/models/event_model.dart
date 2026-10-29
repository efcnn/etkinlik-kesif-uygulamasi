////JSON Tercümanı
/// Immutable and null-safe model representing an Event.
class EventModel {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String startDate;
  final String? endDate;
  final String location;
  final String organizer;
  final String imageUrl;
  final int capacity;
  final int registeredCount;
  final bool isOnline;
  final List<String> tags;

  const EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.startDate,
    this.endDate,
    required this.location,
    required this.organizer,
    required this.imageUrl,
    required this.capacity,
    required this.registeredCount,
    required this.isOnline,
    required this.tags,
  });

  /// Factory constructor to safely parse JSON from the API or local storage.
  /// Handles missing or null fields gracefully without crashing.
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'İsimsiz Etkinlik',
      description: json['description']?.toString(),
      category: json['category']?.toString() ?? 'Genel',
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString(),
      location: json['location']?.toString() ?? 'Konum Belirtilmedi',
      organizer: json['organizer']?.toString() ?? 'Organizatör Belirtilmedi',
      imageUrl: json['imageUrl']?.toString() ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      registeredCount: (json['registeredCount'] as num?)?.toInt() ?? 0,
      isOnline: json['isOnline'] == true,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
    );
  }

  /// Serializes the model into a Map for local storage persistence (e.g. SharedPreferences).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'category': category,
      'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      'location': location,
      'organizer': organizer,
      'imageUrl': imageUrl,
      'capacity': capacity,
      'registeredCount': registeredCount,
      'isOnline': isOnline,
      'tags': tags,
    };
  }

  /// Creates a copy of this [EventModel] with optionally updated fields.
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? startDate,
    String? endDate,
    String? location,
    String? organizer,
    String? imageUrl,
    int? capacity,
    int? registeredCount,
    bool? isOnline,
    List<String>? tags,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      imageUrl: imageUrl ?? this.imageUrl,
      capacity: capacity ?? this.capacity,
      registeredCount: registeredCount ?? this.registeredCount,
      isOnline: isOnline ?? this.isOnline,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Paginated response container for `/events`.
class EventListResponse {
  final List<EventModel> items;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  const EventListResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory EventListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map((e) => EventModel.fromJson(e))
        .toList();

    return EventListResponse(
      items: items,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? items.length,
      total: (json['total'] as num?)?.toInt() ?? items.length,
      hasMore: json['hasMore'] == true,
    );
  }
}

