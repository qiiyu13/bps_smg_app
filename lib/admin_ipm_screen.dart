import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AdminIpmScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;
  
  const AdminIpmScreen({super.key, this.onDataChanged});

  @override
  State<AdminIpmScreen> createState() => _AdminIpmScreenState();
}

class _AdminIpmScreenState extends State<AdminIpmScreen> with SingleTickerProviderStateMixin {
  Map<int, Map<String, dynamic>> ipmData = {};
  Map<int, Map<String, dynamic>> komponenData = {};
  List<int> availableYears = [];
  int selectedYear = 2024;
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

      String? savedIpmData = prefs.getString('ipm_data');
      if (savedIpmData != null) {
        Map<String, dynamic> decoded = json.decode(savedIpmData);
        ipmData = decoded.map((key, value) =>
            MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));
      } else {
        _initializeDefaultIpmData();
      }

      String? savedKomponenData = prefs.getString('ipm_komponen_data');
      if (savedKomponenData != null) {
        Map<String, dynamic> decoded = json.decode(savedKomponenData);
        komponenData = decoded.map((key, value) =>
            MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map)));
      } else {
        _initializeDefaultKomponenData();
      }

      setState(() {
        availableYears = ipmData.keys.toList()..sort();
        if (availableYears.isNotEmpty) {
          selectedYear = availableYears.last;
        }
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      _initializeDefaultIpmData();
      _initializeDefaultKomponenData();
      setState(() {
        availableYears = ipmData.keys.toList()..sort();
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
      
      await prefs.setString('ipm_data', 
        json.encode(ipmData.map((k, v) => MapEntry(k.toString(), v)))
      );
      await prefs.setString('ipm_komponen_data', 
        json.encode(komponenData.map((k, v) => MapEntry(k.toString(), v)))
      );
      
      widget.onDataChanged?.call();
      
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
            backgroundColor: Color(0xFF4CAF50),
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
  
  void _initializeDefaultIpmData() {
    ipmData = {
      2020: {'uhh': 77.34, 'rls': 10.53, 'hls': 15.52, 'pengeluaran': 15243.00, 'ipm': 83.05},
      2021: {'uhh': 77.51, 'rls': 10.78, 'hls': 15.53, 'pengeluaran': 15425.00, 'ipm': 83.55},
      2022: {'uhh': 77.69, 'rls': 10.80, 'hls': 15.54, 'pengeluaran': 16047.00, 'ipm': 84.08},
      2023: {'uhh': 77.90, 'rls': 10.81, 'hls': 15.55, 'pengeluaran': 16420.00, 'ipm': 84.43},
      2024: {'uhh': 78.23, 'rls': 11.05, 'hls': 15.57, 'pengeluaran': 17250.00, 'ipm': 85.24},
    };
  }

  void _initializeDefaultKomponenData() {
    komponenData = {
      2020: {'ipmNasional': 72.81, 'ipmJateng': 71.88, 'ipmSemarang': 83.05},
      2021: {'ipmNasional': 73.16, 'ipmJateng': 72.17, 'ipmSemarang': 83.55},
      2022: {'ipmNasional': 73.77, 'ipmJateng': 72.80, 'ipmSemarang': 84.08},
      2023: {'ipmNasional': 74.39, 'ipmJateng': 73.39, 'ipmSemarang': 84.43},
      2024: {'ipmNasional': 75.02, 'ipmJateng': 73.87, 'ipmSemarang': 85.24},
    };
  }

  // ============= EDIT DIALOGS =============
  
  void _showEditMainDataDialog(int year) {
    final data = ipmData[year] ?? {};
    final controllers = {
      'uhh': TextEditingController(text: '${data['uhh'] ?? 0.0}'),
      'rls': TextEditingController(text: '${data['rls'] ?? 0.0}'),
      'hls': TextEditingController(text: '${data['hls'] ?? 0.0}'),
      'pengeluaran': TextEditingController(text: '${data['pengeluaran'] ?? 0.0}'),
      'ipm': TextEditingController(text: '${data['ipm'] ?? 0.0}'),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Data IPM Tahun $year'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('UHH (Tahun)', controllers['uhh']!, Icons.favorite, isDecimal: true),
              _buildTextField('RLS (Tahun)', controllers['rls']!, Icons.auto_stories, isDecimal: true),
              _buildTextField('HLS (Tahun)', controllers['hls']!, Icons.school, isDecimal: true),
              _buildTextField('Pengeluaran (Ribu Rupiah)', controllers['pengeluaran']!, Icons.monetization_on, isDecimal: true),
              _buildTextField('IPM', controllers['ipm']!, Icons.assessment, isDecimal: true),
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
                  ipmData[year] = {
                    'uhh': double.parse(controllers['uhh']!.text),
                    'rls': double.parse(controllers['rls']!.text),
                    'hls': double.parse(controllers['hls']!.text),
                    'pengeluaran': double.parse(controllers['pengeluaran']!.text),
                    'ipm': double.parse(controllers['ipm']!.text),
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
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditKomponenDialog(int year) {
    final data = komponenData[year] ?? {};
    final controllers = {
      'ipmNasional': TextEditingController(text: '${data['ipmNasional'] ?? 0.0}'),
      'ipmJateng': TextEditingController(text: '${data['ipmJateng'] ?? 0.0}'),
      'ipmSemarang': TextEditingController(text: '${data['ipmSemarang'] ?? 0.0}'),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Perbandingan Wilayah $year'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('IPM Nasional', controllers['ipmNasional']!, Icons.flag, isDecimal: true),
            const SizedBox(height: 12),
            _buildTextField('IPM Jawa Tengah', controllers['ipmJateng']!, Icons.location_city, isDecimal: true),
            const SizedBox(height: 12),
            _buildTextField('IPM Semarang', controllers['ipmSemarang']!, Icons.home, isDecimal: true),
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
                  komponenData[year] = {
                    'ipmNasional': double.parse(controllers['ipmNasional']!.text),
                    'ipmJateng': double.parse(controllers['ipmJateng']!.text),
                    'ipmSemarang': double.parse(controllers['ipmSemarang']!.text),
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
              backgroundColor: const Color(0xFF4CAF50),
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
    final lastData = ipmData[lastYear];
    
    if (lastData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data tahun terakhir tidak valid')),
      );
      return;
    }
    
    final lastKomponen = komponenData[lastYear] ?? {};
    
    final growth = 1.01;
    
    final mainControllers = {
      'uhh': TextEditingController(text: '${(lastData['uhh'] * growth).toStringAsFixed(2)}'),
      'rls': TextEditingController(text: '${(lastData['rls'] * growth).toStringAsFixed(2)}'),
      'hls': TextEditingController(text: '${(lastData['hls'] * growth).toStringAsFixed(2)}'),
      'pengeluaran': TextEditingController(text: '${(lastData['pengeluaran'] * growth).toStringAsFixed(2)}'),
      'ipm': TextEditingController(text: '${(lastData['ipm'] * growth).toStringAsFixed(2)}'),
    };
    
    final komponenControllers = {
      'ipmNasional': TextEditingController(text: '${(lastKomponen['ipmNasional'] ?? 75.0)}'),
      'ipmJateng': TextEditingController(text: '${(lastKomponen['ipmJateng'] ?? 74.0)}'),
      'ipmSemarang': TextEditingController(text: '${(lastKomponen['ipmSemarang'] ?? 85.0)}'),
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
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Data estimasi dari tahun $lastYear',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('DATA KOMPONEN IPM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                _buildTextField('UHH (Tahun)', mainControllers['uhh']!, Icons.favorite, isDecimal: true),
                _buildTextField('RLS (Tahun)', mainControllers['rls']!, Icons.auto_stories, isDecimal: true),
                _buildTextField('HLS (Tahun)', mainControllers['hls']!, Icons.school, isDecimal: true),
                _buildTextField('Pengeluaran (Ribu)', mainControllers['pengeluaran']!, Icons.monetization_on, isDecimal: true),
                _buildTextField('IPM', mainControllers['ipm']!, Icons.assessment, isDecimal: true),
                const SizedBox(height: 16),
                const Text('PERBANDINGAN WILAYAH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                _buildTextField('IPM Nasional', komponenControllers['ipmNasional']!, Icons.flag, isDecimal: true),
                _buildTextField('IPM Jawa Tengah', komponenControllers['ipmJateng']!, Icons.location_city, isDecimal: true),
                _buildTextField('IPM Semarang', komponenControllers['ipmSemarang']!, Icons.home, isDecimal: true),
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
                if (ipmData.containsKey(nextYear)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tahun sudah ada!')),
                  );
                  return;
                }

                setState(() {
                  ipmData[nextYear] = {
                    'uhh': double.parse(mainControllers['uhh']!.text),
                    'rls': double.parse(mainControllers['rls']!.text),
                    'hls': double.parse(mainControllers['hls']!.text),
                    'pengeluaran': double.parse(mainControllers['pengeluaran']!.text),
                    'ipm': double.parse(mainControllers['ipm']!.text),
                  };

                  komponenData[nextYear] = {
                    'ipmNasional': double.parse(komponenControllers['ipmNasional']!.text),
                    'ipmJateng': double.parse(komponenControllers['ipmJateng']!.text),
                    'ipmSemarang': double.parse(komponenControllers['ipmSemarang']!.text),
                  };

                  availableYears = ipmData.keys.toList()..sort();
                  selectedYear = nextYear;
                });
                
                _saveData();
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✓ Tahun $nextYear berhasil ditambahkan!'),
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
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
                ipmData.remove(year);
                komponenData.remove(year);
                availableYears = ipmData.keys.toList()..sort();
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
          title: const Text('Admin - Kelola Data IPM'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Admin Panel - Kelola Data IPM'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard, size: 18), text: 'Data IPM'),
            Tab(icon: Icon(Icons.calendar_today, size: 18), text: 'Kelola Tahun'),
            Tab(icon: Icon(Icons.settings, size: 18), text: 'Pengaturan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDataIpmTab(),
          _buildKelolaTahunTab(),
          _buildPengaturanTab(),
        ],
      ),
    );
  }

  // ============= TAB VIEWS =============
  
  Widget _buildDataIpmTab() {
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
                    Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
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
                          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[200],
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
                    Text('Data IPM Kota Semarang $selectedYear', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF4CAF50)),
                      onPressed: () => _showEditMainDataDialog(selectedYear),
                    ),
                  ],
                ),
                const Divider(),
                _buildDataRow('UHH', '${ipmData[selectedYear]!['uhh']} Tahun', Icons.favorite),
                _buildDataRow('RLS', '${ipmData[selectedYear]!['rls']} Tahun', Icons.auto_stories),
                _buildDataRow('HLS', '${ipmData[selectedYear]!['hls']} Tahun', Icons.school),
                _buildDataRow('Pengeluaran', '${_formatNumber(ipmData[selectedYear]!['pengeluaran'])} Ribu', Icons.monetization_on),
                _buildDataRow('IPM', '${ipmData[selectedYear]!['ipm']}', Icons.assessment),
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
                    Text('Perbandingan Wilayah $selectedYear', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF4CAF50)),
                      onPressed: () => _showEditKomponenDialog(selectedYear),
                    ),
                  ],
                ),
                const Divider(),
                _buildDataRow('IPM Nasional', '${komponenData[selectedYear]!['ipmNasional']}', Icons.flag),
                _buildDataRow('IPM Jawa Tengah', '${komponenData[selectedYear]!['ipmJateng']}', Icons.location_city),
                _buildDataRow('IPM Semarang', '${komponenData[selectedYear]!['ipmSemarang']}', Icons.home),
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

  Widget _buildKelolaTahunTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 4,
          color: const Color(0xFF4CAF50),
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
                    Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
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
              backgroundColor: const Color(0xFF4CAF50),
              child: Text('${year.toString().substring(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            title: Text('Tahun $year', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('IPM: ${ipmData[year]!['ipm']} | UHH: ${ipmData[year]!['uhh']} Tahun', style: TextStyle(fontSize: 12)),
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
                            _initializeDefaultIpmData();
                            _initializeDefaultKomponenData();
                            setState(() {
                              availableYears = ipmData.keys.toList()..sort();
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
                leading: const Icon(Icons.info_outline, color: Color(0xFF4CAF50)),
                title: const Text('Tentang'),
                subtitle: const Text('Admin Panel IPM v1.0'),
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
                            Text('Admin Panel untuk mengelola data Indeks Pembangunan Manusia (IPM) Kota Semarang.', style: TextStyle(fontSize: 14)),
                            SizedBox(height: 16),
                            Text('Fitur:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            SizedBox(height: 8),
                            Text('✓ Edit data komponen IPM (UHH, RLS, HLS, Pengeluaran)'),
                            Text('✓ Edit perbandingan wilayah (Nasional, Jateng, Semarang)'),
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
                                Text('1.0', style: TextStyle(color: Color(0xFF4CAF50))),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Tema:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('IPM', style: TextStyle(color: Color(0xFF4CAF50))),
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