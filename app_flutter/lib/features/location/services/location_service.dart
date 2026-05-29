import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/location_state.dart';

class LocationService {
  Future<DetectedLocation> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationFailure(
        LocationFailureType.serviceDisabled,
        'Activa el GPS del dispositivo para usar tu ubicacion actual.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(
        LocationFailureType.permanentlyDenied,
        'El permiso de ubicacion esta bloqueado. Activalo desde ajustes del sistema.',
      );
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      throw const LocationFailure(
        LocationFailureType.denied,
        'Permiso de ubicacion denegado.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      return DetectedLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    } on TimeoutException {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown == null) {
        throw const LocationFailure(
          LocationFailureType.unknown,
          'El GPS no respondio a tiempo.',
        );
      }
      return DetectedLocation(
        latitude: lastKnown.latitude,
        longitude: lastKnown.longitude,
        accuracy: lastKnown.accuracy,
        fromLastKnownPosition: true,
      );
    }
  }
}
