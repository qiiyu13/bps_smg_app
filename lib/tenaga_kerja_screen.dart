import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'responsive_sizing.dart';

// BPS Color Palette (matching kemiskinana_screen.dart)
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

class TenagaKerjaScreen extends StatefulWidget {
  const TenagaKerjaScreen({super.key});

  @override
  _TenagaKerjaScreenState createState() => _TenagaKerjaScreenState();
}

class _TenagaKerjaScreenState extends State<TenagaKerjaScreen> with AutomaticKeepAliveClientMixin {
  int selectedYear = 2024;
  List<int> availableYears = [2020, 2021, 2022, 2023, 2024];
  int touchedIndex = -1;
  bool isLoading = true;

  Map<int, Map<String, dynamic>> yearData = {};
  Map<int, Map<String, dynamic>> indikatorData = {};
  Map<int, Map<String, double>> distribusiData = {};
  Map<int, Map<String, dynamic>> jatengData = {};
  
  int? touchedPieIndex;
  bool showRealValues = false;
  String? selectedSector;
  String? selectedSectorValue;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? savedYearData = prefs.getString('tenaga_kerja_year_data');
      if (savedYearData != null) {
        Map<String, dynamic> decoded = json.decode(savedYearData);
        yearData = decoded.map((key, value) =>
          MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map))
        );
      } else {
        _initializeDefaultYearData();
      }

      String? savedIndikatorData = prefs.getString('tenaga_kerja_indikator_data');
      if (savedIndikatorData != null) {
        Map<String, dynamic> decoded = json.decode(savedIndikatorData);
        indikatorData = decoded.map((key, value) =>
          MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map))
        );
      } else {
        _initializeDefaultIndikatorData();
      }

      String? savedDistribusiData = prefs.getString('tenaga_kerja_distribusi_data');
      if (savedDistribusiData != null) {
        Map<String, dynamic> decoded = json.decode(savedDistribusiData);
        distribusiData = decoded.map((key, value) =>
          MapEntry(int.parse(key), Map<String, double>.from(value as Map))
        );
      } else {
        _initializeDefaultDistribusiData();
      }

      String? savedJatengData = prefs.getString('tenaga_kerja_jateng_data');
      if (savedJatengData != null) {
        Map<String, dynamic> decoded = json.decode(savedJatengData);
        jatengData = decoded.map((key, value) =>
          MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map))
        );
      } else {
        _initializeDefaultJatengData();
      }

      setState(() {
        availableYears = yearData.keys.toList()..sort();
        if (availableYears.isNotEmpty && !availableYears.contains(selectedYear)) {
          selectedYear = availableYears.last;
        }
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      _initializeDefaultYearData();
      _initializeDefaultIndikatorData();
      _initializeDefaultDistribusiData();
      _initializeDefaultJatengData();
      setState(() {
        isLoading = false;
      });
    }
  }

  void _initializeDefaultYearData() {
    yearData = {
      2020: {'tpt': 8.45, 'tingkatPartisipasi': 67.8, 'bekerja': 856123, 'pengangguran': 78956},
      2021: {'tpt': 7.92, 'tingkatPartisipasi': 68.2, 'bekerja': 871245, 'pengangguran': 75234},
      2022: {'tpt': 7.15, 'tingkatPartisipasi': 69.1, 'bekerja': 889567, 'pengangguran': 68432},
      2023: {'tpt': 6.48, 'tingkatPartisipasi': 69.8, 'bekerja': 905678, 'pengangguran': 62789},
      2024: {'tpt': 5.82, 'tingkatPartisipasi': 70.5, 'bekerja': 922345, 'pengangguran': 57123},
    };
  }

  void _initializeDefaultIndikatorData() {
    indikatorData = {
      2020: {'angkatanKerja': 935079, 'bkbk': 421567, 'tingkatKesempatan': 91.55},
      2021: {'angkatanKerja': 946479, 'bkbk': 418234, 'tingkatKesempatan': 92.08},
      2022: {'angkatanKerja': 957999, 'bkbk': 415678, 'tingkatKesempatan': 92.85},
      2023: {'angkatanKerja': 968467, 'bkbk': 412345, 'tingkatKesempatan': 93.52},
      2024: {'angkatanKerja': 979468, 'bkbk': 408912, 'tingkatKesempatan': 94.18},
    };
  }

  void _initializeDefaultDistribusiData() {
    distribusiData = {
      2020: {'Pertanian': 12.5, 'Industri': 18.3, 'Perdagangan': 28.7, 'Jasa': 35.2, 'Lainnya': 5.3},
      2021: {'Pertanian': 11.8, 'Industri': 19.1, 'Perdagangan': 29.2, 'Jasa': 34.8, 'Lainnya': 5.1},
      2022: {'Pertanian': 11.2, 'Industri': 19.8, 'Perdagangan': 29.8, 'Jasa': 34.5, 'Lainnya': 4.7},
      2023: {'Pertanian': 10.5, 'Industri': 20.5, 'Perdagangan': 30.1, 'Jasa': 34.2, 'Lainnya': 4.7},
      2024: {'Pertanian': 9.8, 'Industri': 21.2, 'Perdagangan': 30.5, 'Jasa': 33.9, 'Lainnya': 4.6},
    };
  }

  void _initializeDefaultJatengData() {
    jatengData = {
      2020: {'tpt': 6.92, 'tingkatPartisipasi': 68.5},
      2021: {'tpt': 6.45, 'tingkatPartisipasi': 69.1},
      2022: {'tpt': 5.89, 'tingkatPartisipasi': 69.7},
      2023: {'tpt': 5.34, 'tingkatPartisipasi': 70.3},
      2024: {'tpt': 4.78, 'tingkatPartisipasi': 70.9},
    };
  }

  @override
  Widget build(BuildContext context) {
    final sizing = ResponsiveSizing(context);
    final isSmallScreen = sizing.isVerySmall || sizing.isSmall;

    if (isLoading) {
      return Scaffold(
        backgroundColor: _bpsBackground,
        body: Center(
          child: CircularProgressIndicator(color: _bpsBlue),
        ),
      );
    }

    if (availableYears.isEmpty || yearData.isEmpty) {
      return Scaffold(
        backgroundColor: _bpsBackground,
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
                        'Data tenaga kerja belum tersedia',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: sizing.categoryLabelFontSize,
                          color: _bpsTextSecondary,
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
      backgroundColor: _bpsBackground,
      body: Column(
        children: [
          _buildHeader(context, sizing, isSmallScreen),
          Expanded(
            child: CustomScrollView(
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
                      _buildDetailedIndicators(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildTPTChart(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildDistribusiChart(sizing, isSmallScreen),
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
        color: _bpsBlue,
        boxShadow: [
          BoxShadow(
            color: _bpsBlue.withOpacity(0.2),
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
                      'Data Tenaga Kerja',
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
                  Icons.work_rounded,
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
                  color: _bpsBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: _bpsBlue,
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
            children: availableYears.map((year) {
              final isSelected = year == selectedYear;
              return Material(
                color: isSelected ? _bpsBlue : _bpsBackground,
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
                        color: isSelected ? _bpsBlue : _bpsBorder,
                        width: isSelected ? 2 : 1.5,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: _bpsBlue.withOpacity(0.3),
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
    final data = yearData[selectedYear];
    if (data == null) return const SizedBox.shrink();

    final tpt = data['tpt'] ?? 0.0;
    final tingkatPartisipasi = data['tingkatPartisipasi'] ?? 0.0;
    final bekerja = data['bekerja'] ?? 0;
    final pengangguran = data['pengangguran'] ?? 0;

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
                  color: _bpsBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: _bpsBlue,
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  'Indikator Utama',
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
                    color: _bpsBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: _bpsBlue,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap untuk detail',
                        style: TextStyle(
                          fontSize: 12,
                          color: _bpsBlue,
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
                value: '${tpt.toStringAsFixed(2)}%',
                label: 'Tingkat Pengangguran Terbuka',
                color: _bpsBlue,
                icon: Icons.trending_down_rounded,
                description: 'TPT menunjukkan persentase angkatan kerja yang sedang mencari pekerjaan terhadap total angkatan kerja. Semakin rendah TPT, semakin baik kondisi ketenagakerjaan.',
                isFirst: true,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${tingkatPartisipasi.toStringAsFixed(2)}%',
                label: 'Tingkat Partisipasi Angkatan Kerja',
                color: _bpsGreen,
                icon: Icons.people_rounded,
                description: 'TPAK menggambarkan persentase penduduk usia kerja yang aktif secara ekonomi (bekerja atau mencari pekerjaan) terhadap total penduduk usia kerja.',
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: _formatNumber(bekerja),
                label: 'Jumlah Penduduk Bekerja',
                color: _bpsOrange,
                icon: Icons.work_rounded,
                description: 'Total penduduk yang bekerja, yaitu yang melakukan kegiatan ekonomi dengan maksud memperoleh atau membantu memperoleh pendapatan atau keuntungan.',
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: _formatNumber(pengangguran),
                label: 'Jumlah Pengangguran',
                color: _bpsRed,
                icon: Icons.group_off_rounded,
                description: 'Total penduduk yang sedang mencari pekerjaan, mempersiapkan usaha, tidak mencari pekerjaan karena merasa tidak mungkin mendapatkan pekerjaan, atau sudah punya pekerjaan tetapi belum mulai bekerja.',
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedIndicators(ResponsiveSizing sizing, bool isSmallScreen) {
    final data = indikatorData[selectedYear];
    if (data == null) return const SizedBox.shrink();

    final angkatanKerja = data['angkatanKerja'] ?? 0;
    final bkbk = data['bkbk'] ?? 0;
    final tingkatKesempatan = data['tingkatKesempatan'] ?? 0.0;

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
                  color: _bpsBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_rounded,
                  color: _bpsBlue,
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  'Indikator Tambahan',
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
                    color: _bpsBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: _bpsBlue,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap untuk detail',
                        style: TextStyle(
                          fontSize: 12,
                          color: _bpsBlue,
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
                value: _formatNumber(angkatanKerja),
                label: 'Angkatan Kerja',
                color: _bpsBlue,
                icon: Icons.groups_rounded,
                description: 'Total penduduk usia kerja (15 tahun ke atas) yang bekerja atau sedang mencari pekerjaan. Angkatan kerja adalah penjumlahan dari penduduk yang bekerja dan pengangguran.',
                isFirst: true,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: _formatNumber(bkbk),
                label: 'Bukan Angkatan Kerja',
                color: _bpsBlue,
                icon: Icons.people_outline_rounded,
                description: 'Penduduk usia kerja yang tidak bekerja dan tidak mencari pekerjaan. Termasuk di dalamnya adalah yang bersekolah, mengurus rumah tangga, pensiunan, dan lain-lain.',
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${tingkatKesempatan.toStringAsFixed(2)}%',
                label: 'Tingkat Kesempatan Kerja',
                color: _bpsBlue,
                icon: Icons.work_history_rounded,
                description: 'Persentase penduduk yang bekerja terhadap angkatan kerja. Indikator ini menunjukkan seberapa besar kesempatan kerja yang tersedia bagi angkatan kerja.',
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

  Widget _buildTPTChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final tptData = availableYears.map((year) {
      final data = yearData[year];
      return data?['tpt'] ?? 0.0;
    }).toList();

    final jatengTPTData = availableYears.map((year) {
      final data = jatengData[year];
      return data?['tpt'] ?? 0.0;
    }).toList();

    final maxY = ([...tptData, ...jatengTPTData].reduce((a, b) => a > b ? a : b) + 1).ceilToDouble();

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
                  color: _bpsBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.show_chart_rounded,
                  color: _bpsBlue,
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tren TPT Kota Semarang vs Jateng',
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
                      'Perbandingan Tingkat Pengangguran (%)',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: _bpsTextSecondary,
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
              _buildLegendItem('Kota Semarang', _bpsBlue, isSmallScreen),
              _buildLegendItem('Jawa Tengah', _bpsGreen, isSmallScreen),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          SizedBox(
            height: isSmallScreen ? 180 : 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: _bpsBorder,
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
                          '${value.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: _bpsTextSecondary,
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
                        if (index >= 0 && index < availableYears.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: isSmallScreen ? 6 : 8),
                            child: Text(
                              availableYears[index].toString(),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 12,
                                color: _bpsTextPrimary,
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
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (availableYears.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: tptData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    color: _bpsBlue,
                    barWidth: isSmallScreen ? 2.5 : 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: isSmallScreen ? 3 : 4,
                          color: _bpsBlue,
                          strokeWidth: isSmallScreen ? 1.5 : 2.5,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          _bpsBlue.withOpacity(0.15),
                          _bpsBlue.withOpacity(0.01),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: jatengTPTData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    color: _bpsGreen,
                    barWidth: isSmallScreen ? 2.5 : 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: isSmallScreen ? 3 : 4,
                          color: _bpsGreen,
                          strokeWidth: isSmallScreen ? 1.5 : 2.5,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          _bpsGreen.withOpacity(0.15),
                          _bpsGreen.withOpacity(0.01),
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

  Widget _buildDistribusiChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final data = distribusiData[selectedYear];
    if (data == null) return const SizedBox.shrink();

    // Get total workers for the selected year to calculate real values
    final yearInfo = yearData[selectedYear];
    final totalWorkers = yearInfo?['bekerja'] ?? 0;

    final sections = data.entries.map((entry) {
      final index = data.keys.toList().indexOf(entry.key);
      final isTouched = index == touchedPieIndex;
      final fontSize = isTouched ? (isSmallScreen ? 12.0 : 14.0) : (isSmallScreen ? 11.0 : 12.0);
      final radius = isTouched ? (isSmallScreen ? 65.0 : 75.0) : (isSmallScreen ? 55.0 : 65.0);
      
      // Calculate real value (number of workers) based on percentage
      final realValue = (totalWorkers * entry.value / 100).round();
      final displayTitle = (showRealValues && isTouched) 
          ? _formatCompactNumber(realValue)
          : '${entry.value.toStringAsFixed(1)}%';

      return PieChartSectionData(
        color: _getSectorColor(entry.key),
        value: entry.value,
        title: displayTitle,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    }).toList();

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: _bpsBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  color: _bpsBlue,
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Default state (visible when no sector selected)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: selectedSector == null ? 1.0 : 0.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Distribusi Lapangan Usaha',
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
                            'Persentase Tenaga Kerja per Sektor',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 13,
                              color: _bpsTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Selected state (visible when sector selected)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: selectedSector != null ? 1.0 : 0.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedSector != null 
                                ? '$selectedSector - $selectedSectorValue'
                                : '',
                            style: TextStyle(
                              fontSize: isSmallScreen
                                  ? sizing.groupTitleSize - 2
                                  : sizing.groupTitleSize,
                              fontWeight: FontWeight.w700,
                              color: selectedSector != null 
                                  ? _getSectorColor(selectedSector!)
                                  : _bpsTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tenaga kerja di sektor',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 13,
                              color: _bpsTextSecondary,
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
          SizedBox(height: isSmallScreen ? 12 : 16),
          SizedBox(
            height: isSmallScreen ? 180 : 220,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedPieIndex = null;
                        showRealValues = false;
                        selectedSector = null;
                        selectedSectorValue = null;
                        return;
                      }
                      touchedPieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      showRealValues = true;
                      // Update header with selected sector info
                      final sectorIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      if (sectorIndex >= 0 && sectorIndex < data.length) {
                        final sectorName = data.keys.toList()[sectorIndex];
                        final percentage = data.values.toList()[sectorIndex];
                        final realValue = (totalWorkers * percentage / 100).round();
                        selectedSector = sectorName;
                        selectedSectorValue = _formatCompactNumber(realValue);
                      } else {
                        selectedSector = null;
                        selectedSectorValue = null;
                      }
                    });
                  },
                  enabled: true,
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: isSmallScreen ? 20 : 30,
                sections: sections,
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Wrap(
            spacing: isSmallScreen ? 8 : 12,
            runSpacing: isSmallScreen ? 8 : 12,
            alignment: WrapAlignment.center,
            children: data.keys.map((sector) {
              return _buildLegendItem(
                sector,
                _getSectorColor(sector),
                isSmallScreen,
              );
            }).toList(),
          ),
        ],
      ),
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

  Color _getSectorColor(String sector) {
    switch (sector) {
      case 'Pertanian':
        return _bpsGreen;
      case 'Industri':
        return _bpsBlue;
      case 'Perdagangan':
        return _bpsOrange;
      case 'Jasa':
        return _bpsPurple;
      case 'Lainnya':
        return _bpsTeal;
      default:
        return _bpsTextSecondary;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatCompactNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
