import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// User-configurable app settings: theme brightness and language override.
///
/// [languageCode] is `null` when the app should follow the system locale;
/// otherwise it is one of [supportedLanguageCodes].
class AppSettings extends Equatable {
  const AppSettings({this.themeMode = ThemeMode.system, this.languageCode});

  final ThemeMode themeMode;
  final String? languageCode;

  /// Language codes the user can pick explicitly (in addition to "system").
  static const supportedLanguageCodes = ['en', 'uk', 'es', 'de'];

  /// The effective [Locale], or `null` to follow the system locale.
  Locale? get locale => languageCode == null ? null : Locale(languageCode!);

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool clearLanguage = false,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: clearLanguage ? null : (languageCode ?? this.languageCode),
    );
  }

  @override
  List<Object?> get props => [themeMode, languageCode];
}
