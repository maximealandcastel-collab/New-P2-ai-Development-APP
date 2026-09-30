import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/themes/enterprise_gym_theme.dart';
import 'package:pler_to_pler_app/core/constants/enterprise_flags.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';

class TenantBrand {
  final String tenantId, displayName, tagline, logoAssetPath;
  final Color primaryColor, accentColor, scaffoldBackground;
  final EnterpriseGymTheme theme;
  const TenantBrand({
    required this.tenantId,
    required this.displayName,
    required this.tagline,
    required this.logoAssetPath,
    required this.primaryColor,
    required this.accentColor,
    required this.scaffoldBackground,
    required this.theme,
  });

  factory TenantBrand.fromGym(EnterpriseGymModel gym) => TenantBrand(
    tenantId: gym.tenantId!,
    displayName: gym.name,
    tagline: gym.tagline,
    logoAssetPath: gym.logoAssetPath.isNotEmpty
        ? gym.logoAssetPath
        : gym.logoUrl,
    primaryColor: gym.brandColor,
    accentColor: gym.accentColor,
    scaffoldBackground: Colors.white,
    theme: EnterpriseGymTheme.fromColors(
      primary: gym.brandColor,
      secondary: gym.accentColor,
      accent: gym.accentColor,
    ),
  );
}

class TenantBrandService {
  TenantBrandService._();
  static final to = TenantBrandService._();

  TenantBrand? get activeBrand {
    final config = EnterpriseService.instance.active.value?.tenant;
    if (config == null) {
      // Bundled gym mode has a backend-issued tenant scope but no live
      // enterprise context. Restore its palette for the signed-in member.
      if (!isSingleMode ||
          (CacheService().get<String>('accessToken')?.isNotEmpty != true)) {
        return null;
      }
      final id = CacheService().get<String>('tenantId');
      if (id == null || id.isEmpty) return null;
      for (final gym in EnterpriseGymModel.activatedPartners) {
        if (gym.tenantId == id) return TenantBrand.fromGym(gym);
      }
      return null;
    }
    final theme = EnterpriseGymTheme.fromColors(
      primary: config.primary,
      secondary: config.secondary,
      accent: config.accent,
    );
    return TenantBrand(
      tenantId: config.id,
      displayName: config.name,
      tagline: config.slogan,
      logoAssetPath: config.logoUrl,
      primaryColor: theme.primaryBrandColor,
      accentColor: config.accent,
      scaffoldBackground: Colors.white,
      theme: theme,
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
  EnterpriseGymTheme get theme => activeBrand?.theme ??
      EnterpriseGymTheme.fromColors(primary: AppColors.primary);
}
