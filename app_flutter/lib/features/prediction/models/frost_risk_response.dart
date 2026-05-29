class FrostRiskResponse {
  const FrostRiskResponse({
    required this.riskLevel,
    required this.confidence,
    required this.recommendation,
    required this.chunoConditions,
    required this.modelVersion,
    required this.dataSources,
  });

  final String riskLevel;
  final double confidence;
  final String recommendation;
  final String chunoConditions;
  final String modelVersion;
  final List<String> dataSources;

  factory FrostRiskResponse.fromJson(Map<String, dynamic> json) {
    return FrostRiskResponse(
      riskLevel: json['risk_level'] as String? ?? 'bajo',
      confidence: (json['confidence'] as num? ?? 0).toDouble(),
      recommendation: json['recommendation'] as String? ?? '',
      chunoConditions: json['chuno_conditions'] as String? ?? 'no_favorables',
      modelVersion: json['model_version'] as String? ?? '-',
      dataSources: (json['data_sources'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}
