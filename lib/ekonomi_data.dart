class EkonomiData {
  final String id;
  String tahun;
  String pertumbuhanEkonomi;
  String kontribusiPDRB;
  String sektorPerdagangan;
  String pdrbPerKapita;
  String vsJawaTengah;
  String vsNasional;
  List<DistrikData> distrikTertinggi;
  List<ChartDataPoint> semarangData;
  List<ChartDataPoint> jatengData;

  EkonomiData({
    required this.id,
    required this.tahun,
    required this.pertumbuhanEkonomi,
    required this.kontribusiPDRB,
    required this.sektorPerdagangan,
    required this.pdrbPerKapita,
    required this.vsJawaTengah,
    required this.vsNasional,
    required this.distrikTertinggi,
    required this.semarangData,
    required this.jatengData,
  });
}

class DistrikData {
  String nama;

  DistrikData({required this.nama});
}

class ChartDataPoint {
  final int year;
  final double value;

  ChartDataPoint({required this.year, required this.value});
}

// Singleton class untuk menyimpan data global
class EkonomiDataManager {
  static final EkonomiDataManager _instance = EkonomiDataManager._internal();

  factory EkonomiDataManager() {
    return _instance;
  }

  EkonomiDataManager._internal();

  // Data list yang bisa diakses dari mana saja
  // UPDATED: Data from BPS Kota Semarang 2024 (Feb 2025)
  List<EkonomiData> dataList = [
    EkonomiData(
      id: '1',
      tahun: '2024',
      pertumbuhanEkonomi: '5.62%',
      kontribusiPDRB: '14.2%',
      sektorPerdagangan: '13.97%',
      pdrbPerKapita: 'Rp 100.04 Juta',
      vsJawaTengah: 'Rank #1/35',
      vsNasional: 'TPT 5.82%',
      distrikTertinggi: [
        DistrikData(nama: 'Kecamatan Semarang Tengah'),
        DistrikData(nama: 'Kecamatan Semarang Utara'),
        DistrikData(nama: 'Kecamatan Tembalang'),
        DistrikData(nama: 'Kecamatan Pedurungan'),
        DistrikData(nama: 'Kecamatan Genuk'),
      ],
      semarangData: [
        ChartDataPoint(year: 2020, value: -1.85),
        ChartDataPoint(year: 2021, value: 5.16),
        ChartDataPoint(year: 2022, value: 5.73),
        ChartDataPoint(year: 2023, value: 5.79),
        ChartDataPoint(year: 2024, value: 5.62),
      ],
      jatengData: [
        ChartDataPoint(year: 2020, value: -1.50),
        ChartDataPoint(year: 2021, value: 4.80),
        ChartDataPoint(year: 2022, value: 5.20),
        ChartDataPoint(year: 2023, value: 5.10),
        ChartDataPoint(year: 2024, value: 5.05),
      ],
    ),
    EkonomiData(
      id: '2',
      tahun: '2023',
      pertumbuhanEkonomi: '5.79%',
      kontribusiPDRB: '14.1%',
      sektorPerdagangan: '13.09%',
      pdrbPerKapita: 'Rp 95.50 Juta',
      vsJawaTengah: 'Rank #1/35',
      vsNasional: 'TPT 5.99%',
      distrikTertinggi: [
        DistrikData(nama: 'Kecamatan Semarang Tengah'),
        DistrikData(nama: 'Kecamatan Tembalang'),
        DistrikData(nama: 'Kecamatan Semarang Utara'),
        DistrikData(nama: 'Kecamatan Banyumanik'),
        DistrikData(nama: 'Kecamatan Pedurungan'),
      ],
      semarangData: [
        ChartDataPoint(year: 2020, value: -1.85),
        ChartDataPoint(year: 2021, value: 5.16),
        ChartDataPoint(year: 2022, value: 5.73),
        ChartDataPoint(year: 2023, value: 5.79),
        ChartDataPoint(year: 2024, value: 5.62),
      ],
      jatengData: [
        ChartDataPoint(year: 2020, value: -1.50),
        ChartDataPoint(year: 2021, value: 4.80),
        ChartDataPoint(year: 2022, value: 5.20),
        ChartDataPoint(year: 2023, value: 5.10),
        ChartDataPoint(year: 2024, value: 5.05),
      ],
    ),
    EkonomiData(
      id: '3',
      tahun: '2022',
      pertumbuhanEkonomi: '5.73%',
      kontribusiPDRB: '14.0%',
      sektorPerdagangan: '13.20%',
      pdrbPerKapita: 'Rp 91.05 Juta',
      vsJawaTengah: 'Rank #1/35',
      vsNasional: 'TPT 7.60%',
      distrikTertinggi: [
        DistrikData(nama: 'Kecamatan Semarang Tengah'),
        DistrikData(nama: 'Kecamatan Tembalang'),
        DistrikData(nama: 'Kecamatan Semarang Utara'),
        DistrikData(nama: 'Kecamatan Pedurungan'),
        DistrikData(nama: 'Kecamatan Banyumanik'),
      ],
      semarangData: [
        ChartDataPoint(year: 2020, value: -1.85),
        ChartDataPoint(year: 2021, value: 5.16),
        ChartDataPoint(year: 2022, value: 5.73),
        ChartDataPoint(year: 2023, value: 5.79),
        ChartDataPoint(year: 2024, value: 5.62),
      ],
      jatengData: [
        ChartDataPoint(year: 2020, value: -1.50),
        ChartDataPoint(year: 2021, value: 4.80),
        ChartDataPoint(year: 2022, value: 5.20),
        ChartDataPoint(year: 2023, value: 5.10),
        ChartDataPoint(year: 2024, value: 5.05),
      ],
    ),
    EkonomiData(
      id: '4',
      tahun: '2021',
      pertumbuhanEkonomi: '5.16%',
      kontribusiPDRB: '13.8%',
      sektorPerdagangan: '13.50%',
      pdrbPerKapita: 'Rp 86.24 Juta',
      vsJawaTengah: 'Rank #1/35',
      vsNasional: 'TPT 9.54%',
      distrikTertinggi: [
        DistrikData(nama: 'Kecamatan Semarang Tengah'),
        DistrikData(nama: 'Kecamatan Tembalang'),
        DistrikData(nama: 'Kecamatan Semarang Utara'),
        DistrikData(nama: 'Kecamatan Pedurungan'),
        DistrikData(nama: 'Kecamatan Banyumanik'),
      ],
      semarangData: [
        ChartDataPoint(year: 2020, value: -1.85),
        ChartDataPoint(year: 2021, value: 5.16),
        ChartDataPoint(year: 2022, value: 5.73),
        ChartDataPoint(year: 2023, value: 5.79),
        ChartDataPoint(year: 2024, value: 5.62),
      ],
      jatengData: [
        ChartDataPoint(year: 2020, value: -1.50),
        ChartDataPoint(year: 2021, value: 4.80),
        ChartDataPoint(year: 2022, value: 5.20),
        ChartDataPoint(year: 2023, value: 5.10),
        ChartDataPoint(year: 2024, value: 5.05),
      ],
    ),
    EkonomiData(
      id: '5',
      tahun: '2020',
      pertumbuhanEkonomi: '-1.85%',
      kontribusiPDRB: '13.5%',
      sektorPerdagangan: '13.52%',
      pdrbPerKapita: 'Rp 82.02 Juta',
      vsJawaTengah: 'Rank #1/35',
      vsNasional: 'TPT 9.57%',
      distrikTertinggi: [
        DistrikData(nama: 'Kecamatan Semarang Tengah'),
        DistrikData(nama: 'Kecamatan Tembalang'),
        DistrikData(nama: 'Kecamatan Semarang Utara'),
        DistrikData(nama: 'Kecamatan Pedurungan'),
        DistrikData(nama: 'Kecamatan Banyumanik'),
      ],
      semarangData: [
        ChartDataPoint(year: 2020, value: -1.85),
        ChartDataPoint(year: 2021, value: 5.16),
        ChartDataPoint(year: 2022, value: 5.73),
        ChartDataPoint(year: 2023, value: 5.79),
        ChartDataPoint(year: 2024, value: 5.62),
      ],
      jatengData: [
        ChartDataPoint(year: 2020, value: -1.50),
        ChartDataPoint(year: 2021, value: 4.80),
        ChartDataPoint(year: 2022, value: 5.20),
        ChartDataPoint(year: 2023, value: 5.10),
        ChartDataPoint(year: 2024, value: 5.05),
      ],
    ),
  ];

  // Fungsi untuk mendapatkan data berdasarkan tahun
  EkonomiData? getDataByYear(String year) {
    try {
      return dataList.firstWhere((data) => data.tahun == year);
    } catch (e) {
      return null;
    }
  }

  // Fungsi untuk mendapatkan data berdasarkan ID
  EkonomiData? getDataById(String id) {
    try {
      return dataList.firstWhere((data) => data.id == id);
    } catch (e) {
      return null;
    }
  }

  // Fungsi untuk menambah data
  void addData(EkonomiData data) {
    dataList.add(data);
  }

  // Fungsi untuk update data
  void updateData(String id, EkonomiData updatedData) {
    final index = dataList.indexWhere((data) => data.id == id);
    if (index != -1) {
      dataList[index] = updatedData;
    }
  }

  // Fungsi untuk delete data
  void deleteData(String id) {
    dataList.removeWhere((data) => data.id == id);
  }

  // Fungsi untuk mendapatkan list tahun yang tersedia
  List<int> getAvailableYears() {
    return dataList.map((e) => int.parse(e.tahun)).toList()
      ..sort((a, b) => b.compareTo(a));
  }
}
