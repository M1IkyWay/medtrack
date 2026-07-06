import 'dart:developer' as developer;

/// Tiny logging facade over `dart:developer`.
///
/// MedTrack is privacy-first and ships no analytics, so this is the single,
/// intentional place where diagnostic output happens. Using `dart:developer`
/// (instead of `print`) keeps logs structured and satisfies `avoid_print`.
abstract final class AppLogger {
  static void debug(String message) => developer.log(message, name: 'medtrack');

  static void error(String message, {Object? error, StackTrace? stackTrace}) =>
      developer.log(
        message,
        name: 'medtrack',
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
}
