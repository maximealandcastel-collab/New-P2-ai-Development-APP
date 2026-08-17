import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/reels/core/reel_video_slot.dart';
import 'package:video_player/video_player.dart';

/// Keeps current + next + previous videos ready in a 3-slot pool.
class ReelPlayerManager {
  ReelPlayerManager({this.onUpdated});

  VoidCallback? onUpdated;

  // 5-slot pool: current + 2 forward + 1 backward + 1 reserve for fast swipes
  static const _slotCount = 5;

  final Map<int, ReelVideoSlot> _slots = {};
  final List<ReelVideoSlot> _free = [];

  int? _activeIndex;
  int _operationId = 0;

  ReelVideoSlot? slotFor(int index) => _slots[index];

  bool isReady(int index) => _slots[index]?.isReady ?? false;

  String errorFor(int index) => _slots[index]?.error ?? '';

  bool isActive(int index) => _activeIndex == index;

  VideoPlayerController? controllerFor(int index) {
    final slot = _slots[index];
    final controller = slot?.controller;
    if (controller == null || !controller.value.isInitialized) return null;
    return controller;
  }

  Future<void> sync({
    required int index,
    required List<ContentModel> contents,
    bool playActive = true,
    bool prioritizeNextPreload = false,
  }) async {
    if (contents.isEmpty) return;

    final op = ++_operationId;
    _ensurePool();
    final center = index.clamp(0, contents.length - 1);
    _activeIndex = center;

    // Immediately silence ALL slots — pause + hard-mute — before the new
    // video loads. Without this, neighbor pre-loads can race and bleed audio.
    final silenceTasks = <Future<void>>[];
    for (final slot in _slots.values) {
      silenceTasks.add(slot.pause());
      silenceTasks.add(slot.setVolume(0));
    }
    await Future.wait(silenceTasks);

    final keep = {
      center,
      if (center > 0) center - 1,
      if (center + 1 < contents.length) center + 1,
      if (center + 2 < contents.length) center + 2, // 2-ahead look-ahead slot
    };

    for (final key in _slots.keys.where((i) => !keep.contains(i)).toList()) {
      if (op != _operationId) return;
      final slot = _slots.remove(key)!;
      await slot.cancel();
      slot.detach();
      _free.add(slot);
    }

    await _load(
      center,
      contents[center],
      autoPlay: playActive,
      operationId: op,
      isCenter: true,
    );
    if (op != _operationId) return;

    // Kick off neighbor preloads IMMEDIATELY — in parallel with center
    // initialization. Neighbors load from disk cache or network concurrently
    // so they are ready before the user swipes to them.
    unawaited(
      _preloadNeighbors(
        center: center,
        contents: contents,
        operationId: op,
        prioritizeNext: prioritizeNextPreload,
      ),
    );

    await _ensureCenterReady(
      center: center,
      content: contents[center],
      playActive: playActive,
      operationId: op,
    );
    if (op != _operationId) return;
    _notify();

    if (op != _operationId) return;

    for (final entry in _slots.entries) {
      if (entry.key != center) {
        await Future.wait([entry.value.pause(), entry.value.setVolume(0)]);
      }
    }
  }

  Future<void> _ensureCenterReady({
    required int center,
    required ContentModel content,
    required bool playActive,
    required int operationId,
  }) async {
    final slot = _slots[center];
    final needsReload = slot == null ||
        (!slot.isReady && slot.error.isEmpty && !slot.isLoading);

    if (needsReload) {
      if (slot != null) {
        await _evictSlot(center, slot);
      }
      if (operationId != _operationId) return;

      await _load(
        center,
        content,
        autoPlay: playActive,
        operationId: operationId,
        isCenter: true,
      );
      if (operationId != _operationId) return;
    }

    final activeSlot = _slots[center];
    if (activeSlot != null &&
        activeSlot.isReady &&
        playActive &&
        operationId == _operationId) {
      await activeSlot.play();
    }
  }

  Future<void> _preloadNeighbors({
    required int center,
    required List<ContentModel> contents,
    required int operationId,
    required bool prioritizeNext,
  }) async {
    if (operationId != _operationId) return;

    // NOTE: no center-ready guard here — neighbors load concurrently with
    // center so they are already buffered when the user swipes.

    Future<void> preloadAt(int idx) async {
      if (operationId != _operationId || idx < 0 || idx >= contents.length) {
        return;
      }
      await _load(idx, contents[idx], operationId: operationId, isCenter: false);
    }

    if (prioritizeNext) {
      // Swipe-forward hint: next → next+1 → prev
      await preloadAt(center + 1);
      await Future.wait([preloadAt(center + 2), preloadAt(center - 1)]);
    } else {
      // Default: next and prev concurrently, then next+1 look-ahead
      await Future.wait([preloadAt(center + 1), preloadAt(center - 1)]);
      if (operationId != _operationId) return;
      await preloadAt(center + 2);
    }
  }

  Future<void> pauseActive() async {
    final slot = _slots[_activeIndex];
    if (slot == null) return;
    await Future.wait([slot.pause(), slot.setVolume(0)]); // hard-mute so audio can never bleed
  }

  Future<void> playActive() => _slots[_activeIndex]?.play() ?? Future.value();

  Future<void> retryAt(int index, ContentModel content) async {
    final old = _slots.remove(index);
    if (old != null) {
      await old.cancel();
      old.detach();
      _free.add(old);
    }
    await _load(
      index,
      content,
      autoPlay: _activeIndex == index,
      isCenter: _activeIndex == index,
    );
    _notify();
  }

  Future<void> reset() async {
    _operationId++;
    for (final slot in _slots.values.toList()) {
      await slot.cancel();
      slot.detach();
      _free.add(slot);
    }
    _slots.clear();
    _activeIndex = null;
    _notify();
  }

  Future<void> releaseAll() async {
    _operationId++;
    for (final slot in [..._slots.values, ..._free]) {
      await slot.release();
    }
    _slots.clear();
    _free.clear();
    _activeIndex = null;
  }

  ReelVideoSlot _createSlot() {
    final slot = ReelVideoSlot();
    slot.onUpdated = _notify;
    return slot;
  }

  void _ensurePool() {
    while (_free.length + _slots.length < _slotCount) {
      _free.add(_createSlot());
    }
  }

  Future<void> _load(
    int index,
    ContentModel content, {
    bool autoPlay = false,
    int? operationId,
    bool isCenter = false,
  }) async {
    final op = operationId ?? _operationId;

    var slot = _slots[index];
    if (slot == null) {
      if (op != _operationId) return;
      slot = await _takeFreeSlot(protectIndex: _activeIndex);
      if (op != _operationId) {
        _free.add(slot);
        return;
      }
      _slots[index] = slot;
    }

    await slot.load(index, content, autoPlay: autoPlay);
    if (op != _operationId) {
      if (!isCenter || index != _activeIndex) {
        await _evictSlot(index, slot);
      }
      return;
    }
    _notify();
  }

  Future<void> _evictSlot(int index, ReelVideoSlot slot) async {
    if (_slots[index] != slot) return;
    _slots.remove(index);
    await slot.cancel();
    slot.detach();
    _free.add(slot);
  }

  Future<ReelVideoSlot> _takeFreeSlot({int? protectIndex}) async {
    if (_free.isNotEmpty) return _free.removeLast();

    final active = protectIndex ?? _activeIndex;
    if (_slots.isEmpty) return _createSlot();

    final candidates = active == null
        ? _slots.entries.toList()
        : _slots.entries.where((entry) => entry.key != active).toList();

    if (candidates.isEmpty) return _createSlot();

    final anchor = active ?? candidates.first.key;
    final farthest = candidates.reduce(
      (a, b) => (anchor - a.key).abs() > (anchor - b.key).abs() ? a : b,
    );
    _slots.remove(farthest.key);
    await farthest.value.cancel();
    farthest.value.detach();
    return farthest.value;
  }

  void _notify() => onUpdated?.call();
}
