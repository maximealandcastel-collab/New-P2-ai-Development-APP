import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/storage_service.dart';
import 'package:pler_to_pler_app/features/authentication/data/repositories/auth_repository.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/otp_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/reset_pass_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/sign_up_controller.dart';
import 'package:pler_to_pler_app/features/nav_bar/controllers/nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/search/controller/search_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';

import '../../features/authentication/presentation/controllers/forget_pass_controller.dart';

class DependencyInjection {
  DependencyInjection._();

  static Future<void> init() async {
    /// Connectivity Service
    final connectivityService = ConnectivityService();
    await connectivityService.init();
    Get.put<ConnectivityService>(connectivityService, permanent: true);

    /// Cache Service
    final cacheService = CacheService();
    await CacheService().init();
    Get.put<CacheService>(cacheService, permanent: true);

    /// Storage Service
    await Get.putAsync<StorageService>(() async {
      final storage = StorageService();
      await storage.init();
      return storage;
    });

    /// API Service
    final apiService = ApiService();
    apiService.init(connectivityService, Get.find<CacheService>());
    Get.put<ApiService>(apiService, permanent: true);

    /// Auth
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
    );
    Get.put<AuthService>(
      AuthService(repository: Get.find<AuthRepository>()),
      permanent: true,
    );

    Get.put<LoginController>(
      LoginController(authService: Get.find<AuthService>()),
      permanent: true,
    );

    Get.put<SignUpController>(
      SignUpController(authService: Get.find<AuthService>()),
      permanent: true,
    );
    Get.put<ForgetController>(
      ForgetController(authService: Get.find<AuthService>()),
      permanent: true,
    );

    Get.put<OtpController>(
      OtpController(authService: Get.find<AuthService>()),
      permanent: true,
    );

    Get.put<ResetPassController>(
      ResetPassController(authService: Get.find<AuthService>()),
      permanent: true,
    );

    Get.lazyPut<SubscribeController>(
          () => SubscribeController(service: Get.find()),fenix: true


    );  Get.lazyPut<NavBarController>(
          () => NavBarController(),fenix: true
    ); 
    
    
    Get.lazyPut<SearchHistoryController>(
          () => SearchHistoryController(cacheService:  Get.find<CacheService>()),fenix: true
    );
  }

  static void clear() {
    Get.deleteAll(force: true);
  }
}
