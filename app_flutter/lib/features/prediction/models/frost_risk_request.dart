class FrostRiskRequest {
  const FrostRiskRequest({
    required this.district,
    required this.province,
    required this.populatedCenter,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.ruralPopulation,
    required this.agriculturalActivity,
    required this.mainCrop,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.cloudCover,
    required this.dewPoint,
    required this.precipitation,
    required this.month,
    required this.hour,
    required this.hoursBelowZero,
    this.totalPopulation,
    this.ruralPercentage,
  });

  final String district;
  final String province;
  final String populatedCenter;
  final double latitude;
  final double longitude;
  final double altitude;
  final int ruralPopulation;
  final int? totalPopulation;
  final double? ruralPercentage;
  final bool agriculturalActivity;
  final String mainCrop;
  final double temperatureMin;
  final double temperatureMax;
  final double feelsLike;
  final double humidity;
  final double windSpeed;
  final double cloudCover;
  final double dewPoint;
  final double precipitation;
  final int month;
  final int hour;
  final int hoursBelowZero;

  factory FrostRiskRequest.demo() {
    return const FrostRiskRequest(
      district: 'Puno',
      province: 'Puno',
      populatedCenter: 'Centro poblado demo',
      latitude: -15.8402,
      longitude: -70.0219,
      altitude: 3827,
      ruralPopulation: 1200,
      totalPopulation: 5000,
      ruralPercentage: 24,
      agriculturalActivity: true,
      mainCrop: 'papa',
      temperatureMin: -2.5,
      temperatureMax: 12.4,
      feelsLike: -4.0,
      humidity: 68,
      windSpeed: 7,
      cloudCover: 20,
      dewPoint: -3.5,
      precipitation: 0,
      month: 6,
      hour: 3,
      hoursBelowZero: 4,
    );
  }

  FrostRiskRequest copyWith({
    String? district,
    String? province,
    String? populatedCenter,
    double? latitude,
    double? longitude,
    double? altitude,
    int? ruralPopulation,
    int? totalPopulation,
    double? ruralPercentage,
    bool? agriculturalActivity,
    String? mainCrop,
    double? temperatureMin,
    double? temperatureMax,
    double? feelsLike,
    double? humidity,
    double? windSpeed,
    double? cloudCover,
    double? dewPoint,
    double? precipitation,
    int? month,
    int? hour,
    int? hoursBelowZero,
  }) {
    return FrostRiskRequest(
      district: district ?? this.district,
      province: province ?? this.province,
      populatedCenter: populatedCenter ?? this.populatedCenter,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      ruralPopulation: ruralPopulation ?? this.ruralPopulation,
      totalPopulation: totalPopulation ?? this.totalPopulation,
      ruralPercentage: ruralPercentage ?? this.ruralPercentage,
      agriculturalActivity: agriculturalActivity ?? this.agriculturalActivity,
      mainCrop: mainCrop ?? this.mainCrop,
      temperatureMin: temperatureMin ?? this.temperatureMin,
      temperatureMax: temperatureMax ?? this.temperatureMax,
      feelsLike: feelsLike ?? this.feelsLike,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      cloudCover: cloudCover ?? this.cloudCover,
      dewPoint: dewPoint ?? this.dewPoint,
      precipitation: precipitation ?? this.precipitation,
      month: month ?? this.month,
      hour: hour ?? this.hour,
      hoursBelowZero: hoursBelowZero ?? this.hoursBelowZero,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'district': district,
      'province': province,
      'populated_center': populatedCenter,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'rural_population': ruralPopulation,
      if (totalPopulation != null) 'total_population': totalPopulation,
      if (ruralPercentage != null) 'rural_percentage': ruralPercentage,
      'agricultural_activity': agriculturalActivity,
      'main_crop': mainCrop,
      'temperature_min': temperatureMin,
      'temperature_max': temperatureMax,
      'feels_like': feelsLike,
      'humidity': humidity,
      'wind_speed': windSpeed,
      'cloud_cover': cloudCover,
      'dew_point': dewPoint,
      'precipitation': precipitation,
      'month': month,
      'hour': hour,
      'hours_below_zero': hoursBelowZero,
    };
  }
}
