import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'app_theme.dart';
import 'profile_screen.dart';
import 'statistik_screen.dart';
import 'ipm_screen.dart';
import 'kemiskinana_screen.dart';
import 'inflasi_screen.dart';
import 'penduduk_screen.dart';
import 'pertumbuhan_ekonomi_screen.dart';
import 'pengangguran_screen.dart';
import 'categories_data.dart';
import 'responsive_sizing.dart';
import 'number_format_utils.dart';
import 'home_snapshot_data.dart';

export 'categories_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _animationController;

  final GlobalKey<_BentoTile1State> _tile1Key = GlobalKey<_BentoTile1State>();
  final GlobalKey<_BentoTile2State> _tile2Key = GlobalKey<_BentoTile2State>();
  final GlobalKey<_BentoTile3State> _tile3Key = GlobalKey<_BentoTile3State>();
  final GlobalKey<_BentoTile4State> _tile4Key = GlobalKey<_BentoTile4State>();
  final GlobalKey<_BentoTile5State> _tile5Key = GlobalKey<_BentoTile5State>();
  final GlobalKey<_BentoTile6State> _tile6Key = GlobalKey<_BentoTile6State>();

  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tile1Key.currentState?.reloadData();
      _tile2Key.currentState?.reloadData();
      _tile3Key.currentState?.reloadData();
      _tile4Key.currentState?.reloadData();
      _tile5Key.currentState?.reloadData();
      _tile6Key.currentState?.reloadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizing = ResponsiveSizing(context);

    return Scaffold(
      backgroundColor: bpsBackground,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _HomeBody(
            animationController: _animationController,
            tile1Key: _tile1Key,
            tile2Key: _tile2Key,
            tile3Key: _tile3Key,
            tile4Key: _tile4Key,
            tile5Key: _tile5Key,
            tile6Key: _tile6Key,
            onExploreAll: () => setState(() => _navIndex = 1),
          ),
          const StatistikScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(sizing),
    );
  }

  Widget _buildBottomNav(ResponsiveSizing sizing) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BPSShadows.bottomNavShadow],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: sizing.bottomNavHeight,
          padding: EdgeInsets.symmetric(
            horizontal: sizing.bottomNavPadding,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                isSelected: _navIndex == 0,
                sizing: sizing,
                onTap: () => setState(() => _navIndex = 0),
              ),
              _buildNavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Statistik',
                isSelected: _navIndex == 1,
                sizing: sizing,
                onTap: () => setState(() => _navIndex = 1),
              ),
              _buildNavItem(
                icon: Icons.info_rounded,
                label: 'About Us',
                isSelected: _navIndex == 2,
                sizing: sizing,
                onTap: () => setState(() => _navIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required ResponsiveSizing sizing,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? bpsBlue : bpsTextLabel,
                size: sizing.bottomNavIconSize,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: sizing.bottomNavLabelSize,
                  color: isSelected ? bpsBlue : bpsTextLabel,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Home Body ────────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  final AnimationController animationController;
  final GlobalKey<_BentoTile1State> tile1Key;
  final GlobalKey<_BentoTile2State> tile2Key;
  final GlobalKey<_BentoTile3State> tile3Key;
  final GlobalKey<_BentoTile4State> tile4Key;
  final GlobalKey<_BentoTile5State> tile5Key;
  final GlobalKey<_BentoTile6State> tile6Key;
  final VoidCallback onExploreAll;

  const _HomeBody({
    required this.animationController,
    required this.tile1Key,
    required this.tile2Key,
    required this.tile3Key,
    required this.tile4Key,
    required this.tile5Key,
    required this.tile6Key,
    required this.onExploreAll,
  });

  @override
  Widget build(BuildContext context) {
    final sizing = ResponsiveSizing(context);
    return Column(
      children: [
        _buildHeader(sizing),
        Expanded(child: _buildBentoSection(sizing)),
      ],
    );
  }

  Widget _buildHeader(ResponsiveSizing sizing) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: bpsBlue.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            sizing.horizontalPadding,
            sizing.horizontalPadding * 0.7,
            sizing.horizontalPadding,
            sizing.horizontalPadding * 0.85,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/images/logo-bps.svg',
                width: sizing.headerLogoSize * 1.9,
                fit: BoxFit.contain,
                placeholderBuilder: (context) => Icon(
                  Icons.account_balance_rounded,
                  color: bpsBlue,
                  size: sizing.headerLogoSize,
                ),
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BPS KOTA SEMARANG',
                      style: TextStyle(
                        color: bpsTextPrimary,
                        fontSize: sizing.headerTitleSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Statistik Terpercaya',
                      style: TextStyle(
                        color: bpsTextSecondary,
                        fontSize: sizing.headerSubtitleSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBentoSection(ResponsiveSizing sizing) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizing.horizontalPadding,
        sizing.itemSpacing + 6,
        sizing.horizontalPadding,
        sizing.itemSpacing + 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StaggeredReveal(
            controller: animationController,
            start: 0.0,
            end: 0.45,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [bpsBlue, Color(0xFF1C6FA8)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: sizing.itemSpacing - 2),
                Text(
                  'Snapshot Data',
                  style: TextStyle(
                    fontSize: sizing.sectionTitleSize,
                    fontWeight: FontWeight.w800,
                    color: bpsTextPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.bolt_rounded, color: bpsBlue, size: 15),
                const SizedBox(width: 2),
                Text(
                  'Terkini',
                  style: TextStyle(
                    fontSize: sizing.headerSubtitleSize,
                    fontWeight: FontWeight.w600,
                    color: bpsBlue,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sizing.itemSpacing + 2),
          Expanded(
            child: _BentoGrid(
              animationController: animationController,
              sizing: sizing,
              tile1Key: tile1Key,
              tile2Key: tile2Key,
              tile3Key: tile3Key,
              tile4Key: tile4Key,
              tile5Key: tile5Key,
              tile6Key: tile6Key,
              onExploreAll: onExploreAll,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bento Grid ───────────────────────────────────────────────────────────────

class _BentoGrid extends StatelessWidget {
  final AnimationController animationController;
  final ResponsiveSizing sizing;
  final GlobalKey<_BentoTile1State> tile1Key;
  final GlobalKey<_BentoTile2State> tile2Key;
  final GlobalKey<_BentoTile3State> tile3Key;
  final GlobalKey<_BentoTile4State> tile4Key;
  final GlobalKey<_BentoTile5State> tile5Key;
  final GlobalKey<_BentoTile6State> tile6Key;
  final VoidCallback onExploreAll;

  const _BentoGrid({
    required this.animationController,
    required this.sizing,
    required this.tile1Key,
    required this.tile2Key,
    required this.tile3Key,
    required this.tile4Key,
    required this.tile5Key,
    required this.tile6Key,
    required this.onExploreAll,
  });

  @override
  Widget build(BuildContext context) {
    const spacing = 10.0;

    return Column(
      children: [
        // Hero — full width, taller
        Expanded(
          flex: 30,
          child: _StaggeredReveal(
            controller: animationController,
            start: 0.08,
            end: 0.62,
            child: _BentoTile5(key: tile5Key),
          ),
        ),
        const SizedBox(height: spacing),
        // Row A — Penduduk + IPM (equal)
        Expanded(
          flex: 22,
          child: _StaggeredReveal(
            controller: animationController,
            start: 0.18,
            end: 0.72,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _BentoTile1(key: tile1Key)),
                const SizedBox(width: spacing),
                Expanded(child: _BentoTile2(key: tile2Key)),
              ],
            ),
          ),
        ),
        const SizedBox(height: spacing),
        // Row B — Inflasi + Kemiskinan (equal)
        Expanded(
          flex: 22,
          child: _StaggeredReveal(
            controller: animationController,
            start: 0.28,
            end: 0.82,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _BentoTile4(key: tile4Key)),
                const SizedBox(width: spacing),
                Expanded(child: _BentoTile3(key: tile3Key)),
              ],
            ),
          ),
        ),
        const SizedBox(height: spacing),
        // Row C — TPT + CTA (equal)
        Expanded(
          flex: 22,
          child: _StaggeredReveal(
            controller: animationController,
            start: 0.38,
            end: 0.92,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _BentoTile6(key: tile6Key)),
                const SizedBox(width: spacing),
                Expanded(child: _CTATile(onTap: onExploreAll, sizing: sizing)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Staggered Reveal ─────────────────────────────────────────────────────────

class _StaggeredReveal extends StatelessWidget {
  final AnimationController controller;
  final double start;
  final double end;
  final Widget child;

  const _StaggeredReveal({
    required this.controller,
    required this.start,
    required this.end,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 24),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ─── Bento Tile Data Loaders ──────────────────────────────────────────────────

class _BentoTile1 extends StatefulWidget {
  const _BentoTile1({super.key});

  @override
  State<_BentoTile1> createState() => _BentoTile1State();
}

class _BentoTile1State extends State<_BentoTile1> {
  double? _value;
  double? _change;
  List<FlSpot>? _spots;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await HomeSnapshotData.loadPendudukData();
      if (data != null && mounted) {
        setState(() {
          _value = data['valueInMillions'] as double;
          _change = data['change'] as double;
          _spots = data['spots'] as List<FlSpot>;
          _date = DateTime(data['latestYear'] as int, 12, 31);
        });
      }
    } catch (e) {
      debugPrint('BentoTile1 error: $e');
    }
  }

  Future<void> reloadData() => _loadData();

  @override
  Widget build(BuildContext context) {
    return _BentoCellWidget(
      label: 'Penduduk',
      value: _value != null
          ? NumberFormatUtils.formatDecimal(_value!, decimalPlaces: 2)
          : '—',
      unit: 'Jt',
      change: _change != null
          ? '${_change! >= 0 ? '+' : ''}${NumberFormatUtils.formatDecimal(_change!, decimalPlaces: 2)}%'
          : '—',
      isPositive: _change != null ? _change! >= 0 : true,
      color: bpsSocialColor,
      icon: Icons.people_rounded,
      spots: _spots ?? [],
      date: _date,
      illustration: 'assets/new-illust-svg/Penduduk.svg',
      watermarkSize: 110,
      watermarkRight: -16,
      watermarkBottom: -18,
      screen: const PendudukScreen(),
    );
  }
}

class _BentoTile2 extends StatefulWidget {
  const _BentoTile2({super.key});

  @override
  State<_BentoTile2> createState() => _BentoTile2State();
}

class _BentoTile2State extends State<_BentoTile2> {
  double? _value;
  double? _change;
  List<FlSpot>? _spots;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await HomeSnapshotData.loadIPMData();
      if (data != null && mounted) {
        setState(() {
          _value = data['value'] as double;
          _change = data['change'] as double;
          _spots = data['spots'] as List<FlSpot>;
          _date = DateTime(data['latestYear'] as int, 12, 31);
        });
      }
    } catch (e) {
      debugPrint('BentoTile2 error: $e');
    }
  }

  Future<void> reloadData() => _loadData();

  @override
  Widget build(BuildContext context) {
    return _BentoCellWidget(
      label: 'IPM',
      value: _value != null
          ? NumberFormatUtils.formatDecimal(_value!, decimalPlaces: 2)
          : '—',
      unit: '',
      change: _change != null
          ? '${_change! >= 0 ? '+' : ''}${NumberFormatUtils.formatDecimal(_change!, decimalPlaces: 2)}%'
          : '—',
      isPositive: _change != null ? _change! >= 0 : true,
      color: bpsDevelopmentColor,
      icon: Icons.trending_up_rounded,
      spots: _spots ?? [],
      date: _date,
      illustration: 'assets/new-illust-svg/IPM.svg',
      screen: const IpmScreen(),
    );
  }
}

class _BentoTile3 extends StatefulWidget {
  const _BentoTile3({super.key});

  @override
  State<_BentoTile3> createState() => _BentoTile3State();
}

class _BentoTile3State extends State<_BentoTile3> {
  double? _value;
  double? _change;
  List<FlSpot>? _spots;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await HomeSnapshotData.loadKemiskinanData();
      if (data != null && mounted) {
        setState(() {
          _value = data['value'] as double;
          _change = data['change'] as double;
          _spots = data['spots'] as List<FlSpot>;
          _date = DateTime(data['latestYear'] as int, 12, 31);
        });
      }
    } catch (e) {
      debugPrint('BentoTile3 error: $e');
    }
  }

  Future<void> reloadData() => _loadData();

  @override
  Widget build(BuildContext context) {
    return _BentoCellWidget(
      label: 'Kemiskinan',
      value: _value != null
          ? NumberFormatUtils.formatDecimal(_value!, decimalPlaces: 2)
          : '—',
      unit: '%',
      change: _change != null
          ? '${_change! >= 0 ? '+' : ''}${NumberFormatUtils.formatDecimal(_change!, decimalPlaces: 2)}%'
          : '—',
      isPositive: _change != null ? _change! < 0 : false,
      color: bpsSocialColor,
      icon: Icons.volunteer_activism_rounded,
      spots: _spots ?? [],
      date: _date,
      illustration: 'assets/new-illust-svg/Kemiskinan.svg',
      watermarkSize: 110,
      watermarkRight: -16,
      watermarkBottom: -18,
      screen: const KemiskinanScreen(),
    );
  }
}

class _BentoTile4 extends StatefulWidget {
  const _BentoTile4({super.key});

  @override
  State<_BentoTile4> createState() => _BentoTile4State();
}

class _BentoTile4State extends State<_BentoTile4> {
  double? _value;
  double? _change;
  List<FlSpot>? _spots;
  String? _dateLabel;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await HomeSnapshotData.loadInflasiData();
      if (data != null && mounted) {
        setState(() {
          _value = data['value'] as double;
          _change = data['change'] as double;
          _spots = data['spots'] as List<FlSpot>;
          _dateLabel = data['dateLabel'] as String?;
        });
      }
    } catch (e) {
      debugPrint('BentoTile4 error: $e');
    }
  }

  Future<void> reloadData() => _loadData();

  @override
  Widget build(BuildContext context) {
    return _BentoCellWidget(
      label: 'Inflasi',
      value: _value != null
          ? NumberFormatUtils.formatDecimal(_value!, decimalPlaces: 2)
          : '—',
      unit: '%',
      change: _change != null
          ? '${_change! >= 0 ? '+' : ''}${NumberFormatUtils.formatDecimal(_change!, decimalPlaces: 2)}%'
          : '—',
      isPositive: _change != null ? _change! >= 0 : true,
      color: bpsBlue,
      icon: Icons.payments_rounded,
      spots: _spots ?? [],
      dateLabel: _dateLabel,
      illustration: 'assets/new-illust-svg/Inflasi.svg',
      screen: const InflasiScreen(),
    );
  }
}

class _BentoTile5 extends StatefulWidget {
  const _BentoTile5({super.key});

  @override
  State<_BentoTile5> createState() => _BentoTile5State();
}

class _BentoTile5State extends State<_BentoTile5> {
  double? _value;
  double? _change;
  List<FlSpot>? _spots;
  int? _latestYear;
  double? _prevVal;
  int? _prevYear;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await HomeSnapshotData.loadEkonomiData();
      if (data != null && mounted) {
        setState(() {
          _value = data['value'] as double;
          _change = data['change'] as double;
          _spots = data['spots'] as List<FlSpot>;
          _latestYear = data['latestYear'] as int;
          _prevVal = data['prevVal'] as double;
          _prevYear = data['prevYear'] as int;
        });
      }
    } catch (e) {
      debugPrint('BentoTile5 error: $e');
    }
  }

  Future<void> reloadData() => _loadData();

  @override
  Widget build(BuildContext context) {
    return _HeroCellWidget(
      label: 'Pertumbuhan Ekonomi',
      value: _value != null
          ? NumberFormatUtils.formatDecimal(_value!, decimalPlaces: 2)
          : '—',
      unit: '%',
      change: _change != null
          ? '${_change! >= 0 ? '+' : ''}${NumberFormatUtils.formatDecimal(_change!, decimalPlaces: 2)}%'
          : '—',
      isPositive: _change != null ? _change! >= 0 : true,
      color: bpsEconomicColor,
      icon: Icons.show_chart_rounded,
      spots: _spots ?? [],
      latestYear: _latestYear,
      prevVal: _prevVal,
      prevYear: _prevYear,
      illustration: 'assets/new-illust-svg/Pertumbuhan_ekonomi.svg',
      screen: const PertumbuhanEkonomiScreen(),
    );
  }
}

class _BentoTile6 extends StatefulWidget {
  const _BentoTile6({super.key});

  @override
  State<_BentoTile6> createState() => _BentoTile6State();
}

class _BentoTile6State extends State<_BentoTile6> {
  double? _value;
  double? _change;
  List<FlSpot>? _spots;
  int? _latestYear;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await HomeSnapshotData.loadTPTData();
      if (data != null && mounted) {
        setState(() {
          _value = data['value'] as double;
          _change = data['change'] as double;
          _spots = data['spots'] as List<FlSpot>;
          _latestYear = data['latestYear'] as int;
        });
      }
    } catch (e) {
      debugPrint('BentoTile6 error: $e');
    }
  }

  Future<void> reloadData() => _loadData();

  @override
  Widget build(BuildContext context) {
    return _BentoCellWidget(
      label: 'Pengangguran',
      value: _value != null
          ? NumberFormatUtils.formatDecimal(_value!, decimalPlaces: 2)
          : '—',
      unit: '%',
      change: _change != null
          ? '${_change! >= 0 ? '+' : ''}${NumberFormatUtils.formatDecimal(_change!, decimalPlaces: 2)}%'
          : '—',
      isPositive: _change != null ? _change! < 0 : false,
      color: bpsSocialColor,
      icon: Icons.work_off_rounded,
      spots: _spots ?? [],
      date: _latestYear != null ? DateTime(_latestYear!, 12, 31) : null,
      illustration: 'assets/new-illust-svg/Pengangguran.svg',
      screen: const PengangguranScreen(),
    );
  }
}

// ─── Hero Cell Widget ─────────────────────────────────────────────────────────

class _HeroCellWidget extends StatefulWidget {
  final String label;
  final String value;
  final String unit;
  final String change;
  final bool isPositive;
  final Color color;
  final IconData icon;
  final List<FlSpot> spots;
  final int? latestYear;
  final double? prevVal;
  final int? prevYear;
  final Widget screen;
  final String? illustration;

  const _HeroCellWidget({
    required this.label,
    required this.value,
    required this.unit,
    required this.change,
    required this.isPositive,
    required this.color,
    required this.icon,
    required this.spots,
    required this.screen,
    this.latestYear,
    this.prevVal,
    this.prevYear,
    this.illustration,
  });

  @override
  State<_HeroCellWidget> createState() => _HeroCellWidgetState();
}

class _HeroCellWidgetState extends State<_HeroCellWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prevText = widget.prevVal != null && widget.prevYear != null
        ? 'vs ${NumberFormatUtils.formatDecimal(widget.prevVal!, decimalPlaces: 2)}% in ${widget.prevYear}'
        : null;

    return AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        final scale = 1.0 - (_pressController.value * 0.025);
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => widget.screen),
          );
        },
        onTapCancel: () => _pressController.reverse(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(widget.color, Colors.white, 0.12)!,
                widget.color,
                Color.lerp(widget.color, Colors.black, 0.26)!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.36),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: -8,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 3),
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Instrument dot-grid texture
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DotGridPainter(
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                ),
                // Lit-from-above sheen
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.white.withOpacity(0.14),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Corner glow
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.18),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Illustration watermark
                if (widget.illustration != null)
                  _TileWatermark(
                    asset: widget.illustration!,
                    size: 188,
                    opacity: 0.5,
                    right: -16,
                    bottom: -18,
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                            Text(
                              widget.label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  widget.value,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1,
                                    letterSpacing: -0.5,
                                    fontFeatures: [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                                if (widget.unit.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.unit,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _ChangePill(
                                change: widget.change,
                                isPositive: widget.isPositive,
                              ),
                            ),
                            if (prevText != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                prevText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Bento Cell Display Widget ────────────────────────────────────────────────

class _BentoCellWidget extends StatefulWidget {
  final String label;
  final String value;
  final String unit;
  final String change;
  final bool isPositive;
  final Color color;
  final IconData icon;
  final List<FlSpot> spots;
  final DateTime? date;
  final String? dateLabel;
  final Widget screen;
  final String? illustration;
  final double watermarkSize;
  final double watermarkRight;
  final double watermarkBottom;

  const _BentoCellWidget({
    required this.label,
    required this.value,
    required this.unit,
    required this.change,
    required this.isPositive,
    required this.color,
    required this.icon,
    required this.spots,
    required this.screen,
    this.date,
    this.dateLabel,
    this.illustration,
    this.watermarkSize = 96,
    this.watermarkRight = -14,
    this.watermarkBottom = -16,
  });

  @override
  State<_BentoCellWidget> createState() => _BentoCellWidgetState();
}

class _BentoCellWidgetState extends State<_BentoCellWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        final scale = 1.0 - (_pressController.value * 0.025);
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => widget.screen),
          );
        },
        onTapCancel: () => _pressController.reverse(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(widget.color, Colors.white, 0.10)!,
                widget.color,
                Color.lerp(widget.color, Colors.black, 0.24)!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.30),
                blurRadius: 18,
                offset: const Offset(0, 8),
                spreadRadius: -6,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 5,
                offset: const Offset(0, 2),
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Lit-from-above sheen
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Corner glow
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.16),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Illustration watermark
                if (widget.illustration != null)
                  _TileWatermark(
                    asset: widget.illustration!,
                    size: widget.watermarkSize,
                    opacity: 0.46,
                    right: widget.watermarkRight,
                    bottom: widget.watermarkBottom,
                  ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: _CompactLayout(widget: widget),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactLayout extends StatelessWidget {
  final _BentoCellWidget widget;
  const _CompactLayout({required this.widget});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          widget.dateLabel ??
              (widget.date != null ? '${widget.date!.year}' : '—'),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.65),
          ),
        ),
        const Spacer(),
        // Value
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                widget.value,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                  letterSpacing: -0.5,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                widget.unit,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        // Change pill
        _ChangePill(
          change: widget.change,
          isPositive: widget.isPositive,
          compact: true,
        ),
      ],
    );
  }
}

// ─── CTA Tile ─────────────────────────────────────────────────────────────────

class _CTATile extends StatelessWidget {
  final VoidCallback onTap;
  final ResponsiveSizing sizing;

  const _CTATile({required this.onTap, required this.sizing});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: bpsBlue.withOpacity(0.12),
        highlightColor: bpsBlue.withOpacity(0.06),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                bpsBlue.withOpacity(0.10),
                bpsBlue.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: bpsBlue.withOpacity(0.25),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: bpsBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: bpsBlue.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${HomeScreenCategories.allCategories.length} Kategori',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: sizing.bottomNavLabelSize,
                  fontWeight: FontWeight.w700,
                  color: bpsBlue,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Jelajahi',
                    style: TextStyle(
                      fontSize: sizing.bottomNavLabelSize - 1,
                      fontWeight: FontWeight.w500,
                      color: bpsBlue.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: bpsBlue.withOpacity(0.8),
                    size: 13,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tile Illustration Watermark ──────────────────────────────────────────────
//
// Recolors a metric illustration to flat white via srcIn and drops it into the
// bottom-right of a bento tile at low opacity — decorative texture, no layout
// cost, never intercepts taps.

class _TileWatermark extends StatelessWidget {
  final String asset;
  final double size;
  final double opacity;
  final double right;
  final double bottom;

  const _TileWatermark({
    required this.asset,
    required this.size,
    this.opacity = 0.14,
    this.right = -14,
    this.bottom = -16,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: SvgPicture.asset(
            asset,
            width: size,
            height: size,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Change Pill ──────────────────────────────────────────────────────────────

class _ChangePill extends StatelessWidget {
  final String change;
  final bool isPositive;
  final bool compact;

  const _ChangePill({
    required this.change,
    required this.isPositive,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 6,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive
                ? Icons.arrow_outward_rounded
                : Icons.south_east_rounded,
            color: Colors.white,
            size: compact ? 11 : 13,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              change,
              style: TextStyle(
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dot-Grid Instrument Texture ──────────────────────────────────────────────

class _DotGridPainter extends CustomPainter {
  final Color color;

  const _DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const gap = 14.0;
    for (double y = 8; y < size.height; y += gap) {
      for (double x = 8; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.color != color;
}

