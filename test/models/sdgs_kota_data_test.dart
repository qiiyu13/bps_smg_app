import 'package:flutter_test/flutter_test.dart';
import 'package:lawang/sdgs_data_service.dart';

void main() {
  group('KotaData.fromJson', () {
    test('parses year->value maps, coercing int values to double', () {
      final k = KotaData.fromJson({
        'id': '1',
        'nama': 'Kota Semarang',
        'cuciTangan': {'2020': 80, '2021': 75.5},
      });
      expect(k.id, '1');
      expect(k.nama, 'Kota Semarang');
      expect(k.samitasilayak[2020], 80.0);
      expect(k.samitasilayak[2021], 75.5);
    });

    test('stringifies non-string id/nama', () {
      final k = KotaData.fromJson({'id': 42, 'nama': 99});
      expect(k.id, '42');
      expect(k.nama, '99');
    });

    test('missing maps default to empty', () {
      final k = KotaData.fromJson({'id': '1', 'nama': 'X'});
      expect(k.samitasilayak, isEmpty);
      expect(k.apk, isEmpty);
    });
  });

  group('toJson <-> fromJson round-trip', () {
    test('preserves indicator maps', () {
      final original = KotaData(
        id: 'kota-1',
        nama: 'Kota Semarang',
        samitasilayak: {2020: 80.0, 2021: 75.5},
        tikRemaja: {2020: 90.0},
        tikDewasa: {2020: 60.0},
        aktaLahir: {2022: 86.0},
        apm: {2022: 100.0},
        apk: {2022: 77.0},
      );

      final restored = KotaData.fromJson(original.toJson());

      expect(restored.id, 'kota-1');
      expect(restored.nama, 'Kota Semarang');
      expect(restored.samitasilayak, original.samitasilayak);
      expect(restored.tikRemaja, original.tikRemaja);
      expect(restored.apk, original.apk);
    });
  });
}
