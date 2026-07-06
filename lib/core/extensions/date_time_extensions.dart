/// Date/time helpers used across scheduling and dose logging.
///
/// MedTrack reasons about "which calendar day" a dose belongs to a lot, so the
/// day-boundary helpers live here rather than being re-derived per feature.
extension DateTimeX on DateTime {
  /// Midnight at the start of this date, dropping the time component.
  DateTime get dateOnly => DateTime(year, month, day);

  /// Whether this instant falls on the same calendar day as [other].
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Whether this instant is today in local time.
  bool get isToday => isSameDay(DateTime.now());
}
