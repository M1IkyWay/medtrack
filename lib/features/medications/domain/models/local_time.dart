import 'package:equatable/equatable.dart';

/// A wall-clock time of day (hour + minute), independent of any date.
///
/// The domain deliberately avoids Flutter's `TimeOfDay` so models stay free of
/// the `flutter/material` dependency and remain unit-testable. Presentation
/// converts to/from `TimeOfDay` at the UI edge; persistence stores
/// [minutesFromMidnight].
class LocalTime extends Equatable implements Comparable<LocalTime> {
  const LocalTime(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24, 'hour must be 0..23'),
      assert(minute >= 0 && minute < 60, 'minute must be 0..59');

  /// Reconstructs a time from minutes since midnight (0..1439).
  factory LocalTime.fromMinutes(int minutes) {
    assert(minutes >= 0 && minutes < 24 * 60, 'minutes must be 0..1439');
    return LocalTime(minutes ~/ 60, minutes % 60);
  }

  final int hour;
  final int minute;

  /// Minutes since midnight — the canonical storage form.
  int get minutesFromMidnight => hour * 60 + minute;

  /// 24-hour `HH:mm` representation, stable across locales for storage/logging.
  String format() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  int compareTo(LocalTime other) =>
      minutesFromMidnight.compareTo(other.minutesFromMidnight);

  @override
  List<Object?> get props => [hour, minute];

  @override
  String toString() => 'LocalTime(${format()})';
}
