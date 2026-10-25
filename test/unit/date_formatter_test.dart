import 'package:flutter_test/flutter_test.dart';
import 'package:etkinlik_kesif_uygulamasi/core/utils/date_formatter.dart';

void main() {
  setUpAll(() async {
    await DateFormatter.initialize();
  });

  group('DateFormatter Tests', () {
    test('parses and formats valid ISO dates in Turkish', () {
      const iso = '2026-10-21T18:00:00+03:00';

      final shortDate = DateFormatter.formatShortDate(iso);
      expect(shortDate, contains('Eki'));
      expect(shortDate, contains('2026'));

      final fullDateTime = DateFormatter.formatFullDateTime(iso);
      expect(fullDateTime, contains('Ekim'));
      expect(fullDateTime, contains('18:00'));
    });

    test('handles null or empty date gracefully', () {
      expect(DateFormatter.formatShortDate(null), 'Tarih Belirtilmedi');
      expect(DateFormatter.formatFullDateTime(''), 'Tarih Belirtilmedi');
      expect(DateFormatter.formatRange(null, null), 'Tarih Belirtilmedi');
    });

    test('formats time range on same day', () {
      const start = '2026-10-21T18:00:00+03:00';
      const end = '2026-10-21T20:00:00+03:00';

      final range = DateFormatter.formatRange(start, end);
      expect(range, contains('18:00 - 20:00'));
      expect(range, contains('Ekim'));
    });
  });
}

