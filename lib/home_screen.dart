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
      duration: const Duration(milliseconds: 600),
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

  void _navigateToProfile() {
    Navigator.push(
      context,
      PageRouteBuilder<void>(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const ProfileScreen(),
      ),
    );
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
                isSelected: false,
                sizing: sizing,
                onTap: _navigateToProfile,
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
          highlightColor: bpsBlue.withOpacity(0.1),
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
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          _buildHeader(sizing),
          _buildBentoSection(sizing),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHeader(ResponsiveSizing sizing) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            bottom: BorderSide(color: bpsBlue, width: 3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              sizing.horizontalPadding,
              sizing.horizontalPadding,
              sizing.horizontalPadding,
              sizing.horizontalPadding,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/logo-bps.svg',
                  width: sizing.headerLogoSize * 2.0,
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
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Statistik Terpercaya',
                        style: TextStyle(
                          color: bpsTextSecondary,
                          fontSize: sizing.headerSubtitleSize,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
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

  SliverToBoxAdapter _buildBentoSection(ResponsiveSizing sizing) {
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOutCubic,
        )),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            sizing.horizontalPadding,
            sizing.sectionSpacing - 8,
            sizing.horizontalPadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: bpsBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: sizing.itemSpacing - 2),
                  Text(
                    'Snapshot Data',
                    style: TextStyle(
                      fontSize: sizing.sectionTitleSize,
                      fontWeight: FontWeight.w700,
                      color: bpsTextPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sizing.itemSpacing + 2),
              _BentoGrid(
                sizing: sizing,
                tile1Key: tile1Key,
                tile2Key: tile2Key,
                tile3Key: tile3Key,
                tile4Key: tile4Key,
                tile5Key: tile5Key,
                tile6Key: tile6Key,
                onExploreAll: onExploreAll,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bento Grid ───────────────────────────────────────────────────────────────

class _BentoGrid extends StatelessWidget {
  final ResponsiveSizing sizing;
  final GlobalKey<_BentoTile1State> tile1Key;
  final GlobalKey<_BentoTile2State> tile2Key;
  final GlobalKey<_BentoTile3State> tile3Key;
  final GlobalKey<_BentoTile4State> tile4Key;
  final GlobalKey<_BentoTile5State> tile5Key;
  final GlobalKey<_BentoTile6State> tile6Key;
  final VoidCallback onExploreAll;

  const _BentoGrid({
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
    final rowHeight = sizing.isVerySmall ? 118.0 : sizing.isSmall ? 128.0 : 138.0;
    const spacing = 10.0;

    return Column(
      children: [
        // Row 1: Penduduk (wide) | IPM (compact)
        SizedBox(
          height: rowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: _BentoTile1(key: tile1Key)),
              const SizedBox(width: spacing),
              Expanded(flex: 1, child: _BentoTile2(key: tile2Key)),
            ],
          ),
        ),
        const SizedBox(height: spacing),
        // Row 2: Kemiskinan (compact) | Inflasi (wide)
        SizedBox(
          height: rowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 1, child: _BentoTile3(key: tile3Key)),
              const SizedBox(width: spacing),
              Expanded(flex: 2, child: _BentoTile4(key: tile4Key)),
            ],
          ),
        ),
        const SizedBox(height: spacing),
        // Row 3: Pertumbuhan Ekonomi (wide) | TPT (compact)
        SizedBox(
          height: rowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: _BentoTile5(key: tile5Key)),
              const SizedBox(width: spacing),
              Expanded(flex: 1, child: _BentoTile6(key: tile6Key)),
            ],
          ),
        ),
        const SizedBox(height: spacing),
        // CTA tile
        _CTATile(onTap: onExploreAll, sizing: sizing),
      ],
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
      color: const Color(0xFF4CAF82),
      icon: Icons.people_rounded,
      spots: _spots ?? [],
      date: _date,
      isWide: true,
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
      isWide: false,
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
      color: const Color(0xFFE05555),
      icon: Icons.volunteer_activism_rounded,
      spots: _spots ?? [],
      date: _date,
      isWide: false,
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
      isWide: true,
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
        });
      }
    } catch (e) {
      debugPrint('BentoTile5 error: $e');
    }
  }

  Future<void> reloadData() => _loadData();

  @override
  Widget build(BuildContext context) {
    return _BentoCellWidget(
      label: 'Pertumbuhan Ekonomi',
      value: _value != null
          ? NumberFormatUtils.formatDecimal(_value!, decimalPlaces: 2)
          : '—',
      unit: '%',
      change: _change != null
          ? '${_change! >= 0 ? '+' : ''}${NumberFormatUtils.formatDecimal(_change!, decimalPlaces: 2)}%'
          : '—',
      isPositive: _change != null ? _change! >= 0 : true,
      color: const Color(0xFF7B5EA7),
      icon: Icons.show_chart_rounded,
      spots: _spots ?? [],
      date: _latestYear != null ? DateTime(_latestYear!, 12, 31) : null,
      isWide: true,
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
      label: 'TPT',
      value: _value != null
          ? NumberFormatUtils.formatDecimal(_value!, decimalPlaces: 2)
          : '—',
      unit: '%',
      change: _change != null
          ? '${_change! >= 0 ? '+' : ''}${NumberFormatUtils.formatDecimal(_change!, decimalPlaces: 2)}%'
          : '—',
      isPositive: _change != null ? _change! < 0 : false,
      color: const Color(0xFF1ABC9C),
      icon: Icons.work_off_rounded,
      spots: _spots ?? [],
      date: _latestYear != null ? DateTime(_latestYear!, 12, 31) : null,
      isWide: false,
      screen: const PengangguranScreen(),
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
  final bool isWide;
  final Widget screen;

  const _BentoCellWidget({
    required this.label,
    required this.value,
    required this.unit,
    required this.change,
    required this.isPositive,
    required this.color,
    required this.icon,
    required this.spots,
    required this.isWide,
    required this.screen,
    this.date,
    this.dateLabel,
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
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color,
                Color.lerp(widget.color, Colors.black, 0.18)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -3,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Decorative background icon
                Positioned(
                  right: -12,
                  bottom: -12,
                  child: Icon(
                    widget.icon,
                    size: widget.isWide ? 90 : 70,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: widget.isWide
                      ? _WideLayout(widget: widget)
                      : _CompactLayout(widget: widget),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  final _BentoCellWidget widget;
  const _WideLayout({required this.widget});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label + date
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          widget.dateLabel ??
              (widget.date != null
                  ? '${widget.date!.day.toString().padLeft(2, '0')}/${widget.date!.month.toString().padLeft(2, '0')}/${widget.date!.year}'
                  : '—'),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        // Value row
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              widget.value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
                letterSpacing: -0.5,
              ),
            ),
            if (widget.unit.isNotEmpty) ...[
              const SizedBox(width: 3),
              Text(
                widget.unit,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        // Change + sparkline
        Row(
          children: [
            Icon(
              widget.isPositive
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 3),
            Text(
              widget.change,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            if (widget.spots.isNotEmpty)
              _MiniChart(spots: widget.spots, color: Colors.white),
          ],
        ),
      ],
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
              (widget.date != null
                  ? '${widget.date!.year}'
                  : '—'),
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
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                widget.unit,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        // Change
        Row(
          children: [
            Icon(
              widget.isPositive
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                widget.change,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: bpsBlue.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: bpsBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: sizing.horizontalPadding),
          child: Row(
            children: [
              Icon(Icons.grid_view_rounded, color: bpsBlue, size: 20),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Text(
                  'Jelajahi ${HomeScreenCategories.allCategories.length} Kategori Statistik',
                  style: TextStyle(
                    fontSize: sizing.bottomNavLabelSize + 1,
                    fontWeight: FontWeight.w600,
                    color: bpsBlue,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: bpsBlue, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Mini Sparkline Chart ─────────────────────────────────────────────────────

class _MiniChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Color color;

  const _MiniChart({required this.spots, required this.color});

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) return const SizedBox();

    return RepaintBoundary(
      child: SizedBox(
        width: 72,
        height: 32,
        child: LineChart(
          LineChartData(
            minY: spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) * 0.95,
            maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.05,
            minX: 0,
            maxX: (spots.length - 1).toDouble(),
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.4,
                color: color,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: const LineTouchData(enabled: false),
          ),
        ),
      ),
    );
  }
}
