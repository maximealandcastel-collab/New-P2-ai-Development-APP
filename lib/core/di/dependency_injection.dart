import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/storage_service.dart';
import 'package:pler_to_pler_app/core/services/video_playback_manager.dart';
import 'package:pler_to_pler_app/features/authentication/data/repositories/auth_repository.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/otp_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/reset_pass_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/sign_up_controller.dart';
import 'package:pler_to_pler_app/features/affiliate/presentation/controllers/affiliate_dashboard_controller.dart';
import 'package:pler_to_pler_app/features/admin/presentation/controllers/admin_dashboard_controller.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/profile/data/repositories/profile_repository.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/search/controller/search_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/data/repositories/subscribe_repository.dart';
import 'package:pler_to_pler_app/features/subscribe/domain/services/subscribe_services.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/features/paywall/controllers/paywall_controller.dart';
import 'package:pler_to_pler_app/features/anam/data/repositories/anam_repository.dart';
import 'package:pler_to_pler_app/features/anam/domain/services/anam_service.dart';
import 'package:pler_to_pler_app/features/ai/data/repositories/ai_repository.dart';
import 'package:pler_to_pler_app/features/ai/domain/services/ai_service.dart';
import 'package:pler_to_pler_app/features/ai/presentation/controllers/train_ai_controller.dart';
import 'package:pler_to_pler_app/features/contents/data/repositories/category_repository.dart';
import 'package:pler_to_pler_app/features/contents/data/repositories/content_repository.dart';
import 'package:pler_to_pler_app/features/contents/domain/services/category_service.dart';
import 'package:pler_to_pler_app/features/contents/domain/services/content_service.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/category_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/contents/reels/presentation/controllers/reel_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/data/repositories/workout_repository.dart';
import 'package:pler_to_pler_app/features/user/workout/domain/services/workout_service.dart';
import 'package:pler_to_pler_app/features/home/presentation/controllers/user_home_controller.dart';
import 'package:pler_to_pler_app/features/home/data/repositories/trainer_dashboard_repository.dart';
import 'package:pler_to_pler_app/features/home/domain/services/trainer_dashboard_service.dart';
import 'package:pler_to_pler_app/features/home/presentation/controllers/trainer_home_controller.dart';
import 'package:pler_to_pler_app/features/settings/data/repositories/earnings_repository.dart';
import 'package:pler_to_pler_app/features/settings/domain/services/earnings_service.dart';
import 'package:pler_to_pler_app/features/settings/domain/services/invoices_service.dart';
import 'package:pler_to_pler_app/features/settings/presentation/controllers/earnings_controller.dart';
import 'package:pler_to_pler_app/features/settings/presentation/controllers/invoices_controller.dart';
import 'package:pler_to_pler_app/features/earnings/data/repositories/withdrawal_repository.dart';
import 'package:pler_to_pler_app/features/earnings/domain/services/withdrawal_service.dart';
import 'package:pler_to_pler_app/features/earnings/presentation/controllers/payment_request_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
import 'package:pler_to_pler_app/features/user/history/presentation/controllers/history_controller.dart';
import 'package:pler_to_pler_app/features/privacy/data/repositories/privacy_repository.dart';
import 'package:pler_to_pler_app/features/privacy/domain/services/privacy_services.dart';
import 'package:pler_to_pler_app/features/privacy/presentation/controllers/privacy_controller.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/repositories/client_repository.dart';
import 'package:pler_to_pler_app/features/trainer/clients/domain/services/client_service.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/controllers/clients_controller.dart';
import 'package:pler_to_pler_app/features/trainer/request/data/repositories/request_repository.dart';
import 'package:pler_to_pler_app/features/trainer/request/domain/services/request_service.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/controllers/requests_controller.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/repositories/exercise_block_repository.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/domain/services/exercise_block_service.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/create_exercise_block_controller.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/exercise_block_controller.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/repositories/device_repository.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/services/apple_watch_service.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/services/bluetooth_service.dart';
import 'package:pler_to_pler_app/features/user/connect_device/domain/services/device_service.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/controllers/device_pairing_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/forget_pass_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/change_password_controller.dart';
import 'package:pler_to_pler_app/features/notification/data/repositories/notification_repository.dart';
import 'package:pler_to_pler_app/features/notification/domain/services/notification_service.dart';
import 'package:pler_to_pler_app/features/notification/presentation/controllers/notification_controller.dart';

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

    /// Video playback — single owner of raw VideoPlayerControllers. Must be
    /// permanent: the bottom nav calls stopAll() on it from outside any route,
    /// and it registers an app-lifecycle observer for the whole session.
    Get.put<VideoPlaybackManager>(VideoPlaybackManager(), permanent: true);

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

    /// Anam video call (lazy — SDK loads only when call screen opens)
    Get.lazyPut<AnamRepository>(
      () => AnamRepository(apiService: Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<AnamService>(
      () => AnamService(repository: Get.find<AnamRepository>()),
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

    // PaywallController must be in global DI — PaywallScreen calls
    // Get.find<PaywallController>() as a class field (crashes if not registered).
    Get.lazyPut<PaywallController>(
      () => PaywallController(),
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

    /// Clients
    Get.lazyPut<ClientRepository>(
      () => ClientRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ClientService>(
      () => ClientService(repository: Get.find<ClientRepository>()),
      fenix: true,
    );
    Get.lazyPut<ClientsController>(
      () => ClientsController(
        service: Get.find<ClientService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    /// Requests
    Get.lazyPut<RequestRepository>(
      () => RequestRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<RequestService>(
      () => RequestService(
        repository: Get.find<RequestRepository>(),
        subscribeService: Get.find<SubscribeServices>(),
      ),
      fenix: true,
    );
    Get.lazyPut<RequestsController>(
      () => RequestsController(
        service: Get.find<RequestService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    /// Exercise Block
    Get.lazyPut<ExerciseBlockRepository>(
      () => ExerciseBlockRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ExerciseBlockService>(
      () => ExerciseBlockService(
        repository: Get.find<ExerciseBlockRepository>(),
        profileService: Get.find<ProfileService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ExerciseBlockController>(
      () => ExerciseBlockController(
        service: Get.find<ExerciseBlockService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CreateExerciseBlockController>(
      () => CreateExerciseBlockController(
        service: Get.find<ExerciseBlockService>(),
        blocksController: Get.find<ExerciseBlockController>(),
      ),
      fenix: true,
    );

    /// Content
    Get.lazyPut<ContentRepository>(
      () => ContentRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ContentService>(
      () => ContentService(repository: Get.find<ContentRepository>()),
      fenix: true,
    );
    Get.lazyPut<ReelController>(ReelController.new, fenix: true);
    Get.lazyPut<ContentController>(
      () => ContentController(
        service: Get.find<ContentService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    /// Workout
    Get.lazyPut<WorkoutRepository>(
      () => WorkoutRepository(apiService: Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<WorkoutService>(
      () => WorkoutService(repository: Get.find<WorkoutRepository>()),
      fenix: true,
    );
    Get.lazyPut<WorkoutController>(
      () => WorkoutController(service: Get.find<WorkoutService>()),
      fenix: true,
    );
    Get.lazyPut<UserHomeController>(
      () => UserHomeController(workoutController: Get.find<WorkoutController>()),
      fenix: true,
    );
    Get.lazyPut<TrainerDashboardRepository>(
      () => TrainerDashboardRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<TrainerDashboardService>(
      () => TrainerDashboardService(repository: Get.find<TrainerDashboardRepository>()),
      fenix: true,
    );
    Get.lazyPut<TrainerHomeController>(
      () => TrainerHomeController(
        service: Get.find<TrainerDashboardService>(),
        connectivityService: Get.find<ConnectivityService>(),
        apiService: Get.find<ApiService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<EarningsRepository>(
      () => EarningsRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<EarningsService>(
      () => EarningsService(repository: Get.find<EarningsRepository>()),
      fenix: true,
    );
    Get.lazyPut<EarningsController>(
      () => EarningsController(
        service: Get.find<EarningsService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<InvoicesService>(
      () => InvoicesService(repository: Get.find<ClientRepository>()),
      fenix: true,
    );
    Get.lazyPut<InvoicesController>(
      () => InvoicesController(
        service: Get.find<InvoicesService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<WithdrawalRepository>(
      () => WithdrawalRepository(apiService: Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<WithdrawalService>(
      () => WithdrawalService(repository: Get.find<WithdrawalRepository>()),
      fenix: true,
    );
    Get.lazyPut<PaymentRequestController>(
      () => PaymentRequestController(service: Get.find<WithdrawalService>()),
      fenix: true,
    );
    Get.lazyPut<HistoryController>(
      () => HistoryController(
        service: Get.find<WorkoutService>(),
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

    /// Notifications
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<NotificationService>(
      () => NotificationService(
        repository: Get.find<NotificationRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut<NotificationController>(
      () => NotificationController(
        service: Get.find<NotificationService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    // AffiliateDashboardController — required for affiliate dashboard screen
    Get.lazyPut<AffiliateDashboardController>(
      AffiliateDashboardController.new,
      fenix: true,
    );

    // AdminDashboardController — required for admin dashboard screen
    Get.lazyPut<AdminDashboardController>(
      AdminDashboardController.new,
      fenix: true,
    );

    // Bluetooth/HealthKit wrapped — an init error must never crash the app
    try {
      Get.put<BluetoothService>(BluetoothService.instance, permanent: true);
    } catch (e) {
      print('[DI] BluetoothService init skipped: $e');
    }
    try {
      Get.put<AppleWatchService>(AppleWatchService(), permanent: true);
    } catch (e) {
      print('[DI] AppleWatchService init skipped: $e');
    }

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
