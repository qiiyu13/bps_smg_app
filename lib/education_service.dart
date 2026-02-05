// education_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'education_data.dart';

class EducationService {
  static const String _storageKey = 'education_data';

  // Singleton pattern
  static final EducationService _instance = EducationService._internal();
  factory EducationService() => _instance;
  EducationService._internal();

  // Get all education data
  Future<Map<String, EducationData>> getAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        print('📁 Data kosong, load default data...');
        // Return default data jika belum ada
        final defaultData = _getDefaultData();
        // Simpan default data
        await saveAllData(defaultData);
        return defaultData;
      }

      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final Map<String, EducationData> result = {};

      jsonMap.forEach((key, value) {
        result[key] = EducationData.fromJson(value as Map<String, dynamic>);
      });

      print('✅ Data berhasil dimuat: ${result.keys.length} tahun');
      return result;
    } catch (e) {
      print('❌ Error loading education data: $e');
      return _getDefaultData();
    }
  }

  // Save all data
  Future<bool> saveAllData(Map<String, EducationData> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> jsonMap = {};

      data.forEach((key, value) {
        jsonMap[key] = value.toJson();
      });

      final String jsonString = json.encode(jsonMap);
      final result = await prefs.setString(_storageKey, jsonString);

      if (result) {
        print('✅ Data berhasil disimpan: ${data.keys.length} tahun');
      }

      return result;
    } catch (e) {
      print('❌ Error saving education data: $e');
      return false;
    }
  }

  // Add new year data
  Future<bool> addYearData(EducationData data) async {
    try {
      final allData = await getAllData();

      // Check if year already exists
      if (allData.containsKey(data.year)) {
        print('⚠️ Tahun ${data.year} sudah ada');
        return false;
      }

      allData[data.year] = data;
      final result = await saveAllData(allData);

      if (result) {
        print('✅ Data tahun ${data.year} berhasil ditambahkan');
      }

      return result;
    } catch (e) {
      print('❌ Error adding year data: $e');
      return false;
    }
  }

  // Update year data
  Future<bool> updateYearData(String oldYear, EducationData newData) async {
    try {
      final allData = await getAllData();

      if (!allData.containsKey(oldYear)) {
        print('⚠️ Tahun $oldYear tidak ditemukan');
        return false;
      }

      // Remove old year data if year changed
      if (oldYear != newData.year) {
        allData.remove(oldYear);
        print('🔄 Tahun berubah dari $oldYear ke ${newData.year}');
      }

      allData[newData.year] = newData;
      final result = await saveAllData(allData);

      if (result) {
        print('✅ Data tahun $oldYear berhasil diupdate');
      }

      return result;
    } catch (e) {
      print('❌ Error updating year data: $e');
      return false;
    }
  }

  // Delete year data
  Future<bool> deleteYearData(String year) async {
    try {
      final allData = await getAllData();

      if (!allData.containsKey(year)) {
        print('⚠️ Tahun $year tidak ditemukan');
        return false;
      }

      allData.remove(year);
      final result = await saveAllData(allData);

      if (result) {
        print('✅ Data tahun $year berhasil dihapus');
      }

      return result;
    } catch (e) {
      print('❌ Error deleting year data: $e');
      return false;
    }
  }

  // Get data by year
  Future<EducationData?> getDataByYear(String year) async {
    try {
      final allData = await getAllData();
      final data = allData[year];

      if (data != null) {
        print('✅ Data tahun $year ditemukan');
      } else {
        print('⚠️ Data tahun $year tidak ditemukan');
      }

      return data;
    } catch (e) {
      print('❌ Error getting data by year: $e');
      return null;
    }
  }

  // Get available years
  Future<List<String>> getAvailableYears() async {
    try {
      final allData = await getAllData();
      final years = allData.keys.toList();
      years.sort((a, b) => b.compareTo(a)); // Sort descending (newest first)
      print('📅 Tahun tersedia: ${years.join(", ")}');
      return years;
    } catch (e) {
      print('❌ Error getting available years: $e');
      return [];
    }
  }

  // Check if year exists
  Future<bool> yearExists(String year) async {
    try {
      final allData = await getAllData();
      final exists = allData.containsKey(year);

      if (exists) {
        print('✅ Tahun $year sudah ada');
      } else {
        print('ℹ️ Tahun $year belum ada');
      }

      return exists;
    } catch (e) {
      print('❌ Error checking year exists: $e');
      return false;
    }
  }

  // Clear all data (untuk reset)
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.remove(_storageKey);

      if (result) {
        print('🗑️ Semua data berhasil dihapus');
      }

      return result;
    } catch (e) {
      print('❌ Error clearing all data: $e');
      return false;
    }
  }

  // Reset to default data
  Future<bool> resetToDefault() async {
    try {
      final defaultData = _getDefaultData();
      final result = await saveAllData(defaultData);

      if (result) {
        print('🔄 Data berhasil direset ke default');
      }

      return result;
    } catch (e) {
      print('❌ Error resetting to default: $e');
      return false;
    }
  }

  // Default data (data awal - tahun 2022-2024)
  Map<String, EducationData> _getDefaultData() {
    print('📦 Membuat default data...');
    return {
      '2022': EducationData(
        year: '2022',
        angkaMelekHuruf: 96.9,
        rataRataLamaSekolah: 8.9,
        harapanLamaSekolah: 13.3,
        rasioGuruMurid: 15.36,
        tingkatKelulusan: 98.9,
        aksesPendidikanTinggi: 35.1,
        jenjangPendidikan: [
          JenjangPendidikan(
              jenjang: 'TK', sekolah: 668, guru: 2272, murid: 28986),
          JenjangPendidikan(
              jenjang: 'RA', sekolah: 137, guru: 693, murid: 8774),
          JenjangPendidikan(
              jenjang: 'SD', sekolah: 506, guru: 7140, murid: 131398),
          JenjangPendidikan(
              jenjang: 'MI', sekolah: 92, guru: 1180, murid: 19205),
          JenjangPendidikan(
              jenjang: 'SMP', sekolah: 191, guru: 3802, murid: 63809),
          JenjangPendidikan(
              jenjang: 'MTs', sekolah: 41, guru: 823, murid: 9538),
          JenjangPendidikan(
              jenjang: 'SMA', sekolah: 74, guru: 1889, murid: 30402),
          JenjangPendidikan(
              jenjang: 'SMK', sekolah: 86, guru: 2464, murid: 38239),
          JenjangPendidikan(jenjang: 'MA', sekolah: 32, guru: 742, murid: 6521),
        ],
        rasioData: [
          RasioData(
              jenjang: 'TK/RA',
              rasioSekolahMurid: 46.91,
              rasioGuruMurid: 12.74),
          RasioData(
              jenjang: 'SD/MI',
              rasioSekolahMurid: 251.84,
              rasioGuruMurid: 18.10),
          RasioData(
              jenjang: 'SMP/MTs',
              rasioSekolahMurid: 316.15,
              rasioGuruMurid: 15.86),
          RasioData(
              jenjang: 'SMA/SMK/MA',
              rasioSekolahMurid: 391.47,
              rasioGuruMurid: 14.75),
        ],
        angkaPutusSekolah: [
          AngkaPutusSekolah(tingkat: 'SD', persentase: 0.5),
          AngkaPutusSekolah(tingkat: 'SMP', persentase: 0.9),
          AngkaPutusSekolah(tingkat: 'SMA', persentase: 1.9),
        ],
        partisipasiPendidikan: [
          PartisipasiPendidikan(
              jenjang: 'SD/MI/Sederajat', apm: 99.80, apk: 103.00),
          PartisipasiPendidikan(
              jenjang: 'SMP/MTs/Sederajat', apm: 92.50, apk: 93.80),
          PartisipasiPendidikan(
              jenjang: 'SMA/SMK/MA/Sederajat', apm: 72.50, apk: 106.00),
        ],
      ),
      '2023': EducationData(
        year: '2023',
        angkaMelekHuruf: 97.2,
        rataRataLamaSekolah: 9.1,
        harapanLamaSekolah: 13.5,
        rasioGuruMurid: 15.4,
        tingkatKelulusan: 99.1,
        aksesPendidikanTinggi: 37.3,
        jenjangPendidikan: [
          JenjangPendidikan(
              jenjang: 'TK', sekolah: 690, guru: 2380, murid: 29800),
          JenjangPendidikan(
              jenjang: 'RA', sekolah: 142, guru: 710, murid: 9000),
          JenjangPendidikan(
              jenjang: 'SD', sekolah: 512, guru: 7320, murid: 133200),
          JenjangPendidikan(
              jenjang: 'MI', sekolah: 95, guru: 1200, murid: 19800),
          JenjangPendidikan(
              jenjang: 'SMP', sekolah: 198, guru: 3950, murid: 65100),
          JenjangPendidikan(
              jenjang: 'MTs', sekolah: 43, guru: 850, murid: 9800),
          JenjangPendidikan(
              jenjang: 'SMA', sekolah: 78, guru: 1950, murid: 31500),
          JenjangPendidikan(
              jenjang: 'SMK', sekolah: 90, guru: 2550, murid: 39500),
          JenjangPendidikan(jenjang: 'MA', sekolah: 35, guru: 780, murid: 6800),
        ],
        rasioData: [
          RasioData(
              jenjang: 'TK/RA', rasioSekolahMurid: 43.2, rasioGuruMurid: 12.5),
          RasioData(
              jenjang: 'SD/MI', rasioSekolahMurid: 260.2, rasioGuruMurid: 18.2),
          RasioData(
              jenjang: 'SMP/MTs',
              rasioSekolahMurid: 328.8,
              rasioGuruMurid: 16.5),
          RasioData(
              jenjang: 'SMA/SMK/MA',
              rasioSekolahMurid: 379.1,
              rasioGuruMurid: 14.9),
        ],
        angkaPutusSekolah: [
          AngkaPutusSekolah(tingkat: 'SD', persentase: 0.4),
          AngkaPutusSekolah(tingkat: 'SMP', persentase: 0.8),
          AngkaPutusSekolah(tingkat: 'SMA', persentase: 1.7),
        ],
        partisipasiPendidikan: [
          PartisipasiPendidikan(
              jenjang: 'SD/MI/Sederajat', apm: 99.85, apk: 103.20),
          PartisipasiPendidikan(
              jenjang: 'SMP/MTs/Sederajat', apm: 93.00, apk: 94.50),
          PartisipasiPendidikan(
              jenjang: 'SMA/SMK/MA/Sederajat', apm: 74.00, apk: 107.00),
        ],
      ),
      '2024': EducationData(
        year: '2024',
        angkaMelekHuruf: 97.6,
        rataRataLamaSekolah: 9.3,
        harapanLamaSekolah: 13.7,
        rasioGuruMurid: 15.0,
        tingkatKelulusan: 99.3,
        aksesPendidikanTinggi: 39.5,
        jenjangPendidikan: [
          JenjangPendidikan(
              jenjang: 'TK', sekolah: 705, guru: 2450, murid: 30200),
          JenjangPendidikan(
              jenjang: 'RA', sekolah: 145, guru: 725, murid: 9200),
          JenjangPendidikan(
              jenjang: 'SD', sekolah: 515, guru: 7420, murid: 134000),
          JenjangPendidikan(
              jenjang: 'MI', sekolah: 98, guru: 1220, murid: 20000),
          JenjangPendidikan(
              jenjang: 'SMP', sekolah: 202, guru: 4020, murid: 65800),
          JenjangPendidikan(
              jenjang: 'MTs', sekolah: 45, guru: 870, murid: 10000),
          JenjangPendidikan(
              jenjang: 'SMA', sekolah: 80, guru: 2000, murid: 32000),
          JenjangPendidikan(
              jenjang: 'SMK', sekolah: 92, guru: 2600, murid: 40000),
          JenjangPendidikan(jenjang: 'MA', sekolah: 38, guru: 800, murid: 7000),
        ],
        rasioData: [
          RasioData(
              jenjang: 'TK/RA', rasioSekolahMurid: 42.8, rasioGuruMurid: 12.3),
          RasioData(
              jenjang: 'SD/MI', rasioSekolahMurid: 260.2, rasioGuruMurid: 18.1),
          RasioData(
              jenjang: 'SMP/MTs',
              rasioSekolahMurid: 325.7,
              rasioGuruMurid: 16.4),
          RasioData(
              jenjang: 'SMA/SMK/MA',
              rasioSekolahMurid: 375.9,
              rasioGuruMurid: 14.7),
        ],
        angkaPutusSekolah: [
          AngkaPutusSekolah(tingkat: 'SD', persentase: 0.3),
          AngkaPutusSekolah(tingkat: 'SMP', persentase: 0.7),
          AngkaPutusSekolah(tingkat: 'SMA', persentase: 1.5),
        ],
        partisipasiPendidikan: [
          PartisipasiPendidikan(
              jenjang: 'SD/MI/Sederajat', apm: 99.90, apk: 103.50),
          PartisipasiPendidikan(
              jenjang: 'SMP/MTs/Sederajat', apm: 93.50, apk: 95.20),
          PartisipasiPendidikan(
              jenjang: 'SMA/SMK/MA/Sederajat', apm: 75.50, apk: 108.00),
        ],
      ),
    };
  }

  // Export data to JSON string (untuk backup/share)
  Future<String> exportToJson() async {
    try {
      final allData = await getAllData();
      final Map<String, dynamic> jsonMap = {};

      allData.forEach((key, value) {
        jsonMap[key] = value.toJson();
      });

      final jsonString = json.encode(jsonMap);
      print('📤 Data berhasil diekspor');
      return jsonString;
    } catch (e) {
      print('❌ Error exporting to JSON: $e');
      return '';
    }
  }

  // Import data from JSON string
  Future<bool> importFromJson(String jsonString) async {
    try {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final Map<String, EducationData> data = {};

      jsonMap.forEach((key, value) {
        data[key] = EducationData.fromJson(value as Map<String, dynamic>);
      });

      final result = await saveAllData(data);

      if (result) {
        print('📥 Data berhasil diimpor: ${data.keys.length} tahun');
      }

      return result;
    } catch (e) {
      print('❌ Error importing from JSON: $e');
      return false;
    }
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final allData = await getAllData();

      if (allData.isEmpty) {
        return {
          'totalYears': 0,
          'latestYear': '',
          'totalStudents': 0,
          'literacyRate': 0.0,
          'graduationRate': 0.0,
        };
      }

      final years = allData.keys.toList();
      years.sort((a, b) => b.compareTo(a));

      final latestData = allData[years.first]!;
      final totalStudents = latestData.jenjangPendidikan
          .fold<int>(0, (sum, item) => sum + item.murid);

      final stats = {
        'totalYears': allData.length,
        'latestYear': years.first,
        'totalStudents': totalStudents,
        'literacyRate': latestData.angkaMelekHuruf,
        'graduationRate': latestData.tingkatKelulusan,
      };

      print('📊 Statistik: ${stats.toString()}');
      return stats;
    } catch (e) {
      print('❌ Error getting statistics: $e');
      return {};
    }
  }
}