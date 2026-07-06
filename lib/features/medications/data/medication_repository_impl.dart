import 'package:drift/drift.dart';

import '../../../data/local/database.dart';
import '../domain/models/dose_log.dart';
import '../domain/models/medication.dart';
import '../domain/models/schedule.dart';
import '../domain/repositories/medication_repository.dart';

/// Drift-backed [MedicationRepository].
///
/// Owns all row ↔ domain mapping so the rest of the app only ever sees domain
/// models. Writes that span the medication and its schedule run in a single
/// transaction to keep the two tables consistent.
class MedicationRepositoryImpl implements MedicationRepository {
  MedicationRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Medication>> watchMedications({required bool activeOnly}) {
    final query =
        _db.select(_db.medications).join([
            innerJoin(
              _db.schedules,
              _db.schedules.medicationId.equalsExp(_db.medications.id),
            ),
          ])
          ..where(_db.medications.isActive.equals(activeOnly))
          ..orderBy([OrderingTerm.desc(_db.medications.createdAt)]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => _toDomain(
              row.readTable(_db.medications),
              row.readTable(_db.schedules),
            ),
          )
          .toList(),
    );
  }

  @override
  Future<Medication?> findById(int id) async {
    final query = _db.select(_db.medications).join([
      innerJoin(
        _db.schedules,
        _db.schedules.medicationId.equalsExp(_db.medications.id),
      ),
    ])..where(_db.medications.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _toDomain(
      row.readTable(_db.medications),
      row.readTable(_db.schedules),
    );
  }

  @override
  Future<int> add(Medication medication) {
    return _db.transaction(() async {
      final id = await _db
          .into(_db.medications)
          .insert(_medicationCompanion(medication));
      await _db
          .into(_db.schedules)
          .insert(_scheduleCompanion(medication.schedule, medicationId: id));
      return id;
    });
  }

  @override
  Future<void> update(Medication medication) {
    final id = medication.id;
    if (id == null) {
      throw ArgumentError('Cannot update a medication without an id');
    }
    return _db.transaction(() async {
      await (_db.update(
        _db.medications,
      )..where((t) => t.id.equals(id))).write(_medicationCompanion(medication));
      await (_db.update(_db.schedules)..where((t) => t.medicationId.equals(id)))
          .write(_scheduleCompanion(medication.schedule, medicationId: id));
    });
  }

  @override
  Future<void> delete(int id) async {
    // Foreign keys are ON, so the schedule and dose logs cascade away.
    await (_db.delete(_db.medications)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> setActive(int id, {required bool isActive}) async {
    await (_db.update(_db.medications)..where((t) => t.id.equals(id))).write(
      MedicationsCompanion(
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Stream<List<DoseLog>> watchDoseLogs(int medicationId) {
    final query = _db.select(_db.doseLogs)
      ..where((t) => t.medicationId.equals(medicationId))
      ..orderBy([(t) => OrderingTerm.desc(t.scheduledTime)]);
    return query.watch().map((rows) => rows.map(_doseLogToDomain).toList());
  }

  // --- Mapping helpers -------------------------------------------------------

  Medication _toDomain(MedicationRow m, ScheduleRow s) => Medication(
    id: m.id,
    name: m.name,
    genericName: m.genericName,
    form: m.form,
    doseUnit: m.doseUnit,
    doseAmount: m.doseAmount,
    notes: m.notes,
    prescribedFor: m.prescribedFor,
    createdAt: m.createdAt,
    updatedAt: m.updatedAt,
    isActive: m.isActive,
    schedule: Schedule(
      type: s.type,
      times: s.times,
      daysOfWeek: s.daysOfWeek,
      intervalDays: s.intervalDays,
      startDate: s.startDate,
      endDate: s.endDate,
      totalDoses: s.totalDoses,
      mealRelation: s.mealRelation,
    ),
  );

  DoseLog _doseLogToDomain(DoseLogRow r) => DoseLog(
    id: r.id,
    medicationId: r.medicationId,
    scheduledTime: r.scheduledTime,
    actualTime: r.actualTime,
    status: r.status,
    notes: r.notes,
  );

  MedicationsCompanion _medicationCompanion(Medication m) =>
      MedicationsCompanion(
        id: m.id == null ? const Value.absent() : Value(m.id!),
        name: Value(m.name),
        genericName: Value(m.genericName),
        form: Value(m.form),
        doseUnit: Value(m.doseUnit),
        doseAmount: Value(m.doseAmount),
        notes: Value(m.notes),
        prescribedFor: Value(m.prescribedFor),
        createdAt: Value(m.createdAt),
        updatedAt: Value(m.updatedAt),
        isActive: Value(m.isActive),
      );

  SchedulesCompanion _scheduleCompanion(
    Schedule s, {
    required int medicationId,
  }) => SchedulesCompanion(
    medicationId: Value(medicationId),
    type: Value(s.type),
    times: Value(s.times),
    daysOfWeek: Value(s.daysOfWeek),
    intervalDays: Value(s.intervalDays),
    startDate: Value(s.startDate),
    endDate: Value(s.endDate),
    totalDoses: Value(s.totalDoses),
    mealRelation: Value(s.mealRelation),
  );
}
