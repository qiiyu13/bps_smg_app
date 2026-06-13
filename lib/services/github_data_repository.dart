import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GitHubDataRepository {
  static const String _baseUrl =
      'https://raw.githubusercontent.com/ZekeHyperByte/bps-semarang-data/main';
  static const String _versionUrl = '$_baseUrl/version.txt';
  static const Duration _timeout = Duration(seconds: 10);

  static Future<String?> fetchVersion() async {
    try {
      final response =
          await http.get(Uri.parse(_versionUrl)).timeout(_timeout);
      if (response.statusCode == 200) return response.body.trim();
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching version: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchJson(String category) async {
    try {
      final url = '$_baseUrl/${category}_data.json';
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      if (kDebugMode) {
        debugPrint('GitHub returned ${response.statusCode} for $category');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching $category: $e');
    }
    return null;
  }
}
