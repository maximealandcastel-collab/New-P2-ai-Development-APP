import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';

enum TenantAdminExperience { none, kmf }

class TenantBrand {
  final String tenantId;
  final String displayName;
  final String tagline;
  final String logoAssetPath;
  final Color primaryColor;
  final Color scaffoldBackground;
  final TenantAdminExperience adminExperience;

  const TenantBrand({
    required this.tenantId,
    required this.displayName,
    required this.tagline,
    required this.logoAssetPath,
    required this.primaryColor,
    required this.scaffoldBackground,
    this.adminExperience = TenantAdminExperience.none,
  });
}

class TenantBrandService {
  TenantBrandService._();

  static final TenantBrandService to = TenantBrandService._();

  static const _brands = <String, TenantBrand>{
    'kmf-fitness': TenantBrand(
      tenantId: 'kmf-fitness',
      displayName: 'KMF Fitness',
      tagline: 'Keep Moving Forward',
      logoAssetPath: 'assets/images/gym_logos/kmf_fitness_club.jpg',
      primaryColor: Color(0xFF168A3A),
      scaffoldBackground: Colors.white,
      adminExperience: TenantAdminExperience.kmf,
    ),
  };

  /// Tenant identity is activated only by backend-issued scope. Never infer it
  /// from email, selected role, or a screen route.
  TenantBrand? brandFor(String? tenantId) =>
      _brands[tenantId?.trim().toLowerCase()];

  TenantBrand? get activeBrand =>
      brandFor(CacheService().get<String>('tenantId'));

  TenantBrand? firstAdminBrand(Iterable<String> tenantIds) {
    for (final tenantId in tenantIds) {
      final brand = brandFor(tenantId);
      if (brand?.adminExperience != TenantAdminExperience.none) return brand;
    }
    return null;
  }

  bool get isWhiteLabeled => activeBrand != null;
  bool get isKmf => activeBrand?.tenantId == 'kmf-fitness';
  String get displayName => activeBrand?.displayName ?? 'P2P FitTech AI';
  String get tagline => activeBrand?.tagline ?? 'Your fitness, your way';
  String? get logoAssetPath => activeBrand?.logoAssetPath;
  Color get primaryColor => activeBrand?.primaryColor ?? AppColors.primary;
  Color get scaffoldBackground =>
      activeBrand?.scaffoldBackground ?? AppColors.backgroundLight;
}
