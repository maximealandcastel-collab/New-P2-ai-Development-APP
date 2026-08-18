// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:maignanka_app/app/helpers/prefs_helper.dart';
// import 'package:maignanka_app/app/utils/app_constants.dart';
//
// class FirebaseNotificationService {
//   static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
//
//   // Singleton pattern
//   FirebaseNotificationService._privateConstructor();
//
//   static final FirebaseNotificationService instance =
//   FirebaseNotificationService._privateConstructor();
//
//   /// **Initialize Firebase Notifications and Socket**
//   static Future<void> initialize() async {
//     // Request notification permission
//     final settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       sound: true,
//       badge: true,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.denied) {
//       debugPrint("🚫 Notification permission denied");
//       return;
//     }
//
//     // Initialize local notifications
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosInit = DarwinInitializationSettings(
//       requestSoundPermission: true,
//       requestBadgePermission: true,
//       requestAlertPermission: true,
//     );
//
//     const initSettings =
//     InitializationSettings(android: androidInit, iOS: iosInit);
//     await _localNotifications.initialize(initSettings);
//
//     // Handle FCM messages
//     FirebaseMessaging.onMessage
//         .listen((message) => _handleForegroundMessage(message));
//     FirebaseMessaging.onMessageOpenedApp.listen((message) =>
//         debugPrint("📩 App opened from notification: ${message.data}"));
//   }
//
//   /// **Handle foreground FCM messages and show local notification**
//   static Future<void> _handleForegroundMessage(RemoteMessage message) async {
//     debugPrint("📩 Received foreground notification: ${message.notification?.title}");
//
//     final notification = message.notification;
//     final android = notification?.android;
//
//     if (notification != null &&
//         (android != null || defaultTargetPlatform == TargetPlatform.iOS)) {
//       _localNotifications.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             'reservation_channel',
//             'Gestion App',
//             importance: Importance.max,
//             priority: Priority.high,
//             playSound: true,
//             icon: '@mipmap/ic_launcher',
//             styleInformation: BigTextStyleInformation(notification.body ?? '',
//                 contentTitle: notification.title ?? ''),
//           ),
//           iOS: DarwinNotificationDetails(),
//         ),
//       );
//     }
//   }
//
//   /// **Retrieve FCM Token**
//   static Future<String?> getFCMToken() async {
//     // Request notification permissions first
//     final settings = await _firebaseMessaging.getNotificationSettings();
//
//     if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
//       await _firebaseMessaging.requestPermission(
//           alert: true, badge: true, sound: true);
//     }
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized ||
//         settings.authorizationStatus == AuthorizationStatus.provisional) {
//       // For iOS, try to get the APNs token first
//       if (defaultTargetPlatform == TargetPlatform.iOS) {
//         String? apnsToken;
//         int attempts = 0;
//
//         // Retry fetching APNs token for up to 5 seconds
//         while (apnsToken == null && attempts < 10) {
//           apnsToken = await _firebaseMessaging.getAPNSToken();
//           await Future.delayed(
//               const Duration(milliseconds: 500)); // Delay before retrying
//           attempts++;
//         }
//
//         if (apnsToken == null) {
//           debugPrint("🚫 APNs token not available yet");
//           return null;
//         }
//
//         debugPrint("✅ APNs token: $apnsToken");
//       }
//
//       // Now that APNs token is available, get the FCM token
//       final fcmToken = await _firebaseMessaging.getToken();
//       debugPrint("✅ FCM token: $fcmToken");
//       return fcmToken;
//     }
//
//     debugPrint("❌ User denied notification permission");
//     return null;
//   }
//
//   /// **Print FCM Token & Store it in Preferences**
//   static Future<void> printFCMToken() async {
//     String token = await PrefsHelper.getString(AppConstants.fcmToken);
//     if (token.isNotEmpty) {
//       debugPrint("🔑 FCM Token (Stored): $token");
//     } else {
//       token = await getFCMToken() ?? '';
//       PrefsHelper.setString(AppConstants.fcmToken, token);
//       debugPrint("🔑 FCM Token (New): $token");
//     }
//   }
// }
