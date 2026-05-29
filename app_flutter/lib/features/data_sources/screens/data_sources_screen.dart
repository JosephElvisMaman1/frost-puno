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
        const SizedBox(height: 18),
        const _ValidationPipelineCard(),
      ],
    );

    if (!showAppBar) {
      return SafeArea(child: ResponsiveContent(child: body));
    }
    return PageScaffold(child: body);
  }
}

class _ValidationPipelineCard extends StatelessWidget {
  const _ValidationPipelineCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final steps = [
      ('1', 'Clima actual', 'Open-Meteo alimenta la app en tiempo real.'),
      ('2', 'SENAMHI', 'Observaciones oficiales validan eventos reales.'),
      ('3', 'Feedback', 'Supabase guarda correcciones y evidencia de campo.'),
      ('4', 'Nuevo modelo', 'ML compara versiones antes de promover.'),
    ];
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline, color: AppColors.warmAmber),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ciclo de mejora del modelo',
                  style: textTheme.headlineMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final step in steps) ...[
            _PipelineStep(
              number: step.$1,
              title: step.$2,
              description: step.$3,
            ),
            if (step != steps.last) const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
          Text(
            'Este flujo evita entrenar automaticamente con datos dudosos y mantiene trazabilidad academica.',
            style: textTheme.bodyMedium?.copyWith(
              color: onSurface.withValues(alpha: 0.66),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _PipelineStep extends StatelessWidget {
  const _PipelineStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.mutedTeal,
          child: Text(number, style: textTheme.labelSmall),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleMedium),
              Text(description, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
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
