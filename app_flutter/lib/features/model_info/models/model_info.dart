class ModelInfo {
  const ModelInfo({
    required this.modelName,
    required this.version,
    required this.createdAt,
    required this.features,
    required this.target,
    required this.metrics,
    required this.datasetSize,
    required this.dataSources,
    required this.limitations,
    this.nClusters,
  });

  final String modelName;
  final String version;
  final String createdAt;
  final List<String> features;
  final String target;
  final Map<String, double> metrics;
  final int datasetSize;
  final List<String> dataSources;
  final List<String> limitations;
  final int? nClusters;

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    final rawMetrics = json['metrics'] as Map<String, dynamic>? ?? const {};
    return ModelInfo(
      modelName: json['model_name'] as String? ?? '-',
      version: json['version'] as String? ?? '-',
      createdAt: json['created_at'] as String? ?? '-',
      features: (json['features'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      target: json['target'] as String? ?? '-',
      metrics: rawMetrics.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      datasetSize: json['dataset_size'] as int? ?? 0,
      dataSources: (json['data_sources'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      limitations: (json['limitations'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      nClusters: (json['n_clusters'] as num?)?.toInt(),
    );
  }
}
