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
  List<EkonomiData> dataList = [
    EkonomiData(
      id: '1',
      tahun: '2024',
      pertumbuhanEkonomi: '5.31%',
      kontribusiPDRB: '9.8%',
      sektorPerdagangan: '28.5%',
      pdrbPerKapita: 'Rp 85.2 Juta',
      vsJawaTengah: '142%',
      vsNasional: '125%',
      distrikTertinggi: [
        DistrikData(nama: 'Kecamatan Semarang Tengah'),
        DistrikData(nama: 'Kecamatan Semarang Utara'),
        DistrikData(nama: 'Kecamatan Tembalang'),
        DistrikData(nama: 'Kecamatan Pedurungan'),
        DistrikData(nama: 'Kecamatan Genuk'),
      ],
      semarangData: [
        ChartDataPoint(year: 2020, value: 10),
        ChartDataPoint(year: 2021, value: 15),
        ChartDataPoint(year: 2022, value: 30),
        ChartDataPoint(year: 2023, value: 40),
        ChartDataPoint(year: 2024, value: 50),
      ],
      jatengData: [
        ChartDataPoint(year: 2020, value: 8),
        ChartDataPoint(year: 2021, value: 12),
        ChartDataPoint(year: 2022, value: 20),
        ChartDataPoint(year: 2023, value: 25),
        ChartDataPoint(year: 2024, value: 40),
      ],
    ),
    EkonomiData(
      id: '2',
      tahun: '2023',
      pertumbuhanEkonomi: '5.05%',
      kontribusiPDRB: '9.5%',
      sektorPerdagangan: '27.8%',
      pdrbPerKapita: 'Rp 81.5 Juta',
      vsJawaTengah: '138%',
      vsNasional: '122%',
      distrikTertinggi: [
        DistrikData(nama: 'Kecamatan Semarang Tengah'),
        DistrikData(nama: 'Kecamatan Tembalang'),
        DistrikData(nama: 'Kecamatan Semarang Utara'),
        DistrikData(nama: 'Kecamatan Banyumanik'),
        DistrikData(nama: 'Kecamatan Pedurungan'),
      ],
      semarangData: [
        ChartDataPoint(year: 2020, value: 8),
        ChartDataPoint(year: 2021, value: 12),
        ChartDataPoint(year: 2022, value: 25),
        ChartDataPoint(year: 2023, value: 35),
        ChartDataPoint(year: 2024, value: 45),
      ],
      jatengData: [
        ChartDataPoint(year: 2020, value: 7),
        ChartDataPoint(year: 2021, value: 10),
        ChartDataPoint(year: 2022, value: 18),
        ChartDataPoint(year: 2023, value: 22),
        ChartDataPoint(year: 2024, value: 35),
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
    return dataList.map((e) => int.parse(e.tahun)).toList()..sort((a, b) => b.compareTo(a));
  }
}