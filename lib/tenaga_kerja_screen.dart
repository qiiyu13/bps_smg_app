import 'package:lawang/number_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'services/github_data_service.dart';
import 'responsive_sizing.dart';
import 'kesimpulan_widget.dart';
import 'dart:async';
import 'app_theme.dart';

class TenagaKerjaScreen extends StatefulWidget {
  const TenagaKerjaScreen({super.key});

  @override
  _TenagaKerjaScreenState createState() => _TenagaKerjaScreenState();
}

class _TenagaKerjaScreenState extends State<TenagaKerjaScreen>
    with AutomaticKeepAliveClientMixin {
  int selectedYear = 2024;
  List<int> availableYears = [2024, 2023, 2022, 2021, 2020];
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
  late Timer _debounceTimer;
  final ScrollController _yearScrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_yearScrollController.hasClients) {
        _yearScrollController.jumpTo(
          _yearScrollController.position.maxScrollExtent,
        );
      }
    });
    _loadData();
  }

  @override
  void dispose() {
    _debounceTimer.cancel();
    _yearScrollController.dispose();
    super.dispose();
  }

  void _changeYear(int year) {
    _debounceTimer.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() => selectedYear = year);
      }
    });
  }

  Future<void> _loadData() async {
    try {
      final githubData = GitHubDataService.getData('tenaga_kerja');
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // --- Year data ---
      final yearSection = githubData?['yearData'] as Map<String, dynamic>?;
      if (yearSection != null) {
        yearData = yearSection.map((key, value) =>
            MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));
        await prefs.setString('tenaga_kerja_year_data', json.encode(yearSection));
      } else {
        String? savedYearData = prefs.getString('tenaga_kerja_year_data');
        if (savedYearData != null) {
          final decoded = json.decode(savedYearData) as Map<String, dynamic>;
          yearData = decoded.map((key, value) =>
              MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));
        } else {
          _initializeDefaultYearData();
        }
      }

      // --- Indikator data ---
      final indikatorSection = githubData?['indikatorData'] as Map<String, dynamic>?;
      if (indikatorSection != null) {
        indikatorData = indikatorSection.map((key, value) =>
            MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));
        await prefs.setString('tenaga_kerja_indikator_data', json.encode(indikatorSection));
      } else {
        String? savedIndikatorData = prefs.getString('tenaga_kerja_indikator_data');
        if (savedIndikatorData != null) {
          final decoded = json.decode(savedIndikatorData) as Map<String, dynamic>;
          indikatorData = decoded.map((key, value) =>
              MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));
        } else {
          _initializeDefaultIndikatorData();
        }
      }

      // --- Distribusi data ---
      final distribusiSection = githubData?['distribusiData'] as Map<String, dynamic>?;
      if (distribusiSection != null) {
        distribusiData = distribusiSection.map((key, value) =>
            MapEntry(int.parse(key), Map<String, double>.from(
              (value as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())),
            )));
        await prefs.setString('tenaga_kerja_distribusi_data', json.encode(distribusiSection));
      } else {
        String? savedDistribusiData = prefs.getString('tenaga_kerja_distribusi_data');
        if (savedDistribusiData != null) {
          final decoded = json.decode(savedDistribusiData) as Map<String, dynamic>;
          distribusiData = decoded.map((key, value) =>
              MapEntry(int.parse(key), Map<String, double>.from(value as Map)));
        } else {
          _initializeDefaultDistribusiData();
        }
      }

      // --- Jateng data ---
      final jatengSection = githubData?['jatengData'] as Map<String, dynamic>?;
      if (jatengSection != null) {
        jatengData = jatengSection.map((key, value) =>
            MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));
        await prefs.setString('tenaga_kerja_jateng_data', json.encode(jatengSection));
      } else {
        String? savedJatengData = prefs.getString('tenaga_kerja_jateng_data');
        if (savedJatengData != null) {
          final decoded = json.decode(savedJatengData) as Map<String, dynamic>;
          jatengData = decoded.map((key, value) =>
              MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));
        } else {
          _initializeDefaultJatengData();
        }
      }

      setState(() {
        availableYears = yearData.keys.toList()..sort((a, b) => a.compareTo(b));
        if (availableYears.isNotEmpty) {
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
        availableYears = yearData.keys.toList()..sort((a, b) => a.compareTo(b));
        if (availableYears.isNotEmpty) {
          selectedYear = availableYears.last;
        }
        isLoading = false;
      });
    }
  }

  void _initializeDefaultYearData() {
    yearData = {
      2020: {
        'tpt': 9.57,
        'tingkatPartisipasi': 69.89,
        'bekerja': 856123,
        'pengangguran': 78956
      },
      2021: {
        'tpt': 9.54,
        'tingkatPartisipasi': 69.41,
        'bekerja': 871245,
        'pengangguran': 75234
      },
      2022: {
        'tpt': 7.60,
        'tingkatPartisipasi': 70.96,
        'bekerja': 889567,
        'pengangguran': 68432
      },
      2023: {
        'tpt': 5.99,
        'tingkatPartisipasi': 69.42,
        'bekerja': 905678,
        'pengangguran': 62789
      },
      2024: {
        'tpt': 5.82,
        'tingkatPartisipasi': 69.88,
        'bekerja': 922345,
        'pengangguran': 57123
      },
      2025: {
        'tpt': 5.65,
        'tingkatPartisipasi': 72.60,
        'bekerja': 938766,
        'pengangguran': 56228
      },
    };
  }

  void _initializeDefaultIndikatorData() {
    indikatorData = {
      2020: {
        'angkatanKerja': 935079,
        'bkbk': 421567,
        'tingkatKesempatan': 91.55
      },
      2021: {
        'angkatanKerja': 946479,
        'bkbk': 418234,
        'tingkatKesempatan': 92.08
      },
      2022: {
        'angkatanKerja': 957999,
        'bkbk': 415678,
        'tingkatKesempatan': 92.85
      },
      2023: {
        'angkatanKerja': 968467,
        'bkbk': 412345,
        'tingkatKesempatan': 93.52
      },
      2024: {
        'angkatanKerja': 979468,
        'bkbk': 408912,
        'tingkatKesempatan': 94.18
      },
      2025: {
        'angkatanKerja': 994994,
        'bkbk': 938766,
        'tingkatKesempatan': 94.35
      },
    };
  }

  void _initializeDefaultDistribusiData() {
    distribusiData = {
      2020: {'Pertanian': 2.00, 'Manufaktur': 26.00, 'Jasa': 73.00},
      2021: {'Pertanian': 2.00, 'Manufaktur': 26.00, 'Jasa': 72.00},
      2022: {'Pertanian': 1.00, 'Manufaktur': 28.00, 'Jasa': 70.00},
      2023: {'Pertanian': 2.00, 'Manufaktur': 26.00, 'Jasa': 72.00},
      2024: {'Pertanian': 2.00, 'Manufaktur': 28.00, 'Jasa': 70.00},
      2025: {'Pertanian': 2.00, 'Manufaktur': 28.00, 'Jasa': 70.00},
    };
  }

  void _initializeDefaultJatengData() {
    jatengData = {
      2020: {'tpt': 6.48, 'tingkatPartisipasi': 68.5},
      2021: {'tpt': 5.95, 'tingkatPartisipasi': 69.1},
      2022: {'tpt': 5.57, 'tingkatPartisipasi': 69.7},
      2023: {'tpt': 5.13, 'tingkatPartisipasi': 70.3},
      2024: {'tpt': 4.78, 'tingkatPartisipasi': 70.9},
      2025: {'tpt': 4.76, 'tingkatPartisipasi': 71.5},
    };
  }

  @override
  Widget build(BuildContext context) {
    final sizing = ResponsiveSizing(context);
    final isSmallScreen = sizing.isVerySmall || sizing.isSmall;

    if (isLoading) {
      return Scaffold(
        backgroundColor: bpsBackground,
        body: Center(
          child: CircularProgressIndicator(color: bpsBlue),
        ),
      );
    }

    if (availableYears.isEmpty || yearData.isEmpty) {
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
                        'Data tenaga kerja belum tersedia',
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
                      _buildMainIndicators(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildDetailedIndicators(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildTPTChart(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildDistribusiChart(sizing, isSmallScreen),
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
                  'Data Tenaga Kerja',
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
                Icons.work_rounded,
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
          SizedBox(
            height: isSmallScreen ? 38 : 42,
            child: ListView.separated(
              controller: _yearScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: availableYears.length,
              separatorBuilder: (_, __) =>
                  SizedBox(width: isSmallScreen ? 6 : 8),
              itemBuilder: (_, i) {
                final year = availableYears[i];
                final isSelected = year == selectedYear;
                return Material(
                  color: isSelected ? bpsBlue : bpsBackground,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => _changeYear(year),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 20,
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
                      ),
                    ),
                  ),
                );
              },
            ),
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
                  'Indikator Utama',
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
                value: NumberFormatUtils.formatPercentage(tpt),
                label: 'Tingkat Pengangguran Terbuka',
                color: bpsBlue,
                icon: Icons.trending_down_rounded,
                description:
                    'TPT menunjukkan persentase angkatan kerja yang sedang mencari pekerjaan terhadap total angkatan kerja. Semakin rendah TPT, semakin baik kondisi ketenagakerjaan.',
                isFirst: true,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: NumberFormatUtils.formatPercentage(tingkatPartisipasi),
                label: 'Tingkat Partisipasi Angkatan Kerja',
                color: bpsGreen,
                icon: Icons.people_rounded,
                description:
                    'TPAK menggambarkan persentase penduduk usia kerja yang aktif secara ekonomi (bekerja atau mencari pekerjaan) terhadap total penduduk usia kerja.',
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: _formatNumber(bekerja),
                label: 'Jumlah Penduduk Bekerja',
                color: bpsOrange,
                icon: Icons.work_rounded,
                description:
                    'Total penduduk yang bekerja, yaitu yang melakukan kegiatan ekonomi dengan maksud memperoleh atau membantu memperoleh pendapatan atau keuntungan.',
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: _formatNumber(pengangguran),
                label: 'Jumlah Pengangguran',
                color: bpsRed,
                icon: Icons.group_off_rounded,
                description:
                    'Total penduduk yang sedang mencari pekerjaan, mempersiapkan usaha, tidak mencari pekerjaan karena merasa tidak mungkin mendapatkan pekerjaan, atau sudah punya pekerjaan tetapi belum mulai bekerja.',
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
                Icons.info_rounded,
                color: bpsBlue,
                size: isSmallScreen ? 16 : 20,
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
                value: _formatNumber(angkatanKerja),
                label: 'Angkatan Kerja',
                color: bpsBlue,
                icon: Icons.groups_rounded,
                description:
                    'Total penduduk usia kerja (15 tahun ke atas) yang bekerja atau sedang mencari pekerjaan. Angkatan kerja adalah penjumlahan dari penduduk yang bekerja dan pengangguran.',
                isFirst: true,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: _formatNumber(bkbk),
                label: 'Bukan Angkatan Kerja',
                color: bpsBlue,
                icon: Icons.people_outline_rounded,
                description:
                    'Penduduk usia kerja yang tidak bekerja dan tidak mencari pekerjaan. Termasuk di dalamnya adalah yang bersekolah, mengurus rumah tangga, pensiunan, dan lain-lain.',
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: NumberFormatUtils.formatPercentage(tingkatKesempatan),
                label: 'Tingkat Kesempatan Kerja',
                color: bpsBlue,
                icon: Icons.work_history_rounded,
                description:
                    'Persentase penduduk yang bekerja terhadap angkatan kerja. Indikator ini menunjukkan seberapa besar kesempatan kerja yang tersedia bagi angkatan kerja.',
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

  Widget _buildTPTChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final tptData = availableYears.map((year) {
      final data = yearData[year];
      return data?['tpt'] ?? 0.0;
    }).toList();

    final jatengTPTData = availableYears.map((year) {
      final data = jatengData[year];
      return data?['tpt'] ?? 0.0;
    }).toList();

    final maxY =
        ([...tptData, ...jatengTPTData].reduce((a, b) => a > b ? a : b) + 1)
            .ceilToDouble();

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
                      'Tren TPT Kota Semarang vs Jateng',
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
                      'Perbandingan Tingkat Pengangguran (%)',
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
          Wrap(
            spacing: isSmallScreen ? 8 : 12,
            runSpacing: isSmallScreen ? 8 : 12,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem('Kota Semarang', bpsBlue, isSmallScreen),
              _buildLegendItem('Jawa Tengah', bpsGreen, isSmallScreen),
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
                        if (index >= 0 && index < availableYears.length) {
                          return Padding(
                            padding:
                                EdgeInsets.only(top: isSmallScreen ? 6 : 8),
                            child: Text(
                              availableYears[index].toString(),
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
                        final year = availableYears[spot.x.toInt()];
                        final label = spot.barIndex == 0 ? 'Semarang' : 'Jawa Tengah';
                        return LineTooltipItem(
                          '$label ($year)',
                          const TextStyle(
                            color: bpsTextSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                          children: [
                            const TextSpan(text: '\n'),
                            TextSpan(
                              text: '${NumberFormatUtils.formatValue(spot.y, decimalPlaces: 2)}%',
                              style: TextStyle(
                                color: spot.barIndex == 0 ? bpsBlue : bpsGreen,
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
                maxX: (availableYears.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: tptData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    color: bpsBlue,
                    barWidth: isSmallScreen ? 2.5 : 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: isSmallScreen ? 3 : 4,
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
                          bpsBlue.withOpacity(0.15),
                          bpsBlue.withOpacity(0.01),
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
                    color: bpsGreen,
                    barWidth: isSmallScreen ? 2.5 : 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: isSmallScreen ? 3 : 4,
                          color: bpsGreen,
                          strokeWidth: isSmallScreen ? 1.5 : 2.5,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          bpsGreen.withOpacity(0.15),
                          bpsGreen.withOpacity(0.01),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: bpsBlue,
                size: isSmallScreen ? 16 : 20,
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
                              color: bpsTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Persentase Tenaga Kerja per Sektor',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 13,
                              color: bpsTextSecondary,
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
                                  : bpsTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tenaga kerja di sektor',
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
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          // Horizontal Bar Chart
          SizedBox(
            height: isSmallScreen ? 140 : 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        touchedPieIndex = null;
                        showRealValues = false;
                        selectedSector = null;
                        selectedSectorValue = null;
                        return;
                      }
                      touchedPieIndex =
                          barTouchResponse.spot!.touchedBarGroupIndex;
                      showRealValues = true;
                      final sectorIndex =
                          barTouchResponse.spot!.touchedBarGroupIndex;
                      if (sectorIndex >= 0 && sectorIndex < data.length) {
                        final sectorName = data.keys.toList()[sectorIndex];
                        final percentage = data.values.toList()[sectorIndex];
                        final realValue =
                            (totalWorkers * percentage / 100).round();
                        selectedSector = sectorName;
                        selectedSectorValue = _formatCompactNumber(realValue);
                      } else {
                        selectedSector = null;
                        selectedSectorValue = null;
                      }
                    });
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.white,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final sectorName = data.keys.toList()[groupIndex];
                      final percentage = data.values.toList()[groupIndex];
                      final realValue = (totalWorkers * percentage / 100).round();
                      return BarTooltipItem(
                        '$sectorName\n',
                        TextStyle(
                          color: bpsTextPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                        children: [
                          TextSpan(
                            text: '${NumberFormatUtils.formatValue(percentage, decimalPlaces: 1)}%\n',
                            style: TextStyle(
                              color: bpsTextPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          TextSpan(
                            text: _formatCompactNumber(realValue),
                            style: TextStyle(
                              color: bpsTextSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 10 : 12,
                            ),
                          ),
                        ],
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
                        if (index >= 0 && index < data.length) {
                          final sectorName = data.keys.toList()[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              sectorName,
                              style: TextStyle(
                                color: bpsTextSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 11 : 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: isSmallScreen ? 30 : 35,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: isSmallScreen ? 35 : 40,
                      interval: 25,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: TextStyle(
                            color: bpsTextLabel,
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen ? 10 : 11,
                          ),
                        );
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
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: bpsBorder,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.entries.map((entry) {
                  final index = data.keys.toList().indexOf(entry.key);
                  final isTouched = index == touchedPieIndex;
                  final color = _getSectorColor(entry.key);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: isTouched ? color.withOpacity(0.8) : color,
                        width: isSmallScreen ? 35 : 50,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100,
                          color: bpsBorder.withOpacity(0.3),
                        ),
                      ),
                    ],
                    showingTooltipIndicators: isTouched ? [0] : [],
                  );
                }).toList(),
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
        return bpsGreen;
      case 'Manufaktur':
        return bpsBlue;
      case 'Jasa':
        return bpsPurple;
      default:
        return bpsTextSecondary;
    }
  }

  String _formatNumber(int number) {
    return NumberFormatUtils.formatCompact(number);
  }

  String _formatCompactNumber(int number) {
    return NumberFormatUtils.formatCompact(number);
  }

  Widget _buildKesimpulanCard(ResponsiveSizing sizing, bool isSmallScreen) {
    if (yearData.isEmpty ||
        indikatorData.isEmpty ||
        availableYears.length < 2) {
      return const SizedBox.shrink();
    }

    final sortedYears = availableYears..sort((a, b) => a.compareTo(b));
    final latestYear = sortedYears.last;
    final firstYear = sortedYears.first;

    final latestIndikator = indikatorData[latestYear];
    final firstIndikator = indikatorData[firstYear];

    if (latestIndikator == null || firstIndikator == null) {
      return const SizedBox.shrink();
    }

    // Get TPT (Tingkat Pengangguran Terbuka) values
    final latestTPT = (latestIndikator['tpt'] as num?)?.toDouble() ?? 0.0;
    final firstTPT = (firstIndikator['tpt'] as num?)?.toDouble() ?? 0.0;

    // Get participation rate
    final latestParticipation =
        (latestIndikator['partisipasi'] as num?)?.toDouble() ?? 0.0;

    final conclusionData = KesimpulanGenerator.generateTenagaKerjaConclusion(
      latestYear: latestYear,
      firstYear: firstYear,
      latestUnemployment: latestTPT,
      firstUnemployment: firstTPT,
      participationRate: latestParticipation,
    );

    return KesimpulanWidget(
      title: 'Tenaga Kerja Kota Semarang',
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
