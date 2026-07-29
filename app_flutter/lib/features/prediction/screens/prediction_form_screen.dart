import 'package:flutter/material.dart';

import '../../../core/api/frost_api_service.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/models/current_weather.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/primary_action_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../location/models/location_state.dart';
import '../../location/services/location_service.dart';
import '../models/frost_risk_request.dart';
import 'result_screen.dart';

class PredictionFormScreen extends StatefulWidget {
  const PredictionFormScreen({required this.apiService, super.key});

  final FrostApiService apiService;

  @override
  State<PredictionFormScreen> createState() => _PredictionFormScreenState();
}

class _PredictionFormScreenState extends State<PredictionFormScreen> {
  final _locationService = LocationService();
  FrostRiskRequest _request = FrostRiskRequest.demo();
  DetectedLocation? _detectedLocation;
  CurrentWeather? _weather;
  bool _isLocating = false;
  bool _isLoadingWeather = false;
  bool _isPredicting = false;
  // null => se muestra la pista por defecto en el idioma activo.
  String? _locationMessage;
  String? _weatherMessage;

  @override
  Widget build(BuildContext context) {
    final isBusy = _isLocating || _isLoadingWeather || _isPredicting;
    final s = AppStrings.current;
    return PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        children: [
          SectionHeader(
            title: s.frostRiskTitle,
            subtitle: s.frostRiskSubtitle,
          ),
          const SizedBox(height: 24),
          _LocationCard(
            request: _request,
            detectedLocation: _detectedLocation,
            message: _locationMessage ?? s.locationHint,
            locating: _isLocating,
            onUseLocation: isBusy ? null : _useCurrentLocation,
          ),
          const SizedBox(height: 18),
          _WeatherCard(
            request: _request,
            weather: _weather,
            message: _weatherMessage ?? s.weatherHint,
            loading: _isLoadingWeather,
            onRefreshWeather: isBusy ? null : _loadWeatherForCurrentRequest,
          ),
          const SizedBox(height: 22),
          _ActionCard(
            predicting: _isPredicting,
            canPredict: !isBusy,
            onPredict: _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _isPredicting = true);
    try {
      final response = await widget.apiService.predict(_request);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(request: _request, response: response),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.current.connectError(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _isPredicting = false);
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    final s = AppStrings.current;
    setState(() {
      _isLocating = true;
      _locationMessage = s.requestingGps;
      _weatherMessage = s.waitingLocation;
    });
    try {
      final location = await _locationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _detectedLocation = location;
        _request = _request.copyWith(
          district: 'Ubicacion detectada',
          province: 'Puno',
          populatedCenter: 'GPS actual',
          latitude: location.latitude,
          longitude: location.longitude,
        );
        _locationMessage = s.gpsAccuracy(
          location.fromLastKnownPosition,
          location.accuracy.toStringAsFixed(0),
        );
      });
      await _loadCurrentWeather();
    } on LocationFailure catch (error) {
      if (!mounted) return;
      setState(() {
        _locationMessage = s.locationFailed(error.message);
        _weatherMessage = s.tapGetWeatherDemo;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _locationMessage = s.locationFailedGeneric;
        _weatherMessage = s.detail(error);
      });
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _loadWeatherForCurrentRequest() async {
    await _loadCurrentWeather();
  }

  Future<void> _loadCurrentWeather() async {
    final s = AppStrings.current;
    setState(() {
      _isLoadingWeather = true;
      _weatherMessage = s.queryingWeather;
    });
    try {
      final weather = await widget.apiService.getCurrentWeather(
        latitude: _request.latitude,
        longitude: _request.longitude,
      );
      if (!mounted) return;
      setState(() {
        _weather = weather;
        _request = _requestWithWeather(_request, weather);
        _weatherMessage = s.weatherUpdated(
          weather.provider,
          weather.fallbackUsed,
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _weatherMessage = s.weatherFailed(error);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingWeather = false);
      }
    }
  }

  FrostRiskRequest _requestWithWeather(
    FrostRiskRequest current,
    CurrentWeather weather,
  ) {
    final now = DateTime.now();
    final temperature = weather.temperature;
    final feelsLike = weather.apparentTemperature ?? temperature;
    final hoursBelowZero = temperature == null
        ? current.hoursBelowZero
        : temperature <= 0
        ? 1
        : 0;

    return current.copyWith(
      temperatureMin: temperature ?? current.temperatureMin,
      temperatureMax: temperature ?? current.temperatureMax,
      feelsLike: feelsLike ?? current.feelsLike,
      humidity: weather.humidity ?? current.humidity,
      windSpeed: weather.windSpeed ?? current.windSpeed,
      cloudCover: weather.cloudCover ?? current.cloudCover,
      dewPoint: weather.dewPoint ?? current.dewPoint,
      precipitation: weather.precipitation ?? current.precipitation,
      month: now.month,
      hour: now.hour,
      hoursBelowZero: hoursBelowZero,
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.request,
    required this.message,
    required this.locating,
    required this.onUseLocation,
    this.detectedLocation,
  });

  final FrostRiskRequest request;
  final DetectedLocation? detectedLocation;
  final String message;
  final bool locating;
  final VoidCallback? onUseLocation;

  @override
  Widget build(BuildContext context) {
    final detected = detectedLocation != null;
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.my_location, label: AppStrings.current.location),
          const SizedBox(height: 16),
          Text(
            detected
                ? AppStrings.current.detectedLocation
                : AppStrings.current.punoDemo,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            '${request.latitude.toStringAsFixed(5)}, ${request.longitude.toStringAsFixed(5)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.68),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 14),
          _InfoBanner(icon: Icons.location_on_outlined, text: message),
          const SizedBox(height: 16),
          PrimaryActionButton(
            label: locating
                ? AppStrings.current.detectingLocation
                : AppStrings.current.useMyLocation,
            icon: Icons.gps_fixed,
            onPressed: onUseLocation,
          ),
        ],
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({
    required this.request,
    required this.message,
    required this.loading,
    required this.onRefreshWeather,
    this.weather,
  });

  final FrostRiskRequest request;
  final CurrentWeather? weather;
  final String message;
  final bool loading;
  final VoidCallback? onRefreshWeather;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.cloud_outlined, label: s.currentWeather),
          const SizedBox(height: 18),
          _WeatherHero(request: request, weather: weather),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _WeatherMetric(
                icon: Icons.water_drop_outlined,
                label: s.humidity,
                value: '${request.humidity.toStringAsFixed(0)}%',
              ),
              _WeatherMetric(
                icon: Icons.air,
                label: s.wind,
                value: '${request.windSpeed.toStringAsFixed(1)} km/h',
              ),
              _WeatherMetric(
                icon: Icons.cloud_queue,
                label: s.clouds,
                value: '${request.cloudCover.toStringAsFixed(0)}%',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoBanner(icon: Icons.cloud_sync_outlined, text: message),
          if (weather?.stationName != null) ...[
            const SizedBox(height: 12),
            StatusChip(
              icon: Icons.place_outlined,
              label: weather!.stationName!,
            ),
          ],
          const SizedBox(height: 16),
          PrimaryActionButton(
            label: loading ? s.gettingWeather : s.getWeather,
            icon: Icons.refresh,
            onPressed: onRefreshWeather,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.predicting,
    required this.canPredict,
    required this.onPredict,
  });

  final bool predicting;
  final bool canPredict;
  final VoidCallback onPredict;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.readyToPredict,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            s.readyToPredictBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 18),
          PrimaryActionButton(
            label: predicting ? s.predicting : s.predict,
            icon: Icons.analytics_outlined,
            onPressed: canPredict ? onPredict : null,
          ),
        ],
      ),
    );
  }
}

class _WeatherHero extends StatelessWidget {
  const _WeatherHero({required this.request, this.weather});

  final FrostRiskRequest request;
  final CurrentWeather? weather;

  @override
  Widget build(BuildContext context) {
    final temp = request.temperatureMin;
    final color = temp <= 0 ? AppColors.warmAmber : AppColors.mutedTeal;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            temp <= 0 ? Icons.ac_unit : Icons.thermostat,
            color: color,
            size: 34,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${temp.toStringAsFixed(1)} C',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(color: color, fontSize: 42),
              ),
              const SizedBox(height: 4),
              Text(
                weather == null
                    ? AppStrings.current.internalDemoValue
                    : AppStrings.current.feelsLike(
                        request.feelsLike.toStringAsFixed(1),
                      ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  const _WeatherMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      constraints: const BoxConstraints(minWidth: 132, minHeight: 74),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.mutedTeal),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.mutedTeal),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.mutedTeal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
