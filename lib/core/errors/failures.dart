/// Domain-level failures for MedTrack.
///
/// The app is fully offline, so failures are local: persistence errors from the
/// Drift database and denied OS permissions (notifications). Presenting these
/// as typed values (rather than raw exceptions) lets the UI map each case to a
/// clear, localized message.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

/// A read/write against the local database failed.
final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// A required OS permission (e.g. notifications) was denied.
final class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// A catch-all for unexpected errors that don't fit a more specific case.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
