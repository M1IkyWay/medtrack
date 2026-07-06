import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/data/local/database.dart';
import 'package:medtrack/features/medications/data/medication_repository_impl.dart';
import 'package:medtrack/features/medications/domain/models/local_time.dart';
import 'package:medtrack/features/medications/domain/models/medication.dart';
import 'package:medtrack/features/medications/domain/models/medication_enums.dart';
import 'package:medtrack/features/medications/domain/models/schedule.dart';

void main() {
  late AppDatabase db;
  late MedicationRepositoryImpl repository;

  Medication sample() {
    final now = DateTime(2026, 1, 1, 8);
    return Medication(
      name: 'Ibuprofen',
      genericName: 'Ibuprofen',
      prescribedFor: 'Headache',
      form: MedicationForm.tablet,
      doseUnit: DoseUnit.mg,
      doseAmount: 400,
      createdAt: now,
      updatedAt: now,
      schedule: const Schedule(
        type: ScheduleType.daily,
        times: [LocalTime(9, 0), LocalTime(21, 0)],
        mealRelation: MealRelation.afterMeal,
      ),
    );
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = MedicationRepositoryImpl(db);
  });

  tearDown(() => db.close());

  test(
    'add then findById round-trips the medication and its schedule',
    () async {
      final id = await repository.add(sample());

      final loaded = await repository.findById(id);

      expect(loaded, isNotNull);
      expect(loaded!.id, id);
      expect(loaded.name, 'Ibuprofen');
      expect(loaded.doseAmount, 400);
      expect(loaded.form, MedicationForm.tablet);
      expect(loaded.schedule.type, ScheduleType.daily);
      expect(loaded.schedule.times, const [LocalTime(9, 0), LocalTime(21, 0)]);
      expect(loaded.schedule.mealRelation, MealRelation.afterMeal);
    },
  );

  test('watchMedications splits active and inactive', () async {
    final id = await repository.add(sample());

    expect(
      await repository.watchMedications(activeOnly: true).first,
      hasLength(1),
    );
    expect(await repository.watchMedications(activeOnly: false).first, isEmpty);

    await repository.setActive(id, isActive: false);

    expect(await repository.watchMedications(activeOnly: true).first, isEmpty);
    expect(
      await repository.watchMedications(activeOnly: false).first,
      hasLength(1),
    );
  });

  test('update rewrites fields and schedule', () async {
    final id = await repository.add(sample());
    final loaded = await repository.findById(id);

    await repository.update(
      loaded!.copyWith(
        name: 'Nurofen',
        doseAmount: 200,
        schedule: loaded.schedule.copyWith(type: ScheduleType.asNeeded),
      ),
    );

    final updated = await repository.findById(id);
    expect(updated!.name, 'Nurofen');
    expect(updated.doseAmount, 200);
    expect(updated.schedule.type, ScheduleType.asNeeded);
  });

  test('delete removes the medication', () async {
    final id = await repository.add(sample());
    await repository.delete(id);
    expect(await repository.findById(id), isNull);
  });
}
