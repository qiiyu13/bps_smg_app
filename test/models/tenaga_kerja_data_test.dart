import 'package:flutter_test/flutter_test.dart';
import 'package:lawang/models/tenaga_kerja_data.dart';

void main() {
  group('LaborYear.fromJson', () {
    test('coerces numbers; int->double and num->int', () {
      final y = LaborYear.fromJson({
        'tpt': 5,
        'tingkatPartisipasi': 69.88,
        'bekerja': 922345,
        'pengangguran': 57123.0,
      });
      expect(y.tpt, 5.0);
      expect(y.tpt, isA<double>());
      expect(y.tingkatPartisipasi, 69.88);
      expect(y.bekerja, 922345);
      expect(y.pengangguran, 57123);
    });

    test('missing fields default to 0', () {
      final y = LaborYear.fromJson({});
      expect(y.tpt, 0.0);
      expect(y.bekerja, 0);
    });
  });

  group('LaborIndikator.fromJson', () {
    test('parses core fields; tpt/partisipasi default to 0 when absent', () {
      final i = LaborIndikator.fromJson(
          {'angkatanKerja': 935079, 'bkbk': 421567, 'tingkatKesempatan': 91.55});
      expect(i.angkatanKerja, 935079);
      expect(i.bkbk, 421567);
      expect(i.tingkatKesempatan, 91.55);
      expect(i.tpt, 0.0);
      expect(i.partisipasi, 0.0);
    });

    test('reads tpt/partisipasi when supplied by remote data', () {
      final i = LaborIndikator.fromJson(
          {'angkatanKerja': 1, 'bkbk': 1, 'tingkatKesempatan': 1, 'tpt': 5.8, 'partisipasi': 70.1});
      expect(i.tpt, 5.8);
      expect(i.partisipasi, 70.1);
    });
  });

  group('LaborJateng.fromJson', () {
    test('parses comparison figures', () {
      final j = LaborJateng.fromJson({'tpt': 6, 'tingkatPartisipasi': 68.5});
      expect(j.tpt, 6.0);
      expect(j.tingkatPartisipasi, 68.5);
    });
  });
}
