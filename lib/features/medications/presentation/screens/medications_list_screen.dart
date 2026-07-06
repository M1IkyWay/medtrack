import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../application/medication_providers.dart';
import '../widgets/medication_card.dart';
import '../widgets/medications_empty_state.dart';

class MedicationsListScreen extends StatelessWidget {
  const MedicationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          children: [
            _MedicationsTab(activeOnly: true),
            _MedicationsTab(activeOnly: false),
          ],
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

class _MedicationsTab extends ConsumerWidget {
  const _MedicationsTab({required this.activeOnly});

  final bool activeOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationsProvider(activeOnly));

    return medications.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (items) {
        if (items.isEmpty) {
          return MedicationsEmptyState(activeOnly: activeOnly);
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 96),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final medication = items[index];
            return MedicationCard(
              medication: medication,
              onTap: () => context.pushNamed(
                RouteName.medicationDetails,
                pathParameters: {'id': '${medication.id}'},
              ),
            );
          },
        );
      },
    );
  }
}
