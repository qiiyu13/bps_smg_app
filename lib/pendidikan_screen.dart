import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'services/github_data_service.dart';
import 'responsive_sizing.dart';
import 'number_format_utils.dart';
import 'kesimpulan_widget.dart';
import 'app_theme.dart';

class PendidikanScreen extends StatefulWidget {
  const PendidikanScreen({super.key});

  @override
  _PendidikanScreenState createState() => _PendidikanScreenState();
}

class _PendidikanScreenState extends State<PendidikanScreen>
    with AutomaticKeepAliveClientMixin {
  int selectedYear = 2025;
  bool isLoading = true;
  final Set<int> _shownNotices = {};

  final List<int> years = [2025, 2024, 2023, 2022, 2021];

  // Data pendidikan per tahun (Data real Kota Semarang)
  Map<int, Map<String, dynamic>> educationData = {};

  Map<String, dynamic> get currentData => educationData[selectedYear]!;

  @override
  bool get wantKeepAlive => true;

  void _show2024DataNotice() {
    if (_shownNotices.contains(2024)) return;

    _shownNotices.add(2024);

    final sizing = ResponsiveSizing(context);
    final isSmallScreen = sizing.isVerySmall || sizing.isSmall;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen
                  ? MediaQuery.of(dialogContext).size.width - 32
                  : 450,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  decoration: BoxDecoration(
                    color: bpsRed,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: isSmallScreen ? 24 : 28,
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 12),
                      Expanded(
                        child: Text(
                          'Informasi Penting',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(dialogContext),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: isSmallScreen ? 20 : 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        decoration: BoxDecoration(
                          color: bpsRed.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: bpsRed.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: bpsRed,
                              size: isSmallScreen ? 18 : 20,
                            ),
                            SizedBox(width: isSmallScreen ? 8 : 10),
                            Expanded(
                              child: Text(
                                'Catatan Data Tahun 2024',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w700,
                                  color: bpsTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      Text(
                        'Data tahun 2024 menggunakan data dari tahun 2023 untuk jenjang pendidikan RA, MI, MTs, dan MA karena keterbatasan ketersediaan data semester ganjil 2024/2025.',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          color: bpsTextSecondary,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 10),
                      Text(
                        'Data yang ditampilkan adalah estimasi berdasarkan data tahun ajaran 2023/2024.',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          color: bpsTextSecondary,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bpsRed,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Saya Mengerti',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int getTotalMurid(int year) {
    final jenjangData = educationData[year]!['jenjangPendidikan'] as List;
    int total = 0;
    for (var item in jenjangData) {
      total += (item['murid'] as int);
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final githubData = GitHubDataService.getData('pendidikan');
      final prefs = await SharedPreferences.getInstance();

      final pendidikanSection = githubData?['pendidikanData'] as Map<String, dynamic>?;
      if (pendidikanSection != null) {
        educationData = pendidikanSection.map((key, value) {
          final yearData = Map<String, dynamic>.from(value as Map);
          final converted = _convertPendidikanYearData(yearData);
          return MapEntry(int.parse(key), converted);
        });
        await prefs.setString('pendidikan_data', json.encode(pendidikanSection));
      } else {
        final savedData = prefs.getString('pendidikan_data');
        if (savedData != null) {
          final decoded = json.decode(savedData) as Map<String, dynamic>;
          educationData = decoded.map(
            (key, value) => MapEntry(
              int.parse(key),
              Map<String, dynamic>.from(value as Map),
            ),
          );
        } else {
          educationData = _getDefaultData();
        }
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() {
          educationData = _getDefaultData();
          isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _convertPendidikanYearData(Map<String, dynamic> data) {
    final converted = <String, dynamic>{};

    final doubleKeys = ['angkaMelekHuruf', 'rataRataLamaSekolah', 'harapanLamaSekolah', 'rasioGuruMurid'];
    for (final key in doubleKeys) {
      if (data.containsKey(key)) {
        converted[key] = (data[key] as num).toDouble();
      }
    }

    if (data.containsKey('jenjangPendidikan')) {
      final list = data['jenjangPendidikan'] as List;
      converted['jenjangPendidikan'] = list.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        for (final k in ['sekolah', 'guru', 'murid']) {
          if (map.containsKey(k) && map[k] is num) {
            map[k] = (map[k] as num).toInt();
          }
        }
        return map;
      }).toList();
    }

    if (data.containsKey('rasioData')) {
      final list = data['rasioData'] as List;
      converted['rasioData'] = list.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        for (final k in ['rasioSekolahMurid', 'rasioGuruMurid']) {
          if (map.containsKey(k) && map[k] is num) {
            map[k] = (map[k] as num).toDouble();
          }
        }
        return map;
      }).toList();
    }

    if (data.containsKey('partisipasiPendidikan')) {
      final list = data['partisipasiPendidikan'] as List;
      converted['partisipasiPendidikan'] = list.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        for (final k in ['apm', 'apk']) {
          if (map.containsKey(k) && map[k] is num) {
            map[k] = (map[k] as num).toDouble();
          }
        }
        return map;
      }).toList();
    }

    converted.addAll(data..removeWhere((key, _) => converted.containsKey(key)));
    return converted;
  }

  Map<int, Map<String, dynamic>> _getDefaultData() {
    return {
      2021: {
        'angkaMelekHuruf': 96.5,
        'rataRataLamaSekolah': 10.78,
        'harapanLamaSekolah': 15.53,
        'rasioGuruMurid': 16.08,
        'jenjangPendidikan': [
          {'jenjang': 'TK', 'sekolah': 668, 'guru': 2272, 'murid': 28986},
          {'jenjang': 'RA', 'sekolah': 137, 'guru': 693, 'murid': 8774},
          {'jenjang': 'SD', 'sekolah': 506, 'guru': 7140, 'murid': 131398},
          {'jenjang': 'MI', 'sekolah': 92, 'guru': 1180, 'murid': 19205},
          {'jenjang': 'SMP', 'sekolah': 191, 'guru': 3802, 'murid': 63809},
          {'jenjang': 'MTs', 'sekolah': 41, 'guru': 823, 'murid': 9538},
          {'jenjang': 'SMA', 'sekolah': 74, 'guru': 1889, 'murid': 30402},
          {'jenjang': 'SMK', 'sekolah': 86, 'guru': 2464, 'murid': 38239},
          {'jenjang': 'MA', 'sekolah': 32, 'guru': 742, 'murid': 6521},
        ],
        'rasioData': [
          {
            'jenjang': 'TK/RA',
            'rasioSekolahMurid': 46.91,
            'rasioGuruMurid': 12.74
          },
          {
            'jenjang': 'SD/MI',
            'rasioSekolahMurid': 251.84,
            'rasioGuruMurid': 18.10
          },
          {
            'jenjang': 'SMP/MTs',
            'rasioSekolahMurid': 316.15,
            'rasioGuruMurid': 15.86
          },
          {
            'jenjang': 'SMA/SMK/MA',
            'rasioSekolahMurid': 391.47,
            'rasioGuruMurid': 14.75
          },
        ],
        'partisipasiPendidikan': [
          {'jenjang': 'SD/MI/Sederajat', 'apm': 99.58, 'apk': 102.66},
          {'jenjang': 'SMP/MTs/Sederajat', 'apm': 90.86, 'apk': 95.00},
          {'jenjang': 'SMA/SMK/MA/Sederajat', 'apm': 70.23, 'apk': 105.01},
        ],
      },
      2022: {
        'angkaMelekHuruf': 96.9,
        'rataRataLamaSekolah': 10.80,
        'harapanLamaSekolah': 15.54,
        'rasioGuruMurid': 15.79,
        'jenjangPendidikan': [
          {'jenjang': 'TK', 'sekolah': 668, 'guru': 2473, 'murid': 32620},
          {'jenjang': 'RA', 'sekolah': 140, 'guru': 636, 'murid': 10051},
          {'jenjang': 'SD', 'sekolah': 507, 'guru': 7102, 'murid': 128239},
          {'jenjang': 'MI', 'sekolah': 94, 'guru': 1137, 'murid': 19730},
          {'jenjang': 'SMP', 'sekolah': 192, 'guru': 3757, 'murid': 62716},
          {'jenjang': 'MTs', 'sekolah': 43, 'guru': 798, 'murid': 9499},
          {'jenjang': 'SMA', 'sekolah': 73, 'guru': 1919, 'murid': 30552},
          {'jenjang': 'SMK', 'sekolah': 86, 'guru': 2379, 'murid': 36343},
          {'jenjang': 'MA', 'sekolah': 33, 'guru': 662, 'murid': 6680},
        ],
        'rasioData': [
          {
            'jenjang': 'TK/RA',
            'rasioSekolahMurid': 52.81,
            'rasioGuruMurid': 13.72
          },
          {
            'jenjang': 'SD/MI',
            'rasioSekolahMurid': 246.20,
            'rasioGuruMurid': 17.96
          },
          {
            'jenjang': 'SMP/MTs',
            'rasioSekolahMurid': 307.30,
            'rasioGuruMurid': 15.85
          },
          {
            'jenjang': 'SMA/SMK/MA',
            'rasioSekolahMurid': 383.20,
            'rasioGuruMurid': 14.83
          },
        ],
        'partisipasiPendidikan': [
          {'jenjang': 'SD/MI/Sederajat', 'apm': 99.97, 'apk': 103.03},
          {'jenjang': 'SMP/MTs/Sederajat', 'apm': 91.26, 'apk': 91.26},
          {'jenjang': 'SMA/SMK/MA/Sederajat', 'apm': 70.24, 'apk': 104.23},
        ],
      },
      2023: {
        'angkaMelekHuruf': 97.2,
        'rataRataLamaSekolah': 10.81,
        'harapanLamaSekolah': 15.55,
        'rasioGuruMurid': 15.82,
        'jenjangPendidikan': [
          {'jenjang': 'TK', 'sekolah': 683, 'guru': 2515, 'murid': 34757},
          {'jenjang': 'RA', 'sekolah': 141, 'guru': 654, 'murid': 10425},
          {'jenjang': 'SD', 'sekolah': 509, 'guru': 7076, 'murid': 125975},
          {'jenjang': 'MI', 'sekolah': 94, 'guru': 1166, 'murid': 19756},
          {'jenjang': 'SMP', 'sekolah': 194, 'guru': 3757, 'murid': 63248},
          {'jenjang': 'MTs', 'sekolah': 48, 'guru': 827, 'murid': 9293},
          {'jenjang': 'SMA', 'sekolah': 70, 'guru': 1874, 'murid': 30935},
          {'jenjang': 'SMK', 'sekolah': 83, 'guru': 2298, 'murid': 36517},
          {'jenjang': 'MA', 'sekolah': 34, 'guru': 676, 'murid': 6705},
        ],
        'rasioData': [
          {
            'jenjang': 'TK/RA',
            'rasioSekolahMurid': 54.83,
            'rasioGuruMurid': 14.26
          },
          {
            'jenjang': 'SD/MI',
            'rasioSekolahMurid': 241.68,
            'rasioGuruMurid': 17.68
          },
          {
            'jenjang': 'SMP/MTs',
            'rasioSekolahMurid': 299.76,
            'rasioGuruMurid': 15.82
          },
          {
            'jenjang': 'SMA/SMK/MA',
            'rasioSekolahMurid': 396.56,
            'rasioGuruMurid': 15.30
          },
        ],
        'partisipasiPendidikan': [
          {'jenjang': 'SD/MI/Sederajat', 'apm': 99.75, 'apk': 102.43},
          {'jenjang': 'SMP/MTs/Sederajat', 'apm': 80.17, 'apk': 84.92},
          {'jenjang': 'SMA/SMK/MA/Sederajat', 'apm': 61.01, 'apk': 102.59},
        ],
      },
      2024: {
        'angkaMelekHuruf': 97.6,
        'rataRataLamaSekolah': 11.05,
        'harapanLamaSekolah': 15.57,
        'rasioGuruMurid': 16.56,
        'jenjangPendidikan': [
          {'jenjang': 'TK', 'sekolah': 692, 'guru': 2561, 'murid': 34315},
          {'jenjang': 'RA', 'sekolah': 141, 'guru': 654, 'murid': 10425},
          {'jenjang': 'SD', 'sekolah': 510, 'guru': 7083, 'murid': 125715},
          {'jenjang': 'MI', 'sekolah': 94, 'guru': 1166, 'murid': 19756},
          {'jenjang': 'SMP', 'sekolah': 193, 'guru': 3854, 'murid': 63841},
          {'jenjang': 'MTs', 'sekolah': 48, 'guru': 827, 'murid': 9293},
          {'jenjang': 'SMA', 'sekolah': 72, 'guru': 1841, 'murid': 31289},
          {'jenjang': 'SMK', 'sekolah': 83, 'guru': 2220, 'murid': 36353},
          {'jenjang': 'MA', 'sekolah': 34, 'guru': 676, 'murid': 6705},
        ],
        'rasioData': [
          {
            'jenjang': 'TK/RA',
            'rasioSekolahMurid': 49.59,
            'rasioGuruMurid': 13.40
          },
          {
            'jenjang': 'SD/MI',
            'rasioSekolahMurid': 246.50,
            'rasioGuruMurid': 17.75
          },
          {
            'jenjang': 'SMP/MTs',
            'rasioSekolahMurid': 330.78,
            'rasioGuruMurid': 16.56
          },
          {
            'jenjang': 'SMA/SMK/MA',
            'rasioSekolahMurid': 436.40,
            'rasioGuruMurid': 16.66
          },
        ],
        'partisipasiPendidikan': [
          {'jenjang': 'SD/MI/Sederajat', 'apm': 99.14, 'apk': 101.11},
          {'jenjang': 'SMP/MTs/Sederajat', 'apm': 79.63, 'apk': 85.48},
          {'jenjang': 'SMA/SMK/MA/Sederajat', 'apm': 60.49, 'apk': 97.81},
        ],
      },
      2025: {
        'angkaMelekHuruf': 98.0,
        'rataRataLamaSekolah': 11.20,
        'harapanLamaSekolah': 15.60,
        'rasioGuruMurid': 16.47,
        'jenjangPendidikan': [
          {'jenjang': 'TK', 'sekolah': 696, 'guru': 2326, 'murid': 33344},
          {'jenjang': 'RA', 'sekolah': 141, 'guru': 597, 'murid': 9625},
          {'jenjang': 'SD', 'sekolah': 513, 'guru': 7217, 'murid': 124968},
          {'jenjang': 'MI', 'sekolah': 93, 'guru': 1099, 'murid': 19469},
          {'jenjang': 'SMP', 'sekolah': 193, 'guru': 3904, 'murid': 64306},
          {'jenjang': 'MTs', 'sekolah': 49, 'guru': 681, 'murid': 9298},
          {'jenjang': 'SMA', 'sekolah': 69, 'guru': 1843, 'murid': 30742},
          {'jenjang': 'SMK', 'sekolah': 82, 'guru': 2224, 'murid': 36100},
          {'jenjang': 'MA', 'sekolah': 33, 'guru': 593, 'murid': 6842},
        ],
        'rasioData': [
          {
            'jenjang': 'TK/RA',
            'rasioSekolahMurid': 47.91,
            'rasioGuruMurid': 14.34
          },
          {
            'jenjang': 'SD/MI',
            'rasioSekolahMurid': 243.60,
            'rasioGuruMurid': 17.32
          },
          {
            'jenjang': 'SMP/MTs',
            'rasioSekolahMurid': 333.19,
            'rasioGuruMurid': 16.47
          },
          {
            'jenjang': 'SMA/SMK/MA',
            'rasioSekolahMurid': 442.66,
            'rasioGuruMurid': 16.44
          },
        ],
        'partisipasiPendidikan': [
          {'jenjang': 'SD/MI/Sederajat', 'apm': 97.7, 'apk': 101.71},
          {'jenjang': 'SMP/MTs/Sederajat', 'apm': 80.86, 'apk': 92.32},
          {'jenjang': 'SMA/SMK/MA/Sederajat', 'apm': 71.45, 'apk': 89.31},
        ],
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final sizing = ResponsiveSizing(context);
    final isSmallScreen = sizing.isVerySmall || sizing.isSmall;

    return Scaffold(
      backgroundColor: bpsBackground,
      body: Column(
        children: [
          _buildHeader(context, sizing, isSmallScreen),
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: bpsGreen),
                        SizedBox(height: sizing.sectionSpacing - 8),
                        Text(
                          'Memuat data pendidikan...',
                          style: TextStyle(
                            fontSize: sizing.categoryLabelFontSize,
                            color: bpsTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : educationData.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(sizing.horizontalPadding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: isSmallScreen ? 48 : 64,
                                color: bpsTextLabel,
                              ),
                              SizedBox(height: sizing.sectionSpacing - 8),
                              Text(
                                'Belum Ada Data',
                                style: TextStyle(
                                  fontSize: sizing.sectionTitleSize,
                                  fontWeight: FontWeight.bold,
                                  color: bpsTextPrimary,
                                ),
                              ),
                              SizedBox(height: sizing.itemSpacing),
                              Text(
                                'Data pendidikan belum tersedia',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: sizing.categoryLabelFontSize,
                                  color: bpsTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : CustomScrollView(
                        physics: const ClampingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.all(sizing.horizontalPadding),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                _buildYearSelector(sizing, isSmallScreen),
                                SizedBox(height: sizing.sectionSpacing),
                                _buildMainIndicators(sizing, isSmallScreen),
                                SizedBox(height: sizing.sectionSpacing),
                                _buildEducationLevelChart(
                                    sizing, isSmallScreen),
                                SizedBox(height: sizing.sectionSpacing),
                                _buildRasioChart(sizing, isSmallScreen),
                                SizedBox(height: sizing.sectionSpacing),
                                _buildPartisipasiChart(sizing, isSmallScreen),
                                SizedBox(height: sizing.sectionSpacing),
                                _buildAdditionalStats(sizing, isSmallScreen),
                                SizedBox(height: sizing.sectionSpacing),
                                _buildKesimpulanCard(sizing, isSmallScreen),
                                SizedBox(height: sizing.sectionSpacing),
                              ]),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ResponsiveSizing sizing, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: bpsGreen,
        boxShadow: [
          BoxShadow(
            color: bpsGreen.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.all(sizing.horizontalPadding),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  'Data Pendidikan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen
                        ? sizing.headerTitleSize + 4
                        : sizing.headerTitleSize + 8,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: isSmallScreen ? 20 : 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearSelector(ResponsiveSizing sizing, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen
          ? sizing.statsCardPadding - 4
          : sizing.statsCardPadding),
      decoration: BoxDecoration(
        color: bpsCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bpsBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: bpsGreen,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Text(
                'Pilih Tahun Data',
                style: TextStyle(
                  fontSize: isSmallScreen
                      ? sizing.groupTitleSize - 2
                      : sizing.groupTitleSize,
                  fontWeight: FontWeight.w700,
                  color: bpsTextPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Wrap(
            spacing: isSmallScreen ? 8 : 12,
            runSpacing: isSmallScreen ? 8 : 12,
            children: years.map((year) {
              final isSelected = year == selectedYear;
              return Material(
                color: isSelected ? bpsGreen : bpsBackground,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    setState(() => selectedYear = year);
                    if (year == 2024) {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _show2024DataNotice();
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: isSmallScreen ? 60 : 70,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 8 : 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? bpsGreen : bpsBorder,
                        width: isSelected ? 2 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: bpsGreen.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      year.toString(),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : bpsTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainIndicators(ResponsiveSizing sizing, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen
          ? sizing.statsCardPadding - 4
          : sizing.statsCardPadding),
      decoration: BoxDecoration(
        color: bpsCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bpsBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: bpsGreen,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  'Indikator Utama Pendidikan',
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? sizing.groupTitleSize - 2
                        : sizing.groupTitleSize,
                    fontWeight: FontWeight.w700,
                    color: bpsTextPrimary,
                  ),
                ),
              ),
              if (!isSmallScreen) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sizing.itemSpacing,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bpsGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: bpsGreen,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap untuk detail',
                        style: TextStyle(
                          fontSize: 12,
                          color: bpsGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Column(
            children: [
              _buildCompactIndicatorRow(
                context: context,
                value:
                    '${NumberFormatUtils.formatCompact(getTotalMurid(selectedYear))}',
                label: 'Total Murid',
                color: bpsGreen,
                icon: Icons.groups,
                description:
                    'Total jumlah murid di seluruh jenjang pendidikan di Kota Semarang, mencakup TK, RA, SD, MI, SMP, MTs, SMA, SMK, dan MA.',
                isFirst: true,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${currentData['angkaMelekHuruf']}%',
                label: 'Angka Melek Huruf',
                color: bpsGreen,
                icon: Icons.menu_book,
                description:
                    'Angka Melek Huruf (AMH) menunjukkan persentase penduduk usia 15 tahun ke atas yang mampu membaca dan menulis huruf latin atau huruf lainnya.',
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${currentData['rataRataLamaSekolah']} th',
                label: 'Rata-rata Lama Sekolah',
                color: bpsOrange,
                icon: Icons.timer,
                description:
                    'Rata-rata Lama Sekolah (RLS) menunjukkan jumlah tahun rata-rata yang dihabiskan oleh penduduk usia 25 tahun ke atas untuk menempuh pendidikan formal.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactIndicatorRow({
    required BuildContext context,
    required String value,
    required String label,
    required Color color,
    required IconData icon,
    required String description,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final sizing = ResponsiveSizing(context);
    final isSmallScreen = sizing.isVerySmall || sizing.isSmall;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            _showDetailDialog(context, label, value, icon, color, description),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 8 : 10,
          ),
          child: Row(
            children: [
              Container(
                width: isSmallScreen ? 10 : 12,
                height: isSmallScreen ? 10 : 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 10),
              Expanded(
                flex: 3,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: bpsTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15 : 17,
                    fontWeight: FontWeight.w800,
                    color: bpsTextPrimary,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: color.withOpacity(0.5),
                size: isSmallScreen ? 18 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorDivider(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: bpsBorder.withOpacity(0.5),
      ),
    );
  }

  void _showDetailDialog(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String description,
  ) {
    final sizing = ResponsiveSizing(context);
    final isSmallScreen = sizing.isVerySmall || sizing.isSmall;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.all(isSmallScreen ? 12 : 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.7,
              maxWidth: isSmallScreen
                  ? MediaQuery.of(dialogContext).size.width - 24
                  : 500,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: Colors.white,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tahun $selectedYear',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(dialogContext),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: isSmallScreen ? 18 : 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: color.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Nilai Indikator',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: bpsTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 8 : 12),
                              Text(
                                value,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 28 : 32,
                                  fontWeight: FontWeight.w800,
                                  color: bpsTextPrimary,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          decoration: BoxDecoration(
                            color: bpsBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                color: color,
                                size: isSmallScreen ? 18 : 20,
                              ),
                              SizedBox(width: isSmallScreen ? 8 : 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Penjelasan',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        fontWeight: FontWeight.w700,
                                        color: color,
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 4 : 6),
                                    Text(
                                      description,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 13 : 14,
                                        color: bpsTextSecondary,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEducationLevelChart(
      ResponsiveSizing sizing, bool isSmallScreen) {
    final data = currentData['jenjangPendidikan'] as List;
    final colors = [
      bpsBlue,
      bpsBlue.withOpacity(0.7),
      bpsGreen,
      bpsGreen.withOpacity(0.7),
      bpsOrange,
      bpsOrange.withOpacity(0.7),
      bpsRed,
      bpsRed.withOpacity(0.7),
      bpsBlue.withOpacity(0.5),
    ];

    return Container(
      padding: EdgeInsets.all(isSmallScreen
          ? sizing.statsCardPadding - 4
          : sizing.statsCardPadding),
      decoration: BoxDecoration(
        color: bpsCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bpsBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: bpsGreen,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jumlah Murid per Jenjang',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? sizing.groupTitleSize - 2
                            : sizing.groupTitleSize,
                        fontWeight: FontWeight.w700,
                        color: bpsTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tahun $selectedYear',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: bpsTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 140000,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String jenjang =
                          data[groupIndex]['jenjang']?.toString() ?? '';
                      String jumlah = NumberFormatUtils.formatCompact(rod.toY);
                      return BarTooltipItem(
                        '$jenjang\n$jumlah ribu murid',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              data[value.toInt()]['jenjang']?.toString() ?? '',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 9 : 10,
                                fontWeight: FontWeight.w600,
                                color: bpsTextPrimary,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: 40000,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toInt()}k',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 9 : 10,
                            color: bpsTextSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 40000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: bpsBorder, strokeWidth: 1);
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (index) {
                  final muridValue = data[index]['murid'];
                  final muridDouble = (muridValue is int)
                      ? muridValue.toDouble()
                      : (muridValue is double)
                          ? muridValue
                          : 0.0;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: muridDouble,
                        color: colors[index % colors.length],
                        width: isSmallScreen ? 12 : 16,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRasioChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final rasioData = currentData['rasioData'] as List;

    // Find max school-to-student ratio for appropriate Y-axis
    double maxRasioSekolah = 0;
    for (var item in rasioData) {
      final val = item['rasioSekolahMurid'];
      if (val is num && val.toDouble() > maxRasioSekolah) {
        maxRasioSekolah = val.toDouble();
      }
    }
    final chartMaxY = ((maxRasioSekolah / 100).ceil() * 100).toDouble() + 50;

    return Column(
      children: [
        // Bar chart for School-to-Student ratio
        Container(
          padding: EdgeInsets.all(isSmallScreen
              ? sizing.statsCardPadding - 4
              : sizing.statsCardPadding),
          decoration: BoxDecoration(
            color: bpsCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: bpsBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bar_chart,
                    color: bpsOrange,
                    size: isSmallScreen ? 16 : 20,
                  ),
                  SizedBox(width: sizing.itemSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rasio Murid per Sekolah',
                          style: TextStyle(
                            fontSize: isSmallScreen
                                ? sizing.groupTitleSize - 2
                                : sizing.groupTitleSize,
                            fontWeight: FontWeight.w700,
                            color: bpsTextPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tahun $selectedYear',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            color: bpsTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
              SizedBox(
                height: 240,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: chartMaxY,
                    minY: 0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          if (groupIndex >= rasioData.length) return null;
                          String jenjang =
                              rasioData[groupIndex]['jenjang']?.toString() ??
                                  '';
                          String rasio = NumberFormatUtils.formatDecimal(
                              rod.toY,
                              decimalPlaces: 1);
                          return BarTooltipItem(
                            '$jenjang\n$rasio murid/sekolah',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < rasioData.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  rasioData[index]['jenjang']?.toString() ?? '',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 9 : 10,
                                    fontWeight: FontWeight.w600,
                                    color: bpsTextPrimary,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          interval: 100,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 9 : 10,
                                color: bpsTextSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 100,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(color: bpsBorder, strokeWidth: 1);
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: rasioData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;

                      final rasioSekolahValue = data['rasioSekolahMurid'];
                      double rasioSekolah = 0.0;
                      if (rasioSekolahValue is num) {
                        rasioSekolah = rasioSekolahValue.toDouble();
                      }

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: rasioSekolah,
                            color: bpsOrange,
                            width: isSmallScreen ? 20 : 28,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sizing.sectionSpacing),
        // Compact indicators for Teacher-to-Student ratio
        Container(
          padding: EdgeInsets.all(isSmallScreen
              ? sizing.statsCardPadding - 4
              : sizing.statsCardPadding),
          decoration: BoxDecoration(
            color: bpsCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: bpsBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people,
                    color: bpsGreen,
                    size: isSmallScreen ? 16 : 20,
                  ),
                  SizedBox(width: sizing.itemSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rasio Murid per Guru',
                          style: TextStyle(
                            fontSize: isSmallScreen
                                ? sizing.groupTitleSize - 2
                                : sizing.groupTitleSize,
                            fontWeight: FontWeight.w700,
                            color: bpsTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tahun $selectedYear',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            color: bpsTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              ...rasioData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final jenjang = data['jenjang']?.toString() ?? '';
                final rasioGuruValue = data['rasioGuruMurid'];
                double rasioGuru = 0.0;
                if (rasioGuruValue is num) {
                  rasioGuru = rasioGuruValue.toDouble();
                }

                return Column(
                  children: [
                    if (index > 0)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: bpsBorder.withOpacity(0.5),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 10 : 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: isSmallScreen ? 10 : 12,
                            height: isSmallScreen ? 10 : 12,
                            decoration: const BoxDecoration(
                              color: bpsGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 10),
                          Expanded(
                            child: Text(
                              jenjang,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                                fontWeight: FontWeight.w600,
                                color: bpsTextPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '1 : ${NumberFormatUtils.formatDecimal(rasioGuru, decimalPlaces: 1)}',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 15 : 17,
                              fontWeight: FontWeight.w800,
                              color: bpsTextPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartisipasiChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final partisipasiData = currentData['partisipasiPendidikan'] as List;

    return Container(
      padding: EdgeInsets.all(isSmallScreen
          ? sizing.statsCardPadding - 4
          : sizing.statsCardPadding),
      decoration: BoxDecoration(
        color: bpsCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bpsBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: bpsGreen,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Angka Partisipasi Murni (APM) & Kasar (APK)',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? sizing.groupTitleSize - 2
                            : sizing.groupTitleSize,
                        fontWeight: FontWeight.w700,
                        color: bpsTextPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tahun $selectedYear',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: bpsTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Wrap(
            spacing: isSmallScreen ? 8 : 12,
            runSpacing: isSmallScreen ? 8 : 12,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem('APM', bpsGreen, isSmallScreen),
              _buildLegendItem('APK', bpsBlue, isSmallScreen),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 110,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (groupIndex >= partisipasiData.length) return null;
                      String jenjang =
                          partisipasiData[groupIndex]['jenjang']?.toString() ??
                              '';
                      String label = rodIndex == 0 ? 'APM' : 'APK';
                      String nilai = NumberFormatUtils.formatDecimal(rod.toY,
                          decimalPlaces: 2);
                      return BarTooltipItem(
                        '$jenjang\n$label: $nilai%',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < partisipasiData.length) {
                          String jenjang =
                              partisipasiData[index]['jenjang']?.toString() ??
                                  '';
                          if (jenjang.length > 15) {
                            jenjang = jenjang.replaceAll('Sederajat', '');
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              jenjang,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 8 : 9,
                                fontWeight: FontWeight.w600,
                                color: bpsTextPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 9 : 10,
                            color: bpsTextSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: bpsBorder, strokeWidth: 1);
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: partisipasiData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;

                  final apmValue = data['apm'];
                  double apm = 0.0;
                  if (apmValue is num) {
                    apm = apmValue.toDouble();
                  }

                  final apkValue = data['apk'];
                  double apk = 0.0;
                  if (apkValue is num) {
                    apk = apkValue.toDouble();
                  }

                  return BarChartGroupData(
                    x: index,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: apm,
                        color: bpsGreen,
                        width: isSmallScreen ? 14 : 18,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: apk,
                        color: bpsBlue,
                        width: isSmallScreen ? 14 : 18,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalStats(ResponsiveSizing sizing, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen
          ? sizing.statsCardPadding - 4
          : sizing.statsCardPadding),
      decoration: BoxDecoration(
        color: bpsCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bpsBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: bpsGreen,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  'Informasi Tambahan',
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? sizing.groupTitleSize - 2
                        : sizing.groupTitleSize,
                    fontWeight: FontWeight.w700,
                    color: bpsTextPrimary,
                  ),
                ),
              ),
              if (!isSmallScreen) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sizing.itemSpacing,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bpsGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: bpsGreen,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap untuk detail',
                        style: TextStyle(
                          fontSize: 12,
                          color: bpsGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Column(
            children: [
              _buildCompactIndicatorRow(
                context: context,
                value: '1:${currentData['rasioGuruMurid']}',
                label: 'Rasio Guru:Murid',
                color: bpsGreen,
                icon: Icons.people,
                description:
                    'Rasio Guru terhadap Murid menunjukkan perbandingan jumlah guru dengan jumlah murid di seluruh jenjang pendidikan. Semakin kecil rasio, semakin ideal kondisi pembelajaran.',
                isFirst: true,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${currentData['harapanLamaSekolah']} tahun',
                label: 'Harapan Lama Sekolah',
                color: bpsGreen,
                icon: Icons.school,
                description:
                    'Harapan Lama Sekolah (HLS) menunjukkan lamanya sekolah (dalam tahun) yang diharapkan akan dirasakan oleh anak pada umur tertentu di masa mendatang.',
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 10 : 12, vertical: isSmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: isSmallScreen ? 8 : 10,
            height: isSmallScreen ? 8 : 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: isSmallScreen ? 4 : 6),
        Text(label,
            style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: color,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildKesimpulanCard(ResponsiveSizing sizing, bool isSmallScreen) {
    if (educationData.isEmpty || years.length < 2) {
      return const SizedBox.shrink();
    }

    final sortedYears = List<int>.from(years)..sort((a, b) => a.compareTo(b));
    final latestYear = sortedYears.last;
    final firstYear = sortedYears.first;

    final latestData = educationData[latestYear];
    final firstData = educationData[firstYear];

    if (latestData == null || firstData == null) {
      return const SizedBox.shrink();
    }

    // Get enrollment rate (partisipasi)
    final latestEnrollment =
        (latestData['partisipasi'] as num?)?.toDouble() ?? 0.0;
    final firstEnrollment =
        (firstData['partisipasi'] as num?)?.toDouble() ?? 0.0;

    // Get teacher ratio
    final latestRasio = (latestData['rasioGuru'] as num?)?.toDouble() ?? 0.0;

    final conclusionData = KesimpulanGenerator.generatePendidikanConclusion(
      latestYear: latestYear,
      firstYear: firstYear,
      latestEnrollment: latestEnrollment,
      firstEnrollment: firstEnrollment,
      teacherRatio: latestRasio,
    );

    return KesimpulanWidget(
      title: 'Pendidikan Kota Semarang',
      conclusion: conclusionData['conclusion'] as String,
      status: conclusionData['status'] as KesimpulanStatus,
      sizing: sizing,
      isSmallScreen: isSmallScreen,
      additionalPoints: (conclusionData['additionalPoints'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}
