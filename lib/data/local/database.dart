import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// The app's single Drift (SQLite) database.
///
/// Day 1 ships the connection scaffold with no tables yet — the medical schema
/// (medications, schedules, dose logs) lands on Day 2. Keeping the database
/// wired now lets the whole codegen pipeline (`build_runner` + `drift_dev`) be
/// validated before feature work begins.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  /// In-memory / injected executor for tests.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _open() => driftDatabase(name: 'medtrack');
}
