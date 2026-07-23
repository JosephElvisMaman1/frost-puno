import 'package:flutter/material.dart';

import '../../../core/api/frost_api_service.dart';
import '../../../core/models/health_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_mode_scope.dart';
import '../../alerts/models/daily_alert.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/primary_action_button.dart';
import '../../../shared/widgets/responsive_content.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../data_sources/screens/data_sources_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../model_info/screens/model_info_screen.dart';
import '../../prediction/screens/prediction_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.apiService, super.key});

  final FrostApiService apiService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _defaultLat = -15.8402;
  static const _defaultLon = -70.0219;

  late final Future<HealthStatus> _healthFuture = widget.apiService.getHealth();
  late final Future<DailyAlert> _alertFuture = widget.apiService.getDailyAlert(
    latitude: _defaultLat,
    longitude: _defaultLon,
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final themeScope = ThemeModeScope.maybeOf(context);
    return SafeArea(
      child: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<HealthStatus>(
                    future: _healthFuture,
                    builder: (context, snapshot) {
                      final active = snapshot.data?.modelAvailable ?? false;
                      return StatusChip(
                        icon: Icons.circle,
                        label: active ? 'Sistema activo' : 'Modo demo',
                        color: active
                            ? AppColors.mutedTeal
                            : AppColors.warmAmber,
                      );
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Cambiar tema',
                  icon: Icon(_themeIcon(themeScope?.themeMode)),
                  onPressed: themeScope == null
                      ? null
                      : () => themeScope.onThemeModeChanged(
                          _nextThemeMode(themeScope.themeMode),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('FrostPuno', style: textTheme.displayLarge),
            const SizedBox(height: 16),
            Text(
              'Prediccion inteligente de heladas para comunidades altoandinas.',
              style: textTheme.headlineMedium?.copyWith(
                color: onSurface.withValues(alpha: 0.68),
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),
            _DailyAlertBanner(future: _alertFuture),
            const SizedBox(height: 20),
            const _CurrentRiskCard(),
            const SizedBox(height: 32),
            PrimaryActionButton(
              label: 'Consultar riesgo',
              icon: Icons.arrow_forward,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      PredictionFormScreen(apiService: widget.apiService),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _QuickTile(
                    icon: Icons.history,
                    label: 'Ver historial',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            HistoryScreen(apiService: widget.apiService),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickTile(
                    icon: Icons.storage_outlined,
                    label: 'Fuentes de datos',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DataSourcesScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _QuickTile(
              icon: Icons.account_tree_outlined,
              label: 'Informacion del modelo',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ModelInfoScreen(apiService: widget.apiService),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const _LearningCycleCard(),
          ],
        ),
      ),
    );
  }

  static ThemeMode _nextThemeMode(ThemeMode? mode) {
    return switch (mode ?? ThemeMode.system) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
  }

  static IconData _themeIcon(ThemeMode? mode) {
    return switch (mode ?? ThemeMode.system) {
      ThemeMode.system => Icons.brightness_auto_outlined,
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
    };
  }
}

class _DailyAlertBanner extends StatelessWidget {
  const _DailyAlertBanner({required this.future});

  final Future<DailyAlert> future;

  Color _color(String severity) => switch (severity) {
    'fuerte' => AppColors.warmAmber,
    'moderada' => AppColors.mediumRisk,
    _ => AppColors.lowRisk,
  };

  IconData _icon(String severity) => switch (severity) {
    'fuerte' => Icons.warning_amber_rounded,
    'moderada' => Icons.ac_unit,
    _ => Icons.check_circle_outline,
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DailyAlert>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final alert = snapshot.data!;
        final color = _color(alert.severity);
        return GlassCard(
          padding: const EdgeInsets.all(18),
          color: color.withValues(alpha: 0.14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon(alert.severity), color: color, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      alert.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CurrentRiskCard extends StatelessWidget {
  const _CurrentRiskCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Riesgo actual de helada',
                  style: textTheme.headlineMedium,
                ),
              ),
              const Icon(Icons.ac_unit, color: AppColors.mutedTeal, size: 42),
            ],
          ),
          const SizedBox(height: 34),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-4.2',
                style: textTheme.displayLarge?.copyWith(fontSize: 54),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'C',
                  style: textTheme.titleMedium?.copyWith(
                    color: onSurface.withValues(alpha: 0.68),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            children: const [
              StatusChip(icon: Icons.water_drop_outlined, label: 'Hum 42%'),
              StatusChip(icon: Icons.air, label: '12 km/h'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LearningCycleCard extends StatelessWidget {
  const _LearningCycleCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.model_training, color: AppColors.warmAmber),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mejora supervisada',
                  style: textTheme.titleMedium,
                ),
              ),
              const StatusChip(label: 'ML v0.2'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'El modelo no se actualiza solo: registra evidencia, compara contra observaciones oficiales y versiona una nueva evaluacion antes de promover cambios.',
            style: textTheme.bodyMedium?.copyWith(
              color: onSurface.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 128),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.66),
              size: 32,
            ),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
