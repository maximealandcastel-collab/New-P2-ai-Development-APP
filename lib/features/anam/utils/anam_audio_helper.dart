import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class AnamAudioHelper {
  AnamAudioHelper._();

  static Future<void> configureForVideoCall() async {
    if (kIsWeb) return;

    try {
      if (WebRTC.platformIsAndroid) {
        await Helper.setAndroidAudioConfiguration(
          AndroidAudioConfiguration(
            manageAudioFocus: true,
            androidAudioMode: AndroidAudioMode.inCommunication,
            androidAudioFocusMode: AndroidAudioFocusMode.gain,
            androidAudioStreamType: AndroidAudioStreamType.voiceCall,
            androidAudioAttributesUsageType:
                AndroidAudioAttributesUsageType.voiceCommunication,
            androidAudioAttributesContentType:
                AndroidAudioAttributesContentType.speech,
            forceHandleAudioRouting: true,
          ),
        );
      } else if (WebRTC.platformIsIOS) {
        await Helper.setAppleAudioConfiguration(
          AppleAudioConfiguration(
            appleAudioCategory: AppleAudioCategory.playAndRecord,
            appleAudioCategoryOptions: {
              AppleAudioCategoryOption.defaultToSpeaker,
              AppleAudioCategoryOption.allowBluetooth,
              AppleAudioCategoryOption.mixWithOthers,
            },
            appleAudioMode: AppleAudioMode.videoChat,
          ),
        );
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AnamAudioHelper.configureForVideoCall: $error');
      }
    }
  }

  static Future<void> enableLoudSpeaker() async {
    if (kIsWeb) return;

    try {
      if (WebRTC.platformIsIOS) {
        await Helper.ensureAudioSession();
      }
      await Helper.setSpeakerphoneOn(true);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AnamAudioHelper.enableLoudSpeaker: $error');
      }
    }
  }

  static Future<void> prepareRemoteAudio(MediaStream? stream) async {
    await enableLoudSpeaker();
    if (stream == null) return;

    for (final track in stream.getAudioTracks()) {
      track.enabled = true;
    }
  }
}
