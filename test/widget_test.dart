// Smoke test: the app boots to the medications list and shows the empty state.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/app/app.dart';

void main() {
  testWidgets('App boots to the medications list with an empty state', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MedTrackApp()));
    await tester.pumpAndSettle();

    // The list screen shell renders: title and both tabs.
    expect(find.text('Medications'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Inactive'), findsOneWidget);

    // With no data yet, the empty state is shown.
    expect(find.text('No medications yet'), findsWidgets);
  });
}
