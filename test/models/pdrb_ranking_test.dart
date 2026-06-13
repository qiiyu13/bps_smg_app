import 'package:flutter_test/flutter_test.dart';
import 'package:lawang/models/pdrb_ranking.dart';

void main() {
  group('PDRBRanking.fromCsv', () {
    test('parses a row with mixed cell types', () {
      final r = PDRBRanking.fromCsv([1, 'Kota Semarang', '123456.78', 1]);
      expect(r.originalNo, 1);
      expect(r.nama, 'Kota Semarang');
      expect(r.pdrb, 123456.78);
      expect(r.rank, 1);
    });
  });

  group('derived getters', () {
    test('isKotaSemarang', () {
      expect(PDRBRanking.fromCsv([1, 'Kota Semarang', '10', 1]).isKotaSemarang,
          isTrue);
      expect(PDRBRanking.fromCsv([2, 'Kab. Demak', '10', 5]).isKotaSemarang,
          isFalse);
    });

    test('isTop3 boundary', () {
      expect(PDRBRanking.fromCsv([1, 'X', '10', 3]).isTop3, isTrue);
      expect(PDRBRanking.fromCsv([1, 'X', '10', 4]).isTop3, isFalse);
    });

    test('formattedPdrb uses Indonesian decimal', () {
      final r = PDRBRanking.fromCsv([1, 'X', '1234.5', 1]);
      expect(r.formattedPdrb, 'Rp 1.234,5 Milyar');
    });
  });
}
