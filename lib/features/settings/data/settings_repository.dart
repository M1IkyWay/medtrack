import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

/// Persists [AppSettings] in `SharedPreferences`. Reads are synchronous (the
/// instance is loaded at startup), so settings can drive `MaterialApp` without
/// an async gate.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _themeKey = 'settings.themeMode';
  static const _languageKey = 'settings.languageCode';

  AppSettings load() {
    final themeName = _prefs.getString(_themeKey);
    final language = _prefs.getString(_languageKey);
    return AppSettings(
      themeMode: ThemeMode.values.asNameMap()[themeName] ?? ThemeMode.system,
      languageCode: AppSettings.supportedLanguageCodes.contains(language)
          ? language
          : null,
    );
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setString(_themeKey, settings.themeMode.name);
    final language = settings.languageCode;
    if (language == null) {
      await _prefs.remove(_languageKey);
    } else {
      await _prefs.setString(_languageKey, language);
    }
  }
}
