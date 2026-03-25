import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for fetching SDGs data from GitHub
/// Falls back to cached data if offline or GitHub is unavailable
class SDGsGitHubRepository {
  // GitHub raw content URL - CHANGE THIS TO YOUR REPO
  static const String _githubBaseUrl =
      'https://raw.githubusercontent.com/ZekeHyperByte/bps-semarang-data/main';
  static const String _dataUrl = '$_githubBaseUrl/sdgs_data.json';
  static const String _versionUrl = '$_githubBaseUrl/version.txt';

  // Local storage keys
  static const String _cachedDataKey = 'sdgs_cached_data_v1';
  static const String _cachedVersionKey = 'sdgs_cached_version';
  static const String _lastUpdatedKey = 'sdgs_last_updated';

  // Timeout for network requests
  static const Duration _timeout = Duration(seconds: 10);

  /// Check if new data is available on GitHub
  static Future<bool> hasUpdate() async {
    try {
      final response = await http.get(Uri.parse(_versionUrl)).timeout(_timeout);

      if (response.statusCode == 200) {
        final remoteVersion = response.body.trim();
        final prefs = await SharedPreferences.getInstance();
        final cachedVersion = prefs.getString(_cachedVersionKey) ?? '0.0.0';

        return remoteVersion != cachedVersion;
      }
    } catch (e) {
      if (kDebugMode) print('Error checking for updates: $e');
    }
    return false;
  }

  /// Fetch latest data from GitHub
  /// Returns null if fetch fails (use getCachedData() for fallback)
  static Future<Map<String, dynamic>?> fetchLatestData() async {
    try {
      if (kDebugMode) print('Fetching SDGs data from GitHub...');

      final response = await http.get(Uri.parse(_dataUrl)).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Cache the data locally
        await _cacheData(data);

        if (kDebugMode) print('SDGs data fetched and cached successfully');
        return data;
      } else {
        if (kDebugMode) print('GitHub returned status ${response.statusCode}');
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching data from GitHub: $e');
      return null;
    }
  }

  /// Get cached data (works offline)
  static Future<Map<String, dynamic>?> getCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cachedDataKey);

      if (cachedJson != null) {
        return jsonDecode(cachedJson) as Map<String, dynamic>;
      }
    } catch (e) {
      if (kDebugMode) print('Error reading cached data: $e');
    }
    return null;
  }

  /// Cache data locally
  static Future<void> _cacheData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachedDataKey, jsonEncode(data));
      await prefs.setString(
          _cachedVersionKey, data['version']?.toString() ?? '1.0.0');
      await prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());
    } catch (e) {
      if (kDebugMode) print('Error caching data: $e');
    }
  }

  /// Get the last time data was updated
  static Future<DateTime?> getLastUpdated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdated = prefs.getString(_lastUpdatedKey);
      if (lastUpdated != null) {
        return DateTime.parse(lastUpdated);
      }
    } catch (e) {
      if (kDebugMode) print('Error reading last updated: $e');
    }
    return null;
  }

  /// Clear cached data (for debugging)
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedDataKey);
      await prefs.remove(_cachedVersionKey);
      await prefs.remove(_lastUpdatedKey);
      if (kDebugMode) print('SDGs cache cleared');
    } catch (e) {
      if (kDebugMode) print('Error clearing cache: $e');
    }
  }

  /// Force refresh - always fetch from GitHub
  static Future<Map<String, dynamic>?> forceRefresh() async {
    await clearCache();
    return await fetchLatestData();
  }
}
