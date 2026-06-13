import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'services/github_data_service.dart';

class HomeSnapshotData {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static void clearPrefsCache() {
    _prefs = null;
  }

  static Future<Map<String, dynamic>?> loadPendudukData() async {
    try {
      final githubData = GitHubDataService.getData('penduduk');
      if (githubData != null) {
        final section = githubData['penduduk'] as Map<String, dynamic>?;
        if (section != null) {
          final decoded = section.map((key, value) =>
              MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));

          final years = decoded.keys.toList()..sort();
          if (years.length >= 2) {
            final latestYear = years.last;
            final prevYear = years[years.length - 2];
            final latestPop = (decoded[latestYear]!['population'] as num).toDouble();
            final prevPop = (decoded[prevYear]!['population'] as num).toDouble();
            final change = (latestPop - prevPop) / prevPop * 100;

            final spots = years.map((y) {
              final pop = (decoded[y]!['population'] as num).toDouble();
              return FlSpot((y - years.first).toDouble(), pop / 1000000);
            }).toList();

            return {
              'valueInMillions': latestPop / 1000000,
              'change': change,
              'latestYear': latestYear,
              'spots': spots,
            };
          }
        }
      }

      final prefs = await _getPrefs();
      final savedData = prefs.getString('penduduk_data');

      Map<int, Map<String, dynamic>> decoded;
      if (savedData != null) {
        decoded = (json.decode(savedData) as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            int.parse(key),
            Map<String, dynamic>.from(value as Map),
          ),
        );
      } else {
        decoded = _defaultPendudukData;
      }

      final years = decoded.keys.toList()..sort();
      if (years.length < 2) return null;

      final latestYear = years.last;
      final prevYear = years[years.length - 2];
      final latestPop = (decoded[latestYear]!['population'] as num).toDouble();
      final prevPop = (decoded[prevYear]!['population'] as num).toDouble();
      final change = (latestPop - prevPop) / prevPop * 100;

      final spots = years.map((y) {
        final pop = (decoded[y]!['population'] as num).toDouble();
        return FlSpot((y - years.first).toDouble(), pop / 1000000);
      }).toList();

      return {
        'valueInMillions': latestPop / 1000000,
        'change': change,
        'latestYear': latestYear,
        'spots': spots,
      };
    } catch (e) {
      debugPrint('Error loading penduduk snapshot: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> loadIPMData() async {
    try {
      final githubData = GitHubDataService.getData('ipm');
      if (githubData != null) {
        final section = githubData['ipmData'] as Map<String, dynamic>?;
        if (section != null) {
          final decoded = section.map((key, value) =>
              MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));

          final years = decoded.keys.toList()..sort();
          if (years.length >= 2) {
            final latestYear = years.last;
            final prevYear = years[years.length - 2];
            final latestIPM = (decoded[latestYear]!['ipm'] as num).toDouble();
            final prevIPM = (decoded[prevYear]!['ipm'] as num).toDouble();
            final change = (latestIPM - prevIPM) / prevIPM * 100;

            final spots = years.map((y) {
              final ipm = (decoded[y]!['ipm'] as num).toDouble();
              return FlSpot((y - years.first).toDouble(), ipm);
            }).toList();

            return {
              'value': latestIPM,
              'change': change,
              'latestYear': latestYear,
              'spots': spots,
            };
          }
        }
      }

      final prefs = await _getPrefs();
      final savedData = prefs.getString('ipm_data');

      Map<int, Map<String, dynamic>> decoded;
      if (savedData != null) {
        decoded = (json.decode(savedData) as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            int.parse(key),
            Map<String, dynamic>.from(value as Map),
          ),
        );
      } else {
        decoded = _defaultIPMData;
      }

      final years = decoded.keys.toList()..sort();
      if (years.length < 2) return null;

      final latestYear = years.last;
      final prevYear = years[years.length - 2];
      final latestIPM = (decoded[latestYear]!['ipm'] as num).toDouble();
      final prevIPM = (decoded[prevYear]!['ipm'] as num).toDouble();
      final change = (latestIPM - prevIPM) / prevIPM * 100;

      final spots = years.map((y) {
        final ipm = (decoded[y]!['ipm'] as num).toDouble();
        return FlSpot((y - years.first).toDouble(), ipm);
      }).toList();

      return {
        'value': latestIPM,
        'change': change,
        'latestYear': latestYear,
        'spots': spots,
      };
    } catch (e) {
      debugPrint('Error loading IPM snapshot: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> loadKemiskinanData() async {
    try {
      final githubData = GitHubDataService.getData('kemiskinan');
      if (githubData != null) {
        final section = githubData['kemiskinanData'] as Map<String, dynamic>?;
        if (section != null) {
          final decoded = section.map((key, value) =>
              MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));

          final years = decoded.keys.toList()..sort();
          if (years.length >= 2) {
            final latestYear = years.last;
            final prevYear = years[years.length - 2];
            final latestPct =
                (decoded[latestYear]!['persentaseValue'] as num).toDouble();
            final prevPct = (decoded[prevYear]!['persentaseValue'] as num).toDouble();
            final change = latestPct - prevPct;

            final spots = years.map((y) {
              final pct = (decoded[y]!['persentaseValue'] as num).toDouble();
              return FlSpot((y - years.first).toDouble(), pct);
            }).toList();

            return {
              'value': latestPct,
              'change': change,
              'latestYear': latestYear,
              'spots': spots,
            };
          }
        }
      }

      final prefs = await _getPrefs();
      final savedData = prefs.getString('kemiskinan_data');

      Map<int, Map<String, dynamic>> decoded;
      if (savedData != null) {
        decoded = (json.decode(savedData) as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            int.parse(key),
            Map<String, dynamic>.from(value as Map),
          ),
        );
      } else {
        decoded = _defaultKemiskinanData;
      }

      final years = decoded.keys.toList()..sort();
      if (years.length < 2) return null;

      final latestYear = years.last;
      final prevYear = years[years.length - 2];
      final latestPct =
          (decoded[latestYear]!['persentaseValue'] as num).toDouble();
      final prevPct = (decoded[prevYear]!['persentaseValue'] as num).toDouble();
      final change = latestPct - prevPct;

      final spots = years.map((y) {
        final pct = (decoded[y]!['persentaseValue'] as num).toDouble();
        return FlSpot((y - years.first).toDouble(), pct);
      }).toList();

      return {
        'value': latestPct,
        'change': change,
        'latestYear': latestYear,
        'spots': spots,
      };
    } catch (e) {
      debugPrint('Error loading kemiskinan snapshot: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> loadInflasiData() async {
    try {
      final githubData = GitHubDataService.getData('inflasi');
      if (githubData != null) {
        final section = githubData['yearlyInflation'] as Map<String, dynamic>?;
        if (section != null) {
          final data = section.map(
              (key, value) => MapEntry(int.parse(key), (value as num).toDouble()));

          final years = data.keys.toList()..sort();
          if (years.length >= 2) {
            final latestYear = years.last;
            final prevYear = years[years.length - 2];
            final latestVal = data[latestYear]!;
            final prevVal = data[prevYear]!;
            final change = latestVal - prevVal;

            final spots = years.map((y) {
              return FlSpot((y - years.first).toDouble(), data[y]!);
            }).toList();

            final now = DateTime.now();
            const monthNames = [
              'Januari',
              'Februari',
              'Maret',
              'April',
              'Mei',
              'Juni',
              'Juli',
              'Agustus',
              'September',
              'Oktober',
              'November',
              'Desember'
            ];
            final dateLabel = '${monthNames[now.month - 1]} ${now.year}';

            return {
              'value': latestVal,
              'change': change,
              'latestYear': latestYear,
              'dateLabel': dateLabel,
              'spots': spots,
            };
          }
        }
      }

      final prefs = await _getPrefs();
      final savedData = prefs.getString('inflasi_yearly_data');

      Map<int, double> data;
      if (savedData != null) {
        data = {};
        final entries = savedData.split(';');
        for (final entry in entries) {
          final parts = entry.split(':');
          if (parts.length == 2) {
            data[int.parse(parts[0])] = double.parse(parts[1]);
          }
        }
      } else {
        data = _defaultInflasiData;
      }

      final years = data.keys.toList()..sort();
      if (years.length < 2) return null;

      final latestYear = years.last;
      final prevYear = years[years.length - 2];
      final latestVal = data[latestYear]!;
      final prevVal = data[prevYear]!;
      final change = latestVal - prevVal;

      final spots = years.map((y) {
        return FlSpot((y - years.first).toDouble(), data[y]!);
      }).toList();

      final now = DateTime.now();
      const monthNames = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      final dateLabel = '${monthNames[now.month - 1]} ${now.year}';

      return {
        'value': latestVal,
        'change': change,
        'latestYear': latestYear,
        'dateLabel': dateLabel,
        'spots': spots,
      };
    } catch (e) {
      debugPrint('Error loading inflasi snapshot: $e');
      return null;
    }
  }

  static double _parseGrowth(String s) =>
      double.tryParse(
          s.replaceAll('%', '').replaceAll(',', '.').trim()) ??
          0.0;

  static Future<Map<String, dynamic>?> loadEkonomiData() async {
    try {
      final githubData = GitHubDataService.getData('ekonomi');
      if (githubData != null) {
        final ekonomiList = githubData['ekonomiData'] as List<dynamic>?;
        if (ekonomiList != null && ekonomiList.length >= 2) {
          final latest = ekonomiList[0] as Map<String, dynamic>;
          final prev = ekonomiList[1] as Map<String, dynamic>;
          final latestVal = _parseGrowth(latest['pertumbuhanEkonomi']?.toString() ?? '0');
          final prevVal = _parseGrowth(prev['pertumbuhanEkonomi']?.toString() ?? '0');
          final change = latestVal - prevVal;
          final latestYear = int.tryParse(latest['tahun']?.toString() ?? '') ?? 0;

          final semarangData = latest['semarangData'] as List<dynamic>?;
          List<FlSpot> spots = [];
          if (semarangData != null) {
            final sorted = semarangData
                .map((e) => e as Map<String, dynamic>)
                .toList()
              ..sort((a, b) =>
                  (a['year'] as int).compareTo(b['year'] as int));
            final firstYear = sorted.first['year'] as int;
            spots = sorted
                .map((e) => FlSpot(
                      ((e['year'] as int) - firstYear).toDouble(),
                      (e['value'] as num).toDouble(),
                    ))
                .toList();
          }
          final prevYear = int.tryParse(prev['tahun']?.toString() ?? '') ?? 0;
          return {
            'value': latestVal,
            'change': change,
            'latestYear': latestYear,
            'prevVal': prevVal,
            'prevYear': prevYear,
            'spots': spots.isEmpty ? _defaultEkonomiSpots : spots,
          };
        }
      }
      return {
        'value': 6.49,
        'change': 6.49 - 5.68,
        'latestYear': 2025,
        'prevVal': 5.68,
        'prevYear': 2024,
        'spots': _defaultEkonomiSpots,
      };
    } catch (e) {
      debugPrint('Error loading ekonomi snapshot: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> loadTPTData() async {
    try {
      final githubData = GitHubDataService.getData('tenaga_kerja');
      if (githubData != null) {
        final section = githubData['pengangguranData'] as Map<String, dynamic>?;
        if (section != null) {
          final decoded = section.map((key, value) =>
              MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));
          final years = decoded.keys.toList()..sort();
          if (years.length >= 2) {
            final latestYear = years.last;
            final prevYear = years[years.length - 2];
            final latestTPT = (decoded[latestYear]!['tptSemarang'] as num).toDouble();
            final prevTPT = (decoded[prevYear]!['tptSemarang'] as num).toDouble();
            final change = latestTPT - prevTPT;
            final spots = years.map((y) {
              final tpt = (decoded[y]!['tptSemarang'] as num).toDouble();
              return FlSpot((y - years.first).toDouble(), tpt);
            }).toList();
            return {'value': latestTPT, 'change': change, 'latestYear': latestYear, 'spots': spots};
          }
        }
      }
      return {'value': 5.65, 'change': 5.65 - 5.82, 'latestYear': 2025, 'spots': _defaultTPTSpots};
    } catch (e) {
      debugPrint('Error loading TPT snapshot: $e');
      return null;
    }
  }

  static final List<FlSpot> _defaultEkonomiSpots = [
    const FlSpot(0, -1.85), const FlSpot(1, 5.16), const FlSpot(2, 5.73),
    const FlSpot(3, 5.77), const FlSpot(4, 5.68), const FlSpot(5, 6.49),
  ];

  static final List<FlSpot> _defaultTPTSpots = [
    const FlSpot(0, 9.57), const FlSpot(1, 9.54), const FlSpot(2, 7.60),
    const FlSpot(3, 5.99), const FlSpot(4, 5.82), const FlSpot(5, 5.65),
  ];

  // Default data matching what individual screens use
  static const Map<int, Map<String, dynamic>> _defaultPendudukData = {
    2020: {
      'population': 1653524,
      'malePopulation': 818441,
      'femalePopulation': 835083,
      'area': 373.7,
      'density': 4425,
      'districts': 16,
      'villages': 177,
      'growthRate': 0.0
    },
    2021: {
      'population': 1656564,
      'malePopulation': 819785,
      'femalePopulation': 836779,
      'area': 374.0,
      'density': 4433,
      'districts': 16,
      'villages': 177,
      'growthRate': 0.18
    },
    2022: {
      'population': 1659975,
      'malePopulation': 821305,
      'femalePopulation': 838670,
      'area': 374.0,
      'density': 4442,
      'districts': 16,
      'villages': 177,
      'growthRate': 0.21
    },
    2023: {
      'population': 1694743,
      'malePopulation': 838437,
      'femalePopulation': 856306,
      'area': 374.0,
      'density': 4535,
      'districts': 16,
      'villages': 177,
      'growthRate': 2.09
    },
    2024: {
      'population': 1708833,
      'malePopulation': 845177,
      'femalePopulation': 863656,
      'area': 374.0,
      'density': 4573,
      'districts': 16,
      'villages': 177,
      'growthRate': 0.83
    },
    2025: {
      'population': 1722421,
      'malePopulation': 851637,
      'femalePopulation': 870784,
      'area': 373.7,
      'density': 4609,
      'districts': 16,
      'villages': 177,
      'growthRate': 0.80
    },
  };

  static const Map<int, Map<String, dynamic>> _defaultIPMData = {
    2020: {
      'uhh': 77.34,
      'rls': 10.53,
      'hls': 15.52,
      'pengeluaran': 15243.00,
      'ipm': 83.05
    },
    2021: {
      'uhh': 77.51,
      'rls': 10.78,
      'hls': 15.53,
      'pengeluaran': 15425.00,
      'ipm': 83.55
    },
    2022: {
      'uhh': 77.69,
      'rls': 10.80,
      'hls': 15.54,
      'pengeluaran': 16047.00,
      'ipm': 84.08
    },
    2023: {
      'uhh': 77.90,
      'rls': 10.81,
      'hls': 15.55,
      'pengeluaran': 16420.00,
      'ipm': 84.43
    },
    2024: {
      'uhh': 78.23,
      'rls': 11.05,
      'hls': 15.57,
      'pengeluaran': 16990.00,
      'ipm': 85.24
    },
    2025: {
      'uhh': 78.72,
      'rls': 11.11,
      'hls': 15.58,
      'pengeluaran': 17402.00,
      'ipm': 85.80
    },
  };

  static const Map<int, Map<String, dynamic>> _defaultKemiskinanData = {
    2020: {
      'pendudukMiskin': '79,58 Ribu',
      'pendudukMiskinValue': 79.58,
      'persentase': '4,34%',
      'persentaseValue': 4.34,
      'garisMiskin': 'Rp 522.691',
      'indeksKedalaman': '0,68',
      'indeksKeparahan': '0,16'
    },
    2021: {
      'pendudukMiskin': '84,45 Ribu',
      'pendudukMiskinValue': 84.45,
      'persentase': '4,56%',
      'persentaseValue': 4.56,
      'garisMiskin': 'Rp 543.929',
      'indeksKedalaman': '0,67',
      'indeksKeparahan': '0,14'
    },
    2022: {
      'pendudukMiskin': '79,87 Ribu',
      'pendudukMiskinValue': 79.87,
      'persentase': '4,25%',
      'persentaseValue': 4.25,
      'garisMiskin': 'Rp 589.598',
      'indeksKedalaman': '0,56',
      'indeksKeparahan': '0,11'
    },
    2023: {
      'pendudukMiskin': '80,53 Ribu',
      'pendudukMiskinValue': 80.53,
      'persentase': '4,23%',
      'persentaseValue': 4.23,
      'garisMiskin': 'Rp 642.456',
      'indeksKedalaman': '0,54',
      'indeksKeparahan': '0,10'
    },
    2024: {
      'pendudukMiskin': '77,79 Ribu',
      'pendudukMiskinValue': 77.79,
      'persentase': '4,03%',
      'persentaseValue': 4.03,
      'garisMiskin': 'Rp 671.936',
      'indeksKedalaman': '0,59',
      'indeksKeparahan': '0,12'
    },
    2025: {
      'pendudukMiskin': '74,36 Ribu',
      'pendudukMiskinValue': 74.36,
      'persentase': '3,80%',
      'persentaseValue': 3.80,
      'garisMiskin': 'Rp 709.785',
      'indeksKedalaman': '0,41',
      'indeksKeparahan': '0,05'
    },
  };

  static const Map<int, double> _defaultInflasiData = {
    2022: 4.99,
    2023: 2.84,
    2024: 1.69,
    2025: 2.84,
    2026: 3.57,
  };
}
