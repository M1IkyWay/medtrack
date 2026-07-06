# The MedTrack Medical Data Model

Most medication reminder apps model a medication as a **name** and a **time**.
That collapses under real-world use: a nasal spray isn't dosed like an insulin
pen, "twice a day" doesn't say _with food or without_, a 7-day antibiotic course
isn't the same as an open-ended daily pill, and "as needed" painkillers have no
schedule at all.

MedTrack's domain layer is built to represent these distinctions faithfully. It
is **pure Dart** — no Flutter, no database types — so it stays testable and
framework-independent. Persistence (Drift) and presentation (Riverpod/Flutter)
map onto it at the edges.

---

## Entities

### `Medication`

The core entity — what the drug is and how it's dosed.

| Field | Type | Notes |
|---|---|---|
| `id` | `int?` | `null` until persisted |
| `name` | `String` | Brand/display name, e.g. "Nurofen" |
| `genericName` | `String?` | Active ingredient, e.g. "Ibuprofen" |
| `form` | `MedicationForm` | tablet, liquid, inhaler, patch … |
| `doseUnit` | `DoseUnit` | mg, ml, IU, puffs … |
| `doseAmount` | `double` | Amount per dose in `doseUnit` |
| `prescribedFor` | `String?` | Condition, e.g. "Headache" |
| `notes` | `String?` | Free-form instructions |
| `isActive` | `bool` | Ongoing vs. finished/archived |
| `schedule` | `Schedule` | When and how often (below) |
| `createdAt` / `updatedAt` | `DateTime` | Audit timestamps |

Dose history is **not** embedded — it is queried separately so the entity stays
lightweight.

### `Schedule`

A value object owned by its `Medication`. Only the fields relevant to the chosen
`type` are meaningful.

| Field | Type | Applies to |
|---|---|---|
| `type` | `ScheduleType` | always |
| `times` | `List<LocalTime>` | all except `asNeeded` |
| `daysOfWeek` | `List<int>?` | `weekly` (1 = Mon … 7 = Sun) |
| `intervalDays` | `int?` | `everyNDays` |
| `startDate` / `endDate` | `DateTime?` | bounded schedules |
| `totalDoses` | `int?` | `course` |
| `mealRelation` | `MealRelation` | always |

### `DoseLog`

One recorded (or expected) dose — the unit of adherence history.

| Field | Type | Notes |
|---|---|---|
| `id` | `int?` | |
| `medicationId` | `int` | owning medication |
| `scheduledTime` | `DateTime` | when it was due |
| `actualTime` | `DateTime?` | when actually taken |
| `status` | `DoseStatus` | taken / skipped / missed / postponed / scheduled |
| `notes` | `String?` | e.g. "skipped — nausea" |

Dose logs are **upserted by `(medicationId, scheduledTime)`**, so acting on the
same scheduled dose twice updates one row instead of creating duplicates.

---

## The enumerations

These are where the medical intent lives. All are stored by ordinal index
(Drift `intEnum`), so they are **append-only** — reordering would corrupt saved
rows.

### `MedicationForm`
`tablet · capsule · liquid · drops · injection · inhaler · patch · cream ·
ointment · suppository · spray · other`

The physical form drives iconography, categorisation and which units make sense.

### `DoseUnit`
`mg · g · mcg · ml · IU · drops · puffs · tablets · units`

Sensible units depend on the form — `puffs` for an inhaler, `IU`/`units` for
insulin, `drops` for eye drops.

### `ScheduleType`
| Value | Meaning |
|---|---|
| `once` | A single one-off dose |
| `daily` | Every day at the configured times |
| `weekly` | Specific weekdays |
| `everyNDays` | Every _N_ days (e.g. every 3rd day) |
| `course` | A finite course with a fixed dose count |
| `asNeeded` | PRN — no schedule, taken on symptom |

### `MealRelation`
`independent · beforeMeal · withMeal · afterMeal · emptyStomach`

Clinically significant: absorption and tolerability of many drugs depend on food
timing.

### `DoseStatus`
`scheduled · taken · skipped · missed · postponed`

Richer than a boolean "taken?" — it distinguishes a deliberate skip from an
unanswered miss from a deferral.

---

## Why not `TimeOfDay`?

Schedules store times as `LocalTime` — a small value object holding hour/minute
as **minutes-from-midnight**, not Flutter's `TimeOfDay`. This keeps the domain
free of `flutter/material` and makes it unit-testable in plain Dart. The UI
converts to/from `TimeOfDay` at its edge; persistence stores the integer.

---

## How it maps to storage

Three Drift tables — `Medications`, `Schedules` (one-to-one, `medicationId`
unique), `DoseLogs` (many). Foreign keys cascade, so deleting a medication
removes its schedule and history. List-valued fields (`times`, `daysOfWeek`) are
persisted via CSV `TypeConverter`s. The repository owns all row↔domain mapping,
so the rest of the app only ever sees domain models.

## How scheduling uses it

`DoseScheduler.upcomingDoses` is a pure function that turns a `Schedule` into the
concrete future `DateTime`s within a rolling horizon — honouring start/end dates,
weekday sets, intervals and course dose caps. The notification layer simply turns
those into local reminders. Because the function is pure, it is covered directly
by unit tests.
