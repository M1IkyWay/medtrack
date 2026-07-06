import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database_provider.dart';
import '../data/medication_repository_impl.dart';
import '../domain/models/dose_log.dart';
import '../domain/models/medication.dart';
import '../domain/repositories/medication_repository.dart';

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepositoryImpl(ref.watch(databaseProvider));
});

/// The `bool` arg is the tab: `true` = active, `false` = inactive.
final medicationsProvider = StreamProvider.family<List<Medication>, bool>((
  ref,
  activeOnly,
) {
  return ref
      .watch(medicationRepositoryProvider)
      .watchMedications(activeOnly: activeOnly);
});

final medicationByIdProvider = FutureProvider.family<Medication?, int>((
  ref,
  id,
) {
  return ref.watch(medicationRepositoryProvider).findById(id);
});

final doseLogsProvider = StreamProvider.family<List<DoseLog>, int>((ref, id) {
  return ref.watch(medicationRepositoryProvider).watchDoseLogs(id);
});
