import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'responsive_sizing.dart';
import 'number_format_utils.dart';
import 'kesimpulan_widget.dart';
import 'services/github_data_service.dart';
import 'app_theme.dart';

class InflasiScreen extends StatefulWidget {
  const InflasiScreen({super.key});

  @override
  State<InflasiScreen> createState() => _InflasiScreenState();
}

class _InflasiScreenState extends State<InflasiScreen>
    with AutomaticKeepAliveClientMixin {
  int selectedYear = 2026;
  int? selectedMonth;
  int? selectedComponentMonth; // For component breakdown

  @override
  bool get wantKeepAlive => true;

  final List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final List<String> fullMonths = [
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
    'Desember',
  ];

  Map<int, List<double?>> monthlyInflationData = {};
  Map<int, double?> yearlyInflation = {};
  Map<int, double> ihkData = {};
  Map<String, Map<int, List<double?>>> inflationComponentsMonthly = {};
  Map<String, Map<String, double>> inflationComponentsYearly = {};

  @override
  void initState() {
    super.initState();
    _loadFromGitHub();
  }

  void _loadFromGitHub() {
    final data = GitHubDataService.getData('inflasi');
    if (data == null) {
      _loadDefaults();
      return;
    }

    final mid = data['monthlyInflationData'];
    if (mid is Map) {
      monthlyInflationData = {};
      for (final entry in mid.entries) {
        final year = int.parse(entry.key.toString());
        final values = (entry.value as List).map((v) => (v as num?)?.toDouble()).toList();
        monthlyInflationData[year] = values;
      }
    }

    final yi = data['yearlyInflation'];
    if (yi is Map) {
      yearlyInflation = {};
      for (final entry in yi.entries) {
        final year = int.parse(entry.key.toString());
        yearlyInflation[year] = (entry.value as num?)?.toDouble();
      }
    }

    final ih = data['ihkData'];
    if (ih is Map) {
      ihkData = {};
      for (final entry in ih.entries) {
        final year = int.parse(entry.key.toString());
        ihkData[year] = (entry.value as num).toDouble();
      }
    }

    final icm = data['inflationComponentsMonthly'];
    if (icm is Map) {
      inflationComponentsMonthly = {};
      for (final compEntry in icm.entries) {
        final component = compEntry.key.toString();
        final yearMap = <int, List<double?>>{};
        for (final yearEntry in (compEntry.value as Map).entries) {
          final year = int.parse(yearEntry.key.toString());
          final values = (yearEntry.value as List).map((v) => (v as num?)?.toDouble()).toList();
          yearMap[year] = values;
        }
        inflationComponentsMonthly[component] = yearMap;
      }
    }

    final icy = data['inflationComponentsYearly'];
    if (icy is Map) {
      inflationComponentsYearly = {};
      for (final compEntry in icy.entries) {
        final component = compEntry.key.toString();
        final yearMap = <String, double>{};
        for (final yearEntry in (compEntry.value as Map).entries) {
          yearMap[yearEntry.key.toString()] = (yearEntry.value as num).toDouble();
        }
        inflationComponentsYearly[component] = yearMap;
      }
    }

    if (yearlyInflation.isNotEmpty) {
      final latestYear = yearlyInflation.keys.reduce((a, b) => a > b ? a : b);
      selectedYear = latestYear;
    }

    setState(() {});
  }

  void _loadDefaults() {
    monthlyInflationData = {
      2022: [
        0.31,
        -0.08,
        0.66,
        0.86,
        0.53,
        0.93,
        0.59,
        -0.44,
        1.13,
        -0.18,
        0.13,
        0.45
      ],
      2023: [
        0.30,
        0.21,
        0.20,
        0.27,
        0.22,
        0.02,
        0.23,
        0.02,
        0.42,
        0.17,
        0.52,
        0.22
      ],
      2024: [
        -0.11,
        0.55,
        0.62,
        0.32,
        -0.21,
        -0.26,
        -0.13,
        -0.04,
        0.01,
        0.20,
        0.22,
        0.50
      ],
      2025: [
        -0.69,
        -0.64,
        1.42,
        1.53,
        -0.42,
        0.22,
        0.23,
        -0.05,
        0.18,
        0.39,
        0.22,
        0.42
      ],
      2026: [
        -0.25,
        0.67,
        0.37,
      ],
    };

    yearlyInflation = {
      2022: 4.99,
      2023: 2.84,
      2024: 1.69,
      2025: 2.84,
      2026: 3.57,
    };

    ihkData = {
      2022: 116.05,
      2023: 116.05,
      2024: 106.09,
      2025: 109.10,
      2026: 109.97,
    };

    inflationComponentsMonthly = {
      'Makanan, Minuman & Tembakau': {
        2022: [
          0.82,
          -1.31,
          1.46,
          1.89,
          1.02,
          2.47,
          1.58,
          -2.11,
          -0.19,
          -1.54,
          0.30,
          1.50
        ],
        2023: [
          1.29,
          0.50,
          0.15,
          0.71,
          0.60,
          0.06,
          0.30,
          -0.11,
          0.73,
          0.40,
          2.14,
          0.53
        ],
        2024: [
          -0.56,
          1.99,
          2.08,
          0.16,
          -1.01,
          -1.18,
          -0.90,
          -0.66,
          -0.32,
          0.56,
          0.61,
          1.52
        ],
        2025: [
          1.93,
          -0.49,
          1.38,
          -0.09,
          -1.65,
          0.90,
          0.05,
          -0.69,
          0.37,
          0.50,
          0.62,
          1.12
        ],
        2026: [
          -1.79,
          0.08,
          1.26,
        ],
      },
      'Pakaian & Alas Kaki': {
        2022: [
          0.32,
          0.26,
          0.25,
          0.78,
          0.03,
          0.68,
          0.24,
          0.66,
          0.42,
          0.27,
          0.42,
          0.08
        ],
        2023: [
          -0.04,
          0.01,
          0.25,
          0.24,
          0.11,
          0.27,
          0.09,
          0.01,
          0.02,
          0.09,
          0.06,
          0.22
        ],
        2024: [
          0.14,
          0.00,
          0.13,
          -0.11,
          0.11,
          0.00,
          0.01,
          0.10,
          0.00,
          0.14,
          0.04,
          0.01
        ],
        2025: [
          0.19,
          0.03,
          0.50,
          0.00,
          0.08,
          0.06,
          0.18,
          -0.01,
          0.01,
          0.01,
          0.03,
          0.03
        ],
        2026: [
          -1.34,
          2.03,
          0.15,
        ],
      },
      'Perumahan & Fasilitas': {
        2022: [
          0.16,
          0.01,
          0.07,
          0.06,
          0.03,
          0.06,
          0.26,
          0.38,
          0.37,
          0.18,
          -0.20,
          -0.05
        ],
        2023: [
          0.10,
          0.01,
          0.03,
          0.02,
          0.01,
          0.00,
          -0.04,
          0.01,
          0.01,
          -0.03,
          -0.02,
          -0.01
        ],
        2024: [
          -0.02,
          -0.01,
          0.02,
          0.07,
          -0.13,
          -0.07,
          0.03,
          0.00,
          0.57,
          0.35,
          -0.02,
          -0.05
        ],
        2025: [
          -10.17,
          -6.17,
          9.41,
          9.07,
          -0.01,
          -0.04,
          0.02,
          0.11,
          0.12,
          0.06,
          0.11,
          0.17
        ],
        2026: [
          0.10,
          2.04,
          0.04,
        ],
      },
      'Perlengkapan Rumah Tangga': {
        2022: [
          0.85,
          0.64,
          0.72,
          0.33,
          0.38,
          0.69,
          0.38,
          -0.09,
          0.15,
          0.15,
          0.03,
          0.43
        ],
        2023: [
          0.06,
          0.14,
          0.00,
          -0.02,
          0.14,
          0.26,
          0.18,
          0.32,
          0.05,
          0.08,
          0.03,
          0.03
        ],
        2024: [
          0.12,
          0.22,
          0.07,
          0.09,
          0.13,
          0.06,
          0.11,
          0.10,
          0.02,
          0.43,
          -0.11,
          0.15
        ],
        2025: [
          0.08,
          0.29,
          0.08,
          -0.01,
          0.00,
          0.11,
          -0.04,
          -0.19,
          0.00,
          0.11,
          -0.35,
          0.06
        ],
        2026: [
          -0.03,
          0.08,
          0.09,
        ],
      },
      'Kesehatan': {
        2022: [
          0.01,
          0.27,
          -0.07,
          0.03,
          0.02,
          0.08,
          0.06,
          0.22,
          0.15,
          0.19,
          0.16,
          -0.03
        ],
        2023: [
          0.54,
          0.07,
          0.32,
          0.64,
          0.10,
          0.47,
          0.12,
          0.01,
          0.20,
          0.04,
          0.02,
          0.04
        ],
        2024: [
          0.05,
          0.05,
          -0.08,
          0.08,
          0.12,
          -0.16,
          0.08,
          0.16,
          0.14,
          0.15,
          0.05,
          0.22
        ],
        2025: [
          0.12,
          0.25,
          0.09,
          0.00,
          0.01,
          0.14,
          0.02,
          0.06,
          0.14,
          0.15,
          0.07,
          0.01
        ],
        2026: [
          -0.63,
          0.03,
          0.27,
        ],
      },
      'Transportasi': {
        2022: [
          -0.07,
          0.58,
          0.86,
          2.06,
          1.61,
          1.33,
          0.87,
          -0.91,
          7.92,
          0.48,
          0.33,
          0.02
        ],
        2023: [
          -0.87,
          0.38,
          0.86,
          0.35,
          0.48,
          -0.79,
          0.67,
          -0.58,
          1.23,
          0.30,
          -0.15,
          0.38
        ],
        2024: [
          -0.17,
          0.09,
          -0.25,
          0.74,
          -0.12,
          0.09,
          0.04,
          0.34,
          -0.10,
          -0.78,
          0.12,
          0.56
        ],
        2025: [
          -0.12,
          0.51,
          -0.35,
          1.41,
          -0.33,
          -0.29,
          0.37,
          0.10,
          -0.36,
          0.03,
          0.39,
          -0.18
        ],
        2026: [
          -0.13,
          -0.05,
          0.24,
        ],
      },
      'Komunikasi & Keuangan': {
        2022: [
          -0.15,
          0.05,
          -0.06,
          -0.03,
          0.14,
          -0.55,
          -0.12,
          -0.32,
          -0.05,
          -0.22,
          -0.09,
          -0.03
        ],
        2023: [
          -0.02,
          0.11,
          -0.11,
          -0.34,
          -0.18,
          0.01,
          -0.34,
          0.00,
          0.28,
          0.00,
          0.00,
          0.09
        ],
        2024: [
          0.00,
          -0.08,
          0.00,
          -0.24,
          -0.18,
          -0.10,
          -0.06,
          -0.18,
          -0.07,
          0.03,
          -0.22,
          null
        ],
        2025: [
          0.00,
          0.00,
          0.00,
          -0.42,
          -0.02,
          0.00,
          0.00,
          -0.21,
          0.03,
          -0.02,
          0.00,
          0.01
        ],
        2026: [
          0.01,
          0.08,
          0.37,
        ],
      },
      'Rekreasi & Olahraga': {
        2022: [
          0.14,
          0.34,
          0.08,
          0.10,
          0.63,
          0.10,
          0.43,
          0.24,
          -1.58,
          2.48,
          0.98,
          0.06
        ],
        2023: [
          1.03,
          0.17,
          0.23,
          0.11,
          0.00,
          -0.02,
          -0.03,
          0.30,
          0.00,
          0.09,
          0.00,
          0.04
        ],
        2024: [
          0.05,
          0.13,
          0.03,
          0.13,
          -0.22,
          0.03,
          0.16,
          -0.06,
          0.16,
          0.00,
          -0.06,
          0.19
        ],
        2025: [
          0.45,
          0.17,
          0.07,
          0.22,
          0.01,
          0.00,
          -0.02,
          0.12,
          0.02,
          0.00,
          -0.24,
          0.04
        ],
        2026: [
          0.18,
          0.44,
          0.27,
        ],
      },
      'Pendidikan': {
        2022: [
          0.00,
          0.00,
          0.00,
          0.00,
          0.00,
          0.00,
          -1.21,
          0.12,
          0.21,
          0.00,
          0.00,
          0.00
        ],
        2023: [
          0.00,
          0.00,
          0.00,
          0.00,
          0.00,
          0.00,
          1.12,
          0.72,
          0.14,
          0.00,
          0.00,
          0.00
        ],
        2024: [
          0.00,
          0.00,
          0.00,
          0.00,
          0.00,
          0.00,
          0.24,
          0.59,
          0.00,
          0.00,
          0.00,
          null
        ],
        2025: [
          0.00,
          0.00,
          0.00,
          0.00,
          0.00,
          0.00,
          1.88,
          1.26,
          0.00,
          0.00,
          0.00,
          0.00
        ],
        2026: [
          0.07,
          -0.08,
          0.00,
        ],
      },
      'Restoran': {
        2022: [
          0.03,
          0.22,
          0.52,
          0.27,
          0.21,
          0.46,
          0.48,
          0.74,
          0.38,
          0.04,
          0.05,
          0.22
        ],
        2023: [
          0.09,
          0.05,
          0.00,
          0.04,
          0.05,
          0.84,
          0.04,
          0.64,
          0.04,
          0.00,
          0.00,
          0.04
        ],
        2024: [
          0.20,
          0.49,
          1.02,
          0.70,
          0.26,
          0.13,
          0.10,
          0.01,
          0.05,
          0.37,
          0.19,
          0.21
        ],
        2025: [
          0.73,
          0.08,
          0.18,
          0.94,
          0.23,
          0.08,
          0.05,
          0.07,
          0.00,
          0.05,
          0.04,
          0.07
        ],
        2026: [
          0.22,
          -0.06,
          0.08,
        ],
      },
      'Perawatan Pribadi': {
        2022: [
          0.45,
          1.19,
          1.51,
          0.81,
          0.05,
          0.94,
          0.28,
          0.67,
          0.07,
          0.11,
          0.28,
          0.88
        ],
        2023: [
          0.81,
          0.08,
          0.45,
          0.39,
          -0.02,
          -0.09,
          -0.02,
          0.02,
          0.46,
          0.32,
          0.24,
          0.45
        ],
        2024: [
          0.18,
          0.00,
          0.67,
          1.87,
          0.60,
          0.39,
          0.62,
          0.37,
          0.24,
          1.00,
          0.84,
          0.29
        ],
        2025: [
          0.77,
          1.22,
          0.98,
          3.22,
          0.04,
          0.49,
          0.06,
          0.18,
          1.67,
          3.46,
          0.33,
          2.05
        ],
        2026: [
          3.41,
          0.07,
          -0.44,
        ],
      },
    };

    inflationComponentsYearly = {
      'Makanan, Minuman & Tembakau': {
        '2022': 5.91,
        '2023': 7.52,
        '2024': 2.24,
        '2025': 3.98,
        '2026': 0.00
      },
      'Pakaian & Alas Kaki': {
        '2022': 4.51,
        '2023': 1.33,
        '2024': 0.55,
        '2025': 1.11,
        '2026': 0.00
      },
      'Perumahan & Fasilitas': {
        '2022': 1.33,
        '2023': 0.09,
        '2024': 0.74,
        '2025': 1.12,
        '2026': 0.00
      },
      'Perlengkapan Rumah Tangga': {
        '2022': 4.75,
        '2023': 1.27,
        '2024': 1.39,
        '2025': 0.13,
        '2026': 0.00
      },
      'Kesehatan': {
        '2022': 1.08,
        '2023': 2.58,
        '2024': 0.85,
        '2025': 1.04,
        '2026': 0.00
      },
      'Transportasi': {
        '2022': 15.88,
        '2023': 2.26,
        '2024': 0.55,
        '2025': 1.17,
        '2026': 0.00
      },
      'Komunikasi & Keuangan': {
        '2022': -1.43,
        '2023': -0.50,
        '2024': -1.11,
        '2025': -0.63,
        '2026': 0.00
      },
      'Rekreasi & Olahraga': {
        '2022': 4.03,
        '2023': 1.93,
        '2024': 0.53,
        '2025': 0.83,
        '2026': 0.00
      },
      'Pendidikan': {
        '2022': -0.89,
        '2023': 2.00,
        '2024': 0.83,
        '2025': 3.16,
        '2026': 0.00
      },
      'Restoran': {
        '2022': 3.66,
        '2023': 1.85,
        '2024': 3.78,
        '2025': 2.55,
        '2026': 0.00
      },
      'Perawatan Pribadi': {
        '2022': 7.49,
        '2023': 3.13,
        '2024': 7.26,
        '2025': 15.41,
        '2026': 0.00
      },
    };
  }

  List<int> get availableYears =>
      monthlyInflationData.keys.toList()..sort((a, b) => a.compareTo(b));

  List<double> get filteredMonthlyData {
    final data = monthlyInflationData[selectedYear] ?? [];
    if (selectedMonth == null) {
      return data.whereType<double>().toList();
    } else {
      if (selectedMonth! >= data.length) return [];
      final value = data[selectedMonth!];
      return value != null ? [value] : [];
    }
  }

  double get currentInflationValue {
    final data = monthlyInflationData[selectedYear];
    if (selectedMonth == null) {
      if (data == null) return 0.0;
      for (int i = data.length - 1; i >= 0; i--) {
        if (data[i] != null) return data[i]!;
      }
      return 0.0;
    } else {
      if (data == null || selectedMonth! >= data.length) return 0.0;
      return data[selectedMonth!] ?? 0.0;
    }
  }

  String get currentMonthLabel {
    if (selectedMonth == null) {
      return 'Desember';
    } else {
      return fullMonths[selectedMonth!];
    }
  }

  Color get inflationColor {
    final value = currentInflationValue;
    if (value > 0.5) return bpsRed;
    if (value > 0.2) return bpsOrange;
    if (value >= 0) return bpsGreen;
    return bpsBlue;
  }

  @override
  Widget build(BuildContext context) {
    final sizing = ResponsiveSizing(context);
    final isSmallScreen = sizing.isVerySmall || sizing.isSmall;

    if (availableYears.isEmpty) {
      return Scaffold(
        backgroundColor: bpsBackground,
        body: Column(
          children: [
            _buildHeader(context, sizing, isSmallScreen),
            Expanded(
              child: Center(
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
                        'Data inflasi belum tersedia',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: sizing.categoryLabelFontSize,
                          color: bpsTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: bpsBackground,
      body: Column(
        children: [
          _buildHeader(context, sizing, isSmallScreen),
          Expanded(
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(sizing.horizontalPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildYearSelector(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildMonthSelector(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildMainIndicators(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildInflationChart(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildMonthlyInflationChart(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildInflationComponents(sizing, isSmallScreen),
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
        color: bpsBlue,
        boxShadow: [
          BoxShadow(
            color: bpsBlue.withOpacity(0.2),
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
                  'Data Inflasi',
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
                Icons.analytics_rounded,
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
                color: bpsBlue,
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
            children: availableYears.map((year) {
              final isSelected = year == selectedYear;
              return Material(
                color: isSelected ? bpsBlue : bpsBackground,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedYear = year;
                      selectedMonth = null;
                      selectedComponentMonth = null;
                    });
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
                        color: isSelected ? bpsBlue : bpsBorder,
                        width: isSelected ? 2 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: bpsBlue.withOpacity(0.3),
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

  Widget _buildMonthSelector(ResponsiveSizing sizing, bool isSmallScreen) {
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
                Icons.calendar_month_rounded,
                color: bpsOrange,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Text(
                'Pilih Bulan',
                style: TextStyle(
                  fontSize: isSmallScreen
                      ? sizing.groupTitleSize - 2
                      : sizing.groupTitleSize,
                  fontWeight: FontWeight.w700,
                  color: bpsTextPrimary,
                ),
              ),
              const Spacer(),
              if (selectedMonth != null)
                Material(
                  color: bpsOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => setState(() => selectedMonth = null),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: sizing.itemSpacing,
                        vertical: 4,
                      ),
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: sizing.bottomNavLabelSize,
                          color: bpsOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(
                monthlyInflationData[selectedYear]?.length ?? 12,
                (index) {
                  final isSelected = selectedMonth == index;
                  return Padding(
                    padding: EdgeInsets.only(right: sizing.itemSpacing),
                    child: Material(
                      color: isSelected ? bpsOrange : bpsBackground,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedMonth = isSelected ? null : index;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: isSmallScreen ? 50 : 60,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 10 : 12,
                            vertical: isSmallScreen ? 8 : 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? bpsOrange : bpsBorder,
                              width: isSelected ? 2 : 1.5,
                            ),
                          ),
                          child: Text(
                            months[index],
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color:
                                  isSelected ? Colors.white : bpsTextSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainIndicators(ResponsiveSizing sizing, bool isSmallScreen) {
    final yearInflation = yearlyInflation[selectedYear] ?? 0.0;
    final ihk = ihkData[selectedYear] ?? 0.0;

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
                color: bpsBlue,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  'Indikator Utama Inflasi',
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
                    color: bpsBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: bpsBlue,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap untuk detail',
                        style: TextStyle(
                          fontSize: 12,
                          color: bpsBlue,
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
                value: NumberFormatUtils.formatPercentage(yearInflation),
                label: 'Inflasi Tahunan',
                color: bpsBlue,
                icon: Icons.trending_up_rounded,
                description:
                    'Inflasi tahunan (Year-on-Year) mengukur perubahan harga barang dan jasa secara umum selama satu tahun. Angka ini menjadi acuan utama kebijakan moneter.',
                isFirst: true,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value:
                    NumberFormatUtils.formatPercentage(currentInflationValue),
                label: selectedMonth == null
                    ? 'Inflasi Bulanan'
                    : 'Inflasi $currentMonthLabel',
                color: inflationColor,
                icon: Icons.calendar_month_rounded,
                description:
                    'Inflasi bulanan (Month-to-Month) mengukur perubahan harga barang dan jasa dari bulan ke bulan. Fluktuasi bulanan dipengaruhi oleh faktor musiman dan kebijakan harga.',
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: NumberFormatUtils.formatDecimal(ihk, decimalPlaces: 2),
                label: 'Indeks Harga Konsumen',
                color: bpsPurple,
                icon: Icons.assessment_rounded,
                description:
                    'Indeks Harga Konsumen (IHK) mengukur rata-rata perubahan harga dari suatu paket barang dan jasa yang dikonsumsi oleh rumah tangga. Basis perhitungan 2018=100.',
                isLast: true,
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
        onTap: () => _showDetailDialog(
          context,
          label,
          value,
          icon,
          color,
          description,
        ),
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

  Widget _buildInflationChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final years = availableYears;
    final spots = years.asMap().entries.map((e) {
      final val = yearlyInflation[e.value] ?? 0.0;
      return FlSpot(e.key.toDouble(), val);
    }).toList();

    final validValues = yearlyInflation.values.whereType<double>().toList();
    final maxY = validValues.isEmpty
        ? 5.0
        : (validValues.reduce((a, b) => a > b ? a : b) + 0.5).ceilToDouble();

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
                Icons.show_chart_rounded,
                color: bpsBlue,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tren Inflasi Tahunan',
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
                      'Persentase Year-on-Year (${years.first}-${years.last})',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: bpsTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          SizedBox(
            height: isSmallScreen ? 200 : 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: bpsBorder,
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: isSmallScreen ? 35 : 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          NumberFormatUtils.formatPercentage(value),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: bpsTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < years.length) {
                          return Padding(
                            padding:
                                EdgeInsets.only(top: isSmallScreen ? 6 : 8),
                            child: Text(
                              years[index].toString(),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 12,
                                color: bpsTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.white,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final year = years[spot.x.toInt()];
                        return LineTooltipItem(
                          '$year',
                          const TextStyle(
                            color: bpsTextSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                          children: [
                            const TextSpan(text: '\n'),
                            TextSpan(
                              text: '${NumberFormatUtils.formatValue(spot.y, decimalPlaces: 2)}%',
                              style: const TextStyle(
                                color: bpsBlue,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (years.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: bpsBlue,
                    barWidth: isSmallScreen ? 2.5 : 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: isSmallScreen ? 3 : 5,
                          color: bpsBlue,
                          strokeWidth: isSmallScreen ? 1.5 : 2.5,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          bpsBlue.withOpacity(0.2),
                          bpsBlue.withOpacity(0.02),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyInflationChart(
      ResponsiveSizing sizing, bool isSmallScreen) {
    if (filteredMonthlyData.isEmpty) {
      return Container(
        padding: EdgeInsets.all(sizing.statsCardPadding),
        decoration: BoxDecoration(
          color: bpsCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: bpsBorder, width: 1.5),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.info_outline_rounded, size: 40, color: bpsTextLabel),
              SizedBox(height: sizing.itemSpacing),
              Text(
                'Data tidak tersedia',
                style: TextStyle(
                  fontSize: sizing.categoryLabelFontSize,
                  color: bpsTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final monthlyData = filteredMonthlyData;
    final maxValue = monthlyData.reduce((a, b) => a > b ? a : b) + 0.2;
    final minValue = monthlyData.reduce((a, b) => a < b ? a : b) - 0.2;

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
                Icons.bar_chart_rounded,
                color: bpsGreen,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedMonth == null
                          ? 'Inflasi Bulanan $selectedYear'
                          : 'Inflasi $currentMonthLabel $selectedYear',
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
                      'Persentase Month-to-Month',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: bpsTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Positif', bpsBlue, isSmallScreen),
              SizedBox(width: sizing.horizontalPadding),
              _buildLegendItem('Negatif (Deflasi)', bpsRed, isSmallScreen),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          SizedBox(
            height: isSmallScreen ? 180 : 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue,
                minY: minValue,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: isSmallScreen ? 30 : 35,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          NumberFormatUtils.formatPercentage(value),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: bpsTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (selectedMonth != null) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              months[selectedMonth!],
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 12,
                                color: bpsTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        } else {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                months[idx],
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 10 : 12,
                                  color: bpsTextPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.white,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final monthLabel = groupIndex < months.length ? months[groupIndex] : '';
                      final value = rod.toY;
                      final displayValue = NumberFormatUtils.formatPercentage(value);
                      return BarTooltipItem(
                        '$monthLabel',
                        const TextStyle(
                          color: bpsTextSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                        children: [
                          const TextSpan(text: '\n'),
                          TextSpan(
                            text: displayValue,
                            style: TextStyle(
                              color: value >= 0 ? bpsBlue : bpsRed,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(monthlyData.length, (index) {
                  final value = monthlyData[index];
                  final color = value >= 0 ? bpsBlue : bpsRed;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: color,
                        width: selectedMonth != null ? 25 : 10,
                        borderRadius: BorderRadius.circular(4),
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

  Widget _buildInflationComponents(
      ResponsiveSizing sizing, bool isSmallScreen) {
    final yearStr = selectedYear.toString();
    // Check if selected year has monthly component data
    final hasMonthlyData = inflationComponentsMonthly.values.any(
      (categoryData) => categoryData.containsKey(selectedYear),
    );

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
                Icons.category_rounded,
                color: bpsOrange,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  'Komponen Inflasi',
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? sizing.groupTitleSize - 2
                        : sizing.groupTitleSize,
                    fontWeight: FontWeight.w700,
                    color: bpsTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          // Month selector for 2023 data
          if (hasMonthlyData) ...[
            SizedBox(height: isSmallScreen ? 12 : 16),
            _buildComponentMonthSelector(sizing, isSmallScreen),
          ],
          SizedBox(height: isSmallScreen ? 12 : 16),
          ...inflationComponentsYearly.entries.map((entry) {
            final color = _getComponentColor(entry.key);
            double value;

            // Use monthly data if available and month selected
            if (hasMonthlyData && selectedComponentMonth != null) {
              final monthlyData =
                  inflationComponentsMonthly[entry.key]?[selectedYear];
              if (monthlyData != null &&
                  selectedComponentMonth! < monthlyData.length) {
                value = monthlyData[selectedComponentMonth!] ?? 0.0;
              } else {
                value = 0.0;
              }
            } else {
              // Use yearly data
              value = entry.value[yearStr] ?? 0.0;
            }

            return Padding(
              padding: EdgeInsets.only(bottom: sizing.itemSpacing),
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                decoration: BoxDecoration(
                  color: bpsBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: bpsBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getComponentIcon(entry.key),
                        color: color,
                        size: isSmallScreen ? 18 : 20,
                      ),
                    ),
                    SizedBox(width: sizing.itemSpacing),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w600,
                          color: bpsTextPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: sizing.itemSpacing),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sizing.itemSpacing,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        NumberFormatUtils.formatPercentage(value),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildComponentMonthSelector(
      ResponsiveSizing sizing, bool isSmallScreen) {
    // Determine available months based on data for selected year
    int availableMonths = 12;
    final firstCategory = inflationComponentsMonthly.entries.firstOrNull;
    if (firstCategory != null) {
      final yearData = firstCategory.value[selectedYear];
      if (yearData != null) {
        availableMonths = yearData.length;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              color: bpsTeal,
              size: isSmallScreen ? 14 : 16,
            ),
            SizedBox(width: sizing.itemSpacing - 4),
            Text(
              selectedComponentMonth == null
                  ? 'Data Tahunan (YoY)'
                  : 'Data Bulan: ${fullMonths[selectedComponentMonth!]} (MtM)',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: bpsTextSecondary,
              ),
            ),
            const Spacer(),
            if (selectedComponentMonth != null)
              Material(
                color: bpsTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: () => setState(() => selectedComponentMonth = null),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: sizing.itemSpacing - 4,
                      vertical: 2,
                    ),
                    child: Text(
                      'Tahunan',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 11,
                        color: bpsTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 8 : 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(availableMonths, (index) {
              final isSelected = selectedComponentMonth == index;
              return Padding(
                padding: EdgeInsets.only(right: sizing.itemSpacing - 4),
                child: Material(
                  color: isSelected ? bpsTeal : bpsBackground,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedComponentMonth = isSelected ? null : index;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: isSmallScreen ? 40 : 48,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 10,
                        vertical: isSmallScreen ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? bpsTeal : bpsBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        months[index],
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.white : bpsTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 12,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmallScreen ? 8 : 10,
            height: isSmallScreen ? 8 : 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isSmallScreen ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getComponentColor(String component) {
    switch (component) {
      case 'Makanan, Minuman & Tembakau':
        return bpsOrange;
      case 'Pakaian & Alas Kaki':
        return bpsPurple;
      case 'Perumahan & Fasilitas':
        return bpsBlue;
      case 'Perlengkapan Rumah Tangga':
        return const Color(0xFF795548);
      case 'Kesehatan':
        return bpsRed;
      case 'Transportasi':
        return bpsGreen;
      case 'Komunikasi & Keuangan':
        return const Color(0xFF3F51B5);
      case 'Rekreasi & Olahraga':
        return bpsTeal;
      case 'Pendidikan':
        return const Color(0xFFFF9800);
      case 'Restoran':
        return const Color(0xFFE91E63);
      case 'Perawatan Pribadi':
        return const Color(0xFF9C27B0);
      default:
        return bpsTextSecondary;
    }
  }

  IconData _getComponentIcon(String component) {
    switch (component) {
      case 'Makanan, Minuman & Tembakau':
        return Icons.restaurant_rounded;
      case 'Pakaian & Alas Kaki':
        return Icons.checkroom_rounded;
      case 'Perumahan & Fasilitas':
        return Icons.home_rounded;
      case 'Perlengkapan Rumah Tangga':
        return Icons.chair_rounded;
      case 'Kesehatan':
        return Icons.local_hospital_rounded;
      case 'Transportasi':
        return Icons.directions_car_rounded;
      case 'Komunikasi & Keuangan':
        return Icons.phone_iphone_rounded;
      case 'Rekreasi & Olahraga':
        return Icons.sports_soccer_rounded;
      case 'Pendidikan':
        return Icons.school_rounded;
      case 'Restoran':
        return Icons.food_bank_rounded;
      case 'Perawatan Pribadi':
        return Icons.spa_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildKesimpulanCard(ResponsiveSizing sizing, bool isSmallScreen) {
    final sortedYears = monthlyInflationData.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    if (sortedYears.length < 2) {
      return const SizedBox.shrink();
    }

    final latestYear = sortedYears.first;
    final firstYear = sortedYears.last;
    final latestData = monthlyInflationData[latestYear];
    final firstData = monthlyInflationData[firstYear];

    if (latestData == null ||
        firstData == null ||
        latestData.isEmpty ||
        firstData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate average inflation for each year
    double calculateAverage(List<double?> values) {
      final filtered = values.whereType<double>().toList();
      if (filtered.isEmpty) return 0.0;
      return filtered.reduce((a, b) => a + b) / filtered.length;
    }

    final latestInflasi = calculateAverage(latestData);
    final firstInflasi = calculateAverage(firstData);

    // Calculate overall average across all years
    double totalInflasi = 0;
    int count = 0;
    for (final year in sortedYears) {
      final data = monthlyInflationData[year];
      if (data != null && data.isNotEmpty) {
        totalInflasi += calculateAverage(data);
        count++;
      }
    }
    final averageInflasi = count > 0 ? totalInflasi / count : 0.0;

    final conclusionData = KesimpulanGenerator.generateInflasiConclusion(
      latestYear: latestYear,
      firstYear: firstYear,
      latestInflasi: latestInflasi,
      firstInflasi: firstInflasi,
      averageInflasi: averageInflasi,
    );

    return KesimpulanWidget(
      title: 'Inflasi Kota Semarang',
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
