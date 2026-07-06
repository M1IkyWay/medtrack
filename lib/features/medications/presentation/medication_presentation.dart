import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/models/medication_enums.dart';

/// Presentation-only mappings for the medical enums: icons and localized
/// labels. Kept out of the domain so the models stay framework-free.

extension MedicationFormPresentation on MedicationForm {
  IconData get icon => switch (this) {
    MedicationForm.tablet => Symbols.medication,
    MedicationForm.capsule => Symbols.pill,
    MedicationForm.liquid => Symbols.local_drink,
    MedicationForm.drops => Symbols.water_drop,
    MedicationForm.injection => Symbols.vaccines,
    MedicationForm.inhaler => Symbols.air,
    MedicationForm.patch => Symbols.healing,
    MedicationForm.cream => Symbols.format_color_fill,
    MedicationForm.ointment => Symbols.opacity,
    MedicationForm.suppository => Symbols.medication,
    MedicationForm.spray => Symbols.sanitizer,
    MedicationForm.other => Symbols.more_horiz,
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
  /// Standard medical abbreviations — intentionally not localized (they are
  /// used identically across the app's supported locales).
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
