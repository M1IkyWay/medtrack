import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/models/medication_enums.dart';

/// Icons and localized labels for the medical enums — kept out of the domain so
/// the models stay framework-free.

extension MedicationFormPresentation on MedicationForm {
  IconData get icon => switch (this) {
    MedicationForm.tablet => Icons.medication,
    MedicationForm.capsule => Icons.medication_outlined,
    MedicationForm.liquid => Icons.local_drink,
    MedicationForm.drops => Icons.water_drop,
    MedicationForm.injection => Icons.vaccines,
    MedicationForm.inhaler => Icons.air,
    MedicationForm.patch => Icons.healing,
    MedicationForm.cream => Icons.format_color_fill,
    MedicationForm.ointment => Icons.opacity,
    MedicationForm.suppository => Icons.medication,
    MedicationForm.spray => Icons.sanitizer,
    MedicationForm.other => Icons.more_horiz,
  };

  String label(AppLocalizations l10n) => switch (this) {
    MedicationForm.tablet => l10n.formTablet,
    MedicationForm.capsule => l10n.formCapsule,
    MedicationForm.liquid => l10n.formLiquid,
    MedicationForm.drops => l10n.formDrops,
    MedicationForm.injection => l10n.formInjection,
    MedicationForm.inhaler => l10n.formInhaler,
    MedicationForm.patch => l10n.formPatch,
    MedicationForm.cream => l10n.formCream,
    MedicationForm.ointment => l10n.formOintment,
    MedicationForm.suppository => l10n.formSuppository,
    MedicationForm.spray => l10n.formSpray,
    MedicationForm.other => l10n.formOther,
  };
}

extension DoseUnitPresentation on DoseUnit {
  /// Standard abbreviations — intentionally not localized.
  String get label => switch (this) {
    DoseUnit.mg => 'mg',
    DoseUnit.g => 'g',
    DoseUnit.mcg => 'mcg',
    DoseUnit.ml => 'ml',
    DoseUnit.iu => 'IU',
    DoseUnit.drops => 'drops',
    DoseUnit.puffs => 'puffs',
    DoseUnit.tablets => 'tabs',
    DoseUnit.units => 'units',
  };
}

extension ScheduleTypePresentation on ScheduleType {
  String label(AppLocalizations l10n) => switch (this) {
    ScheduleType.once => l10n.scheduleOnce,
    ScheduleType.daily => l10n.scheduleDaily,
    ScheduleType.weekly => l10n.scheduleWeekly,
    ScheduleType.everyNDays => l10n.scheduleEveryNDays,
    ScheduleType.course => l10n.scheduleCourse,
    ScheduleType.asNeeded => l10n.scheduleAsNeeded,
  };
}

extension MealRelationPresentation on MealRelation {
  String label(AppLocalizations l10n) => switch (this) {
    MealRelation.independent => l10n.mealIndependent,
    MealRelation.beforeMeal => l10n.mealBeforeMeal,
    MealRelation.withMeal => l10n.mealWithMeal,
    MealRelation.afterMeal => l10n.mealAfterMeal,
    MealRelation.emptyStomach => l10n.mealEmptyStomach,
  };
}

extension DoseStatusPresentation on DoseStatus {
  Color get color => switch (this) {
    DoseStatus.scheduled => AppColors.statusScheduled,
    DoseStatus.taken => AppColors.statusTaken,
    DoseStatus.skipped => AppColors.statusSkipped,
    DoseStatus.missed => AppColors.statusMissed,
    DoseStatus.postponed => AppColors.statusPostponed,
  };

  IconData get icon => switch (this) {
    DoseStatus.scheduled => Icons.schedule,
    DoseStatus.taken => Icons.check_circle,
    DoseStatus.skipped => Icons.cancel,
    DoseStatus.missed => Icons.error,
    DoseStatus.postponed => Icons.snooze,
  };

  String label(AppLocalizations l10n) => switch (this) {
    DoseStatus.scheduled => l10n.statusScheduled,
    DoseStatus.taken => l10n.statusTaken,
    DoseStatus.skipped => l10n.statusSkipped,
    DoseStatus.missed => l10n.statusMissed,
    DoseStatus.postponed => l10n.statusPostponed,
  };
}
