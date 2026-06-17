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
import 'widgets/section_kit.dart';

class IPGData {
  final int year;
  final double? uhh, hls, rls, ppp, ikg, ipg;
  final double? uhhMale,
      uhhFemale,
      hlsMale,
      hlsFemale,
      rlsMale,
      rlsFemale,
      pppMale,
      pppFemale,
      ipmMale,
      ipmFemale;

  IPGData(
      {required this.year,
      this.uhh,
      this.hls,
      this.rls,
      this.ppp,
      this.ikg,
      this.ipg,
      this.uhhMale,
      this.uhhFemale,
      this.hlsMale,
      this.hlsFemale,
      this.rlsMale,
      this.rlsFemale,
      this.pppMale,
      this.pppFemale,
      this.ipmMale,
      this.ipmFemale});

  String get ipgFormatted => ipg != null
      ? NumberFormatUtils.formatDecimal(ipg!, decimalPlaces: 1)
      : 'N/A';
  String get ikgFormatted => ikg != null
      ? NumberFormatUtils.formatDecimal(ikg! * 100, decimalPlaces: 1)
      : 'N/A';
  String get uhhMaleFormatted => uhhMale != null
      ? NumberFormatUtils.formatDecimal(uhhMale!, decimalPlaces: 1)
      : 'N/A';
  String get uhhFemaleFormatted => uhhFemale != null
      ? NumberFormatUtils.formatDecimal(uhhFemale!, decimalPlaces: 1)
      : 'N/A';
  String get hlsMaleFormatted => hlsMale != null
      ? NumberFormatUtils.formatDecimal(hlsMale!, decimalPlaces: 1)
      : 'N/A';
  String get hlsFemaleFormatted => hlsFemale != null
      ? NumberFormatUtils.formatDecimal(hlsFemale!, decimalPlaces: 1)
      : 'N/A';
  String get rlsMaleFormatted => rlsMale != null
      ? NumberFormatUtils.formatDecimal(rlsMale!, decimalPlaces: 1)
      : 'N/A';
  String get rlsFemaleFormatted => rlsFemale != null
      ? NumberFormatUtils.formatDecimal(rlsFemale!, decimalPlaces: 1)
      : 'N/A';
  String get pppMaleFormatted => pppMale != null
      ? NumberFormatUtils.formatInteger((pppMale! / 1000).round())
      : 'N/A';
  String get pppFemaleFormatted => pppFemale != null
      ? NumberFormatUtils.formatInteger((pppFemale! / 1000).round())
      : 'N/A';

  factory IPGData.fromMap(int year, Map<String, dynamic> map) {
    return IPGData(
      year: year,
      uhh: _avg(map['UHH_Laki'], map['UHH_Perempuan']),
      hls: _avg(map['HLS_Laki'], map['HLS_Perempuan']),
      rls: _avg(map['RLS_Laki'], map['RLS_Perempuan']),
      ppp: _avg(map['PPP_Laki'], map['PPP_Perempuan']),
      ipg: (map['IPG'] as num?)?.toDouble(),
      ikg: (map['IKG'] as num?)?.toDouble(),
      uhhMale: (map['UHH_Laki'] as num?)?.toDouble(),
      uhhFemale: (map['UHH_Perempuan'] as num?)?.toDouble(),
      hlsMale: (map['HLS_Laki'] as num?)?.toDouble(),
      hlsFemale: (map['HLS_Perempuan'] as num?)?.toDouble(),
      rlsMale: (map['RLS_Laki'] as num?)?.toDouble(),
      rlsFemale: (map['RLS_Perempuan'] as num?)?.toDouble(),
      pppMale: (map['PPP_Laki'] as num?)?.toDouble(),
      pppFemale: (map['PPP_Perempuan'] as num?)?.toDouble(),
      ipmMale: (map['IPM_Laki'] as num?)?.toDouble(),
      ipmFemale: (map['IPM_Perempuan'] as num?)?.toDouble(),
    );
  }

  static double? _avg(dynamic a, dynamic b) {
    if (a == null || b == null) return null;
    return ((a as num).toDouble() + (b as num).toDouble()) / 2;
  }

  Map<String, dynamic> toMap() => {
        'UHH_Laki': uhhMale,
        'UHH_Perempuan': uhhFemale,
        'HLS_Laki': hlsMale,
        'HLS_Perempuan': hlsFemale,
        'RLS_Laki': rlsMale,
        'RLS_Perempuan': rlsFemale,
        'PPP_Laki': pppMale,
        'PPP_Perempuan': pppFemale,
        'IPM_Laki': ipmMale,
        'IPM_Perempuan': ipmFemale,
        'IPG': ipg,
        'IKG': ikg,
      };
}

class IPGScreen extends StatefulWidget {
  const IPGScreen({super.key});

  @override
  State<IPGScreen> createState() => _IPGScreenState();
}

class _IPGScreenState extends State<IPGScreen>
    with AutomaticKeepAliveClientMixin {
  Map<int, IPGData> ipgDataByYear = {};
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
    _loadIPGData();
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

  Future<void> _loadIPGData() async {
    try {
      final githubData = GitHubDataService.getData('ipg');
      if (githubData != null && githubData['ipgData'] != null) {
        final ipgDataRaw = githubData['ipgData'] as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            ipgDataByYear = ipgDataRaw.map(
              (key, value) => MapEntry(
                int.parse(key),
                IPGData.fromMap(
                    int.parse(key), Map<String, dynamic>.from(value as Map)),
              ),
            );
            availableYears = ipgDataByYear.keys.toList()
              ..sort((a, b) => a.compareTo(b));
            if (availableYears.isNotEmpty) {
              selectedYear = availableYears.last;
            }
            isLoading = false;
          });
        }
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('ipg_data');

      if (mounted) {
        setState(() {
          if (savedData != null) {
            final decoded = json.decode(savedData) as Map<String, dynamic>;
            ipgDataByYear = decoded.map(
              (key, value) => MapEntry(
                int.parse(key),
                IPGData.fromMap(
                    int.parse(key), Map<String, dynamic>.from(value as Map)),
              ),
            );
          } else {
            final List<Map<String, dynamic>> rawData = [
              {
                "Tahun": 2020,
                "UHH_Laki": 71.5,
                "UHH_Perempuan": 75.2,
                "HLS_Laki": 12.8,
                "HLS_Perempuan": 13.1,
                "RLS_Laki": 11.42,
                "RLS_Perempuan": 10.16,
                "PPP_Laki": 16128.0,
                "PPP_Perempuan": 14287.0,
                "IPM_Laki": 85.22,
                "IPM_Perempuan": 81.38,
                "IPG": 95.49,
                "IKG": 0.045
              },
              {
                "Tahun": 2021,
                "UHH_Laki": 71.6,
                "UHH_Perempuan": 75.3,
                "HLS_Laki": 12.9,
                "HLS_Perempuan": 13.2,
                "RLS_Laki": 11.50,
                "RLS_Perempuan": 10.25,
                "PPP_Laki": 16450.0,
                "PPP_Perempuan": 14520.0,
                "IPM_Laki": 85.65,
                "IPM_Perempuan": 81.82,
                "IPG": 95.67,
                "IKG": 0.044
              },
              {
                "Tahun": 2022,
                "UHH_Laki": 71.7,
                "UHH_Perempuan": 75.4,
                "HLS_Laki": 13.0,
                "HLS_Perempuan": 13.3,
                "RLS_Laki": 11.58,
                "RLS_Perempuan": 10.34,
                "PPP_Laki": 16780.0,
                "PPP_Perempuan": 14760.0,
                "IPM_Laki": 86.08,
                "IPM_Perempuan": 82.26,
                "IPG": 95.93,
                "IKG": 0.043
              },
              {
                "Tahun": 2023,
                "UHH_Laki": 71.8,
                "UHH_Perempuan": 75.5,
                "HLS_Laki": 13.1,
                "HLS_Perempuan": 13.4,
                "RLS_Laki": 11.66,
                "RLS_Perempuan": 10.43,
                "PPP_Laki": 17120.0,
                "PPP_Perempuan": 15010.0,
                "IPM_Laki": 86.51,
                "IPM_Perempuan": 82.70,
                "IPG": 95.96,
                "IKG": 0.042
              },
              {
                "Tahun": 2024,
                "UHH_Laki": 71.9,
                "UHH_Perempuan": 75.6,
                "HLS_Laki": 13.2,
                "HLS_Perempuan": 13.5,
                "RLS_Laki": 11.74,
                "RLS_Perempuan": 10.52,
                "PPP_Laki": 17470.0,
                "PPP_Perempuan": 15270.0,
                "IPM_Laki": 86.94,
                "IPM_Perempuan": 83.14,
                "IPG": 96.37,
                "IKG": 0.041
              },
              {
                "Tahun": 2025,
                "UHH_Laki": 71.9,
                "UHH_Perempuan": 75.6,
                "HLS_Laki": 13.2,
                "HLS_Perempuan": 13.5,
                "RLS_Laki": 11.74,
                "RLS_Perempuan": 10.52,
                "PPP_Laki": 17470.0,
                "PPP_Perempuan": 15270.0,
                "IPM_Laki": null,
                "IPM_Perempuan": null,
                "IPG": null,
                "IKG": null
              },
            ];

            final Map<int, IPGData> processedData = {};
            for (final row in rawData) {
              final int year = row["Tahun"] as int;
              processedData[year] = IPGData(
                year: year,
                uhh: ((row["UHH_Laki"] as num) +
                            (row["UHH_Perempuan"] as num)) /
                        2
                    ,
                hls: ((row["HLS_Laki"] as num) +
                            (row["HLS_Perempuan"] as num)) /
                        2
                    ,
                rls: ((row["RLS_Laki"] as num) +
                            (row["RLS_Perempuan"] as num)) /
                        2
                    ,
                ppp: ((row["PPP_Laki"] as num) +
                            (row["PPP_Perempuan"] as num)) /
                        2
                    ,
                ipg: (row["IPG"] as num?)?.toDouble(),
                ikg: (row["IKG"] as num?)?.toDouble(),
                uhhMale: (row["UHH_Laki"] as num).toDouble(),
                uhhFemale: (row["UHH_Perempuan"] as num).toDouble(),
                hlsMale: (row["HLS_Laki"] as num).toDouble(),
                hlsFemale: (row["HLS_Perempuan"] as num).toDouble(),
                rlsMale: (row["RLS_Laki"] as num).toDouble(),
                rlsFemale: (row["RLS_Perempuan"] as num).toDouble(),
                pppMale: (row["PPP_Laki"] as num).toDouble(),
                pppFemale: (row["PPP_Perempuan"] as num).toDouble(),
                ipmMale: (row["IPM_Laki"] as num?)?.toDouble(),
                ipmFemale: (row["IPM_Perempuan"] as num?)?.toDouble(),
              );
            }
            ipgDataByYear = processedData;
          }

          availableYears = ipgDataByYear.keys.toList()
            ..sort((a, b) => a.compareTo(b));
          if (availableYears.isNotEmpty) {
            selectedYear = availableYears.last;
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading IPG data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  IPGData get currentIPGData {
    if (ipgDataByYear.isEmpty) return IPGData(year: selectedYear);
    return ipgDataByYear[selectedYear] ?? ipgDataByYear[availableYears.first]!;
  }

  @override
  Widget build(BuildContext context) {
    final sizing = ResponsiveSizing(context);
    final isSmallScreen = sizing.isVerySmall || sizing.isSmall;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context, sizing, isSmallScreen),
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: bpsOrange),
                        SizedBox(height: sizing.sectionSpacing - 8),
                        Text(
                          'Memuat data IPG...',
                          style: TextStyle(
                            fontSize: sizing.categoryLabelFontSize,
                            color: bpsTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ipgDataByYear.isEmpty
                    ? Center(
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
                                'Data IPG belum tersedia',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: sizing.categoryLabelFontSize,
                                  color: bpsTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : CustomScrollView(
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
                                  title: 'Indikator Utama IPG',
                                  subtitle: 'Ketuk untuk penjelasan',
                                  accent: bpsOrange,
                                  surface: false,
                                  isFirst: true,
                                  isSmall: isSmallScreen,
                                  child: _buildMainIndicators(
                                      sizing, isSmallScreen),
                                ),
                                SpineSection(
                                  number: '02',
                                  overline: 'Gender',
                                  title: 'Perbandingan Gender',
                                  accent: bpsOrange,
                                  surface: false,
                                  isSmall: isSmallScreen,
                                  child: _buildGenderComparison(
                                      sizing, isSmallScreen),
                                ),
                                SpineSection(
                                  number: '03',
                                  overline: 'Tren',
                                  title: 'Tren IPG',
                                  accent: bpsOrange,
                                  surface: false,
                                  isSmall: isSmallScreen,
                                  child: _buildIPGChart(sizing, isSmallScreen),
                                ),
                                SpineSection(
                                  number: '04',
                                  overline: 'Tren',
                                  title: 'Tren IKG',
                                  accent: bpsOrange,
                                  surface: false,
                                  isSmall: isSmallScreen,
                                  child: _buildIKGChart(sizing, isSmallScreen),
                                ),
                                SpineSection(
                                  number: '05',
                                  overline: 'Tentang',
                                  title: 'Tentang IPG',
                                  accent: bpsOrange,
                                  surface: false,
                                  isSmall: isSmallScreen,
                                  child: _buildInfoCard(sizing, isSmallScreen),
                                ),
                                SpineSection(
                                  overline: 'Ringkasan',
                                  title: 'Kesimpulan',
                                  accent: bpsOrange,
                                  surface: false,
                                  isLast: true,
                                  isSmall: isSmallScreen,
                                  child: _buildKesimpulanCard(
                                      sizing, isSmallScreen),
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

  Widget _buildKesimpulanCard(ResponsiveSizing sizing, bool isSmallScreen) {
    if (ipgDataByYear.isEmpty || availableYears.length < 2) {
      return const SizedBox.shrink();
    }

    final sortedYears = availableYears..sort((a, b) => a.compareTo(b));
    final latestYear = sortedYears.last;
    final firstYear = sortedYears.first;
    final latestData = ipgDataByYear[latestYear];
    final firstData = ipgDataByYear[firstYear];

    if (latestData == null ||
        firstData == null ||
        latestData.ipg == null ||
        firstData.ipg == null) {
      return const SizedBox.shrink();
    }

    final conclusionData = KesimpulanGenerator.generateIPGConclusion(
      latestYear: latestYear,
      firstYear: firstYear,
      latestIPG: latestData.ipg!,
      firstIPG: firstData.ipg!,
    );

    return KesimpulanWidget(
      title: 'Indeks Pemberdayaan Gender',
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
    return CategoryHeader(
      overline: 'INDEKS PEMBANGUNAN',
      title: 'Indeks Pembangunan Gender',
      icon: Icons.balance_rounded,
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

  Widget _buildHero(ResponsiveSizing sizing, bool isSmallScreen) {
    final data = currentIPGData;
    final sorted = [...availableYears]..sort();
    final prev = ipgDataByYear[selectedYear - 1];
    final delta = (data.ipg != null && prev?.ipg != null)
        ? data.ipg! - prev!.ipg!
        : null;
    final spark = sorted.map((y) => ipgDataByYear[y]?.ipg ?? 0.0).toList();
    return IndicatorHero(
      overline: 'INDEKS PEMBANGUNAN GENDER',
      value: data.ipgFormatted,
      subtitle: 'IPG • Kota Semarang',
      badge: 'Tahun $selectedYear',
      accent: bpsOrange,
      delta: delta,
      deltaUnit: 'poin',
      sparkline: spark.length > 1 ? spark : null,
      isSmall: isSmallScreen,
      facts: [
        HeroFact('IKG', '${data.ikgFormatted}%'),
        HeroFact('IPM Laki-laki', data.ipmMale != null ? NumberFormatUtils.formatDecimal(data.ipmMale!) : 'N/A'),
        HeroFact('IPM Perempuan', data.ipmFemale != null ? NumberFormatUtils.formatDecimal(data.ipmFemale!) : 'N/A'),
      ],
    );
  }

  Widget _buildMainIndicators(ResponsiveSizing sizing, bool isSmallScreen) {
    final data = currentIPGData;

    return SectionPanel(
      isSmall: isSmallScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildCompactIndicatorRow(
                context: context,
                value: data.ipgFormatted,
                label: 'IPG',
                color: bpsPurple,
                icon: Icons.balance,
                description:
                    'Indeks Pembangunan Gender (IPG) mengukur pencapaian dalam dimensi dan variabel yang sama dengan IPM, dengan memperhatikan disparitas antara laki-laki dan perempuan.',
                isFirst: true,
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${data.ikgFormatted}%',
                label: 'IKG',
                color: bpsBlue,
                icon: Icons.equalizer,
                description:
                    'Indeks Ketimpangan Gender (IKG) mengukur kerugian akibat ketidaksetaraan gender dari 3 dimensi: kesehatan reproduksi, pemberdayaan, dan pasar tenaga kerja.',
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: data.ipmMale != null
                    ? NumberFormatUtils.formatDecimal(data.ipmMale!)
                    : 'N/A',
                label: 'IPM Laki-laki',
                color: Colors.indigo,
                icon: Icons.male,
                description:
                    'Indeks Pembangunan Manusia (IPM) untuk penduduk laki-laki mengukur capaian pembangunan manusia berbasis sejumlah komponen dasar kualitas hidup.',
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: data.ipmFemale != null
                    ? NumberFormatUtils.formatDecimal(data.ipmFemale!)
                    : 'N/A',
                label: 'IPM Perempuan',
                color: Colors.pink,
                icon: Icons.female,
                description:
                    'Indeks Pembangunan Manusia (IPM) untuk penduduk perempuan mengukur capaian pembangunan manusia berbasis sejumlah komponen dasar kualitas hidup.',
                isLast: true,
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderComparison(ResponsiveSizing sizing, bool isSmallScreen) {
    final data = currentIPGData;

    return SectionPanel(
      isSmall: isSmallScreen,
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
                  'Perbandingan Komponen Gender',
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: bpsOrange,
                        size: 14,
                      ),
                      SizedBox(width: 4),
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
                value: '${data.uhhMaleFormatted} thn',
                label: 'UHH Laki-laki',
                color: Colors.indigo,
                icon: Icons.male,
                description:
                    'Umur Harapan Hidup (UHH) laki-laki menunjukkan rata-rata perkiraan banyak tahun yang dapat ditempuh oleh penduduk laki-laki sejak lahir.',
                isFirst: true,
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${data.uhhFemaleFormatted} thn',
                label: 'UHH Perempuan',
                color: Colors.pink,
                icon: Icons.female,
                description:
                    'Umur Harapan Hidup (UHH) perempuan menunjukkan rata-rata perkiraan banyak tahun yang dapat ditempuh oleh penduduk perempuan sejak lahir.',
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${data.hlsMaleFormatted} thn',
                label: 'HLS Laki-laki',
                color: Colors.indigo,
                icon: Icons.male,
                description:
                    'Harapan Lama Sekolah (HLS) laki-laki menunjukkan lamanya sekolah (dalam tahun) yang diharapkan akan dirasakan oleh anak laki-laki pada umur tertentu di masa mendatang.',
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${data.hlsFemaleFormatted} thn',
                label: 'HLS Perempuan',
                color: Colors.pink,
                icon: Icons.female,
                description:
                    'Harapan Lama Sekolah (HLS) perempuan menunjukkan lamanya sekolah (dalam tahun) yang diharapkan akan dirasakan oleh anak perempuan pada umur tertentu di masa mendatang.',
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${data.rlsMaleFormatted} thn',
                label: 'RLS Laki-laki',
                color: Colors.indigo,
                icon: Icons.male,
                description:
                    'Rata-rata Lama Sekolah (RLS) laki-laki menunjukkan jumlah tahun yang digunakan oleh penduduk laki-laki dalam menjalani pendidikan formal.',
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${data.rlsFemaleFormatted} thn',
                label: 'RLS Perempuan',
                color: Colors.pink,
                icon: Icons.female,
                description:
                    'Rata-rata Lama Sekolah (RLS) perempuan menunjukkan jumlah tahun yang digunakan oleh penduduk perempuan dalam menjalani pendidikan formal.',
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${data.pppMaleFormatted} rb',
                label: 'PPP Laki-laki',
                color: Colors.indigo,
                icon: Icons.male,
                description:
                    'Pengeluaran per Kapita Disesuaikan (PPP) laki-laki menunjukkan daya beli penduduk laki-laki terhadap sejumlah kebutuhan pokok yang dilihat dari rata-rata besarnya pengeluaran per kapita.',
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${data.pppFemaleFormatted} rb',
                label: 'PPP Perempuan',
                color: Colors.pink,
                icon: Icons.female,
                description:
                    'Pengeluaran per Kapita Disesuaikan (PPP) perempuan menunjukkan daya beli penduduk perempuan terhadap sejumlah kebutuhan pokok yang dilihat dari rata-rata besarnya pengeluaran per kapita.',
                isLast: true,
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIPGChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final List<FlSpot> ipgSpots = [];
    final List<String> yearLabels = [];
    final List<int> validYearIndices = [];

    for (int i = 0; i < availableYears.length; i++) {
      final year = availableYears[i];
      final yearData = ipgDataByYear[year];
      if (yearData?.ipg != null) {
        ipgSpots.add(FlSpot(i.toDouble(), yearData!.ipg!));
        yearLabels.add(year.toString());
        validYearIndices.add(i);
      }
    }

    final bool hasValidData = ipgSpots.isNotEmpty;

    double minY = 94;
    double maxY = 97;
    double yInterval = 0.5;

    if (hasValidData) {
      final double minIPG = ipgSpots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
      final double maxIPG = ipgSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

      minY = (minIPG - 0.5).floorToDouble();
      maxY = (maxIPG + 0.5).ceilToDouble();

      if (maxY - minY < 2.0) {
        final double mid = (minY + maxY) / 2;
        minY = mid - 1.0;
        maxY = mid + 1.0;
      }

      final double range = maxY - minY;
      yInterval = (range / 5 * 10).round() / 10;
      if (yInterval < 0.5) yInterval = 0.5;
    }

    return SectionPanel(
      isSmall: isSmallScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart_rounded,
                color: bpsPurple,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tren IPG (${availableYears.isNotEmpty ? availableYears.last : ""}-${availableYears.isNotEmpty ? availableYears.first : ""})',
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
                      'Indeks Pembangunan Gender per tahun',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: bpsTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          if (hasValidData)
            Wrap(
              spacing: isSmallScreen ? 8 : 12,
              runSpacing: isSmallScreen ? 8 : 12,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem('IPG', bpsPurple, isSmallScreen),
              ],
            ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          if (hasValidData)
            SizedBox(
              height: isSmallScreen ? 220 : 240,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
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
                    rightTitles:
                        const AxisTitles(),
                    topTitles:
                        const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < availableYears.length) {
                            return Text(
                              availableYears[index].toString(),
                              style: const TextStyle(
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
                            NumberFormatUtils.formatValue(value, decimalPlaces: 1),
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
                          'IPG',
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
                      spots: ipgSpots,
                      isCurved: true,
                      color: bpsPurple,
                      barWidth: 3,
                      dotData: FlDotData(
                        getDotPainter: (spot, percent, bar, index) {
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
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) => Colors.white,
                      tooltipRoundedRadius: 8,
                      tooltipBorder: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index >= 0 && index < validYearIndices.length) {
                            final year = int.parse(yearLabels[index]);
                            return LineTooltipItem(
                              '$year\nIPG: ${NumberFormatUtils.formatValue(spot.y, decimalPlaces: 2)}',
                              const TextStyle(
                                color: bpsPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            )
          else
            const Center(
              child: Text(
                'Data tidak tersedia',
                style: TextStyle(color: bpsTextSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIKGChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final List<BarChartGroupData> barGroups = [];
    final List<String> yearLabels = [];
    final List<int> validYearIndices = [];

    for (int i = 0; i < availableYears.length; i++) {
      final year = availableYears[i];
      final yearData = ipgDataByYear[year];
      if (yearData?.ikg != null) {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: yearData!.ikg!,
                color: bpsBlue,
                width: isSmallScreen ? 28 : 36,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 0.06,
                  color: bpsBlue.withOpacity(0.06),
                ),
              ),
            ],
          ),
        );
        yearLabels.add(year.toString());
        validYearIndices.add(i);
      }
    }

    final bool hasValidData = barGroups.isNotEmpty;

    return SectionPanel(
      isSmall: isSmallScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: bpsOrange,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tren IKG (${availableYears.isNotEmpty ? availableYears.last : ""}-${availableYears.isNotEmpty ? availableYears.first : ""})',
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
                      'Indeks Ketimpangan Gender — nilai lebih rendah = lebih baik',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: bpsOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          if (hasValidData)
            Wrap(
              spacing: isSmallScreen ? 8 : 12,
              runSpacing: isSmallScreen ? 8 : 12,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem('IKG', bpsBlue, isSmallScreen),
              ],
            ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          RepaintBoundary(
            child: SizedBox(
              height: isSmallScreen ? 220 : 240,
              child: hasValidData
                  ? BarChart(
                      BarChartData(
                        maxY: 0.06,
                        minY: 0,
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          horizontalInterval: 0.01,
                          getDrawingHorizontalLine: (value) => const FlLine(
                            color: bpsBorder,
                            strokeWidth: 0.5,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: isSmallScreen ? 42 : 48,
                              interval: 0.01,
                              getTitlesWidget: (value, meta) => Text(
                                NumberFormatUtils.formatDecimal(value,
                                    decimalPlaces: 3),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 10 : 12,
                                  color: bpsTextSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 &&
                                    index < validYearIndices.length) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        top: isSmallScreen ? 6 : 8),
                                    child: Text(
                                      yearLabels[index],
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
                          rightTitles: const AxisTitles(
                              ),
                          topTitles: const AxisTitles(
                              ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: barGroups,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipRoundedRadius: 8,
                            tooltipBorder:
                                BorderSide(color: Colors.grey[300]!),
                            tooltipPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            getTooltipColor: (group) => bpsCardBg,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final index = group.x;
                              if (index >= 0 &&
                                  index < validYearIndices.length) {
                                return BarTooltipItem(
                                  '${yearLabels[index]}\nIKG: ${NumberFormatUtils.formatDecimal(rod.toY, decimalPlaces: 3)}',
                                  const TextStyle(
                                    color: bpsBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'Data tidak tersedia',
                        style: TextStyle(color: bpsTextSecondary),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ResponsiveSizing sizing, bool isSmallScreen) {
    return SectionPanel(
      isSmall: isSmallScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: bpsOrange,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  'Tentang IPG & IKG',
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? sizing.groupTitleSize - 2
                        : sizing.groupTitleSize,
                    fontWeight: FontWeight.w800,
                    color: bpsTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'Indeks Pembangunan Gender (IPG) dan Indeks Ketimpangan Gender (IKG) merupakan indikator yang digunakan untuk mengukur kesetaraan gender dalam pembangunan manusia.',
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
                      Icons.balance_rounded,
                      color: bpsPurple,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    SizedBox(width: sizing.itemSpacing - 4),
                    Expanded(
                      child: Text(
                        'Indeks Pembangunan Gender (IPG)',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w700,
                          color: bpsPurple,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Mengukur pencapaian dalam dimensi dan variabel yang sama dengan IPM, dengan memperhatikan disparitas antara laki-laki dan perempuan.',
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
                      Icons.equalizer_rounded,
                      color: bpsBlue,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    SizedBox(width: sizing.itemSpacing - 4),
                    Expanded(
                      child: Text(
                        'Indeks Ketimpangan Gender (IKG)',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w700,
                          color: bpsBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Mengukur kerugian akibat ketidaksetaraan gender dari 3 dimensi: kesehatan reproduksi, pemberdayaan, dan pasar tenaga kerja.',
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
            'IPG mendekati 100 menunjukkan semakin kecil kesenjangan pembangunan antara laki-laki dan perempuan.',
            sizing,
          ),
          SizedBox(height: sizing.itemSpacing - 2),
          _buildBulletPoint(
            'IKG mendekati 0 menunjukkan semakin rendah ketimpangan gender di suatu wilayah.',
            sizing,
          ),
          SizedBox(height: sizing.itemSpacing - 2),
          _buildBulletPoint(
            'Komponen IPG meliputi Umur Harapan Hidup (UHH), Harapan Lama Sekolah (HLS), Rata-rata Lama Sekolah (RLS), dan Pengeluaran per Kapita (PPP).',
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
            color: bpsOrange,
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
              fontSize: isSmallScreen ? 12 : 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
}
