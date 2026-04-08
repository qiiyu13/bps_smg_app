class EkonomiData {
  final String id;
  String tahun;
  String pertumbuhanEkonomi;
  String kontribusiPDRB;
  String sektorIndustri;
  String sektorKonstruksi;
  String sektorPerdag;
  String pdrbPerKapita;
  String vsJawaTengah;
  String tpt;
  List<ChartDataPoint> semarangData;
  List<ChartDataPoint> jatengData;

  EkonomiData({
    required this.id,
    required this.tahun,
    required this.pertumbuhanEkonomi,
    required this.kontribusiPDRB,
    required this.sektorIndustri,
    required this.sektorKonstruksi,
    required this.sektorPerdag,
    required this.pdrbPerKapita,
    required this.vsJawaTengah,
    required this.tpt,
    required this.semarangData,
    required this.jatengData,
  });
}

class ChartDataPoint {
  final int year;
  final double value;

  ChartDataPoint({required this.year, required this.value});
}

class EkonomiDataManager {
  static final EkonomiDataManager _instance = EkonomiDataManager._internal();

  factory EkonomiDataManager() {
    return _instance;
  }

  EkonomiDataManager._internal();

  List<EkonomiData> dataList = [
    EkonomiData(
      id: '0',
      tahun: '2025',
      pertumbuhanEkonomi: '6.54%',
      kontribusiPDRB: '14.94%',
      sektorIndustri: '28.07%',
      sektorKonstruksi: '27.13%',
      sektorPerdag: '12.88%',
      pdrbPerKapita: 'Rp 167.236 Juta',
      vsJawaTengah: 'Rank #4/35',
      tpt: '5.65%',
      semarangData: [
        ChartDataPoint(year: 2020, value: -1.85),
        ChartDataPoint(year: 2021, value: 5.16),
        ChartDataPoint(year: 2022, value: 5.73),
        ChartDataPoint(year: 2023, value: 5.79),
        ChartDataPoint(year: 2024, value: 5.62),
        ChartDataPoint(year: 2025, value: 6.54),
      ],
      jatengData: [
        ChartDataPoint(year: 2020, value: -2.63),
        ChartDataPoint(year: 2021, value: 3.36),
        ChartDataPoint(year: 2022, value: 5.30),
        ChartDataPoint(year: 2023, value: 4.99),
        ChartDataPoint(year: 2024, value: 4.77),
        ChartDataPoint(year: 2025, value: 10.67),
      ],
    ),
    EkonomiData(
      id: '1',
      tahun: '2024',
      pertumbuhanEkonomi: '5.62%',
      kontribusiPDRB: '14.2%',
      sektorIndustri: '25.04%',
      sektorKonstruksi: '24.43%',
      sektorPerdag: '13.97%',
      pdrbPerKapita: 'Rp 100.04 Juta',
      vsJawaTengah: 'Rank #1/35',
      tpt: '5.82%',
      semarangData: [
        ChartDataPoint(year: 2020, value: -1.85),
        ChartDataPoint(year: 2021, value: 5.16),
        ChartDataPoint(year: 2022, value: 5.73),
        ChartDataPoint(year: 2023, value: 5.79),
        ChartDataPoint(year: 2024, value: 5.62),
        ChartDataPoint(year: 2025, value: 6.54),
      ],
      jatengData: [
        ChartDataPoint(year: 2020, value: -2.63),
        ChartDataPoint(year: 2021, value: 3.36),
        ChartDataPoint(year: 2022, value: 5.30),
        ChartDataPoint(year: 2023, value: 4.99),
        ChartDataPoint(year: 2024, value: 4.77),
        ChartDataPoint(year: 2025, value: 10.67),
      ],
    ),
    EkonomiData(
      id: '2',
      tahun: '2023',
      pertumbuhanEkonomi: '5.79%',
      kontribusiPDRB: '14.1%',
      sektorIndustri: '25.20%',
      sektorKonstruksi: '24.10%',
      sektorPerdag: '13.09%',
      pdrbPerKapita: 'Rp 95.50 Juta',
      vsJawaTengah: 'Rank #1/35',
      tpt: '5.99%',
      semarangData: [
        ChartDataPoint(year: 2020, value: -1.85),
        ChartDataPoint(year: 2021, value: 5.16),
        ChartDataPoint(year: 2022, value: 5.73),
        ChartDataPoint(year: 2023, value: 5.79),
        ChartDataPoint(year: 2025, value: 6.54),
      ],
      jatengData: [
        ChartDataPoint(year: 2020, value: -2.63),
        ChartDataPoint(year: 2021, value: 3.36),
        ChartDataPoint(year: 2022, value: 5.30),
        ChartDataPoint(year: 2023, value: 4.99),
        ChartDataPoint(year: 2025, value: 10.67),
      ],
    ),
    EkonomiData(
      id: '3',
      tahun: '2022',
      pertumbuhanEkonomi: '5.73%',
      kontribusiPDRB: '14.0%',
      sektorIndustri: '25.50%',
      sektorKonstruksi: '23.80%',
      sektorPerdag: '13.20%',
      pdrbPerKapita: 'Rp 91.05 Juta',
      vsJawaTengah: 'Rank #1/35',
      tpt: '7.60%',
      semarangData: [
        ChartDataPoint(year: 2020, value: -1.85),
        ChartDataPoint(year: 2021, value: 5.16),
        ChartDataPoint(year: 2022, value: 5.73),
        ChartDataPoint(year: 2025, value: 6.54),
      ],
      jatengData: [
        ChartDataPoint(year: 2020, value: -2.63),
        ChartDataPoint(year: 2021, value: 3.36),
        ChartDataPoint(year: 2022, value: 5.30),
        ChartDataPoint(year: 2025, value: 10.67),
      ],
    ),
    EkonomiData(
      id: '4',
      tahun: '2021',
      pertumbuhanEkonomi: '5.16%',
      kontribusiPDRB: '13.8%',
      sektorIndustri: '25.80%',
      sektorKonstruksi: '23.20%',
      sektorPerdag: '13.50%',
      pdrbPerKapita: 'Rp 86.24 Juta',
      vsJawaTengah: 'Rank #1/35',
      tpt: '9.54%',
      semarangData: [
        ChartDataPoint(year: 2020, value: -1.85),
        ChartDataPoint(year: 2021, value: 5.16),
        ChartDataPoint(year: 2025, value: 6.54),
      ],
      jatengData: [
        ChartDataPoint(year: 2020, value: -2.63),
        ChartDataPoint(year: 2021, value: 3.36),
        ChartDataPoint(year: 2025, value: 10.67),
      ],
    ),
    EkonomiData(
      id: '5',
      tahun: '2020',
      pertumbuhanEkonomi: '-1.85%',
      kontribusiPDRB: '13.5%',
      sektorIndustri: '26.10%',
      sektorKonstruksi: '22.50%',
      sektorPerdag: '13.52%',
      pdrbPerKapita: 'Rp 82.02 Juta',
      vsJawaTengah: 'Rank #1/35',
      tpt: '9.57%',
      semarangData: [
        ChartDataPoint(year: 2020, value: -1.85),
        ChartDataPoint(year: 2025, value: 6.54),
      ],
      jatengData: [
        ChartDataPoint(year: 2020, value: -2.63),
        ChartDataPoint(year: 2025, value: 10.67),
      ],
    ),
  ];

  EkonomiData? getDataByYear(String year) {
    try {
      return dataList.firstWhere((data) => data.tahun == year);
    } catch (e) {
      return null;
    }
  }

  EkonomiData? getDataById(String id) {
    try {
      return dataList.firstWhere((data) => data.id == id);
    } catch (e) {
      return null;
    }
  }

  void addData(EkonomiData data) {
    dataList.add(data);
  }

  void updateData(String id, EkonomiData updatedData) {
    final index = dataList.indexWhere((data) => data.id == id);
    if (index != -1) {
      dataList[index] = updatedData;
    }
  }

  void deleteData(String id) {
    dataList.removeWhere((data) => data.id == id);
  }

  List<int> getAvailableYears() {
    return dataList.map((e) => int.parse(e.tahun)).toList()
      ..sort((a, b) => a.compareTo(b));
  }
}
