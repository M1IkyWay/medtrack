/// Medical enumerations that give MedTrack its domain accuracy.
///
/// These are intentionally richer than a generic reminder app's "name + time".
/// They are pure Dart (no Flutter, no persistence) so the domain stays testable
/// and framework-independent. Presentation maps them to icons/localized labels;
/// persistence stores them by index.
///
/// IMPORTANT: these enums are stored by their ordinal index in the database
/// (Drift `intEnum`). Only ever **append** new values — never reorder or remove
/// existing ones, or previously saved rows will decode to the wrong value.
library;

/// The physical form a medication takes. Affects dosing UX, iconography and
/// which [DoseUnit]s make sense.
enum MedicationForm {
  tablet,
  capsule,
  liquid,
  drops,
  injection,
  inhaler,
  patch,
  cream,
  ointment,
  suppository,
  spray,
  other,
}

/// The unit a dose is measured in. The sensible set depends on the
/// [MedicationForm] (e.g. `puffs` for an inhaler, `iu`/`units` for insulin).
enum DoseUnit { mg, g, mcg, ml, iu, drops, puffs, tablets, units }

/// How a medication's schedule repeats over time.
enum ScheduleType {
  /// A single one-off dose.
  once,

  /// Every day at the configured times.
  daily,

  /// On specific weekdays (see [Schedule.daysOfWeek]).
  weekly,

  /// Once every N days (see [Schedule.intervalDays]).
  everyNDays,

  /// A finite course with a fixed duration / total dose count.
  course,

  /// As needed (PRN) — no fixed times; taken on symptom.
  asNeeded,
}

/// A dose's relationship to meals — clinically important for absorption and
/// tolerability of many drugs.
enum MealRelation { independent, beforeMeal, withMeal, afterMeal, emptyStomach }

/// The lifecycle state of a single scheduled dose.
enum DoseStatus {
  /// Planned; its time has not arrived yet.
  scheduled,

  /// Confirmed taken by the user.
  taken,

  /// Deliberately skipped by the user.
  skipped,

  /// The time passed with no response.
  missed,

  /// Deferred to a later time.
  postponed,
}
