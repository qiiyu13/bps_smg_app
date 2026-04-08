import 'dart:async';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'profile_screen.dart';
import 'ipm_screen.dart';
import 'kemiskinana_screen.dart';
import 'inflasi_screen.dart';
import 'penduduk_screen.dart';
import 'pendidikan_screen.dart';
import 'tenaga_kerja_screen.dart';
import 'pengangguran_screen.dart';
import 'pertumbuhan_ekonomi_screen.dart';
import 'ipg_screen.dart';
import 'idg_screen.dart';
import 'sdgs_screen.dart';
import 'responsive_sizing.dart';
import 'number_format_utils.dart';

// Category data model - Made immutable for better performance
@immutable
class CategoryItem {
  final String label;
  final String shortLabel;
  final IconData icon;
  final Widget screen;
  final String group;
  final Color groupColor;

  const CategoryItem({
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.screen,
    required this.group,
    required this.groupColor,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryItem &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          group == other.group;

  @override
  int get hashCode => label.hashCode ^ group.hashCode;

  CategoryItem copyWith({
    String? label,
    String? shortLabel,
    IconData? icon,
    Widget? screen,
    String? group,
    Color? groupColor,
  }) {
    return CategoryItem(
      label: label ?? this.label,
      shortLabel: shortLabel ?? this.shortLabel,
      icon: icon ?? this.icon,
      screen: screen ?? this.screen,
      group: group ?? this.group,
      groupColor: groupColor ?? this.groupColor,
    );
  }
}

// Cache frequently used values
class _HomeScreenCache {
  static final List<CategoryItem> _allCategories = [
    // Economic Indicators Group
    const CategoryItem(
      label: 'Pertumbuhan Ekonomi',
      shortLabel: 'Ekonomi',
      icon: Icons.show_chart_rounded,
      screen: PertumbuhanEkonomiScreen(),
      group: 'Economic',
      groupColor: bpsEconomicColor,
    ),
    const CategoryItem(
      label: 'Inflasi',
      shortLabel: 'Inflasi',
      icon: Icons.payments_rounded,
      screen: InflasiScreen(),
      group: 'Economic',
      groupColor: bpsEconomicColor,
    ),
    const CategoryItem(
      label: 'Tenaga Kerja',
      shortLabel: 'Tenaga Kerja',
      icon: Icons.work_rounded,
      screen: TenagaKerjaScreen(),
      group: 'Economic',
      groupColor: bpsEconomicColor,
    ),
    const CategoryItem(
      label: 'Kemiskinan',
      shortLabel: 'Kemiskinan',
      icon: Icons.volunteer_activism_rounded,
      screen: KemiskinanScreen(),
      group: 'Economic',
      groupColor: bpsEconomicColor,
    ),
    const CategoryItem(
      label: 'Pengangguran',
      shortLabel: 'Pengangguran',
      icon: Icons.work_off_rounded,
      screen: PengangguranScreen(),
      group: 'Economic',
      groupColor: bpsEconomicColor,
    ),

    // Social Indicators Group
    const CategoryItem(
      label: 'Penduduk',
      shortLabel: 'Penduduk',
      icon: Icons.people_rounded,
      screen: PendudukScreen(),
      group: 'Social',
      groupColor: bpsSocialColor,
    ),
    const CategoryItem(
      label: 'Pendidikan',
      shortLabel: 'Pendidikan',
      icon: Icons.school_rounded,
      screen: PendidikanScreen(),
      group: 'Social',
      groupColor: bpsSocialColor,
    ),

    // Development Indices Group
    const CategoryItem(
      label: 'Indeks Pembangunan Manusia',
      shortLabel: 'IPM',
      icon: Icons.trending_up_rounded,
      screen: IpmScreen(),
      group: 'Development',
      groupColor: bpsDevelopmentColor,
    ),
    const CategoryItem(
      label: 'Indeks Pembangunan Gender',
      shortLabel: 'IPG',
      icon: Icons.balance_rounded,
      screen: IPGScreen(),
      group: 'Development',
      groupColor: bpsDevelopmentColor,
    ),
    const CategoryItem(
      label: 'Indeks Ketimpangan Gender',
      shortLabel: 'IDG',
      icon: Icons.bar_chart_rounded,
      screen: IDGScreen(),
      group: 'Development',
      groupColor: bpsDevelopmentColor,
    ),
    const CategoryItem(
      label: 'Sustainable Development Goals',
      shortLabel: 'SDGs',
      icon: Icons.public_rounded,
      screen: UserSDGsScreen(),
      group: 'Development',
      groupColor: bpsDevelopmentColor,
    ),
  ];

  static List<CategoryItem> get allCategories => _allCategories;

  static final Map<String, Map<String, dynamic>> _groupInfo = {
    'Economic': {
      'title': 'Indikator Ekonomi',
      'icon': Icons.monetization_on_rounded,
      'color': bpsEconomicColor,
    },
    'Social': {
      'title': 'Indikator Sosial',
      'icon': Icons.groups_rounded,
      'color': bpsSocialColor,
    },
    'Development': {
      'title': 'Indeks Pembangunan',
      'icon': Icons.rocket_launch_rounded,
      'color': bpsDevelopmentColor,
    },
  };

  static Map<String, Map<String, dynamic>> get groupInfo => _groupInfo;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final PageController _statsPageController;

  // FIX 1: Use ValueNotifier for page indicators to avoid setState on every scroll
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  DateTime _lastUpdated = DateTime(2024, 12, 1);

  // Debounce for search
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _statsPageController = PageController(
      viewportFraction: 1.0,
      keepPage: true,
    );

    _statsPageController.addListener(_handlePageChange);
  }

  // FIX 5: Immediate page change with threshold for stability
  void _handlePageChange() {
    if (!mounted) return;

    final page = _statsPageController.page;
    if (page == null) return;

    final newPage = page.round();

    // Only update when we've crossed the page threshold (page is close to integer)
    // This prevents flickering during mid-swipe while still being responsive
    final distanceFromPage = (page - newPage).abs();

    if (distanceFromPage < 0.3 && _currentPageNotifier.value != newPage) {
      _currentPageNotifier.value = newPage;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _statsPageController.removeListener(_handlePageChange);
    _statsPageController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  // Optimized search handler with debouncing
  void _handleSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = value;
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    if (mounted) {
      setState(() {
        _searchQuery = '';
      });
    }
  }

  Future<void> _refreshData() async {
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _lastUpdated = DateTime.now();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil diperbarui'),
          backgroundColor: bpsGreen,
        ),
      );
    }
  }

  // Optimized filtered categories getter
  List<CategoryItem> get _filteredCategories {
    if (_searchQuery.isEmpty) return _HomeScreenCache.allCategories;

    final query = _searchQuery.toLowerCase();
    return _HomeScreenCache.allCategories.where((cat) {
      return cat.label.toLowerCase().contains(query) ||
          cat.shortLabel.toLowerCase().contains(query);
    }).toList();
  }

  // Optimized grouped categories with caching
  Map<String, List<CategoryItem>> get _groupedCategories {
    final result = <String, List<CategoryItem>>{
      'Economic': [],
      'Social': [],
      'Development': [],
    };

    for (final cat in _filteredCategories) {
      result[cat.group]!.add(cat);
    }

    return result;
  }

  String get _formattedLastUpdated {
    final now = DateTime.now();
    final difference = now.difference(_lastUpdated);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} menit yang lalu';
      }
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else {
      return '${_lastUpdated.day}/${_lastUpdated.month}/${_lastUpdated.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizing = ResponsiveSizing(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: _HomeScreenContent(
        animationController: _animationController,
        statsPageController: _statsPageController,
        currentPageNotifier: _currentPageNotifier,
        searchController: _searchController,
        searchQuery: _searchQuery,
        onSearchChanged: _handleSearch,
        onClearSearch: _clearSearch,
        filteredCategories: _filteredCategories,
        groupedCategories: _groupedCategories,
        sizing: sizing,
        lastUpdated: _formattedLastUpdated,
      ),
      bottomNavigationBar: _buildModernBottomNav(sizing),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  Widget _buildModernBottomNav(ResponsiveSizing sizing) {
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
                label: 'Home',
                isSelected: true,
                sizing: sizing,
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

// Extract heavy content to a separate widget to minimize rebuilds
class _HomeScreenContent extends StatelessWidget {
  final AnimationController animationController;
  final PageController statsPageController;
  final ValueNotifier<int> currentPageNotifier;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final List<CategoryItem> filteredCategories;
  final Map<String, List<CategoryItem>> groupedCategories;
  final ResponsiveSizing sizing;
  final String lastUpdated;

  const _HomeScreenContent({
    required this.animationController,
    required this.statsPageController,
    required this.currentPageNotifier,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.filteredCategories,
    required this.groupedCategories,
    required this.sizing,
    required this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics:
          const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        // Header with search
        _buildHeader(),

        // Stats snapshot section
        _buildStatsSection(context),

        // Categories header
        _buildCategoriesHeader(),

        // Category groups
        ..._buildCategoryGroups(context),

        // Footer spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: animationController,
        child: Container(
          decoration: BoxDecoration(
            color: bpsBlue,
            boxShadow: [BPSShadows.headerShadow],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                sizing.horizontalPadding,
                sizing.horizontalPadding,
                sizing.horizontalPadding,
                sizing.horizontalPadding + 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar with logo
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(sizing.headerLogoPadding),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/logo_white.png',
                          width: sizing.headerLogoSize,
                          height: sizing.headerLogoSize,
                          filterQuality: FilterQuality.medium,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.account_balance_rounded,
                              color: Colors.white,
                              size: sizing.headerLogoSize,
                            );
                          },
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
                                color: Colors.white,
                                fontSize: sizing.headerTitleSize,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Statistik Terpercaya',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: sizing.headerSubtitleSize,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sizing.horizontalPadding),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Cari kategori statistik...',
                        hintStyle: TextStyle(
                          color: bpsTextLabel,
                          fontSize: sizing.searchFontSize,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: bpsBlue,
                          size: sizing.searchIconSize,
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: bpsTextSecondary,
                                  size: sizing.searchClearIconSize,
                                ),
                                onPressed: onClearSearch,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: sizing.searchPadding,
                          vertical: sizing.searchPadding,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildLastUpdatedIndicator() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.fromLTRB(
          sizing.horizontalPadding,
          sizing.itemSpacing,
          sizing.horizontalPadding,
          0,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: sizing.itemSpacing,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: bpsGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: bpsGreen.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.update_rounded,
              size: 14,
              color: bpsGreen,
            ),
            const SizedBox(width: 6),
            Text(
              'Terakhir diperbarui: $lastUpdated',
              style: TextStyle(
                fontSize: 11,
                color: bpsGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildStatsSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOutCubic,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                sizing.horizontalPadding,
                sizing.sectionSpacing - 8,
                sizing.horizontalPadding,
                sizing.horizontalPadding - 4,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    color: bpsBlue,
                    size: sizing.sectionIconSize,
                  ),
                  SizedBox(width: sizing.itemSpacing - 2),
                  Text(
                    'Snapshot Indikator Utama',
                    style: TextStyle(
                      fontSize: sizing.sectionTitleSize,
                      fontWeight: FontWeight.w700,
                      color: bpsTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            // Stats cards section
            SizedBox(
              height: sizing.statsCardHeight,
              // Removed fixed white background, border radius, and strict clipping
              // so the cards feel like they are floating freely rather than being inside a frame.
              child: PageView.builder(
                controller: statsPageController,
                itemCount: 4,
                physics:
                    const BouncingScrollPhysics(), // Softer bounce effect when swiping
                allowImplicitScrolling: true,
                clipBehavior:
                    Clip.none, // Allow shadows of the floating cards to show
                itemBuilder: (context, index) {
                  return Padding(
                    // Add the horizontal margin back here so the individual cards don't touch the edges
                    padding: EdgeInsets.symmetric(
                        horizontal: sizing.horizontalPadding),
                    child: switch (index) {
                      0 => const _StatsCard1(),
                      1 => const _StatsCard2(),
                      2 => const _StatsCard3(),
                      3 => const _StatsCard4(),
                      _ => const SizedBox(),
                    },
                  );
                },
              ),
            ),
            SizedBox(height: sizing.itemSpacing),
            // FIX 1: Use ValueListenableBuilder to isolate page indicator rebuilds
            ValueListenableBuilder<int>(
              valueListenable: currentPageNotifier,
              builder: (context, currentPage, child) {
                return _PageIndicators(
                  currentPage: currentPage,
                  pageController: statsPageController,
                  sizing: sizing,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildCategoriesHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          sizing.horizontalPadding,
          sizing.sectionSpacing,
          sizing.horizontalPadding,
          sizing.horizontalPadding - 4,
        ),
        child: Row(
          children: [
            Icon(
              Icons.grid_view_rounded,
              color: bpsBlue,
              size: sizing.sectionIconSize,
            ),
            SizedBox(width: sizing.itemSpacing - 2),
            Text(
              'Jelajahi Statistik',
              style: TextStyle(
                fontSize: sizing.sectionTitleSize,
                fontWeight: FontWeight.w700,
                color: bpsTextPrimary,
              ),
            ),
            const Spacer(),
            if (searchQuery.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sizing.itemSpacing,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: bpsBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${filteredCategories.length} hasil',
                  style: TextStyle(
                    fontSize: sizing.bottomNavLabelSize,
                    fontWeight: FontWeight.w600,
                    color: bpsBlue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryGroups(BuildContext context) {
    final widgets = <Widget>[];
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 3;

    groupedCategories.forEach((groupKey, categories) {
      if (categories.isEmpty) return;

      final info = _HomeScreenCache.groupInfo[groupKey]!;
      final groupColor = info['color'] as Color;

      // Group header
      widgets.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              sizing.horizontalPadding,
              sizing.horizontalPadding,
              sizing.horizontalPadding,
              sizing.itemSpacing,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(sizing.groupIconPadding),
                  decoration:
                      BPSDecorations.groupIconContainerDecoration(groupColor),
                  child: Icon(
                    info['icon'] as IconData,
                    color: groupColor,
                    size: sizing.groupIconSize,
                  ),
                ),
                SizedBox(width: sizing.itemSpacing),
                Text(
                  info['title'] as String,
                  style: TextStyle(
                    fontSize: sizing.groupTitleSize,
                    fontWeight: FontWeight.w700,
                    color: bpsTextPrimary,
                  ),
                ),
                SizedBox(width: sizing.itemSpacing - 2),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sizing.itemSpacing - 2,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: groupColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${categories.length}',
                    style: TextStyle(
                      fontSize: sizing.bottomNavLabelSize,
                      fontWeight: FontWeight.w600,
                      color: groupColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Category grid
      widgets.add(
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: sizing.horizontalPadding),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: sizing.categoryAspectRatio,
              crossAxisSpacing: sizing.gridSpacing,
              mainAxisSpacing: sizing.gridSpacing,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _CategoryCard(
                category: categories[index],
                sizing: sizing,
              ),
              childCount: categories.length,
              addAutomaticKeepAlives: true,
            ),
          ),
        ),
      );
    });

    // Empty state
    if (filteredCategories.isEmpty) {
      widgets.add(
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: sizing.horizontalPadding,
              vertical: sizing.sectionSpacing + 8,
            ),
            padding: EdgeInsets.all(sizing.sectionSpacing),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: sizing.isVerySmall ? 48 : 64,
                  color: bpsTextLabel,
                ),
                SizedBox(height: sizing.horizontalPadding - 4),
                Text(
                  'Tidak ada hasil',
                  style: TextStyle(
                    fontSize: sizing.sectionTitleSize - 2,
                    fontWeight: FontWeight.w600,
                    color: bpsTextSecondary,
                  ),
                ),
                SizedBox(height: sizing.itemSpacing - 2),
                Text(
                  'Coba kata kunci lain',
                  style: TextStyle(
                    fontSize: sizing.categoryLabelFontSize - 1,
                    color: bpsTextLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}

// FIX 1: Extracted page indicators to separate widget for better performance
class _PageIndicators extends StatelessWidget {
  final int currentPage;
  final PageController pageController;
  final ResponsiveSizing sizing;

  const _PageIndicators({
    required this.currentPage,
    required this.pageController,
    required this.sizing,
  });

  void _animateToPage(int index) {
    final currentPage = this.currentPage;
    final distance = (index - currentPage).abs();

    if (distance <= 2) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      pageController.jumpToPage(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final isActive = currentPage == index;
          return _PageIndicatorDot(
            isActive: isActive,
            onTap: () => _animateToPage(index),
            sizing: sizing,
          );
        }),
      ),
    );
  }
}

// FIX 2: Individual page indicator dot for granular rebuilds
class _PageIndicatorDot extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final ResponsiveSizing sizing;

  const _PageIndicatorDot({
    required this.isActive,
    required this.onTap,
    required this.sizing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: isActive
              ? sizing.pageIndicatorActiveWidth
              : sizing.pageIndicatorHeight,
          height: sizing.pageIndicatorHeight,
          decoration: BoxDecoration(
            color: isActive ? bpsBlue : bpsBorder,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

// Extract individual stat cards to separate widgets for better performance
// FIX 3: Cache chart spots with static const to avoid recreation
class _StatsCard1 extends StatefulWidget {
  const _StatsCard1();

  @override
  State<_StatsCard1> createState() => _StatsCard1State();
}

class _StatsCard1State extends State<_StatsCard1> {
  static const List<double> _chartData = [1.68, 1.69, 1.69, 1.70, 1.71];
  static final List<FlSpot> _spots = List.generate(
    _chartData.length,
    (index) => FlSpot(index.toDouble(), _chartData[index]),
  );

  DateTime? _latestDate;

  @override
  void initState() {
    super.initState();
    _loadLatestDate();
  }

  Future<void> _loadLatestDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('semarang_population_data');
      if (savedData != null) {
        final decoded = json.decode(savedData) as Map<String, dynamic>;
        final years = decoded.keys.map(int.parse).toList()..sort();
        if (years.isNotEmpty) {
          final latestYear = years.last;
          // Set date to December 31st of the latest year
          setState(() {
            _latestDate = DateTime(latestYear, 12, 31);
          });
        }
      } else {
        // Default to 2024 if no data
        setState(() {
          _latestDate = DateTime(2024, 12, 31);
        });
      }
    } catch (e) {
      debugPrint('Error loading penduduk date: $e');
      setState(() {
        _latestDate = DateTime(2024, 12, 31);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _GlassStatsCard(
      label: 'Penduduk',
      value: '1,65',
      unit: 'Jt',
      change: '+1,2%',
      isPositive: true,
      accentColor: bpsBlue,
      icon: Icons.people_rounded,
      chartSpots: _spots,
      screen: const PendudukScreen(),
      latestDate: _latestDate,
    );
  }
}

class _StatsCard2 extends StatefulWidget {
  const _StatsCard2();

  @override
  State<_StatsCard2> createState() => _StatsCard2State();
}

class _StatsCard2State extends State<_StatsCard2> {
  static const List<double> _chartData = [83.05, 83.55, 84.08, 84.43, 85.24];
  static final List<FlSpot> _spots = List.generate(
    _chartData.length,
    (index) => FlSpot(index.toDouble(), _chartData[index]),
  );

  DateTime? _latestDate;

  @override
  void initState() {
    super.initState();
    _loadLatestDate();
  }

  Future<void> _loadLatestDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('ipm_data');
      if (savedData != null) {
        final decoded = json.decode(savedData) as Map<String, dynamic>;
        final years = decoded.keys.map(int.parse).toList()..sort();
        if (years.isNotEmpty) {
          final latestYear = years.last;
          setState(() {
            _latestDate = DateTime(latestYear, 12, 31);
          });
        }
      } else {
        setState(() {
          _latestDate = DateTime(2024, 12, 31);
        });
      }
    } catch (e) {
      debugPrint('Error loading IPM date: $e');
      setState(() {
        _latestDate = DateTime(2024, 12, 31);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _GlassStatsCard(
      label: 'IPM',
      value: '85,24',
      unit: '',
      change: '+2,3%',
      isPositive: true,
      accentColor: bpsBlue,
      icon: Icons.trending_up_rounded,
      chartSpots: _spots,
      screen: const IpmScreen(),
      latestDate: _latestDate,
    );
  }
}

class _StatsCard3 extends StatefulWidget {
  const _StatsCard3();

  @override
  State<_StatsCard3> createState() => _StatsCard3State();
}

class _StatsCard3State extends State<_StatsCard3> {
  static const List<double> _chartData = [4.5, 4.3, 4.2, 4.1, 4.0];
  static final List<FlSpot> _spots = List.generate(
    _chartData.length,
    (index) => FlSpot(index.toDouble(), _chartData[index]),
  );

  DateTime? _latestDate;

  @override
  void initState() {
    super.initState();
    _loadLatestDate();
  }

  Future<void> _loadLatestDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('kemiskinan_data');
      if (savedData != null) {
        final decoded = json.decode(savedData) as Map<String, dynamic>;
        final years = decoded.keys.map(int.parse).toList()..sort();
        if (years.isNotEmpty) {
          final latestYear = years.last;
          setState(() {
            _latestDate = DateTime(latestYear, 12, 31);
          });
        }
      } else {
        setState(() {
          _latestDate = DateTime(2024, 12, 31);
        });
      }
    } catch (e) {
      debugPrint('Error loading kemiskinan date: $e');
      setState(() {
        _latestDate = DateTime(2024, 12, 31);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _GlassStatsCard(
      label: 'Kemiskinan',
      value: '4,03',
      unit: '%',
      change: '-0,87%',
      isPositive: false,
      invertedLogic: true, // Lower poverty is good
      accentColor: bpsBlue,
      icon: Icons.volunteer_activism_rounded,
      chartSpots: _spots,
      screen: const KemiskinanScreen(),
      latestDate: _latestDate,
    );
  }
}

class _StatsCard4 extends StatefulWidget {
  const _StatsCard4();

  @override
  State<_StatsCard4> createState() => _StatsCard4State();
}

class _StatsCard4State extends State<_StatsCard4> {
  static const List<double> _chartData = [1.68, 1.87, 4.21, 2.61, 2.89];
  static final List<FlSpot> _spots = List.generate(
    _chartData.length,
    (index) => FlSpot(index.toDouble(), _chartData[index]),
  );

  DateTime? _latestDate;

  @override
  void initState() {
    super.initState();
    _loadLatestDate();
  }

  Future<void> _loadLatestDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('inflasi_yearly_data');
      if (savedData != null) {
        final decoded = json.decode(savedData) as Map<String, dynamic>;
        final years = decoded.keys.map(int.parse).toList()..sort();
        if (years.isNotEmpty) {
          final latestYear = years.last;
          setState(() {
            _latestDate = DateTime(latestYear, 12, 31);
          });
        }
      } else {
        setState(() {
          _latestDate = DateTime(2024, 12, 31);
        });
      }
    } catch (e) {
      debugPrint('Error loading inflasi date: $e');
      setState(() {
        _latestDate = DateTime(2024, 12, 31);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _GlassStatsCard(
      label: 'Inflasi',
      value: '2,89',
      unit: '%',
      change: '+0,39%',
      isPositive: true,
      accentColor: bpsBlue,
      icon: Icons.payments_rounded,
      chartSpots: _spots,
      screen: const InflasiScreen(),
      latestDate: _latestDate,
    );
  }
}

// Enhanced Glassmorphism Card with improved visual hierarchy
class _GlassStatsCard extends StatefulWidget {
  final String label;
  final String value;
  final String unit;
  final String change;
  final bool isPositive;
  final Color accentColor;
  final IconData icon;
  final List<FlSpot> chartSpots;
  final Widget screen;
  final DateTime? latestDate;
  final bool invertedLogic;

  const _GlassStatsCard({
    required this.label,
    required this.value,
    this.unit = '',
    required this.change,
    required this.isPositive,
    required this.accentColor,
    required this.icon,
    required this.chartSpots,
    required this.screen,
    this.latestDate,
    this.invertedLogic = false,
  });

  @override
  State<_GlassStatsCard> createState() => _GlassStatsCardState();
}

class _GlassStatsCardState extends State<_GlassStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  String _formatFullDate(DateTime date) {
    final months = [
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
      'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Determine delta color based on metric type and direction
  Color _getDeltaColor() {
    // Inverted logic: for metrics where increase is bad (e.g., Kemiskinan)
    if (widget.invertedLogic) {
      return widget.isPositive ? bpsRed : bpsGreen;
    }
    // Normal logic: for metrics where increase is good
    return widget.isPositive ? bpsGreen : bpsRed;
  }

  IconData _getDeltaIcon() {
    return widget.isPositive
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final sizing = ResponsiveSizing(context);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => widget.screen),
        );
      },
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          final scale = 1.0 - (_scaleController.value * 0.02);
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: widget.accentColor,
            border: Border.all(
              color: Colors.white.withOpacity(_isPressed ? 0.3 : 0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(_isPressed ? 0.4 : 0.3),
                blurRadius: _isPressed ? 16 : 12,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => widget.screen),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.white.withOpacity(0.1),
                highlightColor: Colors.white.withOpacity(0.05),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sizing.statsCardPadding + 6,
                    vertical: sizing.statsCardPadding - 2,
                  ),
                  child: Row(
                    children: [
                      // Data
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Label row
                            Row(
                              children: [
                                Text(
                                  widget.label,
                                  style: TextStyle(
                                    fontSize: sizing.statsLabelFontSize + 4,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            // Date
                            if (widget.latestDate != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                _formatFullDate(widget.latestDate!),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.75),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            // Big number with superscript unit
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  widget.value,
                                  style: TextStyle(
                                    fontSize: sizing.statsValueFontSize + 4,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (widget.unit.isNotEmpty) ...[
                                  const SizedBox(width: 3),
                                  Baseline(
                                    baseline: sizing.statsValueFontSize + 4,
                                    baselineType: TextBaseline.alphabetic,
                                    child: Text(
                                      widget.unit,
                                      style: TextStyle(
                                        fontSize:
                                            (sizing.statsValueFontSize + 4) *
                                                0.55,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Chart and delta indicator column
                      SizedBox(
                        width: sizing.statsMiniChartWidth + 40,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Delta indicator
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getDeltaIcon(),
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.change,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Sparkline chart
                            _MiniChart(
                              spots: widget.chartSpots,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Color color;

  const _MiniChart({
    required this.spots,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) return const SizedBox();

    return RepaintBoundary(
      child: SizedBox(
        width: 80,
        height: 40,
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

// Glass morphism mini chart with end dot (static, no animation)
class _GlassMiniChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Color color;

  const _GlassMiniChart({
    required this.spots,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) return const SizedBox();

    // Use tighter Y-axis padding to make line use more vertical space
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;

    // Only add small padding if values are very close
    final yPadding = range < 0.5 ? 0.1 : range * 0.05;

    return RepaintBoundary(
      child: SizedBox(
        width: 80,
        height: 50, // Increased from 40 to 50
        child: LineChart(
          LineChartData(
            minY: minY - yPadding,
            maxY: maxY + yPadding,
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
                barWidth: 3, // Thicker line (was 2.5)
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) {
                    // Only show dot on the last data point
                    if (index == spots.length - 1) {
                      return FlDotCirclePainter(
                        radius: 4, // Slightly larger dot
                        color: color,
                        strokeWidth: 0,
                        strokeColor: Colors.transparent,
                      );
                    }
                    // Hide all other dots
                    return FlDotCirclePainter(radius: 0);
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.5), // More visible gradient
                      color.withOpacity(0.05),
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

class _CategoryCard extends StatelessWidget {
  final CategoryItem category;
  final ResponsiveSizing sizing;

  const _CategoryCard({
    required this.category,
    required this.sizing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: category.groupColor.withOpacity(0.15),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: category.groupColor.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => category.screen),
            );
          },
          borderRadius: BorderRadius.circular(16),
          highlightColor: category.groupColor.withOpacity(0.05),
          splashColor: category.groupColor.withOpacity(0.1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Subtle colored strip indicator on the left
              Container(
                width: 4,
                color: category.groupColor,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sizing.categoryCardPadding,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        category.icon,
                        color: category.groupColor,
                        size: sizing.isVerySmall ? 20 : 24,
                      ),
                      SizedBox(width: sizing.itemSpacing),
                      Expanded(
                        child: Text(
                          category.shortLabel,
                          style: TextStyle(
                            fontSize: sizing.isVerySmall
                                ? sizing.categoryLabelFontSize - 2
                                : sizing.categoryLabelFontSize - 1,
                            fontWeight: FontWeight.w600,
                            color: bpsTextPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
