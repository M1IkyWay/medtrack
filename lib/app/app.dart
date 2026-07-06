import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/notification_service.dart';
import '../data/services/notification_service_provider.dart';
import '../features/settings/application/settings_providers.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// Root widget: routing, theming, localization, and routing notification taps
/// into the take-dose flow.
class MedTrackApp extends ConsumerStatefulWidget {
  const MedTrackApp({super.key});

  @override
  ConsumerState<MedTrackApp> createState() => _MedTrackAppState();
}

class _MedTrackAppState extends ConsumerState<MedTrackApp> {
  StreamSubscription<DoseNotificationPayload>? _tapSubscription;

  @override
  void initState() {
    super.initState();
    final service = ref.read(notificationServiceProvider);
    _tapSubscription = service.taps.listen(_openTakeDose);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await service.requestPermissions();
      final launch = await service.initialLaunchPayload();
      if (launch != null) _openTakeDose(launch);
    });
  }

  @override
  void dispose() {
    _tapSubscription?.cancel();
    super.dispose();
  }

  void _openTakeDose(DoseNotificationPayload payload) {
    ref
        .read(routerProvider)
        .pushNamed(
          RouteName.takeDose,
          queryParameters: {
            'medicationId': '${payload.medicationId}',
            'time': '${payload.scheduledTime.millisecondsSinceEpoch}',
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsControllerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
