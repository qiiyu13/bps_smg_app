import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/pdrb_ranking.dart';

class PDRBRankingService {
  static List<PDRBRanking>? _cachedRankings;

  static Future<List<PDRBRanking>> loadRankings() async {
    if (_cachedRankings != null) {
      return _cachedRankings!;
    }

    try {
      // Load CSV from assets
      final String csvData = await rootBundle.loadString(
        'assets/data/ranking_pdrb_jateng.csv',
      );

      // Parse CSV
      final List<List<dynamic>> rows =
          const CsvToListConverter().convert(csvData);

      // Skip header row and convert to objects
      final List<PDRBRanking> rankings = [];
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length >= 4 && row[0].toString().isNotEmpty) {
          try {
            final ranking = PDRBRanking.fromCsv(row);
            rankings.add(ranking);
          } catch (e) {
            // Skip invalid rows
          }
        }
      }

      // Fallback to hardcoded data if CSV parsing failed
      if (rankings.isEmpty) {
        _cachedRankings = _getFallbackData();
      } else {
        _cachedRankings = rankings;
      }
      return _cachedRankings!;
    } catch (e) {
      _cachedRankings = _getFallbackData();
      return _cachedRankings!;
    }
  }

  static List<PDRBRanking> _getFallbackData() {
    return [
      PDRBRanking(
          originalNo: 33, nama: 'Kota Semarang', pdrb: 140199.52, rank: 1),
      PDRBRanking(
          originalNo: 1, nama: 'Kabupaten Cilacap', pdrb: 100327.30, rank: 2),
      PDRBRanking(
          originalNo: 19, nama: 'Kabupaten Kudus', pdrb: 73241.78, rank: 3),
      PDRBRanking(
          originalNo: 2, nama: 'Kabupaten Banyumas', pdrb: 39779.32, rank: 4),
      PDRBRanking(
          originalNo: 22, nama: 'Kabupaten Semarang', pdrb: 35638.96, rank: 5),
      PDRBRanking(
          originalNo: 31, nama: 'Kota Surakarta', pdrb: 35441.11, rank: 6),
      PDRBRanking(
          originalNo: 29, nama: 'Kabupaten Brebes', pdrb: 32847.86, rank: 7),
      PDRBRanking(
          originalNo: 24, nama: 'Kabupaten Kendal', pdrb: 30916.39, rank: 8),
      PDRBRanking(
          originalNo: 18, nama: 'Kabupaten Pati', pdrb: 30885.38, rank: 9),
      PDRBRanking(
          originalNo: 10, nama: 'Kabupaten Klaten', pdrb: 27805.99, rank: 10),
    ];
  }

  static Future<List<PDRBRanking>> getTopN(int n) async {
    final rankings = await loadRankings();
    return rankings.take(n).toList();
  }

  static Future<PDRBRanking?> getSemarangRanking() async {
    final rankings = await loadRankings();
    try {
      return rankings.firstWhere((r) => r.isKotaSemarang);
    } catch (e) {
      return null;
    }
  }

  static void clearCache() {
    _cachedRankings = null;
  }
}
