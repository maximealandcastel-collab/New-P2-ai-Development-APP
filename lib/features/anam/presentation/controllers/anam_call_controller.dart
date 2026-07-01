import 'dart:async';

import 'package:anam_flutter_sdk/anam_flutter_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/features/anam/data/anam_engine_client.dart';
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

  static const _maxStreamWatchAttempts = 60;

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
  StreamSubscription<dynamic>? _closedSub;
  Timer? _streamWatchdog;
  int _streamWatchAttempts = 0;
  int _startGeneration = 0;

  final AnamEngineClient _engineClient = AnamEngineClient();

  String? _dbSessionId;
  String? _lastProcessedUserMessage;
  bool _isEnding = false;
  bool _isStarting = false;
  bool _isProcessingMessage = false;
  bool _disableAnamBrains = true;

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
    // Do not end on [inactive] — iOS fires it for Control Center, permission
    // dialogs, and other overlays. Only end when the app is actually backgrounded.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      unawaited(endCall(popRoute: false));
    }
  }

  bool get isStartingCall =>
      _isStarting || status.value == AnamCallStatus.starting;

  Future<void> startCall({bool isRetryAfterActiveSession = false}) async {
    if (_isEnding || _isStarting) return;

    _isStarting = true;
    final generation = ++_startGeneration;

    try {
      status.value = AnamCallStatus.starting;
      errorMessage.value = null;
      isStreamReady.value = false;

      await _cleanupAnamOnly();

      final previousDbSessionId = _dbSessionId;
      _dbSessionId = null;
      if (previousDbSessionId != null) {
        try {
          await _anamService.endSession(previousDbSessionId);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Anam end previous session failed: $e');
          }
        }
      }

      if (generation != _startGeneration) return;

      final session = await _anamService.startSession(_args.trainerId);
      if (generation != _startGeneration) return;

      _dbSessionId = session.dbSessionId;
      _disableAnamBrains = session.usesClientCustomLlm;
      if (kDebugMode) {
        debugPrint(
          'Anam dbSessionId: $_dbSessionId '
          'customLlm=${session.customLlm} llmId=${session.llmId}',
        );
      }
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

      _client = AnamClientFactory.createClient(
        sessionToken: token,
        enableLogging: kDebugMode,
        disableBrains: _disableAnamBrains,
      );
      renderer = RTCVideoRenderer();
      await renderer!.initialize();

      if (generation != _startGeneration) return;

      _setupClientListeners();

      final preNegotiated = session.preNegotiatedSession ??
          await _engineClient.startEngineSession(
            sessionToken: token,
            personaId: session.personaId,
            disableBrains: _disableAnamBrains,
          );

      if (kDebugMode) {
        debugPrint(
          'Anam engine session: ${preNegotiated['sessionId']} '
          'host=${preNegotiated['engineHost']} '
          'disableBrains=$_disableAnamBrains',
        );
      }

      await runZonedGuarded(
        () => _client!.talk(
          preNegotiatedSession: preNegotiated,
          onStreamReady: _handleStreamReady,
        ),
        _handleStreamError,
      );

      if (generation != _startGeneration) return;

      _startStreamWatchdog();
      _listenForUserSpeech();
    } catch (e) {
      if (generation != _startGeneration) return;

      final message = e.errorMessage.toLowerCase();
      if (!isRetryAfterActiveSession &&
          (message.contains('active call session') ||
              message.contains('already have an active'))) {
        if (kDebugMode) {
          debugPrint('Anam: active session conflict — ending and retrying');
        }
        _isStarting = false;
        await startCall(isRetryAfterActiveSession: true);
        return;
      }

      status.value = AnamCallStatus.error;
      errorMessage.value = e.errorMessage;
      if (kDebugMode) debugPrint('Anam startCall error: $e');
      await _cleanupAnamOnly();
    } finally {
      if (generation == _startGeneration) {
        _isStarting = false;
      }
    }
  }

  void _handleStreamReady(MediaStream? stream) {
    if (stream == null || renderer == null || isStreamReady.value) return;
    try {
      renderer!.srcObject = stream;
      isStreamReady.value = true;
      status.value = AnamCallStatus.connected;
      errorMessage.value = null;
      _streamWatchdog?.cancel();
    } catch (e) {
      if (kDebugMode) debugPrint('Anam attach stream warning: $e');
    }
  }

  bool _isIgnorableStreamError(Object error) {
    if (error is UnimplementedError) return true;
    final message = error.toString();
    return message.contains('UnimplementedError') ||
        message.contains('MediaStream.active');
  }

  void _startStreamWatchdog() {
    _streamWatchdog?.cancel();
    _streamWatchAttempts = 0;
    _streamWatchdog = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_client == null || renderer == null || isStreamReady.value) {
        _streamWatchdog?.cancel();
        return;
      }

      _streamWatchAttempts++;
      if (_streamWatchAttempts > _maxStreamWatchAttempts) {
        _streamWatchdog?.cancel();
        if (!_isEnding && !isStreamReady.value) {
          status.value = AnamCallStatus.error;
          errorMessage.value =
              'Video stream timed out. Please try again.';
        }
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

  void _handleStreamError(Object error, [StackTrace? stackTrace]) {
    if (_isEnding || _isStarting) return;

    if (_isIgnorableStreamError(error)) {
      if (kDebugMode) {
        debugPrint('Anam: ignored flutter_webrtc SDK noise: $error');
      }
      return;
    }

    final message = error.toString();
    if (kDebugMode) {
      debugPrint('Anam stream error: $message');
    }

    if (message.contains('Session ended by server')) {
      unawaited(_handleServerEndSession());
      return;
    }

    if (isStreamReady.value) return;

    status.value = AnamCallStatus.error;
    errorMessage.value = message;
  }

  Future<void> _handleServerEndSession() async {
    if (_isEnding || _isStarting) return;

    status.value = AnamCallStatus.error;
    errorMessage.value = isStreamReady.value
        ? 'Call ended unexpectedly. Please try again.'
        : 'Could not keep the video session alive. Please try again.';
    await endCall(popRoute: false);
  }

  void _setupClientListeners() {
    _connectionSub?.cancel();
    _videoSub?.cancel();
    _audioSub?.cancel();
    _sessionSub?.cancel();
    _errorSub?.cancel();
    _dataChannelSub?.cancel();
    _closedSub?.cancel();

    _videoSub = _client!.on(AnamEvent.videoStreamStarted).listen(
      (stream) => _handleStreamReady(stream is MediaStream ? stream : null),
      onError: _handleStreamError,
    );

    _audioSub = _client!.on(AnamEvent.audioStreamStarted).listen(
      (stream) => _handleStreamReady(stream is MediaStream ? stream : null),
      onError: _handleStreamError,
    );

    _sessionSub = _client!.on(AnamEvent.sessionReady).listen(
      (_) {
        if (_client != null && renderer != null) {
          AnamSpeakHelper.attachRemoteStream(_client!, renderer!);
        }
      },
      onError: _handleStreamError,
    );

    _connectionSub = _client!.on(AnamEvent.connectionEstablished).listen(
      (_) {
        if (_client != null && renderer != null) {
          AnamSpeakHelper.attachRemoteStream(_client!, renderer!);
        }
        if (!isStreamReady.value) {
          status.value = AnamCallStatus.connecting;
        }
      },
      onError: _handleStreamError,
    );

    _closedSub = _client!.on(AnamEvent.connectionClosed).listen(
      (_) {
        if (_isEnding || _isStarting) return;
        unawaited(endCall(popRoute: false));
      },
      onError: _handleStreamError,
    );

    _errorSub = _client!.on(AnamEvent.error).listen(
      (error) => _handleStreamError(error ?? 'Video connection failed'),
      onError: _handleStreamError,
    );

    _dataChannelSub =
        _client!.on<dynamic>(AnamEvent.dataChannelMessage).listen(
      (data) {
        if (data is! Map) return;
        final map = Map<String, dynamic>.from(data);

        if (map['messageType'] == 'speechText' && map['data'] is Map) {
          final speech = Map<String, dynamic>.from(map['data'] as Map);
          if (speech['role'] == 'user' && speech['end_of_speech'] == true) {
            final text = speech['content']?.toString().trim();
            if (text != null && text.isNotEmpty) {
              unawaited(_processUserSpeech(text));
            }
          }
          return;
        }

        final type = map['type']?.toString();
        if (type == 'user_message' || type == 'transcript') {
          final text = map['content']?.toString() ?? map['text']?.toString();
          if (text != null && text.trim().isNotEmpty) {
            unawaited(_processUserSpeech(text.trim()));
          }
        }
      },
      onError: _handleStreamError,
    );
  }

  void _listenForUserSpeech() {
    _historySub?.cancel();
    _historySub = _client!
        .on<List<Message>>(AnamEvent.messageHistoryUpdated)
        .listen(
      (messages) async {
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
      },
      onError: _handleStreamError,
    );
  }

  Future<void> _processUserSpeech(String userText) async {
    if (_dbSessionId == null || _isProcessingMessage || _isEnding) return;
    if (userText == _lastProcessedUserMessage) return;

    _lastProcessedUserMessage = userText;
    _isProcessingMessage = true;

    try {
      final bazzDbSessionId = _dbSessionId!;
      final reply = await _anamService.sendMessage(
        dbSessionId: bazzDbSessionId,
        trainerId: _args.trainerId,
        message: userText,
      );

      lastSuggestedTitle.value = reply.suggestedContentTitles.isNotEmpty
          ? reply.suggestedContentTitles.first
          : null;

      final assistantText = reply.assistantText.trim();
      if (assistantText.isNotEmpty &&
          _client != null &&
          isStreamReady.value) {
        _client?.interruptPersona();
        await AnamSpeakHelper.speak(
          client: _client!,
          text: assistantText,
        );
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
    _startGeneration++;
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
    await _closedSub?.cancel();
    _closedSub = null;
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
