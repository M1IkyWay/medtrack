import 'dart:developer' as developer;

/// Logging facade over `dart:developer` — the app ships no analytics, so this
/// is the only place diagnostics go.
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
