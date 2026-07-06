import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/medications/presentation/screens/medication_details_screen.dart';
import '../features/medications/presentation/screens/medication_form_screen.dart';
import '../features/medications/presentation/screens/medications_list_screen.dart';
import '../features/medications/presentation/screens/take_dose_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

/// Named routes for the app.
///
/// Hand-written (no `go_router_builder` codegen) to avoid a second
/// source-generator competing with `drift_dev` over the analyzer version. The
/// small helpers below keep call sites readable without that machinery.
abstract final class RouteName {
  static const medications = 'medications';
  static const medicationForm = 'medication-form';
  static const medicationDetails = 'medication-details';
  static const takeDose = 'take-dose';
  static const settings = 'settings';
}

/// The app's [GoRouter], exposed via Riverpod so it can later react to
/// providers (e.g. redirect on locale/theme or future auth needs).
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: RouteName.medications,
        builder: (context, state) => const MedicationsListScreen(),
        routes: [
          GoRoute(
            path: 'medication/new',
            name: RouteName.medicationForm,
            builder: (context, state) {
              final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
              return MedicationFormScreen(medicationId: id);
            },
          ),
          GoRoute(
            path: 'medication/:id',
            name: RouteName.medicationDetails,
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return MedicationDetailsScreen(medicationId: id);
            },
          ),
          GoRoute(
            path: 'take',
            name: RouteName.takeDose,
            builder: (context, state) {
              final id = int.parse(state.uri.queryParameters['medicationId']!);
              final millis = int.parse(state.uri.queryParameters['time']!);
              return TakeDoseScreen(
                medicationId: id,
                scheduledTime: DateTime.fromMillisecondsSinceEpoch(millis),
              );
            },
          ),
          GoRoute(
            path: 'settings',
            name: RouteName.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
