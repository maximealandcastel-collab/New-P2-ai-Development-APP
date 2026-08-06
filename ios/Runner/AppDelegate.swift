import Flutter
    import UIKit
    import UserNotifications

    @main
    @objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

    override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
      // Firebase will be configured here once GoogleService-Info.plist is added (Task #37)
      UNUserNotificationCenter.current().delegate = self
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
      GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }

    override func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
      print("[APNs] Failed to register: \(error.localizedDescription)")
    }

    override func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
      completionHandler([.banner, .badge, .sound])
    }
    }
    