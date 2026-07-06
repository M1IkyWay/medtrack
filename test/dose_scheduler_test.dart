import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/medications/application/dose_scheduler.dart';
import 'package:medtrack/features/medications/domain/models/local_time.dart';
import 'package:medtrack/features/medications/domain/models/medication_enums.dart';
import 'package:medtrack/features/medications/domain/models/schedule.dart';

void main() {
  // 2026-01-05 is a Monday (weekday == 1).
  final monday8am = DateTime(2026, 1, 5, 8);

  test('asNeeded yields no scheduled doses', () {
    final doses = DoseScheduler.upcomingDoses(
      const Schedule(type: ScheduleType.asNeeded),
      from: monday8am,
    );
    expect(doses, isEmpty);
  });

  test('daily schedules every configured time within the horizon', () {
    final doses = DoseScheduler.upcomingDoses(
      const Schedule(
        type: ScheduleType.daily,
        times: [LocalTime(9, 0), LocalTime(21, 0)],
      ),
      from: monday8am,
      horizon: const Duration(days: 1),
    );

    expect(doses, hasLength(4));
    expect(doses.first, DateTime(2026, 1, 5, 9));
    expect(doses.every((d) => d.isAfter(monday8am)), isTrue);
    expect(doses, orderedEquals([...doses]..sort()));
  });

  test('weekly only schedules the selected weekdays', () {
    final doses = DoseScheduler.upcomingDoses(
      const Schedule(
        type: ScheduleType.weekly,
        times: [LocalTime(8, 0)],
        daysOfWeek: [1], // Mondays
      ),
      from: DateTime(2026, 1, 5, 7),
      horizon: const Duration(days: 8),
    );

    expect(doses, [DateTime(2026, 1, 5, 8), DateTime(2026, 1, 12, 8)]);
  });

  test('everyNDays respects the interval from the start date', () {
    final doses = DoseScheduler.upcomingDoses(
      Schedule(
        type: ScheduleType.everyNDays,
        times: const [LocalTime(10, 0)],
        intervalDays: 2,
        startDate: DateTime(2026, 1, 5),
      ),
      from: DateTime(2026, 1, 5, 7),
      horizon: const Duration(days: 4),
    );

    expect(doses, [
      DateTime(2026, 1, 5, 10),
      DateTime(2026, 1, 7, 10),
      DateTime(2026, 1, 9, 10),
    ]);
  });

  test('course caps the number of doses at totalDoses', () {
    final doses = DoseScheduler.upcomingDoses(
      const Schedule(
        type: ScheduleType.course,
        times: [LocalTime(9, 0)],
        totalDoses: 3,
      ),
      from: monday8am,
    );

    expect(doses, hasLength(3));
  });

  test('once schedules a single dose on the start date', () {
    final doses = DoseScheduler.upcomingDoses(
      Schedule(
        type: ScheduleType.once,
        times: const [LocalTime(9, 0)],
        startDate: DateTime(2026, 1, 10),
      ),
      from: monday8am,
    );

    expect(doses, [DateTime(2026, 1, 10, 9)]);
  });
}
