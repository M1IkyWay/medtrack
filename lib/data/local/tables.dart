import 'package:drift/drift.dart';

import '../../features/medications/domain/models/medication_enums.dart';
import 'converters.dart';

/// Drift table definitions backing the medical domain models.
///
/// Enums are stored via `intEnum` (by ordinal index) — see the append-only
/// warning in `medication_enums.dart`. List-valued fields use the CSV
/// [TypeConverter]s in `converters.dart`. Child tables cascade-delete with
/// their parent medication (foreign keys are enabled in the database).

@DataClassName('MedicationRow')
class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get genericName => text().nullable()();
  IntColumn get form => intEnum<MedicationForm>()();
  IntColumn get doseUnit => intEnum<DoseUnit>()();
  RealColumn get doseAmount => real()();
  TextColumn get notes => text().nullable()();
  TextColumn get prescribedFor => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

@DataClassName('ScheduleRow')
class Schedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer()
      .references(Medications, #id, onDelete: KeyAction.cascade)
      .unique()();
  IntColumn get type => intEnum<ScheduleType>()();
  TextColumn get times => text().map(const LocalTimeListConverter())();
  TextColumn get daysOfWeek =>
      text().map(const IntListConverter()).nullable()();
  IntColumn get intervalDays => integer().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  IntColumn get totalDoses => integer().nullable()();
  IntColumn get mealRelation => intEnum<MealRelation>()();
}

@DataClassName('DoseLogRow')
class DoseLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId =>
      integer().references(Medications, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get scheduledTime => dateTime()();
  DateTimeColumn get actualTime => dateTime().nullable()();
  IntColumn get status => intEnum<DoseStatus>()();
  TextColumn get notes => text().nullable()();
}
