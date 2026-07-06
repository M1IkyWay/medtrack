import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';

/// One [AppDatabase] per app run. Override with `AppDatabase.forTesting(...)`
/// in tests.
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
