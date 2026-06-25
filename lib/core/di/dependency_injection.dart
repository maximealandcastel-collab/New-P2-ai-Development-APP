import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/storage_service.dart';
import 'package:pler_to_pler_app/features/authentication/data/repositories/auth_repository.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/otp_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/reset_pass_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/sign_up_controller.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/profile/data/repositories/profile_repository.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/search/controller/search_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/data/repositories/subscribe_repository.dart';
import 'package:pler_to_pler_app/features/subscribe/domain/services/subscribe_services.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/features/ai/data/repositories/ai_repository.dart';
import 'package:pler_to_pler_app/features/ai/domain/services/ai_service.dart';
import 'package:pler_to_pler_app/features/ai/presentation/controllers/train_ai_controller.dart';
import 'package:pler_to_pler_app/features/trainer/contents/data/repositories/category_repository.dart';
import 'package:pler_to_pler_app/features/trainer/contents/data/repositories/content_repository.dart';
import 'package:pler_to_pler_app/features/trainer/contents/domain/services/category_service.dart';
import 'package:pler_to_pler_app/features/trainer/contents/domain/services/content_service.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/controllers/category_controller.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/privacy/data/repositories/privacy_repository.dart';
import 'package:pler_to_pler_app/features/privacy/domain/services/privacy_services.dart';
import 'package:pler_to_pler_app/features/privacy/presentation/controllers/privacy_controller.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/repositories/device_repository.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/services/apple_watch_service.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/services/bluetooth_service.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/services/device_service.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/controllers/device_pairing_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/forget_pass_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/change_password_controller.dart';

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

    /// profile
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepository(
        cacheService: Get.find<CacheService>(),
        apiService: Get.find<ApiService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ProfileService>(
      () => ProfileService(repository: Get.find<ProfileRepository>()),
      fenix: true,
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        service: Get.find<ProfileService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.put<LoginController>(
      LoginController(
        authService: Get.find<AuthService>(),
        profileService: Get.find<ProfileService>(),
      ),
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

    Get.lazyPut<ChangePasswordController>(
      () => ChangePasswordController(authService: Get.find<AuthService>()),
      fenix: true,
    );

    Get.lazyPut<BottomNavBarController>(
      () => BottomNavBarController(),
      fenix: true,
    );

    Get.lazyPut<SearchHistoryController>(
      () => SearchHistoryController(cacheService: Get.find<CacheService>()),
      fenix: true,
    );

    Get.lazyPut<ProfileCompleteController>(
      () => ProfileCompleteController(
        authService: Get.find<AuthService>(),
        profileService: Get.find<ProfileService>(),
      ),
      fenix: true,
    );

    /// AI
    Get.lazyPut<AiRepository>(
      () => AiRepository(apiService: Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<AiService>(
      () => AiService(repository: Get.find<AiRepository>()),
      fenix: true,
    );
    Get.lazyPut<TrainAiController>(
      () => TrainAiController(
        aiService: Get.find<AiService>(),
        profileService: Get.find<ProfileService>(),
      ),
      fenix: true,
    );

    /// Subscribe
    Get.lazyPut<SubscribeRepository>(
      () => SubscribeRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<SubscribeServices>(
      () => SubscribeServices(repository: Get.find<SubscribeRepository>()),
      fenix: true,
    );
    Get.lazyPut<SubscribeController>(
      () => SubscribeController(
        service: Get.find<SubscribeServices>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    /// Category
    Get.lazyPut<CategoryRepository>(
      () => CategoryRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CategoryService>(
      () => CategoryService(repository: Get.find<CategoryRepository>()),
      fenix: true,
    );
    Get.lazyPut<CategoryController>(
      () => CategoryController(
        service: Get.find<CategoryService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    /// Content
    Get.lazyPut<ContentRepository>(
      () => ContentRepository(apiService: Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<ContentService>(
      () => ContentService(repository: Get.find<ContentRepository>()),
      fenix: true,
    );
    Get.lazyPut<ContentController>(
      () => ContentController(
        service: Get.find<ContentService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    /// Privacy
    Get.lazyPut<PrivacyRepository>(
      () => PrivacyRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<PrivacyServices>(
      () => PrivacyServices(repository: Get.find<PrivacyRepository>()),
      fenix: true,
    );
    Get.lazyPut<PrivacyController>(
      () => PrivacyController(
        service: Get.find<PrivacyServices>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.put<BluetoothService>(BluetoothService.instance, permanent: true);
    Get.put<AppleWatchService>(AppleWatchService(), permanent: true);

    Get.lazyPut<DeviceRepository>(
      () => DeviceRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<DeviceService>(
      () => DeviceService(repository: Get.find<DeviceRepository>()),
      fenix: true,
    );
    Get.lazyPut<DevicePairingController>(
      () => DevicePairingController(
        deviceService: Get.find<DeviceService>(),
        bluetoothService: BluetoothService.instance,
        appleWatchService: Get.find<AppleWatchService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

  }

  static void clear() {
    Get.deleteAll(force: true);
  }
}
