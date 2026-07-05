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
              AppleAudioCategoryOption.allowBluetoothA2DP,
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

  static Future<void> enableLoudSpeaker({RTCVideoRenderer? renderer}) async {
    if (kIsWeb) return;

    try {
      if (WebRTC.platformIsIOS) {
        await Helper.setAppleAudioIOMode(
          AppleAudioIOMode.localAndRemote,
          preferSpeakerOutput: true,
        );
        await Helper.ensureAudioSession();
      }

      await Helper.setSpeakerphoneOn(true);

      if (WebRTC.platformIsAndroid) {
        await Future<void>.delayed(const Duration(milliseconds: 150));
        await Helper.setSpeakerphoneOn(true);
      }

      await _selectSpeakerOutput(renderer);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AnamAudioHelper.enableLoudSpeaker: $error');
      }
    }
  }

  static Future<void> prepareRemoteAudio({
    MediaStream? stream,
    RTCVideoRenderer? renderer,
  }) async {
    if (stream != null) {
      for (final track in stream.getAudioTracks()) {
        track.enabled = true;
      }
    }

    for (var attempt = 0; attempt < 4; attempt++) {
      await enableLoudSpeaker(renderer: renderer);
      if (attempt < 3) {
        await Future<void>.delayed(
          Duration(milliseconds: 250 * (attempt + 1)),
        );
      }
    }
  }

  static Future<void> _selectSpeakerOutput(RTCVideoRenderer? renderer) async {
    try {
      final outputs = await Helper.audiooutputs;
      for (final device in outputs) {
        final label = device.label.toLowerCase();
        if (!label.contains('speaker') && !label.contains('loud')) {
          continue;
        }

        if (renderer != null) {
          await renderer.audioOutput(device.deviceId);
        } else {
          await Helper.selectAudioOutput(device.deviceId);
        }
        return;
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AnamAudioHelper._selectSpeakerOutput: $error');
      }
    }
  }
}
