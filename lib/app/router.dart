import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/medications/presentation/screens/medication_details_screen.dart';
import '../features/medications/presentation/screens/medication_form_screen.dart';
import '../features/medications/presentation/screens/medications_list_screen.dart';
import '../features/medications/presentation/screens/take_dose_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

/// Route names. Kept hand-written (no `go_router_builder`) because a second
/// source generator clashes with `drift_dev` over the analyzer version.
abstract final class RouteName {
  static const medications = 'medications';
  static const medicationForm = 'medication-form';
  static const medicationDetails = 'medication-details';
  static const takeDose = 'take-dose';
  static const settings = 'settings';
}

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
            pageBuilder: (context, state) {
              final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
              return _transitionPage(
                state,
                MedicationFormScreen(medicationId: id),
              );
            },
          ),
          GoRoute(
            path: 'medication/:id',
            name: RouteName.medicationDetails,
            pageBuilder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return _transitionPage(
                state,
                MedicationDetailsScreen(medicationId: id),
              );
            },
          ),
          GoRoute(
            path: 'take',
            name: RouteName.takeDose,
            pageBuilder: (context, state) {
              final id = int.parse(state.uri.queryParameters['medicationId']!);
              final millis = int.parse(state.uri.queryParameters['time']!);
              return _transitionPage(
                state,
                TakeDoseScreen(
                  medicationId: id,
                  scheduledTime: DateTime.fromMillisecondsSinceEpoch(millis),
                ),
              );
            },
          ),
          GoRoute(
            path: 'settings',
            name: RouteName.settings,
            pageBuilder: (context, state) =>
                _transitionPage(state, const SettingsScreen()),
          ),
        ],
      ),
    ],
  );
});

/// Shared fade-and-rise transition for pushed routes.
CustomTransitionPage<void> _transitionPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
