import '../models/dose_log.dart';
import '../models/medication.dart';
import '../models/medication_enums.dart';

/// Read/write contract for medications and their dose history. Lives in the
/// domain layer so the rest of the app depends on this, not on Drift.
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

  /// Records the outcome of a dose. Upserts by (medicationId, scheduledTime)
  /// so acting on the same scheduled dose twice updates the one row rather than
  /// creating duplicates.
  Future<void> recordDose({
    required int medicationId,
    required DateTime scheduledTime,
    required DoseStatus status,
    DateTime? actualTime,
    String? notes,
  });
}
