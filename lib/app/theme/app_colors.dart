import 'package:flutter/material.dart';

/// Central palette for MedTrack.
///
/// The Material 3 [ColorScheme] is derived from [seed] so the whole app stays
/// tonally consistent. Semantic dose-status colors live here too, because they
/// carry medical meaning (taken / missed / skipped / scheduled) and must read
/// clearly in both light and dark themes rather than being picked ad hoc in
/// widgets.
abstract final class AppColors {
  /// Calm medical teal-green — the brand seed for the generated color scheme.
  static const Color seed = Color(0xFF1B9E8F);

  // Dose-status semantics. Tuned to stay legible on both light and dark
  // surfaces; widgets should reference these rather than raw hex values.
  static const Color statusTaken = Color(0xFF2E9E5B);
  static const Color statusMissed = Color(0xFFD64545);
  static const Color statusSkipped = Color(0xFFE0A030);
  static const Color statusScheduled = Color(0xFF4C8DD6);
  static const Color statusPostponed = Color(0xFF8A7BD8);
}
