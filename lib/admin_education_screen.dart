import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'education_data.dart';
import 'education_service.dart';
import 'add_edit_education.dart';

class AdminEducationScreen extends StatefulWidget {
  const AdminEducationScreen({Key? key}) : super(key: key);

  @override
  State<AdminEducationScreen> createState() => _AdminEducationScreenState();
}

class _AdminEducationScreenState extends State<AdminEducationScreen> {
  final EducationService _service = EducationService();
  Map<String, EducationData> _allData = {};
  bool _isLoading = true;
  String? selectedYear;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getAllData();
      if (mounted) {
        setState(() {
          _allData = data;
          _isLoading = false;
          if (_allData.isNotEmpty && selectedYear == null) {
            final years = _allData.keys.toList();
            years.sort((a, b) => b.compareTo(a));
            selectedYear = years.first;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Gagal memuat data: $e');
      }
    }
  }

  Future<void> _deleteYear(String year) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus data tahun $year?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _service.deleteYearData(year);
      if (success) {
        _showSuccessSnackBar('Data tahun $year berhasil dihapus');
        if (selectedYear == year) {
          selectedYear = null;
        }
        _loadData();
      } else {
        _showErrorSnackBar('Gagal menghapus data');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int getTotalMurid(String year) {
    final data = _allData[year];
    if (data == null) return 0;
    return data.jenjangPendidikan.fold<int>(0, (sum, item) => sum + item.murid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        title: const Text(
          'Kelola Data Pendidikan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFF8C51F3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'reset') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Data'),
                    content:
                        const Text('Reset semua data ke default (2022-2024)?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  final success = await _service.resetToDefault();
                  if (success) {
                    _showSuccessSnackBar('Data berhasil direset');
                    selectedYear = null;
                    _loadData();
                  }
                }
              } else if (value == 'export') {
                final jsonString = await _service.exportToJson();
                if (jsonString.isNotEmpty) {
                  _showSuccessSnackBar('Data berhasil diekspor');
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.upload, size: 20),
                    SizedBox(width: 12),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restore, size: 20),
                    SizedBox(width: 12),
                    Text('Reset ke Default'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _allData.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildHeaderCard(),
                        const SizedBox(height: 16),
                        _buildYearSelector(),
                        if (selectedYear != null) ...[
                          const SizedBox(height: 16),
                          _buildMainStatsGrid(),
                          const SizedBox(height: 16),
                          _buildEducationLevelChart(),
                          const SizedBox(height: 16),
                          _buildRasioChart(),
                          const SizedBox(height: 16),
                          _buildPartisipasiChart(),
                          const SizedBox(height: 16),
                          _buildDropoutRateCard(),
                          const SizedBox(height: 16),
                          _buildAdditionalStats(),
                          const SizedBox(height: 16),
                          _buildActionButtons(),
                        ] else ...[
                          const SizedBox(height: 16),
                          _buildDataList(),
                        ],
                        const SizedBox(height: 80),
                      ],
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditEducationScreen(),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: const Color(0xFF8C51F3),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Data'),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8C51F3), Color(0xFF7D42E9)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8C51F3).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Pendidikan Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_allData.length} tahun data tersedia',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
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

  Widget _buildYearSelector() {
    final years = _allData.keys.toList();
    years.sort((a, b) => b.compareTo(a));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.calendar_today,
                    color: Color(0xFF87C8EB), size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pilih Tahun Data',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (selectedYear != null)
                TextButton.icon(
                  onPressed: () => setState(() => selectedYear = null),
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Lihat Semua'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8C51F3),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: years.map((year) {
              final isSelected = year == selectedYear;
              return GestureDetector(
                onTap: () => setState(() => selectedYear = year),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFC41EE5), Color(0xFF64B5F6)],
                          )
                        : null,
                    color: isSelected ? null : Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    year,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatsGrid() {
    if (selectedYear == null || !_allData.containsKey(selectedYear)) {
      return const SizedBox.shrink();
    }

    final data = _allData[selectedYear]!;
    final totalMurid = getTotalMurid(selectedYear!);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
            'Total Murid',
            '${(totalMurid / 1000).toStringAsFixed(1)}k',
            Icons.groups,
            Colors.blue),
        _buildStatCard('Melek Huruf', '${data.angkaMelekHuruf}%',
            Icons.menu_book, Colors.green),
        _buildStatCard('Rata-rata Lama Sekolah',
            '${data.rataRataLamaSekolah} tahun', Icons.timer, Colors.orange),
        _buildStatCard('Tingkat Kelulusan', '${data.tingkatKelulusan}%',
            Icons.emoji_events, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEducationLevelChart() {
    if (selectedYear == null || !_allData.containsKey(selectedYear)) {
      return const SizedBox.shrink();
    }

    final data = _allData[selectedYear]!.jenjangPendidikan;
    final colors = [
      Colors.blue,
      Colors.lightBlue,
      Colors.green,
      Colors.lightGreen,
      Colors.orange,
      Colors.deepOrange,
      Colors.purple,
      Colors.deepPurple,
      Colors.pink,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purple.shade400]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.bar_chart, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Jumlah Murid per Jenjang',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Tahun $selectedYear',
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: data.fold<double>(
                        0,
                        (max, item) =>
                            item.murid > max ? item.murid.toDouble() : max) *
                    1.1,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (groupIndex >= data.length) return null;
                      return BarTooltipItem(
                        '${data[groupIndex].jenjang}\n${(rod.toY / 1000).toStringAsFixed(1)} ribu murid',
                        const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(data[index].jenjang,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Text('${(value / 1000).toInt()}k',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[600]));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey[200], strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data[index].murid.toDouble(),
                        gradient: LinearGradient(
                          colors: [
                            colors[index % colors.length],
                            colors[index % colors.length].withOpacity(0.7)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRasioChart() {
    if (selectedYear == null || !_allData.containsKey(selectedYear)) {
      return const SizedBox.shrink();
    }

    final rasioData = _allData[selectedYear]!.rasioData;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Colors.pink, Colors.deepPurple]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.bar_chart, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Rasio Sekolah-Murid dan Guru-Murid',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Tahun $selectedYear',
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 6),
              const Text('Sekolah-Murid',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 6),
              const Text('Guru-Murid',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: rasioData.fold<double>(
                        0,
                        (max, item) => item.rasioSekolahMurid > max
                            ? item.rasioSekolahMurid
                            : max) *
                    1.2,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (groupIndex >= rasioData.length) return null;
                      String label = rodIndex == 0 ? 'Sekolah' : 'Guru';
                      return BarTooltipItem(
                        '${rasioData[groupIndex].jenjang}\n1 $label : ${rod.toY.toStringAsFixed(2)} murid',
                        const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < rasioData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(rasioData[index].jenjang,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) => Text('${value.toInt()}',
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[600])),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey[200], strokeWidth: 1),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                      left: BorderSide(color: Colors.grey[300]!)),
                ),
                barGroups: rasioData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                          toY: entry.value.rasioSekolahMurid,
                          color: Colors.pink,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4))),
                      BarChartRodData(
                          toY: entry.value.rasioGuruMurid,
                          color: Colors.deepPurple,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartisipasiChart() {
    if (selectedYear == null || !_allData.containsKey(selectedYear)) {
      return const SizedBox.shrink();
    }

    final partisipasiData = _allData[selectedYear]!.partisipasiPendidikan;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.teal, Colors.green.shade400]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.bar_chart, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Angka Partisipasi Murni (APM) dan Kasar (APK)',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Tahun $selectedYear',
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 6),
              const Text('APM',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 6),
              const Text('APK',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 110,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (groupIndex >= partisipasiData.length) return null;
                      String label = rodIndex == 0 ? 'APM' : 'APK';
                      return BarTooltipItem(
                        '${partisipasiData[groupIndex].jenjang}\n$label: ${rod.toY.toStringAsFixed(2)}%',
                        const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < partisipasiData.length) {
                          String jenjang = partisipasiData[index].jenjang;
                          if (jenjang.length > 15) {
                            jenjang = jenjang.replaceAll('Sederajat', '');
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(jenjang,
                                style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87),
                                textAlign: TextAlign.center),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 20,
                      getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}%',
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[600])),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey[200], strokeWidth: 1),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                      left: BorderSide(color: Colors.grey[300]!)),
                ),
                barGroups: partisipasiData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                          toY: entry.value.apm,
                          color: Colors.teal,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4))),
                      BarChartRodData(
                          toY: entry.value.apk,
                          color: Colors.green.shade400,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropoutRateCard() {
    if (selectedYear == null || !_allData.containsKey(selectedYear)) {
      return const SizedBox.shrink();
    }

    final dropoutData = _allData[selectedYear]!.angkaPutusSekolah;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.orange.shade400]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.trending_down,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Angka Putus Sekolah',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Tahun $selectedYear',
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 16),
          ...dropoutData.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.tingkat,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                      Text('${item.persentase}%',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: item.persentase / 5,
                      minHeight: 7,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.orange.shade400),
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

  Widget _buildAdditionalStats() {
    if (selectedYear == null || !_allData.containsKey(selectedYear)) {
      return const SizedBox.shrink();
    }

    final data = _allData[selectedYear]!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.deepPurple.shade50, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.people, 'Rasio Guru:Murid',
              '1:${data.rasioGuruMurid}', Colors.deepPurple),
          const Divider(height: 20),
          _buildInfoRow(Icons.school, 'Harapan Lama Sekolah',
              '${data.harapanLamaSekolah} tahun', Colors.purple),
          const Divider(height: 20),
          _buildInfoRow(Icons.business, 'Akses Pendidikan Tinggi',
              '${data.aksesPendidikanTinggi}%', Colors.indigo),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 3),
              Text(value,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (selectedYear == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final data = _allData[selectedYear!];
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditEducationScreen(
                      editData: data, editYear: selectedYear!),
                ),
              );
              if (result == true) {
                _loadData();
              }
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8C51F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _deleteYear(selectedYear!),
            icon: const Icon(Icons.delete),
            label: const Text('Hapus Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataList() {
    final years = _allData.keys.toList();
    years.sort((a, b) => b.compareTo(a));

    return Column(
      children: years.map((year) {
        final data = _allData[year]!;
        final totalMurid = getTotalMurid(year);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF8C51F3).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF8C51F3), Color(0xFF7D42E9)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(year,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.visibility,
                          color: Color(0xFF8C51F3)),
                      onPressed: () => setState(() => selectedYear = year),
                      tooltip: 'Lihat Detail',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF8C51F3)),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddEditEducationScreen(
                                  editData: data, editYear: year)),
                        );
                        if (result == true) {
                          _loadData();
                        }
                      },
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteYear(year),
                      tooltip: 'Hapus',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildMiniStat(
                            'Total Murid',
                            '${(totalMurid / 1000).toStringAsFixed(1)}k',
                            Icons.groups,
                            Colors.blue),
                        const SizedBox(width: 12),
                        _buildMiniStat(
                            'Melek Huruf',
                            '${data.angkaMelekHuruf}%',
                            Icons.menu_book,
                            Colors.green),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildMiniStat('Kelulusan', '${data.tingkatKelulusan}%',
                            Icons.emoji_events, Colors.orange),
                        const SizedBox(width: 12),
                        _buildMiniStat(
                            'Lama Sekolah',
                            '${data.rataRataLamaSekolah} th',
                            Icons.timer,
                            Colors.purple),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMiniStat(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  Text(label,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Belum ada data',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Tap tombol + untuk menambah data',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }
}