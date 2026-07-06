import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Ergonomic accessors on [BuildContext] for the most common lookups.
///
/// Keeps widget code terse and consistent: `context.l10n.appTitle` instead of
/// `AppLocalizations.of(context)!.appTitle`, and `context.colors` /
/// `context.textStyles` instead of the longer `Theme.of(context)` chains.
extension ContextX on BuildContext {
  /// Localized strings for the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// The active color scheme.
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// The active text theme.
  TextTheme get textStyles => Theme.of(this).textTheme;
}
