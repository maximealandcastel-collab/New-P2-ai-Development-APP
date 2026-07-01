import 'dart:async';

import 'package:anam_flutter_sdk/anam_flutter_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/features/anam/data/models/anam_usage_model.dart';
import 'package:pler_to_pler_app/features/anam/domain/services/anam_service.dart';
import 'package:pler_to_pler_app/features/anam/presentation/arguments/anam_call_args.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

enum AnamCallStatus {
  idle,
  starting,
  connecting,
  connected,
  ending,
  error,
}

class AnamCallController extends GetxController with WidgetsBindingObserver {
  AnamCallController({
    required AnamService anamService,
    required AnamCallArgs args,
  })  : _anamService = anamService,
        _args = args;

  final AnamService _anamService;
  final AnamCallArgs _args;

  final status = AnamCallStatus.idle.obs;
  final usage = Rxn<AnamUsageModel>();
  final errorMessage = RxnString();
  final lastSuggestedTitle = RxnString();
  final micEnabled = true.obs;
  final isStreamReady = false.obs;

  AnamClient? _client;
  RTCVideoRenderer? renderer;
  StreamSubscription<List<Message>>? _historySub;
  StreamSubscription<dynamic>? _connectionSub;

  String? _dbSessionId;
  String? _lastProcessedUserMessage;
  bool _isEnding = false;
  bool _isProcessingMessage = false;

  String get trainerName => _args.trainerName;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onReady() {
    super.onReady();
    startCall();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(endCall(popRoute: false));
    }
  }

  Future<void> startCall() async {
    if (_isEnding) return;

    try {
      status.value = AnamCallStatus.starting;
      errorMessage.value = null;

      final session = await _anamService.startSession(_args.trainerId);
      _dbSessionId = session.dbSessionId;
      usage.value = session.usage;

      final token = session.sessionToken;
      if (token == null || token.isEmpty) {
        throw Exception('Could not connect. Session token unavailable.');
      }

      status.value = AnamCallStatus.connecting;

      _client = AnamClientFactory.createClient(sessionToken: token);
      renderer = RTCVideoRenderer();
      await renderer!.initialize();

      await _client!.talk(
        personaConfig: PersonaConfig(
          personaId: session.personaId,
          name: session.trainerName ?? _args.trainerName,
          avatarId: session.personaId,
          voiceId: session.personaId,
        ),
        onStreamReady: (stream) {
          if (stream != null && renderer != null) {
            renderer!.srcObject = stream;
            isStreamReady.value = true;
          }
        },
      );

      _listenForUserSpeech();
      _connectionSub = _client!
          .on(AnamEvent.connectionEstablished)
          .listen((_) => status.value = AnamCallStatus.connected);

      status.value = AnamCallStatus.connected;
    } catch (e) {
      status.value = AnamCallStatus.error;
      errorMessage.value = e.errorMessage;
      await _cleanupAnamOnly();
    }
  }

  void _listenForUserSpeech() {
    _historySub?.cancel();
    _historySub = _client!
        .on<List<Message>>(AnamEvent.messageHistoryUpdated)
        .listen((messages) async {
      if (messages.isEmpty ||
          _dbSessionId == null ||
          _isProcessingMessage ||
          _isEnding) {
        return;
      }

      final last = messages.last;
      if (last.role != MessageRole.user) return;

      final userText = last.content.trim();
      if (userText.isEmpty || userText == _lastProcessedUserMessage) return;

      _lastProcessedUserMessage = userText;
      _isProcessingMessage = true;

      try {
        final reply = await _anamService.sendMessage(
          dbSessionId: _dbSessionId!,
          trainerId: _args.trainerId,
          message: userText,
        );

        lastSuggestedTitle.value = reply.suggestedContentTitles.isNotEmpty
            ? reply.suggestedContentTitles.first
            : null;

        if (reply.assistantText.trim().isNotEmpty) {
          _client?.sendUserMessage(reply.assistantText);
        }
      } catch (e) {
        errorMessage.value = e.errorMessage;
      } finally {
        _isProcessingMessage = false;
      }
    });
  }

  void toggleMic() {
    final next = !micEnabled.value;
    micEnabled.value = next;
    _client?.setInputAudioEnabled(next);
  }

  Future<void> endCall({bool popRoute = true}) async {
    if (_isEnding) return;
    _isEnding = true;
    status.value = AnamCallStatus.ending;

    final sessionId = _dbSessionId;
    _dbSessionId = null;

    try {
      await _cleanupAnamOnly();
      if (sessionId != null) {
        final result = await _anamService.endSession(sessionId);
        usage.value = result.usage ?? usage.value;
      }
    } catch (e) {
      errorMessage.value = e.errorMessage;
    } finally {
      status.value = AnamCallStatus.idle;
      if (popRoute && (Get.key.currentState?.canPop() ?? false)) {
        Get.back();
      }
    }
  }

  Future<void> _cleanupAnamOnly() async {
    await _historySub?.cancel();
    _historySub = null;
    await _connectionSub?.cancel();
    _connectionSub = null;
    await _client?.stopStreaming();
    _client = null;
    await renderer?.dispose();
    renderer = null;
    isStreamReady.value = false;
  }

  String statusLabel() {
    switch (status.value) {
      case AnamCallStatus.starting:
        return 'Creating session...';
      case AnamCallStatus.connecting:
        return 'Connecting to ${_args.trainerName}...';
      case AnamCallStatus.connected:
        return 'Connected — start speaking';
      case AnamCallStatus.ending:
        return 'Ending call...';
      case AnamCallStatus.error:
        return errorMessage.value ?? 'Failed to connect';
      case AnamCallStatus.idle:
        return 'Preparing...';
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(endCall(popRoute: false));
    super.onClose();
  }
}
