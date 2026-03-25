import 'package:flutter/material.dart';
import 'responsive_sizing.dart';

// Status enum for conclusion
enum KesimpulanStatus {
  baik, // 🟢 Green - Positive
  perhatian, // 🟡 Yellow - Caution
  perbaikan, // 🔴 Red - Needs improvement
}

// Extension to get color and icon
extension KesimpulanStatusExtension on KesimpulanStatus {
  Color get color {
    switch (this) {
      case KesimpulanStatus.baik:
        return const Color(0xFF4CAF50); // Green
      case KesimpulanStatus.perhatian:
        return const Color(0xFFFFA726); // Orange/Yellow
      case KesimpulanStatus.perbaikan:
        return const Color(0xFFEF5350); // Red
    }
  }

  IconData get icon {
    switch (this) {
      case KesimpulanStatus.baik:
        return Icons.trending_up;
      case KesimpulanStatus.perhatian:
        return Icons.trending_flat;
      case KesimpulanStatus.perbaikan:
        return Icons.trending_down;
    }
  }

  String get label {
    switch (this) {
      case KesimpulanStatus.baik:
        return 'Baik';
      case KesimpulanStatus.perhatian:
        return 'Perlu Perhatian';
      case KesimpulanStatus.perbaikan:
        return 'Perlu Perbaikan';
    }
  }
}

class KesimpulanWidget extends StatelessWidget {
  final String title;
  final String conclusion;
  final KesimpulanStatus status;
  final ResponsiveSizing sizing;
  final bool isSmallScreen;
  final List<String>? additionalPoints;

  const KesimpulanWidget({
    super.key,
    required this.title,
    required this.conclusion,
    required this.status,
    required this.sizing,
    required this.isSmallScreen,
    this.additionalPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen
          ? sizing.statsCardPadding - 4
          : sizing.statsCardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: status.color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and status
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: status.color,
                  size: isSmallScreen ? 18 : 22,
                ),
              ),
              SizedBox(width: sizing.itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KESIMPULAN',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? sizing.groupTitleSize - 2
                            : sizing.groupTitleSize,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF333333),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: const Color(0xFF808080),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: status.color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      status.icon,
                      color: status.color,
                      size: isSmallScreen ? 12 : 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      status.label,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 11,
                        fontWeight: FontWeight.w700,
                        color: status.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 14 : 18),
          // Main conclusion text
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
            decoration: BoxDecoration(
              color: status.color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: status.color.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.format_quote,
                    color: status.color.withOpacity(0.6),
                    size: isSmallScreen ? 16 : 18,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    conclusion,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: const Color(0xFF333333),
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Additional points if any
          if (additionalPoints != null && additionalPoints!.isNotEmpty) ...[
            SizedBox(height: isSmallScreen ? 12 : 14),
            ...additionalPoints!.map((point) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: isSmallScreen ? 6 : 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: status.color.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 13,
                          color: const Color(0xFF666666),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}

// Helper class to generate conclusions for different indicators
class KesimpulanGenerator {
  // Kemiskinan conclusion
  static Map<String, dynamic> generateKemiskinanConclusion({
    required int latestYear,
    required int firstYear,
    required double latestPercentage,
    required double firstPercentage,
    required String latestPopulation,
    String? urbanPercentage,
    String? ruralPercentage,
  }) {
    final change = latestPercentage - firstPercentage;
    final isDecreasing = change < 0;
    final absChange = change.abs();

    KesimpulanStatus status;
    String statusText;

    if (isDecreasing && absChange > 0.5) {
      status = KesimpulanStatus.baik;
      statusText = 'penurunan signifikan';
    } else if (isDecreasing) {
      status = KesimpulanStatus.baik;
      statusText = 'penurunan';
    } else if (change > 0.5) {
      status = KesimpulanStatus.perbaikan;
      statusText = 'peningkatan yang perlu diwaspadai';
    } else {
      status = KesimpulanStatus.perhatian;
      statusText = 'tren yang perlu pemantauan';
    }

    String conclusion;
    if (isDecreasing) {
      conclusion =
          'Tahun $latestYear, persentase kemiskinan Kota Semarang mencapai ${latestPercentage.toStringAsFixed(2)}%, menunjukkan $statusText sebesar ${absChange.toStringAsFixed(2)} poin persentase dibandingkan tahun $firstYear. Tren menurun yang konsisten ini mencerminkan efektivitas program penanggulangan kemiskinan.';
    } else {
      conclusion =
          'Tahun $latestYear, persentase kemiskinan Kota Semarang mencapai ${latestPercentage.toStringAsFixed(2)}%, mengalami $statusText sebesar ${absChange.toStringAsFixed(2)} poin persentase dibandingkan tahun $firstYear. Kondisi ini memerlukan perhatian khusus dan intervensi kebijakan yang lebih intensif.';
    }

    List<String> additionalPoints = [];
    if (urbanPercentage != null && ruralPercentage != null) {
      additionalPoints.add(
          'Terdapat perbedaan tingkat kemiskinan antara wilayah kota dan desa yang perlu mendapatkan penanganan berbeda.');
    }

    return {
      'status': status,
      'conclusion': conclusion,
      'additionalPoints': additionalPoints,
    };
  }

  // IPM conclusion
  static Map<String, dynamic> generateIPMConclusion({
    required int latestYear,
    required int firstYear,
    required double latestIPM,
    required double firstIPM,
    double? nationalAverage,
    double? provincialAverage,
  }) {
    final change = latestIPM - firstIPM;
    final isIncreasing = change > 0;

    KesimpulanStatus status;
    if (latestIPM >= 80) {
      status = KesimpulanStatus.baik;
    } else if (latestIPM >= 70) {
      status = KesimpulanStatus.perhatian;
    } else {
      status = KesimpulanStatus.perbaikan;
    }

    String conclusion =
        'Tahun $latestYear, Indeks Pembangunan Manusia (IPM) Kota Semarang mencapai ${latestIPM.toStringAsFixed(2)}, menunjukkan tingkat pembangunan manusia yang ';

    if (latestIPM >= 80) {
      conclusion += 'sangat tinggi. ';
    } else if (latestIPM >= 70) {
      conclusion += 'tinggi. ';
    } else {
      conclusion += 'sedang. ';
    }

    if (isIncreasing) {
      conclusion +=
          'Nilai ini meningkat sebesar ${change.toStringAsFixed(2)} poin dibandingkan tahun $firstYear, mencerminkan peningkatan kualitas hidup masyarakat.';
    } else {
      conclusion +=
          'Nilai ini mengalami penurunan, memerlukan evaluasi dan perbaikan program pembangunan.';
    }

    List<String> additionalPoints = [];
    if (nationalAverage != null) {
      final diff = latestIPM - nationalAverage;
      if (diff > 0) {
        additionalPoints.add(
            'IPM Kota Semarang lebih tinggi ${diff.toStringAsFixed(2)} poin dari rata-rata nasional (${nationalAverage.toStringAsFixed(2)}), menunjukkan posisi yang relatif baik.');
      } else {
        additionalPoints.add(
            'IPM Kota Semarang masih di bawah rata-rata nasional, perlu upaya percepatan pembangunan.');
      }
    }
    if (provincialAverage != null) {
      final diff = latestIPM - provincialAverage;
      if (diff > 0) {
        additionalPoints.add(
            'Lebih tinggi ${diff.toStringAsFixed(2)} poin dari rata-rata provinsi Jawa Tengah (${provincialAverage.toStringAsFixed(2)}).');
      }
    }

    return {
      'status': status,
      'conclusion': conclusion,
      'additionalPoints': additionalPoints,
    };
  }

  // Ekonomi conclusion
  static Map<String, dynamic> generateEkonomiConclusion({
    required int latestYear,
    required int firstYear,
    required double latestGrowth,
    required double firstGrowth,
    required double averageGrowth,
  }) {
    KesimpulanStatus status;
    String performance;

    if (latestGrowth >= 5.0) {
      status = KesimpulanStatus.baik;
      performance = 'pertumbuhan yang sangat baik';
    } else if (latestGrowth >= 3.0) {
      status = KesimpulanStatus.perhatian;
      performance = 'pertumbuhan moderat';
    } else {
      status = KesimpulanStatus.perbaikan;
      performance = 'pertumbuhan yang perlu diperhatikan';
    }

    String conclusion =
        'Tahun $latestYear, pertumbuhan ekonomi Kota Semarang mencapai ${latestGrowth.toStringAsFixed(2)}%, menunjukkan $performance. ';

    final trendChange = latestGrowth - firstGrowth;
    if (trendChange > 0) {
      conclusion +=
          'Terjadi percepatan pertumbuhan sebesar ${trendChange.toStringAsFixed(2)} poin persentase dibandingkan tahun $firstYear, mencerminkan pemulihan dan penguatan ekonomi.';
    } else if (trendChange < 0) {
      conclusion +=
          'Mengalami perlambatan sebesar ${trendChange.abs().toStringAsFixed(2)} poin persentase dibandingkan tahun $firstYear, perlu strategi stimulasi ekonomi.';
    } else {
      conclusion +=
          'Tren pertumbuhan relatif stabil dengan rata-rata ${averageGrowth.toStringAsFixed(2)}% selama periode teramati.';
    }

    List<String> additionalPoints = [];
    if (averageGrowth >= 5.0) {
      additionalPoints.add(
          'Rata-rata pertumbuhan ${averageGrowth.toStringAsFixed(2)}% menunjukkan fundamental ekonomi yang kuat dan berkelanjutan.');
    } else if (averageGrowth >= 3.0) {
      additionalPoints.add(
          'Rata-rata pertumbuhan ${averageGrowth.toStringAsFixed(2)}% menunjukkan stabilitas ekonomi yang perlu dipertahankan.');
    } else {
      additionalPoints.add(
          'Rata-rata pertumbuhan di bawah target, memerlukan diversifikasi sektor ekonomi dan peningkatan investasi.');
    }

    return {
      'status': status,
      'conclusion': conclusion,
      'additionalPoints': additionalPoints,
    };
  }

  // IDG conclusion
  static Map<String, dynamic> generateIDGConclusion({
    required int latestYear,
    required int firstYear,
    required double latestIDG,
    required double firstIDG,
  }) {
    final change = latestIDG - firstIDG;

    KesimpulanStatus status;
    String parityLevel;

    if (latestIDG >= 95) {
      status = KesimpulanStatus.baik;
      parityLevel = 'hampir mencapai kesetaraan gender yang sempurna';
    } else if (latestIDG >= 85) {
      status = KesimpulanStatus.perhatian;
      parityLevel = 'menunjukkan kesetaraan gender yang baik';
    } else {
      status = KesimpulanStatus.perbaikan;
      parityLevel = 'masih terdapat kesenjangan gender yang signifikan';
    }

    String conclusion =
        'Tahun $latestYear, Indeks Pembangunan Gender (IDG) Kota Semarang mencapai ${latestIDG.toStringAsFixed(2)}, yang berarti $parityLevel. ';

    if (change > 0) {
      conclusion +=
          'Terdapat peningkatan sebesar ${change.toStringAsFixed(2)} poin dibandingkan tahun $firstYear, menunjukkan kemajuan dalam pemberdayaan perempuan.';
    } else if (change < 0) {
      conclusion +=
          'Mengalami penurunan sebesar ${change.abs().toStringAsFixed(2)} poin, memerlukan evaluasi kebijakan kesetaraan gender.';
    } else {
      conclusion +=
          'Nilai relatif stabil, perlu percepatan program pemberdayaan perempuan.';
    }

    List<String> additionalPoints = [];
    if (latestIDG < 95) {
      additionalPoints.add(
          'Fokus pada akses pendidikan, kesehatan reproduksi, dan partisipasi ekonomi perempuan dapat meningkatkan IDG.');
    }

    return {
      'status': status,
      'conclusion': conclusion,
      'additionalPoints': additionalPoints,
    };
  }

  // IPG conclusion
  static Map<String, dynamic> generateIPGConclusion({
    required int latestYear,
    required int firstYear,
    required double latestIPG,
    required double firstIPG,
  }) {
    final change = latestIPG - firstIPG;

    KesimpulanStatus status;
    String empowermentLevel;

    if (latestIPG >= 75) {
      status = KesimpulanStatus.baik;
      empowermentLevel = 'pemberdayaan gender yang sangat baik';
    } else if (latestIPG >= 60) {
      status = KesimpulanStatus.perhatian;
      empowermentLevel = 'pemberdayaan gender yang cukup baik';
    } else {
      status = KesimpulanStatus.perbaikan;
      empowermentLevel = 'pemberdayaan gender yang masih terbatas';
    }

    String conclusion =
        'Tahun $latestYear, Indeks Pemberdayaan Gender (IPG) Kota Semarang mencapai ${latestIPG.toStringAsFixed(2)}, menunjukkan $empowermentLevel dalam hal partisipasi perempuan di bidang politik dan ekonomi. ';

    if (change > 0) {
      conclusion +=
          'Meningkat sebesar ${change.toStringAsFixed(2)} poin dibandingkan tahun $firstYear, mencerminkan peningkatan peran perempuan dalam pengambilan keputusan.';
    } else if (change < 0) {
      conclusion +=
          'Mengalami penurunan sebesar ${change.abs().toStringAsFixed(2)} poin, memerlukan perhatian khusus pada representasi perempuan.';
    } else {
      conclusion +=
          'Tren stabil, perlu upaya lebih lanjut untuk meningkatkan partisipasi perempuan.';
    }

    return {
      'status': status,
      'conclusion': conclusion,
      'additionalPoints': [],
    };
  }

  // Inflasi conclusion
  static Map<String, dynamic> generateInflasiConclusion({
    required int latestYear,
    required int firstYear,
    required double latestInflasi,
    required double firstInflasi,
    required double averageInflasi,
  }) {
    KesimpulanStatus status;
    String inflationLevel;

    if (latestInflasi <= 3.0) {
      status = KesimpulanStatus.baik;
      inflationLevel = 'tingkat inflasi yang rendah dan terkendali';
    } else if (latestInflasi <= 5.0) {
      status = KesimpulanStatus.perhatian;
      inflationLevel = 'tingkat inflasi moderat yang perlu dipantau';
    } else {
      status = KesimpulanStatus.perbaikan;
      inflationLevel = 'tingkat inflasi yang tinggi';
    }

    String conclusion =
        'Tahun $latestYear, tingkat inflasi Kota Semarang mencapai ${latestInflasi.toStringAsFixed(2)}%, menunjukkan $inflationLevel. ';

    final change = latestInflasi - firstInflasi;
    if (change > 0) {
      conclusion +=
          'Mengalami kenaikan sebesar ${change.toStringAsFixed(2)} poin persentase dibandingkan tahun $firstYear.';
    } else if (change < 0) {
      conclusion +=
          'Menurun sebesar ${change.abs().toStringAsFixed(2)} poin persentase dibandingkan tahun $firstYear, menunjukkan stabilitas harga yang membaik.';
    } else {
      conclusion += 'Relatif stabil dibandingkan tahun $firstYear.';
    }

    List<String> additionalPoints = [];
    if (averageInflasi <= 3.5) {
      additionalPoints.add(
          'Rata-rata inflasi ${averageInflasi.toStringAsFixed(2)}% berada dalam kisaran target Bank Indonesia, menunjukkan manajemen moneter yang efektif.');
    } else {
      additionalPoints.add(
          'Rata-rata inflasi ${averageInflasi.toStringAsFixed(2)}% di atas target ideal, perlu koordinasi kebijakan fiskal dan moneter.');
    }

    return {
      'status': status,
      'conclusion': conclusion,
      'additionalPoints': additionalPoints,
    };
  }

  // Tenaga Kerja conclusion
  static Map<String, dynamic> generateTenagaKerjaConclusion({
    required int latestYear,
    required int firstYear,
    required double latestUnemployment,
    required double firstUnemployment,
    required double participationRate,
  }) {
    final change = latestUnemployment - firstUnemployment;

    KesimpulanStatus status;
    String employmentStatus;

    if (latestUnemployment <= 5.0) {
      status = KesimpulanStatus.baik;
      employmentStatus = 'tingkat pengangguran yang rendah';
    } else if (latestUnemployment <= 8.0) {
      status = KesimpulanStatus.perhatian;
      employmentStatus = 'tingkat pengangguran moderat';
    } else {
      status = KesimpulanStatus.perbaikan;
      employmentStatus = 'tingkat pengangguran yang perlu perhatian serius';
    }

    String conclusion =
        'Tahun $latestYear, tingkat pengangguran Kota Semarang mencapai ${latestUnemployment.toStringAsFixed(2)}%, menunjukkan $employmentStatus. ';

    if (change < 0) {
      conclusion +=
          'Mengalami penurunan sebesar ${change.abs().toStringAsFixed(2)} poin persentase dibandingkan tahun $firstYear, mencerminkan penciptaan lapangan kerja yang efektif.';
    } else if (change > 0) {
      conclusion +=
          'Meningkat sebesar ${change.toStringAsFixed(2)} poin persentase dibandingkan tahun $firstYear, memerlukan percepatan program penyerapan tenaga kerja.';
    } else {
      conclusion += 'Relatif stabil dibandingkan tahun $firstYear.';
    }

    List<String> additionalPoints = [];
    if (participationRate >= 70) {
      additionalPoints.add(
          'Tingkat partisipasi angkatan kerja yang tinggi (${participationRate.toStringAsFixed(1)}%) menunjukkan potensi sumber daya manusia yang produktif.');
    } else {
      additionalPoints.add(
          'Tingkat partisipasi angkatan kerja ${participationRate.toStringAsFixed(1)}% masih berpotensi ditingkatkan melalui program pemberdayaan.');
    }

    return {
      'status': status,
      'conclusion': conclusion,
      'additionalPoints': additionalPoints,
    };
  }

  // Penduduk conclusion
  static Map<String, dynamic> generatePendudukConclusion({
    required int latestYear,
    required int firstYear,
    required int latestPopulation,
    required int firstPopulation,
    required double growthRate,
    required double density,
  }) {
    KesimpulanStatus status;
    String growthDescription;

    if (growthRate >= 1.0 && growthRate <= 2.0) {
      status = KesimpulanStatus.baik;
      growthDescription = 'pertumbuhan penduduk yang sehat dan terkendali';
    } else if (growthRate > 2.0 && growthRate <= 3.0) {
      status = KesimpulanStatus.perhatian;
      growthDescription = 'pertumbuhan penduduk yang cukup tinggi';
    } else if (growthRate < 1.0) {
      status = KesimpulanStatus.perhatian;
      growthDescription = 'pertumbuhan penduduk yang lambat';
    } else {
      status = KesimpulanStatus.perbaikan;
      growthDescription = 'pertumbuhan penduduk yang sangat tinggi';
    }

    String conclusion =
        'Tahun $latestYear, jumlah penduduk Kota Semarang mencapai ${_formatPopulation(latestPopulation)}, dengan $growthDescription sebesar ${growthRate.toStringAsFixed(2)}% per tahun. ';

    final populationChange = latestPopulation - firstPopulation;
    conclusion +=
        'Terdapat penambahan ${populationChange >= 1000000 ? "${(populationChange / 1000000).toStringAsFixed(2)} juta" : "${(populationChange / 1000).toStringAsFixed(0)} ribu"} jiwa sejak tahun $firstYear.';

    List<String> additionalPoints = [];
    if (density > 10000) {
      additionalPoints.add(
          'Kepadatan penduduk yang tinggi (${density.toStringAsFixed(0)} jiwa/km²) memerlukan manajemen perkotaan yang efektif dan penyediaan infrastruktur memadai.');
    } else {
      additionalPoints.add(
          'Kepadatan penduduk ${density.toStringAsFixed(0)} jiwa/km² masih dalam batas wajar untuk pengelolaan kota.');
    }

    return {
      'status': status,
      'conclusion': conclusion,
      'additionalPoints': additionalPoints,
    };
  }

  // Pendidikan conclusion
  static Map<String, dynamic> generatePendidikanConclusion({
    required int latestYear,
    required int firstYear,
    required double latestEnrollment,
    required double firstEnrollment,
    required double teacherRatio,
  }) {
    final change = latestEnrollment - firstEnrollment;

    KesimpulanStatus status;
    String educationLevel;

    if (latestEnrollment >= 95) {
      status = KesimpulanStatus.baik;
      educationLevel = 'angka partisipasi pendidikan yang sangat baik';
    } else if (latestEnrollment >= 85) {
      status = KesimpulanStatus.perhatian;
      educationLevel = 'angka partisipasi pendidikan yang cukup baik';
    } else {
      status = KesimpulanStatus.perbaikan;
      educationLevel = 'angka partisipasi pendidikan yang perlu ditingkatkan';
    }

    String conclusion =
        'Tahun $latestYear, angka partisipasi pendidikan Kota Semarang mencapai ${latestEnrollment.toStringAsFixed(2)}%, menunjukkan $educationLevel. ';

    if (change > 0) {
      conclusion +=
          'Meningkat sebesar ${change.toStringAsFixed(2)} poin persentase dibandingkan tahun $firstYear, mencerminkan akses pendidikan yang semakin baik.';
    } else if (change < 0) {
      conclusion +=
          'Menurun sebesar ${change.abs().toStringAsFixed(2)} poin persentase, memerlukan intervensi untuk meningkatkan akses pendidikan.';
    } else {
      conclusion += 'Relatif stabil dibandingkan tahun $firstYear.';
    }

    List<String> additionalPoints = [];
    if (teacherRatio <= 20) {
      additionalPoints.add(
          'Rasio guru-siswa yang ideal ($teacherRatio:1) mendukung kualitas pembelajaran yang lebih baik.');
    } else {
      additionalPoints.add(
          'Rasio guru-siswa $teacherRatio:1 masih perlu dioptimalkan untuk meningkatkan kualitas pendidikan.');
    }

    return {
      'status': status,
      'conclusion': conclusion,
      'additionalPoints': additionalPoints,
    };
  }

  // SDGs conclusion
  static Map<String, dynamic> generateSDGsConclusion({
    required int latestYear,
    required double averageScore,
    required int onTrackCount,
    required int totalIndicators,
    required double progressRate,
  }) {
    final percentage = (onTrackCount / totalIndicators) * 100;

    KesimpulanStatus status;
    String progressLevel;

    if (percentage >= 75) {
      status = KesimpulanStatus.baik;
      progressLevel = 'kemajuan yang sangat baik';
    } else if (percentage >= 50) {
      status = KesimpulanStatus.perhatian;
      progressLevel = 'kemajuan yang cukup baik';
    } else {
      status = KesimpulanStatus.perbaikan;
      progressLevel = 'kemajuan yang perlu dipercepat';
    }

    String conclusion =
        'Tahun $latestYear, pencapaian Tujuan Pembangunan Berkelanjutan (SDGs) Kota Semarang menunjukkan $progressLevel dengan rata-rata skor ${averageScore.toStringAsFixed(2)}. Dari $totalIndicators indikator, terdapat $onTrackCount indikator yang berada pada jalur target.';

    List<String> additionalPoints = [];
    if (progressRate > 0) {
      additionalPoints.add(
          'Tingkat kemajuan $progressRate% per tahun menunjukkan konsistensi dalam implementasi program SDGs.');
    }
    additionalPoints.add(
        'Fokus pada indikator yang belum mencapai target dapat mempercepat pencapaian SDGs Kota Semarang.');

    return {
      'status': status,
      'conclusion': conclusion,
      'additionalPoints': additionalPoints,
    };
  }

  // Helper method
  static String _formatPopulation(int population) {
    if (population >= 1000000) {
      return '${(population / 1000000).toStringAsFixed(2)} juta jiwa';
    } else if (population >= 1000) {
      return '${(population / 1000).toStringAsFixed(0)} ribu jiwa';
    }
    return '$population jiwa';
  }
}
