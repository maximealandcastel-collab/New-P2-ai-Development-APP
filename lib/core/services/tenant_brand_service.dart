import 'package:pler_to_pler_app/core/constants/enterprise_flags.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';

class TenantBrand {
  final String tenantId, displayName, tagline, logoAssetPath;
  final Color primaryColor, scaffoldBackground;
  const TenantBrand({
    required this.tenantId,
    required this.displayName,
    required this.tagline,
    required this.logoAssetPath,
    required this.primaryColor,
    required this.scaffoldBackground,
  });
}

class TenantBrandService {
  TenantBrandService._();
  static final to = TenantBrandService._();
  TenantBrand? get activeBrand {
    if (isSingleMode) {
      if (CacheService().get<String>('tenantId') != 'kmf-fitness') return null;
      return const TenantBrand(
        tenantId: 'kmf-fitness',
        displayName: 'KMF Fitness',
        tagline: 'Keep Moving Forward',
        logoAssetPath: 'assets/images/gym_logos/kmf_fitness_club.jpg',
        primaryColor: Color(0xFF168A3A),
        scaffoldBackground: Colors.white,
      );
    }
    final config = EnterpriseService.instance.active.value?.tenant;
    if (config == null) return null;
    return TenantBrand(
      tenantId: config.id,
      displayName: config.name,
      tagline: config.slogan,
      logoAssetPath: config.logoUrl,
      primaryColor: config.accent,
      scaffoldBackground: config.primary,
    );
  }

  bool get isWhiteLabeled => activeBrand != null;
  String get displayName => activeBrand?.displayName ?? 'P2P FitTech AI';
  String get tagline => activeBrand?.tagline ?? 'Your fitness, your way';
  String? get logoAssetPath => activeBrand?.logoAssetPath;
  Color get primaryColor => activeBrand?.primaryColor ?? AppColors.primary;
  Color get scaffoldBackground =>
      activeBrand?.scaffoldBackground ?? AppColors.backgroundLight;
}
