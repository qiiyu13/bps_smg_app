import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'responsive_sizing.dart';

// BPS Color Palette (matching other screens)
const Color _bpsBlue = Color(0xFF2E99D6);
const Color _bpsOrange = Color(0xFFE88D34);
const Color _bpsGreen = Color(0xFF7DBD42);
const Color _bpsRed = Color(0xFFEF4444);
const Color _bpsBackground = Color(0xFFF5F5F5);
const Color _bpsCardBg = Color(0xFFFFFFFF);
const Color _bpsTextPrimary = Color(0xFF333333);
const Color _bpsTextSecondary = Color(0xFF808080);
const Color _bpsTextLabel = Color(0xFFA0A0A0);
const Color _bpsBorder = Color(0xFFE0E0E0);
const Color _bpsPurple = Color(0xFF7B1FA2);
const Color _bpsTeal = Color(0xFF1ABC9C);

class PendidikanScreen extends StatefulWidget {
  const PendidikanScreen({super.key});

  @override
  _PendidikanScreenState createState() => _PendidikanScreenState();
}

class _PendidikanScreenState extends State<PendidikanScreen> with AutomaticKeepAliveClientMixin {
  int selectedYear = 2024;
  bool isLoading = true;

  final List<int> years = [2020, 2021, 2022, 2023, 2024];

  // Data pendidikan per tahun (Data real Kota Semarang)
  Map<int, Map<String, dynamic>> educationData = {};

  Map<String, dynamic> get currentData => educationData[selectedYear]!;

  @override
  bool get wantKeepAlive => true;

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
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('pendidikan_data');

      if (mounted) {
        setState(() {
          if (savedData != null) {
            final decoded = json.decode(savedData) as Map<String, dynamic>;
            educationData = decoded.map((key, value) =>
              MapEntry(
                int.parse(key),
                Map<String, dynamic>.from(value as Map),
              ),
            );
          } else {
            educationData = _getDefaultData();
          }
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

  Map<int, Map<String, dynamic>> _getDefaultData() {
    return {
      2020: {
        'angkaMelekHuruf': 96.1,
        'rataRataLamaSekolah': 8.5,
        'harapanLamaSekolah': 12.9,
        'rasioGuruMurid': 16.1,
        'tingkatKelulusan': 98.3,
        'aksesPendidikanTinggi': 31.5,
        'jenjangPendidikan': [
          {'jenjang': 'TK', 'sekolah': 650, 'guru': 2200, 'murid': 28200},
          {'jenjang': 'RA', 'sekolah': 135, 'guru': 680, 'murid': 8600},
          {'jenjang': 'SD', 'sekolah': 490, 'guru': 6950, 'murid': 127800},
          {'jenjang': 'MI', 'sekolah': 88, 'guru': 1150, 'murid': 18700},
          {'jenjang': 'SMP', 'sekolah': 185, 'guru': 3700, 'murid': 62100},
          {'jenjang': 'MTs', 'sekolah': 38, 'guru': 800, 'murid': 9300},
          {'jenjang': 'SMA', 'sekolah': 72, 'guru': 1850, 'murid': 29600},
          {'jenjang': 'SMK', 'sekolah': 83, 'guru': 2400, 'murid': 37200},
          {'jenjang': 'MA', 'sekolah': 30, 'guru': 720, 'murid': 6400},
        ],
        'rasioData': [
          {'jenjang': 'TK/RA', 'rasioSekolahMurid': 43.4, 'rasioGuruMurid': 12.8},
          {'jenjang': 'SD/MI', 'rasioSekolahMurid': 260.8, 'rasioGuruMurid': 18.4},
          {'jenjang': 'SMP/MTs', 'rasioSekolahMurid': 335.7, 'rasioGuruMurid': 16.8},
          {'jenjang': 'SMA/SMK/MA', 'rasioSekolahMurid': 405.5, 'rasioGuruMurid': 16.3},
        ],
        'angkaPutusSekolah': [
          {'tingkat': 'SD', 'persentase': 0.7},
          {'tingkat': 'SMP', 'persentase': 1.2},
          {'tingkat': 'SMA', 'persentase': 2.5},
        ],
        'partisipasiPendidikan': [
          {'jenjang': 'SD/MI/Sederajat', 'apm': 99.60, 'apk': 102.57},
          {'jenjang': 'SMP/MTs/Sederajat', 'apm': 91.77, 'apk': 92.54},
          {'jenjang': 'SMA/SMK/MA/Sederajat', 'apm': 69.95, 'apk': 104.60},
        ],
      },
      2021: {
        'angkaMelekHuruf': 96.5,
        'rataRataLamaSekolah': 8.7,
        'harapanLamaSekolah': 13.1,
        'rasioGuruMurid': 15.36,
        'tingkatKelulusan': 98.6,
        'aksesPendidikanTinggi': 33.2,
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
          {'jenjang': 'TK/RA', 'rasioSekolahMurid': 46.91, 'rasioGuruMurid': 12.74},
          {'jenjang': 'SD/MI', 'rasioSekolahMurid': 251.84, 'rasioGuruMurid': 18.10},
          {'jenjang': 'SMP/MTs', 'rasioSekolahMurid': 316.15, 'rasioGuruMurid': 15.86},
          {'jenjang': 'SMA/SMK/MA', 'rasioSekolahMurid': 391.47, 'rasioGuruMurid': 14.75},
        ],
        'angkaPutusSekolah': [
          {'tingkat': 'SD', 'persentase': 0.6},
          {'tingkat': 'SMP', 'persentase': 1.0},
          {'tingkat': 'SMA', 'persentase': 2.2},
        ],
        'partisipasiPendidikan': [
          {'jenjang': 'SD/MI/Sederajat', 'apm': 99.70, 'apk': 102.80},
          {'jenjang': 'SMP/MTs/Sederajat', 'apm': 92.15, 'apk': 93.20},
          {'jenjang': 'SMA/SMK/MA/Sederajat', 'apm': 71.20, 'apk': 105.30},
        ],
      },
      2022: {
        'angkaMelekHuruf': 96.9,
        'rataRataLamaSekolah': 8.9,
        'harapanLamaSekolah': 13.3,
        'rasioGuruMurid': 15.36,
        'tingkatKelulusan': 98.9,
        'aksesPendidikanTinggi': 35.1,
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
          {'jenjang': 'TK/RA', 'rasioSekolahMurid': 46.91, 'rasioGuruMurid': 12.74},
          {'jenjang': 'SD/MI', 'rasioSekolahMurid': 251.84, 'rasioGuruMurid': 18.10},
          {'jenjang': 'SMP/MTs', 'rasioSekolahMurid': 316.15, 'rasioGuruMurid': 15.86},
          {'jenjang': 'SMA/SMK/MA', 'rasioSekolahMurid': 391.47, 'rasioGuruMurid': 14.75},
        ],
        'angkaPutusSekolah': [
          {'tingkat': 'SD', 'persentase': 0.5},
          {'tingkat': 'SMP', 'persentase': 0.9},
          {'tingkat': 'SMA', 'persentase': 1.9},
        ],
        'partisipasiPendidikan': [
          {'jenjang': 'SD/MI/Sederajat', 'apm': 99.80, 'apk': 103.00},
          {'jenjang': 'SMP/MTs/Sederajat', 'apm': 92.50, 'apk': 93.80},
          {'jenjang': 'SMA/SMK/MA/Sederajat', 'apm': 72.50, 'apk': 106.00},
        ],
      },
      2023: {
        'angkaMelekHuruf': 97.2,
        'rataRataLamaSekolah': 9.1,
        'harapanLamaSekolah': 13.5,
        'rasioGuruMurid': 15.4,
        'tingkatKelulusan': 99.1,
        'aksesPendidikanTinggi': 37.3,
        'jenjangPendidikan': [
          {'jenjang': 'TK', 'sekolah': 690, 'guru': 2380, 'murid': 29800},
          {'jenjang': 'RA', 'sekolah': 142, 'guru': 710, 'murid': 9000},
          {'jenjang': 'SD', 'sekolah': 512, 'guru': 7320, 'murid': 133200},
          {'jenjang': 'MI', 'sekolah': 95, 'guru': 1200, 'murid': 19800},
          {'jenjang': 'SMP', 'sekolah': 198, 'guru': 3950, 'murid': 65100},
          {'jenjang': 'MTs', 'sekolah': 43, 'guru': 850, 'murid': 9800},
          {'jenjang': 'SMA', 'sekolah': 78, 'guru': 1950, 'murid': 31500},
          {'jenjang': 'SMK', 'sekolah': 90, 'guru': 2550, 'murid': 39500},
          {'jenjang': 'MA', 'sekolah': 35, 'guru': 780, 'murid': 6800},
        ],
        'rasioData': [
          {'jenjang': 'TK/RA', 'rasioSekolahMurid': 43.2, 'rasioGuruMurid': 12.5},
          {'jenjang': 'SD/MI', 'rasioSekolahMurid': 260.2, 'rasioGuruMurid': 18.2},
          {'jenjang': 'SMP/MTs', 'rasioSekolahMurid': 328.8, 'rasioGuruMurid': 16.5},
          {'jenjang': 'SMA/SMK/MA', 'rasioSekolahMurid': 379.1, 'rasioGuruMurid': 14.9},
        ],
        'angkaPutusSekolah': [
          {'tingkat': 'SD', 'persentase': 0.4},
          {'tingkat': 'SMP', 'persentase': 0.8},
          {'tingkat': 'SMA', 'persentase': 1.7},
        ],
        'partisipasiPendidikan': [
          {'jenjang': 'SD/MI/Sederajat', 'apm': 99.85, 'apk': 103.20},
          {'jenjang': 'SMP/MTs/Sederajat', 'apm': 93.00, 'apk': 94.50},
          {'jenjang': 'SMA/SMK/MA/Sederajat', 'apm': 74.00, 'apk': 107.00},
        ],
      },
      2024: {
        'angkaMelekHuruf': 97.6,
        'rataRataLamaSekolah': 9.3,
        'harapanLamaSekolah': 13.7,
        'rasioGuruMurid': 15.0,
        'tingkatKelulusan': 99.3,
        'aksesPendidikanTinggi': 39.5,
        'jenjangPendidikan': [
          {'jenjang': 'TK', 'sekolah': 705, 'guru': 2450, 'murid': 30200},
          {'jenjang': 'RA', 'sekolah': 145, 'guru': 725, 'murid': 9200},
          {'jenjang': 'SD', 'sekolah': 515, 'guru': 7420, 'murid': 134000},
          {'jenjang': 'MI', 'sekolah': 98, 'guru': 1220, 'murid': 20000},
          {'jenjang': 'SMP', 'sekolah': 202, 'guru': 4020, 'murid': 65800},
          {'jenjang': 'MTs', 'sekolah': 45, 'guru': 870, 'murid': 10000},
          {'jenjang': 'SMA', 'sekolah': 80, 'guru': 2000, 'murid': 32000},
          {'jenjang': 'SMK', 'sekolah': 92, 'guru': 2600, 'murid': 40000},
          {'jenjang': 'MA', 'sekolah': 38, 'guru': 800, 'murid': 7000},
        ],
        'rasioData': [
          {'jenjang': 'TK/RA', 'rasioSekolahMurid': 42.8, 'rasioGuruMurid': 12.3},
          {'jenjang': 'SD/MI', 'rasioSekolahMurid': 260.2, 'rasioGuruMurid': 18.1},
          {'jenjang': 'SMP/MTs', 'rasioSekolahMurid': 325.7, 'rasioGuruMurid': 16.4},
          {'jenjang': 'SMA/SMK/MA', 'rasioSekolahMurid': 375.9, 'rasioGuruMurid': 14.7},
        ],
        'angkaPutusSekolah': [
          {'tingkat': 'SD', 'persentase': 0.3},
          {'tingkat': 'SMP', 'persentase': 0.7},
          {'tingkat': 'SMA', 'persentase': 1.5},
        ],
        'partisipasiPendidikan': [
          {'jenjang': 'SD/MI/Sederajat', 'apm': 99.90, 'apk': 103.50},
          {'jenjang': 'SMP/MTs/Sederajat', 'apm': 93.50, 'apk': 95.20},
          {'jenjang': 'SMA/SMK/MA/Sederajat', 'apm': 75.50, 'apk': 108.00},
        ],
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final sizing = ResponsiveSizing(context);
    final isSmallScreen = sizing.isVerySmall || sizing.isSmall;

    return Scaffold(
      backgroundColor: _bpsBackground,
      body: Column(
        children: [
          _buildHeader(context, sizing, isSmallScreen),
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: _bpsGreen),
                        SizedBox(height: sizing.sectionSpacing - 8),
                        Text(
                          'Memuat data pendidikan...',
                          style: TextStyle(
                            fontSize: sizing.categoryLabelFontSize,
                            color: _bpsTextSecondary,
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
                                color: _bpsTextLabel,
                              ),
                              SizedBox(height: sizing.sectionSpacing - 8),
                              Text(
                                'Belum Ada Data',
                                style: TextStyle(
                                  fontSize: sizing.sectionTitleSize,
                                  fontWeight: FontWeight.bold,
                                  color: _bpsTextPrimary,
                                ),
                              ),
                              SizedBox(height: sizing.itemSpacing),
                              Text(
                                'Data pendidikan belum tersedia',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: sizing.categoryLabelFontSize,
                                  color: _bpsTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : CustomScrollView(
                        physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.all(sizing.horizontalPadding),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                _buildYearSelector(sizing, isSmallScreen),
                                SizedBox(height: sizing.sectionSpacing),
                                _buildMainIndicators(sizing, isSmallScreen),
                                SizedBox(height: sizing.sectionSpacing),
                                _buildEducationLevelChart(sizing, isSmallScreen),
                                SizedBox(height: sizing.sectionSpacing),
                                _buildRasioChart(sizing, isSmallScreen),
                                SizedBox(height: sizing.sectionSpacing),
                                _buildPartisipasiChart(sizing, isSmallScreen),
                                SizedBox(height: sizing.sectionSpacing),
                                _buildDropoutRateCard(sizing, isSmallScreen),
                                SizedBox(height: sizing.sectionSpacing),
                                _buildAdditionalStats(sizing, isSmallScreen),
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

  Widget _buildHeader(BuildContext context, ResponsiveSizing sizing, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: _bpsGreen,
        boxShadow: [
          BoxShadow(
            color: _bpsGreen.withOpacity(0.2),
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
              Material(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
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
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Pendidikan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen
                            ? sizing.headerTitleSize - 2
                            : sizing.headerTitleSize,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    Text(
                      'Data Tahun $selectedYear',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isSmallScreen
                            ? sizing.headerSubtitleSize - 2
                            : sizing.headerSubtitleSize,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: isSmallScreen ? 20 : 24,
                ),
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
        color: _bpsCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bpsBorder, width: 1.5),
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
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: _bpsGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: _bpsGreen,
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
              SizedBox(width: sizing.itemSpacing),
              Text(
                'Pilih Tahun Data',
                style: TextStyle(
                  fontSize: isSmallScreen
                      ? sizing.groupTitleSize - 2
                      : sizing.groupTitleSize,
                  fontWeight: FontWeight.w700,
                  color: _bpsTextPrimary,
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
                color: isSelected ? _bpsGreen : _bpsBackground,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => setState(() => selectedYear = year),
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
                        color: isSelected ? _bpsGreen : _bpsBorder,
                        width: isSelected ? 2 : 1.5,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: _bpsGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Text(
                      year.toString(),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : _bpsTextSecondary,
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
        color: _bpsCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bpsBorder, width: 1.5),
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
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: _bpsGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: _bpsGreen,
                  size: isSmallScreen ? 16 : 20,
                ),
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
                    color: _bpsTextPrimary,
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
                    color: _bpsGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: _bpsGreen,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap untuk detail',
                        style: TextStyle(
                          fontSize: 12,
                          color: _bpsGreen,
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
                value: '${(getTotalMurid(selectedYear) / 1000).toStringAsFixed(1)}k',
                label: 'Total Murid',
                color: _bpsGreen,
                icon: Icons.groups,
                description: 'Total jumlah murid di seluruh jenjang pendidikan di Kota Semarang, mencakup TK, RA, SD, MI, SMP, MTs, SMA, SMK, dan MA.',
                isFirst: true,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${currentData['angkaMelekHuruf']}%',
                label: 'Angka Melek Huruf',
                color: _bpsGreen,
                icon: Icons.menu_book,
                description: 'Angka Melek Huruf (AMH) menunjukkan persentase penduduk usia 15 tahun ke atas yang mampu membaca dan menulis huruf latin atau huruf lainnya.',
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${currentData['rataRataLamaSekolah']} th',
                label: 'Rata-rata Lama Sekolah',
                color: _bpsOrange,
                icon: Icons.timer,
                description: 'Rata-rata Lama Sekolah (RLS) menunjukkan jumlah tahun rata-rata yang dihabiskan oleh penduduk usia 25 tahun ke atas untuk menempuh pendidikan formal.',
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${currentData['tingkatKelulusan']}%',
                label: 'Angka Kelulusan',
                color: _bpsGreen,
                icon: Icons.emoji_events,
                description: 'Angka Kelulusan menunjukkan persentase siswa yang berhasil menyelesaikan pendidikan pada jenjang tertentu dalam satu tahun ajaran.',
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
        onTap: () => _showDetailDialog(context, label, value, icon, color, description),
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
                    color: _bpsTextPrimary,
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
                    color: _bpsTextPrimary,
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
        color: _bpsBorder.withOpacity(0.5),
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
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: isSmallScreen ? 20 : 24,
                        ),
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
                      Material(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
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
                                  color: _bpsTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 8 : 12),
                              Text(
                                value,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 28 : 32,
                                  fontWeight: FontWeight.w800,
                                  color: _bpsTextPrimary,
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
                            color: _bpsBackground,
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
                                        color: _bpsTextSecondary,
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

  Widget _buildEducationLevelChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final data = currentData['jenjangPendidikan'] as List;
    final colors = [
      _bpsBlue,
      _bpsBlue.withOpacity(0.7),
      _bpsGreen,
      _bpsGreen.withOpacity(0.7),
      _bpsOrange,
      _bpsOrange.withOpacity(0.7),
      _bpsRed,
      _bpsRed.withOpacity(0.7),
      _bpsBlue.withOpacity(0.5),
    ];

    return Container(
      padding: EdgeInsets.all(isSmallScreen
          ? sizing.statsCardPadding - 4
          : sizing.statsCardPadding),
      decoration: BoxDecoration(
        color: _bpsCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bpsBorder, width: 1.5),
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
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: _bpsGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: _bpsGreen,
                  size: isSmallScreen ? 16 : 20,
                ),
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
                        color: _bpsTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tahun $selectedYear',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: _bpsTextSecondary,
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
                      String jenjang = data[groupIndex]['jenjang'] ?? '';
                      String jumlah = (rod.toY / 1000).toStringAsFixed(1);
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
                              data[value.toInt()]['jenjang'] ?? '',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 9 : 10,
                                fontWeight: FontWeight.w600,
                                color: _bpsTextPrimary,
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
                            color: _bpsTextSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 40000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: _bpsBorder, strokeWidth: 1);
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
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
            color: _bpsCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _bpsBorder, width: 1.5),
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
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                    decoration: BoxDecoration(
                      color: _bpsOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.bar_chart,
                      color: _bpsOrange,
                      size: isSmallScreen ? 16 : 20,
                    ),
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
                            color: _bpsTextPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tahun $selectedYear',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            color: _bpsTextSecondary,
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
                          String jenjang = rasioData[groupIndex]['jenjang']?.toString() ?? '';
                          String rasio = rod.toY.toStringAsFixed(1);
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
                                    color: _bpsTextPrimary,
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
                                color: _bpsTextSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 100,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(color: _bpsBorder, strokeWidth: 1);
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
                            color: _bpsOrange,
                            width: isSmallScreen ? 20 : 28,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
            color: _bpsCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _bpsBorder, width: 1.5),
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
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                    decoration: BoxDecoration(
                      color: _bpsGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.people,
                      color: _bpsGreen,
                      size: isSmallScreen ? 16 : 20,
                    ),
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
                            color: _bpsTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tahun $selectedYear',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            color: _bpsTextSecondary,
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
                        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: _bpsBorder.withOpacity(0.5),
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
                              color: _bpsGreen,
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
                                color: _bpsTextPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '1 : ${rasioGuru.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 15 : 17,
                              fontWeight: FontWeight.w800,
                              color: _bpsTextPrimary,
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
        color: _bpsCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bpsBorder, width: 1.5),
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
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: _bpsGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: _bpsGreen,
                  size: isSmallScreen ? 16 : 20,
                ),
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
                        color: _bpsTextPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tahun $selectedYear',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: _bpsTextSecondary,
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
              _buildLegendItem('APM', _bpsGreen, isSmallScreen),
              _buildLegendItem('APK', _bpsBlue, isSmallScreen),
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
                      String jenjang = partisipasiData[groupIndex]['jenjang']?.toString() ?? '';
                      String label = rodIndex == 0 ? 'APM' : 'APK';
                      String nilai = rod.toY.toStringAsFixed(2);
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
                          String jenjang = partisipasiData[index]['jenjang']?.toString() ?? '';
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
                                color: _bpsTextPrimary,
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
                            color: _bpsTextSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: _bpsBorder, strokeWidth: 1);
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
                        color: _bpsGreen,
                        width: isSmallScreen ? 14 : 18,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: apk,
                        color: _bpsBlue,
                        width: isSmallScreen ? 14 : 18,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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

  Widget _buildDropoutRateCard(ResponsiveSizing sizing, bool isSmallScreen) {
    final dropoutData = currentData['angkaPutusSekolah'] as List;

    return Container(
      padding: EdgeInsets.all(isSmallScreen
          ? sizing.statsCardPadding - 4
          : sizing.statsCardPadding),
      decoration: BoxDecoration(
        color: _bpsCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bpsBorder, width: 1.5),
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
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: _bpsRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_down,
                  color: _bpsRed,
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Angka Putus Sekolah',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? sizing.groupTitleSize - 2
                            : sizing.groupTitleSize,
                        fontWeight: FontWeight.w700,
                        color: _bpsTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tahun $selectedYear',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: _bpsTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          ...dropoutData.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['tingkat'],
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 13,
                          fontWeight: FontWeight.w600,
                          color: _bpsTextPrimary,
                        ),
                      ),
                      Text(
                        '${item['persentase']}%',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 13,
                          fontWeight: FontWeight.bold,
                          color: _bpsTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: item['persentase'] / 5,
                      minHeight: 7,
                      backgroundColor: _bpsBorder,
                      valueColor: AlwaysStoppedAnimation<Color>(_bpsRed),
                    ),
                  ),
                ],
              ),
            );
          }),
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
        color: _bpsCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bpsBorder, width: 1.5),
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
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: _bpsGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: _bpsGreen,
                  size: isSmallScreen ? 16 : 20,
                ),
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
                    color: _bpsTextPrimary,
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
                    color: _bpsGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: _bpsGreen,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap untuk detail',
                        style: TextStyle(
                          fontSize: 12,
                          color: _bpsGreen,
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
                color: _bpsGreen,
                icon: Icons.people,
                description: 'Rasio Guru terhadap Murid menunjukkan perbandingan jumlah guru dengan jumlah murid di seluruh jenjang pendidikan. Semakin kecil rasio, semakin ideal kondisi pembelajaran.',
                isFirst: true,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${currentData['harapanLamaSekolah']} tahun',
                label: 'Harapan Lama Sekolah',
                color: _bpsGreen,
                icon: Icons.school,
                description: 'Harapan Lama Sekolah (HLS) menunjukkan lamanya sekolah (dalam tahun) yang diharapkan akan dirasakan oleh anak pada umur tertentu di masa mendatang.',
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${currentData['aksesPendidikanTinggi']}%',
                label: 'Akses Pendidikan Tinggi',
                color: _bpsOrange,
                icon: Icons.business,
                description: 'Akses Pendidikan Tinggi menunjukkan persentase penduduk yang memiliki akses dan kesempatan untuk melanjutkan pendidikan ke jenjang perguruan tinggi.',
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
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 12, vertical: isSmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: isSmallScreen ? 8 : 10, height: isSmallScreen ? 8 : 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: isSmallScreen ? 4 : 6),
        Text(label, style: TextStyle(fontSize: isSmallScreen ? 12 : 13, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
