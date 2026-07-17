import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/reels/core/reel_video_slot.dart';
import 'package:video_player/video_player.dart';

/// Keeps current + next + previous videos ready in a 3-slot pool.
class ReelPlayerManager {
  ReelPlayerManager({this.onUpdated});

  VoidCallback? onUpdated;

  static const _slotCount = 3;

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
  }) async {
    if (contents.isEmpty) return;

    final op = ++_operationId;
    _ensurePool();
    final center = index.clamp(0, contents.length - 1);
    _activeIndex = center;

    final keep = {center, if (center > 0) center - 1, if (center + 1 < contents.length) center + 1};

    for (final key in _slots.keys.where((i) => !keep.contains(i)).toList()) {
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
    );
    if (op != _operationId) return;
    _notify();

    if (center + 1 < contents.length) {
      unawaited(
        _load(center + 1, contents[center + 1], operationId: op),
      );
    }
    if (center > 0) {
      unawaited(_load(center - 1, contents[center - 1], operationId: op));
    }

    if (op != _operationId) return;

    for (final entry in _slots.entries) {
      if (entry.key != center) await entry.value.pause();
    }
  }

  Future<void> pauseActive() => _slots[_activeIndex]?.pause() ?? Future.value();

  Future<void> playActive() => _slots[_activeIndex]?.play() ?? Future.value();

  Future<void> retryAt(int index, ContentModel content) async {
    final old = _slots.remove(index);
    if (old != null) {
      await old.cancel();
      old.detach();
      _free.add(old);
    }
    await _load(index, content, autoPlay: _activeIndex == index);
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
  }) async {
    final op = operationId ?? _operationId;

    var slot = _slots[index];
    if (slot == null) {
      if (op != _operationId) return;
      slot = await _takeFreeSlot();
      if (op != _operationId) {
        _free.add(slot);
        return;
      }
      _slots[index] = slot;
    }

    await slot.load(index, content, autoPlay: autoPlay);
    if (op != _operationId) {
      await _evictSlot(index, slot);
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

  Future<ReelVideoSlot> _takeFreeSlot() async {
    if (_free.isNotEmpty) return _free.removeLast();

    final active = _activeIndex;
    if (active == null || _slots.isEmpty) return _createSlot();

    final farthest = _slots.entries.reduce(
      (a, b) => (active - a.key).abs() > (active - b.key).abs() ? a : b,
    );
    _slots.remove(farthest.key);
    await farthest.value.cancel();
    farthest.value.detach();
    return farthest.value;
  }

  void _notify() => onUpdated?.call();
}
