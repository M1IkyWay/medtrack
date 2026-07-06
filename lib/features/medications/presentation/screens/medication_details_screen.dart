import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Detail view for a single medication: schedule, course progress and dose
/// history.
///
/// Day 1 is a routed placeholder that just carries the [medicationId]; the
/// real content lands on Day 2 (details) and Day 3 (history/calendar).
class MedicationDetailsScreen extends ConsumerWidget {
  const MedicationDetailsScreen({required this.medicationId, super.key});

  final int medicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medication')),
      body: Center(child: Text('Details for medication #$medicationId')),
    );
  }
}
