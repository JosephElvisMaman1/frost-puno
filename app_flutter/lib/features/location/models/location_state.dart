class DetectedLocation {
  const DetectedLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.fromLastKnownPosition = false,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final bool fromLastKnownPosition;
}

enum LocationFailureType { serviceDisabled, denied, permanentlyDenied, unknown }

class LocationFailure implements Exception {
  const LocationFailure(this.type, this.message);

  final LocationFailureType type;
  final String message;

  @override
  String toString() => message;
}
