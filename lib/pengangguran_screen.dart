import 'package:lawang/number_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'responsive_sizing.dart';
import 'number_format_utils.dart';
import 'kesimpulan_widget.dart';

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

class PengangguranData {
  final int year;
  final double tptSemarang;
  final double tpakSemarang;
  final double tptJateng;
  final double tpakJateng;
  final double tptNasional;
  final double tpakNasional;

  PengangguranData({
    required this.year,
    required this.tptSemarang,
    required this.tpakSemarang,
    required this.tptJateng,
    required this.tpakJateng,
    required this.tptNasional,
    required this.tpakNasional,
  });

  factory PengangguranData.fromMap(int year, Map<String, dynamic> map) {
    return PengangguranData(
      year: year,
      tptSemarang: (map['tptSemarang'] as num?)?.toDouble() ?? 0.0,
      tpakSemarang: (map['tpakSemarang'] as num?)?.toDouble() ?? 0.0,
      tptJateng: (map['tptJateng'] as num?)?.toDouble() ?? 0.0,
      tpakJateng: (map['tpakJateng'] as num?)?.toDouble() ?? 0.0,
      tptNasional: (map['tptNasional'] as num?)?.toDouble() ?? 0.0,
      tpakNasional: (map['tpakNasional'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tptSemarang': tptSemarang,
      'tpakSemarang': tpakSemarang,
      'tptJateng': tptJateng,
      'tpakJateng': tpakJateng,
      'tptNasional': tptNasional,
      'tpakNasional': tpakNasional,
    };
  }
}

class PengangguranScreen extends StatefulWidget {
  const PengangguranScreen({super.key});

  @override
  State<PengangguranScreen> createState() => _PengangguranScreenState();
}

class _PengangguranScreenState extends State<PengangguranScreen>
    with AutomaticKeepAliveClientMixin {
  int selectedYear = 2024;
  List<int> availableYears = [2025, 2024, 2023, 2022, 2021, 2020];
  Map<int, PengangguranData> yearlyData = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('pengangguran_data');

      if (mounted) {
        setState(() {
          if (savedData != null) {
            final decoded = json.decode(savedData) as Map<String, dynamic>;
            yearlyData = decoded.map(
              (key, value) => MapEntry(
                int.parse(key),
                PengangguranData.fromMap(
                    int.parse(key), Map<String, dynamic>.from(value as Map)),
              ),
            );
          } else {
            yearlyData = _getDefaultData();
          }
          availableYears = yearlyData.keys.toList()
            ..sort((a, b) => a.compareTo(b));
          selectedYear = availableYears.isNotEmpty ? availableYears.last : 2024;
          errorMessage = null;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Gagal memuat data: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  Map<int, PengangguranData> _getDefaultData() {
    return {
      2020: PengangguranData(
        year: 2020,
        tptSemarang: 9.57,
        tpakSemarang: 69.89,
        tptJateng: 6.92,
        tpakJateng: 68.50,
        tptNasional: 7.07,
        tpakNasional: 67.93,
      ),
      2021: PengangguranData(
        year: 2021,
        tptSemarang: 9.54,
        tpakSemarang: 69.41,
        tptJateng: 6.45,
        tpakJateng: 69.10,
        tptNasional: 6.49,
        tpakNasional: 68.04,
      ),
      2022: PengangguranData(
        year: 2022,
        tptSemarang: 7.60,
        tpakSemarang: 70.96,
        tptJateng: 5.89,
        tpakJateng: 69.70,
        tptNasional: 5.86,
        tpakNasional: 68.06,
      ),
      2023: PengangguranData(
        year: 2023,
        tptSemarang: 5.99,
        tpakSemarang: 69.42,
        tptJateng: 5.34,
        tpakJateng: 70.30,
        tptNasional: 5.32,
        tpakNasional: 68.08,
      ),
      2024: PengangguranData(
        year: 2024,
        tptSemarang: 5.82,
        tpakSemarang: 69.88,
        tptJateng: 4.78,
        tpakJateng: 70.90,
        tptNasional: 4.91,
        tpakNasional: 67.22,
      ),
      2025: PengangguranData(
        year: 2025,
        tptSemarang: 5.65,
        tpakSemarang: 72.60,
        tptJateng: 4.50,
        tpakJateng: 71.50,
        tptNasional: 4.70,
        tpakNasional: 67.50,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sizing = ResponsiveSizing(context);
    final isSmallScreen = sizing.isVerySmall || sizing.isSmall;

    if (isLoading) {
      return Scaffold(
        backgroundColor: _bpsBackground,
        body: Column(
          children: [
            _buildHeader(context, sizing, isSmallScreen),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: _bpsBlue),
                    SizedBox(height: sizing.sectionSpacing - 8),
                    Text(
                      'Memuat data pengangguran...',
                      style: TextStyle(
                        fontSize: sizing.categoryLabelFontSize,
                        color: _bpsTextSecondary,
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

    if (errorMessage != null) {
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
                      Icon(Icons.error_outline_rounded,
                          size: isSmallScreen ? 48 : 64, color: _bpsRed),
                      SizedBox(height: sizing.sectionSpacing - 8),
                      Text(
                        'Terjadi Kesalahan',
                        style: TextStyle(
                          fontSize: sizing.sectionTitleSize,
                          fontWeight: FontWeight.w700,
                          color: _bpsTextPrimary,
                        ),
                      ),
                      SizedBox(height: sizing.itemSpacing),
                      Text(
                        errorMessage!,
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
                      _buildTPTChart(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildTPAKChart(sizing, isSmallScreen),
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

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader(
      BuildContext context, ResponsiveSizing sizing, bool isSmallScreen) {
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
              // Back button — white semi-transparent pill
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
              // Title + subtitle
              Expanded(
                child: Text(
                  'Pengangguran',
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
              // Icon badge
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

  // ── YEAR SELECTOR ─────────────────────────────────────────────────────────
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
          // Header row
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: _bpsBlue,
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
                  color: _bpsTextPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          // Year chips
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
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _bpsBlue.withOpacity(0.3),
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

  // ── MAIN INDICATORS ───────────────────────────────────────────────────────
  Widget _buildMainIndicators(ResponsiveSizing sizing, bool isSmallScreen) {
    final data = yearlyData[selectedYear];
    if (data == null) return const SizedBox.shrink();

    final prevData = yearlyData[selectedYear - 1];
    final tptChange = prevData != null
        ? data.tptSemarang - prevData.tptSemarang
        : data.tptSemarang -
            (yearlyData[availableYears.last]?.tptSemarang ?? data.tptSemarang);
    final tpakChange =
        prevData != null ? data.tpakSemarang - prevData.tpakSemarang : 0.0;

    final tptColor = tptChange < 0 ? _bpsGreen : _bpsRed;
    final tpakColor = tpakChange > 0 ? _bpsGreen : _bpsOrange;

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
          // Section header
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: _bpsBlue,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  'Indikator Utama $selectedYear',
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? sizing.groupTitleSize - 2
                        : sizing.groupTitleSize,
                    fontWeight: FontWeight.w700,
                    color: _bpsTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          // Indicator rows
          _buildIndicatorRow(
            label: 'TPT Kota Semarang',
            value: '${NumberFormatUtils.formatValue(data.tptSemarang, decimalPlaces: 2)}%',
            subtitle: tptChange < 0
                ? 'turun ${NumberFormatUtils.formatValue(tptChange.abs(), decimalPlaces: 2)}% dari tahun lalu'
                : 'naik ${NumberFormatUtils.formatValue(tptChange, decimalPlaces: 2)}% dari tahun lalu',
            icon: Icons.trending_down_rounded,
            color: tptColor,
            isSmallScreen: isSmallScreen,
            sizing: sizing,
          ),
          _buildDivider(),
          _buildIndicatorRow(
            label: 'TPAK Kota Semarang',
            value: '${NumberFormatUtils.formatValue(data.tpakSemarang, decimalPlaces: 2)}%',
            subtitle: tpakChange > 0
                ? 'naik ${NumberFormatUtils.formatValue(tpakChange, decimalPlaces: 2)}% dari tahun lalu'
                : 'turun ${NumberFormatUtils.formatValue(tpakChange.abs(), decimalPlaces: 2)}% dari tahun lalu',
            icon: Icons.people_rounded,
            color: tpakColor,
            isSmallScreen: isSmallScreen,
            sizing: sizing,
          ),
          _buildDivider(),
          _buildIndicatorRow(
            label: 'TPT Jawa Tengah',
            value: '${NumberFormatUtils.formatValue(data.tptJateng, decimalPlaces: 2)}%',
            subtitle: 'Perbandingan regional',
            icon: Icons.location_on_rounded,
            color: _bpsOrange,
            isSmallScreen: isSmallScreen,
            sizing: sizing,
          ),
          _buildDivider(),
          _buildIndicatorRow(
            label: 'TPT Nasional',
            value: '${NumberFormatUtils.formatValue(data.tptNasional, decimalPlaces: 2)}%',
            subtitle: 'Perbandingan nasional',
            icon: Icons.public_rounded,
            color: _bpsBlue,
            isSmallScreen: isSmallScreen,
            sizing: sizing,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorRow({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSmallScreen,
    required ResponsiveSizing sizing,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: isSmallScreen ? 16 : 20),
          SizedBox(width: sizing.itemSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? sizing.categoryLabelFontSize - 1
                        : sizing.categoryLabelFontSize,
                    fontWeight: FontWeight.w600,
                    color: _bpsTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? sizing.statsLabelFontSize - 1
                        : sizing.statsLabelFontSize,
                    color: _bpsTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen
                  ? sizing.sectionTitleSize - 2
                  : sizing.sectionTitleSize,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: _bpsBorder, height: 1, thickness: 1);
  }

  // ── TPT CHART ─────────────────────────────────────────────────────────────
  Widget _buildTPTChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final semarangSpots = <FlSpot>[];
    final jatengSpots = <FlSpot>[];
    final nasionalSpots = <FlSpot>[];

    for (final year in List<int>.from(availableYears)..sort()) {
      if (yearlyData.containsKey(year)) {
        final d = yearlyData[year]!;
        semarangSpots.add(FlSpot(year.toDouble(), d.tptSemarang));
        jatengSpots.add(FlSpot(year.toDouble(), d.tptJateng));
        nasionalSpots.add(FlSpot(year.toDouble(), d.tptNasional));
      }
    }

    return _buildChartCard(
      icon: Icons.show_chart_rounded,
      iconColor: _bpsBlue,
      title: 'Tren Tingkat Pengangguran Terbuka (TPT)',
      sizing: sizing,
      isSmallScreen: isSmallScreen,
      minY: 0,
      maxY: 12,
      interval: 2,
      unit: '%',
      spots: [semarangSpots, jatengSpots, nasionalSpots],
      colors: [_bpsBlue, _bpsOrange, _bpsGreen],
      labels: ['Semarang', 'Jawa Tengah', 'Nasional'],
    );
  }

  // ── TPAK CHART ────────────────────────────────────────────────────────────
  Widget _buildTPAKChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final semarangSpots = <FlSpot>[];
    final jatengSpots = <FlSpot>[];
    final nasionalSpots = <FlSpot>[];

    for (final year in List<int>.from(availableYears)..sort()) {
      if (yearlyData.containsKey(year)) {
        final d = yearlyData[year]!;
        semarangSpots.add(FlSpot(year.toDouble(), d.tpakSemarang));
        jatengSpots.add(FlSpot(year.toDouble(), d.tpakJateng));
        nasionalSpots.add(FlSpot(year.toDouble(), d.tpakNasional));
      }
    }

    return _buildChartCard(
      icon: Icons.people_alt_rounded,
      iconColor: _bpsGreen,
      title: 'Tren Tingkat Partisipasi Angkatan Kerja (TPAK)',
      sizing: sizing,
      isSmallScreen: isSmallScreen,
      minY: 60,
      maxY: 80,
      interval: 5,
      unit: '%',
      spots: [semarangSpots, jatengSpots, nasionalSpots],
      colors: [_bpsBlue, _bpsOrange, _bpsGreen],
      labels: ['Semarang', 'Jawa Tengah', 'Nasional'],
    );
  }

  Widget _buildChartCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required ResponsiveSizing sizing,
    required bool isSmallScreen,
    required double minY,
    required double maxY,
    required double interval,
    required String unit,
    required List<List<FlSpot>> spots,
    required List<Color> colors,
    required List<String> labels,
  }) {
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
          // Card header
          Row(
            children: [
              Icon(icon, color: iconColor, size: isSmallScreen ? 16 : 20),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? sizing.groupTitleSize - 2
                        : sizing.groupTitleSize,
                    fontWeight: FontWeight.w700,
                    color: _bpsTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          // Chart
          SizedBox(
            height: isSmallScreen ? 200 : 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: _bpsBorder, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}$unit',
                        style: TextStyle(
                          fontSize: sizing.statsLabelFontSize,
                          color: _bpsTextSecondary,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final year = value.toInt();
                        if (availableYears.contains(year)) {
                          return Text(
                            year.toString(),
                            style: TextStyle(
                              fontSize: sizing.statsLabelFontSize,
                              color: _bpsTextSecondary,
                            ),
                          );
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
                borderData: FlBorderData(show: false),
                minX: availableYears.last.toDouble(),
                maxX: availableYears.first.toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: List.generate(spots.length, (i) {
                  return LineChartBarData(
                    spots: spots[i],
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: colors[i],
                    barWidth: i == 0 ? 3 : 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: i == 0 ? 4 : 3,
                        color: colors[i],
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: i == 0
                        ? BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                colors[0].withOpacity(0.15),
                                colors[0].withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          )
                        : BarAreaData(show: false),
                  );
                }),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        _bpsTextPrimary.withOpacity(0.85),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${labels[spot.barIndex]}: ${NumberFormatUtils.formatValue(spot.y, decimalPlaces: 2)}$unit',
                          TextStyle(
                            color: colors[spot.barIndex],
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: sizing.itemSpacing),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List.generate(labels.length, (i) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 3,
                    decoration: BoxDecoration(
                      color: colors[i],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: sizing.statsLabelFontSize,
                      color: _bpsTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── KESIMPULAN ────────────────────────────────────────────────────────────
  Widget _buildKesimpulanCard(ResponsiveSizing sizing, bool isSmallScreen) {
    final data = yearlyData[selectedYear];
    if (data == null) return const SizedBox.shrink();

    final previousData = yearlyData[selectedYear - 1];
    final tptChange = previousData != null
        ? data.tptSemarang - previousData.tptSemarang
        : 0.0;
    final tpakChange = previousData != null
        ? data.tpakSemarang - previousData.tpakSemarang
        : 0.0;

    final kesimpulanAnak = <String>[];

    if (tptChange < 0) {
      kesimpulanAnak.add(
          'TPT Kota Semarang $selectedYear turun ${NumberFormatUtils.formatValue(tptChange.abs(), decimalPlaces: 2)} persen poin dibanding tahun sebelumnya, menunjukkan peningkatan penyerapan tenaga kerja.');
    } else if (tptChange > 0) {
      kesimpulanAnak.add(
          'TPT Kota Semarang $selectedYear naik ${NumberFormatUtils.formatValue(tptChange, decimalPlaces: 2)} persen poin dibanding tahun sebelumnya, perlu perhatian dalam program ketenagakerjaan.');
    } else {
      kesimpulanAnak.add(
          'TPT Kota Semarang $selectedYear relatif stabil dibanding tahun sebelumnya.');
    }

    if (tpakChange > 0) {
      kesimpulanAnak.add(
          'TPAK meningkat ${NumberFormatUtils.formatValue(tpakChange, decimalPlaces: 2)} persen poin, menunjukkan peningkatan partisipasi penduduk dalam angkatan kerja.');
    }

    if (data.tptSemarang < data.tptNasional) {
      kesimpulanAnak.add(
          'TPT Kota Semarang (${NumberFormatUtils.formatValue(data.tptSemarang, decimalPlaces: 2)}%) lebih rendah dari TPT Nasional (${NumberFormatUtils.formatValue(data.tptNasional, decimalPlaces: 2)}%), menunjukkan kondisi ketenagakerjaan yang lebih baik.');
    }

    final status =
        tptChange <= 0 ? KesimpulanStatus.baik : KesimpulanStatus.perbaikan;
    final mainConclusion = tptChange <= 0
        ? 'Tingkat pengangguran terbuka (TPT) Kota Semarang menunjukkan tren penurunan yang positif.'
        : 'Tingkat pengangguran terbuka (TPT) mengalami peningkatan dan memerlukan perhatian.';

    return KesimpulanWidget(
      title: 'Kesimpulan',
      conclusion: mainConclusion,
      status: status,
      sizing: sizing,
      isSmallScreen: isSmallScreen,
      additionalPoints: kesimpulanAnak,
    );
  }
}

class ChartDataPoint {
  final int year;
  final double value;

  ChartDataPoint({required this.year, required this.value});
}
