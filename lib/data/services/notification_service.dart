import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../core/utils/logger.dart';
import '../../features/medications/application/dose_scheduler.dart';
import '../../features/medications/domain/models/medication.dart';

/// Parsed contents of a reminder notification's payload.
class DoseNotificationPayload {
  const DoseNotificationPayload({
    required this.medicationId,
    required this.scheduledTime,
  });

  final int medicationId;
  final DateTime scheduledTime;

  /// Encodes as `"<medicationId>|<millisSinceEpoch>"`.
  String encode() => '$medicationId|${scheduledTime.millisecondsSinceEpoch}';

  static DoseNotificationPayload? tryParse(String? raw) {
    if (raw == null) return null;
    final parts = raw.split('|');
    if (parts.length != 2) return null;
    final id = int.tryParse(parts[0]);
    final millis = int.tryParse(parts[1]);
    if (id == null || millis == null) return null;
    return DoseNotificationPayload(
      medicationId: id,
      scheduledTime: DateTime.fromMillisecondsSinceEpoch(millis),
    );
  }
}

/// Wraps `flutter_local_notifications` for scheduling medication reminders.
///
/// Turns the pure [DoseScheduler] output into concrete zoned notifications, one
/// per upcoming dose within a rolling horizon (re-scheduled when medications
/// change). Notification taps are surfaced on [taps] so the app can open the
/// "take dose" flow.
///
/// NOTE: requires on-device verification — scheduling, permissions and delivery
/// cannot be exercised from unit tests.
class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<DoseNotificationPayload> _taps =
      StreamController<DoseNotificationPayload>.broadcast();

  static const _channelId = 'medication_reminders';
  static const _channelName = 'Medication reminders';
  // Notification-id slots reserved per medication (must exceed the scheduler's
  // `max`). Medication N owns ids [N * _slots, N * _slots + _slots).
  static const _slots = 100;

  /// Emits when the user taps a reminder while the app is running.
  Stream<DoseNotificationPayload> get taps => _taps.stream;

  Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (error, stack) {
      AppLogger.error(
        'Failed to resolve local timezone',
        error: error,
        stackTrace: stack,
      );
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = DoseNotificationPayload.tryParse(response.payload);
        if (payload != null) _taps.add(payload);
      },
    );
  }

  /// The payload of a reminder the app was cold-launched from, if any.
  Future<DoseNotificationPayload?> initialLaunchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return DoseNotificationPayload.tryParse(
        details!.notificationResponse?.payload,
      );
    }
    return null;
  }

  Future<bool> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    final androidGranted =
        await android?.requestNotificationsPermission() ?? true;
    final iosGranted =
        await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
        true;
    return androidGranted && iosGranted;
  }

  Future<void> scheduleMedication(Medication medication) async {
    final id = medication.id;
    if (id == null) return;
    await cancelMedication(id);
    if (!medication.isActive) return;

    final doses = DoseScheduler.upcomingDoses(
      medication.schedule,
      from: DateTime.now(),
      max: _slots - 1,
    );

    final base = id * _slots;
    for (var i = 0; i < doses.length; i++) {
      await _plugin.zonedSchedule(
        id: base + i,
        title: medication.name,
        body: _doseBody(medication),
        scheduledDate: tz.TZDateTime.from(doses[i], tz.local),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: DoseNotificationPayload(
          medicationId: id,
          scheduledTime: doses[i],
        ).encode(),
      );
    }
  }

  /// Re-fires a single reminder [delay] from now (used by "postpone"). Reuses
  /// the medication's last reserved id slot so it doesn't collide with the
  /// scheduled doses.
  Future<void> scheduleSnooze(
    Medication medication,
    DateTime originalScheduledTime, {
    Duration delay = const Duration(minutes: 30),
  }) async {
    final id = medication.id;
    if (id == null) return;
    await _plugin.zonedSchedule(
      id: id * _slots + (_slots - 1),
      title: medication.name,
      body: _doseBody(medication),
      scheduledDate: tz.TZDateTime.now(tz.local).add(delay),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: DoseNotificationPayload(
        medicationId: id,
        scheduledTime: originalScheduledTime,
      ).encode(),
    );
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Reminders to take your medication',
      importance: Importance.max,
      priority: Priority.high,
    ),
    // Present the reminder even while the app is in the foreground — otherwise
    // iOS silently drops it (which read as "reminder didn't fire" in review).
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
    ),
  );

  Future<void> cancelMedication(int medicationId) async {
    final base = medicationId * _slots;
    for (var i = 0; i < _slots; i++) {
      await _plugin.cancel(id: base + i);
    }
  }

  String _doseBody(Medication medication) => medication.prescribedFor == null
      ? 'Time for your dose'
      : 'Time for your dose · ${medication.prescribedFor}';

  void dispose() => _taps.close();
}
