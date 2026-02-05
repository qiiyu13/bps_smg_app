import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

class AdminIDGScreen extends StatefulWidget {
  const AdminIDGScreen({Key? key}) : super(key: key);

  @override
  State<AdminIDGScreen> createState() => _AdminIDGScreenState();
}

class _AdminIDGScreenState extends State<AdminIDGScreen> with SingleTickerProviderStateMixin {
  Map<int, Map<String, dynamic>> idgData = {};
  List<int> availableYears = [];
  int selectedYear = 2024;
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      
      String? savedData = prefs.getString('idg_data');
      if (savedData != null) {
        Map<String, dynamic> decoded = json.decode(savedData);
        idgData = decoded.map((key, value) => 
          MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map))
        );
      } else {
        _initializeDefaultData();
        await _saveDataSilently();
      }
      
      setState(() {
        availableYears = idgData.keys.toList()..sort();
        if (availableYears.isNotEmpty) {
          selectedYear = availableYears.last;
        }
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      _initializeDefaultData();
      setState(() {
        availableYears = idgData.keys.toList()..sort();
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
      
      await prefs.setString('idg_data', 
        json.encode(idgData.map((k, v) => MapEntry(k.toString(), v)))
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Data IDG berhasil disimpan!'),
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

  Future<void> _saveDataSilently() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('idg_data', 
        json.encode(idgData.map((k, v) => MapEntry(k.toString(), v)))
      );
    } catch (e) {
      debugPrint('Error saving data silently: $e');
    }
  }

  // ============= DEFAULT DATA INITIALIZATION =============
  
  void _initializeDefaultData() {
    idgData = {
      2020: {
        'sumbangan': 37.13,
        'tenaga': 51.15,
        'parlemen': 20.41,
        'idg': 74.67,
        'ikg': 0.157,
      },
      2021: {
        'sumbangan': 37.46,
        'tenaga': 51.30,
        'parlemen': 18.75,
        'idg': 73.64,
        'ikg': 0.142,
      },
      2022: {
        'sumbangan': 38.05,
        'tenaga': 49.78,
        'parlemen': 18.00,
        'idg': 73.93,
        'ikg': 0.266,
      },
      2023: {
        'sumbangan': 37.93,
        'tenaga': 48.76,
        'parlemen': 18.00,
        'idg': 73.86,
        'ikg': 0.168,
      },
      2024: {
        'sumbangan': 37.68,
        'tenaga': 50.42,
        'parlemen': 24.00,
        'idg': 78.71,
        'ikg': 0.14,
      },
    };
  }

  // ============= EDIT DIALOGS =============
  
  void _showEditIDGDialog(int year) {
    final data = idgData[year] ?? {};
    final controllers = {
      'sumbangan': TextEditingController(text: '${data['sumbangan'] ?? 0.0}'),
      'tenaga': TextEditingController(text: '${data['tenaga'] ?? 0.0}'),
      'parlemen': TextEditingController(text: '${data['parlemen'] ?? 0.0}'),
      'idg': TextEditingController(text: '${data['idg'] ?? 0.0}'),
      'ikg': TextEditingController(text: '${data['ikg'] ?? 0.0}'),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Data IDG Tahun $year'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Perubahan akan langsung terlihat di aplikasi user',
                        style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'KOMPONEN IDG',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[800]),
              ),
              SizedBox(height: 8),
              _buildTextField(
                'Sumbangan Pendapatan Perempuan (%)', 
                controllers['sumbangan']!, 
                Icons.attach_money, 
                isDecimal: true
              ),
              _buildTextField(
                'Perempuan sebagai Tenaga Profesional (%)', 
                controllers['tenaga']!, 
                Icons.business_center, 
                isDecimal: true
              ),
              _buildTextField(
                'Keterlibatan Perempuan di Parlemen (%)', 
                controllers['parlemen']!, 
                Icons.account_balance, 
                isDecimal: true
              ),
              const Divider(height: 24),
              Text(
                'INDEKS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[800]),
              ),
              SizedBox(height: 8),
              _buildTextField(
                'Nilai IDG', 
                controllers['idg']!, 
                Icons.trending_up, 
                isDecimal: true
              ),
              _buildTextField(
                'Nilai IKG', 
                controllers['ikg']!, 
                Icons.balance, 
                isDecimal: true
              ),
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
                final sumbangan = double.parse(controllers['sumbangan']!.text);
                final tenaga = double.parse(controllers['tenaga']!.text);
                final parlemen = double.parse(controllers['parlemen']!.text);
                final idg = double.parse(controllers['idg']!.text);
                final ikg = double.parse(controllers['ikg']!.text);

                if (sumbangan < 0 || sumbangan > 100 ||
                    tenaga < 0 || tenaga > 100 ||
                    parlemen < 0 || parlemen > 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Persentase harus antara 0-100!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (idg < 0 || idg > 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nilai IDG harus antara 0-100!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (ikg < 0 || ikg > 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nilai IKG harus antara 0-1!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() {
                  idgData[year] = {
                    'sumbangan': sumbangan,
                    'tenaga': tenaga,
                    'parlemen': parlemen,
                    'idg': idg,
                    'ikg': ikg,
                  };
                });
                _saveData();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6F00),
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
    final lastData = idgData[lastYear];
    
    if (lastData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data tahun terakhir tidak valid')),
      );
      return;
    }
    
    final controllers = {
      'sumbangan': TextEditingController(text: '${lastData['sumbangan'] ?? 38.0}'),
      'tenaga': TextEditingController(text: '${lastData['tenaga'] ?? 50.0}'),
      'parlemen': TextEditingController(text: '${lastData['parlemen'] ?? 20.0}'),
      'idg': TextEditingController(text: '${lastData['idg'] ?? 75.0}'),
      'ikg': TextEditingController(text: '${lastData['ikg'] ?? 0.15}'),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Data Tahun $nextYear'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Data estimasi dari tahun $lastYear',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'KOMPONEN IDG',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                'Sumbangan Pendapatan Perempuan (%)',
                controllers['sumbangan']!,
                Icons.attach_money,
                isDecimal: true,
              ),
              _buildTextField(
                'Perempuan sebagai Tenaga Profesional (%)',
                controllers['tenaga']!,
                Icons.business_center,
                isDecimal: true,
              ),
              _buildTextField(
                'Keterlibatan Perempuan di Parlemen (%)',
                controllers['parlemen']!,
                Icons.account_balance,
                isDecimal: true,
              ),
              const SizedBox(height: 16),
              const Text(
                'INDEKS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                'Nilai IDG',
                controllers['idg']!,
                Icons.trending_up,
                isDecimal: true,
              ),
              _buildTextField(
                'Nilai IKG',
                controllers['ikg']!,
                Icons.balance,
                isDecimal: true,
              ),
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
                if (idgData.containsKey(nextYear)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tahun sudah ada!')),
                  );
                  return;
                }

                final sumbangan = double.parse(controllers['sumbangan']!.text);
                final tenaga = double.parse(controllers['tenaga']!.text);
                final parlemen = double.parse(controllers['parlemen']!.text);
                final idg = double.parse(controllers['idg']!.text);
                final ikg = double.parse(controllers['ikg']!.text);

                if (sumbangan < 0 || sumbangan > 100 ||
                    tenaga < 0 || tenaga > 100 ||
                    parlemen < 0 || parlemen > 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Persentase harus antara 0-100!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (idg < 0 || idg > 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nilai IDG harus antara 0-100!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (ikg < 0 || ikg > 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nilai IKG harus antara 0-1!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() {
                  idgData[nextYear] = {
                    'sumbangan': sumbangan,
                    'tenaga': tenaga,
                    'parlemen': parlemen,
                    'idg': idg,
                    'ikg': ikg,
                  };

                  availableYears = idgData.keys.toList()..sort();
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
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6F00),
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
        content: Text('Hapus semua data IDG tahun $year?\n\nData ini akan dihapus dari aplikasi user.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                idgData.remove(year);
                availableYears = idgData.keys.toList()..sort();
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
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    bool isDecimal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isDecimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : (isNumber ? TextInputType.number : TextInputType.text),
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

  // ============= BUILD UI =============
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Admin - Kelola Data IDG'),
          backgroundColor: const Color(0xFFFF6F00),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6F00)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Admin Panel - Kelola Data IDG'),
        backgroundColor: const Color(0xFFFF6F00),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard, size: 18), text: 'Data IDG'),
            Tab(icon: Icon(Icons.show_chart, size: 18), text: 'Preview Grafik'),
            Tab(icon: Icon(Icons.calendar_today, size: 18), text: 'Kelola Tahun'),
            Tab(icon: Icon(Icons.settings, size: 18), text: 'Pengaturan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDataIDGTab(),
          _buildPreviewGrafikTab(),
          _buildKelolaTahunTab(),
          _buildPengaturanTab(),
        ],
      ),
    );
  }

  // ============= TAB VIEWS =============
  
  Widget _buildDataIDGTab() {
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
                    Icon(Icons.calendar_today, color: Color(0xFFFF6F00)),
                    SizedBox(width: 8),
                    Text(
                      'Pilih Tahun',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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
                          color: isSelected ? const Color(0xFFFF6F00) : Colors.grey[200],
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
                    Text(
                      'Data IDG Tahun $selectedYear',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFFFF6F00)),
                      onPressed: () => _showEditIDGDialog(selectedYear),
                      tooltip: 'Edit Data',
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                _buildIDGCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIDGCard() {
    final data = idgData[selectedYear];
    if (data == null) return const SizedBox();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.white, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      '${data['idg']?.toStringAsFixed(2) ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'IDG',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFED7D31), Color(0xFFFF9F5A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.balance, color: Colors.white, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      '${data['ikg']?.toStringAsFixed(3) ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'IKG',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        _buildDataRow(
          'Sumbangan Pendapatan Perempuan',
          '${data['sumbangan']?.toStringAsFixed(2) ?? 'N/A'}%',
          Icons.attach_money,
        ),
        _buildDataRow(
          'Perempuan sebagai Tenaga Profesional',
          '${data['tenaga']?.toStringAsFixed(2) ?? 'N/A'}%',
          Icons.business_center,
        ),
        _buildDataRow(
          'Keterlibatan Perempuan di Parlemen',
          '${data['parlemen']?.toStringAsFixed(2) ?? 'N/A'}%',
          Icons.account_balance,
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
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey[700])),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewGrafikTab() {
    List<FlSpot> idgSpots = [];
    List<FlSpot> ikgSpots = [];
    List<String> yearLabels = [];

    for (int i = 0; i < availableYears.length; i++) {
      final year = availableYears[i];
      final data = idgData[year];
      if (data != null) {
        if (data['idg'] != null) {
          idgSpots.add(FlSpot(i.toDouble(), data['idg']!.toDouble()));
        }
        if (data['ikg'] != null) {
          double scaledIkg = (64 + (data['ikg']! * 53.33)).toDouble();
          ikgSpots.add(FlSpot(i.toDouble(), scaledIkg));
        }
        yearLabels.add(year.toString());
      }
    }

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
                    Icon(Icons.show_chart, color: Color(0xFFFF6F00)),
                    SizedBox(width: 8),
                    Text(
                      'Preview Grafik IDG & IKG',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Grafik ini menampilkan data yang akan terlihat di aplikasi user',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: idgSpots.isNotEmpty || ikgSpots.isNotEmpty
                      ? LineChart(
                          LineChartData(
                            minY: 64,
                            maxY: 80,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 2,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.withOpacity(0.2),
                                  strokeWidth: 0.5,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 35,
                                  interval: 2,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF4472C4),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 35,
                                  interval: 2,
                                  getTitlesWidget: (value, meta) {
                                    double ikgValue = (value - 64) / 53.33;
                                    return Text(
                                      ikgValue.toStringAsFixed(2),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFED7D31),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= 0 && index < yearLabels.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          yearLabels[index],
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border(
                                left: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
                                right: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
                                bottom: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: idgSpots,
                                isCurved: true,
                                color: const Color(0xFF4472C4),
                                barWidth: 3,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: const Color(0xFF4472C4),
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(show: false),
                              ),
                              LineChartBarData(
                                spots: ikgSpots,
                                isCurved: true,
                                color: const Color(0xFFED7D31),
                                barWidth: 3,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: const Color(0xFFED7D31),
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Data tidak tersedia',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF4472C4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'IDG',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFED7D31),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'IKG',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKelolaTahunTab() {
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
                    Icon(Icons.calendar_today, color: Color(0xFFFF6F00)),
                    SizedBox(width: 8),
                    Text(
                      'Kelola Data Tahun',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Daftar Tahun (${availableYears.length} tahun)',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                ...availableYears.map((year) {
                  final data = idgData[year];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFFFF6F00).withOpacity(0.1),
                        child: Text(
                          year.toString().substring(2),
                          style: TextStyle(
                            color: Color(0xFFFF6F00),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        'Tahun $year',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: data != null
                          ? Text('IDG: ${data['idg']?.toStringAsFixed(2)} | IKG: ${data['ikg']?.toStringAsFixed(3)}')
                          : Text('Data tidak lengkap'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditIDGDialog(year),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteDialog(year),
                            tooltip: 'Hapus',
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showAddYearDialog,
                    icon: Icon(Icons.add, size: 20),
                    label: Text('Tambah Tahun Baru'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPengaturanTab() {
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
                    Icon(Icons.settings, color: Color(0xFFFF6F00)),
                    SizedBox(width: 8),
                    Text(
                      'Pengaturan Admin',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.storage, color: Colors.blue),
                  title: Text('Total Data Tersimpan'),
                  subtitle: Text('${availableYears.length} tahun data IDG'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.green),
                  title: Text('Format Data'),
                  subtitle: Text('JSON di SharedPreferences'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.refresh, color: Colors.orange),
                  title: Text('Reset ke Data Default'),
                  subtitle: Text('Kembalikan data ke nilai awal (2020-2024)'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Reset Data'),
                        content: Text(
                          'Apakah Anda yakin ingin mereset semua data ke nilai default?\n\nSemua perubahan akan hilang!',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              _initializeDefaultData();
                              await _saveData();
                              setState(() {
                                availableYears = idgData.keys.toList()..sort();
                                selectedYear = availableYears.last;
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('✓ Data berhasil direset ke default!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Reset'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700]),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Semua perubahan akan otomatis tersinkronisasi dengan aplikasi user',
                          style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                        ),
                      ),
                    ],
                  ),
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
                  children: [
                    Icon(Icons.help_outline, color: Color(0xFFFF6F00)),
                    SizedBox(width: 8),
                    Text(
                      'Panduan Penggunaan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPanduanItem(
                  '1',
                  'Edit Data',
                  'Pilih tahun di tab "Data IDG" dan klik tombol edit untuk mengubah nilai IDG, IKG, dan komponen lainnya.',
                ),
                _buildPanduanItem(
                  '2',
                  'Tambah Tahun',
                  'Gunakan tab "Kelola Tahun" untuk menambah data tahun baru. Sistem akan otomatis mengisi dengan data estimasi dari tahun terakhir.',
                ),
                _buildPanduanItem(
                  '3',
                  'Preview Grafik',
                  'Lihat visualisasi data di tab "Preview Grafik" untuk memastikan data yang ditampilkan sudah sesuai.',
                ),
                _buildPanduanItem(
                  '4',
                  'Hapus Data',
                  'Hapus data tahun tertentu melalui tab "Kelola Tahun" jika diperlukan. Data akan terhapus dari aplikasi user.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPanduanItem(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(0xFFFF6F00),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}