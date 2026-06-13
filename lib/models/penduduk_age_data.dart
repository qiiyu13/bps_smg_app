/// Typed model for the population age-distribution section of the penduduk
/// screen. Replaces the nested `Map<int, Map<String, dynamic>>` shape.

double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;

/// One age bracket: absolute count + share of total population.
class AgeGroup {
  final int total;
  final double percentage;
  const AgeGroup({required this.total, required this.percentage});
}

/// Age distribution for a single year across the three brackets.
class AgeDistribution {
  final AgeGroup usiaMuda; // 0-14
  final AgeGroup usiaProduktif; // 15-64
  final AgeGroup usiaTua; // 65+

  const AgeDistribution({
    required this.usiaMuda,
    required this.usiaProduktif,
    required this.usiaTua,
  });

  int get totalPopulation =>
      usiaMuda.total + usiaProduktif.total + usiaTua.total;

  /// Lookup a bracket by its string key (used by chart/legend builders).
  AgeGroup byKey(String key) {
    switch (key) {
      case 'usiaMuda':
        return usiaMuda;
      case 'usiaProduktif':
        return usiaProduktif;
      case 'usiaTua':
        return usiaTua;
      default:
        return const AgeGroup(total: 0, percentage: 0.0);
    }
  }

  /// Build from the flat remote/section format where totals and percentages
  /// are sibling keys (e.g. `usiaMuda` + `usiaMudaPercentage`).
  factory AgeDistribution.fromRaw(Map<String, dynamic> j) => AgeDistribution(
        usiaMuda: AgeGroup(
            total: _toInt(j['usiaMuda']),
            percentage: _toDouble(j['usiaMudaPercentage'])),
        usiaProduktif: AgeGroup(
            total: _toInt(j['usiaProduktif']),
            percentage: _toDouble(j['usiaProduktifPercentage'])),
        usiaTua: AgeGroup(
            total: _toInt(j['usiaTua']),
            percentage: _toDouble(j['usiaTuaPercentage'])),
      );
}
