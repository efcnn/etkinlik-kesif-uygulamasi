import 'package:flutter_test/flutter_test.dart';
import 'package:etkinlik_kesif_uygulamasi/features/events/data/models/event_model.dart';

void main() {
  group('EventModel Tests', () {
    test('parses full JSON correctly', () {
      final json = {
        'id': 'evt-001',
        'title': 'Flutter Workshop',
        'description': 'Açıklama metni',
        'category': 'Workshop',
        'startDate': '2026-10-21T18:00:00+03:00',
        'endDate': '2026-10-21T20:00:00+03:00',
        'location': 'Davutpaşa Kampüsü',
        'organizer': 'MOBILAB',
        'imageUrl': 'https://picsum.photos/seed/evt001/800/450',
        'capacity': 60,
        'registeredCount': 42,
        'isOnline': false,
        'tags': ['flutter', 'mobil'],
      };

      final event = EventModel.fromJson(json);

      expect(event.id, 'evt-001');
      expect(event.title, 'Flutter Workshop');
      expect(event.description, 'Açıklama metni');
      expect(event.category, 'Workshop');
      expect(event.startDate, '2026-10-21T18:00:00+03:00');
      expect(event.endDate, '2026-10-21T20:00:00+03:00');
      expect(event.location, 'Davutpaşa Kampüsü');
      expect(event.organizer, 'MOBILAB');
      expect(event.imageUrl, 'https://picsum.photos/seed/evt001/800/450');
      expect(event.capacity, 60);
      expect(event.registeredCount, 42);
      expect(event.isOnline, false);
      expect(event.tags, ['flutter', 'mobil']);
    });

    test('handles null and missing fields gracefully without throwing errors', () {
      final json = <String, dynamic>{
        'id': 'evt-null-test',
        'title': null,
        'description': null,
        'category': null,
        'startDate': null,
        'endDate': null,
        'location': null,
        'organizer': null,
        'imageUrl': null,
        'capacity': null,
        'registeredCount': null,
        'isOnline': null,
        'tags': null,
      };

      final event = EventModel.fromJson(json);

      expect(event.id, 'evt-null-test');
      expect(event.title, 'İsimsiz Etkinlik');
      expect(event.description, isNull);
      expect(event.category, 'Genel');
      expect(event.startDate, '');
      expect(event.endDate, isNull);
      expect(event.location, 'Konum Belirtilmedi');
      expect(event.organizer, 'Organizatör Belirtilmedi');
      expect(event.imageUrl, '');
      expect(event.capacity, 0);
      expect(event.registeredCount, 0);
      expect(event.isOnline, false);
      expect(event.tags, isEmpty);
    });

    test('serializes to JSON and deserializes back faithfully (Persistence)', () {
      const original = EventModel(
        id: 'evt-test-99',
        title: 'Kalıcılık Testi',
        description: 'Yerel depolama için test',
        category: 'Test',
        startDate: '2026-11-01T10:00:00+03:00',
        endDate: '2026-11-01T12:00:00+03:00',
        location: 'Online',
        organizer: 'Kulüp',
        imageUrl: 'https://example.com/image.png',
        capacity: 100,
        registeredCount: 50,
        isOnline: true,
        tags: ['test', 'unit'],
      );

      final jsonMap = original.toJson();
      final restored = EventModel.fromJson(jsonMap);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.description, original.description);
      expect(restored.category, original.category);
      expect(restored.location, original.location);
      expect(restored.isOnline, original.isOnline);
      expect(restored.tags, original.tags);
    });

    test('copyWith updates specified fields only', () {
      const original = EventModel(
        id: 'evt-copy',
        title: 'Başlangıç Başlığı',
        category: 'Sosyal',
        startDate: '2026-10-25',
        location: 'Kampüs',
        organizer: 'Kulüp',
        imageUrl: '',
        capacity: 20,
        registeredCount: 10,
        isOnline: false,
        tags: [],
      );

      final updated = original.copyWith(
        description: 'Detaydan sonradan eklenen açıklama',
        registeredCount: 11,
      );

      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.description, 'Detaydan sonradan eklenen açıklama');
      expect(updated.registeredCount, 11);
    });

    test('EventListResponse parses list correctly', () {
      final json = {
        'items': [
          {
            'id': 'evt-1',
            'title': 'Etkinlik 1',
            'category': 'Workshop',
            'startDate': '2026-10-25',
            'location': 'A Salonu',
            'organizer': 'MOBILAB',
            'imageUrl': '',
            'capacity': 30,
            'registeredCount': 10,
            'isOnline': false,
            'tags': ['flutter'],
          }
        ],
        'page': 1,
        'limit': 10,
        'total': 1,
        'hasMore': false,
      };

      final response = EventListResponse.fromJson(json);

      expect(response.items.length, 1);
      expect(response.items.first.title, 'Etkinlik 1');
      expect(response.page, 1);
      expect(response.total, 1);
      expect(response.hasMore, false);
    });
  });
}

