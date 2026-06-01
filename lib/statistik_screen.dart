import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: bpsBlue, width: 3),
              ),
              dividerColor: Colors.transparent,
              tabs: HomeScreenCategories.tabGroups.asMap().entries.map((entry) {
                final idx = entry.key;
                final groupKey = entry.value;
                final color = HomeScreenCategories.groupInfo[groupKey]!['color'] as Color;
                final count = HomeScreenCategories.allCategories
                    .where((c) => c.group == groupKey)
                    .length;
                return AnimatedBuilder(
                  animation: tabController,
                  builder: (context, child) {
                    final isActive = tabController.index == idx;
                    return Tab(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          '${HomeScreenCategories.tabLabels[idx]} ($count)',
                          style: TextStyle(
                            fontSize: sizing.bottomNavLabelSize + 1,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? color : bpsTextLabel,
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

class _CategoryList extends StatelessWidget {
  final List<CategoryItem> categories;
  final ResponsiveSizing sizing;

  const _CategoryList({
    required this.categories,
    required this.sizing,
  });

  @override
  Widget build(BuildContext context) {
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
                  // Large decorative background icon (illustration placeholder)
                  Positioned(
                    right: -18,
                    bottom: -18,
                    child: Icon(
                      widget.category.icon,
                      size: 120,
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: EdgeInsets.all(widget.sizing.horizontalPadding),
                    child: Row(
                      children: [
                        // Icon container
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            widget.category.icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: widget.sizing.itemSpacing + 2),
                        // Text
                        Expanded(
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
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  groupTitle,
                                  style: TextStyle(
                                    fontSize: widget.sizing.headerSubtitleSize,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: 14,
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
