import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'services/github_data_service.dart';
import 'responsive_sizing.dart';
import 'number_format_utils.dart';
import 'kesimpulan_widget.dart';
import 'dart:async';
import 'app_theme.dart';
import 'widgets/section_kit.dart';

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

  const PovertyData({
    required this.year,
    required this.pendudukMiskinValue,
    required this.pendudukMiskinDisplay,
    required this.persentaseValue,
    required this.persentaseDisplay,
    required this.garisMiskin,
    required this.indeksKedalaman,
    required this.indeksKeparahan,
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
      final githubData = GitHubDataService.getData('kemiskinan');
      final prefs = await SharedPreferences.getInstance();

      final kemiskinanSection = githubData?['kemiskinanData'] as Map<String, dynamic>?;
      if (kemiskinanSection != null) {
        yearlyData = kemiskinanSection.map(
          (key, value) => MapEntry(
            int.parse(key),
            PovertyData.fromMap(int.parse(key), Map<String, dynamic>.from(value as Map)),
          ),
        );
        await prefs.setString('kemiskinan_data', json.encode(kemiskinanSection));
      } else {
        final savedData = prefs.getString('kemiskinan_data');

        if (savedData != null) {
          final decoded = json.decode(savedData) as Map<String, dynamic>;
          yearlyData = decoded.map(
            (key, value) => MapEntry(
              int.parse(key),
              PovertyData.fromMap(int.parse(key), Map<String, dynamic>.from(value as Map)),
            ),
          );
        } else {
          yearlyData = {
            2020: PovertyData.fromMap(2020, const {
              'pendudukMiskin': '79,58 Ribu',
              'pendudukMiskinValue': 79.58,
              'persentase': '4,34%',
              'persentaseValue': 4.34,
              'garisMiskin': 'Rp 522.691',
              'indeksKedalaman': '0,68',
              'indeksKeparahan': '0,16',
            }),
            2021: PovertyData.fromMap(2021, const {
              'pendudukMiskin': '84,45 Ribu',
              'pendudukMiskinValue': 84.45,
              'persentase': '4,56%',
              'persentaseValue': 4.56,
              'garisMiskin': 'Rp 543.929',
              'indeksKedalaman': '0,67',
              'indeksKeparahan': '0,14',
            }),
            2022: PovertyData.fromMap(2022, const {
              'pendudukMiskin': '79,87 Ribu',
              'pendudukMiskinValue': 79.87,
              'persentase': '4,25%',
              'persentaseValue': 4.25,
              'garisMiskin': 'Rp 589.598',
              'indeksKedalaman': '0,56',
              'indeksKeparahan': '0,11',
            }),
            2023: PovertyData.fromMap(2023, const {
              'pendudukMiskin': '80,53 Ribu',
              'pendudukMiskinValue': 80.53,
              'persentase': '4,23%',
              'persentaseValue': 4.23,
              'garisMiskin': 'Rp 642.456',
              'indeksKedalaman': '0,54',
              'indeksKeparahan': '0,10',
            }),
            2024: PovertyData.fromMap(2024, const {
              'pendudukMiskin': '77,79 Ribu',
              'pendudukMiskinValue': 77.79,
              'persentase': '4,03%',
              'persentaseValue': 4.03,
              'garisMiskin': 'Rp 671.936',
              'indeksKedalaman': '0,59',
              'indeksKeparahan': '0,12',
            }),
            2025: PovertyData.fromMap(2025, const {
              'pendudukMiskin': '74,36 Ribu',
              'pendudukMiskinValue': 74.36,
              'persentase': '3,80%',
              'persentaseValue': 3.8,
              'garisMiskin': 'Rp 709.785',
              'indeksKedalaman': '0,41',
              'indeksKeparahan': '0,05',
            }),
          };
        }
      }

      if (mounted) {
        setState(() {
          _cachedSortedYears = yearlyData.keys.toList()
            ..sort((a, b) => a.compareTo(b));

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
          errorMessage = 'Gagal memuat data: $e';
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
                        const CircularProgressIndicator(color: bpsBlue),
                        SizedBox(height: sizing.sectionSpacing - 8),
                        Text(
                          'Memuat data kemiskinan...',
                          style: TextStyle(
                            fontSize: sizing.categoryLabelFontSize,
                            color: bpsTextSecondary,
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
                                color: bpsRed,
                              ),
                              SizedBox(height: sizing.sectionSpacing - 8),
                              Text(
                                'Terjadi Kesalahan',
                                style: TextStyle(
                                  fontSize: sizing.sectionTitleSize,
                                  fontWeight: FontWeight.bold,
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
                              SizedBox(height: sizing.sectionSpacing),
                              ElevatedButton.icon(
                                onPressed: _loadData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Coba Lagi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: bpsBlue,
                                  foregroundColor: bpsCardBg,
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
                        onYearSelected: _changeYear,
                        yearScrollController: _yearScrollController,
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
    return CategoryHeader(
      overline: 'INDIKATOR SOSIAL',
      title: 'Data Kemiskinan',
      icon: Icons.volunteer_activism_rounded,
      accent: bpsGreen,
      isSmall: isSmallScreen,
    );
  }
}

// Extracted content widget for better performance
class _KemiskinanScreenContent extends StatelessWidget {
  final int selectedYear;
  final Map<int, PovertyData> yearlyData;
  final List<int> cachedSortedYears;
  final ValueChanged<int> onYearSelected;
  final ScrollController yearScrollController;
  final ResponsiveSizing sizing;
  final bool isSmallScreen;

  const _KemiskinanScreenContent({
    required this.selectedYear,
    required this.yearlyData,
    required this.cachedSortedYears,
    required this.onYearSelected,
    required this.yearScrollController,
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
                'Data kemiskinan belum tersedia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: sizing.categoryLabelFontSize,
                  color: bpsTextSecondary,
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
              _buildYearSelector(),
              SizedBox(height: sizing.sectionSpacing),
              _buildHero(context, sizing, isSmallScreen),
              SizedBox(height: sizing.sectionSpacing),
              SpineSection(
                number: '01',
                overline: 'Indikator',
                title: 'Indikator Utama Kemiskinan',
                subtitle: 'Ketuk untuk penjelasan',
                accent: bpsGreen,
                surface: false,
                isFirst: true,
                isSmall: isSmallScreen,
                child: _buildPovertyStatsGrid(context, currentData),
              ),
              SpineSection(
                number: '02',
                overline: 'Tren',
                title: 'Jumlah Penduduk Miskin',
                subtitle: 'Ribu jiwa • Kota Semarang',
                accent: bpsGreen,
                surface: false,
                isSmall: isSmallScreen,
                child: _PovertyTrendChart(
                accentColor: bpsRed,
                years: cachedSortedYears,
                values: cachedSortedYears
                    .map((y) => yearlyData[y]!.pendudukMiskinValue)
                    .toList(),
                displayValues: cachedSortedYears
                    .map((y) => yearlyData[y]!.pendudukMiskinDisplay)
                    .toList(),
                minY: 72,
                maxY: 86,
                yInterval: 2,
                yAxisSuffix: ' Ribu',
                indicatorTitle: 'Jumlah Penduduk Miskin',
                indicatorValue: currentData.pendudukMiskinDisplay,
                selectedYear: selectedYear,
                baseYear: cachedSortedYears.first,
                sizing: sizing,
                isSmallScreen: isSmallScreen,
                ),
              ),
              SpineSection(
                number: '03',
                overline: 'Tren',
                title: 'Persentase Kemiskinan',
                subtitle: 'Persen • Kota Semarang',
                accent: bpsGreen,
                surface: false,
                isSmall: isSmallScreen,
                child: _PovertyTrendChart(
                accentColor: bpsOrange,
                years: cachedSortedYears,
                values: cachedSortedYears
                    .map((y) => yearlyData[y]!.persentaseValue)
                    .toList(),
                displayValues: cachedSortedYears
                    .map((y) => yearlyData[y]!.persentaseDisplay)
                    .toList(),
                minY: 3.6,
                maxY: 4.7,
                yInterval: 0.2,
                yAxisSuffix: '%',
                indicatorTitle: 'Persentase Kemiskinan',
                indicatorValue: currentData.persentaseDisplay,
                selectedYear: selectedYear,
                baseYear: cachedSortedYears.first,
                sizing: sizing,
                isSmallScreen: isSmallScreen,
                ),
              ),
              SpineSection(
                number: '04',
                overline: 'Metodologi',
                title: 'Metodologi Pengukuran',
                accent: bpsGreen,
                surface: false,
                isSmall: isSmallScreen,
                child: _PovertyInformationPanel(
                    sizing: sizing, isSmallScreen: isSmallScreen),
              ),
              SpineSection(
                overline: 'Ringkasan',
                title: 'Kesimpulan',
                accent: bpsGreen,
                surface: false,
                isLast: true,
                isSmall: isSmallScreen,
                child: _buildKesimpulanCard(context, sizing, isSmallScreen),
              ),
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
      garisKemiskinan: latestData.garisMiskin,
      indeksKedalaman: latestData.indeksKedalaman,
    );

    return KesimpulanWidget(
      title: 'Kemiskinan Kota Semarang',
      conclusion: conclusionData['conclusion'] as String,
      status: conclusionData['status'] as KesimpulanStatus,
      sizing: sizing,
      isSmallScreen: isSmallScreen,
      additionalPoints: (conclusionData['additionalPoints'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Widget _buildYearSelector() {
    return YearRail(
      years: [...cachedSortedYears]..sort(),
      selected: selectedYear,
      onSelect: onYearSelected,
      accent: bpsGreen,
      isSmall: isSmallScreen,
      controller: yearScrollController,
    );
  }

  Widget _buildHero(BuildContext context, ResponsiveSizing sizing, bool isSmallScreen) {
    final data = yearlyData[selectedYear];
    if (data == null) return const SizedBox.shrink();
    final sorted = [...cachedSortedYears]..sort();
    final spark = sorted.map((y) => yearlyData[y]?.persentaseValue ?? 0.0).toList();
    return IndicatorHero(
      overline: 'PERSENTASE KEMISKINAN',
      value: data.persentaseDisplay,
      subtitle: 'Tingkat kemiskinan • Kota Semarang',
      badge: 'Tahun $selectedYear',
      accent: bpsGreen,
      sparkline: spark.length > 1 ? spark : null,
      isSmall: isSmallScreen,
      facts: [
        HeroFact('Penduduk Miskin', data.pendudukMiskinDisplay),
        HeroFact('Garis Kemiskinan', data.garisMiskin),
      ],
    );
  }

  Widget _buildPovertyStatsGrid(BuildContext context, PovertyData data) {
    return SectionPanel(
      isSmall: isSmallScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildCompactIndicatorRow(
                context: context,
                value: data.pendudukMiskinDisplay,
                label: 'Penduduk Miskin',
                color: bpsRed,
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
                color: bpsOrange,
                icon: Icons.attach_money,
                description:
                    'Garis Kemiskinan merupakan penjumlahan dari Garis Kemiskinan Makanan (GKM) dan Garis Kemiskinan Bukan Makanan (GKBM). Penduduk dengan pengeluaran di bawah GK dikategorikan miskin.',
              ),
              _buildIndicatorDivider(),
              _buildCompactIndicatorRow(
                context: context,
                value: data.persentaseDisplay,
                label: 'Persentase (P0)',
                color: bpsBlue,
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
                    color: bpsTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              // Value (flex: 2, right-aligned)
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
    showDialog(
      context: context,
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
                            const SizedBox(height: 4),
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
                      InkWell(
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
                                  color: bpsTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: isDialogSmall ? 8 : 12),
                              Text(
                                value,
                                style: TextStyle(
                                  fontSize: isDialogSmall ? 28 : 32,
                                  fontWeight: FontWeight.w800,
                                  color: bpsTextPrimary,
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
                            color: bpsBackground,
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
}

// Year selector widget
// Unified poverty trend chart widget - eliminates 400+ lines of duplication
class _PovertyTrendChart extends StatelessWidget {
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
              color: bpsTextSecondary,
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

    return SectionPanel(
      isSmall: isSmallScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header now supplied by the spine section
          RepaintBoundary(
            child: SizedBox(
              height: isSmallScreen ? 220 : 240,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: bpsBorder,
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
                              color: bpsTextSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
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
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: minY,
                  maxY: maxY,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) => bpsCardBg,
                      tooltipRoundedRadius: 8,
                      tooltipBorder:
                          BorderSide(color: Colors.grey[300]!),
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
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: isSmallScreen ? 3 : 5,
                            color: accentColor,
                            strokeWidth: isSmallScreen ? 1.5 : 2.5,
                            strokeColor: bpsCardBg,
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
                          color: bpsTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedYear == baseYear
                            ? indicatorValue
                            : '${NumberFormatUtils.formatDecimal(perubahan.abs())}$yAxisSuffix',
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
                  const SizedBox(width: 16),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 10 : 12,
                      vertical: isSmallScreen ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive ? bpsGreen : bpsRed,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (isPositive ? bpsGreen : bpsRed)
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
                        const SizedBox(width: 4),
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
    return SectionPanel(
      isSmall: isSmallScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header now supplied by the spine section
          Text(
            'BPS mengukur kemiskinan menggunakan pendekatan kebutuhan dasar (basic need approach). Kemiskinan dipandang sebagai ketidakmampuan ekonomi seseorang dalam memenuhi kebutuhan dasar makanan maupun bukan makanan.',
            style: TextStyle(
              fontSize: sizing.categoryLabelFontSize,
              color: bpsTextPrimary,
              height: 1.5,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: bpsCardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu_rounded,
                      color: bpsGreen,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    SizedBox(width: sizing.itemSpacing - 4),
                    Expanded(
                      child: Text(
                        'Garis Kemiskinan Makanan (GKM)',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w700,
                          color: bpsGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Mencerminkan nilai pengeluaran kebutuhan minimum makanan yang disetarakan dengan 2.100 kalori per kapita per hari.',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: bpsTextSecondary,
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
              color: bpsCardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.home_outlined,
                      color: bpsOrange,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    SizedBox(width: sizing.itemSpacing - 4),
                    Expanded(
                      child: Text(
                        'Garis Kemiskinan Bukan Makanan (GKBM)',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w700,
                          color: bpsOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Mencakup kebutuhan minimum untuk perumahan, sandang, pendidikan, dan kesehatan.',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: bpsTextSecondary,
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
            color: bpsBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: sizing.categoryLabelFontSize,
              color: bpsTextPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
