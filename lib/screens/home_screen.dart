import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/jadwal.dart';
import '../providers/mapel_provider.dart';
import '../services/content_provider_service.dart';
import '../services/content_provider.dart';
import 'jadwal_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _hariList = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  // ContentProvider service
  final ContentProviderService _contentProviderService =
      ContentProviderService();
  List<Jadwal> _jadwalList = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _dataChangesSubscription;

  @override
  void initState() {
    super.initState();
    // Load data menggunakan ContentProvider
    _loadJadwalWithContentProvider();
    // Listen to data changes
    _listenToDataChanges();
  }

  @override
  void dispose() {
    _dataChangesSubscription?.cancel();
    super.dispose();
  }

  /// Mendengarkan perubahan data dari ContentProvider
  void _listenToDataChanges() {
    _dataChangesSubscription = _contentProviderService.dataChanges.listen((
      change,
    ) {
      if (change['uri'] == ContentProvider.JADWAL_URI) {
        _loadJadwalWithContentProvider();
      }
    });
  }

  /// Load jadwal menggunakan ContentProvider
  Future<void> _loadJadwalWithContentProvider() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final jadwal = await _contentProviderService.getAllJadwal();
      if (!mounted) return;
      setState(() {
        _jadwalList = jadwal;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat jadwal: $e';
        _isLoading = false;
      });
    }
  }

  /// Get jadwal berdasarkan hari menggunakan ContentProvider
  List<Jadwal> _getJadwalByHari(String hari) {
    return _jadwalList.where((jadwal) => jadwal.hari == hari).toList();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return DefaultTabController(
        length: _hariList.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Jadwal Pelajaran',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blue[700],
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/jadwal_form');
                  if (mounted) {
                    _loadJadwalWithContentProvider();
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.book, color: Colors.white),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/mapel');
                  if (mounted) {
                    context.read<MapelProvider>().loadMapel();
                  }
                },
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.blue[100],
              ),
              labelColor: Colors.blue[900],
              unselectedLabelColor: Colors.blue[400],
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              tabs: _hariList.map((String hari) => Tab(text: hari)).toList(),
            ),
          ),
          body:
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: $_error',
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadJadwalWithContentProvider,
                          child: Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                  : TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children:
                        _hariList.map((String hari) {
                          try {
                            final jadwalForDay = _getJadwalByHari(hari);
                            return JadwalListView(
                              hari: hari,
                              jadwalList: jadwalForDay,
                              onDataMutated: _loadJadwalWithContentProvider,
                            );
                          } catch (e) {
                            return Center(
                              child: Text(
                                'Error di tab $hari: $e',
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          }
                        }).toList(),
                  ),
        ),
      );
    } catch (e) {
      return Scaffold(
        body: Center(
          child: Text(
            'Terjadi error di UI: $e',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }
}

class JadwalListView extends StatelessWidget {
  final String hari;
  final List<Jadwal> jadwalList;
  final VoidCallback onDataMutated;

  const JadwalListView({
    required this.hari,
    required this.jadwalList,
    required this.onDataMutated,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (jadwalList.isEmpty) {
      return Center(
        child: Text(
          'Belum ada jadwal untuk hari $hari.',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: jadwalList.length,
      itemBuilder: (context, index) {
        final jadwal = jadwalList[index];
        return Container(
          margin: EdgeInsets.only(bottom: 14),
          child: Card(
            elevation: 5,
            shadowColor: Colors.blue[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 18,
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.book, color: Colors.blue[700]),
              ),
              title: Text(
                jadwal.mapel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              subtitle: Text(
                '${jadwal.jamMulai} - ${jadwal.jamSelesai}',
                style: TextStyle(color: Colors.blueGrey[700]),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.blue[300],
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JadwalDetailScreen(jadwal: jadwal),
                  ),
                );
                // Setelah kembali, panggil callback untuk refresh data
                onDataMutated();
              },
            ),
          ),
        );
      },
    );
  }
}
