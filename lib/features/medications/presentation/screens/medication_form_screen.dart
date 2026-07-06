import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Create / edit form for a medication.
///
/// [medicationId] is null when creating and set when editing — the title and
/// (later) the pre-filled fields switch on it. Day 1 is an empty shell; the
/// full field set and validation arrive on Day 2.
class MedicationFormScreen extends ConsumerWidget {
  const MedicationFormScreen({this.medicationId, super.key});

  final int? medicationId;

  bool get _isEditing => medicationId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? context.l10n.medicationFormEditTitle
              : context.l10n.medicationFormAddTitle,
        ),
      ),
      body: const Center(child: Text('Medication form — coming on Day 2')),
    );
  }
}
