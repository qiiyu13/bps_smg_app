import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'responsive_sizing.dart';
import 'number_format_utils.dart';
import 'kesimpulan_widget.dart';

// BPS Color Palette (matching kemiskinana_screen.dart)
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
const Color _bpsPurple = Color(0xFF9B59B6);
const Color _bpsTeal = Color(0xFF1ABC9C);

class InflasiScreen extends StatefulWidget {
  const InflasiScreen({super.key});

  @override
  State<InflasiScreen> createState() => _InflasiScreenState();
}

class _InflasiScreenState extends State<InflasiScreen>
    with AutomaticKeepAliveClientMixin {
  int selectedYear = 2023;
  int? selectedMonth;

  @override
  bool get wantKeepAlive => true;

  final List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final List<String> fullMonths = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final Map<int, List<double>> monthlyInflationData = {
    2019: [
      0.32,
      0.01,
      0.11,
      -0.10,
      0.48,
      0.55,
      0.31,
      -0.02,
      -0.27,
      0.02,
      -0.16,
      0.30
    ],
    2020: [
      0.40,
      0.28,
      0.10,
      -0.10,
      0.07,
      0.18,
      -0.05,
      -0.05,
      -0.05,
      -0.09,
      0.28,
      0.45
    ],
    2021: [
      0.26,
      0.10,
      0.08,
      -0.13,
      0.32,
      0.33,
      0.21,
      0.03,
      0.12,
      0.12,
      0.37,
      0.57
    ],
    2022: [
      0.56,
      0.64,
      0.66,
      0.95,
      0.40,
      0.56,
      0.64,
      0.21,
      1.17,
      0.12,
      0.03,
      0.66
    ],
    2023: [
      0.34,
      -0.02,
      0.12,
      -0.07,
      0.09,
      0.59,
      0.21,
      0.18,
      -0.04,
      -0.06,
      0.08,
      0.15
    ],
  };

  final Map<int, double> yearlyInflation = {
    2019: 2.72,
    2020: 1.68,
    2021: 1.87,
    2022: 4.21,
    2023: 2.61,
  };

  final Map<int, double> coreInflation = {
    2019: 3.04,
    2020: 1.59,
    2021: 1.64,
    2022: 3.04,
    2023: 1.93,
  };

  final Map<int, double> ihkData = {
    2019: 106.02,
    2020: 107.80,
    2021: 109.82,
    2022: 114.44,
    2023: 113.59,
  };

  final Map<String, Map<String, double>> inflationComponents = {
    'Makanan, Minuman & Tembakau': {
      '2019': 4.55,
      '2020': 3.28,
      '2021': 2.84,
      '2022': 5.33,
      '2023': 4.12
    },
    'Pakaian & Alas Kaki': {
      '2019': 0.84,
      '2020': 0.45,
      '2021': 0.67,
      '2022': 1.23,
      '2023': 0.92
    },
    'Perumahan & Fasilitas': {
      '2019': 1.69,
      '2020': 1.45,
      '2021': 1.52,
      '2022': 2.15,
      '2023': 1.78
    },
    'Perawatan Kesehatan': {
      '2019': 2.43,
      '2020': 2.15,
      '2021': 2.67,
      '2022': 3.45,
      '2023': 2.89
    },
    'Transportasi': {
      '2019': 1.24,
      '2020': 0.89,
      '2021': 1.45,
      '2022': 4.67,
      '2023': 2.34
    },
    'Komunikasi & Keuangan': {
      '2019': 1.02,
      '2020': 0.78,
      '2021': 0.95,
      '2022': 1.34,
      '2023': 1.12
    },
    'Rekreasi & Olahraga': {
      '2019': 2.18,
      '2020': 1.67,
      '2021': 2.05,
      '2022': 2.89,
      '2023': 2.45
    },
  };

  List<int> get availableYears => monthlyInflationData.keys.toList()..sort((a, b) => b.compareTo(a));

  List<double> get filteredMonthlyData {
    if (selectedMonth == null) {
      return monthlyInflationData[selectedYear] ?? [];
    } else {
      return [monthlyInflationData[selectedYear]![selectedMonth!]];
    }
  }

  double get currentInflationValue {
    if (selectedMonth == null) {
      return monthlyInflationData[selectedYear]?.last ?? 0.0;
    } else {
      return monthlyInflationData[selectedYear]?[selectedMonth!] ?? 0.0;
    }
  }

  String get currentMonthLabel {
    if (selectedMonth == null) {
      return 'Desember';
    } else {
      return fullMonths[selectedMonth!];
    }
  }

  Color get inflationColor {
    final value = currentInflationValue;
    if (value > 0.5) return _bpsRed;
    if (value > 0.2) return _bpsOrange;
    if (value >= 0) return _bpsGreen;
    return _bpsBlue;
  }

  @override
  Widget build(BuildContext context) {
    final sizing = ResponsiveSizing(context);
    final isSmallScreen = sizing.isVerySmall || sizing.isSmall;

    if (availableYears.isEmpty) {
      return Scaffold(
        backgroundColor: _bpsBackground,
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
                        'Data inflasi belum tersedia',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: sizing.categoryLabelFontSize,
                          color: _bpsTextSecondary,
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
      backgroundColor: _bpsBackground,
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
                      _buildMonthSelector(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildMainIndicators(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildInflationChart(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildMonthlyInflationChart(sizing, isSmallScreen),
                      SizedBox(height: sizing.sectionSpacing),
                      _buildInflationComponents(sizing, isSmallScreen),
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
                child: Text(
                  'Data Inflasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen
                        ? sizing.headerTitleSize + 4
                        : sizing.headerTitleSize + 8,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.analytics_rounded,
                color: Colors.white,
                size: isSmallScreen ? 20 : 24,
              ),
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
                color: _bpsBlue,
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
            children: availableYears.map((year) {
              final isSelected = year == selectedYear;
              return Material(
                color: isSelected ? _bpsBlue : _bpsBackground,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedYear = year;
                      selectedMonth = null;
                    });
                  },
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

  Widget _buildMonthSelector(ResponsiveSizing sizing, bool isSmallScreen) {
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
                Icons.calendar_month_rounded,
                color: _bpsOrange,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Text(
                'Pilih Bulan',
                style: TextStyle(
                  fontSize: isSmallScreen
                      ? sizing.groupTitleSize - 2
                      : sizing.groupTitleSize,
                  fontWeight: FontWeight.w700,
                  color: _bpsTextPrimary,
                ),
              ),
              const Spacer(),
              if (selectedMonth != null)
                Material(
                  color: _bpsOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => setState(() => selectedMonth = null),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: sizing.itemSpacing,
                        vertical: 4,
                      ),
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: sizing.bottomNavLabelSize,
                          color: _bpsOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(months.length, (index) {
                final isSelected = selectedMonth == index;
                return Padding(
                  padding: EdgeInsets.only(right: sizing.itemSpacing),
                  child: Material(
                    color: isSelected ? _bpsOrange : _bpsBackground,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedMonth = isSelected ? null : index;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: isSmallScreen ? 50 : 60,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 10 : 12,
                          vertical: isSmallScreen ? 8 : 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? _bpsOrange : _bpsBorder,
                            width: isSelected ? 2 : 1.5,
                          ),
                        ),
                        child: Text(
                          months[index],
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color:
                                isSelected ? Colors.white : _bpsTextSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainIndicators(ResponsiveSizing sizing, bool isSmallScreen) {
    final yearInflation = yearlyInflation[selectedYear] ?? 0.0;
    final coreInfl = coreInflation[selectedYear] ?? 0.0;
    final ihk = ihkData[selectedYear] ?? 0.0;

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
                color: _bpsBlue,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  'Indikator Utama Inflasi',
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
                value: NumberFormatUtils.formatPercentage(yearInflation),
                label: 'Inflasi Tahunan',
                color: _bpsBlue,
                icon: Icons.trending_up_rounded,
                description:
                    'Inflasi tahunan (Year-on-Year) mengukur perubahan harga barang dan jasa secara umum selama satu tahun. Angka ini menjadi acuan utama kebijakan moneter.',
                isFirst: true,
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value:
                    NumberFormatUtils.formatPercentage(currentInflationValue),
                label: selectedMonth == null
                    ? 'Inflasi Bulanan'
                    : 'Inflasi $currentMonthLabel',
                color: inflationColor,
                icon: Icons.calendar_month_rounded,
                description:
                    'Inflasi bulanan (Month-to-Month) mengukur perubahan harga barang dan jasa dari bulan ke bulan. Fluktuasi bulanan dipengaruhi oleh faktor musiman dan kebijakan harga.',
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: NumberFormatUtils.formatPercentage(coreInfl),
                label: 'Inflasi Inti',
                color: _bpsGreen,
                icon: Icons.insights_rounded,
                description:
                    'Inflasi inti (Core Inflation) menghilangkan komponen harga yang bergejolak (volatile) seperti bahan makanan dan energi. Indikator ini mencerminkan tekanan inflasi yang lebih fundamental.',
              ),
              _buildIndicatorDivider(isSmallScreen),
              _buildCompactIndicatorRow(
                context: context,
                value: NumberFormatUtils.formatDecimal(ihk, decimalPlaces: 2),
                label: 'Indeks Harga Konsumen',
                color: _bpsPurple,
                icon: Icons.assessment_rounded,
                description:
                    'Indeks Harga Konsumen (IHK) mengukur rata-rata perubahan harga dari suatu paket barang dan jasa yang dikonsumsi oleh rumah tangga. Basis perhitungan 2018=100.',
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

  Widget _buildIndicatorDivider(bool isSmallScreen) {
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
                                  color: _bpsTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 8 : 12),
                              Text(
                                value,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 28 : 32,
                                  fontWeight: FontWeight.w800,
                                  color: _bpsTextPrimary,
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
                            color: _bpsBackground,
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

  Widget _buildInflationChart(ResponsiveSizing sizing, bool isSmallScreen) {
    final years = availableYears;
    final spots = years.asMap().entries.map((e) {
      final val = yearlyInflation[e.value] ?? 0.0;
      return FlSpot(e.key.toDouble(), val);
    }).toList();

    final maxY = (yearlyInflation.values.reduce((a, b) => a > b ? a : b) + 0.5)
        .ceilToDouble();

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
                Icons.show_chart_rounded,
                color: _bpsBlue,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tren Inflasi Tahunan',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? sizing.groupTitleSize - 2
                            : sizing.groupTitleSize,
                        fontWeight: FontWeight.w700,
                        color: _bpsTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Persentase Year-on-Year (${years.last}-${years.first})',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: _bpsTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          SizedBox(
            height: isSmallScreen ? 200 : 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
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
                      reservedSize: isSmallScreen ? 35 : 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          NumberFormatUtils.formatPercentage(value),
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
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (years.length - 1).toDouble(),
                minY: 1.0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: _bpsBlue,
                    barWidth: isSmallScreen ? 2.5 : 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: isSmallScreen ? 3 : 5,
                          color: _bpsBlue,
                          strokeWidth: isSmallScreen ? 1.5 : 2.5,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          _bpsBlue.withOpacity(0.2),
                          _bpsBlue.withOpacity(0.02),
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
        ],
      ),
    );
  }

  Widget _buildMonthlyInflationChart(
      ResponsiveSizing sizing, bool isSmallScreen) {
    if (filteredMonthlyData.isEmpty) {
      return Container(
        padding: EdgeInsets.all(sizing.statsCardPadding),
        decoration: BoxDecoration(
          color: _bpsCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _bpsBorder, width: 1.5),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.info_outline_rounded, size: 40, color: _bpsTextLabel),
              SizedBox(height: sizing.itemSpacing),
              Text(
                'Data tidak tersedia',
                style: TextStyle(
                  fontSize: sizing.categoryLabelFontSize,
                  color: _bpsTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final monthlyData = filteredMonthlyData;
    final maxValue = monthlyData.reduce((a, b) => a > b ? a : b) + 0.2;
    final minValue = monthlyData.reduce((a, b) => a < b ? a : b) - 0.2;

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
                Icons.bar_chart_rounded,
                color: _bpsGreen,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedMonth == null
                          ? 'Inflasi Bulanan $selectedYear'
                          : 'Inflasi $currentMonthLabel $selectedYear',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? sizing.groupTitleSize - 2
                            : sizing.groupTitleSize,
                        fontWeight: FontWeight.w700,
                        color: _bpsTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Persentase Month-to-Month',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: _bpsTextSecondary,
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
              _buildLegendItem('Positif', _bpsBlue, isSmallScreen),
              SizedBox(width: sizing.horizontalPadding),
              _buildLegendItem('Negatif (Deflasi)', _bpsRed, isSmallScreen),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          SizedBox(
            height: isSmallScreen ? 180 : 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue,
                minY: minValue,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: isSmallScreen ? 30 : 35,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          NumberFormatUtils.formatPercentage(value),
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
                      getTitlesWidget: (value, meta) {
                        if (selectedMonth != null) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              months[selectedMonth!],
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 12,
                                color: _bpsTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        } else {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                months[idx],
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 10 : 12,
                                  color: _bpsTextPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(monthlyData.length, (index) {
                  final value = monthlyData[index];
                  final color = value >= 0 ? _bpsBlue : _bpsRed;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: color,
                        width: selectedMonth != null ? 25 : 10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInflationComponents(
      ResponsiveSizing sizing, bool isSmallScreen) {
    final yearStr = selectedYear.toString();

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
                Icons.category_rounded,
                color: _bpsOrange,
                size: isSmallScreen ? 16 : 20,
              ),
              SizedBox(width: sizing.itemSpacing),
              Text(
                'Komponen Inflasi',
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
          ...inflationComponents.entries.map((entry) {
            final value = entry.value[yearStr] ?? 0.0;
            final color = _getComponentColor(entry.key);

            return Padding(
              padding: EdgeInsets.only(bottom: sizing.itemSpacing),
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                decoration: BoxDecoration(
                  color: _bpsBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _bpsBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getComponentIcon(entry.key),
                        color: color,
                        size: isSmallScreen ? 18 : 20,
                      ),
                    ),
                    SizedBox(width: sizing.itemSpacing),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w600,
                          color: _bpsTextPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: sizing.itemSpacing),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sizing.itemSpacing,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        NumberFormatUtils.formatPercentage(value),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
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
              fontSize: isSmallScreen ? 12 : 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getComponentColor(String component) {
    switch (component) {
      case 'Makanan, Minuman & Tembakau':
        return _bpsOrange;
      case 'Pakaian & Alas Kaki':
        return _bpsPurple;
      case 'Perumahan & Fasilitas':
        return _bpsBlue;
      case 'Perawatan Kesehatan':
        return _bpsRed;
      case 'Transportasi':
        return _bpsGreen;
      case 'Komunikasi & Keuangan':
        return const Color(0xFF3F51B5);
      case 'Rekreasi & Olahraga':
        return _bpsTeal;
      default:
        return _bpsTextSecondary;
    }
  }

  IconData _getComponentIcon(String component) {
    switch (component) {
      case 'Makanan, Minuman & Tembakau':
        return Icons.restaurant_rounded;
      case 'Pakaian & Alas Kaki':
        return Icons.checkroom_rounded;
      case 'Perumahan & Fasilitas':
        return Icons.home_rounded;
      case 'Perawatan Kesehatan':
        return Icons.local_hospital_rounded;
      case 'Transportasi':
        return Icons.directions_car_rounded;
      case 'Komunikasi & Keuangan':
        return Icons.phone_iphone_rounded;
      case 'Rekreasi & Olahraga':
        return Icons.sports_soccer_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildKesimpulanCard(ResponsiveSizing sizing, bool isSmallScreen) {
    final sortedYears = monthlyInflationData.keys.toList()..sort((a, b) => b.compareTo(a));
    if (sortedYears.length < 2) {
      return const SizedBox.shrink();
    }

    final latestYear = sortedYears.first;
    final firstYear = sortedYears.last;
    final latestData = monthlyInflationData[latestYear];
    final firstData = monthlyInflationData[firstYear];

    if (latestData == null ||
        firstData == null ||
        latestData.isEmpty ||
        firstData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate average inflation for each year
    double calculateAverage(List<double> values) {
      if (values.isEmpty) return 0.0;
      return values.reduce((a, b) => a + b) / values.length;
    }

    final latestInflasi = calculateAverage(latestData);
    final firstInflasi = calculateAverage(firstData);

    // Calculate overall average across all years
    double totalInflasi = 0;
    int count = 0;
    for (final year in sortedYears) {
      final data = monthlyInflationData[year];
      if (data != null && data.isNotEmpty) {
        totalInflasi += calculateAverage(data);
        count++;
      }
    }
    final averageInflasi = count > 0 ? totalInflasi / count : 0.0;

    final conclusionData = KesimpulanGenerator.generateInflasiConclusion(
      latestYear: latestYear,
      firstYear: firstYear,
      latestInflasi: latestInflasi,
      firstInflasi: firstInflasi,
      averageInflasi: averageInflasi,
    );

    return KesimpulanWidget(
      title: 'Inflasi Kota Semarang',
      conclusion: conclusionData['conclusion'] as String,
      status: conclusionData['status'] as KesimpulanStatus,
      sizing: sizing,
      isSmallScreen: isSmallScreen,
      additionalPoints: (conclusionData['additionalPoints'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }
}
