import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/user/workout_find/presentation/ai_plan_result_screen.dart';
import 'package:pler_to_pler_app/features/user/workout_find/presentation/exercise_plan_create.dart';
import 'package:pler_to_pler_app/features/user/workout_find/presentation/workout_find_screen.dart';
import 'package:pler_to_pler_app/features/user/rate_my_peel/presentation/rate_my_peel_screen.dart';

import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/sign_up_screen.dart';
import '../features/paywall/controllers/paywall_controller.dart';
import '../features/paywall/presentation/screens/paywall_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

class AppRoute {
  static String init = "/";
  static String loginScreen = "/loginScreen";
  static String signUpScreen = "/signUpScreen";
  static String workoutFinderFlow = "/workoutFinderFlow";
  static String createExercisePlan2 = "/createExercisePlan2";
  static String aiPlanResult = "/aiPlanResult";
  static String paywallScreen = "/paywallScreen";
  static String rateMyPeel = "/rateMyPeel";
  // Registered by the core route table; kept here for workout-flow navigation.
  static String bottonNavBar = "/bottonNavBar";

  static List<GetPage> routes = [
    GetPage(name: init, page: () => SplashScreen()),
    GetPage(name: loginScreen, page: () => LoginScreen()),
    GetPage(name: signUpScreen, page: () => SignUpScreen()),
    GetPage(name: workoutFinderFlow, page: () => WorkoutFinderFlow()),
    GetPage(name: createExercisePlan2, page: () => CreateExercisePlanScreen2()),
    GetPage(name: aiPlanResult, page: () => const AiPlanResultScreen()),
    GetPage(name: rateMyPeel, page: () => const RateMyPeelScreen()),
    GetPage(
      name: paywallScreen,
      page: () => PaywallScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PaywallController>(() => PaywallController());
      }),
    ),
  ];
}
