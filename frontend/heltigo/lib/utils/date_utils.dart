/// Date Utilities — format tanggal untuk UI
/// Sumber: docs/frontend/05_SCREENS_SPEC.md
import 'package:intl/intl.dart';

class DateUtils2 {
  /// Format: "Senin, 12 Mei 2026"
  static String toFullDate(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
  }

  /// Format: "12 Mei 2026"
  static String toMediumDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  /// Format: "12/05/2026"
  static String toShortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format: "Hari ke-5"
  static String toDayNumber(int dayNumber) {
    return 'Hari ke-$dayNumber';
  }

  /// Hitung perbedaan hari dari sekarang
  static int daysDifference(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }
}
