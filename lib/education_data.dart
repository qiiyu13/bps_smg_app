// education_data.dart
class EducationData {
  String year;
  double angkaMelekHuruf;
  double rataRataLamaSekolah;
  double harapanLamaSekolah;
  double rasioGuruMurid;
  double tingkatKelulusan;
  double aksesPendidikanTinggi;
  List<JenjangPendidikan> jenjangPendidikan;
  List<RasioData> rasioData;
  List<AngkaPutusSekolah> angkaPutusSekolah;
  List<PartisipasiPendidikan> partisipasiPendidikan;

  EducationData({
    required this.year,
    required this.angkaMelekHuruf,
    required this.rataRataLamaSekolah,
    required this.harapanLamaSekolah,
    required this.rasioGuruMurid,
    required this.tingkatKelulusan,
    required this.aksesPendidikanTinggi,
    required this.jenjangPendidikan,
    required this.rasioData,
    required this.angkaPutusSekolah,
    required this.partisipasiPendidikan,
  });

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'angkaMelekHuruf': angkaMelekHuruf,
      'rataRataLamaSekolah': rataRataLamaSekolah,
      'harapanLamaSekolah': harapanLamaSekolah,
      'rasioGuruMurid': rasioGuruMurid,
      'tingkatKelulusan': tingkatKelulusan,
      'aksesPendidikanTinggi': aksesPendidikanTinggi,
      'jenjangPendidikan': jenjangPendidikan.map((e) => e.toJson()).toList(),
      'rasioData': rasioData.map((e) => e.toJson()).toList(),
      'angkaPutusSekolah': angkaPutusSekolah.map((e) => e.toJson()).toList(),
      'partisipasiPendidikan':
          partisipasiPendidikan.map((e) => e.toJson()).toList(),
    };
  }

  factory EducationData.fromJson(Map<String, dynamic> json) {
    return EducationData(
      year: json['year'] as String,
      angkaMelekHuruf: (json['angkaMelekHuruf'] as num).toDouble(),
      rataRataLamaSekolah: (json['rataRataLamaSekolah'] as num).toDouble(),
      harapanLamaSekolah: (json['harapanLamaSekolah'] as num).toDouble(),
      rasioGuruMurid: (json['rasioGuruMurid'] as num).toDouble(),
      tingkatKelulusan: (json['tingkatKelulusan'] as num).toDouble(),
      aksesPendidikanTinggi: (json['aksesPendidikanTinggi'] as num).toDouble(),
      jenjangPendidikan: (json['jenjangPendidikan'] as List)
          .map((e) => JenjangPendidikan.fromJson(e as Map<String, dynamic>))
          .toList(),
      rasioData: (json['rasioData'] as List)
          .map((e) => RasioData.fromJson(e as Map<String, dynamic>))
          .toList(),
      angkaPutusSekolah: (json['angkaPutusSekolah'] as List)
          .map((e) => AngkaPutusSekolah.fromJson(e as Map<String, dynamic>))
          .toList(),
      partisipasiPendidikan: (json['partisipasiPendidikan'] as List)
          .map((e) => PartisipasiPendidikan.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  EducationData copyWith({
    String? year,
    double? angkaMelekHuruf,
    double? rataRataLamaSekolah,
    double? harapanLamaSekolah,
    double? rasioGuruMurid,
    double? tingkatKelulusan,
    double? aksesPendidikanTinggi,
    List<JenjangPendidikan>? jenjangPendidikan,
    List<RasioData>? rasioData,
    List<AngkaPutusSekolah>? angkaPutusSekolah,
    List<PartisipasiPendidikan>? partisipasiPendidikan,
  }) {
    return EducationData(
      year: year ?? this.year,
      angkaMelekHuruf: angkaMelekHuruf ?? this.angkaMelekHuruf,
      rataRataLamaSekolah: rataRataLamaSekolah ?? this.rataRataLamaSekolah,
      harapanLamaSekolah: harapanLamaSekolah ?? this.harapanLamaSekolah,
      rasioGuruMurid: rasioGuruMurid ?? this.rasioGuruMurid,
      tingkatKelulusan: tingkatKelulusan ?? this.tingkatKelulusan,
      aksesPendidikanTinggi:
          aksesPendidikanTinggi ?? this.aksesPendidikanTinggi,
      jenjangPendidikan: jenjangPendidikan ?? this.jenjangPendidikan,
      rasioData: rasioData ?? this.rasioData,
      angkaPutusSekolah: angkaPutusSekolah ?? this.angkaPutusSekolah,
      partisipasiPendidikan:
          partisipasiPendidikan ?? this.partisipasiPendidikan,
    );
  }
}

class JenjangPendidikan {
  String jenjang;
  int sekolah;
  int guru;
  int murid;

  JenjangPendidikan({
    required this.jenjang,
    required this.sekolah,
    required this.guru,
    required this.murid,
  });

  Map<String, dynamic> toJson() => {
        'jenjang': jenjang,
        'sekolah': sekolah,
        'guru': guru,
        'murid': murid,
      };

  factory JenjangPendidikan.fromJson(Map<String, dynamic> json) {
    return JenjangPendidikan(
      jenjang: json['jenjang'] as String,
      sekolah: json['sekolah'] as int,
      guru: json['guru'] as int,
      murid: json['murid'] as int,
    );
  }
}

class RasioData {
  String jenjang;
  double rasioSekolahMurid;
  double rasioGuruMurid;

  RasioData({
    required this.jenjang,
    required this.rasioSekolahMurid,
    required this.rasioGuruMurid,
  });

  Map<String, dynamic> toJson() => {
        'jenjang': jenjang,
        'rasioSekolahMurid': rasioSekolahMurid,
        'rasioGuruMurid': rasioGuruMurid,
      };

  factory RasioData.fromJson(Map<String, dynamic> json) {
    return RasioData(
      jenjang: json['jenjang'] as String,
      rasioSekolahMurid: (json['rasioSekolahMurid'] as num).toDouble(),
      rasioGuruMurid: (json['rasioGuruMurid'] as num).toDouble(),
    );
  }
}

class AngkaPutusSekolah {
  String tingkat;
  double persentase;

  AngkaPutusSekolah({
    required this.tingkat,
    required this.persentase,
  });

  Map<String, dynamic> toJson() => {
        'tingkat': tingkat,
        'persentase': persentase,
      };

  factory AngkaPutusSekolah.fromJson(Map<String, dynamic> json) {
    return AngkaPutusSekolah(
      tingkat: json['tingkat'] as String,
      persentase: (json['persentase'] as num).toDouble(),
    );
  }
}

class PartisipasiPendidikan {
  String jenjang;
  double apm;
  double apk;

  PartisipasiPendidikan({
    required this.jenjang,
    required this.apm,
    required this.apk,
  });

  Map<String, dynamic> toJson() => {
        'jenjang': jenjang,
        'apm': apm,
        'apk': apk,
      };

  factory PartisipasiPendidikan.fromJson(Map<String, dynamic> json) {
    return PartisipasiPendidikan(
      jenjang: json['jenjang'] as String,
      apm: (json['apm'] as num).toDouble(),
      apk: (json['apk'] as num).toDouble(),
    );
  }
}