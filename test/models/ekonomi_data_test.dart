import 'package:flutter_test/flutter_test.dart';
import 'package:lawang/ekonomi_data.dart';

void main() {
  group('ChartDataPoint.fromJson', () {
    test('parses double value', () {
      final p = ChartDataPoint.fromJson({'year': 2020, 'value': 5.16});
      expect(p.year, 2020);
      expect(p.value, 5.16);
    });

    // Regression: JSON whole numbers arrive as int; value must still become
    // double without throwing (this was the original crash class).
    test('coerces int value to double', () {
      final p = ChartDataPoint.fromJson({'year': 2021, 'value': 5});
      expect(p.value, 5.0);
      expect(p.value, isA<double>());
    });
  });

  group('EkonomiData.fromJson', () {
    test('defaults missing fields to empty string / empty list', () {
      final d = EkonomiData.fromJson({});
      expect(d.id, '');
      expect(d.tahun, '');
      expect(d.semarangData, isEmpty);
      expect(d.jatengData, isEmpty);
    });

    test('stringifies non-string scalar fields', () {
      final d = EkonomiData.fromJson({'id': 1, 'tahun': 2024});
      expect(d.id, '1');
      expect(d.tahun, '2024');
    });

    test('parses nested chart point lists', () {
      final d = EkonomiData.fromJson({
        'semarangData': [
          {'year': 2020, 'value': 5},
          {'year': 2021, 'value': 5.5},
        ],
      });
      expect(d.semarangData.length, 2);
      expect(d.semarangData.first.value, 5.0);
      expect(d.semarangData.last.value, 5.5);
    });
  });
}
