import 'package:lawang/number_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models/penduduk_age_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'responsive_sizing.dart';
import 'kesimpulan_widget.dart';
import 'services/github_data_service.dart';
import 'dart:async';
import 'app_theme.dart';

class SemarangData {
  final int year;
  final int? population;
  final double? area;
  final int? density;
  final int? districts;
  final int? villages;
  final int? malePopulation;
  final int? femalePopulation;
  final double? growthRate;

  late final String populationFormatted;
  late final String malePopulationFormatted;
  late final String femalePopulationFormatted;
  late final String densityFormatted;
  late final String populationInMillions;
  late final String malePopulationInMillions;
  late final String femalePopulationInMillions;
  late final double malePercentage;
  late final double femalePercentage;

  SemarangData({
    required this.year,
    this.population,
    this.area,
    this.density,
    this.districts,
    this.villages,
    this.malePopulation,
    this.femalePopulation,
    this.growthRate,
  }) {
    populationFormatted = population != null
        ? NumberFormatUtils.formatInteger(population!)
        : 'N/A';
    malePopulationFormatted = malePopulation != null
        ? NumberFormatUtils.formatInteger(malePopulation!)
        : 'N/A';
    femalePopulationFormatted = femalePopulation != null
        ? NumberFormatUtils.formatInteger(femalePopulation!)
        : 'N/A';
    densityFormatted =
        density != null ? NumberFormatUtils.formatInteger(density!) : 'N/A';
    populationInMillions = population != null
        ? NumberFormatUtils.formatDecimal(population! / 1000000.0,
            decimalPlaces: 3)
        : 'N/A';
    malePopulationInMillions = malePopulation != null
        ? NumberFormatUtils.formatDecimal(malePopulation! / 1000000.0,
            decimalPlaces: 3)
        : 'N/A';
    femalePopulationInMillions = femalePopulation != null
        ? NumberFormatUtils.formatDecimal(femalePopulation! / 1000000.0,
            decimalPlaces: 3)
        : 'N/A';
    malePercentage =
        (population != null && malePopulation != null && population! > 0)
            ? (malePopulation! / population! * 100)
            : 0.0;
    femalePercentage =
        (population != null && femalePopulation != null && population! > 0)
            ? (femalePopulation! / population! * 100)
            : 0.0;
  }
}

class DistrictDensity {
  final String name;
  final int density;
  final double population;

  late final String densityFormatted;
  late final String populationFormatted;

  DistrictDensity(
      {required this.name, required this.density, required this.population}) {
    densityFormatted = NumberFormatUtils.formatInteger(density);
    populationFormatted =
        NumberFormatUtils.formatDecimal(population);
  }
}

class PendudukScreen extends StatefulWidget {
  const PendudukScreen({super.key});

  @override
  State<PendudukScreen> createState() => _PendudukScreenState();
}

class _PendudukScreenState extends State<PendudukScreen>
    with AutomaticKeepAliveClientMixin {
  Map<int, SemarangData> semarangDataByYear = {};
  Map<int, List<DistrictDensity>> districtDensityByYear = {};
  List<int> availableYears = [];
  int selectedYear = 2025;
  bool isLoading = true;

  List<FlSpot> _cachedSpots = [];
  Map<int, List<PieChartSectionData>> _cachedPieDataByYear = {};
  Map<int, AgeDistribution> _ageDataByYear = {};
  List<Color> _districtColors = [];

  int? touchedPieIndex;
  bool showRealValues = false;
  String? selectedAgeGroup;
  String? selectedAgeValue;
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
    _initializeColors();
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

  void _initializeColors() {
    _districtColors = [
      bpsBlue,
      bpsOrange,
      bpsGreen,
      bpsRed,
      bpsBlue.withOpacity(0.7),
    ];
  }

  Future<void> _loadData() async {
    try {
      final githubData = GitHubDataService.getData('penduduk');
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString('penduduk_data');
      final String? savedAgeData = prefs.getString('age_distribution_data');
      final String? savedDistrictData = prefs.getString('district_density_data');

      Map<int, SemarangData> processedData;
      Map<int, Map<String, dynamic>> loadedAgeData;
      Map<int, List<DistrictDensity>> loadedDistrictData;

      // --- Penduduk data ---
      final pendudukSection = githubData?['penduduk'] as Map<String, dynamic>?;
      if (pendudukSection != null) {
        processedData = {};
        pendudukSection.forEach((key, value) {
          final int year = int.parse(key);
          final Map<String, dynamic> data = value as Map<String, dynamic>;
          processedData[year] = SemarangData(
            year: year,
            population: (data['population'] as num?)?.toInt(),
            malePopulation: (data['malePopulation'] as num?)?.toInt(),
            femalePopulation: (data['femalePopulation'] as num?)?.toInt(),
            area: (data['area'] as num?)?.toDouble(),
            density: (data['density'] as num?)?.toInt(),
            districts: (data['districts'] as num?)?.toInt(),
            villages: (data['villages'] as num?)?.toInt(),
            growthRate: (data['growthRate'] as num?)?.toDouble(),
          );
        });
        await prefs.setString('penduduk_data', json.encode(pendudukSection));
      } else if (savedData != null) {
        final decoded = json.decode(savedData) as Map<String, dynamic>;
        processedData = {};

        decoded.forEach((key, value) {
          final int year = int.parse(key);
          final data = value as Map<String, dynamic>;
          processedData[year] = SemarangData(
            year: year,
            population: (data['population'] as num?)?.toInt(),
            malePopulation: (data['malePopulation'] as num?)?.toInt(),
            femalePopulation: (data['femalePopulation'] as num?)?.toInt(),
            area: (data['area'] as num?)?.toDouble(),
            density: (data['density'] as num?)?.toInt(),
            districts: (data['districts'] as num?)?.toInt(),
            villages: (data['villages'] as num?)?.toInt(),
            growthRate: (data['growthRate'] as num?)?.toDouble(),
          );
        });
      } else {
        processedData = _getDefaultData();
      }

      final List<int> years = processedData.keys.toList()
        ..sort((a, b) => a.compareTo(b));
      _cachedSpots = [];
      for (int i = 0; i < years.length; i++) {
        final double growthRate = processedData[years[i]]?.growthRate ?? 0.0;
        _cachedSpots.add(FlSpot(i.toDouble(), growthRate / 100));
      }

      // --- Age distribution data ---
      final ageSection = githubData?['ageDistribution'] as Map<String, dynamic>?;
      if (ageSection != null) {
        loadedAgeData = {};
        ageSection.forEach((key, value) {
          loadedAgeData[int.parse(key)] =
              Map<String, dynamic>.from(value as Map);
        });
        await prefs.setString('age_distribution_data', json.encode(ageSection));
      } else if (savedAgeData != null) {
        final decoded = json.decode(savedAgeData) as Map<String, dynamic>;
        loadedAgeData = {};
        decoded.forEach((key, value) {
          loadedAgeData[int.parse(key)] =
              Map<String, dynamic>.from(value as Map);
        });
      } else {
        loadedAgeData = _getDefaultAgeData();
      }

      _ageDataByYear = loadedAgeData
          .map((year, ageData) => MapEntry(year, AgeDistribution.fromRaw(ageData)));

      _cachedPieDataByYear = {};
      for (final int year in _ageDataByYear.keys) {
        final ageData = _ageDataByYear[year]!;
        final usiaMudaPct = ageData.usiaMuda.percentage;
        final usiaProduktifPct = ageData.usiaProduktif.percentage;
        final usiaTuaPct = ageData.usiaTua.percentage;
        _cachedPieDataByYear[year] = [
          PieChartSectionData(
            color: bpsBlue,
            value: usiaMudaPct,
            title: '$usiaMudaPct%',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: bpsGreen,
            value: usiaProduktifPct,
            title: '$usiaProduktifPct%',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: bpsOrange,
            value: usiaTuaPct,
            title: '$usiaTuaPct%',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ];
      }

      // --- District density data ---
      final districtSection = githubData?['districtDensity'] as Map<String, dynamic>?;
      if (districtSection != null) {
        loadedDistrictData = {};
        districtSection.forEach((key, value) {
          final int year = int.parse(key);
          final List<dynamic> districts = value as List<dynamic>;
          loadedDistrictData[year] = districts.map((d) {
            final Map<String, dynamic> district = d as Map<String, dynamic>;
            return DistrictDensity(
              name: district['name'] as String,
              density: (district['density'] as num).toInt(),
              population: (district['population'] as num).toDouble(),
            );
          }).toList();
        });
        await prefs.setString('district_density_data', json.encode(districtSection));
      } else if (savedDistrictData != null) {
        final decoded = json.decode(savedDistrictData) as Map<String, dynamic>;
        loadedDistrictData = {};
        decoded.forEach((key, value) {
          final int year = int.parse(key);
          final List<dynamic> districts = value as List<dynamic>;
          loadedDistrictData[year] = districts.map((d) {
            final district = d as Map<String, dynamic>;
            return DistrictDensity(
              name: district['name'] as String,
              density: (district['density'] as num).toInt(),
              population: (district['population'] as num).toDouble(),
            );
          }).toList();
        });
      } else {
        loadedDistrictData = _getDefaultDistrictData();
      }

      if (mounted) {
        setState(() {
          semarangDataByYear = processedData;
          districtDensityByYear = loadedDistrictData;
          availableYears = years;
          selectedYear = years.isNotEmpty ? years.last : 2024;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      _loadDefaultData();
    }
  }

  Map<int, SemarangData> _getDefaultData() {
    return {
      2020: SemarangData(
          year: 2020,
          population: 1653524,
          malePopulation: 818441,
          femalePopulation: 835083,
          area: 373.7,
          density: 4425,
          districts: 16,
          villages: 177,
          growthRate: 0),
      2021: SemarangData(
          year: 2021,
          population: 1656564,
          malePopulation: 819785,
          femalePopulation: 836779,
          area: 374,
          density: 4433,
          districts: 16,
          villages: 177,
          growthRate: 0.18),
      2022: SemarangData(
          year: 2022,
          population: 1659975,
          malePopulation: 821305,
          femalePopulation: 838670,
          area: 374,
          density: 4442,
          districts: 16,
          villages: 177,
          growthRate: 0.21),
      2023: SemarangData(
          year: 2023,
          population: 1694743,
          malePopulation: 838437,
          femalePopulation: 856306,
          area: 374,
          density: 4535,
          districts: 16,
          villages: 177,
          growthRate: 2.09),
      2024: SemarangData(
          year: 2024,
          population: 1708833,
          malePopulation: 845177,
          femalePopulation: 863656,
          area: 374,
          density: 4573,
          districts: 16,
          villages: 177,
          growthRate: 0.83),
      2025: SemarangData(
          year: 2025,
          population: 1722421,
          malePopulation: 851637,
          femalePopulation: 870784,
          area: 373.7,
          density: 4609,
          districts: 16,
          villages: 177,
          growthRate: 0.80),
    };
  }

  Map<int, Map<String, dynamic>> _getDefaultAgeData() {
    return {
      2020: {
        'usiaMuda': 367018,
        'usiaMudaPercentage': 22.20,
        'usiaProduktif': 1182010,
        'usiaProduktifPercentage': 71.48,
        'usiaTua': 104496,
        'usiaTuaPercentage': 6.32
      },
      2021: {
        'usiaMuda': 363757,
        'usiaMudaPercentage': 21.96,
        'usiaProduktif': 1182986,
        'usiaProduktifPercentage': 71.41,
        'usiaTua': 109821,
        'usiaTuaPercentage': 6.63
      },
      2022: {
        'usiaMuda': 360777,
        'usiaMudaPercentage': 21.73,
        'usiaProduktif': 1183941,
        'usiaProduktifPercentage': 71.32,
        'usiaTua': 115257,
        'usiaTuaPercentage': 6.94
      },
      2023: {
        'usiaMuda': 359130,
        'usiaMudaPercentage': 21.19,
        'usiaProduktif': 1207250,
        'usiaProduktifPercentage': 71.23,
        'usiaTua': 128400,
        'usiaTuaPercentage': 7.58
      },
      2024: {
        'usiaMuda': 356758,
        'usiaMudaPercentage': 20.88,
        'usiaProduktif': 1214892,
        'usiaProduktifPercentage': 71.09,
        'usiaTua': 137183,
        'usiaTuaPercentage': 8.03
      },
      2025: {
        'usiaMuda': 354365,
        'usiaMudaPercentage': 20.57,
        'usiaProduktif': 1221858,
        'usiaProduktifPercentage': 70.94,
        'usiaTua': 146198,
        'usiaTuaPercentage': 8.49
      },
    };
  }

  Map<int, List<DistrictDensity>> _getDefaultDistrictData() {
    return {
      2020: [
        DistrictDensity(name: "Pedurungan", density: 9322, population: 193.151),
        DistrictDensity(name: "Tembalang", density: 4291, population: 189.680),
        DistrictDensity(
            name: "Semarang Barat", density: 6848, population: 148.879),
        DistrictDensity(name: "Banyumanik", density: 5530, population: 142.076),
        DistrictDensity(name: "Ngaliyan", density: 3731, population: 141.727)
      ],
      2021: [
        DistrictDensity(name: "Pedurungan", density: 9321, population: 193.128),
        DistrictDensity(name: "Tembalang", density: 4334, population: 191.560),
        DistrictDensity(
            name: "Semarang Barat", density: 6802, population: 147.885),
        DistrictDensity(name: "Ngaliyan", density: 3741, population: 142.131),
        DistrictDensity(name: "Banyumanik", density: 5515, population: 141.689)
      ],
      2022: [
        DistrictDensity(name: "Tembalang", density: 4377, population: 193.480),
        DistrictDensity(name: "Pedurungan", density: 9321, population: 193.125),
        DistrictDensity(
            name: "Semarang Barat", density: 6758, population: 146.915),
        DistrictDensity(name: "Ngaliyan", density: 3752, population: 142.553),
        DistrictDensity(name: "Banyumanik", density: 5501, population: 141.319)
      ],
      2023: [
        DistrictDensity(name: "Tembalang", density: 4499, population: 198.862),
        DistrictDensity(name: "Pedurungan", density: 9485, population: 196.526),
        DistrictDensity(
            name: "Semarang Barat", density: 6869, population: 149.326),
        DistrictDensity(name: "Ngaliyan", density: 3830, population: 145.495),
        DistrictDensity(name: "Banyumanik", density: 5583, population: 143.433)
      ],
      2024: [
        DistrictDensity(name: "Tembalang", density: 4566, population: 201.821),
        DistrictDensity(name: "Pedurungan", density: 9530, population: 197.468),
        DistrictDensity(
            name: "Semarang Barat", density: 6869, population: 149.327),
        DistrictDensity(name: "Ngaliyan", density: 3860, population: 146.628),
        DistrictDensity(name: "Banyumanik", density: 5595, population: 143.746)
      ],
      2025: [
        DistrictDensity(name: "Tembalang", density: 4635, population: 204.865),
        DistrictDensity(name: "Pedurungan", density: 9578, population: 198.452),
        DistrictDensity(
            name: "Semarang Barat", density: 6870, population: 149.357),
        DistrictDensity(name: "Ngaliyan", density: 3890, population: 147.797),
        DistrictDensity(name: "Banyumanik", density: 5609, population: 144.087)
      ],
    };
  }

  void _loadDefaultData() {
    final processedData = _getDefaultData();
    _cachedSpots = [
      const FlSpot(0, 0),
      const FlSpot(1, 0.0018),
      const FlSpot(2, 0.0021),
      const FlSpot(3, 0.0209),
      const FlSpot(4, 0.0083),
      const FlSpot(5, 0.0080)
    ];

    _ageDataByYear = {
      2020: const AgeDistribution(
          usiaMuda: AgeGroup(total: 367018, percentage: 22.20),
          usiaProduktif: AgeGroup(total: 1182010, percentage: 71.48),
          usiaTua: AgeGroup(total: 104496, percentage: 6.32)),
      2021: const AgeDistribution(
          usiaMuda: AgeGroup(total: 363757, percentage: 21.96),
          usiaProduktif: AgeGroup(total: 1182986, percentage: 71.41),
          usiaTua: AgeGroup(total: 109821, percentage: 6.63)),
      2012: const AgeDistribution(
          usiaMuda: AgeGroup(total: 357600, percentage: 22.70),
          usiaProduktif: AgeGroup(total: 1136500, percentage: 72.17),
          usiaTua: AgeGroup(total: 80930, percentage: 5.14)),
      2013: const AgeDistribution(
          usiaMuda: AgeGroup(total: 352700, percentage: 22.25),
          usiaProduktif: AgeGroup(total: 1146200, percentage: 72.33),
          usiaTua: AgeGroup(total: 85749, percentage: 5.41)),
      2014: const AgeDistribution(
          usiaMuda: AgeGroup(total: 347800, percentage: 21.80),
          usiaProduktif: AgeGroup(total: 1155900, percentage: 72.50),
          usiaTua: AgeGroup(total: 90632, percentage: 5.68)),
      2015: const AgeDistribution(
          usiaMuda: AgeGroup(total: 342900, percentage: 21.38),
          usiaProduktif: AgeGroup(total: 1165600, percentage: 72.66),
          usiaTua: AgeGroup(total: 95581, percentage: 5.95)),
      2016: const AgeDistribution(
          usiaMuda: AgeGroup(total: 338000, percentage: 20.94),
          usiaProduktif: AgeGroup(total: 1175300, percentage: 72.82),
          usiaTua: AgeGroup(total: 100596, percentage: 6.23)),
      2017: const AgeDistribution(
          usiaMuda: AgeGroup(total: 333100, percentage: 20.51),
          usiaProduktif: AgeGroup(total: 1185000, percentage: 72.98),
          usiaTua: AgeGroup(total: 105677, percentage: 6.51)),
      2018: const AgeDistribution(
          usiaMuda: AgeGroup(total: 328200, percentage: 20.09),
          usiaProduktif: AgeGroup(total: 1194700, percentage: 73.13),
          usiaTua: AgeGroup(total: 110825, percentage: 6.78)),
      2019: const AgeDistribution(
          usiaMuda: AgeGroup(total: 323300, percentage: 19.67),
          usiaProduktif: AgeGroup(total: 1204400, percentage: 73.27),
          usiaTua: AgeGroup(total: 116041, percentage: 7.06)),
      2020: const AgeDistribution(
          usiaMuda: AgeGroup(total: 318400, percentage: 19.25),
          usiaProduktif: AgeGroup(total: 1214100, percentage: 73.42),
          usiaTua: AgeGroup(total: 121024, percentage: 7.32)),
      2021: const AgeDistribution(
          usiaMuda: AgeGroup(total: 363757, percentage: 21.96),
          usiaProduktif: AgeGroup(total: 1182986, percentage: 71.41),
          usiaTua: AgeGroup(total: 109821, percentage: 6.63)),
      2022: const AgeDistribution(
          usiaMuda: AgeGroup(total: 360777, percentage: 21.73),
          usiaProduktif: AgeGroup(total: 1183941, percentage: 71.32),
          usiaTua: AgeGroup(total: 115257, percentage: 6.94)),
      2023: const AgeDistribution(
          usiaMuda: AgeGroup(total: 359130, percentage: 21.19),
          usiaProduktif: AgeGroup(total: 1207250, percentage: 71.23),
          usiaTua: AgeGroup(total: 128400, percentage: 7.58)),
      2024: const AgeDistribution(
          usiaMuda: AgeGroup(total: 356758, percentage: 20.88),
          usiaProduktif: AgeGroup(total: 1214892, percentage: 71.09),
          usiaTua: AgeGroup(total: 137183, percentage: 8.03)),
      2025: const AgeDistribution(
          usiaMuda: AgeGroup(total: 354365, percentage: 20.57),
          usiaProduktif: AgeGroup(total: 1221858, percentage: 70.94),
          usiaTua: AgeGroup(total: 146198, percentage: 8.49)),
    };

    _cachedPieDataByYear = {};
    for (final int year in _ageDataByYear.keys) {
      final ageData = _ageDataByYear[year]!;
      _cachedPieDataByYear[year] = [
        PieChartSectionData(
            color: bpsBlue,
            value: ageData.usiaMuda.percentage,
            title: '${ageData.usiaMuda.percentage}%',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        PieChartSectionData(
            color: bpsGreen,
            value: ageData.usiaProduktif.percentage,
            title: '${ageData.usiaProduktif.percentage}%',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        PieChartSectionData(
            color: bpsOrange,
            value: ageData.usiaTua.percentage,
            title: '${ageData.usiaTua.percentage}%',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ];
    }

    if (mounted) {
      setState(() {
        semarangDataByYear = processedData;
        districtDensityByYear = _getDefaultDistrictData();
        availableYears = [2020, 2021, 2022, 2023, 2024, 2025];
        selectedYear = 2025;
        isLoading = false;
      });
    }
  }

  SemarangData get currentSemarangData {
    return semarangDataByYear[selectedYear] ??
        semarangDataByYear[availableYears.first]!;
  }

  List<DistrictDensity> get currentDistrictDensity {
    return districtDensityByYear[selectedYear] ?? [];
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
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: bpsGreen),
                    SizedBox(height: 16),
                    Text('Memuat data...',
                        style: TextStyle(color: bpsTextSecondary)),
                  ],
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
                      _buildPopulationStats(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildPopulationChart(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildAgeDistributionChart(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildAdministrativeData(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildDistrictDensitySection(sizing, isSmallScreen),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bpsGreen,
        boxShadow: [
          BoxShadow(
              color: bpsGreen.withOpacity(0.2),
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
                child: Text('Data Penduduk',
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
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: bpsGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: bpsGreen,
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
                  color: isSelected ? bpsGreen : bpsBackground,
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
                          color: isSelected ? bpsGreen : bpsBorder,
                          width: isSelected ? 2 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: bpsGreen.withOpacity(0.3),
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

  Widget _buildPopulationStats(ResponsiveSizing sizing, bool isSmallScreen) {
    final data = currentSemarangData;
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
                  color: bpsGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: bpsGreen,
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  'Indikator Utama Penduduk',
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
                    color: bpsGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: bpsGreen,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Tap untuk detail',
                        style: TextStyle(
                          fontSize: 12,
                          color: bpsGreen,
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
                value: '${data.populationInMillions} Jt',
                label: 'Total Penduduk',
                color: bpsGreen,
                icon: Icons.groups,
                description:
                    'Total jumlah penduduk Kota Semarang berdasarkan data BPS tahun $selectedYear.',
                isFirst: true,
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: '${data.densityFormatted}/km²',
                label: 'Kepadatan',
                color: bpsOrange,
                icon: Icons.location_city,
                description:
                    'Kepadatan penduduk per kilometer persegi menunjukkan tingkat konsentrasi penduduk di wilayah Kota Semarang.',
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: data.malePopulationFormatted,
                label: 'Laki-laki',
                color: Colors.indigo,
                icon: Icons.male,
                description:
                    'Jumlah penduduk laki-laki Kota Semarang (${NumberFormatUtils.formatPercentage(data.malePercentage)} dari total penduduk).',
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: data.femalePopulationFormatted,
                label: 'Perempuan',
                color: Colors.pink,
                icon: Icons.female,
                description:
                    'Jumlah penduduk perempuan Kota Semarang (${NumberFormatUtils.formatPercentage(data.femalePercentage)} dari total penduduk).',
                isSmallScreen: isSmallScreen,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: data.growthRate != null
                    ? NumberFormatUtils.formatPercentage(data.growthRate!)
                    : 'N/A',
                label: 'Laju Pertumbuhan',
                color: bpsGreen,
                icon: Icons.trending_up,
                description:
                    'Laju pertumbuhan penduduk Kota Semarang per tahun.',
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

  Widget _buildPopulationChart(ResponsiveSizing sizing, bool isSmallScreen) {
    // Prepare data for LineChart - years from oldest (left) to newest (right)
    final chartYears = [2020, 2021, 2022, 2023, 2024, 2025];
    final spots = <FlSpot>[];
    final yearLabels = <String>[];

    for (int i = 0; i < chartYears.length; i++) {
      final year = chartYears[i];
      final data = semarangDataByYear[year];
      if (data != null && data.growthRate != null) {
        spots.add(FlSpot(i.toDouble(), data.growthRate!));
        yearLabels.add(year.toString());
      }
    }

    // Calculate dynamic Y-axis range based on data
    double minY = 0;
    double maxY = 2.5;
    if (spots.isNotEmpty) {
      final growthRates = spots.map((s) => s.y).toList();
      final dataMin = growthRates.reduce((a, b) => a < b ? a : b);
      final dataMax = growthRates.reduce((a, b) => a > b ? a : b);
      // Add padding to min/max for better visualization
      minY = (dataMin * 0.8).clamp(0, double.infinity);
      maxY = dataMax * 1.2;
      // Ensure minimum range for better spacing
      if (maxY - minY < 1.0) {
        maxY = minY + 1.0;
      }
    }

    // Calculate interval based on range
    final yRange = maxY - minY;
    final interval = yRange <= 1.0 ? 0.2 : (yRange <= 2.0 ? 0.5 : 1.0);

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
                  child: Icon(Icons.show_chart,
                      color: bpsGreen, size: isSmallScreen ? 16 : 18)),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Laju Pertumbuhan Penduduk (%)',
                        style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w700,
                            color: bpsTextPrimary)),
                    Text('Kota Semarang',
                        style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 12,
                            color: bpsTextSecondary))
                  ])),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: SizedBox(
              height: isSmallScreen ? 200 : 240,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      
                    ),
                    topTitles: const AxisTitles(
                      
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
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                yearLabels[index],
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 10 : 11,
                                  fontWeight: FontWeight.bold,
                                  color: bpsGreen,
                                ),
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
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              '${NumberFormatUtils.formatValue(value, decimalPlaces: 1)}%',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 9 : 10,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: bpsGreen,
                      barWidth: 3,
                      dotData: FlDotData(
                        getDotPainter: (spot, percent, bar, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: bpsGreen,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: bpsGreen.withOpacity(0.1),
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
                          final year = yearLabels[index];
                          return LineTooltipItem(
                            '$year\n${NumberFormatUtils.formatValue(spot.y, decimalPlaces: 2)}%',
                            const TextStyle(
                              color: bpsGreen,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeDistributionChart(
      ResponsiveSizing sizing, bool isSmallScreen) {
    if (!_ageDataByYear.containsKey(selectedYear)) {
      return const SizedBox.shrink();
    }

    final ageData = _ageDataByYear[selectedYear]!;
    final sections = [
      _buildAgePieSection('usiaMuda', bpsBlue, 0, isSmallScreen),
      _buildAgePieSection('usiaProduktif', bpsGreen, 1, isSmallScreen),
      _buildAgePieSection('usiaTua', bpsOrange, 2, isSmallScreen),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                      color: bpsOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.pie_chart,
                      color: bpsOrange, size: isSmallScreen ? 16 : 18)),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Default state (visible when no age group selected)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: selectedAgeGroup == null ? 1.0 : 0.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Distribusi Umur Penduduk',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w700,
                              color: bpsTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Persentase Penduduk per Kelompok Umur',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: bpsTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Selected state (visible when age group selected)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: selectedAgeGroup != null ? 1.0 : 0.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedAgeGroup != null
                                ? '$selectedAgeGroup - $selectedAgeValue'
                                : '',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w700,
                              color: selectedAgeGroup != null
                                  ? _getAgeGroupColor(selectedAgeGroup!)
                                  : bpsTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Jumlah penduduk',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: bpsTextSecondary,
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
          SizedBox(height: isSmallScreen ? 16 : 20),
          SizedBox(
            height: 180,
            child: Center(
              child: SizedBox(
                height: 160,
                width: 160,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: sections,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedPieIndex = null;
                            showRealValues = false;
                            selectedAgeGroup = null;
                            selectedAgeValue = null;
                            return;
                          }
                          touchedPieIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                          showRealValues = true;
                          // Update header with selected age group info
                          final ageIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                          final ageKeys = [
                            'usiaMuda',
                            'usiaProduktif',
                            'usiaTua'
                          ];
                          final ageLabels = [
                            'Usia Muda (0-14)',
                            'Usia Produktif (15-64)',
                            'Usia Tua (65+)'
                          ];
                          if (ageIndex >= 0 && ageIndex < ageKeys.length) {
                            final ageKey = ageKeys[ageIndex];
                            final ageLabel = ageLabels[ageIndex];
                            final total = ageData.byKey(ageKey).total;
                            selectedAgeGroup = ageLabel;
                            selectedAgeValue = _formatCompactNumber(total);
                          } else {
                            selectedAgeGroup = null;
                            selectedAgeValue = null;
                          }
                        });
                      },
                      enabled: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildAgeLegendItem('Usia Muda (0-14)', bpsBlue,
                  ageData.usiaMuda.total, isSmallScreen),
              const SizedBox(height: 8),
              _buildAgeLegendItem('Usia Produktif (15-64)', bpsGreen,
                  ageData.usiaProduktif.total, isSmallScreen),
              const SizedBox(height: 8),
              _buildAgeLegendItem('Usia Tua (65+)', bpsOrange,
                  ageData.usiaTua.total, isSmallScreen),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _buildAgePieSection(
      String ageKey, Color color, int index, bool isSmallScreen) {
    final ageData = _ageDataByYear[selectedYear]!;
    final double percentage = ageData.byKey(ageKey).percentage;
    final total = ageData.byKey(ageKey).total;
    final isTouched = index == touchedPieIndex;
    final radius = isTouched ? (isSmallScreen ? 70.0 : 75.0) : 60.0;
    final fontSize = isTouched
        ? (isSmallScreen ? 11.0 : 12.0)
        : (isSmallScreen ? 10.0 : 11.0);

    final displayTitle = (showRealValues && isTouched)
        ? _formatCompactNumber(total)
        : NumberFormatUtils.formatPercentage(percentage);

    return PieChartSectionData(
      color: color,
      value: percentage,
      title: displayTitle,
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  String _formatCompactNumber(int number) {
    return NumberFormatUtils.formatCompact(number);
  }

  Widget _buildAgeLegendItem(
      String title, Color color, int value, bool isSmallScreen) {
    return Row(
      children: [
        Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title,
              style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14, color: bpsTextPrimary)),
        ),
        Text(
          _formatCompactNumber(value),
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            color: bpsTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getAgeGroupColor(String ageGroup) {
    if (ageGroup.contains('Muda')) {
      return bpsBlue;
    } else if (ageGroup.contains('Produktif')) {
      return bpsGreen;
    } else if (ageGroup.contains('Tua')) {
      return bpsOrange;
    }
    return bpsTextPrimary;
  }

  Widget _buildAdministrativeData(ResponsiveSizing sizing, bool isSmallScreen) {
    final data = currentSemarangData;
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
                  child: Icon(Icons.account_balance,
                      color: bpsGreen, size: isSmallScreen ? 16 : 18)),
              SizedBox(width: sizing.itemSpacing),
              Text('Data Administrasi',
                  style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w700,
                      color: bpsTextPrimary)),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Row(
            children: [
              Expanded(
                  child: _buildAdminCard('${data.districts}', 'Kecamatan',
                      Icons.account_balance, bpsGreen, isSmallScreen)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildAdminCard('${data.villages}', 'Kelurahan',
                      Icons.location_on, bpsGreen, isSmallScreen)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildAdminCard(
                      data.area != null
                          ? NumberFormatUtils.formatDecimal(data.area!,
                              decimalPlaces: 1)
                          : 'N/A',
                      'km² Luas',
                      Icons.square_foot,
                      bpsOrange,
                      isSmallScreen)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(String value, String label, IconData icon, Color color,
      bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 11, color: bpsTextSecondary)),
        ],
      ),
    );
  }

  Widget _buildDistrictDensitySection(
      ResponsiveSizing sizing, bool isSmallScreen) {
    final districts = currentDistrictDensity;
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
                      color: bpsRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.leaderboard,
                      color: bpsRed, size: isSmallScreen ? 16 : 18)),
              SizedBox(width: sizing.itemSpacing),
              Text('5 Kecamatan Terpadat',
                  style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w700,
                      color: bpsTextPrimary)),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          if (districts.isNotEmpty) ...[
            ...districts.asMap().entries.map((entry) {
              final index = entry.key;
              final district = entry.value;
              final ranking = index + 1;
              final circleColor = _districtColors[index];
              final totalCityPopulation =
                  currentSemarangData.population ?? 1708833;
              final districtPopulationCount =
                  (district.population * 1000).toInt();
              final percentage =
                  districtPopulationCount / totalCityPopulation * 100;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: circleColor, shape: BoxShape.circle),
                      child: Center(
                          child: Text('$ranking',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(district.name,
                              style: TextStyle(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  fontWeight: FontWeight.w600,
                                  color: bpsTextPrimary)),
                          Text('${district.populationFormatted} Ribu',
                              style: TextStyle(
                                  fontSize: isSmallScreen ? 10 : 11,
                                  color: bpsTextSecondary)),
                        ],
                      ),
                    ),
                    Text(NumberFormatUtils.formatPercentage(percentage),
                        style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: bpsTextPrimary)),
                  ],
                ),
              );
            }),
          ] else ...[
            Center(
                child: Text('Data tidak tersedia',
                    style: TextStyle(
                        color: bpsTextSecondary,
                        fontSize: isSmallScreen ? 12 : 14))),
          ],
        ],
      ),
    );
  }

  Widget _buildKesimpulanCard(ResponsiveSizing sizing, bool isSmallScreen) {
    if (semarangDataByYear.isEmpty || availableYears.length < 2) {
      return const SizedBox.shrink();
    }

    final sortedYears = availableYears..sort((a, b) => a.compareTo(b));
    final latestYear = sortedYears.last;
    final firstYear = sortedYears.first;
    final latestData = semarangDataByYear[latestYear];
    final firstData = semarangDataByYear[firstYear];

    if (latestData == null || firstData == null) {
      return const SizedBox.shrink();
    }

    final latestPopulation = latestData.population ?? 0;
    final firstPopulation = firstData.population ?? 0;
    final growthRate = latestData.growthRate ?? 0.0;
    final density = (latestData.density ?? 0).toDouble();

    final conclusionData = KesimpulanGenerator.generatePendudukConclusion(
      latestYear: latestYear,
      firstYear: firstYear,
      latestPopulation: latestPopulation,
      firstPopulation: firstPopulation,
      growthRate: growthRate,
      density: density,
    );

    return KesimpulanWidget(
      title: 'Penduduk Kota Semarang',
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
