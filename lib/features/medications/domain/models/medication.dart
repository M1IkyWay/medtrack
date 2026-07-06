import 'package:equatable/equatable.dart';

import 'medication_enums.dart';
import 'schedule.dart';

/// A medication the user is tracking, together with its [Schedule].
///
/// The core domain entity. [id] is `null` for a not-yet-persisted medication;
/// the repository assigns one on insert. Dose history is not embedded here — it
/// is queried separately from the repository to keep this model lightweight.
class Medication extends Equatable {
  const Medication({
    required this.name,
    required this.form,
    required this.doseUnit,
    required this.doseAmount,
    required this.schedule,
    required this.createdAt,
    required this.updatedAt,
    this.id,
    this.genericName,
    this.notes,
    this.prescribedFor,
    this.isActive = true,
  });

  /// Persistence id; `null` until saved.
  final int? id;

  final String name;

  /// Active ingredient / international name (e.g. "Ibuprofen").
  final String? genericName;

  final MedicationForm form;
  final DoseUnit doseUnit;

  /// Amount taken per dose, in [doseUnit] (e.g. 400 for "400 mg").
  final double doseAmount;

  /// Free-form notes (e.g. doctor's instructions).
  final String? notes;

  /// The condition this was prescribed for (e.g. "Headache", "Diabetes").
  final String? prescribedFor;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Whether this is an ongoing/active course (vs. finished or paused).
  final bool isActive;

  final Schedule schedule;

  /// Whether this instance has been persisted.
  bool get isPersisted => id != null;

  Medication copyWith({
    int? id,
    String? name,
    String? genericName,
    MedicationForm? form,
    DoseUnit? doseUnit,
    double? doseAmount,
    String? notes,
    String? prescribedFor,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Schedule? schedule,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      form: form ?? this.form,
      doseUnit: doseUnit ?? this.doseUnit,
      doseAmount: doseAmount ?? this.doseAmount,
      notes: notes ?? this.notes,
      prescribedFor: prescribedFor ?? this.prescribedFor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      schedule: schedule ?? this.schedule,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    genericName,
    form,
    doseUnit,
    doseAmount,
    notes,
    prescribedFor,
    createdAt,
    updatedAt,
    isActive,
    schedule,
  ];
}
