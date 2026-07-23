import 'package:flutter/material.dart';

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
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          children: [
            const SectionHeader(
              title: 'Ajustes',
              subtitle:
                  'Configura tus alarmas de helada y el perfil con el que usas la app.',
            ),
            const SizedBox(height: 24),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Activar alertas de helada'),
                    subtitle: const Text(
                      'Muestra el aviso en Inicio y envía notificación en el celular.',
                    ),
                    value: settings.alertsEnabled,
                    onChanged: settings.setAlertsEnabled,
                  ),
                  const Divider(height: 24),
                  Text(
                    'Avisarme si la mínima baja de ${settings.alertThreshold.toStringAsFixed(0)} °C',
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
                  Text('Perfil', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Prioriza qué alertas ves en Inicio.',
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
                        label: Text(p.label),
                        selected: selected,
                        onSelected: (_) => settings.setProfile(p),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
