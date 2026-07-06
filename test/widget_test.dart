// Widget tests exercising app startup and the add-medication flow end to end
// (in-memory Drift DB, faked notifications and prefs).
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medtrack/app/app.dart';
import 'package:medtrack/data/local/database.dart';
import 'package:medtrack/data/local/database_provider.dart';
import 'package:medtrack/data/services/notification_service.dart';
import 'package:medtrack/data/services/notification_service_provider.dart';
import 'package:medtrack/features/settings/application/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// No-op notification service so app startup doesn't touch the platform plugin.
class _FakeNotificationService extends NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<DoseNotificationPayload?> initialLaunchPayload() async => null;

  @override
  Future<void> scheduleMedication(medication) async {}
}

/// Boots the full app with test doubles for its infrastructure.
Future<void> pumpApp(WidgetTester tester) async {
  // A tall surface so long forms render entirely on-screen (no off-stage
  // fields that enterText can't reach).
  tester.view.physicalSize = const Size(1200, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWith((ref) {
          final db = AppDatabase.forTesting(NativeDatabase.memory());
          ref.onDispose(db.close);
          return db;
        }),
        notificationServiceProvider.overrideWithValue(
          _FakeNotificationService(),
        ),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MedTrackApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Unmounts the app so Drift's stream-cancel timer fires before teardown checks.
Future<void> teardownApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

void main() {
  setUpAll(() {
    // Avoid google_fonts scheduling a network fetch (and a lingering timer).
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('boots to the medications list with an empty state', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Medications'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Inactive'), findsOneWidget);
    expect(find.text('No medications yet'), findsWidgets);

    await teardownApp(tester);
  });

  testWidgets('adding a medication shows it in the list', (tester) async {
    await pumpApp(tester);

    // Open the form.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('medicationName')), findsOneWidget);

    // Fill the required fields (schedule defaults to daily at 09:00).
    await tester.enterText(find.byKey(const Key('medicationName')), 'Aspirin');
    await tester.enterText(find.byKey(const Key('doseAmount')), '100');

    // Save and return to the list.
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Aspirin'), findsOneWidget);
    expect(find.text('No medications yet'), findsNothing);

    await teardownApp(tester);
  });
}
