import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';

class TenantBrandService {
  TenantBrandService._();

  static final TenantBrandService to = TenantBrandService._();

  /// Branding is activated only by the tenant scope returned by the backend at
  /// login. Never infer enterprise membership from an email address or role.
  bool get isKmf =>
      CacheService().get<String>('tenantId')?.trim() == 'kmf-fitness';

  Color get kmfGreen => const Color(0xFF168A3A);

  Color get primaryColor => isKmf ? kmfGreen : AppColors.primary;

  Color get scaffoldBackground =>
      isKmf ? Colors.white : AppColors.backgroundLight;
}
