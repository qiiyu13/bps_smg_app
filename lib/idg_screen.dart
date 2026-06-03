import 'package:lawang/number_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'responsive_sizing.dart';
import 'kesimpulan_widget.dart';
import 'services/github_data_service.dart';
import 'dart:async';
import 'app_theme.dart';

class IDGData {
  final int year;
  final double? sumbangan;
  final double? tenaga;
  final double? parlemen;
  final double? idg;
  final double? ikg;

  IDGData({
    required this.year,
    this.sumbangan,
    this.tenaga,
    this.parlemen,
    this.idg,
    this.ikg,
  });

  String get idgFormatted => idg != null
      ? NumberFormatUtils.formatDecimal(idg!, decimalPlaces: 2)
      : 'N/A';
  String get ikgFormatted => ikg != null
      ? NumberFormatUtils.formatDecimal(ikg!, decimalPlaces: 2)
      : 'N/A';
  String get sumbanganFormatted => sumbangan != null
      ? NumberFormatUtils.formatDecimal(sumbangan!, decimalPlaces: 2)
      : 'N/A';
  String get tenagaFormatted => tenaga != null
      ? NumberFormatUtils.formatDecimal(tenaga!, decimalPlaces: 2)
      : 'N/A';
  String get parlemenFormatted => parlemen != null
      ? NumberFormatUtils.formatDecimal(parlemen!, decimalPlaces: 2)
      : 'N/A';
}

class IDGScreen extends StatefulWidget {
  const IDGScreen({super.key});

  @override
  State<IDGScreen> createState() => _IDGScreenState();
}

class _IDGScreenState extends State<IDGScreen>
    with AutomaticKeepAliveClientMixin {
  Map<int, IDGData> idgDataByYear = {};
  List<int> availableYears = [];
  int selectedYear = 2024;
  bool isLoading = true;
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
    _loadIDGData();
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

  Future<void> _loadIDGData() async {
    try {
      final githubData = GitHubDataService.getData('idg');
      if (githubData != null && githubData['idgData'] != null) {
        final idgDataRaw = githubData['idgData'] as Map<String, dynamic>;
        Map<int, IDGData> processedData = {};
        idgDataRaw.forEach((key, value) {
          final int year = int.parse(key);
          final Map<String, dynamic> data = Map<String, dynamic>.from(value as Map);
          processedData[year] = IDGData(
            year: year,
            sumbangan: (data['SUMBANGAN'] as num?)?.toDouble(),
            tenaga: (data['TENAGA'] as num?)?.toDouble(),
            parlemen: (data['PARLEMEN'] as num?)?.toDouble(),
            idg: (data['IDG'] as num?)?.toDouble(),
            ikg: (data['IKG'] as num?)?.toDouble(),
          );
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              idgDataByYear = processedData;
              availableYears = processedData.keys.toList()
                ..sort((a, b) => a.compareTo(b));
              if (availableYears.isNotEmpty) {
                selectedYear = availableYears.last;
              }
              isLoading = false;
            });
          }
        });
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedData = prefs.getString('idg_data');

      Map<int, IDGData> processedData = {};

      if (savedData != null) {
        Map<String, dynamic> decoded =
            json.decode(savedData) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          final int year = int.parse(key);
          final Map<String, dynamic> data = value as Map<String, dynamic>;
          processedData[year] = IDGData(
            year: year,
            sumbangan: data['sumbangan'] as double?,
            tenaga: data['tenaga'] as double?,
            parlemen: data['parlemen'] as double?,
            idg: data['idg'] as double?,
            ikg: data['ikg'] as double?,
          );
        });
      } else {
        final List<Map<String, dynamic>> rawData = [
          {
            "Tahun": 2020,
            "SUMBANGAN": 37.13,
            "TENAGA": 51.15,
            "PARLEMEN": 20.41,
            "IDG": 74.67,
            "IKG": 0.157
          },
          {
            "Tahun": 2021,
            "SUMBANGAN": 37.46,
            "TENAGA": 51.30,
            "PARLEMEN": 18.75,
            "IDG": 73.64,
            "IKG": 0.142
          },
          {
            "Tahun": 2022,
            "SUMBANGAN": 38.05,
            "TENAGA": 49.78,
            "PARLEMEN": 18.00,
            "IDG": 73.93,
            "IKG": 0.266
          },
          {
            "Tahun": 2023,
            "SUMBANGAN": 37.93,
            "TENAGA": 48.76,
            "PARLEMEN": 18.00,
            "IDG": 73.86,
            "IKG": 0.168
          },
          {
            "Tahun": 2024,
            "SUMBANGAN": 37.68,
            "TENAGA": 50.42,
            "PARLEMEN": 24.00,
            "IDG": 78.71,
            "IKG": 0.14
          },
          {
            "Tahun": 2025,
            "SUMBANGAN": null,
            "TENAGA": null,
            "PARLEMEN": null,
            "IDG": null,
            "IKG": null
          },
        ];

        for (var row in rawData) {
          final int year = row["Tahun"] as int;
          processedData[year] = IDGData(
            year: year,
            sumbangan: row["SUMBANGAN"] as double?,
            tenaga: row["TENAGA"] as double?,
            parlemen: row["PARLEMEN"] as double?,
            idg: row["IDG"] as double?,
            ikg: row["IKG"] as double?,
          );
        }
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            idgDataByYear = processedData;
            availableYears = processedData.keys.toList()
              ..sort((a, b) => a.compareTo(b));
            if (availableYears.isNotEmpty) {
              selectedYear = availableYears.last;
            }
            isLoading = false;
          });
        }
      });
    } catch (e) {
      debugPrint('Error loading IDG data: $e');
      setState(() => isLoading = false);
    }
  }

  IDGData get currentIDGData {
    if (idgDataByYear.isEmpty) return IDGData(year: selectedYear);
    return idgDataByYear[selectedYear] ?? idgDataByYear[availableYears.first]!;
  }

  @override
  Widget build(BuildContext context) {
    final sizing = ResponsiveSizing(context);
    final isSmallScreen = sizing.isVerySmall || sizing.isSmall;

    if (isLoading) {
      return Scaffold(
        backgroundColor: bpsBackground,
        body: Column(
          children: [
            _buildHeader(context, sizing, isSmallScreen),
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: bpsOrange),
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
                      _buildIDGMainCard(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildIDGOnlyChart(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildIKGOnlyChart(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildIDGDescription(sizing, isSmallScreen),
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

  Widget _buildKesimpulanCard(ResponsiveSizing sizing, bool isSmallScreen) {
    if (idgDataByYear.isEmpty || availableYears.length < 2) {
      return const SizedBox.shrink();
    }

    final sortedYears = availableYears..sort((a, b) => a.compareTo(b));
    final latestYear = sortedYears.last;
    final firstYear = sortedYears.first;
    final latestData = idgDataByYear[latestYear];
    final firstData = idgDataByYear[firstYear];

    if (latestData == null ||
        firstData == null ||
        latestData.idg == null ||
        firstData.idg == null) {
      return const SizedBox.shrink();
    }

    final conclusionData = KesimpulanGenerator.generateIDGConclusion(
      latestYear: latestYear,
      firstYear: firstYear,
      latestIDG: latestData.idg!,
      firstIDG: firstData.idg!,
    );

    return KesimpulanWidget(
      title: 'Indeks Pembangunan Gender',
      conclusion: conclusionData['conclusion'] as String,
      status: conclusionData['status'] as KesimpulanStatus,
      sizing: sizing,
      isSmallScreen: isSmallScreen,
      additionalPoints: (conclusionData['additionalPoints'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Widget _buildHeader(
      BuildContext context, ResponsiveSizing sizing, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: bpsOrange,
        boxShadow: [
          BoxShadow(
              color: bpsOrange.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 4))
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
                  child: Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: isSmallScreen ? 20 : 24),
                ),
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text('Indeks Pemberdayaan Gender',
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
              Icon(Icons.groups_rounded,
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
              Icon(
                Icons.calendar_today_rounded,
                color: bpsOrange,
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

  Widget _buildIDGMainCard(ResponsiveSizing sizing, bool isSmallScreen) {
    final data = currentIDGData;
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
                color: bpsOrange,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  'Indikator Utama IDG',
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
                    color: bpsOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: bpsOrange,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap untuk detail',
                        style: TextStyle(
                          fontSize: 12,
                          color: bpsOrange,
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
                value: data.idgFormatted,
                label: 'IDG',
                color: bpsPurple,
                icon: Icons.groups,
                description:
                    'Indeks Pemberdayaan Gender (IDG) mengukur kesetaraan peran antara laki-laki dan perempuan dalam bidang ekonomi, politik, dan pengambilan keputusan.',
                isFirst: true,
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: data.ikgFormatted,
                label: 'IKG',
                color: bpsBlue,
                icon: Icons.balance,
                description:
                    'Indeks Ketimpangan Gender (IKG) mengukur ketidaksetaraan pencapaian antara laki-laki dan perempuan dalam kesehatan reproduksi, pemberdayaan, dan pasar tenaga kerja.',
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${data.sumbanganFormatted}%',
                label: 'Sumbangan Pendapatan',
                color: bpsGreen,
                icon: Icons.attach_money,
                description:
                    'Sumbangan pendapatan perempuan menunjukkan kontribusi ekonomi perempuan terhadap total pendapatan rumah tangga.',
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${data.tenagaFormatted}%',
                label: 'Tenaga Profesional',
                color: bpsOrange,
                icon: Icons.business_center,
                description:
                    'Persentase perempuan sebagai tenaga profesional menunjukkan partisipasi perempuan dalam pekerjaan profesional dan teknis.',
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${data.parlemenFormatted}%',
                label: 'Keterlibatan Parlemen',
                color: bpsRed,
                icon: Icons.account_balance,
                description:
                    'Keterlibatan perempuan di parlemen menunjukkan partisipasi politik perempuan dalam lembaga legislatif.',
                isLast: true,
                isSmallScreen: isSmallScreen,
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
    required bool isSmallScreen,
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

  Widget _buildIDGOnlyChart(ResponsiveSizing sizing, bool isSmallScreen) {
    List<FlSpot> idgSpots = [];
    List<String> yearLabels = [];
    List<int> validYearIndices = [];

    for (int i = 0; i < availableYears.length; i++) {
      final year = availableYears[i];
      final data = idgDataByYear[year];
      if (data?.idg != null) {
        idgSpots.add(FlSpot(i.toDouble(), data!.idg!));
        yearLabels.add(year.toString());
        validYearIndices.add(i);
      }
    }

    double minY = 70.0;
    double maxY = 80.0;
    double yInterval = 2.0;

    if (idgSpots.isNotEmpty) {
      double minIDG = idgSpots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
      double maxIDG = idgSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

      minY = (minIDG - 2.0).floorToDouble();
      maxY = (maxIDG + 2.0).ceilToDouble();

      if (maxY - minY < 4.0) {
        double mid = (minY + maxY) / 2;
        minY = mid - 2.0;
        maxY = mid + 2.0;
      }

      double range = maxY - minY;
      yInterval = (range / 5).roundToDouble();
      if (yInterval < 1.0) yInterval = 1.0;
    }

    List<FlSpot> chartSpots = List.from(idgSpots);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                      color: bpsPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.trending_up,
                      color: bpsPurple, size: isSmallScreen ? 16 : 18)),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Tren IDG',
                        style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w700,
                            color: bpsTextPrimary)),
                    Text('Nilai lebih tinggi = lebih baik',
                        style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 11,
                            color: bpsPurple))
                  ])),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          idgSpots.isNotEmpty
              ? SizedBox(
                  height: isSmallScreen ? 200 : 240,
                  child: LineChart(
                    LineChartData(
                      minY: minY,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: yInterval,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 &&
                                  index < validYearIndices.length) {
                                return Text(
                                  yearLabels[index],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: bpsPurple,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: yInterval,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                NumberFormatUtils.formatValue(value, decimalPlaces: 0),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          ),
                          axisNameWidget: const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'IDG',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartSpots,
                          isCurved: true,
                          color: bpsPurple,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) {
                              if (spot.y.isNaN) {
                                return FlDotCirclePainter(
                                  radius: 0,
                                  color: Colors.transparent,
                                  strokeWidth: 0,
                                  strokeColor: Colors.transparent,
                                );
                              }
                              return FlDotCirclePainter(
                                radius: 6,
                                color: bpsPurple,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: bpsPurple.withOpacity(0.1),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (spot) => Colors.white,
                          tooltipRoundedRadius: 8,
                          tooltipBorder: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              if (spot.y.isNaN) return null;
                              final index = spot.x.toInt();
                              final year = availableYears[index];
                              return LineTooltipItem(
                                '$year\nIDG: ${NumberFormatUtils.formatValue(spot.y, decimalPlaces: 2)}',
                                const TextStyle(
                                  color: bpsPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: Text('Data tidak tersedia',
                      style: TextStyle(color: bpsTextSecondary))),
        ],
      ),
    );
  }

  Widget _buildIKGOnlyChart(ResponsiveSizing sizing, bool isSmallScreen) {
    List<BarChartGroupData> barGroups = [];
    List<String> yearLabels = [];

    for (int i = 0; i < availableYears.length; i++) {
      final year = availableYears[i];
      final data = idgDataByYear[year];
      if (data?.ikg != null) {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data!.ikg!,
                color: bpsBlue,
                width: isSmallScreen ? 28 : 36,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 0.30,
                  color: bpsBlue.withOpacity(0.06),
                ),
              ),
            ],
          ),
        );
        yearLabels.add(year.toString());
      }
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                      color: bpsOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.trending_down,
                      color: bpsOrange, size: isSmallScreen ? 16 : 18)),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Tren IKG (Ketimpangan)',
                        style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w700,
                            color: bpsTextPrimary)),
                    Text('Nilai lebih rendah = lebih baik',
                        style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 11,
                            color: bpsOrange))
                  ])),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          SizedBox(
            height: 220,
            child: barGroups.isNotEmpty
                ? BarChart(
                    BarChartData(
                      maxY: 0.30,
                      minY: 0,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 0.05,
                        getDrawingHorizontalLine: (value) =>
                            FlLine(color: bpsBorder, strokeWidth: 0.5),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 0.05,
                            getTitlesWidget: (value, meta) => Text(
                              NumberFormatUtils.formatDecimal(value,
                                  decimalPlaces: 2),
                              style: TextStyle(
                                  fontSize: isSmallScreen ? 9 : 10,
                                  color: bpsTextSecondary),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < yearLabels.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(yearLabels[index],
                                      style: TextStyle(
                                          fontSize: isSmallScreen ? 9 : 10,
                                          color: bpsTextSecondary)),
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
                      barGroups: barGroups,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.white,
                          tooltipRoundedRadius: 8,
                          tooltipPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final index = group.x;
                            if (index >= 0 && index < yearLabels.length) {
                              return BarTooltipItem(
                                '${yearLabels[index]}\nIKG: ${NumberFormatUtils.formatDecimal(rod.toY, decimalPlaces: 3)}',
                                const TextStyle(
                                    color: bpsTextPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text('Data tidak tersedia',
                        style: TextStyle(color: bpsTextSecondary))),
          ),
        ],
      ),
    );
  }

  Widget _buildIDGDescription(ResponsiveSizing sizing, bool isSmallScreen) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                      color: bpsGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.info_outline_rounded,
                      color: bpsGreen, size: isSmallScreen ? 16 : 18)),
              SizedBox(width: sizing.itemSpacing),
              Text('Tentang IDG & IKG',
                  style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w700,
                      color: bpsTextPrimary)),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildDescriptionItem(
              'IDG (Indeks Pemberdayaan Gender)',
              'Mengukur kesetaraan peran antara laki-laki dan perempuan dalam bidang ekonomi, politik, dan pengambilan keputusan.',
              bpsPurple,
              isSmallScreen),
          const SizedBox(height: 12),
          _buildDescriptionItem(
              'IKG (Indeks Ketimpangan Gender)',
              'Mengukur ketidaksetaraan pencapaian antara laki-laki dan perempuan dalam kesehatan reproduksi, pemberdayaan, dan pasar tenaga kerja.',
              bpsBlue,
              isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildDescriptionItem(
      String title, String description, Color color, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.15))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  color: color)),
          const SizedBox(height: 4),
          Text(description,
              style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 11,
                  color: bpsTextSecondary,
                  height: 1.4)),
        ],
      ),
    );
  }
}
