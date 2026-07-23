class ChunoDay {
  ChunoDay({
    required this.date,
    required this.tier,
    required this.isGoodDay,
    this.temperatureMin,
    this.humidityMax,
    this.cloudCover,
    this.precipitation,
  });

  final String date;
  final String tier;
  final bool isGoodDay;
  final double? temperatureMin;
  final double? humidityMax;
  final double? cloudCover;
  final double? precipitation;

  factory ChunoDay.fromJson(Map<String, dynamic> json) => ChunoDay(
    date: json['date'] as String,
    tier: json['tier'] as String,
    isGoodDay: json['is_good_day'] as bool,
    temperatureMin: (json['temperature_min'] as num?)?.toDouble(),
    humidityMax: (json['humidity_max'] as num?)?.toDouble(),
    cloudCover: (json['cloud_cover_mean'] as num?)?.toDouble(),
    precipitation: (json['precipitation_sum'] as num?)?.toDouble(),
  );
}

class ChunoWindow {
  ChunoWindow({
    required this.inSeason,
    required this.optimalWindow,
    required this.bestStreak,
    required this.message,
    required this.days,
  });

  final bool inSeason;
  final bool optimalWindow;
  final int bestStreak;
  final String message;
  final List<ChunoDay> days;

  factory ChunoWindow.fromJson(Map<String, dynamic> json) => ChunoWindow(
    inSeason: json['in_season'] as bool,
    optimalWindow: json['optimal_window'] as bool,
    bestStreak: (json['best_streak'] as num).toInt(),
    message: json['message'] as String,
    days: (json['days'] as List)
        .whereType<Map<String, dynamic>>()
        .map(ChunoDay.fromJson)
        .toList(),
  );
}
