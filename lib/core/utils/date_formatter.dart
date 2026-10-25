import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static bool _isInitialized = false;

  /// Initializes Turkish locale for date formatting.
  static Future<void> initialize() async {
    if (!_isInitialized) {
      await initializeDateFormatting('tr_TR', null);
      _isInitialized = true;
    }
  }

  /// Parses an ISO 8601 string safely into [DateTime].
  /// Preserves the organizer's intended event wall-clock time regardless of device timezone.
  static DateTime? parse(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) return null;
    final normalized = isoString.trim().replaceAll(RegExp(r'([+-]\d{2}:\d{2}|Z)$'), '');
    return DateTime.tryParse(normalized);
  }

  /// Formats date for cards: e.g. "21 Eki 2026"
  static String formatShortDate(String? isoString) {
    final dateTime = parse(isoString);
    if (dateTime == null) return 'Tarih Belirtilmedi';
    try {
      return DateFormat('d MMM y', 'tr_TR').format(dateTime);
    } catch (_) {
      return DateFormat('d MMM y').format(dateTime);
    }
  }

  /// Formats date and time: e.g. "21 Ekim 2026, 18:00"
  static String formatFullDateTime(String? isoString) {
    final dateTime = parse(isoString);
    if (dateTime == null) return 'Tarih Belirtilmedi';
    try {
      return DateFormat('d MMMM y, HH:mm', 'tr_TR').format(dateTime);
    } catch (_) {
      return DateFormat('d MMMM y, HH:mm').format(dateTime);
    }
  }

  /// Formats a time range, e.g. "18:00 - 20:00" or start and end date
  static String formatRange(String? startIso, String? endIso) {
    final start = parse(startIso);
    final end = parse(endIso);

    if (start == null && end == null) return 'Tarih Belirtilmedi';
    if (start != null && end == null) return formatFullDateTime(startIso);
    if (start == null && end != null) return formatFullDateTime(endIso);

    // If both on same day, format like "21 Ekim 2026, 18:00 - 20:00"
    final isSameDay = start!.year == end!.year &&
        start.month == end.month &&
        start.day == end.day;

    try {
      if (isSameDay) {
        final dateStr = DateFormat('d MMMM y', 'tr_TR').format(start);
        final startTimeStr = DateFormat('HH:mm', 'tr_TR').format(start);
        final endTimeStr = DateFormat('HH:mm', 'tr_TR').format(end);
        return '$dateStr, $startTimeStr - $endTimeStr';
      } else {
        final startStr = DateFormat('d MMM, HH:mm', 'tr_TR').format(start);
        final endStr = DateFormat('d MMM, HH:mm', 'tr_TR').format(end);
        return '$startStr - $endStr';
      }
    } catch (_) {
      return '${start.toIso8601String()} - ${end.toIso8601String()}';
    }
  }
}

