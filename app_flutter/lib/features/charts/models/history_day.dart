class HistoryDay {
  HistoryDay({
    required this.date,
    this.temperatureMin,
    this.temperatureMax,
    this.humidityMean,
  });

  final String date;
  final double? temperatureMin;
  final double? temperatureMax;
  final double? humidityMean;

  factory HistoryDay.fromJson(Map<String, dynamic> json) => HistoryDay(
    date: json['date'] as String,
    temperatureMin: (json['temperature_min'] as num?)?.toDouble(),
    temperatureMax: (json['temperature_max'] as num?)?.toDouble(),
    humidityMean: (json['humidity_mean'] as num?)?.toDouble(),
  );
}

class WeatherHistory {
  WeatherHistory({required this.days});

  final List<HistoryDay> days;

  factory WeatherHistory.fromJson(Map<String, dynamic> json) => WeatherHistory(
    days: (json['days'] as List)
        .whereType<Map<String, dynamic>>()
        .map(HistoryDay.fromJson)
        .toList(),
  );
}
