class CurrentWeather {
  const CurrentWeather({
    required this.latitude,
    required this.longitude,
    required this.provider,
    required this.fallbackUsed,
    this.temperature,
    this.apparentTemperature,
    this.humidity,
    this.windSpeed,
    this.cloudCover,
    this.dewPoint,
    this.precipitation,
    this.observedAt,
    this.stationName,
    this.stationDistanceKm,
  });

  final double latitude;
  final double longitude;
  final String provider;
  final bool fallbackUsed;
  final double? temperature;
  final double? apparentTemperature;
  final double? humidity;
  final double? windSpeed;
  final double? cloudCover;
  final double? dewPoint;
  final double? precipitation;
  final String? observedAt;
  final String? stationName;
  final double? stationDistanceKm;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    double? n(String key) {
      final value = json[key];
      return value is num ? value.toDouble() : null;
    }

    return CurrentWeather(
      latitude: n('latitude') ?? 0,
      longitude: n('longitude') ?? 0,
      provider: json['provider'] as String? ?? 'desconocido',
      fallbackUsed: json['fallback_used'] as bool? ?? false,
      temperature: n('temperature'),
      apparentTemperature: n('apparent_temperature'),
      humidity: n('humidity'),
      windSpeed: n('wind_speed'),
      cloudCover: n('cloud_cover'),
      dewPoint: n('dew_point'),
      precipitation: n('precipitation'),
      observedAt: json['observed_at'] as String?,
      stationName: json['station_name'] as String?,
      stationDistanceKm: n('station_distance_km'),
    );
  }
}
