class PredictionHistoryItem {
  const PredictionHistoryItem({
    required this.id,
    required this.district,
    required this.province,
    required this.latitude,
    required this.longitude,
    required this.riskLevel,
    required this.confidence,
    required this.chunoConditions,
    required this.recommendation,
    required this.modelVersion,
    required this.dataSources,
    required this.createdAt,
    this.populatedCenter,
    this.altitude,
  });

  final String id;
  final String district;
  final String province;
  final String? populatedCenter;
  final double latitude;
  final double longitude;
  final double? altitude;
  final String riskLevel;
  final double confidence;
  final String chunoConditions;
  final String recommendation;
  final String modelVersion;
  final List<String> dataSources;
  final String createdAt;

  factory PredictionHistoryItem.fromJson(Map<String, dynamic> json) {
    return PredictionHistoryItem(
      id: json['id'] as String? ?? '-',
      district: json['district'] as String? ?? '-',
      province: json['province'] as String? ?? '-',
      populatedCenter: json['populated_center'] as String?,
      latitude: (json['latitude'] as num? ?? 0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      riskLevel: json['risk_level'] as String? ?? 'bajo',
      confidence: (json['confidence'] as num? ?? 0).toDouble(),
      chunoConditions: json['chuno_conditions'] as String? ?? '-',
      recommendation: json['recommendation'] as String? ?? '',
      modelVersion: json['model_version'] as String? ?? '-',
      dataSources: (json['data_sources'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      createdAt: json['created_at'] as String? ?? '-',
    );
  }
}
