import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/reels/core/reel_video_slot.dart';
import 'package:video_player/video_player.dart';

/// Manages a fixed pool of [ReelVideoSlot]s for smooth vertical reel scrolling.
///
/// Keeps the active reel plus one neighbor on each side initialized (3 slots).
/// Only one slot plays at a time.
class ReelPlayerManager extends ChangeNotifier {
  ReelPlayerManager({this.preloadRadius = 1});

  /// Number of videos to preload on each side of the active index.
  final int preloadRadius;

  /// current + previous + next.
  static const int _slotCount = 3;

  final Map<int, ReelVideoSlot> _slotsByIndex = {};
  final List<ReelVideoSlot> _freeSlots = [];
  bool _slotsReady = false;

  int? _activeIndex;

  int? get activeIndex => _activeIndex;

  VideoPlayerController? controllerFor(int index) {
    final slot = _slotsByIndex[index];
    if (slot == null || !slot.isInitialized) return null;
    return slot.controller;
  }

  ReelVideoSlot? slotFor(int index) => _slotsByIndex[index];

  bool isReady(int index) => _slotsByIndex[index]?.isInitialized ?? false;

  String errorFor(int index) => _slotsByIndex[index]?.error ?? '';

  bool isActive(int index) => _activeIndex == index;

  Future<void> sync({
    required int index,
    required List<ContentModel> contents,
    bool playActive = true,
  }) async {
    if (contents.isEmpty) return;

    await _ensureSlots();

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

    if (staleIndices.isNotEmpty) {
      _notifySlotsChanged();
    }

    await _ensureLoaded(
      index: center,
      content: contents[center],
      autoPlay: playActive,
    );

    final nextIndex = center + 1;
    if (nextIndex < contents.length && needed.contains(nextIndex)) {
      unawaited(
        _ensureLoaded(
          index: nextIndex,
          content: contents[nextIndex],
          autoPlay: false,
        ),
      );
    }

    final previousIndex = center - 1;
    if (previousIndex >= 0 && needed.contains(previousIndex)) {
      unawaited(
        _ensureLoaded(
          index: previousIndex,
          content: contents[previousIndex],
          autoPlay: false,
        ),
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
    await _slotsByIndex[index]?.seekToStart();
  }

  Future<void> retryAt(int index, ContentModel content) async {
    final slot = _slotsByIndex[index];
    if (slot != null) {
      await slot.stop();
      slot.detach();
      _slotsByIndex.remove(index);
      _freeSlots.add(slot);
      _notifySlotsChanged();
    }

    final isActive = _activeIndex == index;
    await _ensureLoaded(content: content, index: index, autoPlay: isActive);
  }

  Future<void> reset() async {
    if (!_slotsReady) return;

    final slots = _slotsByIndex.values.toList(growable: false);
    _slotsByIndex.clear();
    _activeIndex = null;

    for (final slot in slots) {
      await slot.stop();
      slot.detach();
      _freeSlots.add(slot);
    }

    _notifySlotsChanged();
  }

  Future<void> releaseAll() async {
    final slots = [
      ..._slotsByIndex.values,
      ..._freeSlots,
    ];
    _slotsByIndex.clear();
    _freeSlots.clear();
    _activeIndex = null;
    _slotsReady = false;

    for (final slot in slots) {
      await slot.release();
    }
  }

  @override
  void dispose() {
    unawaited(releaseAll());
    super.dispose();
  }

  Future<void> _ensureSlots() async {
    if (_slotsReady) return;
    _slotsReady = true;
    for (var i = 0; i < _slotCount; i++) {
      _freeSlots.add(ReelVideoSlot());
    }
  }

  Future<void> _ensureLoaded({
    required int index,
    required ContentModel content,
    required bool autoPlay,
  }) async {
    var slot = _slotsByIndex[index];
    final isNewAssignment = slot == null;

    if (slot == null) {
      slot = await _takeFreeSlot();
      _slotsByIndex[index] = slot;
      if (isNewAssignment) {
        _notifySlotsChanged();
      }
    }

    await slot.loadAt(index, content, autoPlay: autoPlay);
  }

  Future<ReelVideoSlot> _takeFreeSlot() async {
    if (_freeSlots.isNotEmpty) {
      return _freeSlots.removeLast();
    }

    final active = _activeIndex;
    if (active == null || _slotsByIndex.isEmpty) {
      return ReelVideoSlot();
    }

    final farthestEntry = _slotsByIndex.entries.reduce(
      (current, candidate) {
        final currentDistance = (active - current.key).abs();
        final candidateDistance = (active - candidate.key).abs();
        return candidateDistance > currentDistance ? candidate : current;
      },
    );

    final slot = farthestEntry.value;
    _slotsByIndex.remove(farthestEntry.key);
    await slot.stop();
    slot.detach();
    _notifySlotsChanged();
    return slot;
  }

  void _notifySlotsChanged() {
    if (hasListeners) notifyListeners();
  }
}
