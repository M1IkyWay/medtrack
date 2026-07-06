import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../data/services/notification_service_provider.dart';
import '../../application/medication_providers.dart';
import '../../domain/models/medication.dart';
import '../../domain/models/medication_enums.dart';
import '../format.dart';
import '../medication_presentation.dart';

/// Screen shown when the user taps a reminder: confirm, skip or postpone the
/// dose. Records the outcome in the dose log and (for postpone) re-fires the
/// reminder shortly after.
class TakeDoseScreen extends ConsumerWidget {
  const TakeDoseScreen({
    required this.medicationId,
    required this.scheduledTime,
    super.key,
  });

  final int medicationId;
  final DateTime scheduledTime;

  Future<void> _record(
    BuildContext context,
    WidgetRef ref,
    Medication medication,
    DoseStatus status,
  ) async {
    final repository = ref.read(medicationRepositoryProvider);
    await repository.recordDose(
      medicationId: medicationId,
      scheduledTime: scheduledTime,
      status: status,
      actualTime: status == DoseStatus.taken ? DateTime.now() : null,
    );

    if (status == DoseStatus.postponed) {
      await ref
          .read(notificationServiceProvider)
          .scheduleSnooze(medication, scheduledTime);
    }

    ref.invalidate(doseLogsProvider(medicationId));
    if (context.mounted) _leave(context);
  }

  void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('medications');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final async = ref.watch(medicationByIdProvider(medicationId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.takeDoseTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (medication) {
          if (medication == null) {
            return Center(child: Text(l10n.detailsNoDoses));
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Icon(
                  medication.form.icon,
                  size: 72,
                  color: context.colors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  medication.name,
                  textAlign: TextAlign.center,
                  style: context.textStyles.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.doseSummary(
                    formatAmount(medication.doseAmount),
                    medication.doseUnit.label,
                  ),
                  textAlign: TextAlign.center,
                  style: context.textStyles.titleMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.doseScheduledFor(
                    DateFormat.jm(locale).format(scheduledTime),
                  ),
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () =>
                      _record(context, ref, medication, DoseStatus.taken),
                  icon: const Icon(Symbols.check),
                  label: Text(l10n.actionTake),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      _record(context, ref, medication, DoseStatus.postponed),
                  icon: const Icon(Symbols.snooze),
                  label: Text(l10n.actionPostpone),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () =>
                      _record(context, ref, medication, DoseStatus.skipped),
                  icon: const Icon(Symbols.close),
                  label: Text(l10n.actionSkip),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
