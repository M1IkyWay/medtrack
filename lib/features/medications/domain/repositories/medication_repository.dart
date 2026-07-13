import '../models/dose_log.dart';
import '../models/medication.dart';
import '../models/medication_enums.dart';

/// Read/write contract for medications and their dose history. Lives in the
/// domain layer so the rest of the app depends on this, not on Drift.
abstract interface class MedicationRepository {
  /// Newest first; [activeOnly] false streams the inactive ones instead.
  Stream<List<Medication>> watchMedications({required bool activeOnly});

  Future<Medication?> findById(int id);

  /// Returns the new row's id.
  Future<int> add(Medication medication);

  Future<void> update(Medication medication);

  /// Cascades to the schedule and dose logs.
  Future<void> delete(int id);

  Future<void> setActive(int id, {required bool isActive});

  Stream<List<DoseLog>> watchDoseLogs(int medicationId);

  /// Upserts by (medicationId, scheduledTime), so acting on the same dose twice
  /// updates one row instead of duplicating.
  Future<void> recordDose({
    required int medicationId,
    required DateTime scheduledTime,
    required DoseStatus status,
    DateTime? actualTime,
    String? notes,
  });
}
