import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

/// Holds the `SharedPreferences` instance. Overridden in `main()` with the
/// value loaded before `runApp`, so settings are available synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  );
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
});

/// Exposes the current [AppSettings] and mutations that persist changes.
final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(settingsRepositoryProvider).load();

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await ref.read(settingsRepositoryProvider).save(state);
  }

  /// Sets the language override, or clears it (follow system) when [code] is
  /// null.
  Future<void> setLanguage(String? code) async {
    state = code == null
        ? state.copyWith(clearLanguage: true)
        : state.copyWith(languageCode: code);
    await ref.read(settingsRepositoryProvider).save(state);
  }
}
