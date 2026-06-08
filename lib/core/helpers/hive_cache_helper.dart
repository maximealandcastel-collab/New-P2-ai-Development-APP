import 'package:hive_flutter/hive_flutter.dart';

/// A helper class for caching data using Hive.
///
/// Provides methods for initializing Hive, storing/retrieving data,
/// and managing cache boxes with optional expiration.
class HiveCacheHelper {
  static const String _defaultBoxName = 'default_cache';
  
  /// Map of initialized boxes
  static final Map<String, Box> _boxes = {};

  /// Initializes Hive with optional encryption
  ///
  /// Call this method in your app initialization (e.g., in main.dart)
  /// before using any other caching methods.
  ///
  /// [encryptionKey] - Optional 32-byte key for encrypting the hive boxes
  static Future<void> init({List<int>? encryptionKey}) async {
    await Hive.initFlutter();
    
    if (encryptionKey != null) {
      await Hive.openBox(_defaultBoxName, encryptionKey: encryptionKey);
    } else {
      await Hive.openBox(_defaultBoxName);
    }
    
    _boxes[_defaultBoxName] = Hive.box(_defaultBoxName);
  }

  /// Opens a named box for caching
  ///
  /// [boxName] - Name of the box to open
  /// [encryptionKey] - Optional encryption key for this specific box
  static Future<Box> _openBox(String boxName, {List<int>? encryptionKey}) async {
    if (!_boxes.containsKey(boxName)) {
      Box box;
      if (encryptionKey != null) {
        box = await Hive.openBox(boxName, encryptionKey: encryptionKey);
      } else {
        box = await Hive.openBox(boxName);
      }
      _boxes[boxName] = box;
    }
    return _boxes[boxName]!;
  }

  // ==================== DEFAULT BOX OPERATIONS ====================

  /// Saves data to the default cache box
  ///
  /// [key] - Unique identifier for the cached item
  /// [value] - Data to cache (must be Hive-compatible)
  /// [boxName] - Optional custom box name (uses default if not provided)
  static Future<void> save({
    required String key,
    required dynamic value,
    String? boxName,
  }) async {
    final box = boxName != null ? await _openBox(boxName) : _boxes[_defaultBoxName]!;
    await box.put(key, value);
  }

  /// Retrieves data from the default cache box
  ///
  /// [key] - Unique identifier for the cached item
  /// [defaultValue] - Value to return if key doesn't exist
  /// [boxName] - Optional custom box name
  static Future<T?> get<T>({
    required String key,
    T? defaultValue,
    String? boxName,
  }) async {
    final box = boxName != null ? await _openBox(boxName) : _boxes[_defaultBoxName]!;
    return box.get(key, defaultValue: defaultValue) as T?;
  }

  /// Deletes data from the default cache box
  ///
  /// [key] - Unique identifier for the cached item to delete
  /// [boxName] - Optional custom box name
  static Future<void> delete({
    required String key,
    String? boxName,
  }) async {
    final box = boxName != null 
        ? await _openBox(boxName) 
        : _boxes[_defaultBoxName]!;
    await box.delete(key);
  }

  /// Checks if a key exists in the default cache box
  ///
  /// [key] - Unique identifier to check
  /// [boxName] - Optional custom box name
  static Future<bool> containsKey({
    required String key,
    String? boxName,
  }) async {
    final box = boxName != null 
        ? await _openBox(boxName) 
        : _boxes[_defaultBoxName]!;
    return box.containsKey(key);
  }

  /// Clears all data from the default cache box
  ///
  /// [boxName] - Optional custom box name
  static Future<void> clear({String? boxName}) async {
    final box = boxName != null 
        ? await _openBox(boxName) 
        : _boxes[_defaultBoxName]!;
    await box.clear();
  }

  /// Saves data with expiration time (in seconds)
  ///
  /// Stores both the value and its expiration timestamp.
  ///
  /// [key] - Unique identifier for the cached item
  /// [value] - Data to cache
  /// [expireInSeconds] - Time until the cache expires
  /// [boxName] - Optional custom box name
  static Future<void> saveWithExpiration({
    required String key,
    required dynamic value,
    required int expireInSeconds,
    String? boxName,
  }) async {
    final expirationTime = DateTime.now().millisecondsSinceEpoch + (expireInSeconds * 1000);
    final box = boxName != null 
        ? await _openBox(boxName) 
        : _boxes[_defaultBoxName]!;
    
    await box.put(key, value);
    await box.put('${key}_expiration', expirationTime);
  }

  /// Retrieves data if it hasn't expired
  ///
  /// Returns null if the key doesn't exist or has expired.
  /// Automatically deletes expired entries.
  ///
  /// [key] - Unique identifier for the cached item
  /// [boxName] - Optional custom box name
  static Future<T?> getWithExpiration<T>({
    required String key,
    String? boxName,
  }) async {
    final box = boxName != null 
        ? await _openBox(boxName) 
        : _boxes[_defaultBoxName]!;
    
    final expirationKey = '${key}_expiration';
    
    // Check if expiration exists
    if (box.containsKey(expirationKey)) {
      final expirationTime = box.get(expirationKey) as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // If expired, delete both value and expiration
      if (now >= expirationTime) {
        await box.delete(key);
        await box.delete(expirationKey);
        return null;
      }
    }
    
    return box.get(key) as T?;
  }

  /// Gets remaining time until expiration (in seconds)
  ///
  /// Returns null if key doesn't exist or has no expiration set.
  /// Returns 0 if already expired.
  ///
  /// [key] - Unique identifier for the cached item
  /// [boxName] - Optional custom box name
  static Future<int?> getRemainingExpirationTime({
    required String key,
    String? boxName,
  }) async {
    final box = boxName != null 
        ? await _openBox(boxName) 
        : _boxes[_defaultBoxName]!;
    
    final expirationKey = '${key}_expiration';
    
    if (!box.containsKey(expirationKey)) {
      return null;
    }
    
    final expirationTime = box.get(expirationKey) as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = expirationTime - now;
    
    return remaining > 0 ? (remaining / 1000).ceil() : 0;
  }

  // ==================== UTILITY METHODS ====================

  /// Gets all keys in a box
  ///
  /// [boxName] - Optional custom box name
  static Future<List<String>> getAllKeys({String? boxName}) async {
    final box = boxName != null 
        ? await _openBox(boxName) 
        : _boxes[_defaultBoxName]!;
    return box.keys.cast<String>().toList();
  }

  /// Gets the number of items in a box
  ///
  /// [boxName] - Optional custom box name
  static Future<int> getLength({String? boxName}) async {
    final box = boxName != null 
        ? await _openBox(boxName) 
        : _boxes[_defaultBoxName]!;
    return box.length;
  }

  /// Closes a specific box
  ///
  /// [boxName] - Name of the box to close
  static Future<void> closeBox(String boxName) async {
    if (_boxes.containsKey(boxName)) {
      await _boxes[boxName]!.close();
      _boxes.remove(boxName);
    }
  }

  /// Closes all boxes and clears the cache
  static Future<void> dispose() async {
    for (final box in _boxes.values) {
      await box.close();
    }
    _boxes.clear();
    await Hive.close();
  }
}
