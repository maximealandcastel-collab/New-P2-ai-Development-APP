import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _boxName = 'appCache';
  Box? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  Box get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Cache service not initialized. Call init() first.');
    }
    return _box!;
  }

  Future<void> put(String key, dynamic value) async {
    await box.put(key, value);
    debugPrint('Saved to cache: ----------------------->>>  $key: $value');
  }

  // T? get<T>(String key, {T? defaultValue}) {
  //   try {
  //
  //     return box.get(key, defaultValue: defaultValue) as T?;
  //
  //   } catch (_) {
  //     return defaultValue;
  //   }
  // }

  T? get<T>(String key, {T? defaultValue}) {
    try {
      final value = box.get(key, defaultValue: defaultValue);
      if (value == null) return defaultValue;
      if (T == Map<String, dynamic>) {
        return _deepCastMap(value) as T?;
      }
      return value as T?;
    } catch (_) {
      return defaultValue;
    }
  }

  Map<String, dynamic> _deepCastMap(dynamic value) {
    if (value is Map) {
      return value.map((k, v) {
        final castedValue = v is Map ? _deepCastMap(v) : (v is List ? _deepCastList(v) : v);
        return MapEntry(k.toString(), castedValue);
      });
    }
    return {};
  }

  List<dynamic> _deepCastList(List value) {
    return value.map((e) => e is Map ? _deepCastMap(e) : e).toList();
  }



  bool containsKey(String key) {
    return box.containsKey(key);
  }

  Future<void> delete(String key) async {
    await box.delete(key);
    debugPrint('Deleted from cache: ----------------------->>>  $key');
  }

  Future<void> clear() async {
    await box.clear();
  }

  Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }
}
