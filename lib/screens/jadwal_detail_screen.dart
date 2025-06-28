import 'package:flutter/material.dart';
import 'dart:io';
import '../models/jadwal.dart';
import '../services/db_service.dart';
import 'jadwal_form_screen.dart';

class JadwalDetailScreen extends StatelessWidget {
  final Jadwal jadwal;
  const JadwalDetailScreen({Key? key, required this.jadwal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Jadwal'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () async {
              // Navigasi ke form edit (nanti diimplementasi)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          JadwalFormScreen(editMode: true, jadwal: jadwal),
                ),
              ).then((_) => Navigator.pop(context));
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Hapus',
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Hapus Jadwal'),
                      content: Text('Yakin ingin menghapus jadwal ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (jadwal.id != null) {
                              await DBService.deleteJadwal(jadwal.id!);
                              Navigator.pop(context); // Tutup dialog
                              Navigator.pop(context); // Kembali ke Home
                            }
                          },
                          child: Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mata Pelajaran:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(jadwal.mapel, style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
                Text('Jam:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${jadwal.jamMulai} - ${jadwal.jamSelesai}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text('Catatan:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(jadwal.catatan.isEmpty ? '-' : jadwal.catatan),
                // Tampilkan foto materi jika ada
                if (jadwal.imagePath != null) ...[
                  SizedBox(height: 16),
                  Text(
                    'Foto Materi:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(jadwal.imagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
