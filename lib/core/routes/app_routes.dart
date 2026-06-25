import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/ai/presentation/screens/ai_instruction_screen.dart';
import 'package:pler_to_pler_app/features/ai/presentation/screens/train_ai_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/trainer/trainer_complete_profile_screen.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/bottom_nav_bar.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/edit_fitness_info_screen.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/edit_personal_info_screen.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/profile_information_screen.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/trainer_profile_screen.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/user_profile_screen.dart';
import 'package:pler_to_pler_app/features/settings/children/change_password_screen.dart';
import 'package:pler_to_pler_app/features/settings/children/earnings_screen.dart';
import 'package:pler_to_pler_app/features/settings/settings_screen.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/find_trainer_screen.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/payment_details_screen.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/payment_success_screen.dart';
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
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/trainer_profile_screen.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/chat_screen.dart';
import 'package:pler_to_pler_app/features/trainer/contents/domain/services/content_service.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/controllers/create_content_controller.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/screens/category_screen.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/screens/create_category_screen.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/screens/create_content_screen.dart';
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
  static String bottonNavBar = "/bottonNavBar";
  static String findTrainerScreen = "/findTrainerScreen";
  static String trainerProfileScreen = "/trainerProfileScreen";
  static String settingsScreen = "/settingsScreen";
  static String earningsScreen = "/earningsScreen";
  static String contentCategoryScreen = "/contentCategoryScreen";
  static String createCategoryScreen = "/createCategoryScreen";
  static String createContentScreen = "/createContentScreen";
  static String chatScreen = "/chatScreen";
  static String userProfileScreen = "/userProfileScreen";
  static String profileScreen = "/profileScreen";
  static String changePasswordScreen = "/changePasswordScreen";
  static String profileInformationScreen = "/profileInformationScreen";
  static String editPersonalInfoScreen = "/editPersonalInfoScreen";
  static String editFitnessInfoScreen = "/editFitnessInfoScreen";

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
    GetPage(name: paymentSuccessScreen, page: () => PaymentSuccessScreen()),
    GetPage(name: trainerUpgradeScreen, page: () => TrainerUpgradeScreen()),
    GetPage(name: subscribeSelectScreen, page: () => SubscribeSelectScreen()),
    GetPage(name: subscribeSelectScreen, page: () => SubscribeSelectScreen()),
    GetPage(name: bottonNavBar, page: () => BottomNavBarMain()),
    GetPage(name: findTrainerScreen, page: () => FindTrainerScreen()),
    GetPage(name: trainerProfileScreen, page: () => TrainerProfileScreen()),
    GetPage(name: userProfileScreen, page: () => UserProfileScreen()),
    GetPage(name: profileScreen, page: () => ProfileScreen()),
    GetPage(name: changePasswordScreen, page: () => const ChangePasswordScreen()),
    GetPage(
      name: profileInformationScreen,
      page: () => const ProfileInformationScreen(),
    ),
    GetPage(
      name: editPersonalInfoScreen,
      page: () => const EditPersonalInfoScreen(),
      binding: BindingsBuilder(() {
        ProfileController.to.initPersonalInfoForm();
      }),
    ),
    GetPage(
      name: editFitnessInfoScreen,
      page: () => const EditFitnessInfoScreen(),
      binding: BindingsBuilder(() {
        ProfileController.to.initFitnessInfoForm();
      }),
    ),
    GetPage(name: settingsScreen, page: () => SettingsScreen()),
    GetPage(name: earningsScreen, page: () => EarningsScreen()),
    GetPage(name: contentCategoryScreen, page: () => CategoryScreen()),
    GetPage(name: createCategoryScreen, page: () => CreateCategoryScreen()),
    GetPage(
      name: createContentScreen,
      page: () => const CreateContentScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CreateContentController>(
          () => CreateContentController(
            service: Get.find<ContentService>(),
            contentController: Get.find<ContentController>(),
          ),
          fenix: true,
        );
      }),
    ),
    GetPage(name: chatScreen, page: () => ChatScreen()),

    GetPage(name: workoutFinderFlow, page: () => WorkoutFinderFlow()),
    GetPage(name: createExercisePlan, page: () => CreateExercisePlanScreen()),
    GetPage(name: createExercisePlan2, page: () => CreateExercisePlanScreen2()),
  ];
}
