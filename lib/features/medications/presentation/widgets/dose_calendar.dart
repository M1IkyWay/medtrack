import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../domain/models/dose_log.dart';
import '../../domain/models/medication_enums.dart';
import '../medication_presentation.dart';

/// A compact month grid marking each day by its dominant dose status.
///
/// For a day with several logs, the "best" outcome wins (taken > postponed >
/// skipped > missed) so a day where a dose was taken reads as adherent.
class DoseCalendar extends StatelessWidget {
  const DoseCalendar({required this.logs, super.key});

  final List<DoseLog> logs;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    // DateTime.weekday: 1 = Mon … 7 = Sun → leading blanks before day 1.
    final leadingBlanks = firstOfMonth.weekday - 1;
    final locale = Localizations.localeOf(context).toString();

    final statusByDay = _statusByDay();

    final cells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++)
        _DayCell(day: day, isToday: day == now.day, status: statusByDay[day]),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat.yMMMM(locale).format(firstOfMonth),
          style: context.textStyles.titleSmall,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: cells,
        ),
      ],
    );
  }

  Map<int, DoseStatus> _statusByDay() {
    const rank = {
      DoseStatus.taken: 4,
      DoseStatus.postponed: 3,
      DoseStatus.skipped: 2,
      DoseStatus.missed: 1,
      DoseStatus.scheduled: 0,
    };
    final now = DateTime.now();
    final result = <int, DoseStatus>{};
    for (final log in logs) {
      final at = log.scheduledTime;
      if (at.year != now.year || at.month != now.month) continue;
      final current = result[at.day];
      if (current == null || rank[log.status]! > rank[current]!) {
        result[at.day] = log.status;
      }
    }
    return result;
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.isToday, this.status});

  final int day;
  final bool isToday;
  final DoseStatus? status;

  @override
  Widget build(BuildContext context) {
    final color = status?.color;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color?.withValues(alpha: 0.18),
        border: isToday
            ? Border.all(color: context.colors.primary, width: 1.5)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '$day',
        style: context.textStyles.bodySmall?.copyWith(
          color: color ?? context.colors.onSurface,
          fontWeight: isToday ? FontWeight.bold : null,
        ),
      ),
    );
  }
}
