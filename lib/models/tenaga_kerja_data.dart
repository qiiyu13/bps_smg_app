/// Typed models for the Tenaga Kerja (labor) screen.
///
/// Replaces `Map<int, Map<String, dynamic>>` state with typed objects.
/// fromJson coerces `num` (JSON whole numbers arrive as `int`) and defaults
/// missing fields, removing the dynamic-map read crash class.

double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;

/// Core yearly labor figures for Kota Semarang.
class LaborYear {
  final double tpt; // Tingkat Pengangguran Terbuka
  final double tingkatPartisipasi; // TPAK
  final int bekerja;
  final int pengangguran;

  const LaborYear({
    required this.tpt,
    required this.tingkatPartisipasi,
    required this.bekerja,
    required this.pengangguran,
  });

  factory LaborYear.fromJson(Map<String, dynamic> json) => LaborYear(
        tpt: _toDouble(json['tpt']),
        tingkatPartisipasi: _toDouble(json['tingkatPartisipasi']),
        bekerja: _toInt(json['bekerja']),
        pengangguran: _toInt(json['pengangguran']),
      );

  Map<String, dynamic> toJson() => {
        'tpt': tpt,
        'tingkatPartisipasi': tingkatPartisipasi,
        'bekerja': bekerja,
        'pengangguran': pengangguran,
      };
}

/// Derived labor indicators. `tpt` / `partisipasi` may be supplied by the
/// remote data set even though the bundled defaults omit them (they then
/// default to 0.0, preserving the previous runtime behavior).
class LaborIndikator {
  final int angkatanKerja;
  final int bkbk; // Bukan angkatan kerja
  final double tingkatKesempatan;
  final double tpt;
  final double partisipasi;

  const LaborIndikator({
    required this.angkatanKerja,
    required this.bkbk,
    required this.tingkatKesempatan,
    this.tpt = 0.0,
    this.partisipasi = 0.0,
  });

  factory LaborIndikator.fromJson(Map<String, dynamic> json) => LaborIndikator(
        angkatanKerja: _toInt(json['angkatanKerja']),
        bkbk: _toInt(json['bkbk']),
        tingkatKesempatan: _toDouble(json['tingkatKesempatan']),
        tpt: _toDouble(json['tpt']),
        partisipasi: _toDouble(json['partisipasi']),
      );

  Map<String, dynamic> toJson() => {
        'angkatanKerja': angkatanKerja,
        'bkbk': bkbk,
        'tingkatKesempatan': tingkatKesempatan,
        'tpt': tpt,
        'partisipasi': partisipasi,
      };
}

/// Jawa Tengah comparison figures.
class LaborJateng {
  final double tpt;
  final double tingkatPartisipasi;

  const LaborJateng({required this.tpt, required this.tingkatPartisipasi});

  factory LaborJateng.fromJson(Map<String, dynamic> json) => LaborJateng(
        tpt: _toDouble(json['tpt']),
        tingkatPartisipasi: _toDouble(json['tingkatPartisipasi']),
      );

  Map<String, dynamic> toJson() => {
        'tpt': tpt,
        'tingkatPartisipasi': tingkatPartisipasi,
      };
}
