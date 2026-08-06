// Push notifications stubbed — Firebase not yet configured (Task #37).
    // Once GoogleService-Info.plist is added, restore the full implementation.
    import 'package:pler_to_pler_app/core/services/api_service.dart';

    class PushNotificationService {
    PushNotificationService._();
    static final PushNotificationService instance = PushNotificationService._();

    /// No-op until Firebase is wired up.
    Future<void> init(ApiService apiService) async {}
    }
    