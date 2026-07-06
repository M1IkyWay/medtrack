import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography for MedTrack, built on the Inter type family via `google_fonts`.
///
/// Kept in one place so both the light and dark themes share an identical text
/// scale and only the colors differ (handled by the [ColorScheme]).
abstract final class AppTypography {
  /// Applies the Inter font family across an existing Material [TextTheme]
  /// while preserving its sizes, weights and per-theme colors.
  static TextTheme textTheme(TextTheme base) =>
      GoogleFonts.interTextTheme(base);
}
