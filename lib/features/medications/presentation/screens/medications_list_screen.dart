import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../widgets/medications_empty_state.dart';

/// Home screen: lists the user's medications split into Active / Inactive tabs.
///
/// Day 1 renders the shell (app bar, tabs, FAB, empty state) with no data yet;
/// the list content and the active/inactive split arrive on Day 2 once the
/// repository and providers exist.
class MedicationsListScreen extends ConsumerWidget {
  const MedicationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.medicationsListTitle),
          actions: [
            IconButton(
              icon: const Icon(Symbols.settings),
              tooltip: context.l10n.settingsTitle,
              onPressed: () => context.pushNamed(RouteName.settings),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: context.l10n.medicationsTabActive),
              Tab(text: context.l10n.medicationsTabInactive),
            ],
          ),
        ),
        body: const TabBarView(
          children: [MedicationsEmptyState(), MedicationsEmptyState()],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.pushNamed(RouteName.medicationForm),
          icon: const Icon(Symbols.add),
          label: Text(context.l10n.addMedication),
        ),
      ),
    );
  }
}
