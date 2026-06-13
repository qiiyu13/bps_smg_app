import 'services/github_data_service.dart';

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

  factory EkonomiData.fromJson(Map<String, dynamic> json) {
    return EkonomiData(
      id: json['id']?.toString() ?? '',
      tahun: json['tahun']?.toString() ?? '',
      pertumbuhanEkonomi: json['pertumbuhanEkonomi']?.toString() ?? '',
      kontribusiPDRB: json['kontribusiPDRB']?.toString() ?? '',
      sektorIndustri: json['sektorIndustri']?.toString() ?? '',
      sektorKonstruksi: json['sektorKonstruksi']?.toString() ?? '',
      sektorPerdag: json['sektorPerdag']?.toString() ?? '',
      pdrbPerKapita: json['pdrbPerKapita']?.toString() ?? '',
      vsJawaTengah: json['vsJawaTengah']?.toString() ?? '',
      tpt: json['tpt']?.toString() ?? '',
      semarangData: (json['semarangData'] as List<dynamic>?)
              ?.map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      jatengData: (json['jatengData'] as List<dynamic>?)
              ?.map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ChartDataPoint {
  final int year;
  final double value;

  const ChartDataPoint({required this.year, required this.value});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      year: (json['year'] as num).toInt(),
      value: (json['value'] as num).toDouble(),
    );
  }
}

class EkonomiDataManager {
  static final EkonomiDataManager _instance = EkonomiDataManager._internal();

  factory EkonomiDataManager() {
    return _instance;
  }

  EkonomiDataManager._internal();

  // Semarang growth rates (Pertumbuhan Ekonomi %)
  // Source: BPS - PDRB ADHK Kabupaten/Kota di Jawa Tengah (6 Maret 2026)
  // 2020: -1.85%, 2021: 5.16%, 2022: 5.73%, 2023: 5.77% (dihitung), 2024: 5.68%, 2025: 6.49%
  static const List<ChartDataPoint> _semarangChartData = [
    ChartDataPoint(year: 2020, value: -1.85),
    ChartDataPoint(year: 2021, value: 5.16),
    ChartDataPoint(year: 2022, value: 5.73),
    ChartDataPoint(year: 2023, value: 5.77),
    ChartDataPoint(year: 2024, value: 5.68),
    ChartDataPoint(year: 2025, value: 6.49),
  ];

  // Jawa Tengah growth rates (Pertumbuhan Ekonomi %)
  // Source: BPS - PDRB ADHK Kabupaten/Kota di Jawa Tengah (6 Maret 2026)
  // 2020: -2.63%, 2021: 3.36%, 2022: 5.40%, 2023: 4.97% (dihitung), 2024: 4.95%, 2025: 5.37%
  static const List<ChartDataPoint> _jatengChartData = [
    ChartDataPoint(year: 2020, value: -2.63),
    ChartDataPoint(year: 2021, value: 3.36),
    ChartDataPoint(year: 2022, value: 5.40),
    ChartDataPoint(year: 2023, value: 4.97),
    ChartDataPoint(year: 2024, value: 4.95),
    ChartDataPoint(year: 2025, value: 5.37),
  ];

  List<EkonomiData> dataList = [
    // ─── 2025 ── Sumber: BPS, 6 Maret 2026 ────────────────────────────────
    // Kota Semarang: PDRB ADHK = 182.122,11 Milyar Rupiah
    // Pertumbuhan Ekonomi = 6,49% | Kontribusi PDRB Jateng = 14,94%
    // Sektor Industri = 28,07% | Konstruksi = 27,13% | Perdagangan = 12,88%
    // PDRB per Kapita = Rp 167.236 Ribu = Rp 167,24 Juta
    // TPT = 5,65%
    EkonomiData(
      id: '0',
      tahun: '2025',
      pertumbuhanEkonomi: '6,49%',
      kontribusiPDRB: '14,94%',
      sektorIndustri: '28,07%',
      sektorKonstruksi: '27,13%',
      sektorPerdag: '12,88%',
      pdrbPerKapita: 'Rp 167,24 Juta',
      vsJawaTengah: 'Rank #1/35',
      tpt: '5,65%',
      semarangData: _semarangChartData,
      jatengData: _jatengChartData,
    ),
    // ─── 2024 ── Sumber: BPS, 6 Maret 2026 ────────────────────────────────
    // Kota Semarang: PDRB ADHK = 171.014,75 Milyar Rupiah
    // Pertumbuhan Ekonomi = 5,68% | Kontribusi PDRB Jateng = 14,78%
    // Sektor Industri = 28,39% | Konstruksi = 26,84% | Perdagangan = 12,96%
    // PDRB per Kapita = Rp 156.607 Ribu = Rp 156,61 Juta
    // TPT = 5,82%
    EkonomiData(
      id: '1',
      tahun: '2024',
      pertumbuhanEkonomi: '5,68%',
      kontribusiPDRB: '14,78%',
      sektorIndustri: '28,39%',
      sektorKonstruksi: '26,84%',
      sektorPerdag: '12,96%',
      pdrbPerKapita: 'Rp 156,61 Juta',
      vsJawaTengah: 'Rank #1/35',
      tpt: '5,82%',
      semarangData: _semarangChartData,
      jatengData: _jatengChartData,
    ),
    // ─── 2023 ── Sumber: BPS, 6 Maret 2026 ────────────────────────────────
    // Kota Semarang: PDRB ADHK = 161.815,79 Milyar Rupiah
    // Pertumbuhan Ekonomi = 5,77% (dihitung) | Kontribusi PDRB Jateng = 14,68%
    // Sektor Industri = 28,07% | Konstruksi = 26,43% | Perdagangan = 13,09%
    // PDRB per Kapita = Rp 146.839 Ribu = Rp 146,84 Juta
    // TPT = 5,99%
    EkonomiData(
      id: '2',
      tahun: '2023',
      pertumbuhanEkonomi: '5,77%',
      kontribusiPDRB: '14,68%',
      sektorIndustri: '28,07%',
      sektorKonstruksi: '26,43%',
      sektorPerdag: '13,09%',
      pdrbPerKapita: 'Rp 146,84 Juta',
      vsJawaTengah: 'Rank #1/35',
      tpt: '5,99%',
      semarangData: _semarangChartData,
      jatengData: _jatengChartData,
    ),
    // ─── 2022 ── Sumber: BPS, 6 Maret 2026 ────────────────────────────────
    // Kota Semarang: PDRB ADHK = 152.995,41 Milyar Rupiah
    // Pertumbuhan Ekonomi = 5,73% | Kontribusi PDRB Jateng = 14,57%
    // Sektor Industri = 28,87% | Konstruksi = 26,33% | Perdagangan = 13,20%
    // PDRB per Kapita = Rp 135.328 Ribu = Rp 135,33 Juta
    // TPT = 7,60%
    EkonomiData(
      id: '3',
      tahun: '2022',
      pertumbuhanEkonomi: '5,73%',
      kontribusiPDRB: '14,57%',
      sektorIndustri: '28,87%',
      sektorKonstruksi: '26,33%',
      sektorPerdag: '13,20%',
      pdrbPerKapita: 'Rp 135,33 Juta',
      vsJawaTengah: 'Rank #1/35',
      tpt: '7,60%',
      semarangData: _semarangChartData,
      jatengData: _jatengChartData,
    ),
    // ─── 2021 ── Sumber: BPS, 6 Maret 2026 ────────────────────────────────
    // Kota Semarang: PDRB ADHK = 144.704,57 Milyar Rupiah
    // Pertumbuhan Ekonomi = 5,16% | Kontribusi PDRB Jateng = 14,52%
    // Sektor Industri/Konstruksi/Perdagangan = '-' (data tidak tersedia di CSV)
    // PDRB per Kapita = Rp 123.037 Ribu = Rp 123,04 Juta
    // TPT = 9,54%
    EkonomiData(
      id: '4',
      tahun: '2021',
      pertumbuhanEkonomi: '5,16%',
      kontribusiPDRB: '14,52%',
      sektorIndustri: '-',
      sektorKonstruksi: '-',
      sektorPerdag: '-',
      pdrbPerKapita: 'Rp 123,04 Juta',
      vsJawaTengah: 'Rank #1/35',
      tpt: '9,54%',
      semarangData: _semarangChartData,
      jatengData: _jatengChartData,
    ),
    // ─── 2020 ── Sumber: BPS, 6 Maret 2026 ────────────────────────────────
    // Kota Semarang: PDRB ADHK = 137.601,98 Milyar Rupiah
    // Pertumbuhan Ekonomi = -1,85% | Kontribusi PDRB Jateng = 14,27%
    // Sektor Industri/Konstruksi/Perdagangan = '-' (data tidak tersedia di CSV)
    // PDRB per Kapita = Rp 114.189 Ribu = Rp 114,19 Juta
    // TPT = 9,57%
    EkonomiData(
      id: '5',
      tahun: '2020',
      pertumbuhanEkonomi: '-1,85%',
      kontribusiPDRB: '14,27%',
      sektorIndustri: '-',
      sektorKonstruksi: '-',
      sektorPerdag: '-',
      pdrbPerKapita: 'Rp 114,19 Juta',
      vsJawaTengah: 'Rank #1/35',
      tpt: '9,57%',
      semarangData: _semarangChartData,
      jatengData: _jatengChartData,
    ),
  ];

  void loadFromGitHub() {
    final githubData = GitHubDataService.getData('ekonomi');
    if (githubData == null) return;
    final ekonomiList = githubData['ekonomiData'] as List<dynamic>?;
    if (ekonomiList == null) return;
    final parsed = ekonomiList
        .map((e) => EkonomiData.fromJson(e as Map<String, dynamic>))
        .toList();
    if (parsed.isNotEmpty) {
      dataList = parsed;
    }
  }

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
