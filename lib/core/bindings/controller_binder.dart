import 'package:get/get.dart';
import 'package:p2p_fitness/features/authentication/controllers/login_controller.dart';
import 'package:p2p_fitness/features/authentication/controllers/sign_up_controller.dart';
import 'package:p2p_fitness/features/onboarding/controller/onboarding_controller.dart';
import 'package:p2p_fitness/features/splash_screen/controllers/splash_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    // splash controllers
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(),
      fenix: true,
    );

    // auth controllers
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<SignUpController>(() => SignUpController(), fenix: true);
  }
}
