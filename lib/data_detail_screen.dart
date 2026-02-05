import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';

class DataDetailScreen extends StatefulWidget {
  final String dataId;
  final String title;

  const DataDetailScreen(
      {super.key, required this.dataId, required this.title});

  @override
  _DataDetailScreenState createState() => _DataDetailScreenState();
}

class _DataDetailScreenState extends State<DataDetailScreen> {
  Map<String, dynamic>? dataDetail;
  List<String> availableYears = ['2018', '2019', '2020', '2021', '2022'];
  List<String> availableProvinces = [
    'Semua Provinsi',
    'Jawa Barat',
    'Jawa Tengah',
    'Jawa Timur',
    'Bali',
    'Sumatera Utara',
    'DKI Jakarta',
  ];

  String selectedYear = '2022';
  String selectedProvince = 'Semua Provinsi';
  bool isLoading = true;
  bool isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadDataDetail();
  }

  Future<void> _loadDataDetail() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Simulate API call with dummy data
      await Future.delayed(const Duration(seconds: 1));

      dataDetail = _getDummyData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    }

    setState(() {
      isLoading = false;
    });
  }

  Map<String, dynamic> _getDummyData() {
    switch (widget.dataId) {
      case 'jumlah-penduduk':
        return {
          'title': 'Jumlah Penduduk',
          'unit': 'Juta Jiwa',
          'description':
              'Data jumlah penduduk Indonesia berdasarkan proyeksi penduduk',
          'source': 'Badan Pusat Statistik',
          'last_update': '2022-12-31',
          'chart_data': [
            {'year': '2018', 'value': 264.16},
            {'year': '2019', 'value': 266.91},
            {'year': '2020', 'value': 267.66},
            {'year': '2021', 'value': 270.20},
            {'year': '2022', 'value': 272.23},
          ],
          'current_value': 272.23,
          'growth_rate': 1.31,
        };
      case 'penduduk-miskin':
        return {
          'title': 'Penduduk Miskin',
          'unit': 'Persen',
          'description': 'Persentase penduduk miskin terhadap total penduduk',
          'source': 'Badan Pusat Statistik',
          'last_update': '2022-09-15',
          'chart_data': [
            {'year': '2018', 'value': 9.82},
            {'year': '2019', 'value': 9.41},
            {'year': '2020', 'value': 10.19},
            {'year': '2021', 'value': 10.14},
            {'year': '2022', 'value': 9.54},
          ],
          'current_value': 9.54,
          'growth_rate': -5.9,
        };
      default:
        return {
          'title': widget.title,
          'unit': 'Unit',
          'description': 'Deskripsi data ${widget.title}',
          'source': 'Badan Pusat Statistik',
          'last_update': '2022-12-31',
          'chart_data': [
            {'year': '2018', 'value': 100},
            {'year': '2019', 'value': 110},
            {'year': '2020', 'value': 105},
            {'year': '2021', 'value': 115},
            {'year': '2022', 'value': 120},
          ],
          'current_value': 120,
          'growth_rate': 4.35,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareData)
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 20),
          _buildFilters(),
          const SizedBox(height: 20),
          _buildChart(),
          const SizedBox(height: 20),
          _buildDataInfo(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (dataDetail == null) return const SizedBox();

    final currentValue = dataDetail!['current_value'];
    final growthRate = dataDetail!['growth_rate'];
    final unit = dataDetail!['unit'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nilai Saat Ini',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentValue.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: growthRate >= 0
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      growthRate >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${growthRate >= 0 ? '+' : ''}${growthRate.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'dari tahun sebelumnya',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildDropdown('Tahun', selectedYear, availableYears, (
                value,
              ) {
                setState(() {
                  selectedYear = value!;
                });
                _loadDataDetail();
              }),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDropdown(
                'Provinsi',
                selectedProvince,
                availableProvinces,
                (value) {
                  setState(() {
                    selectedProvince = value!;
                  });
                  _loadDataDetail();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: onChanged,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    if (dataDetail == null) return const SizedBox();

    final chartData = dataDetail!['chart_data'] as List;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perkembangan Data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getChartInterval(chartData),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatYAxisValue(value),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < chartData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              chartData[value.toInt()]['year'],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                    left: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value['value'].toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF1976D2),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF1976D2),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF1976D2).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getChartInterval(List chartData) {
    // Use .toDouble() instead of 'as double' to handle both int and double values
    final values =
        chartData.map((item) => (item['value'] as num).toDouble()).toList();
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    return (max - min) / 4;
  }

  String _formatYAxisValue(double value) {
    if (dataDetail!['unit'] == 'Juta Jiwa') {
      return '${value.toInt()}M';
    } else if (dataDetail!['unit'] == 'Persen') {
      return '${value.toStringAsFixed(1)}%';
    }
    return value.toStringAsFixed(1);
  }

  Widget _buildDataInfo() {
    if (dataDetail == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoRow('Deskripsi', dataDetail!['description']),
          const SizedBox(height: 12),
          _buildInfoRow('Sumber', dataDetail!['source']),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Terakhir Update',
            _formatDate(dataDetail!['last_update']),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Satuan', dataDetail!['unit']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(': ', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isExporting ? null : () => _exportData('pdf'),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isExporting ? null : () => _exportData('excel'),
              icon: const Icon(Icons.table_chart),
              label: const Text('Excel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isExporting ? null : () => _exportData('image'),
              icon: const Icon(Icons.image),
              label: const Text('Gambar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(String format) async {
    setState(() {
      isExporting = true;
    });

    try {
      // Simulate export process
      await Future.delayed(const Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data berhasil diexport dalam format $format'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal export data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isExporting = false;
      });
    }
  }

  void _shareData() {
    final title = widget.title;
    final value = dataDetail?['current_value']?.toString() ?? 'N/A';
    final unit = dataDetail?['unit'] ?? '';

    Share.share(
      'Data $title: $value $unit\n\nSumber: Aplikasi Statistik Indonesia',
      subject: 'Data Statistik: $title',
    );
  }
}
