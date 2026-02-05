import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'education_data.dart';
import 'education_service.dart';

class AddEditEducationScreen extends StatefulWidget {
  final EducationData? editData;
  final String? editYear;

  const AddEditEducationScreen({
    Key? key,
    this.editData,
    this.editYear,
  }) : super(key: key);

  @override
  State<AddEditEducationScreen> createState() => _AddEditEducationScreenState();
}

class _AddEditEducationScreenState extends State<AddEditEducationScreen> {
  final _formKey = GlobalKey<FormState>();
  final EducationService _service = EducationService();
  bool _isLoading = false;

  // Controllers untuk data umum
  late TextEditingController _yearController;
  late TextEditingController _angkaMelekHurufController;
  late TextEditingController _rataRataLamaSekolahController;
  late TextEditingController _harapanLamaSekolahController;
  late TextEditingController _rasioGuruMuridController;
  late TextEditingController _tingkatKelulusanController;
  late TextEditingController _aksesPendidikanTinggiController;

  // Data jenjang pendidikan
  final List<Map<String, TextEditingController>> _jenjangControllers = [];
  final List<String> _jenjangList = [
    'TK',
    'RA',
    'SD',
    'MI',
    'SMP',
    'MTs',
    'SMA',
    'SMK',
    'MA'
  ];

  // Data rasio
  final List<Map<String, TextEditingController>> _rasioControllers = [];
  final List<String> _rasioJenjangList = [
    'TK/RA',
    'SD/MI',
    'SMP/MTs',
    'SMA/SMK/MA'
  ];

  // Data putus sekolah
  final List<Map<String, TextEditingController>> _putusSekolahControllers = [];
  final List<String> _putusTingkatList = ['SD', 'SMP', 'SMA'];

  // Data partisipasi
  final List<Map<String, TextEditingController>> _partisipasiControllers = [];
  final List<String> _partisipasiJenjangList = [
    'SD/MI/Sederajat',
    'SMP/MTs/Sederajat',
    'SMA/SMK/MA/Sederajat'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final editData = widget.editData;

    // Data umum
    _yearController = TextEditingController(
      text: editData?.year ?? DateTime.now().year.toString(),
    );
    _angkaMelekHurufController = TextEditingController(
      text: editData?.angkaMelekHuruf.toString() ?? '96.0',
    );
    _rataRataLamaSekolahController = TextEditingController(
      text: editData?.rataRataLamaSekolah.toString() ?? '8.0',
    );
    _harapanLamaSekolahController = TextEditingController(
      text: editData?.harapanLamaSekolah.toString() ?? '13.0',
    );
    _rasioGuruMuridController = TextEditingController(
      text: editData?.rasioGuruMurid.toString() ?? '15.0',
    );
    _tingkatKelulusanController = TextEditingController(
      text: editData?.tingkatKelulusan.toString() ?? '98.0',
    );
    _aksesPendidikanTinggiController = TextEditingController(
      text: editData?.aksesPendidikanTinggi.toString() ?? '30.0',
    );

    // Jenjang pendidikan
    for (int i = 0; i < _jenjangList.length; i++) {
      final existing = editData?.jenjangPendidikan.firstWhere(
        (e) => e.jenjang == _jenjangList[i],
        orElse: () => JenjangPendidikan(
            jenjang: _jenjangList[i], sekolah: 0, guru: 0, murid: 0),
      );

      _jenjangControllers.add({
        'sekolah':
            TextEditingController(text: existing?.sekolah.toString() ?? '0'),
        'guru': TextEditingController(text: existing?.guru.toString() ?? '0'),
        'murid': TextEditingController(text: existing?.murid.toString() ?? '0'),
      });
    }

    // Rasio
    for (int i = 0; i < _rasioJenjangList.length; i++) {
      final existing = editData?.rasioData.firstWhere(
        (e) => e.jenjang == _rasioJenjangList[i],
        orElse: () => RasioData(
            jenjang: _rasioJenjangList[i],
            rasioSekolahMurid: 0,
            rasioGuruMurid: 0),
      );

      _rasioControllers.add({
        'sekolahMurid': TextEditingController(
            text: existing?.rasioSekolahMurid.toString() ?? '0'),
        'guruMurid': TextEditingController(
            text: existing?.rasioGuruMurid.toString() ?? '0'),
      });
    }

    // Putus sekolah
    for (int i = 0; i < _putusTingkatList.length; i++) {
      final existing = editData?.angkaPutusSekolah.firstWhere(
        (e) => e.tingkat == _putusTingkatList[i],
        orElse: () =>
            AngkaPutusSekolah(tingkat: _putusTingkatList[i], persentase: 0),
      );

      _putusSekolahControllers.add({
        'persentase':
            TextEditingController(text: existing?.persentase.toString() ?? '0'),
      });
    }

    // Partisipasi
    for (int i = 0; i < _partisipasiJenjangList.length; i++) {
      final existing = editData?.partisipasiPendidikan.firstWhere(
        (e) => e.jenjang == _partisipasiJenjangList[i],
        orElse: () => PartisipasiPendidikan(
            jenjang: _partisipasiJenjangList[i], apm: 0, apk: 0),
      );

      _partisipasiControllers.add({
        'apm': TextEditingController(text: existing?.apm.toString() ?? '0'),
        'apk': TextEditingController(text: existing?.apk.toString() ?? '0'),
      });
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    _angkaMelekHurufController.dispose();
    _rataRataLamaSekolahController.dispose();
    _harapanLamaSekolahController.dispose();
    _rasioGuruMuridController.dispose();
    _tingkatKelulusanController.dispose();
    _aksesPendidikanTinggiController.dispose();

    for (var controllers in _jenjangControllers) {
      controllers.values.forEach((c) => c.dispose());
    }
    for (var controllers in _rasioControllers) {
      controllers.values.forEach((c) => c.dispose());
    }
    for (var controllers in _putusSekolahControllers) {
      controllers.values.forEach((c) => c.dispose());
    }
    for (var controllers in _partisipasiControllers) {
      controllers.values.forEach((c) => c.dispose());
    }

    super.dispose();
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Build jenjang pendidikan list
      final jenjangList = <JenjangPendidikan>[];
      for (int i = 0; i < _jenjangList.length; i++) {
        jenjangList.add(JenjangPendidikan(
          jenjang: _jenjangList[i],
          sekolah: int.parse(_jenjangControllers[i]['sekolah']!.text),
          guru: int.parse(_jenjangControllers[i]['guru']!.text),
          murid: int.parse(_jenjangControllers[i]['murid']!.text),
        ));
      }

      // Build rasio list
      final rasioList = <RasioData>[];
      for (int i = 0; i < _rasioJenjangList.length; i++) {
        rasioList.add(RasioData(
          jenjang: _rasioJenjangList[i],
          rasioSekolahMurid:
              double.parse(_rasioControllers[i]['sekolahMurid']!.text),
          rasioGuruMurid: double.parse(_rasioControllers[i]['guruMurid']!.text),
        ));
      }

      // Build putus sekolah list
      final putusSekolahList = <AngkaPutusSekolah>[];
      for (int i = 0; i < _putusTingkatList.length; i++) {
        putusSekolahList.add(AngkaPutusSekolah(
          tingkat: _putusTingkatList[i],
          persentase:
              double.parse(_putusSekolahControllers[i]['persentase']!.text),
        ));
      }

      // Build partisipasi list
      final partisipasiList = <PartisipasiPendidikan>[];
      for (int i = 0; i < _partisipasiJenjangList.length; i++) {
        partisipasiList.add(PartisipasiPendidikan(
          jenjang: _partisipasiJenjangList[i],
          apm: double.parse(_partisipasiControllers[i]['apm']!.text),
          apk: double.parse(_partisipasiControllers[i]['apk']!.text),
        ));
      }

      // Create EducationData object
      final educationData = EducationData(
        year: _yearController.text,
        angkaMelekHuruf: double.parse(_angkaMelekHurufController.text),
        rataRataLamaSekolah: double.parse(_rataRataLamaSekolahController.text),
        harapanLamaSekolah: double.parse(_harapanLamaSekolahController.text),
        rasioGuruMurid: double.parse(_rasioGuruMuridController.text),
        tingkatKelulusan: double.parse(_tingkatKelulusanController.text),
        aksesPendidikanTinggi:
            double.parse(_aksesPendidikanTinggiController.text),
        jenjangPendidikan: jenjangList,
        rasioData: rasioList,
        angkaPutusSekolah: putusSekolahList,
        partisipasiPendidikan: partisipasiList,
      );

      bool success;
      if (widget.editYear != null) {
        // Update existing
        success =
            await _service.updateYearData(widget.editYear!, educationData);
      } else {
        // Add new
        success = await _service.addYearData(educationData);
      }

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(widget.editYear != null
                      ? 'Data berhasil diperbarui'
                      : 'Data berhasil ditambahkan'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan data'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        title: Text(
          widget.editYear != null
              ? 'Edit Data Tahun ${widget.editYear}'
              : 'Tambah Data Baru',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8C51F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDataUmumSection(),
            const SizedBox(height: 16),
            _buildJenjangPendidikanSection(),
            const SizedBox(height: 16),
            _buildRasioSection(),
            const SizedBox(height: 16),
            _buildPutusSekolahSection(),
            const SizedBox(height: 16),
            _buildPartisipasiSection(),
            const SizedBox(height: 24),
            _buildSaveButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDataUmumSection() {
    return _buildSection(
      title: 'Data Umum',
      icon: Icons.info_outline,
      color: const Color(0xFF8C51F3),
      children: [
        _buildTextField(
          controller: _yearController,
          label: 'Tahun',
          hint: '2024',
          keyboardType: TextInputType.number,
          enabled: widget.editYear == null,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _angkaMelekHurufController,
          label: 'Angka Melek Huruf (%)',
          hint: '96.0',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _rataRataLamaSekolahController,
          label: 'Rata-rata Lama Sekolah (tahun)',
          hint: '8.0',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _harapanLamaSekolahController,
          label: 'Harapan Lama Sekolah (tahun)',
          hint: '13.0',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _rasioGuruMuridController,
          label: 'Rasio Guru:Murid',
          hint: '15.0',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _tingkatKelulusanController,
          label: 'Tingkat Kelulusan (%)',
          hint: '98.0',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _aksesPendidikanTinggiController,
          label: 'Akses Pendidikan Tinggi (%)',
          hint: '30.0',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildJenjangPendidikanSection() {
    return _buildSection(
      title: 'Jenjang Pendidikan',
      icon: Icons.school,
      color: Colors.blue,
      children: List.generate(_jenjangList.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _jenjangList[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _jenjangControllers[index]['sekolah']!,
                        label: 'Sekolah',
                        hint: '0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        controller: _jenjangControllers[index]['guru']!,
                        label: 'Guru',
                        hint: '0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        controller: _jenjangControllers[index]['murid']!,
                        label: 'Murid',
                        hint: '0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRasioSection() {
    return _buildSection(
      title: 'Rasio Sekolah-Murid & Guru-Murid',
      icon: Icons.bar_chart,
      color: Colors.purple,
      children: List.generate(_rasioJenjangList.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _rasioJenjangList[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _rasioControllers[index]['sekolahMurid']!,
                        label: 'Rasio Sekolah-Murid',
                        hint: '0.0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _rasioControllers[index]['guruMurid']!,
                        label: 'Rasio Guru-Murid',
                        hint: '0.0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPutusSekolahSection() {
    return _buildSection(
      title: 'Angka Putus Sekolah',
      icon: Icons.trending_down,
      color: Colors.orange,
      children: List.generate(_putusTingkatList.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  _putusTingkatList[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: _buildTextField(
                  controller: _putusSekolahControllers[index]['persentase']!,
                  label: 'Persentase (%)',
                  hint: '0.0',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPartisipasiSection() {
    return _buildSection(
      title: 'Partisipasi Pendidikan (APM & APK)',
      icon: Icons.people,
      color: Colors.teal,
      children: List.generate(_partisipasiJenjangList.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _partisipasiJenjangList[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _partisipasiControllers[index]['apm']!,
                        label: 'APM (%)',
                        hint: '0.0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _partisipasiControllers[index]['apk']!,
                        label: 'APK (%)',
                        hint: '0.0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8C51F3), width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[200],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Wajib diisi';
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveData,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8C51F3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save),
                  const SizedBox(width: 8),
                  Text(
                    widget.editYear != null ? 'Perbarui Data' : 'Simpan Data',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}