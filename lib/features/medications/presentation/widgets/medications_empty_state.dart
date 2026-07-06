import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Friendly placeholder shown when there are no medications to display.
class MedicationsEmptyState extends StatelessWidget {
  const MedicationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.pill, size: 72, color: context.colors.primary),
            const SizedBox(height: 16),
            Text(
              context.l10n.medicationsEmptyTitle,
              style: context.textStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.medicationsEmptyMessage,
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
