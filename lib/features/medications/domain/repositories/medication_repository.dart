import '../models/dose_log.dart';
import '../models/medication.dart';

/// Contract for reading and writing medications and their dose history.
///
/// Lives in the domain layer so `application`/`presentation` depend on this
/// abstraction, not on Drift. The Drift-backed implementation is in
/// `data/repositories`.
abstract interface class MedicationRepository {
  /// Streams medications, newest first. When [activeOnly] is true only active
  /// courses are emitted; when false, only inactive ones.
  Stream<List<Medication>> watchMedications({required bool activeOnly});

  /// Loads a single medication (with its schedule), or `null` if absent.
  Future<Medication?> findById(int id);

  /// Inserts a new medication and returns its assigned id.
  Future<int> add(Medication medication);

  /// Updates an existing medication (must have a non-null id).
  Future<void> update(Medication medication);

  /// Deletes a medication and its dependent rows (schedule, dose logs).
  Future<void> delete(int id);

  /// Toggles a medication's active flag without rewriting the whole row.
  Future<void> setActive(int id, {required bool isActive});

  /// Streams the dose history for one medication, most recent first.
  Stream<List<DoseLog>> watchDoseLogs(int medicationId);
}
