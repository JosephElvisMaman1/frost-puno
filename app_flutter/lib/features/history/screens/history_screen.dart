import 'package:flutter/material.dart';

import '../../../core/api/frost_api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/responsive_content.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/prediction_history_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    required this.apiService,
    super.key,
    this.showAppBar = true,
  });

  final FrostApiService apiService;
  final bool showAppBar;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<PredictionHistoryItem>> _future = widget.apiService
      .getPredictionHistory();

  @override
  Widget build(BuildContext context) {
    final body = RefreshIndicator(
      onRefresh: () async {
        setState(() => _future = widget.apiService.getPredictionHistory());
        await _future;
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        children: [
          const SectionHeader(
            title: 'Historial de predicciones',
            subtitle:
                'Predicciones registradas por FastAPI cuando Supabase esta activo.',
          ),
          const SizedBox(height: 26),
          TextField(
            enabled: false,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Filtrar por distrito...',
              fillColor: AppColors.surfaceLow,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.35),
              ),
            ),
          ),
          const SizedBox(height: 26),
          FutureBuilder<List<PredictionHistoryItem>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                return _EmptyHistory(
                  message: 'No se pudo cargar el historial desde FastAPI.',
                );
              }
              final items = snapshot.data ?? const [];
              if (items.isEmpty) {
                return const _EmptyHistory(
                  message:
                      'Aun no hay predicciones guardadas. Con Supabase apagado, FastAPI devuelve una lista vacia.',
                );
              }
              return Column(
                children: items
                    .map((item) => _HistoryCard(item: item))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );

    if (!widget.showAppBar) {
      return SafeArea(child: ResponsiveContent(child: body));
    }
    return PageScaffold(child: body);
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final PredictionHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final isHigh = item.riskLevel == 'alto';
    final color = isHigh ? AppColors.warmAmber : AppColors.mutedTeal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.district,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.deepNavy,
                    ),
                  ),
                ),
                StatusChip(
                  icon: isHigh
                      ? Icons.warning_amber_rounded
                      : Icons.info_outline,
                  label: 'Riesgo ${_title(item.riskLevel)}',
                  color: color,
                  background: color.withValues(alpha: 0.14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.createdAt,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SmallMetric(
                  label: 'CONFIANZA',
                  value: '${(item.confidence * 100).toStringAsFixed(1)}%',
                ),
                _SmallMetric(label: 'MODELO', value: item.modelVersion),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _title(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}

class _SmallMetric extends StatelessWidget {
  const _SmallMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontFamily: 'monospace',
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      color: AppColors.softWhite,
      child: Column(
        children: [
          const Icon(
            Icons.history_toggle_off,
            size: 42,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
