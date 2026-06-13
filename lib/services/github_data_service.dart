import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'github_data_repository.dart';

class GitHubDataService {
  static const String _versionKey = 'github_cached_version';
  static const String _cachePrefix = 'github_cache_';
  static const String _lastSyncKey = 'github_last_sync';

  static const List<String> categories = [
    'inflasi',
    'penduduk',
    'ipm',
    'kemiskinan',
    'ekonomi',
    'pendidikan',
    'tenaga_kerja',
    'ipg',
    'idg',
    'sdgs',
  ];

  static SharedPreferences? _prefs;
  static final Map<String, Map<String, dynamic>> _memoryCache = {};
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    await _syncFromGitHub();
    _initialized = true;
  }

  static Future<void> _syncFromGitHub() async {
    final remoteVersion = await GitHubDataRepository.fetchVersion();
    if (remoteVersion == null) {
      if (kDebugMode) debugPrint('GitHub unavailable, using cache');
      _loadAllFromLocalCache();
      return;
    }

    final cachedVersion = _prefs?.getString(_versionKey) ?? '';
    if (remoteVersion == cachedVersion && _hasAllLocalCache()) {
      if (kDebugMode) debugPrint('Version unchanged ($remoteVersion), using cache');
      _loadAllFromLocalCache();
      return;
    }

    if (kDebugMode) {
      debugPrint('New version detected: $cachedVersion -> $remoteVersion, fetching...');
    }
    int fetched = 0;
    for (final category in categories) {
      final data = await GitHubDataRepository.fetchJson(category);
      if (data != null) {
        _memoryCache[category] = data;
        await _saveToLocalCache(category, data);
        fetched++;
      }
    }

    if (fetched > 0) {
      await _prefs?.setString(_versionKey, remoteVersion);
      await _prefs?.setString(
          _lastSyncKey, DateTime.now().toIso8601String());
      if (kDebugMode) debugPrint('Fetched $fetched/${categories.length} categories');
    }

    _loadAllFromLocalCache();
  }

  static bool _hasAllLocalCache() {
    for (final category in categories) {
      if (_prefs?.getString('$_cachePrefix$category') == null) return false;
    }
    return true;
  }

  static void _loadAllFromLocalCache() {
    for (final category in categories) {
      if (_memoryCache.containsKey(category)) continue;
      final json = _prefs?.getString('$_cachePrefix$category');
      if (json != null) {
        try {
          _memoryCache[category] =
              jsonDecode(json) as Map<String, dynamic>;
        } catch (e) {
          if (kDebugMode) debugPrint('Error parsing cached $category: $e');
        }
      }
    }
  }

  static Future<void> _saveToLocalCache(
      String category, Map<String, dynamic> data) async {
    await _prefs?.setString('$_cachePrefix$category', jsonEncode(data));
  }

  static Map<String, dynamic>? getData(String category) {
    return _memoryCache[category];
  }

  static Future<void> forceRefresh() async {
    _memoryCache.clear();
    for (final category in categories) {
      await _prefs?.remove('$_cachePrefix$category');
    }
    await _prefs?.remove(_versionKey);
    _initialized = false;
    await init();
  }

  static DateTime? getLastSync() {
    final str = _prefs?.getString(_lastSyncKey);
    return str != null ? DateTime.tryParse(str) : null;
  }

  static String? getCachedVersion() => _prefs?.getString(_versionKey);
}
