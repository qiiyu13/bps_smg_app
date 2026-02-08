import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'number_format_utils.dart';

class AdminTenagaKerjaScreen extends StatefulWidget {
  const AdminTenagaKerjaScreen({Key? key}) : super(key: key);

  @override
  State<AdminTenagaKerjaScreen> createState() => _AdminTenagaKerjaScreenState();
}

class _AdminTenagaKerjaScreenState extends State<AdminTenagaKerjaScreen>
    with SingleTickerProviderStateMixin {
  Map<int, Map<String, dynamic>> yearData = {};
  Map<int, Map<String, dynamic>> indikatorData = {};
  Map<int, Map<String, double>> distribusiData = {};
  Map<int, Map<String, dynamic>> jatengData = {};
  List<int> availableYears = [];
  int selectedYear = 2024;
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ============= DATA LOADING & SAVING =============

  Future<void> _loadData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? savedYearData = prefs.getString('tenaga_kerja_year_data');
      if (savedYearData != null) {
        Map<String, dynamic> decoded = json.decode(savedYearData);
        yearData = decoded.map((key, value) =>
            MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));
      } else {
        _initializeDefaultYearData();
      }

      String? savedIndikatorData =
          prefs.getString('tenaga_kerja_indikator_data');
      if (savedIndikatorData != null) {
        Map<String, dynamic> decoded = json.decode(savedIndikatorData);
        indikatorData = decoded.map((key, value) =>
            MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));
      } else {
        _initializeDefaultIndikatorData();
      }

      String? savedDistribusiData =
          prefs.getString('tenaga_kerja_distribusi_data');
      if (savedDistribusiData != null) {
        Map<String, dynamic> decoded = json.decode(savedDistribusiData);
        distribusiData = decoded.map((key, value) =>
            MapEntry(int.parse(key), Map<String, double>.from(value as Map)));
      } else {
        _initializeDefaultDistribusiData();
      }

      String? savedJatengData = prefs.getString('tenaga_kerja_jateng_data');
      if (savedJatengData != null) {
        Map<String, dynamic> decoded = json.decode(savedJatengData);
        jatengData = decoded.map((key, value) =>
            MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));
      } else {
        _initializeDefaultJatengData();
      }

      setState(() {
        availableYears = yearData.keys.toList()..sort();
        if (availableYears.isNotEmpty) {
          selectedYear = availableYears.last;
        }
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      _initializeDefaultYearData();
      _initializeDefaultIndikatorData();
      _initializeDefaultDistribusiData();
      _initializeDefaultJatengData();
      setState(() {
        availableYears = yearData.keys.toList()..sort();
        if (availableYears.isNotEmpty) {
          selectedYear = availableYears.last;
        }
        isLoading = false;
      });
    }
  }

  Future<void> _saveData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('tenaga_kerja_year_data',
          json.encode(yearData.map((k, v) => MapEntry(k.toString(), v))));
      await prefs.setString('tenaga_kerja_indikator_data',
          json.encode(indikatorData.map((k, v) => MapEntry(k.toString(), v))));
      await prefs.setString('tenaga_kerja_distribusi_data',
          json.encode(distribusiData.map((k, v) => MapEntry(k.toString(), v))));
      await prefs.setString('tenaga_kerja_jateng_data',
          json.encode(jatengData.map((k, v) => MapEntry(k.toString(), v))));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Data berhasil disimpan!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ============= DEFAULT DATA INITIALIZATION =============

  void _initializeDefaultYearData() {
    yearData = {
      2020: {
        'angkatanKerja': 1023964,
        'bekerja': 925963,
        'pengangguran': 98001,
        'bukanAngkatanKerja': 441157,
        'tpt': 9.57,
        'tkk': 90.43,
        'tpak': 69.89
      },
      2021: {
        'angkatanKerja': 1034794,
        'bekerja': 936076,
        'pengangguran': 98718,
        'bukanAngkatanKerja': 455948,
        'tpt': 9.54,
        'tkk': 90.46,
        'tpak': 69.41
      },
      2022: {
        'angkatanKerja': 1075827,
        'bekerja': 994091,
        'pengangguran': 81736,
        'bukanAngkatanKerja': 440370,
        'tpt': 7.60,
        'tkk': 92.40,
        'tpak': 70.96
      },
      2023: {
        'angkatanKerja': 929014,
        'bekerja': 873358,
        'pengangguran': 55656,
        'bukanAngkatanKerja': 409201,
        'tpt': 5.99,
        'tkk': 94.01,
        'tpak': 69.42
      },
      2024: {
        'angkatanKerja': 946618,
        'bekerja': 891497,
        'pengangguran': 55121,
        'bukanAngkatanKerja': 407975,
        'tpt': 5.82,
        'tkk': 94.18,
        'tpak': 69.88
      },
    };
  }

  void _initializeDefaultIndikatorData() {
    indikatorData = {
      2020: {
        'tptLaki': 10.08,
        'tptPerempuan': 8.94,
        'tptTotal': 9.57,
        'tkkLaki': 89.92,
        'tkkPerempuan': 91.06,
        'tkkTotal': 90.43,
        'tpakLaki': 79.86,
        'tpakPerempuan': 60.48,
        'tpakTotal': 69.89
      },
      2021: {
        'tptLaki': 10.01,
        'tptPerempuan': 8.94,
        'tptTotal': 9.54,
        'tkkLaki': 89.99,
        'tkkPerempuan': 91.06,
        'tkkTotal': 90.46,
        'tpakLaki': 79.99,
        'tpakPerempuan': 59.42,
        'tpakTotal': 69.41
      },
      2022: {
        'tptLaki': 9.91,
        'tptPerempuan': 4.46,
        'tptTotal': 7.60,
        'tkkLaki': 90.09,
        'tkkPerempuan': 95.54,
        'tkkTotal': 92.40,
        'tpakLaki': 84.03,
        'tpakPerempuan': 58.59,
        'tpakTotal': 70.96
      },
      2023: {
        'tptLaki': 4.91,
        'tptPerempuan': 7.33,
        'tptTotal': 5.99,
        'tkkLaki': 95.09,
        'tkkPerempuan': 92.67,
        'tkkTotal': 94.01,
        'tpakLaki': 78.56,
        'tpakPerempuan': 60.64,
        'tpakTotal': 69.42
      },
      2024: {
        'tptLaki': 3.58,
        'tptPerempuan': 8.68,
        'tptTotal': 5.82,
        'tkkLaki': 96.42,
        'tkkPerempuan': 91.32,
        'tkkTotal': 94.18,
        'tpakLaki': 79.92,
        'tpakPerempuan': 60.24,
        'tpakTotal': 69.88
      },
    };
  }

  void _initializeDefaultDistribusiData() {
    distribusiData = {
      2020: {'Pertanian': 2.00, 'Manufaktur': 26.00, 'Jasa': 73.00},
      2021: {'Pertanian': 2.00, 'Manufaktur': 26.00, 'Jasa': 72.00},
      2022: {'Pertanian': 1.00, 'Manufaktur': 28.00, 'Jasa': 70.00},
      2023: {'Pertanian': 2.00, 'Manufaktur': 26.00, 'Jasa': 72.00},
      2024: {'Pertanian': 2.00, 'Manufaktur': 28.00, 'Jasa': 70.00},
    };
  }

  void _initializeDefaultJatengData() {
    jatengData = {
      2020: {
        'bekerja': 17536935,
        'pengangguran': 1214342,
        'bukanAngkatanKerja': 8258019
      },
      2021: {
        'bekerja': 17835770,
        'pengangguran': 1128223,
        'bukanAngkatanKerja': 8289921
      },
      2022: {
        'bekerja': 18390459,
        'pengangguran': 1084475,
        'bukanAngkatanKerja': 8015925
      },
      2023: {
        'bekerja': 19988875,
        'pengangguran': 1080260,
        'bukanAngkatanKerja': 8308494
      },
      2024: {
        'bekerja': 20861393,
        'pengangguran': 1047451,
        'bukanAngkatanKerja': 7803338
      },
    };
  }

  // ============= EDIT DIALOGS =============

  void _showEditMainDataDialog(int year) {
    final data = yearData[year] ?? {};
    final controllers = {
      'angkatanKerja': TextEditingController(
          text: NumberFormatUtils.formatInteger(data['angkatanKerja'] ?? 0)),
      'bekerja': TextEditingController(
          text: NumberFormatUtils.formatInteger(data['bekerja'] ?? 0)),
      'pengangguran': TextEditingController(
          text: NumberFormatUtils.formatInteger(data['pengangguran'] ?? 0)),
      'bukanAngkatanKerja': TextEditingController(
          text:
              NumberFormatUtils.formatInteger(data['bukanAngkatanKerja'] ?? 0)),
      'tpt': TextEditingController(
          text: NumberFormatUtils.formatDecimal(data['tpt']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
      'tkk': TextEditingController(
          text: NumberFormatUtils.formatDecimal(data['tkk']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
      'tpak': TextEditingController(
          text: NumberFormatUtils.formatDecimal(data['tpak']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Data Utama Tahun $year'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                  'Angkatan Kerja', controllers['angkatanKerja']!, Icons.groups,
                  isNumber: true),
              _buildTextField(
                  'Bekerja', controllers['bekerja']!, Icons.work_outline,
                  isNumber: true),
              _buildTextField('Pengangguran', controllers['pengangguran']!,
                  Icons.trending_down,
                  isNumber: true),
              _buildTextField('Bukan Angkatan Kerja',
                  controllers['bukanAngkatanKerja']!, Icons.person_off,
                  isNumber: true),
              _buildTextField('TPT (%)', controllers['tpt']!, Icons.percent,
                  isDecimal: true),
              _buildTextField(
                  'TKK (%)', controllers['tkk']!, Icons.check_circle,
                  isDecimal: true),
              _buildTextField(
                  'TPAK (%)', controllers['tpak']!, Icons.trending_up,
                  isDecimal: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                setState(() {
                  yearData[year] = {
                    'angkatanKerja': NumberFormatUtils.parseIndonesianInteger(
                            controllers['angkatanKerja']!.text) ??
                        0,
                    'bekerja': NumberFormatUtils.parseIndonesianInteger(
                            controllers['bekerja']!.text) ??
                        0,
                    'pengangguran': NumberFormatUtils.parseIndonesianInteger(
                            controllers['pengangguran']!.text) ??
                        0,
                    'bukanAngkatanKerja':
                        NumberFormatUtils.parseIndonesianInteger(
                                controllers['bukanAngkatanKerja']!.text) ??
                            0,
                    'tpt': NumberFormatUtils.parseIndonesianNumber(
                            controllers['tpt']!.text) ??
                        0.0,
                    'tkk': NumberFormatUtils.parseIndonesianNumber(
                            controllers['tkk']!.text) ??
                        0.0,
                    'tpak': NumberFormatUtils.parseIndonesianNumber(
                            controllers['tpak']!.text) ??
                        0.0,
                  };
                });
                _saveData();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditIndikatorDialog(int year) {
    final data = indikatorData[year] ?? {};
    final controllers = {
      'tptLaki': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              data['tptLaki']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
      'tptPerempuan': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              data['tptPerempuan']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
      'tptTotal': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              data['tptTotal']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
      'tkkLaki': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              data['tkkLaki']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
      'tkkPerempuan': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              data['tkkPerempuan']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
      'tkkTotal': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              data['tkkTotal']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
      'tpakLaki': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              data['tpakLaki']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
      'tpakPerempuan': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              data['tpakPerempuan']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
      'tpakTotal': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              data['tpakTotal']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Indikator Gender $year'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('TPT (Tingkat Pengangguran Terbuka)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTextField(
                  'TPT Laki-laki (%)', controllers['tptLaki']!, Icons.male,
                  isDecimal: true),
              _buildTextField('TPT Perempuan (%)', controllers['tptPerempuan']!,
                  Icons.female,
                  isDecimal: true),
              _buildTextField(
                  'TPT Total (%)', controllers['tptTotal']!, Icons.percent,
                  isDecimal: true),
              const SizedBox(height: 12),
              const Text('TKK (Tingkat Kesempatan Kerja)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTextField(
                  'TKK Laki-laki (%)', controllers['tkkLaki']!, Icons.male,
                  isDecimal: true),
              _buildTextField('TKK Perempuan (%)', controllers['tkkPerempuan']!,
                  Icons.female,
                  isDecimal: true),
              _buildTextField(
                  'TKK Total (%)', controllers['tkkTotal']!, Icons.percent,
                  isDecimal: true),
              const SizedBox(height: 12),
              const Text('TPAK (Tingkat Partisipasi Angkatan Kerja)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTextField(
                  'TPAK Laki-laki (%)', controllers['tpakLaki']!, Icons.male,
                  isDecimal: true),
              _buildTextField('TPAK Perempuan (%)',
                  controllers['tpakPerempuan']!, Icons.female,
                  isDecimal: true),
              _buildTextField(
                  'TPAK Total (%)', controllers['tpakTotal']!, Icons.percent,
                  isDecimal: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                setState(() {
                  indikatorData[year] = {
                    'tptLaki': NumberFormatUtils.parseIndonesianNumber(
                            controllers['tptLaki']!.text) ??
                        0.0,
                    'tptPerempuan': NumberFormatUtils.parseIndonesianNumber(
                            controllers['tptPerempuan']!.text) ??
                        0.0,
                    'tptTotal': NumberFormatUtils.parseIndonesianNumber(
                            controllers['tptTotal']!.text) ??
                        0.0,
                    'tkkLaki': NumberFormatUtils.parseIndonesianNumber(
                            controllers['tkkLaki']!.text) ??
                        0.0,
                    'tkkPerempuan': NumberFormatUtils.parseIndonesianNumber(
                            controllers['tkkPerempuan']!.text) ??
                        0.0,
                    'tkkTotal': NumberFormatUtils.parseIndonesianNumber(
                            controllers['tkkTotal']!.text) ??
                        0.0,
                    'tpakLaki': NumberFormatUtils.parseIndonesianNumber(
                            controllers['tpakLaki']!.text) ??
                        0.0,
                    'tpakPerempuan': NumberFormatUtils.parseIndonesianNumber(
                            controllers['tpakPerempuan']!.text) ??
                        0.0,
                    'tpakTotal': NumberFormatUtils.parseIndonesianNumber(
                            controllers['tpakTotal']!.text) ??
                        0.0,
                  };
                });
                _saveData();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditDistribusiDialog(int year) {
    final data = distribusiData[year] ?? {};
    final controllers = {
      'Pertanian': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              data['Pertanian']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
      'Manufaktur': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              data['Manufaktur']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
      'Jasa': TextEditingController(
          text: NumberFormatUtils.formatDecimal(data['Jasa']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Distribusi Sektor $year'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
                'Pertanian (%)', controllers['Pertanian']!, Icons.agriculture,
                isDecimal: true),
            _buildTextField(
                'Manufaktur (%)', controllers['Manufaktur']!, Icons.factory,
                isDecimal: true),
            _buildTextField('Jasa (%)', controllers['Jasa']!, Icons.business,
                isDecimal: true),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Total harus 100%',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final total = (NumberFormatUtils.parseIndonesianNumber(
                            controllers['Pertanian']!.text) ??
                        0.0) +
                    (NumberFormatUtils.parseIndonesianNumber(
                            controllers['Manufaktur']!.text) ??
                        0.0) +
                    (NumberFormatUtils.parseIndonesianNumber(
                            controllers['Jasa']!.text) ??
                        0.0);

                if ((total - 100.0).abs() > 0.1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Total harus 100%! Saat ini: ${total.toStringAsFixed(2)}%')),
                  );
                  return;
                }

                setState(() {
                  distribusiData[year] = {
                    'Pertanian': NumberFormatUtils.parseIndonesianNumber(
                            controllers['Pertanian']!.text) ??
                        0.0,
                    'Manufaktur': NumberFormatUtils.parseIndonesianNumber(
                            controllers['Manufaktur']!.text) ??
                        0.0,
                    'Jasa': NumberFormatUtils.parseIndonesianNumber(
                            controllers['Jasa']!.text) ??
                        0.0,
                  };
                });
                _saveData();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAddYearDialog() {
    if (availableYears.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data tahun yang tersedia')),
      );
      return;
    }

    final lastYear = availableYears.last;
    final nextYear = lastYear + 1;
    final lastData = yearData[lastYear];

    if (lastData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data tahun terakhir tidak valid')),
      );
      return;
    }

    final lastIndikator = indikatorData[lastYear] ?? {};
    final lastDistribusi = distribusiData[lastYear] ??
        {'Pertanian': 2.0, 'Manufaktur': 28.0, 'Jasa': 70.0};
    final lastJateng = jatengData[lastYear] ?? {};

    final growth = 1.01;

    final mainControllers = {
      'angkatanKerja': TextEditingController(
          text: NumberFormatUtils.formatInteger(
              (lastData['angkatanKerja'] * growth).round())),
      'bekerja': TextEditingController(
          text: NumberFormatUtils.formatInteger(
              (lastData['bekerja'] * growth).round())),
      'pengangguran': TextEditingController(
          text: NumberFormatUtils.formatInteger(
              (lastData['pengangguran'] * 0.95).round())),
      'bukanAngkatanKerja': TextEditingController(
          text: NumberFormatUtils.formatInteger(
              (lastData['bukanAngkatanKerja'] * 1.005).round())),
      'tpt': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              (lastData['tpt'] * 0.95).toDouble(),
              decimalPlaces: 2)),
      'tkk': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              (lastData['tkk'] * 1.005).toDouble(),
              decimalPlaces: 2)),
      'tpak': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              lastData['tpak']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
    };

    final indikatorControllers = {
      'tptLaki': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              (lastIndikator['tptLaki'] ?? 5.0).toDouble(),
              decimalPlaces: 2)),
      'tptPerempuan': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              (lastIndikator['tptPerempuan'] ?? 6.0).toDouble(),
              decimalPlaces: 2)),
      'tptTotal': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              (lastIndikator['tptTotal'] ?? 5.5).toDouble(),
              decimalPlaces: 2)),
      'tkkLaki': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              (lastIndikator['tkkLaki'] ?? 95.0).toDouble(),
              decimalPlaces: 2)),
      'tkkPerempuan': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              (lastIndikator['tkkPerempuan'] ?? 94.0).toDouble(),
              decimalPlaces: 2)),
      'tkkTotal': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              (lastIndikator['tkkTotal'] ?? 94.5).toDouble(),
              decimalPlaces: 2)),
      'tpakLaki': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              (lastIndikator['tpakLaki'] ?? 80.0).toDouble(),
              decimalPlaces: 2)),
      'tpakPerempuan': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              (lastIndikator['tpakPerempuan'] ?? 60.0).toDouble(),
              decimalPlaces: 2)),
      'tpakTotal': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              (lastIndikator['tpakTotal'] ?? 70.0).toDouble(),
              decimalPlaces: 2)),
    };

    final distribusiControllers = {
      'Pertanian': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              lastDistribusi['Pertanian']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
      'Manufaktur': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              lastDistribusi['Manufaktur']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
      'Jasa': TextEditingController(
          text: NumberFormatUtils.formatDecimal(
              lastDistribusi['Jasa']?.toDouble() ?? 0.0,
              decimalPlaces: 2)),
    };

    final jatengControllers = {
      'bekerja': TextEditingController(
          text: NumberFormatUtils.formatInteger(
              ((lastJateng['bekerja'] ?? 20000000) * growth).round())),
      'pengangguran': TextEditingController(
          text: NumberFormatUtils.formatInteger(
              ((lastJateng['pengangguran'] ?? 1000000) * 0.98).round())),
      'bukanAngkatanKerja': TextEditingController(
          text: NumberFormatUtils.formatInteger(
              ((lastJateng['bukanAngkatanKerja'] ?? 8000000) * 1.002).round())),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Tahun $nextYear'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Data estimasi dari tahun $lastYear',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('DATA UTAMA KOTA SEMARANG',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                _buildTextField('Angkatan Kerja',
                    mainControllers['angkatanKerja']!, Icons.groups,
                    isNumber: true),
                _buildTextField(
                    'Bekerja', mainControllers['bekerja']!, Icons.work_outline,
                    isNumber: true),
                _buildTextField('Pengangguran',
                    mainControllers['pengangguran']!, Icons.trending_down,
                    isNumber: true),
                _buildTextField('Bukan Angkatan Kerja',
                    mainControllers['bukanAngkatanKerja']!, Icons.person_off,
                    isNumber: true),
                _buildTextField(
                    'TPT (%)', mainControllers['tpt']!, Icons.percent,
                    isDecimal: true),
                _buildTextField(
                    'TKK (%)', mainControllers['tkk']!, Icons.check_circle,
                    isDecimal: true),
                _buildTextField(
                    'TPAK (%)', mainControllers['tpak']!, Icons.trending_up,
                    isDecimal: true),
                const SizedBox(height: 16),
                const Text('INDIKATOR GENDER',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                _buildTextField('TPT Laki (%)',
                    indikatorControllers['tptLaki']!, Icons.male,
                    isDecimal: true),
                _buildTextField('TPT Perempuan (%)',
                    indikatorControllers['tptPerempuan']!, Icons.female,
                    isDecimal: true),
                _buildTextField('TPT Total (%)',
                    indikatorControllers['tptTotal']!, Icons.percent,
                    isDecimal: true),
                _buildTextField('TKK Laki (%)',
                    indikatorControllers['tkkLaki']!, Icons.male,
                    isDecimal: true),
                _buildTextField('TKK Perempuan (%)',
                    indikatorControllers['tkkPerempuan']!, Icons.female,
                    isDecimal: true),
                _buildTextField('TKK Total (%)',
                    indikatorControllers['tkkTotal']!, Icons.percent,
                    isDecimal: true),
                _buildTextField('TPAK Laki (%)',
                    indikatorControllers['tpakLaki']!, Icons.male,
                    isDecimal: true),
                _buildTextField('TPAK Perempuan (%)',
                    indikatorControllers['tpakPerempuan']!, Icons.female,
                    isDecimal: true),
                _buildTextField('TPAK Total (%)',
                    indikatorControllers['tpakTotal']!, Icons.percent,
                    isDecimal: true),
                const SizedBox(height: 16),
                const Text('DISTRIBUSI SEKTOR',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                _buildTextField('Pertanian (%)',
                    distribusiControllers['Pertanian']!, Icons.agriculture,
                    isDecimal: true),
                _buildTextField('Manufaktur (%)',
                    distribusiControllers['Manufaktur']!, Icons.factory,
                    isDecimal: true),
                _buildTextField(
                    'Jasa (%)', distribusiControllers['Jasa']!, Icons.business,
                    isDecimal: true),
                const SizedBox(height: 16),
                const Text('DATA JAWA TENGAH',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                _buildTextField(
                    'Bekerja Jateng', jatengControllers['bekerja']!, Icons.work,
                    isNumber: true),
                _buildTextField('Pengangguran Jateng',
                    jatengControllers['pengangguran']!, Icons.trending_down,
                    isNumber: true),
                _buildTextField('Bukan AK Jateng',
                    jatengControllers['bukanAngkatanKerja']!, Icons.person_off,
                    isNumber: true),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                if (yearData.containsKey(nextYear)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tahun sudah ada!')),
                  );
                  return;
                }

                final totalDistribusi =
                    (NumberFormatUtils.parseIndonesianNumber(
                                distribusiControllers['Pertanian']!.text) ??
                            0.0) +
                        (NumberFormatUtils.parseIndonesianNumber(
                                distribusiControllers['Manufaktur']!.text) ??
                            0.0) +
                        (NumberFormatUtils.parseIndonesianNumber(
                                distribusiControllers['Jasa']!.text) ??
                            0.0);

                if ((totalDistribusi - 100.0).abs() > 0.1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Total distribusi harus 100%! Saat ini: ${totalDistribusi.toStringAsFixed(2)}%')),
                  );
                  return;
                }

                setState(() {
                  yearData[nextYear] = {
                    'angkatanKerja': NumberFormatUtils.parseIndonesianInteger(
                            mainControllers['angkatanKerja']!.text) ??
                        0,
                    'bekerja': NumberFormatUtils.parseIndonesianInteger(
                            mainControllers['bekerja']!.text) ??
                        0,
                    'pengangguran': NumberFormatUtils.parseIndonesianInteger(
                            mainControllers['pengangguran']!.text) ??
                        0,
                    'bukanAngkatanKerja':
                        NumberFormatUtils.parseIndonesianInteger(
                                mainControllers['bukanAngkatanKerja']!.text) ??
                            0,
                    'tpt': NumberFormatUtils.parseIndonesianNumber(
                            mainControllers['tpt']!.text) ??
                        0.0,
                    'tkk': NumberFormatUtils.parseIndonesianNumber(
                            mainControllers['tkk']!.text) ??
                        0.0,
                    'tpak': NumberFormatUtils.parseIndonesianNumber(
                            mainControllers['tpak']!.text) ??
                        0.0,
                  };

                  indikatorData[nextYear] = {
                    'tptLaki': NumberFormatUtils.parseIndonesianNumber(
                            indikatorControllers['tptLaki']!.text) ??
                        0.0,
                    'tptPerempuan': NumberFormatUtils.parseIndonesianNumber(
                            indikatorControllers['tptPerempuan']!.text) ??
                        0.0,
                    'tptTotal': NumberFormatUtils.parseIndonesianNumber(
                            indikatorControllers['tptTotal']!.text) ??
                        0.0,
                    'tkkLaki': NumberFormatUtils.parseIndonesianNumber(
                            indikatorControllers['tkkLaki']!.text) ??
                        0.0,
                    'tkkPerempuan': NumberFormatUtils.parseIndonesianNumber(
                            indikatorControllers['tkkPerempuan']!.text) ??
                        0.0,
                    'tkkTotal': NumberFormatUtils.parseIndonesianNumber(
                            indikatorControllers['tkkTotal']!.text) ??
                        0.0,
                    'tpakLaki': NumberFormatUtils.parseIndonesianNumber(
                            indikatorControllers['tpakLaki']!.text) ??
                        0.0,
                    'tpakPerempuan': NumberFormatUtils.parseIndonesianNumber(
                            indikatorControllers['tpakPerempuan']!.text) ??
                        0.0,
                    'tpakTotal': NumberFormatUtils.parseIndonesianNumber(
                            indikatorControllers['tpakTotal']!.text) ??
                        0.0,
                  };

                  distribusiData[nextYear] = {
                    'Pertanian': NumberFormatUtils.parseIndonesianNumber(
                            distribusiControllers['Pertanian']!.text) ??
                        0.0,
                    'Manufaktur': NumberFormatUtils.parseIndonesianNumber(
                            distribusiControllers['Manufaktur']!.text) ??
                        0.0,
                    'Jasa': NumberFormatUtils.parseIndonesianNumber(
                            distribusiControllers['Jasa']!.text) ??
                        0.0,
                  };

                  jatengData[nextYear] = {
                    'bekerja': NumberFormatUtils.parseIndonesianInteger(
                            jatengControllers['bekerja']!.text) ??
                        0,
                    'pengangguran': NumberFormatUtils.parseIndonesianInteger(
                            jatengControllers['pengangguran']!.text) ??
                        0,
                    'bukanAngkatanKerja':
                        NumberFormatUtils.parseIndonesianInteger(
                                jatengControllers['bukanAngkatanKerja']!
                                    .text) ??
                            0,
                  };

                  availableYears = yearData.keys.toList()..sort();
                  selectedYear = nextYear;
                });

                _saveData();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✓ Tahun $nextYear berhasil ditambahkan!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int year) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus semua data tahun $year?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                yearData.remove(year);
                indikatorData.remove(year);
                distribusiData.remove(year);
                jatengData.remove(year);
                availableYears = yearData.keys.toList()..sort();
                if (availableYears.isNotEmpty && selectedYear == year) {
                  selectedYear = availableYears.last;
                }
              });
              _saveData();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // ============= HELPER WIDGETS =============

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool isNumber = false, bool isDecimal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isDecimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : (isNumber ? TextInputType.number : TextInputType.text),
        inputFormatters: isDecimal
            ? [IndonesianNumberInputFormatter(allowDecimal: true)]
            : (isNumber ? [IndonesianNumberInputFormatter()] : []),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return 'N/A';
    if (number is int) {
      return NumberFormatUtils.formatInteger(number);
    }
    return NumberFormatUtils.formatCompact(number);
  }

  // ============= BUILD UI =============

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Admin - Kelola Data Tenaga Kerja'),
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
        ),
        body: const Center(
            child: CircularProgressIndicator(color: Color(0xFF1976D2))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Admin Panel - Kelola Data Tenaga Kerja'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard, size: 18), text: 'Data Utama'),
            Tab(icon: Icon(Icons.people, size: 18), text: 'Indikator Gender'),
            Tab(
                icon: Icon(Icons.pie_chart, size: 18),
                text: 'Distribusi Sektor'),
            Tab(
                icon: Icon(Icons.calendar_today, size: 18),
                text: 'Kelola Tahun'),
            Tab(icon: Icon(Icons.settings, size: 18), text: 'Pengaturan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDataUtamaTab(),
          _buildIndikatorGenderTab(),
          _buildDistribusiSektorTab(),
          _buildKelolaTahunTab(),
          _buildPengaturanTab(),
        ],
      ),
    );
  }

  // ============= TAB VIEWS =============

  Widget _buildDataUtamaTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Color(0xFF1976D2)),
                    SizedBox(width: 8),
                    Text('Pilih Tahun',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableYears.map((year) {
                    final isSelected = year == selectedYear;
                    return GestureDetector(
                      onTap: () => setState(() => selectedYear = year),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1976D2)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$year',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Data Kota Semarang $selectedYear',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF1976D2)),
                      onPressed: () => _showEditMainDataDialog(selectedYear),
                    ),
                  ],
                ),
                const Divider(),
                _buildDataRow(
                    'Angkatan Kerja',
                    _formatNumber(yearData[selectedYear]!['angkatanKerja']),
                    Icons.groups),
                _buildDataRow(
                    'Bekerja',
                    _formatNumber(yearData[selectedYear]!['bekerja']),
                    Icons.work_outline),
                _buildDataRow(
                    'Pengangguran',
                    _formatNumber(yearData[selectedYear]!['pengangguran']),
                    Icons.trending_down),
                _buildDataRow(
                    'Bukan Angkatan Kerja',
                    _formatNumber(
                        yearData[selectedYear]!['bukanAngkatanKerja']),
                    Icons.person_off),
                _buildDataRow(
                    'TPT', '${yearData[selectedYear]!['tpt']}%', Icons.percent),
                _buildDataRow('TKK', '${yearData[selectedYear]!['tkk']}%',
                    Icons.check_circle),
                _buildDataRow('TPAK', '${yearData[selectedYear]!['tpak']}%',
                    Icons.trending_up),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey[700])),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildIndikatorGenderTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.people, color: Colors.purple),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                      'Edit data indikator ketenagakerjaan berdasarkan gender',
                      style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...availableYears.map((year) {
          final data = indikatorData[year] ?? {};
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple,
                child: Text('${year.toString().substring(2)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              title: Text('Tahun $year',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                    'TPT: ${data['tptTotal']}% | TKK: ${data['tkkTotal']}% | TPAK: ${data['tpakTotal']}%',
                    style: TextStyle(fontSize: 12)),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.purple),
                onPressed: () => _showEditIndikatorDialog(year),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDistribusiSektorTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.pie_chart, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                      'Edit data distribusi penduduk bekerja menurut lapangan usaha',
                      style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...availableYears.map((year) {
          final data = distribusiData[year] ?? {};
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text('${year.toString().substring(2)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              title: Text('Tahun $year',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                    'Pertanian: ${data['Pertanian']}% | Manufaktur: ${data['Manufaktur']}% | Jasa: ${data['Jasa']}%',
                    style: TextStyle(fontSize: 12)),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => _showEditDistribusiDialog(year),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildKelolaTahunTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 4,
          color: const Color(0xFF1976D2),
          child: InkWell(
            onTap: _showAddYearDialog,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tambah Tahun Baru',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Klik untuk menambah data tahun',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 20),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Color(0xFF1976D2)),
                    SizedBox(width: 8),
                    Text('Data Tahun Tersedia',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 4),
                Text('Kelola data tahun yang sudah ada',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...availableYears.map((year) => Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1976D2),
                  child: Text('${year.toString().substring(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                title: Text('Tahun $year',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                    'Angkatan Kerja: ${_formatNumber(yearData[year]!['angkatanKerja'])} | TPT: ${yearData[year]!['tpt']}%',
                    style: TextStyle(fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.edit, color: Colors.blue, size: 20),
                      onPressed: () => _showEditMainDataDialog(year),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _showDeleteDialog(year),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildPengaturanTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.red),
                title: const Text('Reset ke Data Default'),
                subtitle:
                    const Text('Kembalikan semua data ke pengaturan awal'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Konfirmasi Reset'),
                      content:
                          const Text('Semua perubahan akan hilang. Lanjutkan?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _initializeDefaultYearData();
                            _initializeDefaultIndikatorData();
                            _initializeDefaultDistribusiData();
                            _initializeDefaultJatengData();
                            setState(() {
                              availableYears = yearData.keys.toList()..sort();
                              selectedYear = availableYears.last;
                            });
                            _saveData();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text('Tentang'),
                subtitle: const Text('Admin Panel Tenaga Kerja v1.0'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Tentang Aplikasi'),
                      content: const SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Admin Panel untuk mengelola data tenaga kerja Kota Semarang.',
                                style: TextStyle(fontSize: 14)),
                            SizedBox(height: 16),
                            Text('Fitur:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            SizedBox(height: 8),
                            Text('✓ Edit data utama ketenagakerjaan'),
                            Text('✓ Edit indikator gender (TPT, TKK, TPAK)'),
                            Text('✓ Edit distribusi sektor lapangan usaha'),
                            Text('✓ Tambah tahun baru (2025+)'),
                            Text('✓ Hapus data tahun'),
                            Text('✓ Validasi otomatis'),
                            Text('✓ UI bersih & mudah digunakan'),
                            SizedBox(height: 16),
                            Divider(),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Versi:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('1.0',
                                    style: TextStyle(color: Colors.blue)),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Tema:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('Tenaga Kerja',
                                    style: TextStyle(color: Colors.blue)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tutup'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
