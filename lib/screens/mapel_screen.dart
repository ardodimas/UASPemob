import 'package:flutter/material.dart';
import '../models/mapel.dart';
import '../services/db_service.dart';

class MapelScreen extends StatefulWidget {
  @override
  _MapelScreenState createState() => _MapelScreenState();
}

class _MapelScreenState extends State<MapelScreen> {
  final TextEditingController mapelController = TextEditingController();
  List<Mapel> _mapelList = [];
  bool _isLoading = true;

  Future<void> _loadMapel() async {
    final data = await DBService.getAllMapel();
    setState(() {
      _mapelList = data;
      _isLoading = false;
    });
  }

  void _showMapelDialog({int? editIndex}) {
    if (editIndex != null) {
      mapelController.text = _mapelList[editIndex].nama;
    } else {
      mapelController.clear();
    }
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(editIndex == null ? 'Tambah Mapel' : 'Edit Mapel'),
            content: TextField(
              controller: mapelController,
              decoration: InputDecoration(labelText: 'Nama Mata Pelajaran'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  String nama = mapelController.text.trim();
                  if (nama.isNotEmpty) {
                    if (editIndex == null) {
                      await DBService.insertMapel(Mapel(nama: nama));
                    } else {
                      // update mapel
                      await DBService.updateMapel(
                        editIndex + 1,
                        Mapel(nama: nama),
                      );
                    }
                    Navigator.pop(context);
                    _loadMapel();
                  }
                },
                child: Text(editIndex == null ? 'Tambah' : 'Simpan'),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMapel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Mata Pelajaran'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Tambah Mapel',
            onPressed: () => _showMapelDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _mapelList.isEmpty
                ? Center(child: Text('Belum ada mata pelajaran.'))
                : ListView.builder(
                  itemCount: _mapelList.length,
                  itemBuilder: (context, index) {
                    final mapel = _mapelList[index];
                    return Card(
                      child: ListTile(
                        title: Text(mapel.nama),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed:
                                  () => _showMapelDialog(editIndex: index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: Text('Hapus Mapel'),
                                        content: Text(
                                          'Yakin ingin menghapus mapel ini?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await DBService.deleteMapel(
                                                index + 1,
                                              );
                                              Navigator.pop(context);
                                              _loadMapel();
                                            },
                                            child: Text(
                                              'Hapus',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
