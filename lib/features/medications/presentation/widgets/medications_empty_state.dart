import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Friendly placeholder shown when a tab has no medications.
class MedicationsEmptyState extends StatelessWidget {
  const MedicationsEmptyState({this.activeOnly = true, super.key});

  final bool activeOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = activeOnly
        ? l10n.medicationsEmptyTitle
        : l10n.medicationsInactiveEmptyTitle;
    final message = activeOnly
        ? l10n.medicationsEmptyMessage
        : l10n.medicationsInactiveEmptyMessage;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.pill, size: 72, color: context.colors.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: context.textStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
