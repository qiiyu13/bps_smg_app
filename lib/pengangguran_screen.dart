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
import 'widgets/section_kit.dart';

class PengangguranData {
  final int year;
  final double tptSemarang;
  final double tpakSemarang;
  final double tptJateng;
  final double tpakJateng;

  PengangguranData({
    required this.year,
    required this.tptSemarang,
    required this.tpakSemarang,
    required this.tptJateng,
    required this.tpakJateng,
  });

  factory PengangguranData.fromMap(int year, Map<String, dynamic> map) {
    return PengangguranData(
      year: year,
      tptSemarang: (map['tptSemarang'] as num?)?.toDouble() ?? 0.0,
      tpakSemarang: (map['tpakSemarang'] as num?)?.toDouble() ?? 0.0,
      tptJateng: (map['tptJateng'] as num?)?.toDouble() ?? 0.0,
      tpakJateng: (map['tpakJateng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tptSemarang': tptSemarang,
      'tpakSemarang': tpakSemarang,
      'tptJateng': tptJateng,
      'tpakJateng': tpakJateng,
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
      final prefs = await SharedPreferences.getInstance();

      final pengangguranSection = githubData?['pengangguranData'] as Map<String, dynamic>?;
      if (pengangguranSection != null) {
        yearlyData = pengangguranSection.map(
          (key, value) => MapEntry(
            int.parse(key),
            PengangguranData.fromMap(
                int.parse(key), Map<String, dynamic>.from(value as Map)),
          ),
        );
        await prefs.setString('pengangguran_data', json.encode(pengangguranSection));
      } else {
        final savedData = prefs.getString('pengangguran_data');

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
      }

      if (mounted) {
        setState(() {
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
          errorMessage = 'Gagal memuat data: $e';
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
        tptJateng: 6.48,
        tpakJateng: 68.50,
      ),
      2021: PengangguranData(
        year: 2021,
        tptSemarang: 9.54,
        tpakSemarang: 69.41,
        tptJateng: 5.95,
        tpakJateng: 69.10,
      ),
      2022: PengangguranData(
        year: 2022,
        tptSemarang: 7.60,
        tpakSemarang: 70.96,
        tptJateng: 5.57,
        tpakJateng: 69.70,
      ),
      2023: PengangguranData(
        year: 2023,
        tptSemarang: 5.99,
        tpakSemarang: 69.42,
        tptJateng: 5.13,
        tpakJateng: 70.30,
      ),
      2024: PengangguranData(
        year: 2024,
        tptSemarang: 5.82,
        tpakSemarang: 69.88,
        tptJateng: 4.78,
        tpakJateng: 70.90,
      ),
      2025: PengangguranData(
        year: 2025,
        tptSemarang: 5.65,
        tpakSemarang: 72.60,
        tptJateng: 4.76,
        tpakJateng: 71.50,
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
        backgroundColor: bpsBackground,
        body: Column(
          children: [
            _buildHeader(context, sizing, isSmallScreen),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: bpsBlue),
                    SizedBox(height: sizing.sectionSpacing - 8),
                    Text(
                      'Memuat data pengangguran...',
                      style: TextStyle(
                        fontSize: sizing.categoryLabelFontSize,
                        color: bpsTextSecondary,
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
                      Icon(Icons.error_outline_rounded,
                          size: isSmallScreen ? 48 : 64, color: bpsRed),
                      SizedBox(height: sizing.sectionSpacing - 8),
                      Text(
                        'Terjadi Kesalahan',
                        style: TextStyle(
                          fontSize: sizing.sectionTitleSize,
                          fontWeight: FontWeight.w700,
                          color: bpsTextPrimary,
                        ),
                      ),
                      SizedBox(height: sizing.itemSpacing),
                      Text(
                        errorMessage!,
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
                      _buildHero(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      SpineSection(
                        number: '01',
                        overline: 'Indikator',
                        title: 'Indikator Utama',
                        accent: bpsGreen,
                        surface: false,
                        isFirst: true,
                        isSmall: isSmallScreen,
                        child: _buildMainIndicators(sizing, isSmallScreen),
                      ),
                      SpineSection(
                        number: '02',
                        overline: 'Tren',
                        title: 'Tingkat Pengangguran Terbuka',
                        subtitle: 'TPT • Semarang vs Jawa Tengah',
                        accent: bpsGreen,
                        surface: false,
                        isSmall: isSmallScreen,
                        child: _buildTPTChart(sizing, isSmallScreen),
                      ),
                      SpineSection(
                        number: '03',
                        overline: 'Tren',
                        title: 'Tingkat Partisipasi Angkatan Kerja',
                        subtitle: 'TPAK • Semarang vs Jawa Tengah',
                        accent: bpsGreen,
                        surface: false,
                        isSmall: isSmallScreen,
                        child: _buildTPAKChart(sizing, isSmallScreen),
                      ),
                      SpineSection(
                        overline: 'Ringkasan',
                        title: 'Kesimpulan',
                        accent: bpsGreen,
                        surface: false,
                        isLast: true,
                        isSmall: isSmallScreen,
                        child: _buildKesimpulanCard(sizing, isSmallScreen),
                      ),
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
    return CategoryHeader(
      overline: 'INDIKATOR SOSIAL',
      title: 'Pengangguran',
      icon: Icons.work_off_rounded,
      accent: bpsGreen,
      isSmall: isSmallScreen,
    );
  }

  Widget _buildYearSelector(ResponsiveSizing sizing, bool isSmallScreen) {
    return YearRail(
      years: [...availableYears]..sort(),
      selected: selectedYear,
      onSelect: _changeYear,
      accent: bpsGreen,
      isSmall: isSmallScreen,
      controller: _yearScrollController,
    );
  }

  Widget _buildHero(ResponsiveSizing sizing, bool isSmallScreen) {
    final data = yearlyData[selectedYear];
    if (data == null) return const SizedBox.shrink();
    final sorted = [...availableYears]..sort();
    final prevData = yearlyData[selectedYear - 1];
    final delta = prevData != null ? data.tptSemarang - prevData.tptSemarang : null;
    final spark = sorted.map((y) => yearlyData[y]?.tptSemarang ?? 0.0).toList();
    return IndicatorHero(
      overline: 'TINGKAT PENGANGGURAN TERBUKA',
      value: '${NumberFormatUtils.formatValue(data.tptSemarang, decimalPlaces: 2)}%',
      subtitle: 'TPT • Kota Semarang',
      badge: 'Tahun $selectedYear',
      accent: bpsGreen,
      delta: delta,
      sparkline: spark.length > 1 ? spark : null,
      isSmall: isSmallScreen,
      facts: [
        HeroFact('TPAK', '${NumberFormatUtils.formatValue(data.tpakSemarang, decimalPlaces: 2)}%'),
        HeroFact('TPT Jawa Tengah', '${NumberFormatUtils.formatValue(data.tptJateng, decimalPlaces: 2)}%'),
      ],
    );
  }

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

    final tptColor = tptChange < 0 ? bpsGreen : bpsRed;
    final tpakColor = tpakChange > 0 ? bpsGreen : bpsOrange;

    return SectionPanel(
      isSmall: isSmallScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator rows (header supplied by the spine section)
          _buildIndicatorRow(
            label: 'TPT Kota Semarang',
            value:
                '${NumberFormatUtils.formatValue(data.tptSemarang, decimalPlaces: 2)}%',
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
            value:
                '${NumberFormatUtils.formatValue(data.tpakSemarang, decimalPlaces: 2)}%',
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
            value:
                '${NumberFormatUtils.formatValue(data.tptJateng, decimalPlaces: 2)}%',
            subtitle: 'Perbandingan regional',
            icon: Icons.location_on_rounded,
            color: bpsOrange,
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
                    color: bpsTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? sizing.statsLabelFontSize - 1
                        : sizing.statsLabelFontSize,
                    color: bpsTextSecondary,
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
              color: bpsTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: bpsBorder, height: 1, thickness: 1);
  }

  // ── TPT CHART ─────────────────────────────────────────────────────────────
  Widget _buildTPTChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final semarangSpots = <FlSpot>[];
    final jatengSpots = <FlSpot>[];

    for (final year in List<int>.from(availableYears)..sort()) {
      if (yearlyData.containsKey(year)) {
        final d = yearlyData[year]!;
        semarangSpots.add(FlSpot(year.toDouble(), d.tptSemarang));
        jatengSpots.add(FlSpot(year.toDouble(), d.tptJateng));
      }
    }

    return _buildChartCard(
      sizing: sizing,
      isSmallScreen: isSmallScreen,
      minY: 0,
      maxY: 12,
      interval: 2,
      unit: '%',
      spots: [semarangSpots, jatengSpots],
      colors: [bpsBlue, bpsOrange],
      labels: ['Semarang', 'Jawa Tengah'],
    );
  }

  // ── TPAK CHART ────────────────────────────────────────────────────────────
  Widget _buildTPAKChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final semarangSpots = <FlSpot>[];
    final jatengSpots = <FlSpot>[];

    for (final year in List<int>.from(availableYears)..sort()) {
      if (yearlyData.containsKey(year)) {
        final d = yearlyData[year]!;
        semarangSpots.add(FlSpot(year.toDouble(), d.tpakSemarang));
        jatengSpots.add(FlSpot(year.toDouble(), d.tpakJateng));
      }
    }

    return _buildChartCard(
      sizing: sizing,
      isSmallScreen: isSmallScreen,
      minY: 60,
      maxY: 80,
      interval: 5,
      unit: '%',
      spots: [semarangSpots, jatengSpots],
      colors: [bpsBlue, bpsOrange],
      labels: ['Semarang', 'Jawa Tengah'],
    );
  }

  Widget _buildChartCard({
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
    return SectionPanel(
      isSmall: isSmallScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart (header now supplied by the spine section)
          SizedBox(
            height: isSmallScreen ? 200 : 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: bpsBorder, strokeWidth: 1),
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
                          color: bpsTextSecondary,
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
                              color: bpsTextSecondary,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      ),
                  topTitles: const AxisTitles(
                      ),
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
                    color: colors[i],
                    barWidth: i == 0 ? 3 : 2,
                    dotData: FlDotData(
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
                                colors[0].withOpacity(0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          )
                        : BarAreaData(),
                  );
                }),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.white,
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
                      color: bpsTextSecondary,
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
