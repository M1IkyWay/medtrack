import 'package:drift/drift.dart';

import '../../features/medications/domain/models/local_time.dart';

/// Persists `List<LocalTime>` as a compact CSV of minutes-from-midnight
/// (e.g. `"480,1200"` for 08:00 and 20:00).
class LocalTimeListConverter extends TypeConverter<List<LocalTime>, String> {
  const LocalTimeListConverter();

  @override
  List<LocalTime> fromSql(String fromDb) => fromDb.isEmpty
      ? const []
      : fromDb
            .split(',')
            .map((s) => LocalTime.fromMinutes(int.parse(s)))
            .toList();

  @override
  String toSql(List<LocalTime> value) =>
      value.map((t) => t.minutesFromMidnight).join(',');
}

/// Persists `List<int>` (e.g. weekdays 1..7) as a CSV string.
class IntListConverter extends TypeConverter<List<int>, String> {
  const IntListConverter();

  @override
  List<int> fromSql(String fromDb) =>
      fromDb.isEmpty ? const [] : fromDb.split(',').map(int.parse).toList();

  @override
  String toSql(List<int> value) => value.join(',');
}
