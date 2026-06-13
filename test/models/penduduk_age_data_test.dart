import 'package:flutter_test/flutter_test.dart';
import 'package:lawang/models/penduduk_age_data.dart';

void main() {
  group('AgeDistribution.fromRaw', () {
    final raw = {
      'usiaMuda': 367018,
      'usiaMudaPercentage': 22.20,
      'usiaProduktif': 1182010,
      'usiaProduktifPercentage': 71.48,
      'usiaTua': 104496,
      'usiaTuaPercentage': 6.32,
    };

    test('maps flat keys into bracket groups', () {
      final a = AgeDistribution.fromRaw(raw);
      expect(a.usiaMuda.total, 367018);
      expect(a.usiaMuda.percentage, 22.20);
      expect(a.usiaProduktif.total, 1182010);
      expect(a.usiaTua.percentage, 6.32);
    });

    test('totalPopulation is the sum of bracket totals', () {
      final a = AgeDistribution.fromRaw(raw);
      expect(a.totalPopulation, 367018 + 1182010 + 104496);
    });

    test('missing fields default to 0', () {
      final a = AgeDistribution.fromRaw({});
      expect(a.usiaMuda.total, 0);
      expect(a.usiaTua.percentage, 0.0);
      expect(a.totalPopulation, 0);
    });
  });

  group('byKey', () {
    const a = AgeDistribution(
      usiaMuda: AgeGroup(total: 1, percentage: 10),
      usiaProduktif: AgeGroup(total: 2, percentage: 20),
      usiaTua: AgeGroup(total: 3, percentage: 30),
    );

    test('returns the matching bracket', () {
      expect(a.byKey('usiaMuda').total, 1);
      expect(a.byKey('usiaProduktif').percentage, 20);
      expect(a.byKey('usiaTua').total, 3);
    });

    test('unknown key returns empty group', () {
      expect(a.byKey('nope').total, 0);
    });
  });
}
