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
      tag: 'CLIMA',
      description:
          'Fuente climatica principal del MVP. Provee datos meteorologicos historicos y pronosticos por coordenadas.',
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
      tag: 'VALIDACION',
      description:
          'Fuente oficial propuesta para validar estaciones, avisos de heladas y calibracion climatica.',
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
          color: AppColors.surfaceHigh,
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.textSecondary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'El MVP usa datos abiertos y una semilla territorial curada. INEI no se usa como fuente de clima.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
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
