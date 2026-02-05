import 'package:flutter/material.dart';
import 'data_detail_screen.dart';

class DataListScreen extends StatefulWidget {
  const DataListScreen({super.key});

  @override
  _DataListScreenState createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> kependudukanData = [];
  List<Map<String, dynamic>> ekonomiData = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load dummy data since API might not be available
      kependudukanData = [
        {
          'id': 'jumlah-penduduk',
          'title': 'Jumlah Penduduk',
          'subtitle': 'Hubungan Asal - Usul',
          'icon': Icons.people,
          'category': 'kependudukan'
        },
        {
          'id': 'penduduk-miskin',
          'title': 'Penduduk Miskin',
          'subtitle': 'Tingkat Ketimpangan',
          'icon': Icons.trending_down,
          'category': 'kependudukan'
        },
        {
          'id': 'kepadatan-penduduk',
          'title': 'Kepadatan Penduduk',
          'subtitle': 'Kecamatan',
          'icon': Icons.location_city,
          'category': 'kependudukan'
        },
        {
          'id': 'perkawinan-usia-dini',
          'title': 'Perkawinan Usia Dini',
          'subtitle': 'Kecamatan',
          'icon': Icons.family_restroom,
          'category': 'kependudukan'
        },
      ];

      ekonomiData = [
        {
          'id': 'pdrb',
          'title': 'PDRB',
          'subtitle': 'Produk Domestik Regional Bruto',
          'icon': Icons.monetization_on,
          'category': 'ekonomi'
        },
        {
          'id': 'inflasi',
          'title': 'Inflasi',
          'subtitle': 'Tingkat Inflasi Bulanan',
          'icon': Icons.trending_up,
          'category': 'ekonomi'
        },
        {
          'id': 'ekspor-impor',
          'title': 'Ekspor - Impor',
          'subtitle': 'Perdagangan Luar Negeri',
          'icon': Icons.import_export,
          'category': 'ekonomi'
        },
        {
          'id': 'investasi',
          'title': 'Investasi',
          'subtitle': 'Realisasi Investasi',
          'icon': Icons.account_balance,
          'category': 'ekonomi'
        },
      ];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _searchData(String query) async {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults.clear();
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      // Simulate search in local data
      List<Map<String, dynamic>> allData = [
        ...kependudukanData,
        ...ekonomiData
      ];
      searchResults = allData
          .where((item) =>
              item['title'].toLowerCase().contains(query.toLowerCase()) ||
              item['subtitle'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencari data: $e')),
      );
    }

    setState(() {
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        title: const Text('Daftar Data'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Kependudukan'),
            Tab(text: 'Ekonomi'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchController.text.isNotEmpty
                    ? _buildSearchResults()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDataList(kependudukanData),
                          _buildDataList(ekonomiData),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _searchData(value),
        decoration: InputDecoration(
          hintText: 'Cari data',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchData('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color(0xFF1976D2)),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Data tidak ditemukan',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba gunakan kata kunci lain',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return _buildDataList(searchResults);
  }

  Widget _buildDataList(List<Map<String, dynamic>> dataList) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dataList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        final item = dataList[index];
        return _buildDataCard(item);
      },
    );
  }

  Widget _buildDataCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            item['icon'],
            color: const Color(0xFF1976D2),
            size: 24,
          ),
        ),
        title: Text(
          item['title'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Text(
          item['subtitle'],
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DataDetailScreen(
                dataId: item['id'],
                title: item['title'],
              ),
            ),
          );
        },
      ),
    );
  }
}
