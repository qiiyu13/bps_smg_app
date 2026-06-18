import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'sdgs_data_service.dart';
import 'dart:math';
import 'responsive_sizing.dart';
import 'number_format_utils.dart';
import 'kesimpulan_widget.dart';
import 'dart:async';
import 'app_theme.dart';
import 'widgets/section_kit.dart';

/// Indicator scale family. Coverage indicators are 0–100% by definition;
/// participation ratios (APM/APK) can legitimately exceed 100, so they live
/// on their own axis and never share a chart with coverage indicators.
enum _Family { coverage, participation }

/// Static metadata for one SDGs indicator: label, styling, scale family and an
/// accessor into [KotaData]. Centralised so cards, charts and dialogs stay in
/// sync instead of each re-listing the indicators.
class _Ind {
  final String key;
  final String label; // full name
  final String short; // chart/axis label
  final String goal; // SDG tag
  final IconData icon;
  final Color color;
  final _Family family;
  final String desc;
  final Map<int, double> Function(KotaData) pick;

  const _Ind({
    required this.key,
    required this.label,
    required this.short,
    required this.goal,
    required this.icon,
    required this.color,
    required this.family,
    required this.desc,
    required this.pick,
  });
}

// Top-level accessors so _Ind instances can stay const-friendly.
Map<int, double> _pSanitasi(KotaData k) => k.samitasilayak;
Map<int, double> _pTikRemaja(KotaData k) => k.tikRemaja;
Map<int, double> _pTikDewasa(KotaData k) => k.tikDewasa;
Map<int, double> _pAkta(KotaData k) => k.aktaLahir;
Map<int, double> _pApm(KotaData k) => k.apm;
Map<int, double> _pApk(KotaData k) => k.apk;

const List<_Ind> _kCoverage = [
  _Ind(
    key: 'samitasilayak',
    label: 'Sanitasi Layak',
    short: 'Sanitasi',
    goal: 'SDG 6',
    icon: Icons.water_drop_rounded,
    color: bpsBlue,
    family: _Family.coverage,
    desc:
        'Persentase rumah tangga dengan akses sanitasi layak — fasilitas tempat buang air besar sendiri/bersama dengan tangki septik. Indikator Tujuan 6: Air Bersih dan Sanitasi Layak.',
    pick: _pSanitasi,
  ),
  _Ind(
    key: 'tikRemaja',
    label: 'Akses TIK Remaja',
    short: 'TIK Remaja',
    goal: 'SDG 9',
    icon: Icons.smartphone_rounded,
    color: bpsGreen,
    family: _Family.coverage,
    desc:
        'Persentase penduduk usia remaja yang mengakses Teknologi Informasi dan Komunikasi (internet). Indikator Tujuan 9: Industri, Inovasi dan Infrastruktur.',
    pick: _pTikRemaja,
  ),
  _Ind(
    key: 'tikDewasa',
    label: 'Akses TIK Dewasa',
    short: 'TIK Dewasa',
    goal: 'SDG 9',
    icon: Icons.devices_rounded,
    color: bpsTeal,
    family: _Family.coverage,
    desc:
        'Persentase penduduk usia dewasa yang mengakses Teknologi Informasi dan Komunikasi (internet). Indikator Tujuan 9: Industri, Inovasi dan Infrastruktur.',
    pick: _pTikDewasa,
  ),
  _Ind(
    key: 'aktaLahir',
    label: 'Kepemilikan Akta Lahir',
    short: 'Akta Lahir',
    goal: 'SDG 16',
    icon: Icons.assignment_ind_rounded,
    color: bpsOrange,
    family: _Family.coverage,
    desc:
        'Persentase anak usia 0–17 tahun yang memiliki akta kelahiran. Indikator Tujuan 16: Perdamaian, Keadilan dan Kelembagaan yang Tangguh.',
    pick: _pAkta,
  ),
];

const List<_Ind> _kParticipation = [
  _Ind(
    key: 'apm',
    label: 'Angka Partisipasi Murni',
    short: 'APM',
    goal: 'SDG 4',
    icon: Icons.school_rounded,
    color: bpsPurple,
    family: _Family.participation,
    desc:
        'Angka Partisipasi Murni (APM) — proporsi anak pada kelompok usia sekolah tertentu yang bersekolah pada jenjang yang sesuai. Nilai dapat melampaui 100 karena penyesuaian data. Indikator Tujuan 4: Pendidikan Berkualitas.',
    pick: _pApm,
  ),
  _Ind(
    key: 'apk',
    label: 'Angka Partisipasi Kasar',
    short: 'APK',
    goal: 'SDG 4',
    icon: Icons.auto_graph_rounded,
    color: bpsRed,
    family: _Family.participation,
    desc:
        'Angka Partisipasi Kasar (APK) — rasio jumlah siswa pada suatu jenjang terhadap penduduk usia sekolah jenjang tersebut. Nilai wajar melampaui 100 bila ada siswa di luar rentang usia resmi. Indikator Tujuan 4: Pendidikan Berkualitas.',
    pick: _pApk,
  ),
];

const List<_Ind> _kAllInd = [..._kCoverage, ..._kParticipation];

/// One of the 17 Sustainable Development Goals, carrying its official UN brand
/// colour. The colour system is the recognised visual language of the SDGs —
/// reproducing it faithfully is what makes the "Tentang" card read as the real
/// agenda rather than a generic list.
class _Sdg {
  final int n;
  final String title; // concise Indonesian title
  final String en; // English title (shown in detail)
  final Color color;
  const _Sdg(this.n, this.title, this.en, this.color);

  /// Official UN "E-WEB" goal tile (colour + number + title + glyph baked in).
  String get asset => 'assets/sdgs/goal-${n.toString().padLeft(2, '0')}.png';
}

const List<_Sdg> _kGoals = [
  _Sdg(1, 'Tanpa Kemiskinan', 'No Poverty', Color(0xFFE5243B)),
  _Sdg(2, 'Tanpa Kelaparan', 'Zero Hunger', Color(0xFFDDA63A)),
  _Sdg(3, 'Kehidupan Sehat', 'Good Health & Well-being', Color(0xFF4C9F38)),
  _Sdg(4, 'Pendidikan Berkualitas', 'Quality Education', Color(0xFFC5192D)),
  _Sdg(5, 'Kesetaraan Gender', 'Gender Equality', Color(0xFFFF3A21)),
  _Sdg(6, 'Air Bersih & Sanitasi', 'Clean Water & Sanitation',
      Color(0xFF26BDE2)),
  _Sdg(7, 'Energi Bersih', 'Affordable & Clean Energy', Color(0xFFFCC30B)),
  _Sdg(8, 'Pekerjaan Layak', 'Decent Work & Growth', Color(0xFFA21942)),
  _Sdg(9, 'Industri & Inovasi', 'Industry, Innovation & Infrastructure',
      Color(0xFFFD6925)),
  _Sdg(10, 'Berkurangnya Kesenjangan', 'Reduced Inequalities',
      Color(0xFFDD1367)),
  _Sdg(11, 'Kota Berkelanjutan', 'Sustainable Cities', Color(0xFFFD9D24)),
  _Sdg(12, 'Konsumsi Bertanggung Jawab', 'Responsible Consumption',
      Color(0xFFBF8B2E)),
  _Sdg(13, 'Penanganan Iklim', 'Climate Action', Color(0xFF3F7E44)),
  _Sdg(14, 'Ekosistem Lautan', 'Life Below Water', Color(0xFF0A97D9)),
  _Sdg(15, 'Ekosistem Daratan', 'Life on Land', Color(0xFF56C02B)),
  _Sdg(16, 'Perdamaian & Keadilan', 'Peace, Justice & Institutions',
      Color(0xFF00689D)),
  _Sdg(17, 'Kemitraan', 'Partnerships for the Goals', Color(0xFF19486A)),
];

class UserSDGsScreen extends StatefulWidget {
  const UserSDGsScreen({super.key});

  @override
  State<UserSDGsScreen> createState() => _UserSDGsScreenState();
}

class _UserSDGsScreenState extends State<UserSDGsScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  List<KotaData> kotaDataList = [];

  int selectedYear = 2024;
  String selectedKota = '';
  bool isLoading = true;

  // Which indicator the inter-city comparison chart ranks.
  String comparisonKey = 'tikRemaja';
  // Which scale family the trend chart shows (can't mix scales).
  _Family trendFamily = _Family.coverage;

  final List<int> availableYears = [2024, 2023, 2022, 2021, 2020, 2019];
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
    _initializeAnimations();
    _loadData();
  }

  @override
  void dispose() {
    _debounceTimer.cancel();
    _yearScrollController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _changeYear(int year) {
    _debounceTimer.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          selectedYear = year;
        });
        _cardController.reset();
        _cardController.forward();
      }
    });
  }

  void _initializeAnimations() {
    _cardController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _cardAnimation =
        CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack);
    Future.delayed(
        const Duration(milliseconds: 300), () => _cardController.forward());
  }

  Future<void> _loadData() async {
    try {
      await SDGsDataService.initializeDefaultData();
      final data = await SDGsDataService.getAllKota();
      if (mounted) {
        setState(() {
          kotaDataList = data;
          if (data.isNotEmpty && selectedKota.isEmpty) {
            selectedKota = data.first.nama;
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  KotaData? _getSelectedKotaData() {
    try {
      return kotaDataList.firstWhere((kota) => kota.nama == selectedKota);
    } catch (e) {
      return kotaDataList.isNotEmpty ? kotaDataList.first : null;
    }
  }

  List<int> get _sortedYears => [...availableYears]..sort();

  // ---- Scale helpers: keep axes honest so nothing clips off the top ----

  /// Smallest "nice" axis ceiling >= [v]. Coverage caps at 100; participation
  /// rounds up to the next multiple of 20 so APK ~158 isn't clipped at 105.
  double _niceMax(double v) {
    if (v <= 100) return 100;
    return (v / 20).ceil() * 20.0;
  }

  double _axisInterval(double maxY) => maxY <= 100 ? 20 : 40;

  /// Composite coverage index for a city/year — mean of available coverage
  /// indicators. Participation is excluded (different scale would skew it).
  double? _coverageIndex(KotaData k, int year) {
    final vals = _kCoverage
        .map((i) => i.pick(k)[year])
        .whereType<double>()
        .toList();
    if (vals.isEmpty) return null;
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sizing = ResponsiveSizing(context);
    final isSmallScreen = sizing.isVerySmall || sizing.isSmall;

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          _buildHeader(context, sizing, isSmallScreen),
          const Expanded(
              child:
                  Center(child: CircularProgressIndicator(color: bpsOrange)))
        ]),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context, sizing, isSmallScreen),
          Expanded(
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(sizing.horizontalPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(children: [
                        Expanded(
                            child: _buildYearSelector(sizing, isSmallScreen)),
                        SizedBox(width: sizing.itemSpacing),
                        _buildCitySelector(sizing, isSmallScreen),
                      ]),
                      SizedBox(height: sizing.sectionSpacing),
                      SpineSection(
                        number: '01',
                        overline: 'Ringkasan',
                        title: 'Indeks Cakupan SDGs',
                        subtitle: '$selectedKota • $selectedYear',
                        accent: bpsOrange,
                        surface: false,
                        isFirst: true,
                        isSmall: isSmallScreen,
                        child: _buildHero(sizing, isSmallScreen),
                      ),
                      SpineSection(
                        number: '02',
                        overline: 'Cakupan',
                        title: 'Indikator Cakupan',
                        subtitle: 'Skala 0–100% • ketuk untuk detail',
                        accent: bpsOrange,
                        surface: false,
                        isSmall: isSmallScreen,
                        child: _buildCoverageCards(sizing, isSmallScreen),
                      ),
                      SpineSection(
                        number: '03',
                        overline: 'Pendidikan',
                        title: 'Partisipasi Sekolah',
                        subtitle: 'Rasio — dapat melampaui 100',
                        accent: bpsOrange,
                        surface: false,
                        isSmall: isSmallScreen,
                        child: _buildParticipation(sizing, isSmallScreen),
                      ),
                      SpineSection(
                        number: '04',
                        overline: 'Tren',
                        title: 'Tren Antar Tahun',
                        subtitle: '$selectedKota • 2019–2024',
                        accent: bpsOrange,
                        surface: false,
                        isSmall: isSmallScreen,
                        child: _buildTrendChart(sizing, isSmallScreen),
                      ),
                      SpineSection(
                        number: '05',
                        overline: 'Antar Kota',
                        title: 'Perbandingan Antar Kota',
                        accent: bpsOrange,
                        surface: false,
                        isSmall: isSmallScreen,
                        child: _buildComparisonChart(sizing, isSmallScreen),
                      ),
                      SpineSection(
                        number: '06',
                        overline: 'Tentang',
                        title: 'Tentang TPB/SDGs',
                        accent: bpsOrange,
                        surface: false,
                        isSmall: isSmallScreen,
                        child: _buildSDGsInfo(sizing, isSmallScreen),
                      ),
                      SpineSection(
                        overline: 'Ringkasan',
                        title: 'Kesimpulan',
                        accent: bpsOrange,
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
      overline: 'INDEKS PEMBANGUNAN',
      title: 'SDGs Jawa Tengah',
      icon: Icons.public_rounded,
      accent: bpsOrange,
      isSmall: isSmallScreen,
    );
  }

  Widget _buildYearSelector(ResponsiveSizing sizing, bool isSmallScreen) {
    return YearRail(
      years: [...availableYears]..sort(),
      selected: selectedYear,
      onSelect: _changeYear,
      accent: bpsOrange,
      isSmall: isSmallScreen,
      controller: _yearScrollController,
    );
  }

  // One selector: shows the chosen wilayah, tap opens a searchable sheet.
  // Compact chip — sits beside the year selector. Tap opens the search sheet.
  // Replaces the old separate "Cari" + "Pilih" panels (same job, twice).
  Widget _buildCitySelector(ResponsiveSizing sizing, bool isSmallScreen) {
    final isKota = selectedKota.toLowerCase().startsWith('kota');
    final short = selectedKota
        .replaceFirst(RegExp(r'^Kab\.\s*'), '')
        .replaceFirst(RegExp(r'^Kota\s*'), '');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _openCityPicker,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 160),
          padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 10 : 12,
              vertical: isSmallScreen ? 6 : 7),
          decoration: BoxDecoration(
              color: bpsBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: bpsBorder)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(isKota ? Icons.location_city_rounded : Icons.terrain_rounded,
                color: bpsOrange, size: isSmallScreen ? 16 : 18),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Flexible(
              child: Text(
                short.isEmpty ? 'Wilayah' : short,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: kDisplayFont,
                    fontSize: isSmallScreen ? 14 : 15.5,
                    fontWeight: FontWeight.w800,
                    color: bpsTextPrimary),
              ),
            ),
            SizedBox(width: isSmallScreen ? 2 : 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: bpsOrange, size: 20),
          ]),
        ),
      ),
    );
  }

  void _openCityPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (sheetContext) {
        final sizing = ResponsiveSizing(sheetContext);
        final small = sizing.isVerySmall || sizing.isSmall;
        String query = '';
        return StatefulBuilder(builder: (context, setSheet) {
          final results = query.isEmpty
              ? kotaDataList
              : kotaDataList
                  .where((k) =>
                      k.nama.toLowerCase().contains(query.toLowerCase()))
                  .toList();
          return Padding(
            // Lift above the keyboard.
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.92,
              builder: (context, scrollController) {
                return Column(children: [
                  const SizedBox(height: 10),
                  Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: bpsBorder,
                          borderRadius: BorderRadius.circular(2))),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        small ? 16 : 20, 14, small ? 16 : 20, 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pilih Wilayah',
                              style: TextStyle(
                                  fontFamily: kDisplayFont,
                                  fontSize: small ? 18 : 20,
                                  fontWeight: FontWeight.w800,
                                  color: bpsTextPrimary)),
                          const SizedBox(height: 12),
                          DecoratedBox(
                            decoration: BoxDecoration(
                                color: bpsBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: bpsBorder)),
                            child: TextField(
                              autofocus: false,
                              onChanged: (v) => setSheet(() => query = v),
                              decoration: InputDecoration(
                                  hintText: 'Cari kota/kabupaten…',
                                  hintStyle: const TextStyle(
                                      color: bpsTextSecondary, fontSize: 14),
                                  prefixIcon: const Icon(Icons.search_rounded,
                                      color: bpsOrange),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 14)),
                            ),
                          ),
                        ]),
                  ),
                  Expanded(
                    child: results.isEmpty
                        ? const Center(
                            child: Text('Tidak ada hasil',
                                style: TextStyle(color: bpsTextSecondary)))
                        : ListView.separated(
                            controller: scrollController,
                            padding: EdgeInsets.fromLTRB(
                                small ? 12 : 16, 4, small ? 12 : 16, 16),
                            itemCount: results.length,
                            separatorBuilder: (_, __) =>
                                Divider(height: 1, color: bpsBorder.withOpacity(0.5)),
                            itemBuilder: (context, i) {
                              final k = results[i];
                              final selected = k.nama == selectedKota;
                              final isKota =
                                  k.nama.toLowerCase().startsWith('kota');
                              return ListTile(
                                dense: small,
                                leading: Icon(
                                    isKota
                                        ? Icons.location_city_rounded
                                        : Icons.terrain_rounded,
                                    color: selected
                                        ? bpsOrange
                                        : bpsTextSecondary,
                                    size: 20),
                                title: Text(k.nama,
                                    style: TextStyle(
                                        fontSize: small ? 14 : 15,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: selected
                                            ? bpsOrange
                                            : bpsTextPrimary)),
                                trailing: selected
                                    ? const Icon(Icons.check_circle_rounded,
                                        color: bpsOrange, size: 20)
                                    : null,
                                onTap: () {
                                  setState(() => selectedKota = k.nama);
                                  _cardController.reset();
                                  _cardController.forward();
                                  Navigator.pop(sheetContext);
                                },
                              );
                            },
                          ),
                  ),
                ]);
              },
            ),
          );
        });
      },
    );
  }

  // ---- 01 Hero: composite coverage index --------------------------------

  Widget _buildHero(ResponsiveSizing sizing, bool isSmallScreen) {
    final kota = _getSelectedKotaData();
    if (kota == null) {
      return SectionPanel(
        isSmall: isSmallScreen,
        child: const Center(
            child: Text('Tidak ada data untuk kota yang dipilih',
                style: TextStyle(color: bpsTextSecondary))),
      );
    }

    final cur = _coverageIndex(kota, selectedYear);
    final prev = _coverageIndex(kota, selectedYear - 1);
    final delta = (cur != null && prev != null) ? cur - prev : null;
    final spark = _sortedYears
        .map((y) => _coverageIndex(kota, y))
        .whereType<double>()
        .toList();

    // Highlight the three coverage indicators as supporting facts.
    final facts = _kCoverage.take(3).map((ind) {
      final v = ind.pick(kota)[selectedYear];
      return HeroFact(
          ind.short, v != null ? NumberFormatUtils.formatPercentage(v) : 'N/A');
    }).toList();

    return IndicatorHero(
      overline: 'INDEKS CAKUPAN SDGs',
      value: cur != null ? NumberFormatUtils.formatPercentage(cur) : 'N/A',
      subtitle: 'Rata-rata indikator cakupan • $selectedKota',
      badge: 'Tahun $selectedYear',
      accent: bpsOrange,
      delta: delta,
      deltaUnit: 'pp',
      sparkline: spark.length > 1 ? spark : null,
      facts: facts,
      isSmall: isSmallScreen,
    );
  }

  // ---- 02 Coverage — instrument readout rows ----------------------------

  Widget _buildCoverageCards(ResponsiveSizing sizing, bool isSmallScreen) {
    final kota = _getSelectedKotaData();
    if (kota == null) return const SizedBox.shrink();

    return SectionPanel(
      isSmall: isSmallScreen,
      child: Column(children: [
        for (int i = 0; i < _kCoverage.length; i++) ...[
          FadeTransition(
            opacity: _cardAnimation,
            child: _buildCoverageRow(kota, _kCoverage[i], isSmallScreen),
          ),
          if (i < _kCoverage.length - 1)
            Divider(height: 1, thickness: 1, color: bpsBorder.withOpacity(0.6)),
        ],
      ]),
    );
  }

  Widget _buildCoverageRow(KotaData kota, _Ind ind, bool isSmallScreen) {
    final value = ind.pick(kota)[selectedYear];
    final prev = ind.pick(kota)[selectedYear - 1];
    final delta = (value != null && prev != null) ? value - prev : null;
    final available = value != null;
    final fraction = available ? (value.clamp(0, 100) / 100) : 0.0;

    final trend = _sortedYears
        .map((y) => ind.pick(kota)[y])
        .whereType<double>()
        .toList();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showDetailDialog(ind, value),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // Icon chip.
            Container(
              width: isSmallScreen ? 40 : 44,
              height: isSmallScreen ? 40 : 44,
              decoration: BoxDecoration(
                  color: ind.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11)),
              child: Icon(ind.icon,
                  color: ind.color, size: isSmallScreen ? 20 : 22),
            ),
            SizedBox(width: isSmallScreen ? 12 : 14),
            // Label + measurement track.
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(ind.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14.5,
                                fontWeight: FontWeight.w700,
                                color: bpsTextPrimary)),
                      ),
                      const SizedBox(width: 6),
                      _goalPill(ind.goal, ind.color),
                    ]),
                    SizedBox(height: isSmallScreen ? 9 : 11),
                    _coverageTrack(ind.color, fraction, available),
                  ]),
            ),
            SizedBox(width: isSmallScreen ? 12 : 14),
            // Value + delta + sparkline.
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: available
                        ? NumberFormatUtils.formatDecimal(value,
                            decimalPlaces: 1)
                        : 'N/A',
                    style: TextStyle(
                        fontFamily: kDisplayFont,
                        fontSize: isSmallScreen ? 19 : 22,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        letterSpacing: -0.5,
                        color: bpsTextPrimary),
                  ),
                  if (available)
                    TextSpan(
                        text: ' %',
                        style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 12,
                            fontWeight: FontWeight.w700,
                            color: bpsTextSecondary)),
                ]),
              ),
              const SizedBox(height: 5),
              if (delta != null) _deltaTag(delta, isSmallScreen),
              if (trend.length > 1) ...[
                SizedBox(height: delta != null ? 6 : 0),
                SizedBox(
                  width: isSmallScreen ? 56 : 64,
                  height: 16,
                  child: CustomPaint(
                      painter: _MiniTrendPainter(trend, ind.color)),
                ),
              ],
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _goalPill(String goal, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4)),
      child: Text(goal,
          style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: color)),
    );
  }

  /// Thin 0–100 measurement track with a faint baseline and tick at 50.
  Widget _coverageTrack(Color color, double fraction, bool available) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      return SizedBox(
        height: 8,
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4)),
          ),
          // 50% tick.
          Positioned(
            left: w * 0.5,
            child: Container(
                width: 1, height: 8, color: bpsTextSecondary.withOpacity(0.25)),
          ),
          if (available)
            FractionallySizedBox(
              widthFactor: fraction.clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(4)),
              ),
            ),
        ]),
      );
    });
  }

  Widget _deltaTag(double delta, bool isSmallScreen) {
    final positive = delta >= 0;
    final tint = positive ? bpsGreen : bpsRed;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          size: isSmallScreen ? 11 : 12, color: tint),
      const SizedBox(width: 2),
      Text(
        '${NumberFormatUtils.formatDecimal(delta.abs(), decimalPlaces: 1)} pp',
        style: TextStyle(
            fontSize: isSmallScreen ? 10.5 : 11.5,
            fontWeight: FontWeight.w700,
            color: tint),
      ),
    ]);
  }

  // ---- 03 Participation (ratio, own scale, 100 reference) ---------------

  Widget _buildParticipation(ResponsiveSizing sizing, bool isSmallScreen) {
    final kota = _getSelectedKotaData();
    if (kota == null) return const SizedBox.shrink();

    final values = {
      for (final ind in _kParticipation) ind.key: ind.pick(kota)[selectedYear]
    };
    final present = values.values.whereType<double>().toList();
    final maxScale =
        present.isEmpty ? 160.0 : _niceMax(present.reduce(max));

    return SectionPanel(
      isSmall: isSmallScreen,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final ind in _kParticipation) ...[
          _buildParticipationBar(
              ind, values[ind.key], maxScale, isSmallScreen),
          if (ind.key != _kParticipation.last.key)
            SizedBox(height: isSmallScreen ? 14 : 18),
        ],
        SizedBox(height: isSmallScreen ? 12 : 14),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
          decoration: BoxDecoration(
              color: bpsBackground, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded,
                size: 16, color: bpsTextSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                  'Garis 100 adalah acuan partisipasi penuh. APK dapat melampaui 100 bila ada siswa di luar usia resmi jenjang.',
                  style: TextStyle(
                      fontSize: isSmallScreen ? 10.5 : 11.5,
                      color: bpsTextSecondary,
                      height: 1.35)),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildParticipationBar(
      _Ind ind, double? value, double maxScale, bool isSmallScreen) {
    final available = value != null;
    final fraction = available ? (value / maxScale).clamp(0.0, 1.0) : 0.0;
    final refFraction = (100 / maxScale).clamp(0.0, 1.0);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showDetailDialog(ind, value),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(ind.icon, size: isSmallScreen ? 16 : 18, color: ind.color),
            const SizedBox(width: 8),
            Expanded(
              child: Text('${ind.label} (${ind.short})',
                  style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13.5,
                      fontWeight: FontWeight.w600,
                      color: bpsTextPrimary)),
            ),
            Text(
                available
                    ? NumberFormatUtils.formatDecimal(value, decimalPlaces: 1)
                    : 'N/A',
                style: TextStyle(
                    fontFamily: kDisplayFont,
                    fontSize: isSmallScreen ? 15 : 17,
                    fontWeight: FontWeight.w800,
                    color: ind.color)),
          ]),
          const SizedBox(height: 8),
          LayoutBuilder(builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Stack(children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                    color: ind.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)),
              ),
              FractionallySizedBox(
                widthFactor: fraction,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                      color: ind.color,
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
              // Reference marker at value 100.
              Positioned(
                left: (w * refFraction).clamp(0.0, w - 1.5),
                child: Container(
                    width: 1.5,
                    height: 12,
                    color: bpsTextSecondary.withOpacity(0.6)),
              ),
            ]);
          }),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('0',
                style: const TextStyle(
                    fontSize: 9, color: bpsTextSecondary)),
            Text('100',
                style: const TextStyle(
                    fontSize: 9,
                    color: bpsTextSecondary,
                    fontWeight: FontWeight.w600)),
            Text(maxScale.toInt().toString(),
                style: const TextStyle(
                    fontSize: 9, color: bpsTextSecondary)),
          ]),
        ]),
      ),
    );
  }

  // ---- 04 Trend line chart (per scale family) ---------------------------

  Widget _buildTrendChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final kota = _getSelectedKotaData();
    if (kota == null) return const SizedBox.shrink();

    final inds =
        trendFamily == _Family.coverage ? _kCoverage : _kParticipation;
    final years = _sortedYears;

    // Build spots per indicator; drop years with no value for that indicator.
    final lines = <_Ind, List<FlSpot>>{};
    double maxVal = 0;
    double minVal = double.infinity;
    for (final ind in inds) {
      final spots = <FlSpot>[];
      for (int i = 0; i < years.length; i++) {
        final v = ind.pick(kota)[years[i]];
        if (v == null) continue;
        spots.add(FlSpot(i.toDouble(), v));
        maxVal = max(maxVal, v);
        minVal = min(minVal, v);
      }
      if (spots.isNotEmpty) lines[ind] = spots;
    }

    if (lines.isEmpty) {
      return _emptyChart('Data tren tidak tersedia', isSmallScreen);
    }

    final maxY = _niceMax(maxVal);
    final minY = trendFamily == _Family.coverage
        ? (minVal.floor() / 10).floor() * 10.0
        : 0.0;
    final interval = _axisInterval(maxY - minY).clamp(10, 40).toDouble();

    return SectionPanel(
      isSmall: isSmallScreen,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildFamilyToggle(isSmallScreen),
        SizedBox(height: isSmallScreen ? 14 : 18),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: lines.keys
              .map((ind) => _buildLegendItem(ind.short, ind.color, isSmallScreen))
              .toList(),
        ),
        SizedBox(height: isSmallScreen ? 14 : 18),
        RepaintBoundary(
          child: SizedBox(
            height: isSmallScreen ? 230 : 250,
            child: LineChart(LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (v) =>
                    const FlLine(color: bpsBorder, strokeWidth: 0.5),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: isSmallScreen ? 34 : 40,
                        interval: interval,
                        getTitlesWidget: (v, meta) => Text(
                            v.toInt().toString(),
                            style: TextStyle(
                                fontSize: isSmallScreen ? 9 : 10,
                                color: bpsTextSecondary)))),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (v, meta) {
                          final i = v.toInt();
                          if (i < 0 || i >= years.length) {
                            return const Text('');
                          }
                          return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(years[i].toString(),
                                  style: TextStyle(
                                      fontSize: isSmallScreen ? 9 : 10,
                                      fontWeight: FontWeight.w600,
                                      color: bpsTextPrimary)));
                        })),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => bpsCardBg,
                  tooltipRoundedRadius: 8,
                  tooltipBorder: const BorderSide(color: bpsBorder),
                  getTooltipItems: (touched) {
                    final inds2 = lines.keys.toList();
                    return touched.map((s) {
                      final ind = inds2[s.barIndex];
                      return LineTooltipItem(
                        '${ind.short}: ${NumberFormatUtils.formatDecimal(s.y, decimalPlaces: 1)}',
                        TextStyle(
                            color: ind.color,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 10 : 11),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: lines.entries
                  .map((e) => _lineData(e.value, e.key.color, isSmallScreen))
                  .toList(),
            )),
          ),
        ),
      ]),
    );
  }

  LineChartBarData _lineData(
      List<FlSpot> spots, Color color, bool isSmallScreen) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.25,
      color: color,
      barWidth: isSmallScreen ? 2.5 : 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: isSmallScreen ? 2.5 : 3.5,
          color: color,
          strokeWidth: 1.5,
          strokeColor: bpsCardBg,
        ),
      ),
    );
  }

  Widget _buildFamilyToggle(bool isSmallScreen) {
    Widget chip(String label, _Family f) {
      final selected = trendFamily == f;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => trendFamily = f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 10),
            decoration: BoxDecoration(
              color: selected ? bpsOrange : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: isSmallScreen ? 11.5 : 12.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : bpsTextSecondary)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: bpsBackground, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        chip('Cakupan', _Family.coverage),
        chip('Partisipasi', _Family.participation),
      ]),
    );
  }

  // ---- 05 Inter-city comparison (indicator selectable + rank) -----------

  Widget _buildComparisonChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final ind = _kAllInd.firstWhere((i) => i.key == comparisonKey,
        orElse: () => _kCoverage.first);

    final rows = kotaDataList
        .map((k) => MapEntry(k.nama, ind.pick(k)[selectedYear]))
        .where((e) => e.value != null)
        .map((e) => MapEntry(e.key, e.value!))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (rows.isEmpty) {
      return SectionPanel(
        isSmall: isSmallScreen,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildIndicatorPicker(isSmallScreen),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _emptyChart('Data tidak tersedia untuk $selectedYear', isSmallScreen),
        ]),
      );
    }

    final names = rows.map((e) => e.key).toList();
    final values = rows.map((e) => e.value).toList();
    final average = values.reduce((a, b) => a + b) / values.length;
    final highest = values.first;
    final lowest = values.last;
    final maxY = _niceMax(highest);
    final rank = names.indexOf(selectedKota);

    return SectionPanel(
      isSmall: isSmallScreen,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildIndicatorPicker(isSmallScreen),
        SizedBox(height: isSmallScreen ? 12 : 16),
        // Rank badge for the selected city.
        if (rank >= 0)
          Container(
            margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 14),
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 14,
                vertical: isSmallScreen ? 8 : 10),
            decoration: BoxDecoration(
                color: ind.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ind.color.withOpacity(0.25))),
            child: Row(children: [
              Icon(Icons.emoji_events_rounded,
                  size: isSmallScreen ? 18 : 20, color: ind.color),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: bpsTextPrimary),
                    children: [
                      TextSpan(text: '$selectedKota peringkat '),
                      TextSpan(
                          text: '${rank + 1}',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: ind.color)),
                      TextSpan(text: ' dari ${names.length} • ${ind.short}'),
                    ],
                  ),
                ),
              ),
              Text(NumberFormatUtils.formatDecimal(values[rank],
                  decimalPlaces: 1),
                  style: TextStyle(
                      fontFamily: kDisplayFont,
                      fontWeight: FontWeight.w800,
                      fontSize: isSmallScreen ? 14 : 16,
                      color: ind.color)),
            ]),
          ),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
          decoration: BoxDecoration(
              color: bpsOrange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12)),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildComparisonStatItem(
                'Rata-rata',
                NumberFormatUtils.formatDecimal(average, decimalPlaces: 1),
                Icons.bar_chart,
                bpsOrange,
                isSmallScreen),
            _buildComparisonStatItem(
                'Tertinggi',
                NumberFormatUtils.formatDecimal(highest, decimalPlaces: 1),
                Icons.arrow_upward,
                bpsGreen,
                isSmallScreen),
            _buildComparisonStatItem(
                'Terendah',
                NumberFormatUtils.formatDecimal(lowest, decimalPlaces: 1),
                Icons.arrow_downward,
                bpsRed,
                isSmallScreen),
          ]),
        ),
        SizedBox(height: isSmallScreen ? 14 : 18),
        Row(children: [
          Text('PERINGKAT',
              style: TextStyle(
                  fontSize: isSmallScreen ? 9.5 : 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: bpsTextSecondary)),
          const Spacer(),
          Text('${names.length} wilayah',
              style: TextStyle(
                  fontSize: isSmallScreen ? 9.5 : 10.5,
                  color: bpsTextSecondary)),
        ]),
        SizedBox(height: isSmallScreen ? 8 : 10),
        // Vertical ranked leaderboard — readable at 35 rows, unlike the old
        // horizontally-scrolling bar chart with angled labels.
        for (int i = 0; i < names.length; i++)
          _buildRankRow(
            rank: i + 1,
            name: names[i],
            value: values[i],
            maxScale: maxY,
            ind: ind,
            isSelected: names[i] == selectedKota,
            isSmall: isSmallScreen,
          ),
      ]),
    );
  }

  Widget _buildRankRow({
    required int rank,
    required String name,
    required double value,
    required double maxScale,
    required _Ind ind,
    required bool isSelected,
    required bool isSmall,
  }) {
    final fraction = (value / maxScale).clamp(0.0, 1.0);
    final refFraction = (100 / maxScale).clamp(0.0, 1.0);
    final medal = rank <= 3;
    final rankColor = rank == 1
        ? const Color(0xFFD4A017)
        : rank == 2
            ? const Color(0xFF9AA3AD)
            : rank == 3
                ? const Color(0xFFB87333)
                : bpsTextSecondary;
    return Material(
      color: isSelected ? ind.color.withOpacity(0.07) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() => selectedKota = name);
          _cardController.reset();
          _cardController.forward();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(
              horizontal: isSelected ? (isSmall ? 8 : 10) : 0,
              vertical: isSmall ? 7 : 8),
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ind.color.withOpacity(0.3)))
              : null,
          child: Row(children: [
            // Rank chip.
            SizedBox(
              width: isSmall ? 26 : 30,
              child: Text(
                rank.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: kDisplayFont,
                    fontSize: isSmall ? (medal ? 15 : 13) : (medal ? 17 : 14),
                    fontWeight: medal ? FontWeight.w800 : FontWeight.w600,
                    color: rankColor),
              ),
            ),
            SizedBox(width: isSmall ? 8 : 10),
            // Name + bar.
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: isSmall ? 12 : 13,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? ind.color : bpsTextPrimary)),
                    const SizedBox(height: 5),
                    LayoutBuilder(builder: (context, c) {
                      final w = c.maxWidth;
                      return SizedBox(
                        height: 7,
                        child: Stack(clipBehavior: Clip.none, children: [
                          Container(
                            height: 7,
                            decoration: BoxDecoration(
                                color: ind.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          FractionallySizedBox(
                            widthFactor: fraction,
                            child: Container(
                              height: 7,
                              decoration: BoxDecoration(
                                  color: isSelected
                                      ? ind.color
                                      : ind.color.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          // 100 reference tick for participation indicators.
                          if (ind.family == _Family.participation &&
                              refFraction < 1)
                            Positioned(
                              left: (w * refFraction).clamp(0.0, w - 1),
                              child: Container(
                                  width: 1,
                                  height: 7,
                                  color: bpsTextSecondary.withOpacity(0.55)),
                            ),
                        ]),
                      );
                    }),
                  ]),
            ),
            SizedBox(width: isSmall ? 10 : 12),
            // Value.
            SizedBox(
              width: isSmall ? 42 : 48,
              child: Text(
                NumberFormatUtils.formatDecimal(value, decimalPlaces: 1),
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: kDisplayFont,
                    fontSize: isSmall ? 13 : 14.5,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? ind.color : bpsTextPrimary),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildIndicatorPicker(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: bpsBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bpsBorder)),
      child: DropdownButton<String>(
        value: comparisonKey,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.expand_more_rounded, color: bpsOrange),
        items: _kAllInd
            .map((ind) => DropdownMenuItem(
                value: ind.key,
                child: Row(children: [
                  Icon(ind.icon, size: isSmallScreen ? 16 : 18, color: ind.color),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text('${ind.label} • ${ind.goal}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: isSmallScreen ? 13 : 14)),
                  ),
                ])))
            .toList(),
        onChanged: (v) {
          if (v != null) setState(() => comparisonKey = v);
        },
      ),
    );
  }

  Widget _buildComparisonStatItem(String label, String value, IconData icon,
      Color color, bool isSmallScreen) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, size: isSmallScreen ? 16 : 18, color: color)),
      const SizedBox(height: 6),
      Text(label,
          style: TextStyle(
              fontSize: isSmallScreen ? 9 : 10, color: bpsTextSecondary)),
      const SizedBox(height: 2),
      Text(value,
          style: TextStyle(
              fontFamily: kDisplayFont,
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: bpsTextPrimary)),
    ]);
  }

  Widget _buildLegendItem(String label, Color color, bool isSmallScreen) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: isSmallScreen ? 8 : 10,
          height: isSmallScreen ? 8 : 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label,
          style: TextStyle(
              fontSize: isSmallScreen ? 10.5 : 11.5,
              fontWeight: FontWeight.w600,
              color: bpsTextPrimary)),
    ]);
  }

  Widget _emptyChart(String message, bool isSmallScreen) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
          color: bpsBackground, borderRadius: BorderRadius.circular(12)),
      child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.info_outline, size: 36, color: bpsTextSecondary),
        const SizedBox(height: 8),
        Text(message,
            style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13, color: bpsTextSecondary)),
      ])),
    );
  }

  // ---- Indicator detail dialog ------------------------------------------

  void _showDetailDialog(_Ind ind, double? value) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final dSizing = ResponsiveSizing(dialogContext);
        final small = dSizing.isVerySmall || dSizing.isSmall;
        final unit = ind.family == _Family.coverage ? ' %' : '';
        return Dialog(
          insetPadding: EdgeInsets.all(small ? 12 : 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.7,
              maxWidth: small
                  ? MediaQuery.of(dialogContext).size.width - 24
                  : 500,
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: EdgeInsets.all(small ? 14 : 18),
                decoration: BoxDecoration(
                    color: ind.color,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20))),
                child: Row(children: [
                  Icon(ind.icon, color: Colors.white, size: small ? 22 : 26),
                  SizedBox(width: small ? 10 : 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ind.label,
                              style: TextStyle(
                                  fontSize: small ? 16 : 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          const SizedBox(height: 2),
                          Text('${ind.goal} • Tahun $selectedYear',
                              style: TextStyle(
                                  fontSize: small ? 11.5 : 13,
                                  color: Colors.white70)),
                        ]),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(dialogContext),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.close_rounded, color: Colors.white)),
                  ),
                ]),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(small ? 16 : 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(
                              value != null
                                  ? NumberFormatUtils.formatDecimal(value,
                                      decimalPlaces: 2)
                                  : 'N/A',
                              style: TextStyle(
                                  fontFamily: kDisplayFont,
                                  fontSize: small ? 36 : 44,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                  color: ind.color)),
                          if (value != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(unit,
                                  style: TextStyle(
                                      fontSize: small ? 14 : 16,
                                      fontWeight: FontWeight.w600,
                                      color: ind.color)),
                            ),
                        ]),
                        SizedBox(height: small ? 12 : 16),
                        Text(ind.desc,
                            style: TextStyle(
                                fontSize: small ? 12.5 : 13.5,
                                height: 1.5,
                                color: bpsTextPrimary)),
                      ]),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  // ---- 06 About SDGs — official UN goal-colour poster -------------------

  Widget _buildSDGsInfo(ResponsiveSizing sizing, bool isSmallScreen) {
    // Deep ink field makes the 17 brand colours read at full saturation.
    const ink = Color(0xFF0C1A24);
    const inkSoft = Color(0xFF16303D);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [inkSoft, ink],
        ),
        boxShadow: [
          BoxShadow(
              color: ink.withOpacity(0.45),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            isSmallScreen ? 18 : 22,
            isSmallScreen ? 18 : 22,
            isSmallScreen ? 18 : 22,
            isSmallScreen ? 14 : 16,
          ),
          child: _buildGoalsMasthead(isSmallScreen),
        ),
        // The 17-colour spectrum ruler — the masthead signature, echoing the
        // measurement-rule motif used on the hero blocks.
        _buildSpectrumRuler(),
        Padding(
          padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
          child: _buildGoalsGrid(isSmallScreen),
        ),
      ]),
    );
  }

  Widget _buildGoalsMasthead(bool isSmallScreen) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Oversized numeral lockup — editorial masthead.
        Text(
          '17',
          style: TextStyle(
            fontFamily: kDisplayFont,
            fontSize: isSmallScreen ? 56 : 68,
            fontWeight: FontWeight.w800,
            height: 0.82,
            letterSpacing: -3,
            color: Colors.white,
          ),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AGENDA 2030',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: isSmallScreen ? 10 : 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tujuan Pembangunan\nBerkelanjutan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 15 : 17,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                ]),
          ),
        ),
        Icon(Icons.public_rounded,
            color: Colors.white.withOpacity(0.18),
            size: isSmallScreen ? 30 : 36),
      ]),
      SizedBox(height: isSmallScreen ? 14 : 16),
      Text(
        'Komitmen global dan nasional menyejahterakan masyarakat lewat 17 tujuan yang saling terhubung — ditargetkan tercapai pada 2030. Ketuk tiap tujuan untuk detail.',
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: isSmallScreen ? 11.5 : 12.5,
          height: 1.5,
        ),
      ),
    ]);
  }

  Widget _buildSpectrumRuler() {
    return SizedBox(
      height: 6,
      child: Row(
        children: _kGoals
            .map((g) => Expanded(child: ColoredBox(color: g.color)))
            .toList(),
      ),
    );
  }

  Widget _buildGoalsGrid(bool isSmallScreen) {
    final cols = isSmallScreen ? 3 : 4;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1, // official tiles are square
      ),
      itemCount: _kGoals.length,
      itemBuilder: (context, index) =>
          _buildGoalTile(_kGoals[index], isSmallScreen),
    );
  }

  Widget _buildGoalTile(_Sdg goal, bool isSmallScreen) {
    return Material(
      color: goal.color,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showGoalDialog(goal),
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Image.asset(
          goal.asset,
          fit: BoxFit.cover,
          // Fall back to the colour block if the asset ever fails to load.
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              goal.n.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontFamily: kDisplayFont,
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showGoalDialog(_Sdg goal) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final dSizing = ResponsiveSizing(dialogContext);
        final small = dSizing.isVerySmall || dSizing.isSmall;
        return Dialog(
          insetPadding: EdgeInsets.all(small ? 12 : 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.antiAlias,
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: small
                    ? MediaQuery.of(dialogContext).size.width - 24
                    : 420),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // The official tile, full bleed at the top.
              Stack(children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(goal.asset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          ColoredBox(color: goal.color)),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black.withOpacity(0.25),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(dialogContext),
                      child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.close_rounded,
                              color: Colors.white, size: 20)),
                    ),
                  ),
                ),
              ]),
              Padding(
                padding: EdgeInsets.all(small ? 18 : 22),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: goal.color,
                              borderRadius: BorderRadius.circular(6)),
                          child: Text('TUJUAN ${goal.n}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1)),
                        ),
                        const SizedBox(width: 8),
                        Text(goal.en,
                            style: TextStyle(
                                color: bpsTextSecondary,
                                fontSize: small ? 11 : 12,
                                fontWeight: FontWeight.w500)),
                      ]),
                      SizedBox(height: small ? 8 : 10),
                      Text(goal.title,
                          style: TextStyle(
                              fontFamily: kDisplayFont,
                              color: bpsTextPrimary,
                              fontSize: small ? 22 : 26,
                              fontWeight: FontWeight.w800,
                              height: 1.1)),
                    ]),
              ),
            ]),
          ),
        );
      },
    );
  }

  // ---- 07 Conclusion (follows the selected city) ------------------------

  Widget _buildKesimpulanCard(ResponsiveSizing sizing, bool isSmallScreen) {
    final kota = _getSelectedKotaData();
    if (kota == null) return const SizedBox.shrink();

    final sortedYears = _sortedYears;
    final latestYear = sortedYears.last;
    final firstYear = sortedYears.first;

    final latestScore = _coverageIndex(kota, latestYear) ?? 0;
    final firstScore = _coverageIndex(kota, firstYear) ?? 0;

    // Count indicators improving from firstYear to latestYear.
    int onTrackCount = 0;
    int totalIndicators = 0;
    for (final ind in _kAllInd) {
      final map = ind.pick(kota);
      if (map.containsKey(latestYear) && map.containsKey(firstYear)) {
        totalIndicators++;
        if (map[latestYear]! >= map[firstYear]!) onTrackCount++;
      }
    }

    final progressRate =
        firstScore > 0 ? ((latestScore - firstScore) / firstScore * 100) : 0.0;

    final conclusionData = KesimpulanGenerator.generateSDGsConclusion(
      latestYear: latestYear,
      averageScore: latestScore,
      onTrackCount: onTrackCount,
      totalIndicators: totalIndicators,
      progressRate: progressRate,
    );

    return KesimpulanWidget(
      title: 'SDGs $selectedKota',
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

/// Lightweight per-indicator trend line for the coverage rows. Plain polyline
/// in the indicator colour with a dot on the latest point — no fl_chart
/// overhead, reads on a white field (unlike the white-only [MiniSparkline]).
class _MiniTrendPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  const _MiniTrendPainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce(min);
    final maxV = values.reduce(max);
    final span = (maxV - minV).abs() < 0.01 ? 1.0 : (maxV - minV);
    const pad = 3.0;
    double dx(int i) => i / (values.length - 1) * size.width;
    double dy(double v) =>
        size.height - pad - (v - minV) / span * (size.height - pad * 2);

    final path = Path()..moveTo(dx(0), dy(values[0]));
    for (int i = 1; i < values.length; i++) {
      path.lineTo(dx(i), dy(values[i]));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    // Latest point.
    canvas.drawCircle(
      Offset(dx(values.length - 1), dy(values.last)),
      2.4,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_MiniTrendPainter old) =>
      old.values != values || old.color != color;
}
