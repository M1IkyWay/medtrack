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
  final List<LocalTime> times;

  /// Weekdays, 1 = Monday … 7 = Sunday.
  final List<int>? daysOfWeek;

  final int? intervalDays;
  final DateTime? startDate;

  /// `null` means ongoing.
  final DateTime? endDate;

  final int? totalDoses;
  final MealRelation mealRelation;

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
