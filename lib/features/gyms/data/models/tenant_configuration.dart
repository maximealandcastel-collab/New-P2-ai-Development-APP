import 'package:flutter/material.dart';
import 'enterprise_gym_model.dart';

/// Versioned public branding; layout and modules are deliberately not configurable.
class TenantConfiguration {
  final String id, name, slogan, logoUrl, timezone;
  final Color primary, secondary, accent;
  final List<String> photos;
  final String category;
  final List<String> tags;
  final List<Map<String, dynamic>> locations;
  final Map<String, dynamic> contact;
  const TenantConfiguration({
    this.category = 'Enterprise Gym',
    this.tags = const [],
    required this.id,
    required this.name,
    required this.slogan,
    required this.logoUrl,
    required this.timezone,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.photos,
    required this.locations,
    required this.contact,
  });

  factory TenantConfiguration.fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Missing tenant $key');
      }
      return value;
    }

    Color color(String key) {
      final value = requiredString(key);
      if (!RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(value)) {
        throw FormatException('Invalid $key');
      }
      return Color(0xff000000 | int.parse(value.substring(1), radix: 16));
    }

    if (json['schemaVersion'] != 1)
      throw const FormatException('Unsupported tenant version');
    return TenantConfiguration(
      category: json['category'] as String? ?? 'Enterprise Gym',
      tags: List<String>.from(json['tags'] as List? ?? []),
      id: requiredString('id'),
      name: requiredString('name'),
      slogan: json['slogan'] as String? ?? '',
      logoUrl: json['logoUrl'] as String? ?? '',
      timezone: requiredString('timezone'),
      primary: color('primaryColor'),
      secondary: color('secondaryColor'),
      accent: color('accentColor'),
      photos: List<String>.from(json['photos'] as List? ?? []),
      locations: (json['locations'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      contact: Map<String, dynamic>.from(json['contact'] as Map? ?? {}),
    );
  }

  EnterpriseGymModel toGym() {
    final location = locations.isEmpty ? <String, dynamic>{} : locations.first;
    return EnterpriseGymModel(
      id: id,
      tenantId: id,
      name: name,
      initials: name
          .trim()
          .split(RegExp(r'\s+'))
          .take(3)
          .map((s) => s[0])
          .join(),
      category: category,
      filterTags: tags,
      rating: 0,
      memberCount: '',
      brandColor: primary,
      accentColor: accent,
      remoteLogoUrl: logoUrl,
      textColor:
          ThemeData.estimateBrightnessForColor(primary) == Brightness.dark
          ? Colors.white
          : Colors.black,
      isActivated: true,
      loginExperience: GymLoginExperience.whiteLabel,
      imageAssetPath: photos.isEmpty ? '' : photos.first,
      galleryAssetPaths: photos,
      address: location['address'] as String? ?? '',
      city: location['city'] as String? ?? '',
      zipCode: location['zipCode'] as String? ?? '',
      lat: (location['lat'] as num?)?.toDouble() ?? 0,
      lng: (location['lng'] as num?)?.toDouble() ?? 0,
      tagline: slogan,
    );
  }
}

class EnterpriseContext {
  final TenantConfiguration tenant;
  final List<String> roles;
  final List<String> capabilities;
  const EnterpriseContext({
    required this.tenant,
    required this.roles,
    required this.capabilities,
  });
  bool get isAdmin => roles.contains('owner') || roles.contains('admin');
  factory EnterpriseContext.fromJson(Map<String, dynamic> json) =>
      EnterpriseContext(
        tenant: TenantConfiguration.fromJson(
          Map<String, dynamic>.from(json['tenant'] as Map),
        ),
        roles: List<String>.from(json['roles'] as List),
        capabilities: List<String>.from(json['capabilities'] as List? ?? []),
      );
}

class EnterprisePage {
  final List<Map<String, dynamic>> items;
  final String? nextCursor;
  const EnterprisePage(this.items, this.nextCursor);
  factory EnterprisePage.fromJson(Map<String, dynamic> json) => EnterprisePage(
    (json['items'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(),
    json['nextCursor'] as String?,
  );
}
