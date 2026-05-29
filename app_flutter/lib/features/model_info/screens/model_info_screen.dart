import 'package:flutter/material.dart';

import '../../../core/api/frost_api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/model_info.dart';

class ModelInfoScreen extends StatelessWidget {
  const ModelInfoScreen({required this.apiService, super.key});

  final FrostApiService apiService;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: FutureBuilder<ModelInfo>(
        future: apiService.getModelInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('No se pudo cargar informacion del modelo.'),
            );
          }
          final info = snapshot.data!;
          final f1 = info.metrics['f1_macro'] ?? 0;
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            children: [
              const SectionHeader(
                title: 'Informacion del modelo',
                subtitle:
                    'Especificaciones tecnicas y metricas de rendimiento del clasificador climatico actual.',
              ),
              const SizedBox(height: 30),
              GlassCard(
                color: AppColors.softWhite,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _MonoLabel('ARQUITECTURA BASE'),
                          const SizedBox(height: 12),
                          Text(
                            info.modelName,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 20),
                          const Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              StatusChip(label: 'Ensemble Learning'),
                              StatusChip(label: 'Scikit-Learn'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.surfaceLow,
                      child: Icon(
                        Icons.account_tree_outlined,
                        color: AppColors.deepNavy,
                        size: 34,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _MetricPanel(
                icon: Icons.analytics_outlined,
                label: 'METRICA PRINCIPAL',
                value: f1.toStringAsFixed(2),
                suffix: 'F1 macro',
                description:
                    'Balance entre precision y exhaustividad para tres clases de riesgo.',
              ),
              const SizedBox(height: 18),
              _MetricPanel(
                icon: Icons.dataset_outlined,
                label: 'DATASET SIZE',
                value: info.datasetSize.toString(),
                suffix: 'muestras',
                description:
                    'Registros generados desde Open-Meteo y contexto territorial inicial.',
              ),
              const SizedBox(height: 18),
              GlassCard(
                color: AppColors.softWhite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _MonoLabel('VERSION Y ESTADO'),
                    const SizedBox(height: 14),
                    Text(
                      info.version,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.24),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: AppColors.success,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Quality Gate: Aprobado',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
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

class _MetricPanel extends StatelessWidget {
  const _MetricPanel({
    required this.icon,
    required this.label,
    required this.value,
    required this.suffix,
    required this.description,
  });

  final IconData icon;
  final String label;
  final String value;
  final String suffix;
  final String description;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              _MonoLabel(label),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.deepNavy,
                fontFamily: 'monospace',
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(text: value),
                TextSpan(
                  text: ' $suffix',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MonoLabel extends StatelessWidget {
  const _MonoLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontFamily: 'monospace',
        letterSpacing: 1.4,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
