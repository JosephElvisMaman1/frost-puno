import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/api/frost_api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/responsive_content.dart';
import '../../../shared/widgets/section_header.dart';
import '../models/history_day.dart';

const _defaultLat = -15.8402;
const _defaultLon = -70.0219;

String _fmt(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({required this.apiService, super.key});

  final FrostApiService apiService;

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  late Future<WeatherHistory> _future = _load();

  Future<WeatherHistory> _load() {
    // Open-Meteo Archive tiene ~5 dias de retraso; pedimos 30 dias hasta hace 6.
    final end = DateTime.now().subtract(const Duration(days: 6));
    final start = end.subtract(const Duration(days: 29));
    return widget.apiService.getWeatherHistory(
      latitude: _defaultLat,
      longitude: _defaultLon,
      start: _fmt(start),
      end: _fmt(end),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ResponsiveContent(
        child: FutureBuilder<WeatherHistory>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _Error(message: snapshot.error.toString());
            }
            final days = snapshot.data!.days;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() => _future = _load());
                await _future;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                children: [
                  const SectionHeader(
                    title: 'Clima historico',
                    subtitle:
                        'Temperaturas minimas/maximas y humedad de los ultimos 30 dias (Open-Meteo Archive).',
                  ),
                  const SizedBox(height: 20),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Temperatura (°C)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        _Legend(
                          items: const [
                            ('Minima', AppColors.mutedTeal),
                            ('Maxima', AppColors.warmAmber),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: LineChart(_tempChart(context, days)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Humedad relativa (%)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: LineChart(_humidityChart(context, days)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<FlSpot> _spots(List<HistoryDay> days, double? Function(HistoryDay) pick) {
    final spots = <FlSpot>[];
    for (var i = 0; i < days.length; i++) {
      final value = pick(days[i]);
      if (value != null) spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  LineChartData _tempChart(BuildContext context, List<HistoryDay> days) {
    return LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: _titles(days),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        _line(_spots(days, (d) => d.temperatureMin), AppColors.mutedTeal),
        _line(_spots(days, (d) => d.temperatureMax), AppColors.warmAmber),
      ],
    );
  }

  LineChartData _humidityChart(BuildContext context, List<HistoryDay> days) {
    return LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: _titles(days),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        _line(_spots(days, (d) => d.humidityMean), AppColors.deepTeal),
      ],
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) => LineChartBarData(
    spots: spots,
    isCurved: true,
    color: color,
    barWidth: 2.5,
    dotData: const FlDotData(show: false),
  );

  FlTitlesData _titles(List<HistoryDay> days) => FlTitlesData(
    show: true,
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: true, reservedSize: 34),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: (days.length / 4).clamp(1, 30).toDouble(),
        getTitlesWidget: (value, meta) {
          final index = value.toInt();
          if (index < 0 || index >= days.length) return const SizedBox.shrink();
          final label = days[index].date;
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              label.length >= 10 ? label.substring(5) : label,
              style: const TextStyle(fontSize: 10),
            ),
          );
        },
      ),
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.items});

  final List<(String, Color)> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: items
          .map(
            (item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 12, height: 12, color: item.$2),
                const SizedBox(width: 6),
                Text(item.$1, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          )
          .toList(),
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
        const Icon(Icons.show_chart, size: 48, color: AppColors.warmAmber),
        const SizedBox(height: 16),
        Text(
          'No se pudo cargar el historico.',
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
