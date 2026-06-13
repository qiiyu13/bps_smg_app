import 'package:flutter_test/flutter_test.dart';
import 'package:lawang/number_format_utils.dart';

void main() {
  group('formatInteger', () {
    test('inserts dot thousands separators', () {
      expect(NumberFormatUtils.formatInteger(1500), '1.500');
      expect(NumberFormatUtils.formatInteger(1000000), '1.000.000');
    });

    test('handles zero and negatives', () {
      expect(NumberFormatUtils.formatInteger(0), '0');
      expect(NumberFormatUtils.formatInteger(-1500), '-1.500');
    });
  });

  group('formatDecimal', () {
    test('uses comma decimal and dot thousands', () {
      expect(NumberFormatUtils.formatDecimal(1234.56), '1.234,56');
    });

    test('trims trailing zeros', () {
      expect(NumberFormatUtils.formatDecimal(1000000.5), '1.000.000,5');
      expect(NumberFormatUtils.formatDecimal(10.0), '10');
    });

    test('negative values keep sign', () {
      expect(NumberFormatUtils.formatDecimal(-5.25), '-5,25');
    });

    test('NaN / Infinity guarded', () {
      expect(NumberFormatUtils.formatDecimal(double.nan), 'N/A');
      expect(NumberFormatUtils.formatDecimal(double.infinity), 'N/A');
    });
  });

  group('formatCompact', () {
    test('full number below 10k', () {
      expect(NumberFormatUtils.formatCompact(1500), '1.500');
      expect(NumberFormatUtils.formatCompact(0), '0');
    });

    test('Ribu range', () {
      expect(NumberFormatUtils.formatCompact(10000), '10 Ribu');
      expect(NumberFormatUtils.formatCompact(95800), '95,8 Ribu');
    });

    test('Juta range', () {
      expect(NumberFormatUtils.formatCompact(1500000), '1,5 Jt');
    });
  });

  group('formatPercentage', () {
    test('appends % with comma decimal', () {
      expect(NumberFormatUtils.formatPercentage(12.34), '12,34%');
    });
  });

  group('parseIndonesianNumber (round-trip-ish)', () {
    test('regular formatted string', () {
      expect(NumberFormatUtils.parseIndonesianNumber('1.234,56'), 1234.56);
    });

    test('Ribu / Jt suffixes', () {
      expect(NumberFormatUtils.parseIndonesianNumber('10 Ribu'), 10000);
      expect(NumberFormatUtils.parseIndonesianNumber('1,5 Jt'), 1500000);
    });

    test('empty string returns null', () {
      expect(NumberFormatUtils.parseIndonesianNumber(''), isNull);
    });
  });

  group('formatValue (dynamic dispatch)', () {
    test('null guarded', () {
      expect(NumberFormatUtils.formatValue(null), 'N/A');
    });

    test('int and double paths', () {
      expect(NumberFormatUtils.formatValue(1500), '1.500');
      expect(NumberFormatUtils.formatValue(12.34, isPercentage: true), '12,34%');
    });
  });
}
