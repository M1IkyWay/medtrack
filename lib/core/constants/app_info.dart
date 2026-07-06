/// Static app metadata surfaced on the About screen.
///
/// [version] mirrors `pubspec.yaml`; bump both together on release. Kept as a
/// constant to avoid a platform channel just to read the version string.
abstract final class AppInfo {
  static const version = '1.0.0';
  static const sourceUrl = 'https://github.com/milkyway/medtrack';
}
