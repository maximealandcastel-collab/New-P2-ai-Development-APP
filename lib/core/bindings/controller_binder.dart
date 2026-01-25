import 'package:get/get.dart';
import 'package:p2p_fitness/features/splash_screen/controllers/splash_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    // splash controllers
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
  }
}
