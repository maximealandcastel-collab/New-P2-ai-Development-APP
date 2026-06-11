import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/ai/presentation/screens/ai_instruction_screen.dart';
import 'package:pler_to_pler_app/features/ai/presentation/screens/train_ai_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/trainer/trainer_complete_profile_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/user/payment_details_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/user/profile_setup_success_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/user/user_complete_profile_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/forgot_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/otp_verification_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/reset_password_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/sign_up_screen.dart';
import 'package:pler_to_pler_app/features/onboarding/controller/onboarding_controller.dart';
import 'package:pler_to_pler_app/features/onboarding/presentation/screens/onboarding_main_screen.dart';
import 'package:pler_to_pler_app/features/splash/controllers/splash_controller.dart';
import 'package:pler_to_pler_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/subscribe_select_screen.dart';
import 'package:pler_to_pler_app/features/trainer/createExercisePlan/presentation/screen/create_exercise_plan_screen.dart';
import 'package:pler_to_pler_app/features/user/workout_find/presentation/exercise_plan_create.dart';
import 'package:pler_to_pler_app/features/user/workout_find/presentation/workout_find_screen.dart';

class AppRoute {
  static String init = "/";
  static String onboardingMainScreen = "/onboardingMainScreen";
  static String loginScreen = "/loginScreen";
  static String forgotScreen = "/forgotScreen";
  static String otpVerificationScreen = "/otpVerificationScreen";
  static String signUpScreen = "/signUpScreen";
  static String resetPasswordScreen = "/resetPasswordScreen";
  static String userCompleteProfileScreen = "/completeProfileScreen";
  static String trainerCompleteProfileScreen = "/trainerCompleteProfileScreen";
  static String aiInstructionScreen = "/aiInstructionScreen";
  static String trainAiScreen = "/trainAiScreen";
  static String workoutFinderFlow = "/workoutFinderFlow";
  static String createExercisePlan = "/createExercisePlan";
  static String createExercisePlan2 = "/createExercisePlan2";
  static String paymentSuccessScreen = "/paymentSuccessScreen";
  static String trainerUpgradeScreen = "/trainerUpgradeScreen";
  static String subscribeSelectScreen = "/subscribeSelectScreen";

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
    GetPage(name: signUpScreen, page: () => SignUpScreen()),
    GetPage(name: loginScreen, page: () => LoginScreen()),
    GetPage(name: forgotScreen, page: () => ForgotScreen()),
    GetPage(name: otpVerificationScreen, page: () => OtpVerificationScreen()),
    GetPage(name: resetPasswordScreen, page: () => ResetPasswordScreen()),
    GetPage(name: userCompleteProfileScreen, page: () => UserCompleteProfileScreen()),
    GetPage(name: trainerCompleteProfileScreen, page: () => TrainerCompleteProfileScreen()),
    GetPage(name: trainAiScreen, page: () => TrainAiScreen()),
    GetPage(name: aiInstructionScreen, page: () => AiInstructionScreen()),
    GetPage(name: paymentSuccessScreen, page: () => ProfileSetupSuccessScreen()),
    GetPage(name: trainerUpgradeScreen, page: () => TrainerUpgradeScreen()),
    GetPage(name: subscribeSelectScreen, page: () => SubscribeSelectScreen()),

    GetPage(name: workoutFinderFlow, page: () => WorkoutFinderFlow()),
    GetPage(name: createExercisePlan, page: () => CreateExercisePlanScreen()),
    GetPage(name: createExercisePlan2, page: () => CreateExercisePlanScreen2()),
  ];
}
