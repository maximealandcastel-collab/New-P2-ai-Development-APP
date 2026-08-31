import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/video_playback_manager.dart';
import 'package:pler_to_pler_app/features/authentication/data/data_sources/auth_local_data_source.dart';
import 'package:pler_to_pler_app/features/authentication/data/data_sources/auth_remote_data_source.dart';
import 'package:pler_to_pler_app/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:pler_to_pler_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:pler_to_pler_app/features/authentication/domain/usecases/login_usecase.dart';
import 'package:pler_to_pler_app/features/authentication/domain/usecases/google_login_usecase.dart';
import 'package:pler_to_pler_app/features/authentication/domain/usecases/register_usecase.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/sign_up_controller.dart';
import 'package:pler_to_pler_app/features/nav_bar/controllers/nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/onboarding/controller/onboarding_controller.dart';
import 'package:pler_to_pler_app/features/profile/controller/profile_controller.dart';
import 'package:pler_to_pler_app/features/splash_screen/controllers/splash_controller.dart';
import 'package:pler_to_pler_app/core/utils/helpers/privacy_and_terms_helper.dart';

/// Dependency Injection Binder for Clean Architecture
/// Registers all dependencies in the correct order:
/// 1. Data Sources (Remote & Local)
/// 2. Repositories
/// 3. Use Cases
/// 4. Controllers/ViewModels
class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    // ============================================
    // AUTHENTICATION LAYER
    // ============================================

    // 1. Data Sources
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(),
      fenix: true,
    );

    Get.lazyPut<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(),
      fenix: true,
    );

    // 2. Repository
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find(),
        localDataSource: Get.find(),
      ),
      fenix: true,
    );

    // 3. Use Cases
    Get.lazyPut(
      () => LoginUseCase(Get.find()),
      fenix: true,
    );

    Get.lazyPut(
      () => GoogleLoginUseCase(Get.find()),
      fenix: true,
    );

    Get.lazyPut(
      () => RegisterUseCase(Get.find()),
      fenix: true,
    );

    // 4. Controllers
    Get.put(
      LoginController(
        loginUseCase: Get.find(),
        googleLoginUseCase: Get.find(),
      ),
    );

    Get.put(
      SignUpController(registerUseCase: Get.find()),
    );

    // ============================================
    // PROFILE LAYER
    // ============================================
    Get.put(
      ProfileController(),
    );

    // ============================================
    // OTHER EXISTING CONTROLLERS
    // ============================================
    Get.put(SplashController());
    Get.put(OnboardingController());
    Get.put(NavBarController());
    Get.lazyPut<PrivacyController>(() => PrivacyController(), fenix: true);

    // ============================================
    // VIDEO PLAYBACK (audio-bleed guard)
    // ============================================
    Get.put(VideoPlaybackManager(), permanent: true);
  }
}
