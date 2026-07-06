import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Theme brightness and language override. [languageCode] is `null` to follow
/// the system locale, otherwise one of [supportedLanguageCodes].
class AppSettings extends Equatable {
  const AppSettings({this.themeMode = ThemeMode.system, this.languageCode});

  final ThemeMode themeMode;
  final String? languageCode;

  static const supportedLanguageCodes = ['en', 'uk', 'es', 'de'];

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
