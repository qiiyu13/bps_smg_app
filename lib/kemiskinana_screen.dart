import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'responsive_sizing.dart';
import 'number_format_utils.dart';
import 'kesimpulan_widget.dart';

// BPS Color Palette (matching home_screen.dart)
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

// Poverty data model - Made immutable for better performance
@immutable
class PovertyData {
  final int year;
  final double pendudukMiskinValue;
  final String pendudukMiskinDisplay;
  final double persentaseValue;
  final String persentaseDisplay;
  final String garisMiskin;
  final String indeksKedalaman;
  final String indeksKeparahan;
  final String kemiskinanKota;
  final String kemiskinanKotaChange;
  final String kemiskinanDesa;
  final String kemiskinanDesaChange;

  const PovertyData({
    required this.year,
    required this.pendudukMiskinValue,
    required this.pendudukMiskinDisplay,
    required this.persentaseValue,
    required this.persentaseDisplay,
    required this.garisMiskin,
    required this.indeksKedalaman,
    required this.indeksKeparahan,
    required this.kemiskinanKota,
    required this.kemiskinanKotaChange,
    required this.kemiskinanDesa,
    required this.kemiskinanDesaChange,
  });

  factory PovertyData.fromMap(int year, Map<String, dynamic> map) {
    return PovertyData(
      year: year,
      pendudukMiskinValue:
          (map['pendudukMiskinValue'] as num?)?.toDouble() ?? 0.0,
      pendudukMiskinDisplay: map['pendudukMiskin']?.toString() ?? '-',
      persentaseValue: (map['persentaseValue'] as num?)?.toDouble() ?? 0.0,
      persentaseDisplay: map['persentase']?.toString() ?? '-',
      garisMiskin: map['garisMiskin']?.toString() ?? '-',
      indeksKedalaman: map['indeksKedalaman']?.toString() ?? '-',
      indeksKeparahan: map['indeksKeparahan']?.toString() ?? '-',
      kemiskinanKota: map['kemiskinanKota']?.toString() ?? '-',
      kemiskinanKotaChange: map['kemiskinanKotaChange']?.toString() ?? '-',
      kemiskinanDesa: map['kemiskinanDesa']?.toString() ?? '-',
      kemiskinanDesaChange: map['kemiskinanDesaChange']?.toString() ?? '-',
    );
  }

  // For backwards compatibility with SharedPreferences
  Map<String, dynamic> toMap() => {
        'pendudukMiskin': pendudukMiskinDisplay,
        'pendudukMiskinValue': pendudukMiskinValue,
        'persentase': persentaseDisplay,
        'persentaseValue': persentaseValue,
        'garisMiskin': garisMiskin,
        'indeksKedalaman': indeksKedalaman,
        'indeksKeparahan': indeksKeparahan,
        'kemiskinanKota': kemiskinanKota,
        'kemiskinanKotaChange': kemiskinanKotaChange,
        'kemiskinanDesa': kemiskinanDesa,
        'kemiskinanDesaChange': kemiskinanDesaChange,
      };
}

class KemiskinanScreen extends StatefulWidget {
  const KemiskinanScreen({super.key});

  @override
  State<KemiskinanScreen> createState() => _KemiskinanScreenState();
}

class _KemiskinanScreenState extends State<KemiskinanScreen>
    with AutomaticKeepAliveClientMixin {
  int selectedYear = 2024;
  Map<int, PovertyData> yearlyData = {};
  bool isLoading = true;
  String? errorMessage;
  List<int> _cachedSortedYears = [];

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
      final savedData = prefs.getString('kemiskinan_data');

      if (mounted) {
        setState(() {
          if (savedData != null) {
            // Data dari admin
            final decoded = json.decode(savedData) as Map<String, dynamic>;
            yearlyData = decoded.map(
              (key, value) => MapEntry(
                int.parse(key),
                PovertyData.fromMap(
                    int.parse(key), Map<String, dynamic>.from(value as Map)),
              ),
            );
          } else {
            // Data default jika belum ada dari admin
            yearlyData = {
              2020: PovertyData.fromMap(2020, {
                'pendudukMiskin': '79.58 Ribu',
                'pendudukMiskinValue': 79.58,
                'persentase': '4.34%',
                'persentaseValue': 4.34,
                'garisMiskin': 'Rp 522,691',
                'indeksKedalaman': '0.68',
                'indeksKeparahan': '0.16',
                'kemiskinanKota': '4.34%',
                'kemiskinanKotaChange': '+0.20%',
                'kemiskinanDesa': '12.82%',
                'kemiskinanDesaChange': '+0.27%',
              }),
              2021: PovertyData.fromMap(2021, {
                'pendudukMiskin': '84.45 Ribu',
                'pendudukMiskinValue': 84.45,
                'persentase': '4.56%',
                'persentaseValue': 4.56,
                'garisMiskin': 'Rp 543,929',
                'indeksKedalaman': '0.67',
                'indeksKeparahan': '0.14',
                'kemiskinanKota': '4.56%',
                'kemiskinanKotaChange': '+0.28%',
                'kemiskinanDesa': '13.20%',
                'kemiskinanDesaChange': '+0.38%',
              }),
              2022: PovertyData.fromMap(2022, {
                'pendudukMiskin': '79.87 Ribu',
                'pendudukMiskinValue': 79.87,
                'persentase': '4.25%',
                'persentaseValue': 4.25,
                'garisMiskin': 'Rp 589,598',
                'indeksKedalaman': '0.56',
                'indeksKeparahan': '0.11',
                'kemiskinanKota': '4.25%',
                'kemiskinanKotaChange': '-0.22%',
                'kemiskinanDesa': '12.34%',
                'kemiskinanDesaChange': '-0.86%',
              }),
              2023: PovertyData.fromMap(2023, {
                'pendudukMiskin': '80.53 Ribu',
                'pendudukMiskinValue': 80.53,
                'persentase': '4.23%',
                'persentaseValue': 4.23,
                'garisMiskin': 'Rp 642,456',
                'indeksKedalaman': '0.54',
                'indeksKeparahan': '0.10',
                'kemiskinanKota': '4.23%',
                'kemiskinanKotaChange': '-0.41%',
                'kemiskinanDesa': '12.45%',
                'kemiskinanDesaChange': '-0.89%',
              }),
              2024: PovertyData.fromMap(2024, {
                'pendudukMiskin': '77.79 Ribu',
                'pendudukMiskinValue': 77.79,
                'persentase': '4.03%',
                'persentaseValue': 4.03,
                'garisMiskin': 'Rp 671,936',
                'indeksKedalaman': '0.59',
                'indeksKeparahan': '0.12',
                'kemiskinanKota': '4.03%',
                'kemiskinanKotaChange': '-0.29%',
                'kemiskinanDesa': '12.11%',
                'kemiskinanDesaChange': '-0.34%',
              }),
            };
          }

          // Cache sorted years to avoid recalculation
          _cachedSortedYears = yearlyData.keys.toList()..sort();

          // Set selected year ke tahun terbaru yang ada
          if (_cachedSortedYears.isNotEmpty) {
            selectedYear = _cachedSortedYears.last;
          }

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
                        const CircularProgressIndicator(color: _bpsBlue),
                        SizedBox(height: sizing.sectionSpacing - 8),
                        Text(
                          'Memuat data kemiskinan...',
                          style: TextStyle(
                            fontSize: sizing.categoryLabelFontSize,
                            color: _bpsTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(sizing.horizontalPadding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: sizing.isVerySmall ? 48 : 64,
                                color: _bpsRed,
                              ),
                              SizedBox(height: sizing.sectionSpacing - 8),
                              Text(
                                'Terjadi Kesalahan',
                                style: TextStyle(
                                  fontSize: sizing.sectionTitleSize,
                                  fontWeight: FontWeight.bold,
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
                              SizedBox(height: sizing.sectionSpacing),
                              ElevatedButton.icon(
                                onPressed: _loadData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Coba Lagi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _bpsBlue,
                                  foregroundColor: _bpsCardBg,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: sizing.horizontalPadding,
                                    vertical: sizing.itemSpacing,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _KemiskinanScreenContent(
                        selectedYear: selectedYear,
                        yearlyData: yearlyData,
                        cachedSortedYears: _cachedSortedYears,
                        onYearSelected: (year) =>
                            setState(() => selectedYear = year),
                        sizing: sizing,
                        isSmallScreen: isSmallScreen,
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
                      'Data Kemiskinan',
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
                  Icons.volunteer_activism_rounded,
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
}

// Extracted content widget for better performance
class _KemiskinanScreenContent extends StatelessWidget {
  final int selectedYear;
  final Map<int, PovertyData> yearlyData;
  final List<int> cachedSortedYears;
  final ValueChanged<int> onYearSelected;
  final ResponsiveSizing sizing;
  final bool isSmallScreen;

  const _KemiskinanScreenContent({
    required this.selectedYear,
    required this.yearlyData,
    required this.cachedSortedYears,
    required this.onYearSelected,
    required this.sizing,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    if (yearlyData.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(sizing.horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: sizing.isVerySmall ? 48 : 64,
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
                'Data kemiskinan belum tersedia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: sizing.categoryLabelFontSize,
                  color: _bpsTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentData = yearlyData[selectedYear]!;

    return CustomScrollView(
      physics:
          const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(sizing.horizontalPadding),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _YearSelector(
                years: cachedSortedYears,
                selectedYear: selectedYear,
                onYearSelected: onYearSelected,
                sizing: sizing,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: sizing.sectionSpacing),
              _buildPovertyStatsGrid(context, currentData),
              SizedBox(height: sizing.sectionSpacing),
              _PovertyTrendChart(
                title: 'Jumlah Penduduk Miskin (Ribu Jiwa)',
                subtitle:
                    'Tren dari tahun ${cachedSortedYears.first} hingga ${cachedSortedYears.last}',
                icon: Icons.people_outline,
                accentColor: _bpsRed,
                years: cachedSortedYears,
                values: cachedSortedYears
                    .map((y) => yearlyData[y]!.pendudukMiskinValue)
                    .toList(),
                displayValues: cachedSortedYears
                    .map((y) => yearlyData[y]!.pendudukMiskinDisplay)
                    .toList(),
                minY: 75,
                maxY: 87,
                yInterval: 2,
                yAxisSuffix: ' Ribu',
                indicatorTitle: 'Jumlah Penduduk Miskin',
                indicatorValue: currentData.pendudukMiskinDisplay,
                selectedYear: selectedYear,
                baseYear: cachedSortedYears.first,
                sizing: sizing,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: sizing.sectionSpacing),
              _PovertyTrendChart(
                title: 'Persentase Kemiskinan (%)',
                subtitle:
                    'Tren dari tahun ${cachedSortedYears.first} hingga ${cachedSortedYears.last}',
                icon: Icons.percent,
                accentColor: _bpsOrange,
                years: cachedSortedYears,
                values: cachedSortedYears
                    .map((y) => yearlyData[y]!.persentaseValue)
                    .toList(),
                displayValues: cachedSortedYears
                    .map((y) => yearlyData[y]!.persentaseDisplay)
                    .toList(),
                minY: 3.8,
                maxY: 4.8,
                yInterval: 0.2,
                yAxisSuffix: '%',
                indicatorTitle: 'Persentase Kemiskinan',
                indicatorValue: currentData.persentaseDisplay,
                selectedYear: selectedYear,
                baseYear: cachedSortedYears.first,
                sizing: sizing,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: sizing.sectionSpacing),
              _PovertyInformationPanel(
                  sizing: sizing, isSmallScreen: isSmallScreen),
              SizedBox(height: sizing.sectionSpacing),
              _buildKesimpulanCard(context, sizing, isSmallScreen),
              SizedBox(height: sizing.sectionSpacing),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildKesimpulanCard(
      BuildContext context, ResponsiveSizing sizing, bool isSmallScreen) {
    if (yearlyData.isEmpty || cachedSortedYears.length < 2) {
      return const SizedBox.shrink();
    }

    final latestYear = cachedSortedYears.last;
    final firstYear = cachedSortedYears.first;
    final latestData = yearlyData[latestYear]!;
    final firstData = yearlyData[firstYear]!;

    final conclusionData = KesimpulanGenerator.generateKemiskinanConclusion(
      latestYear: latestYear,
      firstYear: firstYear,
      latestPercentage: latestData.persentaseValue,
      firstPercentage: firstData.persentaseValue,
      latestPopulation: latestData.pendudukMiskinDisplay,
      urbanPercentage: latestData.kemiskinanKota,
      ruralPercentage: latestData.kemiskinanDesa,
    );

    return KesimpulanWidget(
      title: 'Kemiskinan Kota Semarang',
      conclusion: conclusionData['conclusion'] as String,
      status: conclusionData['status'] as KesimpulanStatus,
      sizing: sizing,
      isSmallScreen: isSmallScreen,
      additionalPoints: conclusionData['additionalPoints'] as List<String>?,
    );
  }

  Widget _buildPovertyStatsGrid(BuildContext context, PovertyData data) {
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
                  'Indikator Utama Kemiskinan',
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
                value: data.pendudukMiskinDisplay,
                label: 'Penduduk Miskin',
                color: _bpsRed,
                icon: Icons.people_outline,
                description:
                    'Jumlah penduduk miskin adalah banyaknya penduduk yang memiliki rata-rata pengeluaran per kapita per bulan di bawah garis kemiskinan.',
                isFirst: true,
              ),
              _buildIndicatorDivider(),
              _buildCompactIndicatorRow(
                context: context,
                value: data.garisMiskin,
                label: 'Garis Kemiskinan',
                color: _bpsOrange,
                icon: Icons.attach_money,
                description:
                    'Garis Kemiskinan merupakan penjumlahan dari Garis Kemiskinan Makanan (GKM) dan Garis Kemiskinan Bukan Makanan (GKBM). Penduduk dengan pengeluaran di bawah GK dikategorikan miskin.',
              ),
              _buildIndicatorDivider(),
              _buildCompactIndicatorRow(
                context: context,
                value: data.persentaseDisplay,
                label: 'Persentase (P0)',
                color: _bpsBlue,
                icon: Icons.pie_chart,
                description:
                    'Persentase Penduduk Miskin (P0) menunjukkan proporsi penduduk yang berada di bawah garis kemiskinan terhadap total penduduk.',
              ),
              _buildIndicatorDivider(),
              _buildCompactIndicatorRow(
                context: context,
                value: data.indeksKedalaman,
                label: 'Kedalaman (P1)',
                color: Colors.purple,
                icon: Icons.analytics,
                description:
                    'Indeks Kedalaman Kemiskinan (P1) menggambarkan seberapa jauh rata-rata pengeluaran penduduk miskin dari garis kemiskinan. Semakin tinggi nilai, semakin dalam tingkat kemiskinan.',
              ),
              _buildIndicatorDivider(),
              _buildCompactIndicatorRow(
                context: context,
                value: data.indeksKeparahan,
                label: 'Keparahan (P2)',
                color: Colors.deepOrange,
                icon: Icons.trending_down,
                description:
                    'Indeks Keparahan Kemiskinan (P2) menggambarkan ketimpangan pengeluaran di antara penduduk miskin. Semakin tinggi nilai, semakin tinggi ketimpangan pengeluaran penduduk miskin.',
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
              // Color indicator dot (10-12px)
              Container(
                width: isSmallScreen ? 10 : 12,
                height: isSmallScreen ? 10 : 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 10),

              // Label (flex: 3, left-aligned)
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

              SizedBox(width: 8),

              // Value (flex: 2, right-aligned)
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

              SizedBox(width: 6),

              // Chevron indicator
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

  Widget _buildIndicatorDivider() {
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
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final dialogSizing = ResponsiveSizing(dialogContext);
        final isDialogSmall = dialogSizing.isVerySmall || dialogSizing.isSmall;

        return Dialog(
          insetPadding: EdgeInsets.all(isDialogSmall ? 12 : 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.7,
              maxWidth: isDialogSmall
                  ? MediaQuery.of(dialogContext).size.width - 24
                  : 500,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(isDialogSmall ? 12 : 16),
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
                        padding: EdgeInsets.all(isDialogSmall ? 8 : 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: isDialogSmall ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: isDialogSmall ? 8 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: isDialogSmall ? 16 : 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tahun $selectedYear',
                              style: TextStyle(
                                fontSize: isDialogSmall ? 12 : 14,
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
                              size: isDialogSmall ? 18 : 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isDialogSmall ? 12 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Value Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isDialogSmall ? 12 : 16),
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
                                  fontSize: isDialogSmall ? 13 : 14,
                                  color: _bpsTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: isDialogSmall ? 8 : 12),
                              Text(
                                value,
                                style: TextStyle(
                                  fontSize: isDialogSmall ? 28 : 32,
                                  fontWeight: FontWeight.w800,
                                  color: _bpsTextPrimary,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isDialogSmall ? 12 : 16),

                        // Description
                        Container(
                          padding: EdgeInsets.all(isDialogSmall ? 12 : 16),
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
                                size: isDialogSmall ? 18 : 20,
                              ),
                              SizedBox(width: isDialogSmall ? 8 : 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Penjelasan',
                                      style: TextStyle(
                                        fontSize: isDialogSmall ? 14 : 16,
                                        fontWeight: FontWeight.w700,
                                        color: color,
                                      ),
                                    ),
                                    SizedBox(height: isDialogSmall ? 4 : 6),
                                    Text(
                                      description,
                                      style: TextStyle(
                                        fontSize: isDialogSmall ? 13 : 14,
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
}

// Year selector widget
class _YearSelector extends StatelessWidget {
  final List<int> years;
  final int selectedYear;
  final ValueChanged<int> onYearSelected;
  final ResponsiveSizing sizing;
  final bool isSmallScreen;

  const _YearSelector({
    required this.years,
    required this.selectedYear,
    required this.onYearSelected,
    required this.sizing,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
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
            children: years.map((year) {
              final isSelected = year == selectedYear;
              return Material(
                color: isSelected ? _bpsBlue : _bpsBackground,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => onYearSelected(year),
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
}

// Unified poverty trend chart widget - eliminates 400+ lines of duplication
class _PovertyTrendChart extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final List<int> years;
  final List<double> values;
  final List<String> displayValues;
  final double minY;
  final double maxY;
  final double yInterval;
  final String yAxisSuffix;
  final String indicatorTitle;
  final String indicatorValue;
  final int selectedYear;
  final int baseYear;
  final ResponsiveSizing sizing;
  final bool isSmallScreen;

  const _PovertyTrendChart({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.years,
    required this.values,
    required this.displayValues,
    required this.minY,
    required this.maxY,
    required this.yInterval,
    required this.yAxisSuffix,
    required this.indicatorTitle,
    required this.indicatorValue,
    required this.selectedYear,
    required this.baseYear,
    required this.sizing,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    if (years.isEmpty) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Text(
            'Tidak ada data untuk ditampilkan',
            style: TextStyle(
              fontSize: sizing.categoryLabelFontSize,
              color: _bpsTextSecondary,
            ),
          ),
        ),
      );
    }

    final selectedYearIndex = years.indexOf(selectedYear);
    final baseYearIndex = years.indexOf(baseYear);
    final currentValue =
        selectedYearIndex >= 0 ? values[selectedYearIndex] : 0.0;
    final baseValue = baseYearIndex >= 0 ? values[baseYearIndex] : 0.0;
    final perubahan = baseValue - currentValue;
    final isPositive = perubahan > 0;

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
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
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
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? sizing.groupTitleSize - 2
                            : sizing.groupTitleSize,
                        fontWeight: FontWeight.w800,
                        color: _bpsTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
          RepaintBoundary(
            child: SizedBox(
              height: isSmallScreen ? 220 : 240,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yInterval,
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
                        reservedSize: isSmallScreen
                            ? (yAxisSuffix == '%' ? 38 : 42)
                            : (yAxisSuffix == '%' ? 45 : 50),
                        interval: yInterval,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            yAxisSuffix == '%'
                                ? '${NumberFormatUtils.formatDecimal(value, decimalPlaces: 1)}$yAxisSuffix'
                                : '${value.toInt()}$yAxisSuffix',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10 : 12,
                              color: _bpsTextSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
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
                                  color: _bpsTextPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: minY,
                  maxY: maxY,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) => _bpsCardBg,
                      tooltipRoundedRadius: 8,
                      tooltipBorder:
                          BorderSide(color: Colors.grey[300]!, width: 1),
                      tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index >= 0 && index < years.length) {
                            final value = displayValues[index];
                            return LineTooltipItem(
                              '${years[index]}\n$value',
                              TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: sizing.bottomNavLabelSize,
                              ),
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        years.length,
                        (i) => FlSpot(i.toDouble(), values[i]),
                      ),
                      isCurved: true,
                      color: accentColor,
                      barWidth: isSmallScreen ? 2.5 : 3.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: isSmallScreen ? 3 : 5,
                            color: accentColor,
                            strokeWidth: isSmallScreen ? 1.5 : 2.5,
                            strokeColor: _bpsCardBg,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withOpacity(0.2),
                            accentColor.withOpacity(0.02),
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
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Left section: Title + Value (left-aligned)
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedYear == baseYear
                            ? indicatorTitle
                            : '${isPositive ? "Penurunan" : "Kenaikan"} (dari $baseYear)',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: _bpsTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        selectedYear == baseYear
                            ? indicatorValue
                            : '${NumberFormatUtils.formatDecimal(perubahan.abs(), decimalPlaces: 2)}$yAxisSuffix',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : 28,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right section: Badge (only when comparing years)
                if (selectedYear != baseYear) ...[
                  SizedBox(width: 16),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 10 : 12,
                      vertical: isSmallScreen ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive ? _bpsGreen : _bpsRed,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (isPositive ? _bpsGreen : _bpsRed)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.trending_down : Icons.trending_up,
                          size: isSmallScreen ? 14 : 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          isPositive ? 'Menurun' : 'Meningkat',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Information panel widget
class _PovertyInformationPanel extends StatelessWidget {
  final ResponsiveSizing sizing;
  final bool isSmallScreen;

  const _PovertyInformationPanel({
    required this.sizing,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen
          ? sizing.statsCardPadding - 4
          : sizing.statsCardPadding),
      decoration: BoxDecoration(
        color: _bpsBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bpsBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: _bpsBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: _bpsBlue,
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  'Metodologi Pengukuran Kemiskinan',
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? sizing.groupTitleSize - 2
                        : sizing.groupTitleSize,
                    fontWeight: FontWeight.w800,
                    color: _bpsTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'BPS mengukur kemiskinan menggunakan pendekatan kebutuhan dasar (basic need approach). Kemiskinan dipandang sebagai ketidakmampuan ekonomi seseorang dalam memenuhi kebutuhan dasar makanan maupun bukan makanan.',
            style: TextStyle(
              fontSize: sizing.categoryLabelFontSize,
              color: _bpsTextPrimary,
              height: 1.5,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: _bpsCardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu_rounded,
                      color: _bpsGreen,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    SizedBox(width: sizing.itemSpacing - 4),
                    Expanded(
                      child: Text(
                        'Garis Kemiskinan Makanan (GKM)',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w700,
                          color: _bpsGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Mencerminkan nilai pengeluaran kebutuhan minimum makanan yang disetarakan dengan 2.100 kalori per kapita per hari.',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: _bpsTextSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sizing.itemSpacing),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: _bpsCardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.home_outlined,
                      color: _bpsOrange,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    SizedBox(width: sizing.itemSpacing - 4),
                    Expanded(
                      child: Text(
                        'Garis Kemiskinan Bukan Makanan (GKBM)',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w700,
                          color: _bpsOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Mencakup kebutuhan minimum untuk perumahan, sandang, pendidikan, dan kesehatan.',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: _bpsTextSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildBulletPoint(
            'Garis Kemiskinan (GK) adalah penjumlahan dari GKM dan GKBM yang menjadi batas penentuan kemiskinan.',
            sizing,
          ),
          SizedBox(height: sizing.itemSpacing - 2),
          _buildBulletPoint(
            'Penduduk dikategorikan miskin apabila rata-rata pengeluaran per kapita per bulan berada di bawah Garis Kemiskinan.',
            sizing,
          ),
          SizedBox(height: sizing.itemSpacing - 2),
          _buildBulletPoint(
            'Penghitungan tingkat kemiskinan menggunakan data Survei Sosial Ekonomi Nasional (Susenas).',
            sizing,
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, ResponsiveSizing sizing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            fontSize: sizing.categoryLabelFontSize,
            color: _bpsBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: sizing.categoryLabelFontSize,
              color: _bpsTextPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
