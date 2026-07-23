class ClusterProfile {
  ClusterProfile({
    required this.clusterId,
    required this.tier,
    required this.size,
    required this.temperature,
    required this.dewPoint,
  });

  final int clusterId;
  final String tier;
  final int size;
  final double temperature;
  final double dewPoint;

  factory ClusterProfile.fromJson(Map<String, dynamic> json) => ClusterProfile(
    clusterId: (json['cluster_id'] as num).toInt(),
    tier: json['tier'] as String,
    size: (json['size'] as num).toInt(),
    temperature: (json['temperature_2m'] as num).toDouble(),
    dewPoint: (json['dew_point_2m'] as num).toDouble(),
  );
}

class DistrictCluster {
  DistrictCluster({
    required this.distrito,
    required this.tier,
    required this.dominantCluster,
    required this.coldShare,
    required this.altitude,
    required this.temperatureMean,
  });

  final String distrito;
  final String tier;
  final int dominantCluster;
  final double coldShare;
  final double altitude;
  final double temperatureMean;

  factory DistrictCluster.fromJson(Map<String, dynamic> json) =>
      DistrictCluster(
        distrito: json['distrito'] as String,
        tier: json['tier'] as String,
        dominantCluster: (json['dominant_cluster'] as num).toInt(),
        coldShare: (json['cold_share'] as num).toDouble(),
        altitude: (json['altitud_estimada'] as num).toDouble(),
        temperatureMean: (json['temperature_2m_mean'] as num).toDouble(),
      );
}

class ClustersResult {
  ClustersResult({
    required this.modelName,
    required this.version,
    required this.nClusters,
    required this.silhouette,
    required this.profiles,
    required this.districts,
  });

  final String modelName;
  final String version;
  final int nClusters;
  final double silhouette;
  final List<ClusterProfile> profiles;
  final List<DistrictCluster> districts;

  factory ClustersResult.fromJson(Map<String, dynamic> json) => ClustersResult(
    modelName: json['model_name'] as String,
    version: json['version'] as String,
    nClusters: (json['n_clusters'] as num).toInt(),
    silhouette: (json['silhouette'] as num).toDouble(),
    profiles: (json['profiles'] as List)
        .whereType<Map<String, dynamic>>()
        .map(ClusterProfile.fromJson)
        .toList(),
    districts: (json['districts'] as List)
        .whereType<Map<String, dynamic>>()
        .map(DistrictCluster.fromJson)
        .toList(),
  );
}
