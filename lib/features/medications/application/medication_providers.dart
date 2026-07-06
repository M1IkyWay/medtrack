import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database_provider.dart';
import '../data/medication_repository_impl.dart';
import '../domain/models/medication.dart';
import '../domain/repositories/medication_repository.dart';

/// The medication repository, backed by the app's Drift database.
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepositoryImpl(ref.watch(databaseProvider));
});

/// Streams medications for one tab: `true` = active, `false` = inactive.
final medicationsProvider = StreamProvider.family<List<Medication>, bool>((
  ref,
  activeOnly,
) {
  return ref
      .watch(medicationRepositoryProvider)
      .watchMedications(activeOnly: activeOnly);
});

/// Loads a single medication by id (for the details / edit screens).
final medicationByIdProvider = FutureProvider.family<Medication?, int>((
  ref,
  id,
) {
  return ref.watch(medicationRepositoryProvider).findById(id);
});
