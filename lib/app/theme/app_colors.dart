import 'package:flutter/material.dart';

/// Brand seed for the generated [ColorScheme], plus the dose-status colors.
/// The status colors are centralised because they carry meaning and must stay
/// legible in both light and dark themes.
abstract final class AppColors {
  static const Color seed = Color(0xFF1B9E8F);

  // Dose-status semantics. Tuned to stay legible on both light and dark
  // surfaces; widgets should reference these rather than raw hex values.
  static const Color statusTaken = Color(0xFF2E9E5B);
  static const Color statusMissed = Color(0xFFD64545);
  static const Color statusSkipped = Color(0xFFE0A030);
  static const Color statusScheduled = Color(0xFF4C8DD6);
  static const Color statusPostponed = Color(0xFF8A7BD8);
}
