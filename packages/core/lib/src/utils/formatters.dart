import 'package:intl/intl.dart';

/// Date and time formatters (German locale)
class Formatters {
  Formatters._();

  static final _dateFormat = DateFormat('dd.MM.yyyy', 'de_DE');
  static final _timeFormat = DateFormat('HH:mm', 'de_DE');
  static final _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm', 'de_DE');
  static final _dayFormat = DateFormat('EEEE', 'de_DE');
  static final _shortDateFormat = DateFormat('dd.MM.', 'de_DE');

  /// Format date: 01.01.2025
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// Format time: 14:30
  static String formatTime(DateTime date) => _timeFormat.format(date);

  /// Format date and time: 01.01.2025 14:30
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  /// Format day name: Montag
  static String dayName(DateTime date) => _dayFormat.format(date);

  /// Format short date: 01.01.
  static String shortDate(DateTime date) => _shortDateFormat.format(date);

  /// Format ticket number with prefix and padded number
  static String formatTicketNumber(String prefix, int number) {
    return '$prefix-${number.toString().padLeft(3, '0')}';
  }

  /// Format wait time in human readable format
  static String formatWaitTime(int minutes) {
    if (minutes < 60) {
      return minutes == 1 ? '1 Minute' : '$minutes Minuten';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    final hourStr = hours == 1 ? '1 Stunde' : '$hours Stunden';
    if (mins == 0) return hourStr;
    return '$hourStr $mins Minuten';
  }

  /// Format relative time: "vor 5 Minuten", "in 2 Stunden"
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.isNegative) {
      // Future
      final absDiff = diff.abs();
      if (absDiff.inMinutes < 1) return 'jetzt';
      if (absDiff.inMinutes < 60) return 'in ${absDiff.inMinutes} Min.';
      if (absDiff.inHours < 24) return 'in ${absDiff.inHours} Std.';
      return 'in ${absDiff.inDays} Tagen';
    } else {
      // Past
      if (diff.inMinutes < 1) return 'gerade eben';
      if (diff.inMinutes < 60) return 'vor ${diff.inMinutes} Min.';
      if (diff.inHours < 24) return 'vor ${diff.inHours} Std.';
      if (diff.inDays < 7) return 'vor ${diff.inDays} Tagen';
      return formatDate(date);
    }
  }

  /// Format duration in minutes
  static String duration(int minutes) {
    if (minutes < 60) return '$minutes Min.';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours Std.';
    return '$hours Std. $mins Min.';
  }

  /// Format wait time estimate (rounded)
  static String waitTimeEstimate(int? minutes) {
    if (minutes == null) return 'Unbekannt';
    if (minutes <= 0) return 'Jetzt';
    if (minutes < 5) return 'Weniger als 5 Min.';
    if (minutes < 15) return 'ca. ${((minutes + 4) ~/ 5) * 5} Min.';
    if (minutes < 60) return 'ca. ${((minutes + 9) ~/ 10) * 10} Min.';
    return 'Über 1 Stunde';
  }
}

