import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Shorthands for the lookups widgets do most: `context.l10n`, `context.colors`,
/// `context.textStyles`.
extension ContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get textStyles => Theme.of(this).textTheme;
}
