import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/sign_up_screen.dart';
import 'package:pler_to_pler_app/features/onboarding/controller/onboarding_controller.dart';
import 'package:pler_to_pler_app/features/onboarding/presentation/screens/onboarding_main_screen.dart';
import 'package:pler_to_pler_app/features/splash_screen/controllers/splash_controller.dart';
import 'package:pler_to_pler_app/features/splash_screen/presentation/screens/splash_screen.dart';
import 'package:pler_to_pler_app/features/trainer/createExercisePlan/presentation/screen/create_exercise_plan_screen.dart';
import 'package:pler_to_pler_app/features/user/workout_find/presentation/exercise_plan_create.dart';
import 'package:pler_to_pler_app/features/user/workout_find/presentation/workout_find_screen.dart';
class AppRoute {
  static String init = "/";
  static String onboardingMainScreen = "/onboardingMainScreen";
  static String loginScreen = "/loginScreen";
  static String signUpScreen = "/signUpScreen";
  static String workoutFinderFlow = "/workoutFinderFlow";
  static String createExercisePlan = "/createExercisePlan";
  static String createExercisePlan2 = "/createExercisePlan2";

  static List<GetPage> routes = [
    GetPage(
      name: init,
      page: () => SplashScreen(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(
      name: onboardingMainScreen,
      page: () => OnboardingMainScreen(),
      binding: BindingsBuilder(() {
        Get.put(OnboardingController());
      }),
    ),
    GetPage(name: loginScreen, page: () => LoginScreen()),
    GetPage(name: signUpScreen, page: () => SignUpScreen()),
    GetPage(name: workoutFinderFlow, page: () => WorkoutFinderFlow()),
    GetPage(name: createExercisePlan, page: () => CreateExercisePlanScreen()),
    GetPage(name: createExercisePlan2, page: () => CreateExercisePlanScreen2()),
  ];
}
