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

    await _load(center, contents[center], autoPlay: playActive);
    _notify();

    if (center + 1 < contents.length) {
      unawaited(_load(center + 1, contents[center + 1]));
    }
    if (center > 0) {
      unawaited(_load(center - 1, contents[center - 1]));
    }

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

  void _ensurePool() {
    while (_free.length + _slots.length < _slotCount) {
      _free.add(ReelVideoSlot());
    }
  }

  Future<void> _load(
    int index,
    ContentModel content, {
    bool autoPlay = false,
  }) async {
    var slot = _slots[index];
    if (slot == null) {
      slot = await _takeFreeSlot();
      _slots[index] = slot;
    }

    await slot.load(index, content, autoPlay: autoPlay);
    _notify();
  }

  Future<ReelVideoSlot> _takeFreeSlot() async {
    if (_free.isNotEmpty) return _free.removeLast();

    final active = _activeIndex;
    if (active == null || _slots.isEmpty) return ReelVideoSlot();

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
