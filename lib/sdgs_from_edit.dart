import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sdgs_data_service.dart';

class SDGsFormEditScreen extends StatefulWidget {
  final KotaData? kotaData;
  final Function(KotaData) onSave;

  const SDGsFormEditScreen({
    Key? key,
    this.kotaData,
    required this.onSave,
  }) : super(key: key);

  @override
  State<SDGsFormEditScreen> createState() => _SDGsFormEditScreenState();
}

class _SDGsFormEditScreenState extends State<SDGsFormEditScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TabController _tabController;

  // Data maps
  Map<int, double> samitasilayak = {};
  Map<int, double> tikRemaja = {};
  Map<int, double> tikDewasa = {};
  Map<int, double> aktaLahir = {};
  Map<int, double> apm = {};
  Map<int, double> apk = {};

  // Text controllers for each year and indicator
  Map<String, TextEditingController> _controllers = {};

  int selectedYear = 2024;
  bool _isSaving = false;

  final List<int> years = [2024, 2023, 2022, 2021, 2020, 2019];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _namaController = TextEditingController(text: widget.kotaData?.nama ?? '');

    // Initialize data
    _initializeData();
    _initializeControllers();
  }

  void _initializeData() {
    if (widget.kotaData != null) {
      samitasilayak = Map.from(widget.kotaData!.samitasilayak);
      tikRemaja = Map.from(widget.kotaData!.tikRemaja);
      tikDewasa = Map.from(widget.kotaData!.tikDewasa);
      aktaLahir = Map.from(widget.kotaData!.aktaLahir);
      apm = Map.from(widget.kotaData!.apm);
      apk = Map.from(widget.kotaData!.apk);
    }

    // Initialize with 0 for all years if empty
    for (var year in years) {
      samitasilayak.putIfAbsent(year, () => 0.0);
      tikRemaja.putIfAbsent(year, () => 0.0);
      tikDewasa.putIfAbsent(year, () => 0.0);
      aktaLahir.putIfAbsent(year, () => 0.0);
      apm.putIfAbsent(year, () => 0.0);
      apk.putIfAbsent(year, () => 0.0);
    }
  }

  void _initializeControllers() {
    _controllers.clear();

    for (var year in years) {
      _controllers['samitasilayak_$year'] = TextEditingController(
        text: (samitasilayak[year] ?? 0).toStringAsFixed(2),
      );
      _controllers['tikRemaja_$year'] = TextEditingController(
        text: (tikRemaja[year] ?? 0).toStringAsFixed(2),
      );
      _controllers['tikDewasa_$year'] = TextEditingController(
        text: (tikDewasa[year] ?? 0).toStringAsFixed(2),
      );
      _controllers['aktaLahir_$year'] = TextEditingController(
        text: (aktaLahir[year] ?? 0).toStringAsFixed(2),
      );
      _controllers['apm_$year'] = TextEditingController(
        text: (apm[year] ?? 0).toStringAsFixed(2),
      );
      _controllers['apk_$year'] = TextEditingController(
        text: (apk[year] ?? 0).toStringAsFixed(2),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _namaController.dispose();
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _updateDataFromControllers() {
    for (var year in years) {
      samitasilayak[year] =
          double.tryParse(_controllers['samitasilayak_$year']?.text ?? '0') ??
              0;
      tikRemaja[year] =
          double.tryParse(_controllers['tikRemaja_$year']?.text ?? '0') ?? 0;
      tikDewasa[year] =
          double.tryParse(_controllers['tikDewasa_$year']?.text ?? '0') ?? 0;
      aktaLahir[year] =
          double.tryParse(_controllers['aktaLahir_$year']?.text ?? '0') ?? 0;
      apm[year] = double.tryParse(_controllers['apm_$year']?.text ?? '0') ?? 0;
      apk[year] = double.tryParse(_controllers['apk_$year']?.text ?? '0') ?? 0;
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }

    setState(() => _isSaving = true);

    _updateDataFromControllers();

    final newData = KotaData(
      id: widget.kotaData?.id ?? '',
      nama: _namaController.text.trim(),
      samitasilayak: samitasilayak,
      tikRemaja: tikRemaja,
      tikDewasa: tikDewasa,
      aktaLahir: aktaLahir,
      apm: apm,
      apk: apk,
      lastModified: DateTime.now(),
    );

    widget.onSave(newData);
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.kotaData == null ? 'Tambah Data Kota' : 'Edit Data Kota',
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveData,
              tooltip: 'Simpan',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              color: const Color(0xFF1976D2),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.edit_note),
                    text: 'Input Data',
                  ),
                  Tab(
                    icon: Icon(Icons.preview),
                    text: 'Preview',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInputTab(),
                  _buildPreviewTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.kotaData == null ? 'Simpan' : 'Update',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Nama Kota Section
          _buildSectionHeader('Informasi Dasar', Icons.info_outline),
          const SizedBox(height: 12),
          TextFormField(
            controller: _namaController,
            decoration: InputDecoration(
              labelText: 'Nama Kota/Kabupaten',
              hintText: 'Contoh: Kota Semarang',
              prefixIcon: const Icon(Icons.location_city),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama kota harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Year Selector
          _buildSectionHeader('Pilih Tahun', Icons.calendar_today),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedYear,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                items: years.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text(
                      'Tahun $year',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedYear = value ?? 2024;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Indicators Section
          _buildSectionHeader(
              'Data Indikator SDGs - $selectedYear', Icons.show_chart),
          const SizedBox(height: 16),

          _buildIndicatorInput(
            label: 'Samitasilayak',
            key: 'samitasilayak',
            icon: Icons.clean_hands,
            color: const Color(0xFF00A8E8),
            description: 'Goal 6: Air Bersih dan Sanitasi',
          ),
          const SizedBox(height: 14),

          _buildIndicatorInput(
            label: 'TIK Remaja (15-24 tahun)',
            key: 'tikRemaja',
            icon: Icons.computer,
            color: const Color(0xFF4CAF50),
            description: 'Goal 17: Inklusi Digital',
          ),
          const SizedBox(height: 14),

          _buildIndicatorInput(
            label: 'TIK Dewasa (15-59 tahun)',
            key: 'tikDewasa',
            icon: Icons.devices,
            color: const Color(0xFFFF9800),
            description: 'Goal 17: Inklusi Digital',
          ),
          const SizedBox(height: 14),

          _buildIndicatorInput(
            label: 'Akta Lahir',
            key: 'aktaLahir',
            icon: Icons.assignment,
            color: const Color(0xFF9C27B0),
            description: 'Goal 16: Kepemilikan Akta Lahir',
          ),
          const SizedBox(height: 14),

          _buildIndicatorInput(
            label: 'APM (Angka Partisipasi Murni)',
            key: 'apm',
            icon: Icons.school,
            color: const Color(0xFFF44336),
            description: 'Goal 4: Pendidikan Berkualitas',
          ),
          const SizedBox(height: 14),

          _buildIndicatorInput(
            label: 'APK (Angka Partisipasi Kasar)',
            key: 'apk',
            icon: Icons.auto_graph,
            color: const Color(0xFF009688),
            description: 'Goal 4: Pendidikan Berkualitas',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1976D2), size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorInput({
    required String label,
    required String key,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    final controller = _controllers['${key}_$selectedYear']!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextFormField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Nilai ($selectedYear)',
                hintText: '0.00',
                suffixText: '%',
                prefixIcon: Icon(Icons.edit, color: color, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: color, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: color, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nilai harus diisi';
                }
                final doubleValue = double.tryParse(value);
                if (doubleValue == null) {
                  return 'Nilai harus berupa angka';
                }
                if (doubleValue < 0 || doubleValue > 100) {
                  return 'Nilai harus antara 0-100';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple.shade50, Colors.white],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.purple.shade600],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.preview, color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    const Text(
                      'Preview Data',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_city,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _namaController.text.isEmpty
                              ? 'Belum ada nama kota'
                              : _namaController.text,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Preview Cards
          _buildPreviewCard(
            'samitasilayak',
            samitasilayak,
            const Color(0xFF00A8E8),
            Icons.clean_hands,
          ),
          const SizedBox(height: 10),
          _buildPreviewCard(
            'TIK Remaja',
            tikRemaja,
            const Color(0xFF4CAF50),
            Icons.computer,
          ),
          const SizedBox(height: 10),
          _buildPreviewCard(
            'TIK Dewasa',
            tikDewasa,
            const Color(0xFFFF9800),
            Icons.devices,
          ),
          const SizedBox(height: 10),
          _buildPreviewCard(
            'Akta Lahir',
            aktaLahir,
            const Color(0xFF9C27B0),
            Icons.assignment,
          ),
          const SizedBox(height: 10),
          _buildPreviewCard(
            'APM',
            apm,
            const Color(0xFFF44336),
            Icons.school,
          ),
          const SizedBox(height: 10),
          _buildPreviewCard(
            'APK',
            apk,
            const Color(0xFF009688),
            Icons.auto_graph,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(
      String title, Map<int, double> data, Color color, IconData icon) {
    _updateDataFromControllers();

    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
    final hasData = sortedYears.any((year) {
      final value = data[year] ?? 0;
      return value > 0;
    });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: !hasData
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline,
                              size: 36, color: Colors.grey[400]),
                          const SizedBox(height: 6),
                          Text(
                            'Belum ada data',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: sortedYears.map((year) {
                        final value = data[year] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  color.withOpacity(0.2),
                                  color.withOpacity(0.25)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: color.withOpacity(0.4)),
                            ),
                            child: Text(
                              '$year: ${value.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
