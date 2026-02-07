import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Local storage service for caching and preferences
class StorageService {
  late SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  StorageService({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // -- Regular Storage (SharedPreferences) --

  /// Get string value
  String? getString(String key) => _prefs.getString(key);

  /// Set string value
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  /// Get int value
  int? getInt(String key) => _prefs.getInt(key);

  /// Set int value
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  /// Get bool value
  bool? getBool(String key) => _prefs.getBool(key);

  /// Set bool value
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  /// Get JSON object
  Map<String, dynamic>? getJson(String key) {
    final str = _prefs.getString(key);
    if (str == null) return null;
    return json.decode(str) as Map<String, dynamic>;
  }

  /// Set JSON object
  Future<bool> setJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, json.encode(value));

  /// Remove key
  Future<bool> remove(String key) => _prefs.remove(key);

  /// Clear all non-secure storage
  Future<bool> clear() => _prefs.clear();

  // -- Secure Storage (FlutterSecureStorage) --

  /// Get secure string
  Future<String?> getSecure(String key) => _secureStorage.read(key: key);

  /// Set secure string
  Future<void> setSecure(String key, String value) =>
      _secureStorage.write(key: key, value: value);

  /// Delete secure key
  Future<void> deleteSecure(String key) => _secureStorage.delete(key: key);

  /// Clear all secure storage
  Future<void> clearSecure() => _secureStorage.deleteAll();
}
