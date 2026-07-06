import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../application/medication_providers.dart';
import '../../domain/models/dose_log.dart';
import '../../domain/models/medication_enums.dart';
import '../medication_presentation.dart';
import 'dose_calendar.dart';

/// Dose history for one medication: adherence rate, a month calendar and the
/// list of recorded doses. Tapping a row re-opens the take-dose flow so its
/// status can be changed.
class DoseHistorySection extends ConsumerWidget {
  const DoseHistorySection({required this.medicationId, super.key});

  final int medicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(doseLogsProvider(medicationId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('$error'),
      data: (logs) {
        if (logs.isEmpty) {
          return Text(
            l10n.detailsNoDoses,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          );
        }

        final rate = _adherenceRate(logs);
        final locale = Localizations.localeOf(context).toString();
        final dateTimeFormat = DateFormat.MMMd(locale).add_jm();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (rate != null)
              Text(
                l10n.complianceLabel((rate * 100).round()),
                style: context.textStyles.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            const SizedBox(height: 16),
            DoseCalendar(logs: logs),
            const SizedBox(height: 16),
            for (final log in logs)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(log.status.icon, color: log.status.color),
                title: Text(dateTimeFormat.format(log.scheduledTime)),
                subtitle: Text(log.status.label(l10n)),
                onTap: () => context.pushNamed(
                  RouteName.takeDose,
                  queryParameters: {
                    'medicationId': '$medicationId',
                    'time': '${log.scheduledTime.millisecondsSinceEpoch}',
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  /// Fraction of resolved doses that were taken. Only doses the user acted on
  /// (taken / skipped / missed) count toward the denominator; still-scheduled or
  /// postponed doses are ignored. Returns null when there is nothing to score.
  double? _adherenceRate(List<DoseLog> logs) {
    final resolved = logs.where(
      (l) =>
          l.status == DoseStatus.taken ||
          l.status == DoseStatus.skipped ||
          l.status == DoseStatus.missed,
    );
    if (resolved.isEmpty) return null;
    final taken = resolved.where((l) => l.status == DoseStatus.taken).length;
    return taken / resolved.length;
  }
}
