import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../domain/models/medication_enums.dart';
import '../medication_presentation.dart';

class DoseFormSelector extends StatelessWidget {
  const DoseFormSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final MedicationForm value;
  final ValueChanged<MedicationForm> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final form in MedicationForm.values)
          ChoiceChip(
            selected: form == value,
            avatar: Icon(form.icon, size: 18),
            label: Text(form.label(l10n)),
            onSelected: (_) => onChanged(form),
          ),
      ],
    );
  }
}
