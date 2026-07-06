import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';

/// App settings: language, theme, notification sound, and about.
///
/// Day 1 is a placeholder; the real controls arrive on Day 4 (polish).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: const Center(child: Text('Settings — coming on Day 4')),
    );
  }
}
