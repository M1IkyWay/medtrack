/// The medical enumerations — richer than a generic reminder app's "name + time".
///
/// IMPORTANT: stored by ordinal index (Drift `intEnum`), so only ever **append**
/// values — reordering or removing corrupts previously saved rows.
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

/// How a schedule repeats. `asNeeded` is PRN — no fixed times, taken on symptom.
enum ScheduleType { once, daily, weekly, everyNDays, course, asNeeded }

/// A dose's relationship to meals — clinically important for absorption and
/// tolerability of many drugs.
enum MealRelation { independent, beforeMeal, withMeal, afterMeal, emptyStomach }

/// The lifecycle state of a dose. `skipped` is deliberate; `missed` means the
/// time passed with no response.
enum DoseStatus { scheduled, taken, skipped, missed, postponed }
