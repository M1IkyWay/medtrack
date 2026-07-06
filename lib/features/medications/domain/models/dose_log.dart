import 'package:equatable/equatable.dart';

import 'medication_enums.dart';

/// A single recorded (or expected) dose for a medication.
///
/// The unit of adherence history: when a dose was scheduled, when it was
/// actually taken (if at all) and its [DoseStatus]. Dose-logging UI and
/// scheduling land on Day 3; the model and table are defined now so the schema
/// is complete.
class DoseLog extends Equatable {
  const DoseLog({
    required this.medicationId,
    required this.scheduledTime,
    required this.status,
    this.id,
    this.actualTime,
    this.notes,
  });

  final int? id;

  /// The medication this dose belongs to.
  final int medicationId;

  /// When the dose was due.
  final DateTime scheduledTime;

  /// When it was actually taken; `null` unless [status] is
  /// [DoseStatus.taken] / [DoseStatus.postponed].
  final DateTime? actualTime;

  final DoseStatus status;

  /// Optional note (e.g. "skipped — nausea").
  final String? notes;

  DoseLog copyWith({
    int? id,
    int? medicationId,
    DateTime? scheduledTime,
    DateTime? actualTime,
    DoseStatus? status,
    String? notes,
  }) {
    return DoseLog(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualTime: actualTime ?? this.actualTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    medicationId,
    scheduledTime,
    actualTime,
    status,
    notes,
  ];
}
