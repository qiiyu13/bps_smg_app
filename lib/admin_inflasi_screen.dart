import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminInflasiScreen extends StatefulWidget {
  const AdminInflasiScreen({Key? key}) : super(key: key);

  @override
  State<AdminInflasiScreen> createState() => _AdminInflasiScreenState();
}

class _AdminInflasiScreenState extends State<AdminInflasiScreen> {
  // Data storage keys
  static const String _monthlyDataKey = 'inflasi_monthly_data';
  static const String _yearlyDataKey = 'inflasi_yearly_data';
  static const String _coreDataKey = 'inflasi_core_data';
  static const String _ihkDataKey = 'inflasi_ihk_data';
  static const String _componentsKey = 'inflasi_components_data';

  // Default data
  Map<int, List<double>> monthlyInflationData = {
    2019: [0.32, 0.01, 0.11, -0.10, 0.48, 0.55, 0.31, -0.02, -0.27, 0.02, -0.16, 0.30],
    2020: [0.40, 0.28, 0.10, -0.10, 0.07, 0.18, -0.05, -0.05, -0.05, -0.09, 0.28, 0.45],
    2021: [0.26, 0.10, 0.08, -0.13, 0.32, 0.33, 0.21, 0.03, 0.12, 0.12, 0.37, 0.57],
    2022: [0.56, 0.64, 0.66, 0.95, 0.40, 0.56, 0.64, 0.21, 1.17, 0.12, 0.03, 0.66],
    2023: [0.34, -0.02, 0.12, -0.07, 0.09, 0.59, 0.21, 0.18, -0.04, -0.06, 0.08, 0.15],
  };

  Map<int, double> yearlyInflation = {
    2019: 2.72,
    2020: 1.68,
    2021: 1.87,
    2022: 4.21,
    2023: 2.61,
  };

  Map<int, double> coreInflation = {
    2019: 3.04,
    2020: 1.59,
    2021: 1.64,
    2022: 3.04,
    2023: 1.93,
  };

  Map<int, double> ihkData = {
    2019: 106.02,
    2020: 107.80,
    2021: 109.82,
    2022: 114.44,
    2023: 113.59,
  };

  Map<String, Map<String, double>> inflationComponents = {
    'Makanan, Minuman & Tembakau': {'2019': 4.55, '2020': 3.28, '2021': 2.84, '2022': 5.33, '2023': 4.12},
    'Pakaian & Alas Kaki': {'2019': 0.84, '2020': 0.45, '2021': 0.67, '2022': 1.23, '2023': 0.92},
    'Perumahan & Fasilitas': {'2019': 1.69, '2020': 1.45, '2021': 1.52, '2022': 2.15, '2023': 1.78},
    'Perawatan Kesehatan': {'2019': 2.43, '2020': 2.15, '2021': 2.67, '2022': 3.45, '2023': 2.89},
    'Transportasi': {'2019': 1.24, '2020': 0.89, '2021': 1.45, '2022': 4.67, '2023': 2.34},
    'Komunikasi & Keuangan': {'2019': 1.02, '2020': 0.78, '2021': 0.95, '2022': 1.34, '2023': 1.12},
    'Rekreasi & Olahraga': {'2019': 2.18, '2020': 1.67, '2021': 2.05, '2022': 2.89, '2023': 2.45},
  };

  final List<String> fullMonths = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];

  int _selectedYear = 2023;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      final monthlyDataString = prefs.getString(_monthlyDataKey);
      if (monthlyDataString != null) {
        monthlyInflationData = _parseMonthlyData(monthlyDataString);
      }
      
      final yearlyDataString = prefs.getString(_yearlyDataKey);
      if (yearlyDataString != null) {
        yearlyInflation = _parseYearlyData(yearlyDataString);
      }
      
      final coreDataString = prefs.getString(_coreDataKey);
      if (coreDataString != null) {
        coreInflation = _parseYearlyData(coreDataString);
      }
      
      final ihkDataString = prefs.getString(_ihkDataKey);
      if (ihkDataString != null) {
        ihkData = _parseYearlyData(ihkDataString);
      }
      
      final componentsString = prefs.getString(_componentsKey);
      if (componentsString != null) {
        inflationComponents = _parseComponentsData(componentsString);
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Map<int, List<double>> _parseMonthlyData(String data) {
    final Map<int, List<double>> result = {};
    final lines = data.split(';');
    
    for (final line in lines) {
      final parts = line.split(':');
      if (parts.length == 2) {
        final year = int.parse(parts[0]);
        final values = parts[1].split(',').map((e) => double.parse(e)).toList();
        result[year] = values;
      }
    }
    
    return result;
  }

  Map<int, double> _parseYearlyData(String data) {
    final Map<int, double> result = {};
    final lines = data.split(';');
    
    for (final line in lines) {
      final parts = line.split(':');
      if (parts.length == 2) {
        final year = int.parse(parts[0]);
        final value = double.parse(parts[1]);
        result[year] = value;
      }
    }
    
    return result;
  }

  Map<String, Map<String, double>> _parseComponentsData(String data) {
    final Map<String, Map<String, double>> result = {};
    final lines = data.split(';');
    
    for (final line in lines) {
      final parts = line.split(':');
      if (parts.length == 2) {
        final componentName = parts[0];
        final yearData = parts[1].split(',');
        final Map<String, double> componentData = {};
        
        for (final yearValue in yearData) {
          final yearParts = yearValue.split('=');
          if (yearParts.length == 2) {
            componentData[yearParts[0]] = double.parse(yearParts[1]);
          }
        }
        
        result[componentName] = componentData;
      }
    }
    
    return result;
  }

  Future<void> _saveData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      final monthlyDataString = monthlyInflationData.entries
          .map((e) => '${e.key}:${e.value.join(",")}')
          .join(';');
      await prefs.setString(_monthlyDataKey, monthlyDataString);
      
      final yearlyDataString = yearlyInflation.entries
          .map((e) => '${e.key}:${e.value}')
          .join(';');
      await prefs.setString(_yearlyDataKey, yearlyDataString);
      
      final coreDataString = coreInflation.entries
          .map((e) => '${e.key}:${e.value}')
          .join(';');
      await prefs.setString(_coreDataKey, coreDataString);
      
      final ihkDataString = ihkData.entries
          .map((e) => '${e.key}:${e.value}')
          .join(';');
      await prefs.setString(_ihkDataKey, ihkDataString);
      
      final componentsString = inflationComponents.entries
          .map((e) => '${e.key}:${e.value.entries.map((y) => '${y.key}=${y.value}').join(",")}')
          .join(';');
      await prefs.setString(_componentsKey, componentsString);
      
      _showSuccessSnackbar('Data berhasil disimpan!');
    } catch (e) {
      _showErrorSnackbar('Gagal menyimpan data: $e');
    }
  }

  Future<void> _resetData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Data'),
        content: const Text('Apakah Anda yakin ingin mengembalikan data ke nilai default? Data yang telah diubah akan hilang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        monthlyInflationData = {
          2019: [0.32, 0.01, 0.11, -0.10, 0.48, 0.55, 0.31, -0.02, -0.27, 0.02, -0.16, 0.30],
          2020: [0.40, 0.28, 0.10, -0.10, 0.07, 0.18, -0.05, -0.05, -0.05, -0.09, 0.28, 0.45],
          2021: [0.26, 0.10, 0.08, -0.13, 0.32, 0.33, 0.21, 0.03, 0.12, 0.12, 0.37, 0.57],
          2022: [0.56, 0.64, 0.66, 0.95, 0.40, 0.56, 0.64, 0.21, 1.17, 0.12, 0.03, 0.66],
          2023: [0.34, -0.02, 0.12, -0.07, 0.09, 0.59, 0.21, 0.18, -0.04, -0.06, 0.08, 0.15],
        };
        yearlyInflation = {2019: 2.72, 2020: 1.68, 2021: 1.87, 2022: 4.21, 2023: 2.61};
        coreInflation = {2019: 3.04, 2020: 1.59, 2021: 1.64, 2022: 3.04, 2023: 1.93};
        ihkData = {2019: 106.02, 2020: 107.80, 2021: 109.82, 2022: 114.44, 2023: 113.59};
        inflationComponents = {
          'Makanan, Minuman & Tembakau': {'2019': 4.55, '2020': 3.28, '2021': 2.84, '2022': 5.33, '2023': 4.12},
          'Pakaian & Alas Kaki': {'2019': 0.84, '2020': 0.45, '2021': 0.67, '2022': 1.23, '2023': 0.92},
          'Perumahan & Fasilitas': {'2019': 1.69, '2020': 1.45, '2021': 1.52, '2022': 2.15, '2023': 1.78},
          'Perawatan Kesehatan': {'2019': 2.43, '2020': 2.15, '2021': 2.67, '2022': 3.45, '2023': 2.89},
          'Transportasi': {'2019': 1.24, '2020': 0.89, '2021': 1.45, '2022': 4.67, '2023': 2.34},
          'Komunikasi & Keuangan': {'2019': 1.02, '2020': 0.78, '2021': 0.95, '2022': 1.34, '2023': 1.12},
          'Rekreasi & Olahraga': {'2019': 2.18, '2020': 1.67, '2021': 2.05, '2022': 2.89, '2023': 2.45},
        };
      });
      
      _saveData();
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editMonthlyData() {
    final yearData = monthlyInflationData[_selectedYear];
    if (yearData == null) return;

    final List<TextEditingController> controllers = yearData
        .map((value) => TextEditingController(text: value.toStringAsFixed(2)))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Data Bulanan $_selectedYear'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(12, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          fullMonths[index],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: controllers[index],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Nilai (%)',
                            border: const OutlineInputBorder(),
                            suffixText: '%',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final List<double> newData = controllers
                    .map((controller) => double.parse(controller.text))
                    .toList();

                setState(() {
                  monthlyInflationData[_selectedYear] = newData;
                  final avg = newData.fold(0.0, (sum, value) => sum + value) / 12;
                  yearlyInflation[_selectedYear] = double.parse(avg.toStringAsFixed(2));
                });

                _saveData();
                Navigator.of(context).pop();
                _showSuccessSnackbar('Data bulanan berhasil diperbarui!');
              } catch (e) {
                _showErrorSnackbar('Format angka tidak valid');
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _editYearlyData(String title, Map<int, double> data, Function(Map<int, double>) onUpdate) {
    final List<TextEditingController> controllers = [];
    final years = data.keys.toList()..sort();

    for (final year in years) {
      controllers.add(TextEditingController(text: data[year]?.toStringAsFixed(2) ?? ''));
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(years.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          years[index].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: controllers[index],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Nilai ${title.contains('IHK') ? '' : '(%)'}',
                            border: const OutlineInputBorder(),
                            suffixText: title.contains('IHK') ? '' : '%',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final Map<int, double> newData = {};
                for (int i = 0; i < years.length; i++) {
                  newData[years[i]] = double.parse(controllers[i].text);
                }

                onUpdate(newData);
                _saveData();
                Navigator.of(context).pop();
                _showSuccessSnackbar('Data berhasil diperbarui!');
              } catch (e) {
                _showErrorSnackbar('Format angka tidak valid');
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _addYear() {
    final controller = TextEditingController();
    final monthControllers = List.generate(12, (_) => TextEditingController());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Tahun Baru'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tahun',
                    border: OutlineInputBorder(),
                    hintText: 'Contoh: 2024',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Data Inflasi Bulanan:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...List.generate(12, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(fullMonths[index]),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: monthControllers[index],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: '%',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final year = int.parse(controller.text);
                if (year < 2000 || year > 2100) {
                  _showErrorSnackbar('Tahun harus antara 2000-2100');
                  return;
                }

                final List<double> monthlyData = monthControllers
                    .map((c) => double.parse(c.text))
                    .toList();

                setState(() {
                  monthlyInflationData[year] = monthlyData;
                  final avg = monthlyData.fold(0.0, (sum, value) => sum + value) / 12;
                  yearlyInflation[year] = double.parse(avg.toStringAsFixed(2));
                  coreInflation[year] = 0.0;
                  ihkData[year] = 0.0;
                  
                  for (final component in inflationComponents.keys) {
                    inflationComponents[component]![year.toString()] = 0.0;
                  }
                });

                _saveData();
                Navigator.of(context).pop();
                _showSuccessSnackbar('Tahun $year berhasil ditambahkan!');
              } catch (e) {
                _showErrorSnackbar('Format angka tidak valid');
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _deleteYear() {
    final years = monthlyInflationData.keys.toList()..sort();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tahun'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: years.length,
            itemBuilder: (context, index) {
              final year = years[index];
              return ListTile(
                title: Text('Tahun $year'),
                subtitle: Text('Inflasi: ${yearlyInflation[year]?.toStringAsFixed(2)}%'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _confirmDeleteYear(year);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteYear(int year) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus semua data tahun $year?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                monthlyInflationData.remove(year);
                yearlyInflation.remove(year);
                coreInflation.remove(year);
                ihkData.remove(year);
                
                for (final component in inflationComponents.keys) {
                  inflationComponents[component]!.remove(year.toString());
                }
              });

              _saveData();
              Navigator.of(context)
                ..pop()
                ..pop();
              _showSuccessSnackbar('Tahun $year berhasil dihapus!');
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

  void _editComponents() {
    final components = inflationComponents.keys.toList();
    final years = inflationComponents[components.first]?.keys.toList() ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Komponen Inflasi'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  isScrollable: true,
                  indicator: BoxDecoration(
                    color: const Color(0xFF3F51B5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[700],
                  tabs: components.map((e) {
                    final icon = _getComponentIcon(e);
                    return Tab(
                      icon: Icon(icon, size: 18),
                      text: e.split(' ').first,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: components.map((component) {
                    final componentData = inflationComponents[component]!;
                    final controllers = years.map((year) {
                      return TextEditingController(
                        text: componentData[year]?.toStringAsFixed(2) ?? '',
                      );
                    }).toList();

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              component,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(years.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: Text(years[index]),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: controllers[index],
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Nilai (%)',
                                        border: OutlineInputBorder(),
                                        suffixText: '%',
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              try {
                                final Map<String, double> newData = {};
                                for (int i = 0; i < years.length; i++) {
                                  newData[years[i]] = double.parse(controllers[i].text);
                                }

                                setState(() {
                                  inflationComponents[component] = newData;
                                });

                                _saveData();
                                _showSuccessSnackbar('Data komponen berhasil diperbarui!');
                              } catch (e) {
                                _showErrorSnackbar('Format angka tidak valid');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3F51B5),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('Simpan Komponen Ini'),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  IconData _getComponentIcon(String component) {
    switch (component) {
      case 'Makanan, Minuman & Tembakau':
        return Icons.restaurant;
      case 'Pakaian & Alas Kaki':
        return Icons.checkroom;
      case 'Perumahan & Fasilitas':
        return Icons.home;
      case 'Perawatan Kesehatan':
        return Icons.local_hospital;
      case 'Transportasi':
        return Icons.directions_car;
      case 'Komunikasi & Keuangan':
        return Icons.phone_iphone;
      case 'Rekreasi & Olahraga':
        return Icons.sports_soccer;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Inflasi'),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveData,
            tooltip: 'Simpan Perubahan',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F51B5)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Memuat data...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Info
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.trending_up, color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Kelola Data Inflasi',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tahun yang dipilih: $_selectedYear',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                'Inflasi: ${yearlyInflation[_selectedYear]?.toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Action Buttons
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.settings, color: Color(0xFF3F51B5)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Aksi Utama',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildActionButton(
                                    'Tambah Tahun',
                                    Icons.add_circle,
                                    Colors.green,
                                    _addYear,
                                  ),
                                  _buildActionButton(
                                    'Hapus Tahun',
                                    Icons.remove_circle,
                                    Colors.red,
                                    _deleteYear,
                                  ),
                                  _buildActionButton(
                                    'Reset Data',
                                    Icons.restore,
                                    Colors.orange,
                                    _resetData,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tahun Filter
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.filter_list, color: Color(0xFF3F51B5)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Pilih Tahun',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 40,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: (monthlyInflationData.keys.toList()..sort()).length,
                                  itemBuilder: (context, index) {
                                    final year = (monthlyInflationData.keys.toList()..sort())[index];
                                    final isSelected = year == _selectedYear;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(
                                          year.toString(),
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          setState(() {
                                            _selectedYear = year;
                                          });
                                        },
                                        selectedColor: const Color(0xFF3F51B5),
                                        backgroundColor: Colors.grey[100],
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: isSelected ? const Color(0xFF3F51B5) : Colors.grey[300]!,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Edit Sections Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.3,
                        children: [
                          _buildEditCard(
                            'Data Bulanan',
                            'Edit data inflasi bulanan',
                            Icons.calendar_month,
                            Colors.blue,
                            _editMonthlyData,
                          ),
                          _buildEditCard(
                            'Data Tahunan',
                            'Edit data inflasi tahunan',
                            Icons.timeline,
                            Colors.green,
                            () => _editYearlyData('Inflasi Tahunan', yearlyInflation, (newData) {
                              setState(() => yearlyInflation = newData);
                            }),
                          ),
                          _buildEditCard(
                            'Inflasi Inti',
                            'Edit data inflasi inti',
                            Icons.insights,
                            Colors.purple,
                            () => _editYearlyData('Inflasi Inti', coreInflation, (newData) {
                              setState(() => coreInflation = newData);
                            }),
                          ),
                          _buildEditCard(
                            'Data IHK',
                            'Edit Indeks Harga Konsumen',
                            Icons.assessment,
                            Colors.orange,
                            () => _editYearlyData('IHK', ihkData, (newData) {
                              setState(() => ihkData = newData);
                            }),
                          ),
                          _buildEditCard(
                            'Komponen',
                            'Edit komponen inflasi',
                            Icons.pie_chart,
                            Colors.red,
                            _editComponents,
                          ),
                          _buildEditCard(
                            'Quick Save',
                            'Simpan semua perubahan',
                            Icons.save,
                            Colors.teal,
                            _saveData,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Preview Data
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.preview, color: Color(0xFF3F51B5)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Preview Data',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildPreviewItem('Tahun', '$_selectedYear'),
                              _buildPreviewItem('Inflasi Tahunan', '${yearlyInflation[_selectedYear]?.toStringAsFixed(2)}%'),
                              _buildPreviewItem('Inflasi Inti', '${coreInflation[_selectedYear]?.toStringAsFixed(2)}%'),
                              _buildPreviewItem('IHK', ihkData[_selectedYear]?.toStringAsFixed(2) ?? '0.00'),
                              const SizedBox(height: 8),
                              const Text(
                                'Data Bulanan:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Text(
                                  monthlyInflationData[_selectedYear]
                                      ?.map((e) => e.toStringAsFixed(2))
                                      .join(', ') ?? 'Tidak ada data',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(100, 40),
      ),
    );
  }

  Widget _buildEditCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: color,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}