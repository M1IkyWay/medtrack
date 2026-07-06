import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/settings/application/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> makeContainer([
    Map<String, Object> initial = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(initial);
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('defaults to system theme and locale', () async {
    final container = await makeContainer();
    final settings = container.read(settingsControllerProvider);
    expect(settings.themeMode, ThemeMode.system);
    expect(settings.languageCode, isNull);
    expect(settings.locale, isNull);
  });

  test('loads persisted values', () async {
    final container = await makeContainer({
      'settings.themeMode': 'dark',
      'settings.languageCode': 'uk',
    });
    final settings = container.read(settingsControllerProvider);
    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.locale, const Locale('uk'));
  });

  test('setThemeMode and setLanguage update and persist', () async {
    final container = await makeContainer();
    final controller = container.read(settingsControllerProvider.notifier);

    await controller.setThemeMode(ThemeMode.light);
    await controller.setLanguage('es');

    var settings = container.read(settingsControllerProvider);
    expect(settings.themeMode, ThemeMode.light);
    expect(settings.languageCode, 'es');

    // A fresh controller over the same prefs reads back the saved values.
    final reload = container.read(settingsRepositoryProvider).load();
    expect(reload.themeMode, ThemeMode.light);
    expect(reload.languageCode, 'es');

    // Clearing the language falls back to system.
    await controller.setLanguage(null);
    settings = container.read(settingsControllerProvider);
    expect(settings.languageCode, isNull);
  });
}
