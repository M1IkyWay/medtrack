import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// These domain imports are required by the generated `database.g.dart` part,
// which references the enum and value types used in the table columns.
import '../../features/medications/domain/models/local_time.dart';
import '../../features/medications/domain/models/medication_enums.dart';
import 'converters.dart';
import 'tables.dart';

part 'database.g.dart';

/// The app's single Drift (SQLite) database.
///
/// Holds the medical schema (medications, schedules, dose logs). Foreign keys
/// are enabled on open so deleting a medication cascades to its schedule and
/// dose logs.
@DriftDatabase(tables: [Medications, Schedules, DoseLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  /// In-memory / injected executor for tests.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _open() => driftDatabase(name: 'medtrack');
}
