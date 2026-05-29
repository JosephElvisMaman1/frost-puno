import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/responsive_content.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/data_source_info.dart';

class DataSourcesScreen extends StatelessWidget {
  const DataSourcesScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  static const sources = [
    DataSourceInfo(
      name: 'Open-Meteo',
      tag: 'FALLBACK',
      description:
          'Fuente climatica global usada como respaldo operativo cuando SENAMHI no entrega datos disponibles para el MVP.',
      icon: Icons.cloud_outlined,
    ),
    DataSourceInfo(
      name: 'INEI',
      tag: 'TERRITORIO',
      description:
          'Fuente territorial, censal y agropecuaria para ubigeos, distritos, ruralidad y contexto local.',
      icon: Icons.map_outlined,
    ),
    DataSourceInfo(
      name: 'SENAMHI',
      tag: 'OFICIAL',
      description:
          'Fuente oficial peruana prioritaria para estaciones, avisos, validacion y futura calibracion climatica.',
      icon: Icons.device_thermostat,
    ),
    DataSourceInfo(
      name: 'MIDAGRI/SIEA',
      tag: 'AGRO',
      description:
          'Fuente agricola complementaria para produccion, cultivos relevantes e impacto productivo.',
      icon: Icons.agriculture_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      children: [
        const SectionHeader(
          title: 'Fuentes de datos',
          subtitle:
              'Referencias y origenes de la informacion analizada por el sistema.',
        ),
        const SizedBox(height: 28),
        for (final source in sources) ...[
          _SourceCard(source: source),
          const SizedBox(height: 18),
        ],
        GlassCard(
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.66),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'SENAMHI se prioriza como fuente oficial; si no hay datos operativos disponibles, FrostPuno usa Open-Meteo como fallback.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.68),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!showAppBar) {
      return SafeArea(child: ResponsiveContent(child: body));
    }
    return PageScaffold(child: body);
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.source});

  final DataSourceInfo source;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(source.icon, color: AppColors.mutedTeal, size: 30),
              const SizedBox(width: 12),
              Text(
                source.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 14),
          StatusChip(label: source.tag),
          const SizedBox(height: 14),
          Text(
            source.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
