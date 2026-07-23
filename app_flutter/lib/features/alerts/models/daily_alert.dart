class DailyAlert {
  DailyAlert({
    required this.riskLevel,
    required this.frostAlert,
    required this.severity,
    required this.title,
    required this.message,
    this.temperatureMin,
  });

  final String riskLevel;
  final bool frostAlert;
  final String severity; // fuerte | moderada | ninguna
  final String title;
  final String message;
  final double? temperatureMin;

  factory DailyAlert.fromJson(Map<String, dynamic> json) => DailyAlert(
    riskLevel: json['risk_level'] as String,
    frostAlert: json['frost_alert'] as bool,
    severity: json['severity'] as String,
    title: json['title'] as String,
    message: json['message'] as String,
    temperatureMin: (json['temperature_min'] as num?)?.toDouble(),
  );
}
