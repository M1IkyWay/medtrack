import 'package:equatable/equatable.dart';

import 'local_time.dart';
import 'medication_enums.dart';

/// When and how often a medication is taken — a value object owned by its
/// [Medication]. Only the fields relevant to the chosen [type] are meaningful.
class Schedule extends Equatable {
  const Schedule({
    required this.type,
    this.times = const [],
    this.daysOfWeek,
    this.intervalDays,
    this.startDate,
    this.endDate,
    this.totalDoses,
    this.mealRelation = MealRelation.independent,
  });

  final ScheduleType type;

  /// Times of day the dose is taken. Empty for [ScheduleType.asNeeded].
  final List<LocalTime> times;

  /// Weekdays for [ScheduleType.weekly], 1 = Monday … 7 = Sunday.
  final List<int>? daysOfWeek;

  /// Interval for [ScheduleType.everyNDays] (e.g. 3 = every third day).
  final int? intervalDays;

  final DateTime? startDate;

  /// End of the schedule; `null` means ongoing.
  final DateTime? endDate;

  /// Total number of doses for a finite course.
  final int? totalDoses;

  final MealRelation mealRelation;

  /// Whether this schedule has a defined end (a course or an explicit end date).
  bool get isFinite =>
      type == ScheduleType.course ||
      type == ScheduleType.once ||
      endDate != null;

  Schedule copyWith({
    ScheduleType? type,
    List<LocalTime>? times,
    List<int>? daysOfWeek,
    int? intervalDays,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDoses,
    MealRelation? mealRelation,
  }) {
    return Schedule(
      type: type ?? this.type,
      times: times ?? this.times,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      intervalDays: intervalDays ?? this.intervalDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDoses: totalDoses ?? this.totalDoses,
      mealRelation: mealRelation ?? this.mealRelation,
    );
  }

  @override
  List<Object?> get props => [
    type,
    times,
    daysOfWeek,
    intervalDays,
    startDate,
    endDate,
    totalDoses,
    mealRelation,
  ];
}
