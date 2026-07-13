import 'package:equatable/equatable.dart';

import 'medication_enums.dart';
import 'schedule.dart';

/// The core domain entity. [id] is `null` until persisted; dose history is not
/// embedded — it's queried separately so this model stays light.
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

  final int? id;
  final String name;

  /// Active ingredient, e.g. "Ibuprofen".
  final String? genericName;

  final MedicationForm form;
  final DoseUnit doseUnit;

  /// Amount per dose, in [doseUnit] (400 for "400 mg").
  final double doseAmount;

  final String? notes;
  final String? prescribedFor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Schedule schedule;

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
