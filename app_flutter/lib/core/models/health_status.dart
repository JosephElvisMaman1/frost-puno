class HealthStatus {
  const HealthStatus({
    required this.status,
    required this.appName,
    required this.version,
    required this.modelAvailable,
  });

  final String status;
  final String appName;
  final String version;
  final bool modelAvailable;

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      status: json['status'] as String? ?? 'unknown',
      appName: json['app_name'] as String? ?? 'Frost Puno API',
      version: json['version'] as String? ?? '-',
      modelAvailable: json['model_available'] as bool? ?? false,
    );
  }
}
