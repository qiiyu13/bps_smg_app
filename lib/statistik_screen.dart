import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'app_theme.dart';
import 'categories_data.dart';
import 'responsive_sizing.dart';

class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _warmSvgCache();
  }

  // Parse + cache every category illustration up front so the first tab swipe
  // never blocks the main thread decoding a heavy SVG mid-gesture.
  void _warmSvgCache() {
    for (final c in HomeScreenCategories.allCategories) {
      if (c.illustration == null) continue;
      final loader = SvgAssetLoader(c.illustration!);
      svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizing = ResponsiveSizing(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatistikHeader(tabController: _tabController, sizing: sizing),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: HomeScreenCategories.tabGroups.map((groupKey) {
              final categories = HomeScreenCategories.allCategories
                  .where((c) => c.group == groupKey)
                  .toList();
              return _CategoryList(categories: categories, sizing: sizing);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _StatistikHeader extends StatelessWidget {
  final TabController tabController;
  final ResponsiveSizing sizing;

  const _StatistikHeader({
    required this.tabController,
    required this.sizing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: bpsBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                sizing.horizontalPadding,
                sizing.horizontalPadding,
                sizing.horizontalPadding,
                8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistik',
                    style: TextStyle(
                      fontSize: sizing.headerTitleSize + 4,
                      fontWeight: FontWeight.w800,
                      color: bpsTextPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Data BPS Kota Semarang',
                    style: TextStyle(
                      fontSize: sizing.headerSubtitleSize,
                      color: bpsTextSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: tabController,
              labelPadding: EdgeInsets.zero,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: bpsBlue, width: 3),
                insets: EdgeInsets.symmetric(horizontal: 24),
              ),
              dividerColor: Colors.transparent,
              tabs: HomeScreenCategories.tabGroups.asMap().entries.map((entry) {
                final idx = entry.key;
                final groupKey = entry.value;
                final color = HomeScreenCategories.groupInfo[groupKey]!['color'] as Color;
                final count = HomeScreenCategories.allCategories
                    .where((c) => c.group == groupKey)
                    .length;
                final animation = tabController.animation ?? tabController;
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    // Continuous position (0..length-1) tracks the swipe in
                    // real time, so the label interpolates with the finger
                    // instead of snapping late on the index threshold.
                    final value = tabController.animation?.value ??
                        tabController.index.toDouble();
                    final t = (1.0 - (value - idx).abs()).clamp(0.0, 1.0);
                    // Front-load the saturation so the color lights up early in
                    // the swipe, in sync with the indicator, not at the very end.
                    final lit = Curves.easeOutCubic.transform(t);
                    return Tab(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          '${HomeScreenCategories.tabLabels[idx]} ($count)',
                          style: TextStyle(
                            fontSize: sizing.bottomNavLabelSize + 1,
                            fontWeight:
                                t > 0.3 ? FontWeight.w700 : FontWeight.w500,
                            color: Color.lerp(bpsTextLabel, color, lit),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryList extends StatefulWidget {
  final List<CategoryItem> categories;
  final ResponsiveSizing sizing;

  const _CategoryList({
    required this.categories,
    required this.sizing,
  });

  @override
  State<_CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<_CategoryList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final categories = widget.categories;
    final sizing = widget.sizing;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          sizing.horizontalPadding,
          sizing.horizontalPadding,
          sizing.horizontalPadding,
          sizing.horizontalPadding + 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _CategoryCard(
            category: categories[index],
            sizing: sizing,
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final CategoryItem category;
  final ResponsiveSizing sizing;

  const _CategoryCard({
    required this.category,
    required this.sizing,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
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
    final groupTitle =
        HomeScreenCategories.groupInfo[widget.category.group]!['title'] as String;
    final color = widget.category.groupColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          final scale = 1.0 - (_pressController.value * 0.02);
          return Transform.scale(scale: scale, child: child);
        },
        child: GestureDetector(
          onTapDown: (_) => _pressController.forward(),
          onTapUp: (_) {
            _pressController.reverse();
            HapticFeedback.selectionClick();
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (_) => widget.category.screen),
            );
          },
          onTapCancel: () => _pressController.reverse(),
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  Color.lerp(color, Colors.black, 0.15)!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // Large decorative illustration watermark (recolored flat white)
                  Positioned(
                    right: -14,
                    bottom: -16,
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: widget.category.illustration != null
                            ? SvgPicture.asset(
                                widget.category.illustration!,
                                width: 118,
                                height: 118,
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(0.4),
                                  BlendMode.srcIn,
                                ),
                              )
                            : Icon(
                                widget.category.icon,
                                size: 120,
                                color: Colors.white.withOpacity(0.12),
                              ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: EdgeInsets.all(widget.sizing.horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.category.label,
                          style: TextStyle(
                            fontSize: widget.sizing.categoryLabelFontSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          groupTitle,
                          style: TextStyle(
                            fontSize: widget.sizing.headerSubtitleSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.8),
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
      ),
    );
  }
}
