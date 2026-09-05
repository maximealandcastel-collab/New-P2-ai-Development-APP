import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/paywall/controllers/paywall_controller.dart';
import 'package:pler_to_pler_app/features/paywall/presentation/screens/paywall_screen.dart';
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
import 'package:pler_to_pler_app/features/earnings/presentation/screens/payment_request_screen.dart';
import 'package:pler_to_pler_app/features/anam/domain/services/anam_service.dart';
import 'package:pler_to_pler_app/features/anam/presentation/arguments/anam_call_args.dart';
import 'package:pler_to_pler_app/features/anam/presentation/controllers/anam_call_controller.dart';
import 'package:pler_to_pler_app/features/anam/presentation/controllers/anam_connect_controller.dart';
import 'package:pler_to_pler_app/features/anam/presentation/screens/anam_call_screen.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';
import 'package:pler_to_pler_app/features/settings/presentation/children/admin_support_screen.dart';
import 'package:pler_to_pler_app/features/settings/presentation/children/ai_video_chat_connect_screen.dart';
import 'package:pler_to_pler_app/features/settings/presentation/children/change_password_screen.dart';
import 'package:pler_to_pler_app/features/settings/presentation/settings_screen.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/find_trainer_screen.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/trainer_match_screen.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/payment_details_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/user/user_complete_profile_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/admin_bypass_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/forgot_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/otp_verification_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/reset_password_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/sign_up_screen.dart';
import 'package:pler_to_pler_app/features/onboarding/controller/onboarding_controller.dart';
import 'package:pler_to_pler_app/features/onboarding/presentation/screens/onboarding_main_screen.dart';
import 'package:pler_to_pler_app/features/admin/presentation/controllers/admin_dashboard_controller.dart';
import 'package:pler_to_pler_app/features/admin/presentation/screens/admin_user_list_screen.dart';
import 'package:pler_to_pler_app/features/smarter_care/presentation/screens/smarter_care_screen.dart';
import 'package:pler_to_pler_app/features/splash/controllers/splash_controller.dart';
import 'package:pler_to_pler_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/subscribe_select_screen.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/trainer_profile_screen.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/controllers/client_details_controller.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/chat_screen.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/client_details_screen.dart';
import 'package:pler_to_pler_app/features/trainer/request/data/models/trainer_request_model.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/screens/request_details_screen.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_details_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/create_content_controller.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/category_screen.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/content_details_screen.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/create_category_screen.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/create_content_screen.dart';
import 'package:pler_to_pler_app/features/contents/presentation/arguments/video_player_args.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/video_player_screen.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/models/exercise_block_model.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/screens/add_exercise_block_screen.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/screens/add_exercise_screen.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/screens/add_exercise_steps_screen.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/screens/add_exercise_substitutions_screen.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/domain/services/exercise_block_service.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/exercise_block_details_controller.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/screens/exercise_block_details_screen.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/screens/exercise_block_screen.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/screens/generate_exercise_block_screen.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/workout_generating_screen.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/workout_plan_details_screen.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/workout_screen.dart';
import 'package:pler_to_pler_app/features/user/workout_find/presentation/ai_plan_result_screen.dart';
import 'package:pler_to_pler_app/features/notification/presentation/screen/notification_screen.dart';
import 'package:pler_to_pler_app/features/privacy/presentation/screens/privacy_policy_all_screen.dart';
import 'package:pler_to_pler_app/features/settings/presentation/children/earnings_screen.dart';
import 'package:pler_to_pler_app/features/settings/presentation/children/invoice_preview_screen.dart';
import 'package:pler_to_pler_app/features/settings/presentation/children/invoices_screen.dart';
import 'package:pler_to_pler_app/features/settings/presentation/controllers/invoice_preview_controller.dart';
import 'package:pler_to_pler_app/features/user/connect_device/data/models/device_model.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/screens/add_device_screen.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/screens/device_details_screen.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/screens/manage_devices_screen.dart';
import 'package:pler_to_pler_app/features/community/presentation/screens/before_after_screen.dart';

/// Reads a route argument of type [T], or null when it is absent or the wrong
/// type. Bindings run before the page builds, so an unguarded
/// `Get.arguments as T` turns a deep link, a forgotten argument, or a
/// process-death restore into a TypeError thrown inside the binding — which
/// GetX surfaces as a red screen rather than a recoverable error.
T? _arg<T>() => Get.arguments is T ? Get.arguments as T : null;

/// Returns the user to the previous route on the next frame. Used when a route
/// cannot be built because its required argument is missing; popping is far
/// less jarring than a red screen or a permanently blank page.
void _popMissingArgument() {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (Get.key.currentState?.canPop() ?? false) Get.back();
  });
}

/// Registers [next] as the live ContentDetailsController, disposing whatever
/// was registered before. Get.put() overwrites its entry without calling
/// onClose() on the instance it displaces — and because both contentDetails
/// and videoPlayer register this type, the displaced controller's video player
/// kept playing with nothing left holding a reference to stop it.
void _replaceContentDetailsController(ContentDetailsController next) {
  if (Get.isRegistered<ContentDetailsController>()) {
    Get.delete<ContentDetailsController>(force: true);
  }
  Get.put<ContentDetailsController>(next, permanent: false);
}

class AppRoute {
  static String init = "/";
  static String onboardingMainScreen = "/onboardingMainScreen";
  static String loginScreen = "/loginScreen";
  static String forgotScreen = "/forgotScreen";
  static String otpVerificationScreen = "/otpVerificationScreen";
  static String signUpScreen = "/signUpScreen";
  static String paywallScreen = "/paywallScreen";
  static String resetPasswordScreen = "/resetPasswordScreen";
  static String userCompleteProfileScreen = "/completeProfileScreen";
  static String trainerCompleteProfileScreen = "/trainerCompleteProfileScreen";
  static String aiInstructionScreen = "/aiInstructionScreen";
  static String trainAiScreen = "/trainAiScreen";
  static String paymentDetailsScreen = "/trainerUpgradeScreen";
  static String subscribeSelectScreen = "/subscribeSelectScreen";
  static String bottonNavBar = "/bottonNavBar";
  static String findTrainerScreen = "/findTrainerScreen";
  static String trainerProfileScreen = "/trainerProfileScreen";
  static String settingsScreen = "/settingsScreen";
  static String contentCategoryScreen = "/contentCategoryScreen";
  static String createCategoryScreen = "/createCategoryScreen";
  static String createContentScreen = "/createContentScreen";
  static String contentDetailsScreen = "/contentDetailsScreen";
  static String videoPlayerScreen = "/videoPlayerScreen";
  static String chatScreen = "/chatScreen";
  static String userProfileScreen = "/userProfileScreen";
  static String profileScreen = "/profileScreen";
  static String changePasswordScreen = "/changePasswordScreen";
  static String profileInformationScreen = "/profileInformationScreen";
  static String editPersonalInfoScreen = "/editPersonalInfoScreen";
  static String editFitnessInfoScreen = "/editFitnessInfoScreen";
  static String exerciseBlockScreen = "/exerciseBlockScreen";
  static String generateExerciseBlockScreen = "/generateExerciseBlockScreen";
  static String addExerciseBlockScreen = "/addExerciseBlockScreen";
  static String addExerciseScreen = "/addExerciseScreen";
  static String addExerciseStepsScreen = "/addExerciseStepsScreen";
  static String addExerciseSubstitutionsScreen = "/addExerciseSubstitutionsScreen";
  static String exerciseBlockDetailsScreen = "/exerciseBlockDetailsScreen";
  static String clientDetailsScreen = "/clientDetailsScreen";
  static String requestDetailsScreen = "/requestDetailsScreen";
  static String aiVideoChatConnectScreen = "/aiVideoChatConnectScreen";
  static String anamCallScreen = "/anamCallScreen";
  static String workoutScreen = "/workoutScreen";
  static String workoutGeneratingScreen = "/workoutGeneratingScreen";
  static String workoutPlanDetailsScreen = "/workoutPlanDetailsScreen";
  static String aiPlanResult = "/aiPlanResult";
  static String paymentRequestScreen = "/paymentRequestScreen";
  static String earningsScreen = "/earningsScreen";
  static String invoicesScreen = "/invoicesScreen";
  static String invoicePreviewScreen = "/invoicePreviewScreen";
  static String manageDevicesScreen = "/manageDevicesScreen";
  static String addDeviceScreen = "/addDeviceScreen";
  static String deviceDetailsScreen = "/deviceDetailsScreen";
  static String notificationsScreen = "/notificationsScreen";
  static String privacyPolicyScreen = "/privacyPolicyScreen";
  static String adminSupportScreen = "/adminSupportScreen";
  static String smarterCareScreen = "/smarterCareScreen";
  static String adminUserListScreen = "/adminUserListScreen";
  static String beforeAfterScreen = "/beforeAfterScreen";
  static String trainerMatchScreen = "/trainerMatchScreen";
  static String adminBypassScreen = "/adminBypassScreen";

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
    GetPage(
      name: paywallScreen,
      page: () => PaywallScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PaywallController>()) {
          Get.lazyPut<PaywallController>(() => PaywallController(), fenix: true);
        }
      }),
    ),
    GetPage(name: loginScreen, page: () => LoginScreen()),
    // Registered so the route carries a name. Reaching it via an anonymous
    // Get.offAll builder left settings.name null, which made ReelRouteObserver
    // and ApiService's pre-auth check both misread the current route.
    GetPage(name: adminBypassScreen, page: () => AdminBypassScreen()),
    GetPage(name: forgotScreen, page: () => ForgotScreen()),
    GetPage(name: otpVerificationScreen, page: () => OtpVerificationScreen()),
    GetPage(name: resetPasswordScreen, page: () => ResetPasswordScreen()),
    GetPage(
      name: userCompleteProfileScreen,
      page: () => UserCompleteProfileScreen(),
    ),
    GetPage(
      name: trainerCompleteProfileScreen,
      page: () => TrainerCompleteProfileScreen(),
    ),
    GetPage(name: trainAiScreen, page: () => TrainAiScreen()),
    GetPage(name: aiInstructionScreen, page: () => AiInstructionScreen()),
    GetPage(name: paymentDetailsScreen, page: () => PaymentDetailsScreen()),
    GetPage(name: subscribeSelectScreen, page: () => SubscribeSelectScreen()),
    GetPage(name: bottonNavBar, page: () => BottomNavBarMain()),
    GetPage(name: findTrainerScreen, page: () => FindTrainerScreen()),
    GetPage(name: trainerMatchScreen, page: () => const TrainerMatchScreen()),
    GetPage(name: trainerProfileScreen, page: () => TrainerProfileScreen()),
    GetPage(name: userProfileScreen, page: () => UserProfileScreen()),
    GetPage(name: profileScreen, page: () => ProfileScreen()),
    GetPage(name: paymentRequestScreen, page: () => const PaymentRequestScreen()),
    GetPage(
      name: aiVideoChatConnectScreen,
      page: () => const AiVideoChatConnectScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AnamConnectController>(
          () => AnamConnectController(
            anamService: Get.find<AnamService>(),
            profileService: Get.find<ProfileService>(),
          ),
        );
      }),
    ),
    GetPage(
      name: anamCallScreen,
      page: () => const AnamCallScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 280),
      binding: BindingsBuilder(() {
        final args = _arg<AnamCallArgs>();
        if (args == null) {
          _popMissingArgument();
          return;
        }
        Get.put<AnamCallController>(
          AnamCallController(
            anamService: Get.find<AnamService>(),
            args: args,
          ),
          permanent: false,
        );
      }),
    ),
    GetPage(
      name: changePasswordScreen,
      page: () => const ChangePasswordScreen(),
    ),
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
    GetPage(name: contentCategoryScreen, page: () => CategoryScreen()),
    GetPage(name: createCategoryScreen, page: () => CreateCategoryScreen()),
    GetPage(
      name: createContentScreen,
      page: () => const CreateContentScreen(),
      binding: BindingsBuilder(() {
        Get.put<CreateContentController>(
          CreateContentController(
            contentController: Get.find<ContentController>(),
          ),
          permanent: false,
        );
      }),
    ),
    GetPage(
      name: contentDetailsScreen,
      page: () => const ContentDetailsScreen(),
      binding: BindingsBuilder(() {
        final content = _arg<ContentModel>();
        if (content == null) {
          _popMissingArgument();
          return;
        }
        _replaceContentDetailsController(
          ContentDetailsController(content: content),
        );
      }),
    ),
    GetPage(
      name: videoPlayerScreen,
      page: () => const VideoPlayerScreen(),
      binding: BindingsBuilder(() {
        final args = _arg<VideoPlayerArgs>();
        if (args == null) {
          _popMissingArgument();
          return;
        }
        _replaceContentDetailsController(
          ContentDetailsController(videoUrl: args.videoUrl),
        );
      }),
    ),
    GetPage(name: chatScreen, page: () => ChatScreen()),
    GetPage(name: exerciseBlockScreen, page: () => ExerciseBlockScreen()),
    GetPage(
      name: generateExerciseBlockScreen,
      page: () => const GenerateExerciseBlockScreen(),
    ),
    GetPage(
      name: addExerciseBlockScreen,
      page: () => const AddExerciseBlockScreen(),
    ),
    GetPage(
      name: addExerciseScreen,
      page: () => const AddExerciseScreen(),
    ),
    GetPage(
      name: addExerciseStepsScreen,
      page: () => const AddExerciseStepsScreen(),
    ),
    GetPage(
      name: addExerciseSubstitutionsScreen,
      page: () => const AddExerciseSubstitutionsScreen(),
    ),
    GetPage(
      name: exerciseBlockDetailsScreen,
      page: () => const ExerciseBlockDetailsScreen(),
      binding: BindingsBuilder(() {
        final preview = _arg<ExerciseBlockModel>();
        if (preview == null) {
          _popMissingArgument();
          return;
        }
        Get.put<ExerciseBlockDetailsController>(
          ExerciseBlockDetailsController(
            blockId: preview.id ?? '',
            previewBlock: preview,
            service: Get.find<ExerciseBlockService>(),
          ),
          permanent: false,
        );
      }),
    ),
    GetPage(
      name: clientDetailsScreen,
      page: () => const ClientDetailsScreen(),
      binding: BindingsBuilder(() {
        final invoice = _arg<ClientInvoiceModel>();
        if (invoice == null) {
          _popMissingArgument();
          return;
        }
        Get.put<ClientDetailsController>(
          ClientDetailsController(invoice: invoice),
          permanent: false,
        );
      }),
    ),
    GetPage(
      name: requestDetailsScreen,
      page: () {
        final request = _arg<TrainerRequestModel>();
        if (request == null) {
          _popMissingArgument();
          return const SizedBox.shrink();
        }
        return RequestDetailsScreen(request: request);
      },
    ),
    GetPage(
      name: workoutScreen,
      page: () => const WorkoutScreen(),
    ),
    GetPage(
      name: workoutGeneratingScreen,
      page: () => const WorkoutGeneratingScreen(),
    ),
    GetPage(
      name: aiPlanResult,
      page: () => const AiPlanResultScreen(),
    ),
    GetPage(
      name: workoutPlanDetailsScreen,
      page: () => const WorkoutPlanDetailsScreen(),
      binding: BindingsBuilder(() {
        final args = Get.arguments;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (args is WorkoutModel) {
            WorkoutController.to.initWorkoutDetails(args);
          } else if (args is String && args.isNotEmpty) {
            WorkoutController.to.fetchWorkoutById(args);
          }
        });
      }),
    ),
    GetPage(name: earningsScreen, page: () => const EarningsScreen()),
    GetPage(name: invoicesScreen, page: () => const InvoicesScreen()),
    GetPage(
      name: invoicePreviewScreen,
      page: () {
        final invoice = _arg<ClientInvoiceModel>();
        if (invoice == null) {
          _popMissingArgument();
          return const SizedBox.shrink();
        }
        return InvoicePreviewScreen(invoice: invoice);
      },
      binding: BindingsBuilder(() {
        final invoice = _arg<ClientInvoiceModel>();
        if (invoice == null) return;
        Get.put(InvoicePreviewController(invoice: invoice));
      }),
    ),
    GetPage(
      name: manageDevicesScreen,
      page: () => const ManageDevicesScreen(),
    ),
    GetPage(name: addDeviceScreen, page: () => const AddDeviceScreen()),
    GetPage(
      name: deviceDetailsScreen,
      page: () {
        final device = _arg<DeviceModel>();
        if (device == null) {
          _popMissingArgument();
          return const SizedBox.shrink();
        }
        return DeviceDetailsScreen(device: device);
      },
    ),
    GetPage(
      name: notificationsScreen,
      page: () => const NotificationsScreen(),
    ),
    GetPage(
      name: privacyPolicyScreen,
      page: () => const PrivacyPolicyAllScreen(),
    ),    GetPage(
      name: adminSupportScreen,
      page: () => const AdminSupportScreen(),
    ),
    GetPage(
      name: smarterCareScreen,
      page: () => const SmarterCareScreen(),
    ),
    GetPage(
      name: adminUserListScreen,
      page: () => const AdminUserListScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AdminDashboardController>()) {
          Get.put(AdminDashboardController());
        }
      }),
    ),
    GetPage(
      name: beforeAfterScreen,
      page: () => const BeforeAfterScreen(),
    ),
  ];

  /// Fallback for any route name that is not in [routes].
  ///
  /// GetMaterialApp resolves an unmatched route as `(isUnknown ? unknownRoute
  /// : route)!`, so leaving this unset turns every stale or mistyped route name
  /// into a "Null check operator used on a null value" crash. A few navigations
  /// in the app still point at names from the abandoned lib/routes table.
  static final GetPage unknown = GetPage(
    name: '/notFound',
    page: () => const _RouteNotFoundScreen(),
  );
}

class _RouteNotFoundScreen extends StatelessWidget {
  const _RouteNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            "This screen isn't available.",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}