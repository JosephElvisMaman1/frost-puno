class LivestockRisk {
  LivestockRisk({required this.level, required this.message});

  final String level;
  final String message;

  factory LivestockRisk.fromJson(Map<String, dynamic> json) => LivestockRisk(
    level: json['level'] as String? ?? 'bajo',
    message: json['message'] as String? ?? '',
  );
}

class ClimateAnomaly {
  ClimateAnomaly({
    required this.isUnusual,
    required this.message,
    this.historicalMean,
    this.delta,
  });

  final bool isUnusual;
  final String message;
  final double? historicalMean;
  final double? delta;

  factory ClimateAnomaly.fromJson(Map<String, dynamic> json) => ClimateAnomaly(
    isUnusual: json['is_unusual'] as bool? ?? false,
    message: json['message'] as String? ?? '',
    historicalMean: (json['historical_mean'] as num?)?.toDouble(),
    delta: (json['delta'] as num?)?.toDouble(),
  );
}

class DailyAlert {
  DailyAlert({
    required this.riskLevel,
    required this.frostAlert,
    required this.severity,
    required this.title,
    required this.message,
    required this.livestock,
    required this.anomaly,
    this.temperatureMin,
  });

  final String riskLevel;
  final bool frostAlert;
  final String severity; // fuerte | moderada | ninguna
  final String title;
  final String message;
  final double? temperatureMin;
  final LivestockRisk livestock;
  final ClimateAnomaly anomaly;

  factory DailyAlert.fromJson(Map<String, dynamic> json) => DailyAlert(
    riskLevel: json['risk_level'] as String,
    frostAlert: json['frost_alert'] as bool,
    severity: json['severity'] as String,
    title: json['title'] as String,
    message: json['message'] as String,
    temperatureMin: (json['temperature_min'] as num?)?.toDouble(),
    livestock: LivestockRisk.fromJson(
      (json['livestock'] as Map<String, dynamic>?) ?? const {},
    ),
    anomaly: ClimateAnomaly.fromJson(
      (json['anomaly'] as Map<String, dynamic>?) ?? const {},
    ),
  );
}
