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
      final value = json[key];
      if (value is! String || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(value)) {
        return const Color(0xFFB83B12);
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

  EnterpriseGymModel toGym() => toGyms().first;

  /// Expands every facility supplied by the enterprise API into a selectable
  /// directory record. New locations therefore appear without an app update.
  List<EnterpriseGymModel> toGyms() {
    final sourceLocations = locations.isEmpty
        ? const <Map<String, dynamic>>[<String, dynamic>{}]
        : locations;
    return sourceLocations.asMap().entries.map((entry) {
      final location = entry.value;
      final locationId = (location['id'] ?? location['_id'] ?? entry.key)
          .toString()
          .trim()
          .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final locationPhotos = List<String>.from(
        location['photos'] as List? ?? const <String>[],
      );
      final displayPhotos = locationPhotos.isEmpty ? photos : locationPhotos;
      final locationName = (location['name'] as String?)?.trim() ?? '';
      final locationCity = location['city'] as String? ?? '';
      final locationState = location['state'] as String? ?? '';
      final locationAddress = location['address'] as String? ?? '';
      final resolvedAddress = locationAddress.isNotEmpty
          ? locationAddress
          : [locationCity, locationState]
                .where((part) => part.isNotEmpty)
                .join(', ');

      return EnterpriseGymModel(
        id: sourceLocations.length == 1 ? id : '${id}_$locationId',
        tenantId: id,
        franchiseId: id,
        name: locationName.isEmpty ? name : locationName,
        franchiseName: name,
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
        imageAssetPath: displayPhotos.isEmpty ? '' : displayPhotos.first,
        galleryAssetPaths: displayPhotos,
        address: resolvedAddress,
        city: locationCity,
        zipCode: location['zipCode'] as String? ?? '',
        lat: (location['lat'] as num?)?.toDouble() ?? 0,
        lng: (location['lng'] as num?)?.toDouble() ?? 0,
        tagline: slogan,
      );
    }).toList(growable: false);
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
