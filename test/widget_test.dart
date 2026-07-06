// Smoke test: the app boots to the medications list and shows the empty state.
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medtrack/app/app.dart';
import 'package:medtrack/data/local/database.dart';
import 'package:medtrack/data/local/database_provider.dart';

void main() {
  setUpAll(() {
    // Avoid google_fonts scheduling a network fetch (and a lingering timer) in
    // tests — fall back to the bundled default font synchronously.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App boots to the medications list with an empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
            final db = AppDatabase.forTesting(NativeDatabase.memory());
            ref.onDispose(db.close);
            return db;
          }),
        ],
        child: const MedTrackApp(),
      ),
    );
    await tester.pumpAndSettle();

    // The list screen shell renders: title and both tabs.
    expect(find.text('Medications'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Inactive'), findsOneWidget);

    // With no data yet, the empty state is shown.
    expect(find.text('No medications yet'), findsWidgets);

    // Unmount so Drift's stream-cancel timer fires before the test tears down
    // (otherwise the pending zero-duration timer trips the test invariants).
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  });
}
