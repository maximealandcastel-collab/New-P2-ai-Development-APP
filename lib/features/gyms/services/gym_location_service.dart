import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';

class GymLocationService {
  static final GymLocationService _instance = GymLocationService._internal();
  factory GymLocationService() => _instance;
  GymLocationService._internal();

  Position? _lastPosition;

  /// Returns user's current position, requesting permission if needed.
  /// Returns null if permission denied or location unavailable.
  Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      _lastPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return _lastPosition;
    } catch (e) {
      debugPrint('GymLocationService: $e');
      return null;
    }
  }

  /// Attaches distance values to each gym and sorts nearest-first.
  /// Keeps isOwnGym gyms at the top of the featured list.
  List<EnterpriseGymModel> sortByDistance(
    List<EnterpriseGymModel> gyms,
    Position position,
  ) {
    for (final gym in gyms) {
      if (gym.lat != 0.0 && gym.lng != 0.0) {
        gym.distanceMi = _haversineDistanceMi(
          position.latitude,
          position.longitude,
          gym.lat,
          gym.lng,
        );
      }
    }

    final sorted = List<EnterpriseGymModel>.from(gyms);
    sorted.sort((a, b) {
      // Own gym always first
      if (a.isOwnGym && !b.isOwnGym) return -1;
      if (!a.isOwnGym && b.isOwnGym) return 1;
      // Contract-pending gyms explicitly pinned by the founder stay next.
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      final da = a.distanceMi ?? double.infinity;
      final db = b.distanceMi ?? double.infinity;
      return da.compareTo(db);
    });
    return sorted;
  }

  /// Haversine formula — returns distance in miles.
  double _haversineDistanceMi(
    double lat1, double lng1, double lat2, double lng2) {
    const R = 3958.8; // Earth radius in miles
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;
}
