import 'package:flutter/material.dart';
import 'app_theme.dart';
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

@immutable
class CategoryItem {
  final String label;
  final String shortLabel;
  final IconData icon;
  final Widget screen;
  final String group;
  final Color groupColor;
  final String? illustration;

  /// Multiplier on the card's base watermark size. Square-viewBox illustrations
  /// (e.g. Kemiskinan, 1000×1000) carry internal padding and render visually
  /// smaller than edge-bleeding art at the same box size — bump those above 1.0.
  final double illustrationScale;

  const CategoryItem({
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.screen,
    required this.group,
    required this.groupColor,
    this.illustration,
    this.illustrationScale = 1.0,
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
}

class HomeScreenCategories {
  static const List<String> tabGroups = ['Economic', 'Social', 'Development'];
  static const List<String> tabLabels = ['Ekonomi', 'Sosial', 'Pembangunan'];

  static final List<CategoryItem> allCategories = [
    // Economic
    const CategoryItem(
      label: 'Pertumbuhan Ekonomi',
      shortLabel: 'Ekonomi',
      icon: Icons.show_chart_rounded,
      screen: PertumbuhanEkonomiScreen(),
      group: 'Economic',
      groupColor: bpsEconomicColor,
      illustration: 'assets/new-illust-svg/Pertumbuhan_ekonomi.svg',
    ),
    const CategoryItem(
      label: 'Inflasi',
      shortLabel: 'Inflasi',
      icon: Icons.payments_rounded,
      screen: InflasiScreen(),
      group: 'Economic',
      groupColor: bpsEconomicColor,
      illustration: 'assets/new-illust-svg/Inflasi.svg',
    ),
    // Social
    const CategoryItem(
      label: 'Penduduk',
      shortLabel: 'Penduduk',
      icon: Icons.people_rounded,
      screen: PendudukScreen(),
      group: 'Social',
      groupColor: bpsSocialColor,
      illustration: 'assets/new-illust-svg/Penduduk.svg',
    ),
    const CategoryItem(
      label: 'Pendidikan',
      shortLabel: 'Pendidikan',
      icon: Icons.school_rounded,
      screen: PendidikanScreen(),
      group: 'Social',
      groupColor: bpsSocialColor,
      illustration: 'assets/new-illust-svg/pendidikan.svg',
    ),
    const CategoryItem(
      label: 'Tenaga Kerja',
      shortLabel: 'Tenaga Kerja',
      icon: Icons.work_rounded,
      screen: TenagaKerjaScreen(),
      group: 'Social',
      groupColor: bpsSocialColor,
      illustration: 'assets/new-illust-svg/tenaga-kerja.svg',
    ),
    const CategoryItem(
      label: 'Kemiskinan',
      shortLabel: 'Kemiskinan',
      icon: Icons.volunteer_activism_rounded,
      screen: KemiskinanScreen(),
      group: 'Social',
      groupColor: bpsSocialColor,
      illustration: 'assets/new-illust-svg/Kemiskinan_2_outline.svg',
      illustrationScale: 1.3,
    ),
    const CategoryItem(
      label: 'Pengangguran',
      shortLabel: 'Pengangguran',
      icon: Icons.work_off_rounded,
      screen: PengangguranScreen(),
      group: 'Social',
      groupColor: bpsSocialColor,
      illustration: 'assets/new-illust-svg/Pengangguran.svg',
    ),
    // Development
    const CategoryItem(
      label: 'Indeks Pembangunan Manusia',
      shortLabel: 'IPM',
      icon: Icons.trending_up_rounded,
      screen: IpmScreen(),
      group: 'Development',
      groupColor: bpsDevelopmentColor,
      illustration: 'assets/new-illust-svg/IPM.svg',
    ),
    const CategoryItem(
      label: 'Indeks Pembangunan Gender',
      shortLabel: 'IPG',
      icon: Icons.balance_rounded,
      screen: IPGScreen(),
      group: 'Development',
      groupColor: bpsDevelopmentColor,
      illustration: 'assets/new-illust-svg/IPG_2_outline.svg',
    ),
    const CategoryItem(
      label: 'Indeks Ketimpangan Gender',
      shortLabel: 'IDG',
      icon: Icons.bar_chart_rounded,
      screen: IDGScreen(),
      group: 'Development',
      groupColor: bpsDevelopmentColor,
      illustration: 'assets/new-illust-svg/IKG_2_outline.svg',
    ),
    const CategoryItem(
      label: 'Sustainable Development Goals',
      shortLabel: 'SDGs',
      icon: Icons.public_rounded,
      screen: UserSDGsScreen(),
      group: 'Development',
      groupColor: bpsDevelopmentColor,
      illustration: 'assets/new-illust-svg/sdgs.svg',
    ),
  ];

  static final Map<String, Map<String, dynamic>> groupInfo = {
    'Economic': {
      'title': 'Indikator Ekonomi',
      'subtitle': '2 indikator tersedia',
      'icon': Icons.monetization_on_rounded,
      'color': bpsEconomicColor,
    },
    'Social': {
      'title': 'Indikator Sosial',
      'subtitle': '5 indikator tersedia',
      'icon': Icons.groups_rounded,
      'color': bpsSocialColor,
    },
    'Development': {
      'title': 'Indeks Pembangunan',
      'subtitle': '4 indeks tersedia',
      'icon': Icons.rocket_launch_rounded,
      'color': bpsDevelopmentColor,
    },
  };
}
