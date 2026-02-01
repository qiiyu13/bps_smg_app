import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'app_theme.dart';
import 'profile_screen.dart';
import 'ipm_screen.dart';
import 'kemiskinana_screen.dart';
import 'inflasi_screen.dart';
import 'penduduk_screen.dart';
import 'pendidikan_screen.dart';
import 'tenaga_kerja_screen.dart';
import 'pertumbuhan_ekonomi_screen.dart';
import 'ipg_screen.dart';
import 'idg_screen.dart';
import 'sdgs_screen.dart';
import 'responsive_sizing.dart';

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
      shortLabel: 'Ketenagakerjaan',
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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
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
      backgroundColor: bpsBackground,
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
        color: bpsCardBg,
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
                icon: Icons.person_rounded,
                label: 'Profile',
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
      physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        // Header with search
        _buildHeader(),
        
        // Last updated indicator
        _buildLastUpdatedIndicator(),
        
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
                      color: bpsCardBg,
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
            // Glass cards need a gradient background to show the blur effect
            Container(
              margin: EdgeInsets.symmetric(horizontal: sizing.horizontalPadding),
              height: sizing.statsCardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    bpsBlue.withOpacity(0.15),
                    bpsGreen.withOpacity(0.1),
                    bpsOrange.withOpacity(0.08),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: RepaintBoundary(
                  child: PageView.builder(
                    controller: statsPageController,
                    itemCount: 4,
                    physics: const PageScrollPhysics(),
                    allowImplicitScrolling: true,
                    itemBuilder: (context, index) {
                      return switch (index) {
                        0 => const _StatsCard1(),
                        1 => const _StatsCard2(),
                        2 => const _StatsCard3(),
                        3 => const _StatsCard4(),
                        _ => const SizedBox(),
                      };
                    },
                  ),
                ),
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
                  decoration: BPSDecorations.groupIconContainerDecoration(groupColor),
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
              color: bpsCardBg,
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
class _StatsCard1 extends StatelessWidget {
  const _StatsCard1();

  // Pre-computed chart data and spots
  static const List<double> _chartData = [1.68, 1.69, 1.69, 1.70, 1.71];
  static final List<FlSpot> _spots = List.generate(
    _chartData.length,
    (index) => FlSpot(index.toDouble(), _chartData[index]),
  );

  @override
  Widget build(BuildContext context) {
    return _GlassStatsCard(
      label: 'Penduduk',
      value: '1.709M',
      change: '+1.2%',
      isPositive: true,
      accentColor: bpsBlue,
      icon: Icons.people_rounded,
      chartSpots: _spots,
      screen: const PendudukScreen(),
    );
  }
}

class _StatsCard2 extends StatelessWidget {
  const _StatsCard2();

  static const List<double> _chartData = [80.5, 81.2, 81.8, 82.1, 82.4];
  static final List<FlSpot> _spots = List.generate(
    _chartData.length,
    (index) => FlSpot(index.toDouble(), _chartData[index]),
  );

  @override
  Widget build(BuildContext context) {
    return _GlassStatsCard(
      label: 'IPM',
      value: '82.39',
      change: '+2.3%',
      isPositive: true,
      accentColor: bpsGreen,
      icon: Icons.trending_up_rounded,
      chartSpots: _spots,
      screen: const IpmScreen(),
    );
  }
}

class _StatsCard3 extends StatelessWidget {
  const _StatsCard3();

  static const List<double> _chartData = [4.5, 4.3, 4.2, 4.1, 4.0];
  static final List<FlSpot> _spots = List.generate(
    _chartData.length,
    (index) => FlSpot(index.toDouble(), _chartData[index]),
  );

  @override
  Widget build(BuildContext context) {
    return _GlassStatsCard(
      label: 'Kemiskinan',
      value: '4.03%',
      change: '-0.87%',
      isPositive: false,
      accentColor: bpsOrange,
      icon: Icons.volunteer_activism_rounded,
      chartSpots: _spots,
      screen: const KemiskinanScreen(),
    );
  }
}

class _StatsCard4 extends StatelessWidget {
  const _StatsCard4();

  static const List<double> _chartData = [2.1, 2.5, 2.8, 2.9, 2.9];
  static final List<FlSpot> _spots = List.generate(
    _chartData.length,
    (index) => FlSpot(index.toDouble(), _chartData[index]),
  );

  @override
  Widget build(BuildContext context) {
    return _GlassStatsCard(
      label: 'Inflasi',
      value: '2.89%',
      change: '+0.39%',
      isPositive: true,
      accentColor: bpsRed,
      icon: Icons.payments_rounded,
      chartSpots: _spots,
      screen: const InflasiScreen(),
    );
  }
}

// Performance-optimized Glass Card Widget
class _GlassStatsCard extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final bool isPositive;
  final Color accentColor;
  final IconData icon;
  final List<FlSpot> chartSpots;
  final Widget screen;

  const _GlassStatsCard({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.accentColor,
    required this.icon,
    required this.chartSpots,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    final sizing = ResponsiveSizing(context);
    
    return RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Material(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => screen),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1.5,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.08),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(sizing.statsCardPadding),
                  child: Row(
                    children: [
                      // Glass icon container
                      Container(
                        width: sizing.statsIconContainerSize,
                        height: sizing.statsIconContainerSize,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: accentColor,
                          size: sizing.statsIconSize,
                        ),
                      ),
                      SizedBox(width: sizing.statsCardPadding - 4),
                      // Data column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: sizing.statsLabelFontSize,
                                fontWeight: FontWeight.w600,
                                color: bpsTextSecondary.withOpacity(0.9),
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: sizing.isVerySmall ? 4 : 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: sizing.statsValueFontSize,
                                      fontWeight: FontWeight.w800,
                                      color: bpsTextPrimary,
                                      height: 1,
                                      letterSpacing: -0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: sizing.isVerySmall ? 4 : 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: sizing.isVerySmall ? 5 : 8,
                                    vertical: sizing.isVerySmall ? 2 : 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isPositive
                                        ? bpsGreen.withOpacity(0.2)
                                        : bpsOrange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isPositive
                                          ? bpsGreen.withOpacity(0.3)
                                          : bpsOrange.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isPositive
                                            ? Icons.arrow_upward_rounded
                                            : Icons.arrow_downward_rounded,
                                        color: isPositive ? bpsGreen : bpsOrange,
                                        size: sizing.statsChangeIconSize,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        change,
                                        style: TextStyle(
                                          fontSize: sizing.statsChangeFontSize,
                                          fontWeight: FontWeight.w700,
                                          color: isPositive ? bpsGreen : bpsOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Mini chart with glass effect
                      SizedBox(
                        width: sizing.statsMiniChartWidth,
                        child: _GlassMiniChart(spots: chartSpots, color: accentColor),
                      ),
                    ],
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

// Glass morphism mini chart - brighter colors for glass card
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
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.4),
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
    return Material(
      color: bpsCardBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => category.screen),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: bpsCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: bpsBorder,
              width: 1.5,
            ),
            boxShadow: [BPSShadows.cardShadow],
          ),
          padding: EdgeInsets.all(sizing.categoryCardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(sizing.categoryIconContainerPadding),
                    decoration: BoxDecoration(
                      color: category.groupColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.groupColor,
                      size: sizing.categoryIconSize,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: bpsTextLabel,
                    size: sizing.categoryArrowSize,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.shortLabel,
                    style: TextStyle(
                      fontSize: sizing.categoryLabelFontSize,
                      fontWeight: FontWeight.w700,
                      color: bpsTextPrimary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (category.label != category.shortLabel) ...[
                    SizedBox(height: sizing.isVerySmall ? 2 : 4),
                    Text(
                      category.label,
                      style: TextStyle(
                        fontSize: sizing.categorySubLabelFontSize,
                        color: bpsTextLabel,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
