import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_theme.dart';

/// ════════════════════════════════════════════════════════════════════════
/// Section Kit — shared "editorial data brief" UI language for category
/// screens. One bold accent-colored hero per screen; everything else quiet
/// white panels with an accent-spine section header.
///
/// All components are accent-driven: pass the group color (blue = Economic,
/// green = Social, orange = Development) and the chrome adapts.
/// ════════════════════════════════════════════════════════════════════════

const String kDisplayFont = 'PlusJakartaSans';

/// Derive a 3-stop hero gradient from an accent color: a lighter lead, the
/// accent itself, then a deepened tail. Keeps every group's hero on-brand.
List<Color> heroGradient(Color accent) {
  final hsl = HSLColor.fromColor(accent);
  final light = hsl
      .withLightness((hsl.lightness + 0.12).clamp(0.0, 1.0))
      .withSaturation((hsl.saturation + 0.05).clamp(0.0, 1.0))
      .toColor();
  final dark = hsl
      .withLightness((hsl.lightness - 0.28).clamp(0.0, 1.0))
      .toColor();
  return [light, accent, dark];
}

/// Quiet white container used for every non-hero section.
class SectionPanel extends StatelessWidget {
  final Widget child;
  final bool isSmall;
  final EdgeInsets? padding;

  const SectionPanel({
    super.key,
    required this.child,
    this.isSmall = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Flat surface to match the editorial spine: no border, no shadow. The
    // spine rail now carries the structure, so panels stay quiet.
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(isSmall ? 16 : 18),
      decoration: BoxDecoration(
        color: bpsCardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

/// Accent-spine section header: 4px color bar + title (+ optional subtitle,
/// trailing widget). Replaces the old boxed-icon + grey header pattern.
class SectionHead extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color accent;
  final bool isSmall;
  final Widget? trailing;

  const SectionHead({
    super.key,
    required this.title,
    this.subtitle,
    this.accent = bpsBlue,
    this.isSmall = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: subtitle != null ? (isSmall ? 34 : 38) : 22,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: kDisplayFont,
                  fontSize: isSmall ? 15.5 : 17,
                  fontWeight: FontWeight.w700,
                  color: bpsTextPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: isSmall ? 11.5 : 12.5,
                    color: bpsTextSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Small left-accent stat tile (paired metrics under a feature value).
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSmall;

  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 14),
      decoration: BoxDecoration(
        color: bpsBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isSmall ? 18 : 20),
          SizedBox(height: isSmall ? 8 : 10),
          Text(
            value,
            style: TextStyle(
              fontFamily: kDisplayFont,
              fontSize: isSmall ? 16 : 18,
              fontWeight: FontWeight.w800,
              color: bpsTextPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 11 : 12,
              color: bpsTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single labelled fact rendered inside the hero footer.
class HeroFact {
  final String label;
  final String value;
  const HeroFact(this.label, this.value);
}

/// The one bold colored block per screen — the headline indicator.
/// Gradient field, oversized value, optional delta chip, optional sparkline,
/// optional footer facts.
class IndicatorHero extends StatelessWidget {
  final String overline;
  final String value;
  final String subtitle;
  final String? badge;
  final Color accent;
  final double? delta;
  final String deltaUnit;
  final List<double>? sparkline;
  final List<HeroFact> facts;
  final bool isSmall;
  final IconData? icon;

  const IndicatorHero({
    super.key,
    required this.overline,
    required this.value,
    required this.subtitle,
    this.badge,
    this.accent = bpsBlue,
    this.delta,
    this.deltaUnit = 'pp',
    this.sparkline,
    this.facts = const [],
    this.isSmall = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = heroGradient(accent);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isSmall ? 20 : 24,
        isSmall ? 20 : 24,
        isSmall ? 20 : 24,
        isSmall ? 16 : 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
          stops: const [0.0, 0.45, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.34),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -42,
            top: -52,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 24,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      overline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        fontSize: isSmall ? 10 : 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: isSmall ? 12 : 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: kDisplayFont,
                        color: Colors.white,
                        fontSize: isSmall ? 46 : 56,
                        fontWeight: FontWeight.w800,
                        height: 0.95,
                        letterSpacing: -2,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  if (delta != null) ...[
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _DeltaChip(
                          delta: delta!, unit: deltaUnit, isSmall: isSmall),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontSize: isSmall ? 11.5 : 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (sparkline != null && sparkline!.isNotEmpty) ...[
                SizedBox(height: isSmall ? 14 : 18),
                SizedBox(
                  height: isSmall ? 44 : 52,
                  child: MiniSparkline(values: sparkline!, accent: accent),
                ),
              ],
              if (facts.isNotEmpty) ...[
                SizedBox(height: isSmall ? 12 : 14),
                Divider(color: Colors.white.withOpacity(0.16), height: 1),
                SizedBox(height: isSmall ? 10 : 12),
                Row(
                  children: [
                    for (int i = 0; i < facts.length; i++) ...[
                      if (i > 0)
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.16),
                        ),
                      _heroFact(facts[i]),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroFact(HeroFact fact) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fact.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: isSmall ? 10.5 : 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              fact.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: kDisplayFont,
                color: Colors.white,
                fontSize: isSmall ? 14 : 16,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  final double delta;
  final String unit;
  final bool isSmall;

  const _DeltaChip(
      {required this.delta, required this.unit, required this.isSmall});

  @override
  Widget build(BuildContext context) {
    final positive = delta >= 0;
    final tint = positive ? const Color(0xFFB6E388) : const Color(0xFFFFB4A8);
    final fmt = delta.abs().toStringAsFixed(2).replaceAll('.', ',');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: tint.withOpacity(0.45), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            color: tint,
            size: isSmall ? 13 : 14,
          ),
          const SizedBox(width: 3),
          Text(
            '${positive ? '+' : '-'}$fmt $unit',
            style: TextStyle(
              color: tint,
              fontSize: isSmall ? 11.5 : 12.5,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// White line sparkline on a colored hero field. Dot only on the last point.
class MiniSparkline extends StatelessWidget {
  final List<double> values;
  final Color accent;

  const MiniSparkline({super.key, required this.values, required this.accent});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final lastIndex = values.length - 1;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        minX: 0,
        maxX: lastIndex.toDouble(),
        minY: minV - 1,
        maxY: maxV + 1,
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (int i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
            isCurved: true,
            color: Colors.white,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                if (index != lastIndex) {
                  return FlDotCirclePainter(radius: 0, color: Colors.white);
                }
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2.5,
                  strokeColor: accent,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.28),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal pill rail for selecting a year (or any int key).
class YearRail extends StatelessWidget {
  final List<int> years;
  final int selected;
  final ValueChanged<int> onSelect;
  final Color accent;
  final bool isSmall;
  final ScrollController? controller;
  final String label;

  const YearRail({
    super.key,
    required this.years,
    required this.selected,
    required this.onSelect,
    this.accent = bpsBlue,
    this.isSmall = false,
    this.controller,
    this.label = 'TAHUN DATA',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 10 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: bpsTextLabel,
            ),
          ),
        ),
        SizedBox(
          height: isSmall ? 38 : 42,
          child: ListView.separated(
            controller: controller,
            scrollDirection: Axis.horizontal,
            itemCount: years.length,
            separatorBuilder: (_, __) => SizedBox(width: isSmall ? 8 : 10),
            itemBuilder: (_, i) {
              final year = years[i];
              final isSelected = year == selected;
              return Material(
                color: isSelected ? accent : bpsCardBg,
                borderRadius: BorderRadius.circular(40),
                child: InkWell(
                  onTap: () => onSelect(year),
                  borderRadius: BorderRadius.circular(40),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: isSelected ? accent : bpsBorder,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: accent.withOpacity(0.28),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      year.toString(),
                      style: TextStyle(
                        fontFamily: kDisplayFont,
                        fontSize: isSmall ? 14 : 15,
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
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════
/// Editorial spine — a continuous left rail threads every section of a screen.
/// Each section gets a numbered node + title beside it; content sits below,
/// indented under the title. Sections stack with NO gaps between them so the
/// rail reads as one unbroken line down the page.
///
/// Every section shares ONE quiet surface — flat white, soft rounded, no
/// border and no drop shadow — so the page reads as a single connected
/// document threaded by the rail rather than a stack of disconnected cards.
/// `framed: false` only tightens padding (used for charts that supply their
/// own internal margins); it is NOT a different surface.
///
/// Pass a `number` ("01", "02"…) for ordinary nodes; leave it null for the
/// final/conclusion node, which renders as a solid accent dot.
/// ════════════════════════════════════════════════════════════════════════
class SpineSection extends StatelessWidget {
  final String? number;
  final String title;
  final String? subtitle;
  final String? overline;
  final Color accent;
  final Widget child;
  final bool framed;
  final bool surface;
  final bool isFirst;
  final bool isLast;
  final bool isSmall;
  final Widget? trailing;

  const SpineSection({
    super.key,
    this.number,
    required this.title,
    required this.child,
    this.subtitle,
    this.overline,
    this.accent = bpsBlue,
    this.framed = true,
    this.surface = true,
    this.isFirst = false,
    this.isLast = false,
    this.isSmall = false,
    this.trailing,
  });

  static const double _nodeSize = 24;
  // Slim left gutter: the node sits in the top-left corner and the rail line
  // runs down the far-left edge, so section BODIES keep almost the full screen
  // width on a phone. Only the header hangs indented beside the node.
  static const double _bodyIndent = 16; // clears the rail line
  // Node center measured from the top of the section — aligned to the vertical
  // middle of the title block so the line enters/exits through the node.
  double get _nodeCenterY => _nodeSize / 2;

  @override
  Widget build(BuildContext context) {
    final lineX = _nodeSize / 2; // rail line runs through the node centre
    final headerExtra = _nodeSize + 8 - _bodyIndent; // header clears the node
    final line = accent.withOpacity(0.22);
    final bottomGap = isLast ? 0.0 : (isSmall ? 22.0 : 26.0);

    // Stack sized by the (non-positioned) content; the rail line uses
    // top/bottom anchoring to fill that height — no IntrinsicHeight, so
    // LayoutBuilder / ScrollView children inside the surface are safe.
    return Stack(
      children: [
        // line above the node (omitted on the first section)
        if (!isFirst)
          Positioned(
            left: lineX - 1,
            top: 0,
            height: _nodeCenterY,
            child: Container(width: 2, color: line),
          ),
        // line below the node, fills to the bottom (omitted on last)
        if (!isLast)
          Positioned(
            left: lineX - 1,
            top: _nodeCenterY,
            bottom: 0,
            child: Container(width: 2, color: line),
          ),
        // ── Content column (sizes the stack) ──────────────────────────
        Padding(
          padding: EdgeInsets.only(left: _bodyIndent, bottom: bottomGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header hangs indented beside the corner node
              Padding(
                padding: EdgeInsets.only(left: headerExtra),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _nodeSize),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (overline != null) ...[
                      Text(
                        overline!.toUpperCase(),
                        style: TextStyle(
                          fontFamily: kDisplayFont,
                          fontSize: isSmall ? 9.5 : 10,
                          fontWeight: FontWeight.w700,
                          color: accent,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 3),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: kDisplayFont,
                              fontSize: isSmall ? 16.5 : 18.5,
                              fontWeight: FontWeight.w800,
                              color: bpsTextPrimary,
                              letterSpacing: -0.4,
                              height: 1.08,
                            ),
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: 8),
                          trailing!,
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: isSmall ? 11.5 : 12.5,
                          color: bpsTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ),
              SizedBox(height: isSmall ? 9 : 11),
              // report-style rule: short accent lead + hairline
              Row(
                children: [
                  Container(width: 22, height: 2.5, color: accent),
                  Expanded(
                    child: Container(height: 1, color: bpsBorder),
                  ),
                ],
              ),
              SizedBox(height: isSmall ? 12 : 14),
              if (surface)
                Container(
                  width: double.infinity,
                  padding: framed
                      ? EdgeInsets.all(isSmall ? 16 : 18)
                      : EdgeInsets.all(isSmall ? 10 : 12),
                  decoration: BoxDecoration(
                    color: bpsCardBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: child,
                )
              else
                child,
            ],
          ),
        ),
        // ── Node (top-left corner, on top of the line) ────────────────
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            width: _nodeSize,
            height: _nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLast ? accent : Colors.white,
              border: Border.all(color: accent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: isLast
                  ? const Icon(Icons.flag_rounded,
                      color: Colors.white, size: 13)
                  : Text(
                      number ?? '•',
                      style: TextStyle(
                        fontFamily: kDisplayFont,
                        color: accent,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Slim screen header with overline + title, accent background.
class CategoryHeader extends StatelessWidget {
  final String overline;
  final String title;
  final IconData icon;
  final Color accent;
  final bool isSmall;
  final double titleSize;

  const CategoryHeader({
    super.key,
    required this.overline,
    required this.title,
    required this.icon,
    this.accent = bpsBlue,
    this.isSmall = false,
    this.titleSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent,
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 12 : 16,
            vertical: isSmall ? 10 : 14,
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.all(isSmall ? 10 : 12),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: isSmall ? 20 : 24,
                  ),
                ),
              ),
              SizedBox(width: isSmall ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overline,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: isSmall ? 9.5 : 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: kDisplayFont,
                        color: Colors.white,
                        fontSize: isSmall ? titleSize - 4 : titleSize,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                icon,
                color: Colors.white.withOpacity(0.9),
                size: isSmall ? 22 : 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
