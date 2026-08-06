// ─────────────────────────────────────────────────────────────────────────────
// IMPORTANT: Replace every TODO value below with the real values from your
// Firebase project before building.
//
// How to get these values:
//   1. Open https://console.firebase.google.com → your project
//   2. iOS app → "GoogleService-Info.plist" → open the file and copy:
//        API_KEY            → apiKey
//        GOOGLE_APP_ID      → appId
//        GCG_SENDER_ID      → messagingSenderId
//        PROJECT_ID         → projectId
//        STORAGE_BUCKET     → storageBucket
//        BUNDLE_ID          → iosBundleId
//   3. Run `flutterfire configure` to generate this file automatically, OR
//      fill in the values manually below.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── iOS ──────────────────────────────────────────────────────────────────
  // Replace the TODO values with the real ones from GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TODO_PASTE_API_KEY',               // API_KEY
    appId: 'TODO_PASTE_GOOGLE_APP_ID',          // GOOGLE_APP_ID
    messagingSenderId: 'TODO_PASTE_GCG_SENDER_ID', // GCG_SENDER_ID
    projectId: 'TODO_PASTE_PROJECT_ID',         // PROJECT_ID
    storageBucket: 'TODO_PASTE_STORAGE_BUCKET', // STORAGE_BUCKET
    iosBundleId: 'com.p2pfittech.ai',           // must match your bundle ID
  );

  // ── Android ──────────────────────────────────────────────────────────────
  // Replace if you add Android to the Firebase project
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TODO_PASTE_ANDROID_API_KEY',
    appId: 'TODO_PASTE_ANDROID_APP_ID',
    messagingSenderId: 'TODO_PASTE_GCG_SENDER_ID',
    projectId: 'TODO_PASTE_PROJECT_ID',
    storageBucket: 'TODO_PASTE_STORAGE_BUCKET',
  );
}
