import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../application/medication_providers.dart';
import '../../domain/models/medication.dart';
import '../../domain/models/medication_enums.dart';
import '../../domain/models/schedule.dart';
import '../format.dart';
import '../medication_presentation.dart';

/// Detail view for a single medication: header, schedule and (from Day 3) dose
/// history. Offers edit and delete actions.
class MedicationDetailsScreen extends ConsumerWidget {
  const MedicationDetailsScreen({required this.medicationId, super.key});

  final int medicationId;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Medication medication,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage(medication.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(medicationRepositoryProvider).delete(medicationId);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(medicationByIdProvider(medicationId));

    return Scaffold(
      appBar: AppBar(
        title: Text(async.value?.name ?? l10n.medicationsListTitle),
        actions: [
          if (async.value != null) ...[
            IconButton(
              icon: const Icon(Symbols.edit),
              tooltip: l10n.commonEdit,
              onPressed: () => context.pushNamed(
                RouteName.medicationForm,
                queryParameters: {'id': '$medicationId'},
              ),
            ),
            IconButton(
              icon: const Icon(Symbols.delete),
              tooltip: l10n.commonDelete,
              onPressed: () => _confirmDelete(context, ref, async.value!),
            ),
          ],
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (medication) {
          if (medication == null) {
            return Center(child: Text(l10n.detailsNoDoses));
          }
          return _DetailsBody(medication: medication);
        },
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final schedule = medication.schedule;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: context.colors.primaryContainer,
              child: Icon(
                medication.form.icon,
                color: context.colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medication.name, style: context.textStyles.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    l10n.doseSummary(
                      formatAmount(medication.doseAmount),
                      medication.doseUnit.label,
                    ),
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  if (medication.prescribedFor != null)
                    Text(
                      medication.prescribedFor!,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ScheduleCard(schedule: schedule),
        if (medication.notes != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(medication.notes!),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(l10n.detailsHistoryTitle, style: context.textStyles.titleMedium),
        const SizedBox(height: 8),
        Text(
          l10n.detailsNoDoses,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.schedule});

  final Schedule schedule;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMd(locale);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.detailsScheduleTitle,
              style: context.textStyles.titleMedium,
            ),
            const SizedBox(height: 12),
            _Row(Symbols.repeat, schedule.type.label(l10n)),
            if (schedule.times.isNotEmpty)
              _Row(Symbols.schedule, formatTimes(schedule.times)),
            _Row(Symbols.restaurant, schedule.mealRelation.label(l10n)),
            if (schedule.type == ScheduleType.course &&
                schedule.totalDoses != null)
              _Row(
                Symbols.medication,
                l10n.detailsCourseProgress(0, schedule.totalDoses!),
              ),
            if (schedule.startDate != null)
              _Row(Symbols.event, dateFormat.format(schedule.startDate!)),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 20, color: context.colors.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
