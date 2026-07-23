import 'package:flutter/material.dart';

import '../../../core/api/frost_api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/responsive_content.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/cluster_info.dart';

Color tierColor(String tier) => switch (tier) {
  'alto' => AppColors.warmAmber,
  'medio' => AppColors.mediumRisk,
  _ => AppColors.lowRisk,
};

class ClustersScreen extends StatefulWidget {
  const ClustersScreen({required this.apiService, super.key});

  final FrostApiService apiService;

  @override
  State<ClustersScreen> createState() => _ClustersScreenState();
}

class _ClustersScreenState extends State<ClustersScreen> {
  late Future<ClustersResult> _future = widget.apiService.getClusters();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ResponsiveContent(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() => _future = widget.apiService.getClusters());
            await _future;
          },
          child: FutureBuilder<ClustersResult>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ErrorView(message: snapshot.error.toString());
              }
              final data = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                children: [
                  const SectionHeader(
                    title: 'Zonas de riesgo',
                    subtitle:
                        'Distritos de Puno agrupados por K-Means segun su regimen termico.',
                  ),
                  const SizedBox(height: 20),
                  GlassCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: _Metric(
                            label: 'Clusters',
                            value: '${data.nClusters}',
                          ),
                        ),
                        Expanded(
                          child: _Metric(
                            label: 'Silhouette',
                            value: data.silhouette.toStringAsFixed(3),
                          ),
                        ),
                        Expanded(
                          child: _Metric(
                            label: 'Modelo',
                            value: data.modelName,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Distritos por nivel',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...data.districts.map((d) => _DistrictTile(district: d)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DistrictTile extends StatelessWidget {
  const _DistrictTile({required this.district});

  final DistrictCluster district;

  @override
  Widget build(BuildContext context) {
    final color = tierColor(district.tier);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    district.distrito,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${district.altitude.toStringAsFixed(0)} m · media ${district.temperatureMean.toStringAsFixed(1)} °C',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.66),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusChip(label: district.tier.toUpperCase(), color: color),
                const SizedBox(height: 6),
                Text(
                  'frio ${(district.coldShare * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.cloud_off, size: 48, color: AppColors.warmAmber),
        const SizedBox(height: 16),
        Text(
          'No se pudieron cargar las zonas.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
