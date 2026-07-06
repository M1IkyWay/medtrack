import '../domain/models/local_time.dart';

/// Presentation formatting helpers for medication values.

/// Formats a dose amount without a trailing `.0` (e.g. `400`, `2.5`).
String formatAmount(double amount) {
  if (amount == amount.roundToDouble()) return amount.toInt().toString();
  return amount.toString();
}

/// Joins schedule times into a compact `08:00 · 20:00` summary.
String formatTimes(List<LocalTime> times) {
  final sorted = [...times]..sort();
  return sorted.map((t) => t.format()).join(' · ');
}
