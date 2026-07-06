import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_service.dart';

/// Exposes the app-wide [NotificationService].
///
/// Overridden in `main()` with the instance that has already been initialized
/// (timezone data loaded, plugin ready). Accessing it without that override is
/// a programming error.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError(
    'notificationServiceProvider must be overridden in main()',
  );
});
