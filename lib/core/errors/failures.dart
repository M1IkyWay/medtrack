/// Typed local failures, so the UI can map each to a clear localized message.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

final class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
