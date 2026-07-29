import 'package:flutter/material.dart';

import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/settings/user_settings.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/section_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = UserSettings.instance;
    return PageScaffold(
      child: AnimatedBuilder(
        animation: settings,
        builder: (context, _) {
          final s = AppStrings.current;
          return ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          children: [
            SectionHeader(
              title: s.settings,
              subtitle: s.settingsSubtitle,
            ),
            const SizedBox(height: 24),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.enableAlerts),
                    subtitle: Text(s.enableAlertsSub),
                    value: settings.alertsEnabled,
                    onChanged: settings.setAlertsEnabled,
                  ),
                  const Divider(height: 24),
                  Text(
                    s.alertThresholdLabel(
                      settings.alertThreshold.toStringAsFixed(0),
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    min: -12,
                    max: 2,
                    divisions: 14,
                    label: '${settings.alertThreshold.toStringAsFixed(0)} °C',
                    value: settings.alertThreshold,
                    onChanged: settings.alertsEnabled
                        ? settings.setThreshold
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.profile, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    s.profileHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.66),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: UserProfile.values.map((p) {
                      final selected = settings.profile == p;
                      return ChoiceChip(
                        label: Text(s.profileName(p.name)),
                        selected: selected,
                        onSelected: (_) => settings.setProfile(p),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.languageLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppLanguage.values.map((l) {
                      return ChoiceChip(
                        label: Text(l.label),
                        selected: settings.language == l,
                        onSelected: (_) => settings.setLanguage(l),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        );
        },
      ),
    );
  }
}
