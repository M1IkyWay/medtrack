import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_info.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../application/settings_providers.dart';

/// App settings: appearance (theme), language override and an about section.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Native language names (endonyms) — intentionally not localized.
  static const _languageNames = {
    'en': 'English',
    'uk': 'Українська',
    'es': 'Español',
    'de': 'Deutsch',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          _SectionHeader(l10n.settingsAppearance),
          RadioGroup<ThemeMode>(
            groupValue: settings.themeMode,
            onChanged: (mode) {
              if (mode != null) controller.setThemeMode(mode);
            },
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  title: Text(l10n.themeSystem),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  title: Text(l10n.themeLight),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  title: Text(l10n.themeDark),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _SectionHeader(l10n.settingsLanguage),
          RadioGroup<String?>(
            groupValue: settings.languageCode,
            onChanged: (code) => controller.setLanguage(code),
            child: Column(
              children: [
                RadioListTile<String?>(
                  value: null,
                  title: Text(l10n.languageSystem),
                ),
                for (final code in _languageNames.keys)
                  RadioListTile<String?>(
                    value: code,
                    title: Text(_languageNames[code]!),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          _SectionHeader(l10n.settingsAbout),
          ListTile(
            leading: const Icon(Symbols.info),
            title: Text(l10n.aboutVersion(AppInfo.version)),
          ),
          ListTile(
            leading: const Icon(Symbols.code),
            title: Text(l10n.aboutSource),
            trailing: const Icon(Symbols.open_in_new, size: 18),
            onTap: () => _openSource(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Row(
              children: [
                Icon(
                  Symbols.lock,
                  size: 18,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.aboutPrivacy,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSource(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launchUrl(
      Uri.parse(AppInfo.sourceUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) {
      messenger.showSnackBar(const SnackBar(content: Text(AppInfo.sourceUrl)));
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(
      text,
      style: context.textStyles.labelLarge?.copyWith(
        color: context.colors.primary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
