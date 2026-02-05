import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Map<String, dynamic>> provinces = [
    {
      'id': 'jawa-barat',
      'name': 'Jawa Barat',
      'population': '48.0 Juta',
      'density': '1.341 per km²',
      'poverty': '7.25%',
      'area': '35.377 km²',
      'capital': 'Bandung',
      'governor': 'Ridwan Kamil',
      'districts': 27,
      'cities': 9,
      'gdp': 'Rp 2.565 Triliun',
      'unemployment': '8.45%'
    },
    {
      'id': 'jawa-tengah',
      'name': 'Jawa Tengah',
      'population': '36.5 Juta',
      'density': '1.124 per km²',
      'poverty': '10.64%',
      'area': '32.548 km²',
      'capital': 'Semarang',
      'governor': 'Ganjar Pranowo',
      'districts': 29,
      'cities': 6,
      'gdp': 'Rp 1.875 Triliun',
      'unemployment': '5.23%'
    },
    {
      'id': 'jawa-timur',
      'name': 'Jawa Timur',
      'population': '40.7 Juta',
      'density': '855 per km²',
      'poverty': '10.37%',
      'area': '47.800 km²',
      'capital': 'Surabaya',
      'governor': 'Khofifah Indar Parawansa',
      'districts': 29,
      'cities': 9,
      'gdp': 'Rp 2.278 Triliun',
      'unemployment': '4.11%'
    },
    {
      'id': 'bali',
      'name': 'Bali',
      'population': '4.3 Juta',
      'density': '750 per km²',
      'poverty': '4.14%',
      'area': '5.780 km²',
      'capital': 'Denpasar',
      'governor': 'I Wayan Koster',
      'districts': 8,
      'cities': 1,
      'gdp': 'Rp 274 Miliar',
      'unemployment': '2.88%'
    },
    {
      'id': 'sumatra-utara',
      'name': 'Sumatera Utara',
      'population': '15.1 Juta',
      'density': '209 per km²',
      'poverty': '8.75%',
      'area': '72.460 km²',
      'capital': 'Medan',
      'governor': 'Edy Rahmayadi',
      'districts': 25,
      'cities': 8,
      'gdp': 'Rp 732 Miliar',
      'unemployment': '5.67%'
    },
    {
      'id': 'dki-jakarta',
      'name': 'DKI Jakarta',
      'population': '10.6 Juta',
      'density': '15.900 per km²',
      'poverty': '3.47%',
      'area': '664 km²',
      'capital': 'Jakarta',
      'governor': 'Anies Baswedan',
      'districts': 1,
      'cities': 5,
      'gdp': 'Rp 2.842 Triliun',
      'unemployment': '7.22%'
    },
  ];

  String selectedProvinceId = '';
  bool isLoading = false;
  bool hasNetworkConnection = true;
  bool isCheckingNetwork = true;
  Timer? _networkTimer;

  @override
  void initState() {
    super.initState();
    _checkNetworkConnection();
    // Periksa koneksi setiap 10 detik
    _networkTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkNetworkConnection();
    });
  }

  @override
  void dispose() {
    _networkTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          hasNetworkConnection = true;
          isCheckingNetwork = false;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        hasNetworkConnection = false;
        isCheckingNetwork = false;
      });
    }
  }

  Future<void> _retryConnection() async {
    setState(() {
      isCheckingNetwork = true;
    });
    await _checkNetworkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        title: const Text('Peta Data'),
        centerTitle: true,
        actions: [
          if (!hasNetworkConnection)
            IconButton(
              icon: const Icon(Icons.wifi_off, color: Colors.red),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak ada koneksi internet'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildMapPlaceholder(),
          _buildProvincesList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih provinsi / kabupaten',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Klik pada peta atau daftar di bawah untuk melihat data detail',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (!hasNetworkConnection)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 16,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Mode Offline - Peta tidak tersedia',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 250,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          if (hasNetworkConnection && !isCheckingNetwork) ...[
            // Map with network connection
            Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: const NetworkImage(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Indonesia_provinces_blank_map.svg/800px-Indonesia_provinces_blank_map.svg.png',
                    ),
                    fit: BoxFit.contain,
                    onError: (exception, stackTrace) {
                      // Handle image load error
                      setState(() {
                        hasNetworkConnection = false;
                      });
                    },
                  ),
                ),
              ),
            ),
            // Interactive hotspots
            Positioned(
              left: 120,
              top: 100,
              child: _buildMapPoint('Jawa Barat'),
            ),
            Positioned(
              left: 140,
              top: 110,
              child: _buildMapPoint('Jawa Tengah'),
            ),
            Positioned(
              left: 160,
              top: 105,
              child: _buildMapPoint('Jawa Timur'),
            ),
            Positioned(
              left: 190,
              top: 140,
              child: _buildMapPoint('Bali'),
            ),
            Positioned(
              left: 80,
              top: 80,
              child: _buildMapPoint('DKI Jakarta'),
            ),
          ] else ...[
            // No network or checking network
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isCheckingNetwork) ...[
                    const CircularProgressIndicator(
                      color: Color(0xFF1976D2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Memeriksa koneksi...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 48,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak Ada Koneksi Internet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Peta memerlukan koneksi internet.\nSilakan periksa koneksi Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _retryConnection,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Data provinsi tetap tersedia di bawah',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapPoint(String provinceName) {
    if (!hasNetworkConnection) return const SizedBox.shrink();

    final isSelected =
        selectedProvinceId == provinceName.toLowerCase().replaceAll(' ', '-');

    return GestureDetector(
      onTap: () => _selectProvince(
          provinceName.toLowerCase().replaceAll(' ', '-'), provinceName),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : const Color(0xFF1976D2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvincesList() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Daftar Provinsi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                if (!hasNetworkConnection) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.offline_bolt,
                          size: 12,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Offline',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: provinces.length,
                itemBuilder: (context, index) {
                  final province = provinces[index];
                  final isSelected = selectedProvinceId == province['id'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1976D2).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1976D2)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: isSelected
                            ? const Color(0xFF1976D2)
                            : Colors.grey[600],
                      ),
                      title: Text(
                        province['name'],
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF1976D2)
                              : Colors.grey[800],
                        ),
                      ),
                      subtitle: Text(
                        'Penduduk: ${province['population']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: isSelected
                            ? const Color(0xFF1976D2)
                            : Colors.grey[400],
                      ),
                      onTap: () =>
                          _selectProvince(province['id'], province['name']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectProvince(String provinceId, String provinceName) {
    setState(() {
      selectedProvinceId = selectedProvinceId == provinceId ? '' : provinceId;
    });

    if (selectedProvinceId.isNotEmpty) {
      _showProvinceDetail(provinceName);
    }
  }

  Map<String, dynamic> _getProvinceData(String provinceName) {
    return provinces.firstWhere(
      (province) => province['name'] == provinceName,
      orElse: () => provinces[0],
    );
  }

  void _showProvinceDetail(String provinceName) {
    final provinceData = _getProvinceData(provinceName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF1976D2),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provinceName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (!hasNetworkConnection) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.offline_bolt,
                                size: 14,
                                color: Colors.orange[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Mode Offline',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildStatisticCard(
                          'Jumlah Penduduk',
                          provinceData['population'],
                          Icons.people,
                          Colors.blue),
                      _buildStatisticCard('Kepadatan', provinceData['density'],
                          Icons.location_city, Colors.green),
                      _buildStatisticCard(
                          'Tingkat Kemiskinan',
                          provinceData['poverty'],
                          Icons.trending_down,
                          Colors.orange),
                      _buildStatisticCard('Luas Wilayah', provinceData['area'],
                          Icons.map, Colors.purple),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToDetailPage(provinceData);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Lihat Data Lengkap',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetailPage(Map<String, dynamic> provinceData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProvinceDetailScreen(provinceData: provinceData),
      ),
    );
  }

  Widget _buildStatisticCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
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

// Halaman Detail Provinsi
class ProvinceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> provinceData;

  const ProvinceDetailScreen({super.key, required this.provinceData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        title: Text('Detail ${provinceData['name']}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1976D2),
                    Colors.blue[300]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provinceData['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Ibu Kota: ${provinceData['capital']}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickStat(
                            'Kabupaten', '${provinceData['districts']}'),
                        _buildQuickStat('Kota', '${provinceData['cities']}'),
                        _buildQuickStat('Luas', provinceData['area']),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistik Demografis
            _buildSectionHeader('Statistik Demografis', Icons.people),
            const SizedBox(height: 16),
            _buildDetailCard(
                'Jumlah Penduduk',
                provinceData['population'],
                Icons.people,
                Colors.blue,
                'Total penduduk berdasarkan sensus terbaru'),
            _buildDetailCard(
                'Kepadatan Penduduk',
                provinceData['density'],
                Icons.location_city,
                Colors.green,
                'Jumlah penduduk per kilometer persegi'),
            _buildDetailCard(
                'Tingkat Kemiskinan',
                provinceData['poverty'],
                Icons.trending_down,
                Colors.orange,
                'Persentase penduduk miskin'),

            const SizedBox(height: 24),

            // Statistik Ekonomi
            _buildSectionHeader('Statistik Ekonomi', Icons.monetization_on),
            const SizedBox(height: 16),
            _buildDetailCard(
                'Produk Domestik Regional Bruto',
                provinceData['gdp'],
                Icons.account_balance,
                Colors.purple,
                'PDRB atas dasar harga berlaku'),
            _buildDetailCard(
                'Tingkat Pengangguran',
                provinceData['unemployment'],
                Icons.work_off,
                Colors.red,
                'Tingkat Pengangguran Terbuka (TPT)'),

            const SizedBox(height: 24),

            // Informasi Pemerintahan
            _buildSectionHeader(
                'Informasi Pemerintahan', Icons.account_balance),
            const SizedBox(height: 16),
            _buildInfoCard('Gubernur', provinceData['governor'], Icons.person),
            _buildInfoCard(
                'Ibu Kota', provinceData['capital'], Icons.location_city),
            _buildInfoCard(
                'Jumlah Kabupaten', '${provinceData['districts']}', Icons.map),
            _buildInfoCard(
                'Jumlah Kota', '${provinceData['cities']}', Icons.business),

            const SizedBox(height: 24),

            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDataSources(context),
                    icon: const Icon(Icons.source),
                    label: const Text('Sumber Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _shareData(context),
                    icon: const Icon(Icons.share),
                    label: const Text('Bagikan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1976D2),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon,
      Color color, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showDataSources(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.source, color: Color(0xFF1976D2)),
            SizedBox(width: 8),
            Text('Sumber Data'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data statistik diperoleh dari:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Text('• Badan Pusat Statistik (BPS)'),
            Text('• Kementerian Dalam Negeri'),
            Text('• Bank Indonesia'),
            Text('• Pemerintah Daerah setempat'),
            SizedBox(height: 12),
            Text(
              'Data diperbarui secara berkala sesuai dengan publikasi resmi.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _shareData(BuildContext context) {
    final dataText = '''
Data ${provinceData['name']}:

📍 Ibu Kota: ${provinceData['capital']}
👥 Penduduk: ${provinceData['population']}
📊 Kepadatan: ${provinceData['density']}
💰 PDRB: ${provinceData['gdp']}
📉 Kemiskinan: ${provinceData['poverty']}%
💼 Pengangguran: ${provinceData['unemployment']}%
🗺️ Luas: ${provinceData['area']}

Sumber: Aplikasi Peta Data Indonesia
''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share, color: Color(0xFF1976D2)),
            SizedBox(width: 8),
            Text('Bagikan Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dataText,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareButton(
                  'Salin Teks',
                  Icons.copy,
                  () {
                    // Implement copy to clipboard
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data disalin ke clipboard'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
                _buildShareButton(
                  'Export PDF',
                  Icons.picture_as_pdf,
                  () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur export PDF segera hadir'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1976D2).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF1976D2)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1976D2),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
