import 'package:equatable/equatable.dart';

import 'medication_enums.dart';

/// A single recorded (or expected) dose — the unit of adherence history: when
/// it was scheduled, when it was actually taken (if at all), and its status.
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
  final int medicationId;
  final DateTime scheduledTime;

  /// `null` unless taken/postponed.
  final DateTime? actualTime;

  final DoseStatus status;
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
