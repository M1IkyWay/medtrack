import '../domain/models/medication_enums.dart';
import '../domain/models/schedule.dart';

/// Pure scheduling logic: given a [Schedule], compute the concrete future dose
/// times within a rolling horizon.
///
/// Kept free of Flutter and the notification plugin so it is fully unit
/// testable — the notification layer just turns these `DateTime`s into
/// scheduled reminders.
abstract final class DoseScheduler {
  /// Upcoming dose date-times for [schedule], strictly after [from] and within
  /// [horizon], sorted ascending and capped at [max].
  ///
  /// [ScheduleType.asNeeded] has no fixed times and yields an empty list.
  static List<DateTime> upcomingDoses(
    Schedule schedule, {
    required DateTime from,
    Duration horizon = const Duration(days: 14),
    int max = 64,
  }) {
    if (schedule.type == ScheduleType.asNeeded || schedule.times.isEmpty) {
      return const [];
    }

    final start = _startDay(schedule, from);
    final end = _endDay(schedule, from, horizon);
    final times = [...schedule.times]..sort();

    final result = <DateTime>[];
    for (
      var day = start;
      !day.isAfter(end);
      day = day.add(const Duration(days: 1))
    ) {
      if (!_dayMatches(schedule, day, from)) continue;
      for (final time in times) {
        final at = DateTime(
          day.year,
          day.month,
          day.day,
          time.hour,
          time.minute,
        );
        if (at.isAfter(from)) result.add(at);
      }
    }

    result.sort();
    if (schedule.type == ScheduleType.course && schedule.totalDoses != null) {
      // A finite course never schedules more than its remaining dose count.
      final cap = schedule.totalDoses!.clamp(0, result.length);
      result.removeRange(cap, result.length);
    }
    return result.length > max ? result.sublist(0, max) : result;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _startDay(Schedule schedule, DateTime from) {
    final today = _dateOnly(from);
    final startDate = schedule.startDate;
    if (startDate == null) return today;
    final start = _dateOnly(startDate);
    return start.isAfter(today) ? start : today;
  }

  static DateTime _endDay(Schedule schedule, DateTime from, Duration horizon) {
    final horizonEnd = _dateOnly(from.add(horizon));
    final endDate = schedule.endDate;
    if (endDate == null) return horizonEnd;
    final end = _dateOnly(endDate);
    return end.isBefore(horizonEnd) ? end : horizonEnd;
  }

  static bool _dayMatches(Schedule schedule, DateTime day, DateTime from) {
    // A fixed anchor — the start date, or today when none is set. Must not be
    // the iterated day, or "once"/"everyNDays" would match every day.
    final anchor = _dateOnly(schedule.startDate ?? from);
    switch (schedule.type) {
      case ScheduleType.once:
        return day.isSameDayAs(anchor);
      case ScheduleType.daily:
      case ScheduleType.course:
        return true;
      case ScheduleType.weekly:
        return schedule.daysOfWeek?.contains(day.weekday) ?? false;
      case ScheduleType.everyNDays:
        final interval = schedule.intervalDays ?? 1;
        if (interval <= 0) return false;
        final diff = day.difference(anchor).inDays;
        return diff >= 0 && diff % interval == 0;
      case ScheduleType.asNeeded:
        return false;
    }
  }
}

extension _SameDay on DateTime {
  bool isSameDayAs(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}
