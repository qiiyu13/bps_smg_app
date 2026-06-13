import 'package:flutter_test/flutter_test.dart';
import 'package:lawang/models/ipm_data.dart';

void main() {
  group('IpmYear.fromJson', () {
    test('parses all fields as double', () {
      final y = IpmYear.fromJson({
        'uhh': 78.23,
        'rls': 11.05,
        'hls': 15.57,
        'pengeluaran': 16990,
        'ipm': 85.24,
      });
      expect(y.uhh, 78.23);
      expect(y.rls, 11.05);
      expect(y.hls, 15.57);
      // int in JSON coerced to double (the original crash class)
      expect(y.pengeluaran, 16990.0);
      expect(y.pengeluaran, isA<double>());
      expect(y.ipm, 85.24);
    });

    test('missing fields default to 0.0 instead of throwing', () {
      final y = IpmYear.fromJson({'ipm': 85.0});
      expect(y.ipm, 85.0);
      expect(y.uhh, 0.0);
      expect(y.pengeluaran, 0.0);
    });

    test('toJson round-trips', () {
      const y = IpmYear(
          uhh: 1, rls: 2, hls: 3, pengeluaran: 4, ipm: 5);
      expect(IpmYear.fromJson(y.toJson()).ipm, 5.0);
    });
  });

  group('IpmKomponen.fromJson', () {
    test('parses national/provincial/city values', () {
      final k = IpmKomponen.fromJson(
          {'ipmNasional': 75, 'ipmJateng': 73.87, 'ipmSemarang': 85.24});
      expect(k.ipmNasional, 75.0);
      expect(k.ipmJateng, 73.87);
      expect(k.ipmSemarang, 85.24);
    });

    test('missing fields default to 0.0', () {
      final k = IpmKomponen.fromJson({});
      expect(k.ipmNasional, 0.0);
      expect(k.ipmJateng, 0.0);
      expect(k.ipmSemarang, 0.0);
    });
  });
}
