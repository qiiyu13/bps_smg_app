import 'package:flutter/material.dart';
import 'ekonomi_data.dart';

class AdminPertumbuhanEkonomiScreen extends StatefulWidget {
  const AdminPertumbuhanEkonomiScreen({super.key});

  @override
  State<AdminPertumbuhanEkonomiScreen> createState() => _AdminPertumbuhanEkonomiScreenState();
}

class _AdminPertumbuhanEkonomiScreenState extends State<AdminPertumbuhanEkonomiScreen> {
  final dataManager = EkonomiDataManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF00BCD4).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildHeaderCard(dataManager.dataList.length),
                    const SizedBox(height: 20),
                    ...dataManager.dataList.map((data) => _buildDataCard(data)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context),
        backgroundColor: const Color(0xFF00BCD4),
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
          colors: [Color(0xFF00BCD4), Color(0xFF00ACC1)],
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
              'Admin - Pertumbuhan Ekonomi',
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
          colors: [Color(0xFF00BCD4), Color(0xFF00ACC1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BCD4).withOpacity(0.4),
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
                  'Kelola Data Ekonomi',
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

  Widget _buildDataCard(EkonomiData data) {
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
                    colors: [Color(0xFF00BCD4), Color(0xFF00ACC1)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tahun ${data.tahun}',
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
                    onPressed: () => _showAddEditDialog(context, data: data),
                    icon: const Icon(Icons.edit, color: Color(0xFF00BCD4)),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(context, data),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow('Pertumbuhan Ekonomi', data.pertumbuhanEkonomi, Icons.trending_up),
          _buildInfoRow('Kontribusi PDRB', data.kontribusiPDRB, Icons.pie_chart),
          _buildInfoRow('Sektor Perdagangan', data.sektorPerdagangan, Icons.store),
          _buildInfoRow('PDRB per Kapita', data.pdrbPerKapita, Icons.account_balance_wallet),
          _buildInfoRow('vs Jawa Tengah', data.vsJawaTengah, Icons.compare_arrows),
          _buildInfoRow('vs Nasional', data.vsNasional, Icons.public),
          const SizedBox(height: 12),
          const Text(
            'Kecamatan Tertinggi:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ...data.distrikTertinggi.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00BCD4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value.nama,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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
              color: const Color(0xFF00BCD4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: const Color(0xFF00BCD4)),
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

  void _showAddEditDialog(BuildContext context, {EkonomiData? data}) {
    final isEdit = data != null;
    
    final tahunController = TextEditingController(text: data?.tahun ?? '');
    final pertumbuhanController = TextEditingController(text: data?.pertumbuhanEkonomi ?? '');
    final kontribusiController = TextEditingController(text: data?.kontribusiPDRB ?? '');
    final sektorController = TextEditingController(text: data?.sektorPerdagangan ?? '');
    final pdrbController = TextEditingController(text: data?.pdrbPerKapita ?? '');
    final vsJatengController = TextEditingController(text: data?.vsJawaTengah ?? '');
    final vsNasionalController = TextEditingController(text: data?.vsNasional ?? '');
    
    List<TextEditingController> distrikControllers = [];
    if (data != null) {
      for (var distrik in data.distrikTertinggi) {
        distrikControllers.add(TextEditingController(text: distrik.nama));
      }
    } else {
      for (int i = 0; i < 5; i++) {
        distrikControllers.add(TextEditingController());
      }
    }

    List<TextEditingController> semarangYearControllers = [];
    List<TextEditingController> semarangValueControllers = [];
    List<TextEditingController> jatengYearControllers = [];
    List<TextEditingController> jatengValueControllers = [];
    
    if (data != null) {
      for (var point in data.semarangData) {
        semarangYearControllers.add(TextEditingController(text: point.year.toString()));
        semarangValueControllers.add(TextEditingController(text: point.value.toString()));
      }
      for (var point in data.jatengData) {
        jatengYearControllers.add(TextEditingController(text: point.year.toString()));
        jatengValueControllers.add(TextEditingController(text: point.value.toString()));
      }
    } else {
      for (int i = 0; i < 5; i++) {
        semarangYearControllers.add(TextEditingController(text: (2020 + i).toString()));
        semarangValueControllers.add(TextEditingController());
        jatengYearControllers.add(TextEditingController(text: (2020 + i).toString()));
        jatengValueControllers.add(TextEditingController());
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Data' : 'Tambah Data'),
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
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pertumbuhanController,
                  decoration: const InputDecoration(
                    labelText: 'Pertumbuhan Ekonomi (ex: 5.31%)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.trending_up),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: kontribusiController,
                  decoration: const InputDecoration(
                    labelText: 'Kontribusi PDRB (ex: 9.8%)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.pie_chart),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sektorController,
                  decoration: const InputDecoration(
                    labelText: 'Sektor Perdagangan (ex: 28.5%)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.store),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pdrbController,
                  decoration: const InputDecoration(
                    labelText: 'PDRB per Kapita (ex: Rp 85.2 Juta)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance_wallet),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: vsJatengController,
                  decoration: const InputDecoration(
                    labelText: 'vs Jawa Tengah (ex: 142%)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.compare_arrows),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: vsNasionalController,
                  decoration: const InputDecoration(
                    labelText: 'vs Nasional (ex: 125%)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.public),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'Kecamatan Tertinggi (Top 5):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: distrikControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Kecamatan ${index + 1}',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.location_city),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'Data Grafik Semarang (5 Tahun):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: semarangYearControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Tahun',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: semarangValueControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Nilai',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'Data Grafik Jawa Tengah (5 Tahun):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: jatengYearControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Tahun',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: jatengValueControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Nilai',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              List<ChartDataPoint> semarangData = [];
              List<ChartDataPoint> jatengData = [];
              
              for (int i = 0; i < 5; i++) {
                semarangData.add(ChartDataPoint(
                  year: int.tryParse(semarangYearControllers[i].text) ?? 2020 + i,
                  value: double.tryParse(semarangValueControllers[i].text) ?? 0,
                ));
                jatengData.add(ChartDataPoint(
                  year: int.tryParse(jatengYearControllers[i].text) ?? 2020 + i,
                  value: double.tryParse(jatengValueControllers[i].text) ?? 0,
                ));
              }

              if (isEdit) {
                dataManager.updateData(
                  data.id,
                  EkonomiData(
                    id: data.id,
                    tahun: tahunController.text,
                    pertumbuhanEkonomi: pertumbuhanController.text,
                    kontribusiPDRB: kontribusiController.text,
                    sektorPerdagangan: sektorController.text,
                    pdrbPerKapita: pdrbController.text,
                    vsJawaTengah: vsJatengController.text,
                    vsNasional: vsNasionalController.text,
                    distrikTertinggi: distrikControllers
                        .map((c) => DistrikData(nama: c.text))
                        .toList(),
                    semarangData: semarangData,
                    jatengData: jatengData,
                  ),
                );
              } else {
                dataManager.addData(
                  EkonomiData(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    tahun: tahunController.text,
                    pertumbuhanEkonomi: pertumbuhanController.text,
                    kontribusiPDRB: kontribusiController.text,
                    sektorPerdagangan: sektorController.text,
                    pdrbPerKapita: pdrbController.text,
                    vsJawaTengah: vsJatengController.text,
                    vsNasional: vsNasionalController.text,
                    distrikTertinggi: distrikControllers
                        .map((c) => DistrikData(nama: c.text))
                        .toList(),
                    semarangData: semarangData,
                    jatengData: jatengData,
                  ),
                );
              }
              
              setState(() {}); // Refresh UI
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEdit ? 'Data berhasil diupdate' : 'Data berhasil ditambahkan'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
              foregroundColor: Colors.white,
            ),
            child: Text(isEdit ? 'Update' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, EkonomiData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus data tahun ${data.tahun}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              dataManager.deleteData(data.id);
              setState(() {}); // Refresh UI
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data berhasil dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
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