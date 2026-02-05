import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AdminKemiskinanScreen extends StatefulWidget {
  const AdminKemiskinanScreen({super.key});

  @override
  State<AdminKemiskinanScreen> createState() => _AdminKemiskinanScreenState();
}

class _AdminKemiskinanScreenState extends State<AdminKemiskinanScreen> {
  Map<int, Map<String, dynamic>> yearlyData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('kemiskinan_data');
      
      if (mounted) {
        setState(() {
          if (savedData != null) {
            final decoded = json.decode(savedData) as Map<String, dynamic>;
            yearlyData = decoded.map((key, value) =>
              MapEntry(int.parse(key), Map<String, dynamic>.from(value as Map))
            );
          } else {
            // Data default
            yearlyData = {
              2020: {
                'pendudukMiskin': '79.58 Ribu',
                'pendudukMiskinValue': 79.58,
                'persentase': '4.34%',
                'persentaseValue': 4.34,
                'garisMiskin': 'Rp 533,691',
                'indeksKedalaman': '0.68',
                'indeksKeparahan': '0.16',
              },
              2021: {
                'pendudukMiskin': '84.45 Ribu',
                'pendudukMiskinValue': 84.45,
                'persentase': '4.56%',
                'persentaseValue': 4.56,
                'garisMiskin': 'Rp 543,929',
                'indeksKedalaman': '0.67',
                'indeksKeparahan': '0.14',
              },
              2022: {
                'pendudukMiskin': '79.87 Ribu',
                'pendudukMiskinValue': 79.87,
                'persentase': '4.25%',
                'persentaseValue': 4.25,
                'garisMiskin': 'Rp 589,598',
                'indeksKedalaman': '0.56',
                'indeksKeparahan': '0.11',
              },
              2023: {
                'pendudukMiskin': '80.53 Ribu',
                'pendudukMiskinValue': 80.53,
                'persentase': '4.23%',
                'persentaseValue': 4.23,
                'garisMiskin': 'Rp 642,456',
                'indeksKedalaman': '0.54',
                'indeksKeparahan': '0.10',
              },
              2024: {
                'pendudukMiskin': '77.79 Ribu',
                'pendudukMiskinValue': 77.79,
                'persentase': '4.03%',
                'persentaseValue': 4.03,
                'garisMiskin': 'Rp 671,936',
                'indeksKedalaman': '0.59',
                'indeksKeparahan': '0.12',
              },
            };
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(
        yearlyData.map((key, value) => MapEntry(key.toString(), value))
      );
      await prefs.setString('kemiskinan_data', encoded);
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFF5722).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildHeaderCard(yearlyData.length),
                          const SizedBox(height: 20),
                          ...(yearlyData.keys.toList()..sort((a, b) => b.compareTo(a)))
                              .map((year) => _buildDataCard(year, yearlyData[year]!)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context),
        backgroundColor: const Color(0xFFFF5722),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Data'),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF5722), Color(0xFFE64A19)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Admin - Kemiskinan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(int dataCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5722), Color(0xFFE64A19)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5722).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.dashboard,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kelola Data Kemiskinan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total $dataCount data tersimpan',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(int year, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5722), Color(0xFFE64A19)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tahun $year',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showAddEditDialog(context, year: year, data: data),
                    icon: const Icon(Icons.edit, color: Color(0xFFFF5722)),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(context, year),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow('Jumlah Penduduk Miskin', data['pendudukMiskin']?.toString() ?? '-', Icons.people_outline),
          _buildInfoRow('Persentase Kemiskinan', data['persentase']?.toString() ?? '-', Icons.pie_chart),
          _buildInfoRow('Garis Kemiskinan', data['garisMiskin']?.toString() ?? '-', Icons.attach_money),
          _buildInfoRow('Indeks Kedalaman (P1)', data['indeksKedalaman']?.toString() ?? '-', Icons.analytics),
          _buildInfoRow('Indeks Keparahan (P2)', data['indeksKeparahan']?.toString() ?? '-', Icons.trending_down),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5722).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: const Color(0xFFFF5722)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {int? year, Map<String, dynamic>? data}) {
    final isEdit = year != null;
    
    final tahunController = TextEditingController(text: year?.toString() ?? '');
    final pendudukMiskinController = TextEditingController(text: data?['pendudukMiskin']?.toString() ?? '');
    final pendudukMiskinValueController = TextEditingController(text: data?['pendudukMiskinValue']?.toString() ?? '');
    final persentaseController = TextEditingController(text: data?['persentase']?.toString() ?? '');
    final persentaseValueController = TextEditingController(text: data?['persentaseValue']?.toString() ?? '');
    final garisMiskinController = TextEditingController(text: data?['garisMiskin']?.toString() ?? '');
    final indeksKedalamanController = TextEditingController(text: data?['indeksKedalaman']?.toString() ?? '');
    final indeksKeparahanController = TextEditingController(text: data?['indeksKeparahan']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Data Tahun $year' : 'Tambah Data'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tahunController,
                  decoration: const InputDecoration(
                    labelText: 'Tahun',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !isEdit,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pendudukMiskinController,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Penduduk Miskin (ex: 79.58 Ribu)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pendudukMiskinValueController,
                  decoration: const InputDecoration(
                    labelText: 'Nilai Penduduk Miskin (ex: 79.58)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                    helperText: 'Untuk grafik',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: persentaseController,
                  decoration: const InputDecoration(
                    labelText: 'Persentase Kemiskinan (ex: 4.34%)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.pie_chart),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: persentaseValueController,
                  decoration: const InputDecoration(
                    labelText: 'Nilai Persentase (ex: 4.34)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                    helperText: 'Untuk grafik',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: garisMiskinController,
                  decoration: const InputDecoration(
                    labelText: 'Garis Kemiskinan (ex: Rp 533,691)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: indeksKedalamanController,
                  decoration: const InputDecoration(
                    labelText: 'Indeks Kedalaman P1 (ex: 0.68)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.analytics),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: indeksKeparahanController,
                  decoration: const InputDecoration(
                    labelText: 'Indeks Keparahan P2 (ex: 0.16)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.trending_down),
                  ),
                  keyboardType: TextInputType.number,
                ),
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
            onPressed: () async {
              final newYear = int.tryParse(tahunController.text);
              if (newYear == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tahun harus berupa angka'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final newData = {
                'pendudukMiskin': pendudukMiskinController.text,
                'pendudukMiskinValue': double.tryParse(pendudukMiskinValueController.text) ?? 0,
                'persentase': persentaseController.text,
                'persentaseValue': double.tryParse(persentaseValueController.text) ?? 0,
                'garisMiskin': garisMiskinController.text,
                'indeksKedalaman': indeksKedalamanController.text,
                'indeksKeparahan': indeksKeparahanController.text,
              };

              if (isEdit) {
                if (newYear != year) {
                  yearlyData.remove(year);
                }
                yearlyData[newYear] = newData;
              } else {
                if (yearlyData.containsKey(newYear)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data tahun ini sudah ada'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                yearlyData[newYear] = newData;
              }

              await _saveData();
              setState(() {});
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'Data berhasil diupdate' : 'Data berhasil ditambahkan'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
              foregroundColor: Colors.white,
            ),
            child: Text(isEdit ? 'Update' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int year) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus data tahun $year?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              yearlyData.remove(year);
              await _saveData();
              setState(() {});
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil dihapus'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
}