import 'package:flutter/material.dart';

enum GymLoginExperience { standard, whiteLabel }

class EnterpriseGymModel {
  final String remoteLogoUrl;
  final String id;
  final String name;
  final String initials;
  final String category;
  final String memberCount;
  final Color brandColor;
  final Color accentColor;
  final Color textColor;
  final bool isActive;
  final bool isOwnGym;
  final bool isPinned;
  final bool
  isActivated; // true = visible in the app; false = contract not signed yet
  final bool requiresLoggedOutSession;
  final GymLoginExperience loginExperience;
  final String? tenantId;
  final double rating;
  final String imageUrl;
  final String imageAssetPath;
  final List<String> galleryAssetPaths;
  final List<String> filterTags;
  final String city;
  final String zipCode;
  final String address;
  final String tagline;
  final double lat;
  final double lng;
  double? distanceMi;

  /// Partnership status shown on every non-activated Gym.
  final String statusLabel;

  EnterpriseGymModel({
    this.remoteLogoUrl = '',
    required this.id,
    required this.name,
    required this.initials,
    required this.category,
    required this.memberCount,
    required this.brandColor,
    required this.accentColor,
    this.textColor = Colors.white,
    this.isActive = true,
    this.isOwnGym = false,
    this.isPinned = false,
    this.isActivated = false,
    this.requiresLoggedOutSession = false,
    this.loginExperience = GymLoginExperience.standard,
    this.tenantId,
    this.rating = 4.5,
    this.imageUrl = '',
    this.imageAssetPath = '',
    this.galleryAssetPaths = const [],
    this.filterTags = const [],
    this.city = '',
    this.zipCode = '',
    this.address = '',
    this.tagline = '',
    this.lat = 0.0,
    this.lng = 0.0,
    this.distanceMi,
    this.statusLabel =
        'Targeted integration — partnership not yet established.',
  });

  String get distanceLabel {
    if (distanceMi == null) return '';
    if (distanceMi! < 0.1) return '< 0.1 mi';
    return '${distanceMi!.toStringAsFixed(1)} mi';
  }

  String get logoUrl => remoteLogoUrl;
  String get logoAssetPath => '';
}
