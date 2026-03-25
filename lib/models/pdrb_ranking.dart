import '../number_format_utils.dart';

class PDRBRanking {
  final int originalNo;
  final String nama;
  final double pdrb;
  final int rank;

  PDRBRanking({
    required this.originalNo,
    required this.nama,
    required this.pdrb,
    required this.rank,
  });

  factory PDRBRanking.fromCsv(List<dynamic> row) {
    return PDRBRanking(
      originalNo: int.parse(row[0].toString()),
      nama: row[1].toString(),
      pdrb: double.parse(row[2].toString()),
      rank: int.parse(row[3].toString()),
    );
  }

  bool get isKotaSemarang => nama == 'Kota Semarang';
  bool get isTop3 => rank <= 3;
  String get formattedPdrb =>
      'Rp ${NumberFormatUtils.formatDecimal(pdrb, decimalPlaces: 2)} Milyar';
}
