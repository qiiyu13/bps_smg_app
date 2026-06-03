import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'sdgs_data_service.dart';
import 'dart:math';
import 'responsive_sizing.dart';
import 'number_format_utils.dart';
import 'kesimpulan_widget.dart';
import 'dart:async';
import 'app_theme.dart';

class UserSDGsScreen extends StatefulWidget {
  const UserSDGsScreen({Key? key}) : super(key: key);

  @override
  State<UserSDGsScreen> createState() => _UserSDGsScreenState();
}

class _UserSDGsScreenState extends State<UserSDGsScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  List<KotaData> kotaDataList = [];
  List<KotaData> filteredList = [];

  int selectedYear = 2024;
  String selectedKota = '';
  String searchQuery = '';
  bool isLoading = true;

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
          filteredList = data;
          if (data.isNotEmpty && selectedKota.isEmpty)
            selectedKota = data.first.nama;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredList = query.isEmpty
          ? List.from(kotaDataList)
          : kotaDataList
              .where((kota) =>
                  kota.nama.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  List<KotaData> get _searchedKotaList => searchQuery.isEmpty
      ? kotaDataList
      : kotaDataList
          .where((kota) =>
              kota.nama.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();

  KotaData? _getSelectedKotaData() {
    try {
      if (_searchedKotaList.any((kota) => kota.nama == selectedKota))
        return _searchedKotaList
            .firstWhere((kota) => kota.nama == selectedKota);
      return kotaDataList.firstWhere((kota) => kota.nama == selectedKota);
    } catch (e) {
      return _searchedKotaList.isNotEmpty ? _searchedKotaList.first : null;
    }
  }

  double _getIndicatorValue(KotaData kota, String indicator) {
    switch (indicator) {
      case 'samitasilayak':
        return kota.samitasilayak[selectedYear] ?? 0;
      case 'tikRemaja':
        return kota.tikRemaja[selectedYear] ?? 0;
      case 'tikDewasa':
        return kota.tikDewasa[selectedYear] ?? 0;
      case 'aktaLahir':
        return kota.aktaLahir[selectedYear] ?? 0;
      case 'apm':
        return kota.apm[selectedYear] ?? 0;
      case 'apk':
        return kota.apk[selectedYear] ?? 0;
      default:
        return 0;
    }
  }

  List<BarChartGroupData> _getBarChartData() {
    final kotaData = _getSelectedKotaData();
    if (kotaData == null) return [];
    final indicators = [
      _getIndicatorValue(kotaData, 'samitasilayak'),
      _getIndicatorValue(kotaData, 'tikRemaja'),
      _getIndicatorValue(kotaData, 'aktaLahir'),
      _getIndicatorValue(kotaData, 'apm'),
      _getIndicatorValue(kotaData, 'apk')
    ];
    return List.generate(
        indicators.length,
        (index) => BarChartGroupData(x: index, barRods: [
              BarChartRodData(
                  toY: indicators[index],
                  color: _getIndicatorColor(index),
                  width: 24,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)))
            ]));
  }

  Color _getIndicatorColor(int index) {
    const colors = [bpsBlue, bpsGreen, bpsOrange, bpsPurple, bpsRed];
    return colors[index % colors.length];
  }

  String _getIndicatorLabel(int index) {
    const labels = [
      'Sami\ntasilayak',
      'TIK\nRemaja',
      'Akta\nLahir',
      'APM',
      'APK'
    ];
    return labels[index];
  }

  bool _isYearAvailable(String indicator) {
    final kotaData = _getSelectedKotaData();
    switch (indicator) {
      case 'samitasilayak':
      case 'tikRemaja':
      case 'tikDewasa':
        return kotaData?.samitasilayak.containsKey(selectedYear) ?? false;
      case 'aktaLahir':
      case 'apm':
      case 'apk':
        return kotaData?.aktaLahir.containsKey(selectedYear) ?? false;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizing = ResponsiveSizing(context);
    final isSmallScreen = sizing.isVerySmall || sizing.isSmall;

    if (isLoading) {
      return Scaffold(
        backgroundColor: bpsBackground,
        body: Column(children: [
          _buildHeader(context, sizing, isSmallScreen),
          const Expanded(
              child:
                  Center(child: CircularProgressIndicator(color: bpsOrange)))
        ]),
      );
    }

    return Scaffold(
      backgroundColor: bpsBackground,
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
                      _buildYearSelector(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildSearchBar(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildKotaSelector(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildIndicatorCards(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildChartSection(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildComparisonChart(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildSDGsInfo(sizing, isSmallScreen),
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
      decoration: BoxDecoration(color: bpsOrange, boxShadow: [
        BoxShadow(
            color: bpsOrange.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4))
      ]),
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
                      child: Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: isSmallScreen ? 20 : 24))),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text('SDGs Jawa Tengah',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen
                            ? sizing.headerTitleSize + 4
                            : sizing.headerTitleSize + 8,
                        fontWeight: FontWeight.w700,
                        height: 1.1),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
              Icon(Icons.public_rounded,
                  color: Colors.white, size: isSmallScreen ? 20 : 24),
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
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: bpsOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: bpsOrange,
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
                  color: isSelected ? bpsOrange : bpsBackground,
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
                          color: isSelected ? bpsOrange : bpsBorder,
                          width: isSelected ? 2 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: bpsOrange.withOpacity(0.3),
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

  Widget _buildSearchBar(ResponsiveSizing sizing, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen
          ? sizing.statsCardPadding - 4
          : sizing.statsCardPadding),
      decoration: BoxDecoration(
          color: bpsCardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                  color: bpsGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.search_rounded,
                  color: bpsGreen, size: isSmallScreen ? 16 : 18)),
          SizedBox(width: sizing.itemSpacing),
          Text('Cari Kota/Kabupaten',
              style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  color: bpsTextPrimary))
        ]),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Container(
          decoration: BoxDecoration(
              color: bpsBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: bpsBorder)),
          child: TextField(
            decoration: InputDecoration(
                hintText: 'Ketik nama kota/kabupaten...',
                hintStyle: TextStyle(
                    color: bpsTextSecondary,
                    fontSize: isSmallScreen ? 13 : 14),
                prefixIcon: Icon(Icons.location_city,
                    color: bpsOrange, size: isSmallScreen ? 18 : 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: bpsTextSecondary),
                        onPressed: () => _filterSearch(''))
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
            style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
            onChanged: _filterSearch,
          ),
        ),
      ]),
    );
  }

  Widget _buildKotaSelector(ResponsiveSizing sizing, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen
          ? sizing.statsCardPadding - 4
          : sizing.statsCardPadding),
      decoration: BoxDecoration(
          color: bpsCardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                  color: bpsOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.place_rounded,
                  color: bpsOrange, size: isSmallScreen ? 16 : 18)),
          SizedBox(width: sizing.itemSpacing),
          Text('Pilih Kota/Kabupaten',
              style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  color: bpsTextPrimary))
        ]),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: bpsBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: bpsBorder)),
          child: DropdownButton<String>(
            value: _searchedKotaList.any((kota) => kota.nama == selectedKota)
                ? selectedKota
                : (_searchedKotaList.isNotEmpty
                    ? _searchedKotaList.first.nama
                    : null),
            isExpanded: true,
            underline: const SizedBox(),
            items: _searchedKotaList
                .map((kota) => DropdownMenuItem(
                    value: kota.nama,
                    child: Text(kota.nama,
                        style: TextStyle(fontSize: isSmallScreen ? 13 : 14))))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedKota = value);
                _cardController.reset();
                _cardController.forward();
              }
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildIndicatorCards(ResponsiveSizing sizing, bool isSmallScreen) {
    final kotaData = _getSelectedKotaData();
    if (kotaData == null)
      return Container(
          padding: EdgeInsets.all(sizing.statsCardPadding),
          decoration: BoxDecoration(
              color: bpsCardBg, borderRadius: BorderRadius.circular(16)),
          child: const Center(
              child: Text('Tidak ada data untuk kota yang dipilih',
                  style: TextStyle(color: bpsTextSecondary))));

    final stats = [
      {
        'title': 'Samitasilayak',
        'value': _isYearAvailable('samitasilayak')
            ? _getIndicatorValue(kotaData, 'samitasilayak')
            : 0.0,
        'icon': Icons.clean_hands,
        'color': bpsOrange,
        'available': _isYearAvailable('samitasilayak')
      },
      {
        'title': 'TIK Remaja',
        'value': _isYearAvailable('tikRemaja')
            ? _getIndicatorValue(kotaData, 'tikRemaja')
            : 0.0,
        'icon': Icons.computer,
        'color': bpsGreen,
        'available': _isYearAvailable('tikRemaja')
      },
      {
        'title': 'Akta Lahir',
        'value': _isYearAvailable('aktaLahir')
            ? _getIndicatorValue(kotaData, 'aktaLahir')
            : 0.0,
        'icon': Icons.assignment,
        'color': bpsOrange,
        'available': _isYearAvailable('aktaLahir')
      },
      {
        'title': 'APM',
        'value':
            _isYearAvailable('apm') ? _getIndicatorValue(kotaData, 'apm') : 0.0,
        'icon': Icons.school,
        'color': bpsPurple,
        'available': _isYearAvailable('apm')
      },
      {
        'title': 'APK',
        'value':
            _isYearAvailable('apk') ? _getIndicatorValue(kotaData, 'apk') : 0.0,
        'icon': Icons.auto_graph,
        'color': bpsRed,
        'available': _isYearAvailable('apk')
      },
    ];

    return Container(
      padding: EdgeInsets.all(isSmallScreen
          ? sizing.statsCardPadding - 4
          : sizing.statsCardPadding),
      decoration: BoxDecoration(
          color: bpsCardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                  color: bpsOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.analytics_rounded,
                  color: bpsOrange, size: isSmallScreen ? 16 : 18)),
          SizedBox(width: sizing.itemSpacing),
          Text('Indikator SDGs - $selectedYear',
              style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  color: bpsTextPrimary))
        ]),
        SizedBox(height: isSmallScreen ? 12 : 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return Padding(
                padding:
                    EdgeInsets.only(right: index < stats.length - 1 ? 10 : 0),
                child: FadeTransition(
                    opacity: _cardAnimation,
                    child: _buildIndicatorCard(
                        title: stat['title'] as String,
                        value: stat['value'] as double,
                        icon: stat['icon'] as IconData,
                        color: stat['color'] as Color,
                        available: stat['available'] as bool,
                        isSmallScreen: isSmallScreen)),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildIndicatorCard(
      {required String title,
      required double value,
      required IconData icon,
      required Color color,
      required bool available,
      required bool isSmallScreen}) {
    final percentage = available ? (value.clamp(0, 100) / 100) : 0.0;
    return Container(
      width: isSmallScreen ? 110 : 120,
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: available ? color.withOpacity(0.2) : bpsBorder)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(alignment: Alignment.center, children: [
          SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation(color),
                  backgroundColor: color.withOpacity(0.15))),
          Icon(icon, color: color, size: isSmallScreen ? 22 : 26),
        ]),
        const SizedBox(height: 10),
        Text(title,
            style: TextStyle(
                fontSize: isSmallScreen ? 10 : 11,
                color: bpsTextPrimary,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(available ? NumberFormatUtils.formatPercentage(value) : 'N/A',
            style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: bpsTextPrimary)),
      ]),
    );
  }

  Widget _buildChartSection(ResponsiveSizing sizing, bool isSmallScreen) {
    final kotaData = _getSelectedKotaData();
    final hasData = kotaData != null &&
        (_isYearAvailable('samitasilayak') ||
            _isYearAvailable('tikRemaja') ||
            _isYearAvailable('aktaLahir') ||
            _isYearAvailable('apm') ||
            _isYearAvailable('apk'));

    return Container(
      padding: EdgeInsets.all(isSmallScreen
          ? sizing.statsCardPadding - 4
          : sizing.statsCardPadding),
      decoration: BoxDecoration(
          color: bpsCardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                  color: bpsGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.bar_chart_rounded,
                  color: bpsGreen, size: isSmallScreen ? 16 : 18)),
          SizedBox(width: sizing.itemSpacing),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Perbandingan Indikator',
                    style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: bpsTextPrimary)),
                Text('${kotaData?.nama ?? 'Kota'} - Tahun $selectedYear',
                    style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 11,
                        color: bpsTextSecondary))
              ]))
        ]),
        SizedBox(height: isSmallScreen ? 16 : 20),
        if (!hasData)
          Container(
              height: 200,
              decoration: BoxDecoration(
                  color: bpsBackground,
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Icon(Icons.info_outline,
                        size: 36, color: bpsTextSecondary),
                    const SizedBox(height: 8),
                    Text('Data tidak tersedia untuk tahun ini',
                        style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            color: bpsTextSecondary))
                  ])))
        else
          SizedBox(
              height: 240,
              child: BarChart(BarChartData(
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.white,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final label = _getIndicatorLabel(groupIndex);
                        return BarTooltipItem(
                          label.replaceAll('\n', ' '),
                          const TextStyle(
                            color: bpsTextSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                          children: [
                            const TextSpan(text: '\n'),
                            TextSpan(
                              text: '${rod.toY.round()}%',
                              style: TextStyle(
                                color: _getIndicatorColor(groupIndex),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  barGroups: _getBarChartData(),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) =>
                          FlLine(color: bpsBorder, strokeWidth: 0.5)),
                  titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) => Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(_getIndicatorLabel(value.toInt()),
                                      style: TextStyle(
                                          fontSize: isSmallScreen ? 9 : 10,
                                          fontWeight: FontWeight.w500,
                                          color: bpsTextSecondary),
                                      textAlign: TextAlign.center)))),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              interval: 20,
                              getTitlesWidget: (value, meta) =>
                                  Text('${value.toInt()}%', style: TextStyle(fontSize: isSmallScreen ? 9 : 10, color: bpsTextSecondary)))),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
                  maxY: 110))),
      ]),
    );
  }

  Widget _buildComparisonChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final allKotaNames = kotaDataList.map((k) => k.nama).toList();
    final allTikRemaja =
        kotaDataList.map((k) => k.tikRemaja[selectedYear] ?? 0).toList();
    final sortedData = List.generate(allKotaNames.length,
        (index) => {'nama': allKotaNames[index], 'value': allTikRemaja[index]})
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
    final sortedNames = sortedData.map((e) => e['nama'] as String).toList();
    final sortedValues = sortedData.map((e) => e['value'] as double).toList();

    if (sortedValues.isEmpty) return const SizedBox.shrink();

    final average = sortedValues.reduce((a, b) => a + b) / sortedValues.length;
    final highest = sortedValues.first;
    final lowest = sortedValues.last;

    return Container(
      padding: EdgeInsets.all(isSmallScreen
          ? sizing.statsCardPadding - 4
          : sizing.statsCardPadding),
      decoration: BoxDecoration(
          color: bpsCardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                  color: bpsOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.leaderboard_rounded,
                  color: bpsOrange, size: isSmallScreen ? 16 : 18)),
          SizedBox(width: sizing.itemSpacing),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('TIK Remaja - Antar Kota',
                    style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: bpsTextPrimary)),
                Text('Tahun $selectedYear',
                    style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 11,
                        color: bpsTextSecondary))
              ]))
        ]),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
          decoration: BoxDecoration(
              color: bpsOrange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12)),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildComparisonStatItem(
                'Rata-rata',
                NumberFormatUtils.formatPercentage(average),
                Icons.bar_chart,
                bpsOrange,
                isSmallScreen),
            _buildComparisonStatItem(
                'Tertinggi',
                NumberFormatUtils.formatPercentage(highest),
                Icons.arrow_upward,
                bpsGreen,
                isSmallScreen),
            _buildComparisonStatItem(
                'Terendah',
                NumberFormatUtils.formatPercentage(lowest),
                Icons.arrow_downward,
                bpsRed,
                isSmallScreen),
          ]),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        SizedBox(
          height: 260,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(
                width: max(MediaQuery.of(context).size.width - 60,
                    sortedNames.length * 35.0),
                child: BarChart(BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: highest + 10,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.white,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final name = groupIndex < sortedNames.length ? sortedNames[groupIndex] : '';
                        return BarTooltipItem(
                          name,
                          const TextStyle(
                            color: bpsTextSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                          children: [
                            const TextSpan(text: '\n'),
                            TextSpan(
                              text: '${rod.toY.round()}%',
                              style: const TextStyle(
                                color: bpsOrange,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  barGroups: List.generate(sortedNames.length, (index) {
                    final isSelected = sortedNames[index] == selectedKota;
                    return BarChartGroupData(x: index, barRods: [
                      BarChartRodData(
                          toY: sortedValues[index],
                          color: isSelected
                              ? bpsOrange
                              : bpsOrange.withOpacity(0.4),
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)))
                    ]);
                  }),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) =>
                          FlLine(color: bpsBorder, strokeWidth: 0.5)),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= sortedNames.length)
                                return const SizedBox();
                              final nama = sortedNames[value.toInt()];
                              final isSelected = nama == selectedKota;
                              return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: RotatedBox(
                                          quarterTurns: 1,
                                          child: Text(
                                              nama.length > 12
                                                  ? '${nama.substring(0, 10)}..'
                                                  : nama,
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? bpsOrange
                                                      : bpsTextSecondary)))));
                            })),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}%',
                                style: TextStyle(
                                    fontSize: 9, color: bpsTextSecondary)))),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                )),
              ),
            ],
          ),
        ),
      ]),
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
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: bpsTextPrimary)),
    ]);
  }

  Widget _buildSDGsInfo(ResponsiveSizing sizing, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen
          ? sizing.statsCardPadding - 4
          : sizing.statsCardPadding),
      decoration: BoxDecoration(
          color: const Color(0xFF1B5E20),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: bpsGreen.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.eco,
              color: Colors.white, size: isSmallScreen ? 20 : 24),
          SizedBox(width: sizing.itemSpacing),
          Text('Tentang TPB/SDGs',
              style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white))
        ]),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Text(
              'Tujuan Pembangunan Berkelanjutan (SDGs) adalah komitmen global dan nasional dalam menyejahterakan masyarakat yang mencakup 17 tujuan global untuk tahun 2030.',
              style: TextStyle(
                  fontSize: isSmallScreen ? 11 : 12,
                  color: Colors.white,
                  height: 1.4)),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        _buildSDGsGrid(isSmallScreen),
      ]),
    );
  }

  Widget _buildSDGsGrid(bool isSmallScreen) {
    final sdgsList = [
      '1. Tanpa Kemiskinan',
      '2. Tanpa Kelaparan',
      '3. Kehidupan Sehat',
      '4. Pendidikan',
      '5. Kesetaraan Gender',
      '6. Air Bersih',
      '7. Energi Bersih',
      '8. Pekerjaan Layak',
      '9. Industri & Inovasi',
      '10. Berkurang Kesenjangan',
      '11. Kota Berkelanjutan',
      '12. Konsumsi Bertanggung Jawab',
      '13. Perubahan Iklim',
      '14. Ekosistem Lautan',
      '15. Ekosistem Daratan',
      '16. Perdamaian & Keadilan',
      '17. Kemitraan'
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: isSmallScreen ? 2.0 : 2.4),
      itemCount: sdgsList.length,
      itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2))),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Center(
              child: Text(sdgsList[index],
                  style: TextStyle(
                      fontSize: isSmallScreen ? 8 : 9,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis))),
    );
  }

  Widget _buildKesimpulanCard(ResponsiveSizing sizing, bool isSmallScreen) {
    if (kotaDataList.isEmpty) {
      return const SizedBox.shrink();
    }

    // Find Semarang data
    final semarangData = kotaDataList.firstWhere(
      (kota) => kota.nama.toLowerCase().contains('semarang'),
      orElse: () => kotaDataList.first,
    );

    final sortedYears = availableYears..sort();
    final latestYear = sortedYears.last;
    final firstYear = sortedYears.first;

    // Calculate average score for a year
    double calculateAverageScore(int year) {
      final values = [
        semarangData.samitasilayak[year],
        semarangData.tikRemaja[year],
        semarangData.tikDewasa[year],
        semarangData.aktaLahir[year],
        semarangData.apm[year],
        semarangData.apk[year],
      ].where((v) => v != null).toList();

      if (values.isEmpty) return 0.0;
      return values.reduce((a, b) => a! + b!)! / values.length;
    }

    final latestScore = calculateAverageScore(latestYear);
    final firstScore = calculateAverageScore(firstYear);

    // Count indicators on track (assuming target is improvement over time)
    int onTrackCount = 0;
    int totalIndicators = 0;

    final indicators = [
      semarangData.samitasilayak,
      semarangData.tikRemaja,
      semarangData.tikDewasa,
      semarangData.aktaLahir,
      semarangData.apm,
      semarangData.apk,
    ];

    for (final indicator in indicators) {
      if (indicator.containsKey(latestYear) &&
          indicator.containsKey(firstYear)) {
        totalIndicators++;
        final latest = indicator[latestYear]!;
        final first = indicator[firstYear]!;
        // For most indicators, higher is better
        if (latest >= first) {
          onTrackCount++;
        }
      }
    }

    // Calculate progress rate
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
      title: 'SDGs Kota Semarang',
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
