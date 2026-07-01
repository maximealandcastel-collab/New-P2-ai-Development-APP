import 'dart:async';

import 'package:anam_flutter_sdk/anam_flutter_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/features/anam/data/models/anam_usage_model.dart';
import 'package:pler_to_pler_app/features/anam/domain/services/anam_service.dart';
import 'package:pler_to_pler_app/features/anam/presentation/arguments/anam_call_args.dart';
import 'package:pler_to_pler_app/features/anam/utils/anam_speak_helper.dart';

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

  static const _customLlmId = 'CUSTOMER_CLIENT_V1';

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
  StreamSubscription<dynamic>? _videoSub;
  StreamSubscription<dynamic>? _audioSub;
  StreamSubscription<dynamic>? _sessionSub;
  StreamSubscription<dynamic>? _errorSub;
  StreamSubscription<dynamic>? _dataChannelSub;
  Timer? _streamWatchdog;

  String? _dbSessionId;
  String? _lastProcessedUserMessage;
  bool _isEnding = false;
  bool _isProcessingMessage = false;

  String get trainerName => _args.trainerName;

  bool get hasError => status.value == AnamCallStatus.error;

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
      isStreamReady.value = false;

      final session = await _anamService.startSession(_args.trainerId);
      _dbSessionId = session.dbSessionId;
      usage.value = session.usage;

      if (!session.hasConnectPayload) {
        throw Exception(
          'Could not connect. Backend did not return sessionToken.',
        );
      }

      final token = session.sessionToken ??
          session.preNegotiatedSession?['sessionToken']?.toString();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Could not connect. Backend did not return sessionToken.',
        );
      }

      status.value = AnamCallStatus.connecting;

      await _cleanupAnamOnly();

      _client = AnamClient(
        options: AnamClientOptions(
          sessionToken: token,
          enableLogging: kDebugMode,
          disableBrains: true,
        ),
      );
      renderer = RTCVideoRenderer();
      await renderer!.initialize();

      _setupClientListeners();

      final personaConfig = PersonaConfig(
        personaId: session.personaId,
        name: session.trainerName ?? _args.trainerName,
        avatarId: session.personaId,
        voiceId: session.personaId,
        llmId: _customLlmId,
      );

      if (session.preNegotiatedSession != null) {
        await _client!.talk(
          preNegotiatedSession: session.preNegotiatedSession,
          onStreamReady: _handleStreamReady,
        );
      } else {
        await _client!.talk(
          personaConfig: personaConfig,
          onStreamReady: _handleStreamReady,
        );
      }

      _startStreamWatchdog();
      _listenForUserSpeech();
    } catch (e) {
      status.value = AnamCallStatus.error;
      errorMessage.value = e.errorMessage;
      if (kDebugMode) debugPrint('Anam startCall error: $e');
      await _cleanupAnamOnly();
    }
  }

  void _handleStreamReady(MediaStream? stream) {
    if (stream == null || renderer == null || isStreamReady.value) return;
    renderer!.srcObject = stream;
    isStreamReady.value = true;
    status.value = AnamCallStatus.connected;
    _streamWatchdog?.cancel();
  }

  void _startStreamWatchdog() {
    _streamWatchdog?.cancel();
    _streamWatchdog = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_client == null || renderer == null || isStreamReady.value) {
        _streamWatchdog?.cancel();
        return;
      }
      AnamSpeakHelper.attachRemoteStream(_client!, renderer!);
      if (renderer!.srcObject != null) {
        isStreamReady.value = true;
        status.value = AnamCallStatus.connected;
        _streamWatchdog?.cancel();
      }
    });
  }

  void _setupClientListeners() {
    _connectionSub?.cancel();
    _videoSub?.cancel();
    _audioSub?.cancel();
    _sessionSub?.cancel();
    _errorSub?.cancel();
    _dataChannelSub?.cancel();

    _videoSub = _client!.on(AnamEvent.videoStreamStarted).listen((stream) {
      _handleStreamReady(stream is MediaStream ? stream : null);
    });

    _audioSub = _client!.on(AnamEvent.audioStreamStarted).listen((stream) {
      _handleStreamReady(stream is MediaStream ? stream : null);
    });

    _sessionSub = _client!.on(AnamEvent.sessionReady).listen((_) {
      if (_client != null && renderer != null) {
        AnamSpeakHelper.attachRemoteStream(_client!, renderer!);
      }
    });

    _connectionSub = _client!
        .on(AnamEvent.connectionEstablished)
        .listen((_) {
      if (_client != null && renderer != null) {
        AnamSpeakHelper.attachRemoteStream(_client!, renderer!);
      }
      if (!isStreamReady.value) {
        status.value = AnamCallStatus.connecting;
      }
    });

    _errorSub = _client!.on(AnamEvent.error).listen((error) {
      status.value = AnamCallStatus.error;
      errorMessage.value = error?.toString() ?? 'Video connection failed';
      if (kDebugMode) debugPrint('Anam SDK error: $error');
    });

    _dataChannelSub =
        _client!.on<dynamic>(AnamEvent.dataChannelMessage).listen((data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      final type = map['type']?.toString();
      if (type == 'user_message' || type == 'transcript') {
        final text = map['content']?.toString() ?? map['text']?.toString();
        if (text != null && text.trim().isNotEmpty) {
          unawaited(_processUserSpeech(text.trim()));
        }
      }
    });
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

      await _processUserSpeech(userText);
    });
  }

  Future<void> _processUserSpeech(String userText) async {
    if (_dbSessionId == null || _isProcessingMessage || _isEnding) return;
    if (userText == _lastProcessedUserMessage) return;

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

      final assistantText = reply.assistantText.trim();
      if (assistantText.isNotEmpty && _client != null) {
        await AnamSpeakHelper.speak(_client!, assistantText);
      }
    } catch (e) {
      errorMessage.value = e.errorMessage;
      if (kDebugMode) debugPrint('Anam message error: $e');
    } finally {
      _isProcessingMessage = false;
    }
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
      _isEnding = false;
      if (popRoute && (Get.key.currentState?.canPop() ?? false)) {
        Get.back();
      }
    }
  }

  Future<void> _cleanupAnamOnly() async {
    _streamWatchdog?.cancel();
    _streamWatchdog = null;
    await _historySub?.cancel();
    _historySub = null;
    await _connectionSub?.cancel();
    _connectionSub = null;
    await _videoSub?.cancel();
    _videoSub = null;
    await _audioSub?.cancel();
    _audioSub = null;
    await _sessionSub?.cancel();
    _sessionSub = null;
    await _errorSub?.cancel();
    _errorSub = null;
    await _dataChannelSub?.cancel();
    _dataChannelSub = null;
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
        return isStreamReady.value
            ? 'Connected — start speaking'
            : 'Connecting to ${_args.trainerName}...';
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
