import 'package:flutter/material.dart';

import '../../../core/api/frost_api_service.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/responsive_content.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/chuno_window.dart';

// Puno demo por defecto; en produccion la pantalla recibe GPS del usuario.
const _defaultLat = -15.8402;
const _defaultLon = -70.0219;

Color _dayColor(String tier) => switch (tier) {
  'excelente' => AppColors.deepTeal,
  'bueno' => AppColors.lowRisk,
  'marginal' => AppColors.mediumRisk,
  _ => AppColors.warmAmber,
};

class ChunoScreen extends StatefulWidget {
  const ChunoScreen({required this.apiService, super.key});

  final FrostApiService apiService;

  @override
  State<ChunoScreen> createState() => _ChunoScreenState();
}

class _ChunoScreenState extends State<ChunoScreen> {
  late Future<ChunoWindow> _future = _load();

  Future<ChunoWindow> _load() => widget.apiService.getChunoWindow(
    latitude: _defaultLat,
    longitude: _defaultLon,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ResponsiveContent(
        child: FutureBuilder<ChunoWindow>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _Error(message: snapshot.error.toString());
            }
            final data = snapshot.data!;
            final s = AppStrings.current;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() => _future = _load());
                await _future;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                children: [
                  SectionHeader(
                    title: s.chunoTitle,
                    subtitle: s.chunoSubtitle,
                  ),
                  const SizedBox(height: 20),
                  _SeasonCard(data: data),
                  const SizedBox(height: 24),
                  Text(
                    s.dailyForecast,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...data.days.map((d) => _DayTile(day: d)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SeasonCard extends StatelessWidget {
  const _SeasonCard({required this.data});

  final ChunoWindow data;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final s = AppStrings.current;
    final color = data.optimalWindow
        ? AppColors.deepTeal
        : (data.inSeason ? AppColors.mediumRisk : AppColors.mutedTeal);
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.ac_unit, color: color, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data.optimalWindow
                      ? s.optimalWindow
                      : data.inSeason
                      ? s.inSeason
                      : s.offSeason,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              StatusChip(
                label: s.streak(data.bestStreak),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: onSurface.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.day});

  final ChunoDay day;

  @override
  Widget build(BuildContext context) {
    final color = _dayColor(day.tier);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              day.isGoodDay ? Icons.check_circle : Icons.remove_circle_outline,
              color: color,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day.date, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.current.chunoDayMetrics(
                      day.temperatureMin?.toStringAsFixed(1) ?? '—',
                      day.cloudCover?.toStringAsFixed(0) ?? '—',
                      day.humidityMax?.toStringAsFixed(0) ?? '—',
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            StatusChip(
              label: AppStrings.current.tierWord(day.tier),
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message});

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
          AppStrings.current.chunoError,
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
