import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../domain/models/medication.dart';
import '../format.dart';
import '../medication_presentation.dart';

class MedicationCard extends StatelessWidget {
  const MedicationCard({
    required this.medication,
    required this.onTap,
    super.key,
  });

  final Medication medication;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final doseText = l10n.doseSummary(
      formatAmount(medication.doseAmount),
      medication.doseUnit.label,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: context.colors.primaryContainer,
          child: Icon(
            medication.form.icon,
            color: context.colors.onPrimaryContainer,
          ),
        ),
        title: Text(
          medication.name,
          style: context.textStyles.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$doseText · ${medication.schedule.type.label(l10n)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Symbols.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
