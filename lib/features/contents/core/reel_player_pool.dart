import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pler_to_pler_app/features/contents/core/content_media_resolver.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';

class ReelPlayerSlot {
  ReelPlayerSlot._(this.player, this.videoController);

  factory ReelPlayerSlot.create() {
    final player = Player(
      configuration: const PlayerConfiguration(libass: true),
    );
    final videoController = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
      ),
    );
    return ReelPlayerSlot._(player, videoController);
  }

  final Player player;
  final VideoController videoController;

  int? index;
  bool isReady = false;
  bool isOpening = false;
  String error = '';
  Future<void>? _openFuture;

  Future<void> loadAt(
    int targetIndex,
    ContentModel content, {
    required bool play,
  }) async {
    if (index == targetIndex && isReady && error.isEmpty) {
      if (play) {
        await player.play();
      } else {
        await player.pause();
      }
      return;
    }

    if (isOpening && index == targetIndex) {
      await _openFuture;
      if (play && isReady) {
        await player.play();
      }
      return;
    }

    final media = ContentMediaResolver.mediaFromContent(content);
    index = targetIndex;
    isReady = false;
    error = '';
    isOpening = true;

    if (media == null) {
      error = 'No video available for this content.';
      isOpening = false;
      return;
    }

    _openFuture = _openMedia(media, play: play);
    await _openFuture;
  }

  Future<void> _openMedia(Media media, {required bool play}) async {
    try {
      await player.setPlaylistMode(PlaylistMode.single);
      await player.open(media, play: play);
      isReady = true;
    } catch (error) {
      this.error = 'Unable to play this video.';
      isReady = false;
      if (kDebugMode) {
        debugPrint('ReelPlayerSlot open error: $error');
      }
    } finally {
      isOpening = false;
    }
  }

  Future<void> pause() async {
    try {
      await player.pause();
    } catch (_) {}
  }

  Future<void> play() async {
    if (!isReady) return;
    try {
      await player.play();
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await player.pause();
      await player.stop();
    } catch (_) {}
  }

  void detach() {
    index = null;
    isReady = false;
    isOpening = false;
    error = '';
    _openFuture = null;
  }

  Future<void> dispose() async {
    try {
      await player.pause();
      await player.stop();
      await player.dispose();
    } catch (_) {}
  }
}

class ReelPlayerPool {
  ReelPlayerPool({
    this.preloadRadius = 1,
    this.onStateChanged,
    this.onReelCompleted,
  });

  final int preloadRadius;
  final VoidCallback? onStateChanged;
  final VoidCallback? onReelCompleted;

  final Map<int, ReelPlayerSlot> _slotsByIndex = {};
  final List<ReelPlayerSlot> _freeSlots = [
    ReelPlayerSlot.create(),
    ReelPlayerSlot.create(),
    ReelPlayerSlot.create(),
  ];

  int? _activeIndex;
  StreamSubscription<bool>? _completedSub;

  VideoController? videoControllerFor(int index) {
    final slot = _slotsByIndex[index];
    if (slot == null || !slot.isReady) return null;
    return slot.videoController;
  }

  bool isReady(int index) => _slotsByIndex[index]?.isReady ?? false;

  bool isOpening(int index) => _slotsByIndex[index]?.isOpening ?? false;

  String errorFor(int index) => _slotsByIndex[index]?.error ?? '';

  int? get activeIndex => _activeIndex;

  Future<void> sync({
    required int index,
    required List<ContentModel> contents,
  }) async {
    if (contents.isEmpty) return;

    final center = index.clamp(0, contents.length - 1);
    _activeIndex = center;

    final needed = <int>{center};
    for (var offset = 1; offset <= preloadRadius; offset++) {
      final previous = center - offset;
      final next = center + offset;
      if (previous >= 0) needed.add(previous);
      if (next < contents.length) needed.add(next);
    }

    final staleIndices =
        _slotsByIndex.keys.where((key) => !needed.contains(key)).toList();
    for (final staleIndex in staleIndices) {
      final slot = _slotsByIndex.remove(staleIndex)!;
      await slot.stop();
      slot.detach();
      _freeSlots.add(slot);
    }

    await _ensureLoaded(center, contents[center], play: true);
    _attachActiveListeners(_slotsByIndex[center]);

    for (final preloadIndex in needed) {
      if (preloadIndex == center) continue;
      unawaited(
        _ensureLoaded(preloadIndex, contents[preloadIndex], play: false),
      );
    }

    for (final entry in _slotsByIndex.entries) {
      if (entry.key != center) {
        await entry.value.pause();
      }
    }
  }

  Future<void> pauseActive() async {
    final index = _activeIndex;
    if (index == null) return;
    await _slotsByIndex[index]?.pause();
  }

  Future<void> playActive() async {
    final index = _activeIndex;
    if (index == null) return;
    await _slotsByIndex[index]?.play();
  }

  Future<void> replayActive() async {
    final index = _activeIndex;
    if (index == null) return;
    final slot = _slotsByIndex[index];
    if (slot == null || !slot.isReady) return;

    try {
      await slot.player.seek(Duration.zero);
      await slot.player.play();
    } catch (_) {}
  }

  Future<void> reset() async {
    _detachActiveListeners();

    final slots = _slotsByIndex.values.toList(growable: false);
    _slotsByIndex.clear();
    _activeIndex = null;

    for (final slot in slots) {
      await slot.stop();
      slot.detach();
      _freeSlots.add(slot);
    }
  }

  Future<void> dispose() async {
    _detachActiveListeners();

    final slots = [
      ..._slotsByIndex.values,
      ..._freeSlots,
    ];
    _slotsByIndex.clear();
    _freeSlots.clear();
    _activeIndex = null;

    for (final slot in slots) {
      await slot.dispose();
    }
  }

  Future<void> _ensureLoaded(
    int index,
    ContentModel content, {
    required bool play,
  }) async {
    var slot = _slotsByIndex[index];
    if (slot == null) {
      slot = _takeFreeSlot();
      _slotsByIndex[index] = slot;
    }

    await slot.loadAt(index, content, play: play);
    _notifyStateChanged();
  }

  void _notifyStateChanged() => onStateChanged?.call();

  void _attachActiveListeners(ReelPlayerSlot? slot) {
    _detachActiveListeners();
    if (slot == null || !slot.isReady) return;

    _completedSub = slot.player.stream.completed.listen((completed) {
      if (completed) onReelCompleted?.call();
    });
  }

  void _detachActiveListeners() {
    unawaited(_completedSub?.cancel());
    _completedSub = null;
  }

  ReelPlayerSlot _takeFreeSlot() {
    if (_freeSlots.isNotEmpty) {
      return _freeSlots.removeLast();
    }

    final farthestEntry = _slotsByIndex.entries.reduce(
      (current, candidate) {
        final currentDistance = (_activeIndex! - current.key).abs();
        final candidateDistance = (_activeIndex! - candidate.key).abs();
        return candidateDistance > currentDistance ? candidate : current;
      },
    );

    final slot = farthestEntry.value;
    _slotsByIndex.remove(farthestEntry.key);
    unawaited(slot.stop());
    slot.detach();
    return slot;
  }
}
