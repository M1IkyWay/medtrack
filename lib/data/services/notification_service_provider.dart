import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_service.dart';

/// Overridden in `main()` with the already-initialized instance.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError(
    'notificationServiceProvider must be overridden in main()',
  );
});
