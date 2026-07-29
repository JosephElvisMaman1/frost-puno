import 'package:flutter/material.dart';

import '../../../core/api/frost_api_service.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/models/health_status.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/settings/user_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_mode_scope.dart';
import '../../alerts/models/daily_alert.dart';
import '../../settings/screens/settings_screen.dart';
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
    final s = AppStrings.current;
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
                        label: active ? s.systemActive : s.demoMode,
                        color: active
                            ? AppColors.mutedTeal
                            : AppColors.warmAmber,
                      );
                    },
                  ),
                ),
                IconButton(
                  tooltip: s.changeTheme,
                  icon: Icon(_themeIcon(themeScope?.themeMode)),
                  onPressed: themeScope == null
                      ? null
                      : () => themeScope.onThemeModeChanged(
                          _nextThemeMode(themeScope.themeMode),
                        ),
                ),
                IconButton(
                  tooltip: s.settings,
                  icon: const Icon(Icons.tune),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('FrostPuno', style: textTheme.displayLarge),
            const SizedBox(height: 16),
            Text(
              s.appTagline,
              style: textTheme.headlineMedium?.copyWith(
                color: onSurface.withValues(alpha: 0.68),
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),
            _AlertSection(future: _alertFuture),
            const SizedBox(height: 20),
            const _CurrentRiskCard(),
            const SizedBox(height: 32),
            PrimaryActionButton(
              label: s.checkRisk,
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
                    label: s.viewHistory,
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
                    label: s.dataSources,
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
              label: s.modelInfo,
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

Color _levelColor(String level) => switch (level) {
  'alto' => AppColors.warmAmber,
  'medio' => AppColors.mediumRisk,
  _ => AppColors.lowRisk,
};

class _AlertSection extends StatefulWidget {
  const _AlertSection({required this.future});

  final Future<DailyAlert> future;

  @override
  State<_AlertSection> createState() => _AlertSectionState();
}

class _AlertSectionState extends State<_AlertSection> {
  bool _notified = false;

  bool _shouldAlert(DailyAlert alert, UserSettings settings) {
    if (!settings.alertsEnabled) return false;
    if (alert.frostAlert) return true;
    final tmin = alert.temperatureMin;
    return tmin != null && tmin <= settings.alertThreshold;
  }

  @override
  Widget build(BuildContext context) {
    final settings = UserSettings.instance;
    return FutureBuilder<DailyAlert>(
      future: widget.future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final alert = snapshot.data!;
        return AnimatedBuilder(
          animation: settings,
          builder: (context, _) {
            final active = _shouldAlert(alert, settings);
            final s = AppStrings.current;
            if (active && !_notified) {
              _notified = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                NotificationService.showFrostAlert(
                  s.frostTitle(alert.severity),
                  s.frostMessage(alert.severity),
                );
              });
            }

            final profile = settings.profile;
            final showLivestock =
                profile == UserProfile.general ||
                profile == UserProfile.ganadero;
            final cards = <Widget>[];

            if (settings.alertsEnabled) {
              cards.add(
                _FrostBanner(alert: alert, active: active, settings: settings),
              );
            }
            if (showLivestock && alert.livestock.level != 'bajo') {
              cards.add(_LivestockCard(livestock: alert.livestock));
            }
            if (alert.anomaly.isUnusual) {
              cards.add(_AnomalyCard(anomaly: alert.anomaly));
            }
            if (cards.isEmpty) return const SizedBox.shrink();

            return Column(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  cards[i],
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _FrostBanner extends StatelessWidget {
  const _FrostBanner({
    required this.alert,
    required this.active,
    required this.settings,
  });

  final DailyAlert alert;
  final bool active;
  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    final color = active ? _levelColor(alert.riskLevel) : AppColors.lowRisk;
    final icon = active ? Icons.warning_amber_rounded : Icons.check_circle_outline;
    return GlassCard(
      padding: const EdgeInsets.all(18),
      color: color.withValues(alpha: 0.14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.current.frostTitle(alert.severity),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.current.frostMessage(alert.severity),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LivestockCard extends StatelessWidget {
  const _LivestockCard({required this.livestock});

  final LivestockRisk livestock;

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(livestock.level);
    return GlassCard(
      padding: const EdgeInsets.all(18),
      color: color.withValues(alpha: 0.12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.pets, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.current.livestockTitle(livestock.level),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.current.livestockMessage(livestock.level),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnomalyCard extends StatelessWidget {
  const _AnomalyCard({required this.anomaly});

  final ClimateAnomaly anomaly;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      color: AppColors.deepTeal.withValues(alpha: 0.12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.insights, color: AppColors.deepTeal, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.current.anomalyTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.deepTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.current.anomalyMessage(anomaly.delta),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
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
                  AppStrings.current.currentFrostRisk,
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
            children: [
              StatusChip(
                icon: Icons.water_drop_outlined,
                label: AppStrings.current.humShort('42%'),
              ),
              const StatusChip(icon: Icons.air, label: '12 km/h'),
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
                  AppStrings.current.maintenanceTitle,
                  style: textTheme.titleMedium,
                ),
              ),
              const StatusChip(label: 'K-Means'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            AppStrings.current.maintenanceBody,
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
