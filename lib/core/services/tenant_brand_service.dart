import 'package:pler_to_pler_app/core/constants/enterprise_flags.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';

class TenantBrand {
  final String tenantId, displayName, tagline, logoAssetPath;
  final Color primaryColor, accentColor, scaffoldBackground;
  const TenantBrand({
    required this.tenantId,
    required this.displayName,
    required this.tagline,
    required this.logoAssetPath,
    required this.primaryColor,
    required this.accentColor,
    required this.scaffoldBackground,
  });

  factory TenantBrand.fromGym(EnterpriseGymModel gym) => TenantBrand(
        tenantId: gym.tenantId!,
        displayName: gym.name,
        tagline: gym.tagline,
        logoAssetPath:
            gym.logoAssetPath.isNotEmpty ? gym.logoAssetPath : gym.logoUrl,
        primaryColor: gym.brandColor,
        accentColor: gym.accentColor,
        scaffoldBackground: Colors.white,
      );
}

class TenantBrandService {
  TenantBrandService._();
  static final to = TenantBrandService._();

  EnterpriseGymModel? _configuredGym(String tenantId) {
    for (final gym in EnterpriseGymModel.activatedPartners) {
      if (gym.tenantId == tenantId && gym.hasCompleteTenantFoundation) {
        return gym;
      }
    }
    return null;
  }

  TenantBrand? get activeBrand {
    if (isSingleMode) {
      final tenantId = CacheService().get<String>('tenantId');
      if (tenantId == null) return null;
      final gym = _configuredGym(tenantId);
      return gym == null ? null : TenantBrand.fromGym(gym);
    }
    final config = EnterpriseService.instance.active.value?.tenant;
    if (config == null) return null;
    return TenantBrand(
      tenantId: config.id,
      displayName: config.name,
      tagline: config.slogan,
      logoAssetPath: config.logoUrl,
      primaryColor: config.primary,
      accentColor: config.accent,
      scaffoldBackground: Colors.white,
    );
  }

  bool get isWhiteLabeled => activeBrand != null;
  String get displayName => activeBrand?.displayName ?? 'P2P FitTech AI';
  String get tagline => activeBrand?.tagline ?? 'Your fitness, your way';
  String? get logoAssetPath => activeBrand?.logoAssetPath;
  Color get primaryColor => activeBrand?.primaryColor ?? AppColors.primary;
  Color get accentColor => activeBrand?.accentColor ?? AppColors.primary;
  Color get scaffoldBackground =>
      activeBrand?.scaffoldBackground ?? AppColors.backgroundLight;
}
