import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inter type scale, shared by the light and dark themes.
abstract final class AppTypography {
  static TextTheme textTheme(TextTheme base) =>
      GoogleFonts.interTextTheme(base);
}
