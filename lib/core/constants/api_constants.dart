class ApiConstants {
    /// Override at run time, e.g.:
    /// `flutter run --dart-define=API_BASE_URL=http://127.0.0.1:4001`
    //static const String baseUrl = 'https://fit-tech-ai.replit.app';
    static const String baseUrl = String.fromEnvironment(
      'API_ORIGIN',
      defaultValue: 'https://p2pfitechai.com',
    );
    static const String mediaBaseUrl = String.fromEnvironment(
      'API_ORIGIN',
      defaultValue: 'https://p2pfitechai.com',
    );

    /// ─── Auth Marker ───────────────────────────
    static const String requiresAuthHeader = 'X-Requires-Auth';
    static const Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    /// AUTH ──────────────────────────────────────────────
    static const String login = '/api/v1/auth/login';
    static const String register = '/api/v1/auth/register';
    static const String forgot = '/api/v1/auth/forget-password';
    static const String otpVerify = '/api/v1/auth/verify-otp';
    static const String resendOtp = '/api/v1/auth/resend-otp';
    static const String resetPassword = '/api/v1/auth/reset-password';
    static const String changePassword = '/api/v1/auth/change-password';
    static const String phoneSendOtp = '/api/v1/auth/phone/send';
    static const String phoneOtpStatus = '/api/v1/auth/phone/status';
    static const String updateFcmToken = '/api/v1/auth/fcm-token';
    static const String accountDelete = '/api/v1/auth/account-delete';
    static const String uploadProfilePicture = '/api/v1/auth/upload-profile-picture';
    static const String uploadCoverPhoto = '/api/v1/auth/upload-cover-photo';

    /// USER ──────────────────────────────────────────────
    static const String userProfile = '/api/v1/auth/me';
    static const String userOnboarding = '/api/v1/auth/me/onboarding';
    static const String trainerProfile = '/api/v1/trainer';
    static const String trainerMe = '/api/v1/trainer/me';
    static const String trainerDashboardStats = '/api/v1/trainer/me/dashboard-stats';
    static const String trainerRequest = '/api/v1/trainer-request';
    static const String trainerRequestAll = '/api/v1/trainer-request/all';
    static String acceptTrainerRequest(String requestId, String type) =>
        '/api/v1/trainer-request/$requestId/$type';
    static String trainerKnowledgePack(String trainerId) =>
        '/api/v1/trainer/$trainerId/knowledge-pack';
    static String trainerDetails(String trainerId) => '/api/v1/trainer/$trainerId';
    static String trainers(int page, int limit) =>
        '/api/v1/trainer?page=$page&limit=$limit';

    /// EXERCISE BLOCK ──────────────────────────────────────────────
    static String trainerBlocks(
      String trainerId,
      int page,
      int limit, {
      bool approvedOnly = true,
    }) =>
        '/api/v1/trainer/$trainerId/blocks?approvedOnly=$approvedOnly&page=$page&limit=$limit';

    static String trainerBlocksGenerate(String trainerId) =>
        '/api/v1/trainer/$trainerId/blocks/generate';

    static String trainerBlocksCreate(String trainerId) =>
        '/api/v1/trainer/$trainerId/blocks';

    static String trainerBlockById(String trainerId, String blockId) =>
        '/api/v1/trainer/$trainerId/blocks/$blockId';

    static String blockById(String blockId) => '/api/v1/block/$blockId';

    /// INVOICE ──────────────────────────────────────────────
    static const String invoice = '/api/v1/invoice';
    static const String trainerInvoices = '/api/v1/invoice/trainer';
    static String sendInvoice(String invoiceId) => '/api/v1/invoice/$invoiceId/send';

    /// CATEGORY ──────────────────────────────────────────────
    static const String categoryMy = '/api/v1/category/my';
    static const String categoryCreate = '/api/v1/category/create';
    static String categoryById(String categoryId) => '/api/v1/category/$categoryId';

    /// CONTENT ──────────────────────────────────────────────
    static const String myContent = '/api/v1/content/my-content';
    static const String content = '/api/v1/content/content';
    static String contentById(String id) => '/api/v1/content/content/$id';

    /// DEFAULT CONTENT ──────────────────────────────────────────────
    static const String defaultContent = '/api/v1/content/feed';
    static String defaultContentById(String id) => '/api/v1/content/content/$id';

    /// WORKOUT ──────────────────────────────────────────────
    /// POST — create a new workout goal
    static const String workout = '/api/v1/workout';
    /// GET list with optional filters
    static String workouts({String? status, int page = 1, int limit = 10}) {
      final q = [
        if (status != null) 'status=$status',
        'page=$page',
        'limit=$limit',
      ].join('&');
      return '/api/v1/workout?$q';
    }
    static const String workoutToday = '/api/v1/workout/today';
    static const String workoutTodayOverview = '/api/v1/workout/today/overview';
    static const String workoutProgressionMonthly = '/api/v1/workout/progression/monthly';
    static String workoutById(String workoutId) => '/api/v1/workout/$workoutId';
    static String workoutGenerate(String workoutId) =>
        '/api/v1/workout/$workoutId/generate';
    static String workoutStart(String workoutId) =>
        '/api/v1/workout/$workoutId/start';
    static String workoutComplete(String workoutId, String exerciseId) =>
        '/api/v1/workout/$workoutId/exercises/$exerciseId/complete';
    static String workoutExerciseComplete(String workoutId) =>
        '/api/v1/workout/$workoutId/complete';

    /// AFFILIATE / PARTNER ─────────────────────────────────────────────────────
    static const String affiliateDashboard = '/api/v1/affiliate/dashboard';
    static const String affiliateReferrals = '/api/v1/affiliate/referrals';
    static const String affiliateWithdraw = '/api/v1/affiliate/withdraw';

    /// PROMO CODES ─────────────────────────────────────────────────────────────
    static const String promoValidate = '/api/v1/promo/validate';
    static const String promoRedeem = '/api/v1/promo/redeem';

    /// IAP ──────────────────────────────────────────────
    static const String iapVerify = '/api/v1/iap/verify';

    /// TRAINER WORKOUT PLANS ───────────────────────────────────────────────
    static const String trainerWorkoutPlans = '/api/v1/workout-plan/my-plans';
    static const String trainerMyWorkoutPlans = '/api/v1/workout-plan/trainer/my-plans';
    static const String trainerWorkoutPlanCreate = '/api/v1/workout-plan';

    /// NOTIFICATIONS ──────────────────────────────────────────────
    static const String notifications = '/api/v1/notification';
    static const String notificationsUnreadCount = '/api/v1/notification/unread-count';
    static const String notificationsReadAll = '/api/v1/notification/read-all';

    /// PRIVACY / LEGAL ─────────────────────────────────────────────────────────
    static const String privacyPolicy = '/api/v1/privacy';
    static const String termsAndCondition = '/api/v1/terms';
    static const String aboutUs = '/api/v1/about';

    /// DEVICE ──────────────────────────────────────────────
    static const String userDevices = '/api/v1/devices';
    static const String pairDevice = '/api/v1/devices/pair';
    static String deviceStatus(String deviceId) => '/api/v1/devices/$deviceId/status';
    static String unpairDevice(String deviceId) => '/api/v1/devices/$deviceId';
    static String deviceMetrics(String deviceId) => '/api/v1/devices/$deviceId/metrics';

    /// WITHDRAWAL / EARNINGS ──────────────────────────────────────────────
    static const String trainerEarnings = '/api/v1/withdrawal/earnings';
    static String trainerPayments({required int page, required int limit}) =>
        '/api/v1/withdrawal/payments?page=$page&limit=$limit';
    static const String withdrawal = '/api/v1/withdrawal';

    /// ANAM VIDEO CALL ─────────────────────────────────────────────────────────
    static const String anamUsage = '/api/v1/anam/usage';
    static const String anamSessionStart = '/api/v1/anam/session/start';
    static String anamSessionMessage(String dbSessionId) =>
        '/api/v1/anam/session/$dbSessionId/message';
    static String anamSessionEnd(String dbSessionId) =>
        '/api/v1/anam/session/$dbSessionId/end';
    static String trainerAnam(String trainerId) => '/api/v1/trainer/$trainerId/anam';

    static const String searchHistoryKey = '/searchHistoryKey';
    }
    
