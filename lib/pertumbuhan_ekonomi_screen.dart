import 'package:lawang/number_format_utils.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ekonomi_data.dart';
import 'responsive_sizing.dart';
import 'models/pdrb_ranking.dart';
import 'services/pdrb_ranking_service.dart';
import 'kesimpulan_widget.dart';
import 'app_theme.dart';
import 'widgets/section_kit.dart';

class PertumbuhanEkonomiScreen extends StatefulWidget {
  const PertumbuhanEkonomiScreen({super.key});

  @override
  State<PertumbuhanEkonomiScreen> createState() =>
      _PertumbuhanEkonomiScreenState();
}

class _PertumbuhanEkonomiScreenState extends State<PertumbuhanEkonomiScreen>
    with AutomaticKeepAliveClientMixin {
  final dataManager = EkonomiDataManager();
  late int selectedYear;
  late List<int> availableYears;
  late Timer _debounceTimer;
  final ScrollController _yearScrollController = ScrollController();
  List<PDRBRanking> _rankings = [];
  bool _isLoadingRankings = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    dataManager.loadFromGitHub();
    availableYears = dataManager.getAvailableYears()
      ..sort((a, b) => a.compareTo(b));
    selectedYear = availableYears.isNotEmpty ? availableYears.last : 2024;
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_yearScrollController.hasClients) {
        _yearScrollController.jumpTo(
          _yearScrollController.position.maxScrollExtent,
        );
      }
    });
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    try {
      final rankings = await PDRBRankingService.getTopN(10);
      if (mounted) {
        setState(() {
          _rankings = rankings;
          _isLoadingRankings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRankings = false;
        });
      }
    }
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
        setState(() {
          selectedYear = year;
        });
      }
    });
  }

  EkonomiData? get currentData =>
      dataManager.getDataByYear(selectedYear.toString());

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Parse an Indonesian-formatted percentage string ("6,49%") to a double.
  double _parseGrowth(String raw) {
    final cleaned = raw.replaceAll('%', '').replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Format a double back to Indonesian decimal notation ("6.49" → "6,49").
  String _fmt(double v, {int decimals = 2}) =>
      v.toStringAsFixed(decimals).replaceAll('.', ',');

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sizing = ResponsiveSizing(context);
    final isSmallScreen = sizing.isVerySmall || sizing.isSmall;

    if (availableYears.isEmpty || currentData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
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
                          fontFamily: 'PlusJakartaSans',
                          fontSize: sizing.sectionTitleSize,
                          fontWeight: FontWeight.bold,
                          color: bpsTextPrimary,
                        ),
                      ),
                      SizedBox(height: sizing.itemSpacing),
                      Text(
                        'Data ekonomi belum tersedia',
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
      backgroundColor: Colors.white,
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
                      _buildYearRail(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildHero(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      SpineSection(
                        number: '01',
                        overline: 'Indikator',
                        title: 'Indikator Utama',
                        subtitle: 'Ketuk untuk penjelasan',
                        accent: bpsBlue,
                        isFirst: true,
                        isSmall: isSmallScreen,
                        child: _buildMainIndicators(sizing, isSmallScreen),
                      ),
                      SpineSection(
                        number: '02',
                        overline: 'Rincian',
                        title: 'PDRB per Kapita',
                        subtitle: 'Atas dasar harga berlaku',
                        accent: bpsBlue,
                        isSmall: isSmallScreen,
                        child: _buildPDRBSection(sizing, isSmallScreen),
                      ),
                      SpineSection(
                        number: '03',
                        overline: 'Tren',
                        title: 'Tren Pertumbuhan',
                        subtitle: '2020 – 2025 (%)',
                        accent: bpsBlue,
                        framed: false,
                        isSmall: isSmallScreen,
                        child: _buildChartSection(sizing, isSmallScreen),
                      ),
                      SpineSection(
                        number: '04',
                        overline: 'Peringkat',
                        title: 'Peringkat PDRB',
                        subtitle: 'Top 10 • Jawa Tengah',
                        accent: bpsBlue,
                        isSmall: isSmallScreen,
                        child: _buildRankingSection(sizing, isSmallScreen),
                      ),
                      SpineSection(
                        overline: 'Ringkasan',
                        title: 'Kesimpulan',
                        accent: bpsBlue,
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

  Widget _buildHeader(
      BuildContext context, ResponsiveSizing sizing, bool isSmallScreen) {
    return CategoryHeader(
      overline: 'INDIKATOR EKONOMI',
      title: 'Pertumbuhan Ekonomi',
      icon: Icons.show_chart_rounded,
      accent: bpsBlue,
      isSmall: isSmallScreen,
    );
  }

  // ── Year rail ──────────────────────────────────────────────────────────────

  Widget _buildYearRail(ResponsiveSizing sizing, bool isSmallScreen) {
    return YearRail(
      years: availableYears,
      selected: selectedYear,
      onSelect: _changeYear,
      accent: bpsBlue,
      isSmall: isSmallScreen,
      controller: _yearScrollController,
    );
  }

  // ── Hero (headline indicator) ────────────────────────────────────────────

  Widget _buildHero(ResponsiveSizing sizing, bool isSmallScreen) {
    final data = currentData!;
    final cur = _parseGrowth(data.pertumbuhanEkonomi);
    final prevData = dataManager.getDataByYear((selectedYear - 1).toString());
    final delta = prevData != null
        ? cur - _parseGrowth(prevData.pertumbuhanEkonomi)
        : null;
    final jatengLatest =
        data.jatengData.isNotEmpty ? data.jatengData.last.value : null;

    return IndicatorHero(
      overline: 'PERTUMBUHAN EKONOMI',
      value: data.pertumbuhanEkonomi,
      subtitle: 'PDRB atas dasar harga konstan • Kota Semarang',
      badge: 'Tahun $selectedYear',
      accent: bpsBlue,
      delta: delta,
      sparkline: data.semarangData.map((e) => e.value).toList(),
      isSmall: isSmallScreen,
      facts: [
        HeroFact('Jawa Tengah',
            jatengLatest != null ? '${_fmt(jatengLatest)}%' : '–'),
        HeroFact('Peringkat Provinsi', data.vsJawaTengah),
      ],
    );
  }

  // ── Shared section chrome (delegates to section_kit) ────────────────────────

  // Section chrome now comes from the editorial spine (SpineSection): the
  // per-section panel + header are supplied by the wrapper, so these legacy
  // helpers collapse to pass-throughs to keep builder bodies untouched.
  Widget _panel({required Widget child, bool isSmallScreen = false}) => child;

  Widget _sectionHead({
    required String title,
    String? subtitle,
    Color accent = bpsBlue,
    bool isSmallScreen = false,
  }) =>
      const SizedBox.shrink();

  // ── Main indicators ────────────────────────────────────────────────────────

  Widget _buildMainIndicators(ResponsiveSizing sizing, bool isSmallScreen) {
    final data = currentData!;

    return _panel(
      isSmallScreen: isSmallScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHead(
            title: 'Indikator Utama',
            subtitle: 'Ketuk untuk penjelasan',
            isSmallScreen: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          _buildCompactIndicatorRow(
            context: context,
            value: data.pertumbuhanEkonomi,
            label: 'Pertumbuhan Ekonomi',
            color: bpsBlue,
            icon: Icons.trending_up_rounded,
            description:
                'Pertumbuhan ekonomi menunjukkan peningkatan aktivitas ekonomi dalam periode tertentu. Angka positif menandakan ekonomi sedang berkembang.',
          ),
          _buildIndicatorDivider(isSmallScreen),
          _buildCompactIndicatorRow(
            context: context,
            value: data.kontribusiPDRB,
            label: 'Kontribusi PDRB',
            color: bpsGreen,
            icon: Icons.pie_chart_rounded,
            description:
                'Kontribusi PDRB menunjukkan seberapa besar peran wilayah ini terhadap produk domestik regional bruto.',
          ),
          _buildIndicatorDivider(isSmallScreen),
          _buildCompactIndicatorRow(
            context: context,
            value: data.sektorIndustri,
            label: 'Sektor Industri Pengolahan',
            color: bpsOrange,
            icon: Icons.factory_rounded,
            description:
                'Sektor Industri Pengolahan merupakan sektor terbesar kontributor PDRB Kota Semarang.',
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
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withOpacity(0.08),
        highlightColor: color.withOpacity(0.04),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 6 : 8,
            vertical: isSmallScreen ? 10 : 12,
          ),
          child: Row(
            children: [
              Container(
                width: isSmallScreen ? 34 : 38,
                height: isSmallScreen ? 34 : 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: isSmallScreen ? 18 : 20),
              ),
              SizedBox(width: isSmallScreen ? 10 : 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14.5,
                    fontWeight: FontWeight.w600,
                    color: bpsTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: isSmallScreen ? 17 : 19,
                  fontWeight: FontWeight.w800,
                  color: bpsTextPrimary,
                  letterSpacing: -0.4,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              SizedBox(width: isSmallScreen ? 2 : 4),
              Icon(
                Icons.chevron_right_rounded,
                color: bpsTextLabel,
                size: isSmallScreen ? 18 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorDivider(bool isSmallScreen) {
    return Divider(
      height: 1,
      thickness: 1,
      color: bpsBorder.withOpacity(0.5),
      indent: isSmallScreen ? 50 : 58,
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
                                fontFamily: 'PlusJakartaSans',
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
                                  fontFamily: 'PlusJakartaSans',
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

  // ── PDRB per kapita ──────────────────────────────────────────────────────

  Widget _buildPDRBSection(ResponsiveSizing sizing, bool isSmallScreen) {
    final data = currentData!;

    return _panel(
      isSmallScreen: isSmallScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHead(
            title: 'PDRB per Kapita',
            subtitle: 'Atas dasar harga berlaku',
            isSmallScreen: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 14 : 18),
          _buildPerKapitaCard(data, isSmallScreen),
          SizedBox(height: isSmallScreen ? 10 : 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildPerKapitaStat(
                    value: data.vsJawaTengah,
                    label: 'vs Jawa Tengah',
                    icon: Icons.emoji_events_rounded,
                    color: bpsGreen,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
                SizedBox(width: sizing.gridSpacing),
                Expanded(
                  child: _buildPerKapitaStat(
                    value: data.tpt,
                    label: 'Tingkat Pengangguran',
                    icon: Icons.work_off_rounded,
                    color: bpsOrange,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Headline "feature" card for PDRB per kapita — a filled blue field with a
  /// large faint watermark, year pill and oversized white value.
  Widget _buildPerKapitaCard(EkonomiData data, bool isSmallScreen) {
    final pad = isSmallScreen ? 18.0 : 22.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF38A8E0), bpsBlue, Color(0xFF1B6C9C)],
            stops: [0.0, 0.45, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: bpsBlue.withOpacity(0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Oversized watermark, bleeding off the bottom-right edge.
            Positioned(
              right: -20,
              bottom: -26,
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: isSmallScreen ? 124 : 150,
                color: Colors.white.withOpacity(0.10),
              ),
            ),
            // Soft top-left sheen for depth.
            Positioned(
              left: -40,
              top: -50,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'PDRB PER KAPITA',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10.5 : 11.5,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 9 : 11,
                          vertical: isSmallScreen ? 4 : 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Text(
                          '${data.tahun}',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: isSmallScreen ? 11 : 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 14 : 18),
                  Text(
                    data.pdrbPerKapita,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: isSmallScreen ? 27 : 33,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1.0,
                      height: 1.05,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 7 : 9),
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Atas dasar harga berlaku',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11.5 : 12.5,
                          color: Colors.white.withOpacity(0.82),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Supporting stat tile paired with the per-kapita feature card. Soft tinted
  /// field, filled icon chip, faint watermark — echoes the hero's language.
  Widget _buildPerKapitaStat({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSmallScreen,
  }) {
    final pad = isSmallScreen ? 13.0 : 15.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
          ),
          border: Border.all(color: color.withOpacity(0.22), width: 1.5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -14,
              bottom: -16,
              child: Icon(
                icon,
                size: isSmallScreen ? 64 : 76,
                color: color.withOpacity(0.08),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isSmallScreen ? 30 : 34,
                    height: isSmallScreen ? 30 : 34,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isSmallScreen ? 16 : 18,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 14),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: isSmallScreen ? 19 : 22,
                      fontWeight: FontWeight.w800,
                      color: bpsTextPrimary,
                      letterSpacing: -0.6,
                      height: 1.0,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 3 : 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 12,
                      color: bpsTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Trend chart ──────────────────────────────────────────────────────────

  Widget _buildChartSection(ResponsiveSizing sizing, bool isSmallScreen) {
    final data = currentData!;
    final double chartHeight = isSmallScreen ? 180 : 220;

    return _panel(
      isSmallScreen: isSmallScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHead(
            title: 'Tren Pertumbuhan',
            subtitle: '2020 – 2025 (%)',
            isSmallScreen: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Wrap(
            spacing: isSmallScreen ? 8 : 12,
            runSpacing: isSmallScreen ? 8 : 12,
            children: [
              _buildLegendItem('Kota Semarang', bpsBlue, isSmallScreen),
              _buildLegendItem('Jawa Tengah', bpsOrange, isSmallScreen),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          SizedBox(
            height: chartHeight,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 1,
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
                      reservedSize: isSmallScreen ? 35 : 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            '${NumberFormatUtils.formatValue(value, decimalPlaces: 1)}%',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 9 : 10,
                              color: bpsTextSecondary,
                              fontWeight: FontWeight.w500,
                            ),
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
                        if (index >= 0 && index < data.semarangData.length) {
                          final year = data.semarangData[index].year;
                          final label = sizing.isVerySmall
                              ? "'${year.toString().substring(2)}"
                              : year.toString();
                          return Padding(
                            padding:
                                EdgeInsets.only(top: isSmallScreen ? 6 : 8),
                            child: Text(
                              label,
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
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.white,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final label =
                            spot.barIndex == 0 ? 'Semarang' : 'Jawa Tengah';
                        final yearData = spot.barIndex == 0
                            ? data.semarangData[spot.x.toInt()]
                            : data.jatengData[spot.x.toInt()];
                        return LineTooltipItem(
                          '$label (${yearData.year})',
                          const TextStyle(
                            color: bpsTextSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                          children: [
                            const TextSpan(text: '\n'),
                            TextSpan(
                              text:
                                  '${NumberFormatUtils.formatValue(spot.y, decimalPlaces: 2)}%',
                              style: TextStyle(
                                color: spot.barIndex == 0 ? bpsBlue : bpsOrange,
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
                maxX: (data.semarangData.length - 1).toDouble(),
                minY: -3,
                maxY: 7,
                lineBarsData: [
                  LineChartBarData(
                    spots: data.semarangData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.value);
                    }).toList(),
                    isCurved: true,
                    color: bpsBlue,
                    barWidth: isSmallScreen ? 2.5 : 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
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
                    spots: data.jatengData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.value);
                    }).toList(),
                    isCurved: true,
                    color: bpsOrange,
                    barWidth: isSmallScreen ? 2.5 : 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: isSmallScreen ? 3 : 4,
                          color: bpsOrange,
                          strokeWidth: isSmallScreen ? 1.5 : 2.5,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isSmallScreen) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isSmallScreen ? 14 : 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: isSmallScreen ? 5 : 6),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 13,
            color: bpsTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Ranking ────────────────────────────────────────────────────────────────

  Widget _buildRankingSection(ResponsiveSizing sizing, bool isSmallScreen) {
    if (_isLoadingRankings) {
      return _panel(
        isSmallScreen: isSmallScreen,
        child: Column(
          children: [
            _sectionHead(
              title: 'Peringkat PDRB',
              accent: bpsOrange,
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 24 : 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(bpsBlue),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'Memuat data ranking...',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: bpsTextSecondary,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
          ],
        ),
      );
    }

    final rankingData = _rankings;

    if (rankingData.isEmpty) {
      return _panel(
        isSmallScreen: isSmallScreen,
        child: Column(
          children: [
            _sectionHead(
              title: 'Peringkat PDRB',
              accent: bpsOrange,
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 20 : 28),
            Icon(
              Icons.error_outline_rounded,
              color: bpsRed,
              size: isSmallScreen ? 40 : 48,
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'Data tidak tersedia',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: bpsTextPrimary,
              ),
            ),
            SizedBox(height: isSmallScreen ? 4 : 8),
            Text(
              'Gagal memuat data ranking dari CSV',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: bpsTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return _panel(
      isSmallScreen: isSmallScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHead(
            title: 'Peringkat PDRB',
            subtitle: 'Top 10 • Jawa Tengah 2024',
            accent: bpsOrange,
            isSmallScreen: isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 14 : 18),
          ...() {
            final maxPdrb = rankingData
                .map((e) => e.pdrb)
                .fold<double>(0, (a, b) => b > a ? b : a);
            return rankingData.map(
                (item) => _buildRankRow(item, maxPdrb, isSmallScreen));
          }(),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: bpsTextLabel,
                size: isSmallScreen ? 14 : 16,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: Text(
                  'Semarang menempati peringkat #1 dari 35 kota/kabupaten di Jawa Tengah',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 12.5,
                    color: bpsTextSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Medal colors for the podium positions.
  Color _medalColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFF5B301); // gold
      case 2:
        return const Color(0xFF9AA5B1); // silver
      case 3:
        return const Color(0xFFCD7F32); // bronze
      default:
        return bpsTextLabel;
    }
  }

  /// One ranking row: medal-tinted rank badge, name, value and a proportional
  /// magnitude bar so the gap between cities reads at a glance.
  Widget _buildRankRow(PDRBRanking item, double maxPdrb, bool isSmallScreen) {
    final isSemarang = item.isKotaSemarang;
    final isPodium = item.rank <= 3;
    final accent = isSemarang ? bpsOrange : _medalColor(item.rank);
    final ratio = maxPdrb > 0 ? (item.pdrb / maxPdrb).clamp(0.04, 1.0) : 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 7 : 9),
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 10 : 12,
        isSmallScreen ? 9 : 11,
        isSmallScreen ? 12 : 14,
        isSmallScreen ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: isSemarang ? bpsOrange.withOpacity(0.07) : bpsCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSemarang ? bpsOrange.withOpacity(0.45) : bpsBorder,
          width: isSemarang ? 1.5 : 1,
        ),
        boxShadow: isSemarang
            ? [
                BoxShadow(
                  color: bpsOrange.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Rank badge — filled medal for podium, soft tint otherwise.
              Container(
                width: isSmallScreen ? 30 : 34,
                height: isSmallScreen ? 30 : 34,
                decoration: BoxDecoration(
                  color: (isSemarang || isPodium)
                      ? accent
                      : accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: (isSemarang || isPodium)
                      ? [
                          BoxShadow(
                            color: accent.withOpacity(0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isPodium && !isSemarang
                      ? Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: isSmallScreen ? 17 : 19,
                        )
                      : Text(
                          '${item.rank}',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: isSmallScreen ? 13 : 15,
                            fontWeight: FontWeight.w800,
                            color: isSemarang ? Colors.white : accent,
                          ),
                        ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 12),
              Expanded(
                child: Row(
                  children: [
                    if (isSemarang) ...[
                      Icon(Icons.star_rounded,
                          color: bpsOrange, size: isSmallScreen ? 14 : 16),
                      SizedBox(width: isSmallScreen ? 4 : 6),
                    ],
                    Flexible(
                      child: Text(
                        item.nama,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14.5,
                          fontWeight:
                              isSemarang ? FontWeight.w700 : FontWeight.w600,
                          color: isSemarang ? bpsOrange : bpsTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item.formattedPdrb,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: isSmallScreen ? 12.5 : 14,
                  fontWeight: FontWeight.w700,
                  color: isSemarang ? bpsOrange : bpsTextPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 9),
          // Proportional magnitude bar.
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(
                  height: isSmallScreen ? 4 : 5,
                  color: bpsBorder.withOpacity(0.5),
                ),
                FractionallySizedBox(
                  widthFactor: ratio.toDouble(),
                  child: Container(
                    height: isSmallScreen ? 4 : 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accent.withOpacity(0.55), accent],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKesimpulanCard(ResponsiveSizing sizing, bool isSmallScreen) {
    if (availableYears.length < 2) {
      return const SizedBox.shrink();
    }

    final sortedYears = availableYears..sort((a, b) => a.compareTo(b));
    final latestYear = sortedYears.last;
    final firstYear = sortedYears.first;

    final latestData = dataManager.getDataByYear(latestYear.toString());
    final firstData = dataManager.getDataByYear(firstYear.toString());

    if (latestData == null || firstData == null) {
      return const SizedBox.shrink();
    }

    final latestGrowth = _parseGrowth(latestData.pertumbuhanEkonomi);
    final firstGrowth = _parseGrowth(firstData.pertumbuhanEkonomi);

    double totalGrowth = 0;
    int count = 0;
    for (final dataPoint in latestData.semarangData) {
      totalGrowth += dataPoint.value;
      count++;
    }
    final averageGrowth = count > 0 ? (totalGrowth / count) : 0.0;

    final conclusionData = KesimpulanGenerator.generateEkonomiConclusion(
      latestYear: latestYear,
      firstYear: firstYear,
      latestGrowth: latestGrowth,
      firstGrowth: firstGrowth,
      averageGrowth: averageGrowth,
    );

    return KesimpulanWidget(
      title: 'Pertumbuhan Ekonomi Kota Semarang',
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
