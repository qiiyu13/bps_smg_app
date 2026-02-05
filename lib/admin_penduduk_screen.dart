import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AdminPendudukScreen extends StatefulWidget {
  const AdminPendudukScreen({Key? key}) : super(key: key);

  @override
  State<AdminPendudukScreen> createState() => _AdminPendudukScreenState();
}

class _AdminPendudukScreenState extends State<AdminPendudukScreen> with SingleTickerProviderStateMixin {
  Map<int, Map<String, dynamic>> pendudukData = {};
  Map<int, Map<String, dynamic>> ageDistributionData = {};
  Map<int, List<Map<String, dynamic>>> districtDensityData = {};
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
      
      String? savedData = prefs.getString('penduduk_data');
      if (savedData != null) {
        Map<String, dynamic> decoded = json.decode(savedData);
        pendudukData = decoded.map((key, value) => 
          MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map))
        );
      } else {
        _initializeDefaultData();
      }

      String? savedAgeData = prefs.getString('age_distribution_data');
      if (savedAgeData != null) {
        Map<String, dynamic> decoded = json.decode(savedAgeData);
        ageDistributionData = decoded.map((key, value) => 
          MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map))
        );
      } else {
        _initializeDefaultAgeData();
      }

      String? savedDistrictData = prefs.getString('district_density_data');
      if (savedDistrictData != null) {
        Map<String, dynamic> decoded = json.decode(savedDistrictData);
        districtDensityData = decoded.map((key, value) {
          List<dynamic> districts = value as List<dynamic>;
          return MapEntry(int.parse(key), 
            districts.map((d) => Map<String, dynamic>.from(d as Map)).toList()
          );
        });
      } else {
        _initializeDefaultDistrictData();
      }
      
      setState(() {
        availableYears = pendudukData.keys.toList()..sort();
        if (availableYears.isNotEmpty) {
          selectedYear = availableYears.last;
        }
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      _initializeDefaultData();
      _initializeDefaultAgeData();
      _initializeDefaultDistrictData();
      setState(() {
        availableYears = pendudukData.keys.toList()..sort();
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
      
      await prefs.setString('penduduk_data', 
        json.encode(pendudukData.map((k, v) => MapEntry(k.toString(), v)))
      );
      await prefs.setString('age_distribution_data', 
        json.encode(ageDistributionData.map((k, v) => MapEntry(k.toString(), v)))
      );
      await prefs.setString('district_density_data', 
        json.encode(districtDensityData.map((k, v) => MapEntry(k.toString(), v)))
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
  
  void _initializeDefaultData() {
    pendudukData = {
      2020: {'population': 1653524, 'malePopulation': 818441, 'femalePopulation': 835083, 'area': 373.7, 'density': 4425, 'districts': 16, 'villages': 177, 'growthRate': 0.0},
      2021: {'population': 1656564, 'malePopulation': 819785, 'femalePopulation': 836779, 'area': 374.0, 'density': 4433, 'districts': 16, 'villages': 177, 'growthRate': 0.18},
      2022: {'population': 1659975, 'malePopulation': 821305, 'femalePopulation': 838670, 'area': 374.0, 'density': 4442, 'districts': 16, 'villages': 177, 'growthRate': 0.21},
      2023: {'population': 1694743, 'malePopulation': 838437, 'femalePopulation': 856306, 'area': 374.0, 'density': 4535, 'districts': 16, 'villages': 177, 'growthRate': 2.09},
      2024: {'population': 1708833, 'malePopulation': 845177, 'femalePopulation': 863656, 'area': 374.0, 'density': 4573, 'districts': 16, 'villages': 177, 'growthRate': 0.83},
    };
  }

  void _initializeDefaultAgeData() {
    ageDistributionData = {
      2020: {'usiaMuda': 367018, 'usiaMudaPercentage': 22.20, 'usiaProduktif': 1182010, 'usiaProduktifPercentage': 71.48, 'usiaTua': 104496, 'usiaTuaPercentage': 6.32},
      2021: {'usiaMuda': 363757, 'usiaMudaPercentage': 21.96, 'usiaProduktif': 1182986, 'usiaProduktifPercentage': 71.41, 'usiaTua': 109821, 'usiaTuaPercentage': 6.63},
      2022: {'usiaMuda': 360777, 'usiaMudaPercentage': 21.73, 'usiaProduktif': 1183941, 'usiaProduktifPercentage': 71.32, 'usiaTua': 115257, 'usiaTuaPercentage': 6.94},
      2023: {'usiaMuda': 359130, 'usiaMudaPercentage': 21.19, 'usiaProduktif': 1207250, 'usiaProduktifPercentage': 71.23, 'usiaTua': 128400, 'usiaTuaPercentage': 7.58},
      2024: {'usiaMuda': 356758, 'usiaMudaPercentage': 20.88, 'usiaProduktif': 1214892, 'usiaProduktifPercentage': 71.09, 'usiaTua': 137183, 'usiaTuaPercentage': 8.03},
    };
  }

  void _initializeDefaultDistrictData() {
    districtDensityData = {
      2020: [
        {'name': 'Pedurungan', 'density': 9322, 'population': 193.151},
        {'name': 'Tembalang', 'density': 4291, 'population': 189.680},
        {'name': 'Semarang Barat', 'density': 6848, 'population': 148.879},
        {'name': 'Banyumanik', 'density': 5530, 'population': 142.076},
        {'name': 'Ngaliyan', 'density': 3731, 'population': 141.727},
      ],
      2021: [
        {'name': 'Pedurungan', 'density': 9321, 'population': 193.128},
        {'name': 'Tembalang', 'density': 4334, 'population': 191.560},
        {'name': 'Semarang Barat', 'density': 6802, 'population': 147.885},
        {'name': 'Ngaliyan', 'density': 3741, 'population': 142.131},
        {'name': 'Banyumanik', 'density': 5515, 'population': 141.689},
      ],
      2022: [
        {'name': 'Tembalang', 'density': 4377, 'population': 193.480},
        {'name': 'Pedurungan', 'density': 9321, 'population': 193.125},
        {'name': 'Semarang Barat', 'density': 6758, 'population': 146.915},
        {'name': 'Ngaliyan', 'density': 3752, 'population': 142.553},
        {'name': 'Banyumanik', 'density': 5501, 'population': 141.319},
      ],
      2023: [
        {'name': 'Tembalang', 'density': 4499, 'population': 198.862},
        {'name': 'Pedurungan', 'density': 9485, 'population': 196.526},
        {'name': 'Semarang Barat', 'density': 6869, 'population': 149.326},
        {'name': 'Ngaliyan', 'density': 3830, 'population': 145.495},
        {'name': 'Banyumanik', 'density': 5583, 'population': 143.433},
      ],
      2024: [
        {'name': 'Tembalang', 'density': 4566, 'population': 201.821},
        {'name': 'Pedurungan', 'density': 9530, 'population': 197.468},
        {'name': 'Semarang Barat', 'density': 6869, 'population': 149.327},
        {'name': 'Ngaliyan', 'density': 3860, 'population': 146.628},
        {'name': 'Banyumanik', 'density': 5595, 'population': 143.746},
      ],
    };
  }

  // ============= EDIT DIALOGS =============
  
  void _showEditMainDataDialog(int year) {
    final data = pendudukData[year] ?? {};
    final controllers = {
      'population': TextEditingController(text: '${data['population'] ?? 0}'),
      'malePopulation': TextEditingController(text: '${data['malePopulation'] ?? 0}'),
      'femalePopulation': TextEditingController(text: '${data['femalePopulation'] ?? 0}'),
      'area': TextEditingController(text: '${data['area'] ?? 374.0}'),
      'density': TextEditingController(text: '${data['density'] ?? 0}'),
      'districts': TextEditingController(text: '${data['districts'] ?? 16}'),
      'villages': TextEditingController(text: '${data['villages'] ?? 177}'),
      'growthRate': TextEditingController(text: '${data['growthRate'] ?? 0.0}'),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Data Tahun $year'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Total Penduduk', controllers['population']!, Icons.people, isNumber: true),
              _buildTextField('Laki-laki', controllers['malePopulation']!, Icons.male, isNumber: true),
              _buildTextField('Perempuan', controllers['femalePopulation']!, Icons.female, isNumber: true),
              _buildTextField('Luas Area (km²)', controllers['area']!, Icons.map, isDecimal: true),
              _buildTextField('Kepadatan (jiwa/km²)', controllers['density']!, Icons.density_medium, isNumber: true),
              _buildTextField('Jumlah Kecamatan', controllers['districts']!, Icons.location_city, isNumber: true),
              _buildTextField('Jumlah Kelurahan', controllers['villages']!, Icons.home_work, isNumber: true),
              _buildTextField('Laju Pertumbuhan (%)', controllers['growthRate']!, Icons.trending_up, isDecimal: true),
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
                  pendudukData[year] = {
                    'population': int.parse(controllers['population']!.text),
                    'malePopulation': int.parse(controllers['malePopulation']!.text),
                    'femalePopulation': int.parse(controllers['femalePopulation']!.text),
                    'area': double.parse(controllers['area']!.text),
                    'density': int.parse(controllers['density']!.text),
                    'districts': int.parse(controllers['districts']!.text),
                    'villages': int.parse(controllers['villages']!.text),
                    'growthRate': double.parse(controllers['growthRate']!.text),
                  };
                });
                _saveData();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF795548),
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditAgeDialog(int year) {
    final data = ageDistributionData[year] ?? {};
    final controllers = {
      'usiaMuda': TextEditingController(text: '${data['usiaMuda'] ?? 0}'),
      'usiaMudaPercentage': TextEditingController(text: '${data['usiaMudaPercentage'] ?? 0.0}'),
      'usiaProduktif': TextEditingController(text: '${data['usiaProduktif'] ?? 0}'),
      'usiaProduktifPercentage': TextEditingController(text: '${data['usiaProduktifPercentage'] ?? 0.0}'),
      'usiaTua': TextEditingController(text: '${data['usiaTua'] ?? 0}'),
      'usiaTuaPercentage': TextEditingController(text: '${data['usiaTuaPercentage'] ?? 0.0}'),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Distribusi Umur $year'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Usia Muda (0-14)', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTextField('Jumlah', controllers['usiaMuda']!, Icons.child_care, isNumber: true),
              _buildTextField('Persentase (%)', controllers['usiaMudaPercentage']!, Icons.percent, isDecimal: true),
              const SizedBox(height: 12),
              const Text('Usia Produktif (15-64)', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTextField('Jumlah', controllers['usiaProduktif']!, Icons.work, isNumber: true),
              _buildTextField('Persentase (%)', controllers['usiaProduktifPercentage']!, Icons.percent, isDecimal: true),
              const SizedBox(height: 12),
              const Text('Usia Tua (65+)', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTextField('Jumlah', controllers['usiaTua']!, Icons.elderly, isNumber: true),
              _buildTextField('Persentase (%)', controllers['usiaTuaPercentage']!, Icons.percent, isDecimal: true),
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
                final total = double.parse(controllers['usiaMudaPercentage']!.text) +
                    double.parse(controllers['usiaProduktifPercentage']!.text) +
                    double.parse(controllers['usiaTuaPercentage']!.text);
                
                if ((total - 100.0).abs() > 0.1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Total harus 100%! Saat ini: ${total.toStringAsFixed(2)}%')),
                  );
                  return;
                }

                setState(() {
                  ageDistributionData[year] = {
                    'usiaMuda': int.parse(controllers['usiaMuda']!.text),
                    'usiaMudaPercentage': double.parse(controllers['usiaMudaPercentage']!.text),
                    'usiaProduktif': int.parse(controllers['usiaProduktif']!.text),
                    'usiaProduktifPercentage': double.parse(controllers['usiaProduktifPercentage']!.text),
                    'usiaTua': int.parse(controllers['usiaTua']!.text),
                    'usiaTuaPercentage': double.parse(controllers['usiaTuaPercentage']!.text),
                  };
                });
                _saveData();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF795548),
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditDistrictDialog(int year, int index) {
    final districts = districtDensityData[year] ?? [];
    if (index >= districts.length) return;
    
    final district = districts[index];
    final controllers = {
      'name': TextEditingController(text: '${district['name']}'),
      'density': TextEditingController(text: '${district['density']}'),
      'population': TextEditingController(text: '${district['population']}'),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${district['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('Nama Kecamatan', controllers['name']!, Icons.location_city),
            _buildTextField('Kepadatan', controllers['density']!, Icons.density_medium, isNumber: true),
            _buildTextField('Populasi (ribu)', controllers['population']!, Icons.people, isDecimal: true),
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
                setState(() {
                  districtDensityData[year]![index] = {
                    'name': controllers['name']!.text,
                    'density': int.parse(controllers['density']!.text),
                    'population': double.parse(controllers['population']!.text),
                  };
                });
                _saveData();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF795548),
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
    final lastData = pendudukData[lastYear];
    
    if (lastData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data tahun terakhir tidak valid')),
      );
      return;
    }
    
    final lastAge = ageDistributionData[lastYear] ?? {
      'usiaMuda': 0,
      'usiaMudaPercentage': 20.0,
      'usiaProduktif': 0,
      'usiaProduktifPercentage': 70.0,
      'usiaTua': 0,
      'usiaTuaPercentage': 10.0,
    };
    
    final lastDistricts = districtDensityData[lastYear] ?? [];
    final growth = 1.005;
    
    final mainControllers = {
      'population': TextEditingController(text: '${(lastData['population'] * growth).round()}'),
      'malePopulation': TextEditingController(text: '${(lastData['malePopulation'] * growth).round()}'),
      'femalePopulation': TextEditingController(text: '${(lastData['femalePopulation'] * growth).round()}'),
      'area': TextEditingController(text: '${lastData['area']}'),
      'density': TextEditingController(text: '${(lastData['density'] * growth).round()}'),
      'districts': TextEditingController(text: '${lastData['districts']}'),
      'villages': TextEditingController(text: '${lastData['villages']}'),
      'growthRate': TextEditingController(text: '0.5'),
    };
    
    final ageControllers = {
      'usiaMuda': TextEditingController(text: '${((lastAge['usiaMuda'] ?? 0) * growth).round()}'),
      'usiaMudaPercentage': TextEditingController(text: '${lastAge['usiaMudaPercentage'] ?? 20.0}'),
      'usiaProduktif': TextEditingController(text: '${((lastAge['usiaProduktif'] ?? 0) * growth).round()}'),
      'usiaProduktifPercentage': TextEditingController(text: '${lastAge['usiaProduktifPercentage'] ?? 70.0}'),
      'usiaTua': TextEditingController(text: '${((lastAge['usiaTua'] ?? 0) * growth).round()}'),
      'usiaTuaPercentage': TextEditingController(text: '${lastAge['usiaTuaPercentage'] ?? 10.0}'),
    };
    
    final districtControllers = List.generate(5, (i) {
      if (i < lastDistricts.length) {
        return {
          'name': TextEditingController(text: '${lastDistricts[i]['name']}'),
          'density': TextEditingController(text: '${(lastDistricts[i]['density'] * growth).round()}'),
          'population': TextEditingController(text: '${(lastDistricts[i]['population'] * growth).toStringAsFixed(3)}'),
        };
      }
      return {
        'name': TextEditingController(text: 'Kecamatan ${i + 1}'),
        'density': TextEditingController(text: '4500'),
        'population': TextEditingController(text: '150.000'),
      };
    });

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
                    'Data estimasi dari tahun $lastYear (pertumbuhan +0.5%)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('DATA UTAMA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                _buildTextField('Populasi', mainControllers['population']!, Icons.people, isNumber: true),
                _buildTextField('Laki-laki', mainControllers['malePopulation']!, Icons.male, isNumber: true),
                _buildTextField('Perempuan', mainControllers['femalePopulation']!, Icons.female, isNumber: true),
                _buildTextField('Area (km²)', mainControllers['area']!, Icons.map, isDecimal: true),
                _buildTextField('Kepadatan', mainControllers['density']!, Icons.density_medium, isNumber: true),
                _buildTextField('Kecamatan', mainControllers['districts']!, Icons.location_city, isNumber: true),
                _buildTextField('Kelurahan', mainControllers['villages']!, Icons.home_work, isNumber: true),
                _buildTextField('Growth Rate (%)', mainControllers['growthRate']!, Icons.trending_up, isDecimal: true),
                const SizedBox(height: 16),
                const Text('DISTRIBUSI UMUR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                _buildTextField('Usia Muda', ageControllers['usiaMuda']!, Icons.child_care, isNumber: true),
                _buildTextField('Usia Muda %', ageControllers['usiaMudaPercentage']!, Icons.percent, isDecimal: true),
                _buildTextField('Usia Produktif', ageControllers['usiaProduktif']!, Icons.work, isNumber: true),
                _buildTextField('Usia Produktif %', ageControllers['usiaProduktifPercentage']!, Icons.percent, isDecimal: true),
                _buildTextField('Usia Tua', ageControllers['usiaTua']!, Icons.elderly, isNumber: true),
                _buildTextField('Usia Tua %', ageControllers['usiaTuaPercentage']!, Icons.percent, isDecimal: true),
                const SizedBox(height: 16),
                const Text('5 KECAMATAN TERPADAT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                ...List.generate(5, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kecamatan ${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      _buildTextField('Nama', districtControllers[i]['name']!, Icons.location_city),
                      _buildTextField('Kepadatan', districtControllers[i]['density']!, Icons.density_medium, isNumber: true),
                      _buildTextField('Populasi (ribu)', districtControllers[i]['population']!, Icons.people, isDecimal: true),
                      if (i < 4) const Divider(height: 16),
                    ],
                  ),
                )),
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
                if (pendudukData.containsKey(nextYear)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tahun sudah ada!')),
                  );
                  return;
                }

                final totalPercentage = double.parse(ageControllers['usiaMudaPercentage']!.text) +
                    double.parse(ageControllers['usiaProduktifPercentage']!.text) +
                    double.parse(ageControllers['usiaTuaPercentage']!.text);
                
                if ((totalPercentage - 100.0).abs() > 0.1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Total % harus 100! Saat ini: ${totalPercentage.toStringAsFixed(2)}%')),
                  );
                  return;
                }

                setState(() {
                  pendudukData[nextYear] = {
                    'population': int.parse(mainControllers['population']!.text),
                    'malePopulation': int.parse(mainControllers['malePopulation']!.text),
                    'femalePopulation': int.parse(mainControllers['femalePopulation']!.text),
                    'area': double.parse(mainControllers['area']!.text),
                    'density': int.parse(mainControllers['density']!.text),
                    'districts': int.parse(mainControllers['districts']!.text),
                    'villages': int.parse(mainControllers['villages']!.text),
                    'growthRate': double.parse(mainControllers['growthRate']!.text),
                  };

                  ageDistributionData[nextYear] = {
                    'usiaMuda': int.parse(ageControllers['usiaMuda']!.text),
                    'usiaMudaPercentage': double.parse(ageControllers['usiaMudaPercentage']!.text),
                    'usiaProduktif': int.parse(ageControllers['usiaProduktif']!.text),
                    'usiaProduktifPercentage': double.parse(ageControllers['usiaProduktifPercentage']!.text),
                    'usiaTua': int.parse(ageControllers['usiaTua']!.text),
                    'usiaTuaPercentage': double.parse(ageControllers['usiaTuaPercentage']!.text),
                  };

                  districtDensityData[nextYear] = List.generate(5, (i) => {
                    'name': districtControllers[i]['name']!.text,
                    'density': int.parse(districtControllers[i]['density']!.text),
                    'population': double.parse(districtControllers[i]['population']!.text),
                  });

                  availableYears = pendudukData.keys.toList()..sort();
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
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF795548),
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
                pendudukData.remove(year);
                ageDistributionData.remove(year);
                districtDensityData.remove(year);
                availableYears = pendudukData.keys.toList()..sort();
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
  
  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, bool isDecimal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isDecimal ? const TextInputType.numberWithOptions(decimal: true) : (isNumber ? TextInputType.number : TextInputType.text),
        inputFormatters: isDecimal 
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
            : (isNumber ? [FilteringTextInputFormatter.digitsOnly] : []),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return 'N/A';
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // ============= BUILD UI =============
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Admin - Kelola Data'),
          backgroundColor: const Color(0xFF795548),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF795548))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Admin Panel - Kelola Data Penduduk'),
        backgroundColor: const Color(0xFF795548),
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
            Tab(icon: Icon(Icons.pie_chart, size: 18), text: 'Distribusi Umur'),
            Tab(icon: Icon(Icons.location_on, size: 18), text: 'Kecamatan'),
            Tab(icon: Icon(Icons.calendar_today, size: 18), text: 'Kelola Tahun'),
            Tab(icon: Icon(Icons.settings, size: 18), text: 'Pengaturan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDataUtamaTab(),
          _buildDistribusiUmurTab(),
          _buildKecamatanTab(),
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
                    Icon(Icons.calendar_today, color: Color(0xFF795548)),
                    SizedBox(width: 8),
                    Text('Pilih Tahun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF795548) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$year',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                    Text('Data Tahun $selectedYear', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF795548)),
                      onPressed: () => _showEditMainDataDialog(selectedYear),
                    ),
                  ],
                ),
                const Divider(),
                _buildDataRow('Populasi', _formatNumber(pendudukData[selectedYear]!['population']), Icons.people),
                _buildDataRow('Laki-laki', _formatNumber(pendudukData[selectedYear]!['malePopulation']), Icons.male),
                _buildDataRow('Perempuan', _formatNumber(pendudukData[selectedYear]!['femalePopulation']), Icons.female),
                _buildDataRow('Area', '${pendudukData[selectedYear]!['area']} km²', Icons.map),
                _buildDataRow('Kepadatan', '${_formatNumber(pendudukData[selectedYear]!['density'])} jiwa/km²', Icons.density_medium),
                _buildDataRow('Kecamatan', '${pendudukData[selectedYear]!['districts']}', Icons.location_city),
                _buildDataRow('Kelurahan', '${pendudukData[selectedYear]!['villages']}', Icons.home_work),
                _buildDataRow('Growth Rate', '${pendudukData[selectedYear]!['growthRate']}%', Icons.trending_up),
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

  Widget _buildDistribusiUmurTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.pie_chart, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Edit data distribusi umur untuk grafik pie chart', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...availableYears.map((year) {
          final data = ageDistributionData[year] ?? {};
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text('${year.toString().substring(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              title: Text('Tahun $year', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Muda: ${data['usiaMudaPercentage']}% | Produktif: ${data['usiaProduktifPercentage']}% | Tua: ${data['usiaTuaPercentage']}%', 
                  style: TextStyle(fontSize: 12)),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showEditAgeDialog(year),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildKecamatanTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Edit data 5 kecamatan terpadat', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...availableYears.map((year) {
          final districts = districtDensityData[year] ?? [];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Text('${year.toString().substring(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              title: Text('Tahun $year', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${districts.length} kecamatan', style: TextStyle(fontSize: 12)),
              children: List.generate(districts.length, (i) {
                final d = districts[i];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.green[100],
                    child: Text('${i + 1}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green[900])),
                  ),
                  title: Text('${d['name']}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('Density: ${d['density']} | Pop: ${d['population']} ribu', style: TextStyle(fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.green, size: 20),
                    onPressed: () => _showEditDistrictDialog(year, i),
                  ),
                );
              }),
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
          color: const Color(0xFF795548),
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
                  const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20),
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
                    Icon(Icons.calendar_today, color: Color(0xFF795548)),
                    SizedBox(width: 8),
                    Text('Data Tahun Tersedia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 4),
                Text('Kelola data tahun yang sudah ada', style: TextStyle(fontSize: 13, color: Colors.grey)),
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
              backgroundColor: const Color(0xFF795548),
              child: Text('${year.toString().substring(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            title: Text('Tahun $year', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('Populasi: ${_formatNumber(pendudukData[year]!['population'])}', style: TextStyle(fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => _showEditMainDataDialog(year),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
                subtitle: const Text('Kembalikan semua data ke pengaturan awal'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Konfirmasi Reset'),
                      content: const Text('Semua perubahan akan hilang. Lanjutkan?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _initializeDefaultData();
                            _initializeDefaultAgeData();
                            _initializeDefaultDistrictData();
                            setState(() {
                              availableYears = pendudukData.keys.toList()..sort();
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
                subtitle: const Text('Admin Panel v3.2 - Clean UI Edition'),
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
                            Text('Admin Panel untuk mengelola data penduduk Kota Semarang.', style: TextStyle(fontSize: 14)),
                            SizedBox(height: 16),
                            Text('Fitur:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            SizedBox(height: 8),
                            Text('✓ Edit data tahun'),
                            Text('✓ Edit distribusi umur'),
                            Text('✓ Edit data kecamatan'),
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
                                Text('Versi:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('3.2', style: TextStyle(color: Colors.blue)),
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