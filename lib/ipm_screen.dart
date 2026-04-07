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
const Color _bpsPurple = Color(0xFF7B1FA2);
const Color _bpsBackground = Color(0xFFF5F5F5);
const Color _bpsCardBg = Color(0xFFFFFFFF);
const Color _bpsTextPrimary = Color(0xFF333333);
const Color _bpsTextSecondary = Color(0xFF808080);
const Color _bpsTextLabel = Color(0xFFA0A0A0);
const Color _bpsBorder = Color(0xFFE0E0E0);
const Color _bpsTeal = Color(0xFF1ABC9C);

class IpmScreen extends StatefulWidget {
  const IpmScreen({super.key});

  @override
  State<IpmScreen> createState() => _IpmScreenState();
}

class _IpmScreenState extends State<IpmScreen>
    with AutomaticKeepAliveClientMixin {
  int selectedYear = 2024;
  Map<int, Map<String, dynamic>> ipmData = {};
  Map<int, Map<String, dynamic>> komponenData = {};
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

      final savedIpmData = prefs.getString('ipm_data');
      if (savedIpmData != null) {
        final decoded = json.decode(savedIpmData) as Map<String, dynamic>;
        ipmData = decoded.map((key, value) =>
            MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));
      } else {
        _initializeDefaultIpmData();
      }

      final savedKomponenData = prefs.getString('ipm_komponen_data');
      if (savedKomponenData != null) {
        final decoded = json.decode(savedKomponenData) as Map<String, dynamic>;
        komponenData = decoded.map((key, value) =>
            MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));
      } else {
        _initializeDefaultKomponenData();
      }

      if (mounted) {
        setState(() {
          _cachedSortedYears = ipmData.keys.toList()..sort();
          if (_cachedSortedYears.isNotEmpty) {
            selectedYear = _cachedSortedYears.last;
          }
          errorMessage = null;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      _initializeDefaultIpmData();
      _initializeDefaultKomponenData();
      if (mounted) {
        setState(() {
          _cachedSortedYears = ipmData.keys.toList()..sort();
          if (_cachedSortedYears.isNotEmpty) {
            selectedYear = _cachedSortedYears.last;
          }
          errorMessage = 'Gagal memuat data: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  void _initializeDefaultIpmData() {
    ipmData = {
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
        'pengeluaran': 17250.00,
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
  }

  void _initializeDefaultKomponenData() {
    komponenData = {
      2020: {'ipmNasional': 72.81, 'ipmJateng': 71.88, 'ipmSemarang': 83.05},
      2021: {'ipmNasional': 73.16, 'ipmJateng': 72.17, 'ipmSemarang': 83.55},
      2022: {'ipmNasional': 73.77, 'ipmJateng': 72.80, 'ipmSemarang': 84.08},
      2023: {'ipmNasional': 74.39, 'ipmJateng': 73.39, 'ipmSemarang': 84.43},
      2024: {'ipmNasional': 75.02, 'ipmJateng': 73.87, 'ipmSemarang': 85.24},
      2025: {'ipmNasional': 75.90, 'ipmJateng': 74.77, 'ipmSemarang': 85.80},
    };
  }

  String _formatNumber(double number) {
    return NumberFormatUtils.formatCompact(number);
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
                        const CircularProgressIndicator(color: _bpsOrange),
                        SizedBox(height: sizing.sectionSpacing - 8),
                        Text(
                          'Memuat data IPM...',
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
                                  backgroundColor: _bpsOrange,
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
                    : _IpmScreenContent(
                        selectedYear: selectedYear,
                        ipmData: ipmData,
                        komponenData: komponenData,
                        cachedSortedYears: _cachedSortedYears,
                        onYearSelected: (year) =>
                            setState(() => selectedYear = year),
                        sizing: sizing,
                        isSmallScreen: isSmallScreen,
                        formatNumber: _formatNumber,
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
        color: _bpsOrange,
        boxShadow: [
          BoxShadow(
            color: _bpsOrange.withOpacity(0.2),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Indeks Pembangunan Manusia',
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
              Icon(
                Icons.trending_up_rounded,
                color: Colors.white,
                size: isSmallScreen ? 20 : 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extracted content widget for better performance
class _IpmScreenContent extends StatelessWidget {
  final int selectedYear;
  final Map<int, Map<String, dynamic>> ipmData;
  final Map<int, Map<String, dynamic>> komponenData;
  final List<int> cachedSortedYears;
  final ValueChanged<int> onYearSelected;
  final ResponsiveSizing sizing;
  final bool isSmallScreen;
  final String Function(double) formatNumber;

  const _IpmScreenContent({
    required this.selectedYear,
    required this.ipmData,
    required this.komponenData,
    required this.cachedSortedYears,
    required this.onYearSelected,
    required this.sizing,
    required this.isSmallScreen,
    required this.formatNumber,
  });

  @override
  Widget build(BuildContext context) {
    if (ipmData.isEmpty) {
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
                'Data IPM belum tersedia',
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

    final currentData = ipmData[selectedYear]!;

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
              _buildIndicatorsCard(context, currentData),
              SizedBox(height: sizing.sectionSpacing),
              _IpmComparisonChart(
                komponenData: komponenData,
                cachedSortedYears: cachedSortedYears,
                sizing: sizing,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: sizing.sectionSpacing),
              _IpmInformationPanel(
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
    if (ipmData.isEmpty || cachedSortedYears.length < 2) {
      return const SizedBox.shrink();
    }

    final latestYear = cachedSortedYears.last;
    final firstYear = cachedSortedYears.first;
    final latestData = ipmData[latestYear]!;
    final firstData = ipmData[firstYear]!;
    final latestKomponen = komponenData[latestYear];

    final conclusionData = KesimpulanGenerator.generateIPMConclusion(
      latestYear: latestYear,
      firstYear: firstYear,
      latestIPM: latestData['ipm'] as double,
      firstIPM: firstData['ipm'] as double,
      nationalAverage: latestKomponen?['ipmNasional'] as double?,
      provincialAverage: latestKomponen?['ipmJateng'] as double?,
    );

    return KesimpulanWidget(
      title: 'Indeks Pembangunan Manusia',
      conclusion: conclusionData['conclusion'] as String,
      status: conclusionData['status'] as KesimpulanStatus,
      sizing: sizing,
      isSmallScreen: isSmallScreen,
      additionalPoints: conclusionData['additionalPoints'] as List<String>?,
    );
  }

  Widget _buildIndicatorsCard(BuildContext context, Map<String, dynamic> data) {
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
              Icon(
                Icons.analytics_rounded,
                color: _bpsOrange,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  'Indikator Utama IPM',
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
                    color: _bpsOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: _bpsOrange,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap untuk detail',
                        style: TextStyle(
                          fontSize: 12,
                          color: _bpsOrange,
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
                value: NumberFormatUtils.formatDecimal(data['ipm'] as double,
                    decimalPlaces: 2),
                label: 'IPM',
                color: _bpsGreen,
                icon: Icons.trending_up_rounded,
                description:
                    'Indeks Pembangunan Manusia (IPM) mengukur capaian pembangunan manusia berbasis sejumlah komponen dasar kualitas hidup meliputi umur panjang dan hidup sehat, pengetahuan, dan standar hidup layak.',
                isFirst: true,
              ),
              _buildIndicatorDivider(),
              _buildCompactIndicatorRow(
                context: context,
                value:
                    '${NumberFormatUtils.formatDecimal(data['uhh'] as double, decimalPlaces: 2)} Tahun',
                label: 'UHH',
                color: _bpsRed,
                icon: Icons.favorite,
                description:
                    'Umur Harapan Hidup (UHH) saat lahir didefinisikan sebagai rata-rata perkiraan banyak tahun yang dapat ditempuh oleh seseorang sejak lahir. UHH mencerminkan derajat kesehatan suatu masyarakat.',
              ),
              _buildIndicatorDivider(),
              _buildCompactIndicatorRow(
                context: context,
                value:
                    '${NumberFormatUtils.formatDecimal(data['hls'] as double, decimalPlaces: 2)} Tahun',
                label: 'HLS',
                color: _bpsBlue,
                icon: Icons.school,
                description:
                    'Harapan Lama Sekolah (HLS) didefinisikan sebagai lamanya sekolah (dalam tahun) yang diharapkan akan dirasakan oleh anak pada umur tertentu di masa mendatang.',
              ),
              _buildIndicatorDivider(),
              _buildCompactIndicatorRow(
                context: context,
                value:
                    '${NumberFormatUtils.formatDecimal(data['rls'] as double, decimalPlaces: 2)} Tahun',
                label: 'RLS',
                color: _bpsGreen,
                icon: Icons.auto_stories,
                description:
                    'Rata-rata Lama Sekolah (RLS) didefinisikan sebagai jumlah tahun yang digunakan oleh penduduk dalam menjalani pendidikan formal.',
              ),
              _buildIndicatorDivider(),
              _buildCompactIndicatorRow(
                context: context,
                value: formatNumber(data['pengeluaran']),
                label: 'Pengeluaran per Kapita',
                color: _bpsOrange,
                icon: Icons.monetization_on,
                description:
                    'Pengeluaran per kapita disesuaikan merupakan rata-rata pengeluaran per kapita per tahun yang telah disesuaikan dengan paritas daya beli (Purchasing Power Parity).',
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
                      Icon(
                        icon,
                        color: Colors.white,
                        size: isDialogSmall ? 20 : 24,
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
              Icon(
                Icons.calendar_today_rounded,
                color: _bpsOrange,
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
          Wrap(
            spacing: isSmallScreen ? 8 : 12,
            runSpacing: isSmallScreen ? 8 : 12,
            children: years.map((year) {
              final isSelected = year == selectedYear;
              return Material(
                color: isSelected ? _bpsOrange : _bpsBackground,
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
                        color: isSelected ? _bpsOrange : _bpsBorder,
                        width: isSelected ? 2 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _bpsOrange.withOpacity(0.3),
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

// IPM Comparison Chart widget
class _IpmComparisonChart extends StatelessWidget {
  final Map<int, Map<String, dynamic>> komponenData;
  final List<int> cachedSortedYears;
  final ResponsiveSizing sizing;
  final bool isSmallScreen;

  const _IpmComparisonChart({
    required this.komponenData,
    required this.cachedSortedYears,
    required this.sizing,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    if (komponenData.isEmpty) return const SizedBox.shrink();

    final List<FlSpot> nasionalSpots = [];
    final List<FlSpot> jatengSpots = [];
    final List<FlSpot> semarangSpots = [];
    final List<String> yearLabels = [];

    for (int i = 0; i < cachedSortedYears.length; i++) {
      final year = cachedSortedYears[i];
      if (!komponenData.containsKey(year)) continue;
      final data = komponenData[year]!;
      nasionalSpots.add(FlSpot(i.toDouble(), data['ipmNasional'].toDouble()));
      jatengSpots.add(FlSpot(i.toDouble(), data['ipmJateng'].toDouble()));
      semarangSpots.add(FlSpot(i.toDouble(), data['ipmSemarang'].toDouble()));
      yearLabels.add(year.toString());
    }

    if (semarangSpots.isEmpty) return const SizedBox.shrink();

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
              Icon(
                Icons.show_chart,
                color: _bpsGreen,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perbandingan IPM antar Wilayah',
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
                      'Tren dari tahun ${cachedSortedYears.first} hingga ${cachedSortedYears.last}',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Semarang', _bpsGreen),
              const SizedBox(width: 12),
              _buildLegendItem('Jateng', _bpsBlue),
              const SizedBox(width: 12),
              _buildLegendItem('Nasional', _bpsOrange),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          RepaintBoundary(
            child: SizedBox(
              height: isSmallScreen ? 220 : 240,
              child: LineChart(
                LineChartData(
                  minY: 70,
                  maxY: 88,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
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
                        reservedSize: isSmallScreen ? 38 : 45,
                        interval: 4,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            NumberFormatUtils.formatDecimal(value,
                                decimalPlaces: 0),
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
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < yearLabels.length) {
                            return Padding(
                              padding:
                                  EdgeInsets.only(top: isSmallScreen ? 6 : 8),
                              child: Text(
                                yearLabels[index],
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
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
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
                        return touchedSpots.map((barSpot) {
                          final index = barSpot.x.toInt();
                          if (index >= 0 && index < yearLabels.length) {
                            String label = barSpot.barIndex == 0
                                ? 'Semarang'
                                : (barSpot.barIndex == 1
                                    ? 'Jateng'
                                    : 'Nasional');
                            Color color = barSpot.barIndex == 0
                                ? _bpsGreen
                                : (barSpot.barIndex == 1
                                    ? _bpsBlue
                                    : _bpsOrange);
                            return LineTooltipItem(
                              '${yearLabels[index]}\n$label: ${NumberFormatUtils.formatDecimal(barSpot.y, decimalPlaces: 2)}',
                              TextStyle(
                                color: color,
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
                    _buildLineData(semarangSpots, _bpsGreen),
                    _buildLineData(jatengSpots, _bpsBlue),
                    _buildLineData(nasionalSpots, _bpsOrange),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLineData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: isSmallScreen ? 2.5 : 3.5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: isSmallScreen ? 3 : 5,
            color: color,
            strokeWidth: isSmallScreen ? 1.5 : 2.5,
            strokeColor: _bpsCardBg,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.02),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 12,
        vertical: isSmallScreen ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
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
              fontSize: isSmallScreen ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: _bpsTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Information panel widget
class _IpmInformationPanel extends StatelessWidget {
  final ResponsiveSizing sizing;
  final bool isSmallScreen;

  const _IpmInformationPanel({
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
              Icon(
                Icons.info_outline_rounded,
                color: _bpsOrange,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  'Tentang IPM',
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
            'Indeks Pembangunan Manusia (IPM) mengukur capaian pembangunan manusia berbasis dimensi dasar: umur panjang dan hidup sehat (UHH), pengetahuan (HLS & RLS), dan standar hidup layak (pengeluaran per kapita).',
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
                      Icons.check_circle,
                      color: _bpsGreen,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    SizedBox(width: sizing.itemSpacing - 4),
                    Expanded(
                      child: Text(
                        'Kategori IPM',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w700,
                          color: _bpsGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'IPM Semarang termasuk kategori SANGAT TINGGI (>80). IPM dihitung menggunakan rata-rata geometrik dari indeks kesehatan, pendidikan, dan pengeluaran.',
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
                      Icons.school_outlined,
                      color: _bpsBlue,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    SizedBox(width: sizing.itemSpacing - 4),
                    Expanded(
                      child: Text(
                        'Dimensi Pengetahuan',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w700,
                          color: _bpsBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Diukur melalui Harapan Lama Sekolah (HLS) dan Rata-rata Lama Sekolah (RLS) penduduk usia 25 tahun ke atas.',
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
            'IPM dihitung dengan metode baru sejak 2010 menggunakan rata-rata geometrik.',
            sizing,
          ),
          SizedBox(height: sizing.itemSpacing - 2),
          _buildBulletPoint(
            'Pengeluaran per kapita disesuaikan menggunakan paritas daya beli (PPP).',
            sizing,
          ),
          SizedBox(height: sizing.itemSpacing - 2),
          _buildBulletPoint(
            'Data bersumber dari Badan Pusat Statistik (BPS) Kota Semarang.',
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
            color: _bpsOrange,
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
