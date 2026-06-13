/// Typed models for the IPM (Indeks Pembangunan Manusia) screen.
///
/// Replaces the previous `Map<int, Map<String, dynamic>>` shape so screen
/// code reads typed fields instead of dynamic map lookups. All numeric reads
/// are coerced from `num` (JSON whole numbers arrive as `int`) and default to
/// 0.0 when missing, removing the runtime `TypeError` crash class.

double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;

/// One year of core IPM indicators.
class IpmYear {
  final double uhh; // Umur Harapan Hidup
  final double rls; // Rata-rata Lama Sekolah
  final double hls; // Harapan Lama Sekolah
  final double pengeluaran; // Pengeluaran per kapita
  final double ipm; // Composite IPM score

  const IpmYear({
    required this.uhh,
    required this.rls,
    required this.hls,
    required this.pengeluaran,
    required this.ipm,
  });

  factory IpmYear.fromJson(Map<String, dynamic> json) => IpmYear(
        uhh: _toDouble(json['uhh']),
        rls: _toDouble(json['rls']),
        hls: _toDouble(json['hls']),
        pengeluaran: _toDouble(json['pengeluaran']),
        ipm: _toDouble(json['ipm']),
      );

  Map<String, dynamic> toJson() => {
        'uhh': uhh,
        'rls': rls,
        'hls': hls,
        'pengeluaran': pengeluaran,
        'ipm': ipm,
      };
}

/// IPM comparison across National / Provincial (Jateng) / City (Semarang).
class IpmKomponen {
  final double ipmNasional;
  final double ipmJateng;
  final double ipmSemarang;

  const IpmKomponen({
    required this.ipmNasional,
    required this.ipmJateng,
    required this.ipmSemarang,
  });

  factory IpmKomponen.fromJson(Map<String, dynamic> json) => IpmKomponen(
        ipmNasional: _toDouble(json['ipmNasional']),
        ipmJateng: _toDouble(json['ipmJateng']),
        ipmSemarang: _toDouble(json['ipmSemarang']),
      );

  Map<String, dynamic> toJson() => {
        'ipmNasional': ipmNasional,
        'ipmJateng': ipmJateng,
        'ipmSemarang': ipmSemarang,
      };
}
