import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';

/// Exposes the singleton [AppDatabase] to the Riverpod graph.
///
/// Repositories read the database through this provider rather than
/// constructing their own, so there is exactly one connection per app run. In
/// tests, override this provider with `AppDatabase.forTesting(...)`.
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
