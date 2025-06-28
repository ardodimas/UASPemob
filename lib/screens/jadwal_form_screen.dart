import 'package:flutter/material.dart';
import 'dart:io';
import '../models/jadwal.dart';
import '../services/content_provider_service.dart';
import '../services/image_service.dart';

class JadwalFormScreen extends StatefulWidget {
  final bool editMode;
  final Jadwal? jadwal;

  const JadwalFormScreen({this.editMode = false, this.jadwal, Key? key})
    : super(key: key);

  @override
  _JadwalFormScreenState createState() => _JadwalFormScreenState();
}

class _JadwalFormScreenState extends State<JadwalFormScreen> {
  final TextEditingController jamMulaiController = TextEditingController();
  final TextEditingController jamSelesaiController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  // ContentProvider service
  final ContentProviderService _contentProviderService =
      ContentProviderService();

  String? selectedMapel;
  String? selectedHari;
  String? errorMessage;
  bool _isSaving = false;
  List<String> _mapelNamaList = [];
  bool _isLoadingMapel = true;
  String? _imagePath;
  final List<String> _hariList = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  Future<void> _loadMapel() async {
    try {
      // Menggunakan ContentProvider untuk load mapel
      final mapelList = await _contentProviderService.getAllMapel();
      setState(() {
        _mapelNamaList = mapelList.map((m) => m.nama).toList();
        _isLoadingMapel = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat mata pelajaran: $e';
        _isLoadingMapel = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.editMode && widget.jadwal != null) {
      selectedMapel = widget.jadwal!.mapel;
      selectedHari = widget.jadwal!.hari;
      jamMulaiController.text = widget.jadwal!.jamMulai;
      jamSelesaiController.text = widget.jadwal!.jamSelesai;
      catatanController.text = widget.jadwal!.catatan;
      _imagePath = widget.jadwal!.imagePath;
    }
    _loadMapel();
  }

  // Fungsi untuk menampilkan time picker
  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  // Fungsi untuk menampilkan dialog pilihan gambar
  Future<void> _showImagePickerDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Ambil Foto'),
                subtitle: Text('Menggunakan kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  await _takePhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pilih dari Galeri'),
                subtitle: Text('Pilih gambar yang sudah ada'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mengambil foto
  Future<void> _takePhoto() async {
    try {
      final File? imageFile = await ImageService.takePhoto();
      if (imageFile != null) {
        setState(() {
          _imagePath = imageFile.path;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Fitur kamera belum tersedia. Silakan pilih dari galeri.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error mengambil foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    try {
      final File? imageFile = await ImageService.pickImage();
      if (imageFile != null) {
        setState(() {
          _imagePath = imageFile.path;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fitur galeri belum tersedia.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error memilih gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk menghapus gambar
  void _removeImage() {
    setState(() {
      _imagePath = null;
    });
  }

  // Fungsi untuk menyimpan jadwal menggunakan ContentProvider
  Future<void> _saveJadwal() async {
    if (selectedMapel == null || selectedHari == null) {
      setState(() {
        errorMessage = 'Pilih mata pelajaran dan hari!';
      });
      return;
    }

    if (jamMulaiController.text.isEmpty || jamSelesaiController.text.isEmpty) {
      setState(() {
        errorMessage = 'Jam mulai dan selesai wajib diisi!';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      errorMessage = null;
    });

    try {
      final jadwal = Jadwal(
        id: widget.editMode ? widget.jadwal!.id : null,
        hari: selectedHari!,
        mapel: selectedMapel!,
        jamMulai: jamMulaiController.text,
        jamSelesai: jamSelesaiController.text,
        catatan: catatanController.text,
        imagePath: _imagePath,
      );

      if (widget.editMode) {
        // Update jadwal menggunakan ContentProvider
        await _contentProviderService.updateJadwal(jadwal);
      } else {
        // Insert jadwal menggunakan ContentProvider
        await _contentProviderService.insertJadwal(jadwal);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.editMode
                ? 'Jadwal berhasil diupdate!'
                : 'Jadwal berhasil ditambahkan!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal menyimpan jadwal: $e';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(widget.editMode ? 'Edit Jadwal' : 'Tambah Jadwal'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'Form Jadwal Pelajaran',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  if (errorMessage != null) ...[
                    Text(errorMessage!, style: TextStyle(color: Colors.red)),
                    SizedBox(height: 12),
                  ],
                  DropdownButtonFormField<String>(
                    value: selectedHari,
                    items:
                        _hariList
                            .map(
                              (hari) => DropdownMenuItem(
                                value: hari,
                                child: Text(hari),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedHari = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Pilih Hari',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _isLoadingMapel
                      ? Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<String>(
                        value: selectedMapel,
                        items:
                            _mapelNamaList
                                .map(
                                  (nama) => DropdownMenuItem(
                                    value: nama,
                                    child: Text(nama),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            _mapelNamaList.isEmpty
                                ? null
                                : (value) {
                                  setState(() {
                                    selectedMapel = value;
                                  });
                                },
                        decoration: InputDecoration(
                          labelText: 'Pilih Mata Pelajaran',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: jamMulaiController,
                          readOnly: true, // Membuat field hanya bisa dibaca
                          onTap: () => _selectTime(context, jamMulaiController),
                          decoration: InputDecoration(
                            labelText: 'Jam Mulai',
                            prefixIcon: Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: jamSelesaiController,
                          readOnly: true, // Membuat field hanya bisa dibaca
                          onTap:
                              () => _selectTime(context, jamSelesaiController),
                          decoration: InputDecoration(
                            labelText: 'Jam Selesai',
                            prefixIcon: Icon(Icons.access_time_filled),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: catatanController,
                    decoration: InputDecoration(
                      labelText: 'Catatan (opsional)',
                      prefixIcon: Icon(Icons.note_alt),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16),
                  // Bagian untuk gambar materi
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.photo_camera, color: Colors.blue[700]),
                              SizedBox(width: 8),
                              Text(
                                'Foto Materi (opsional)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          if (_imagePath != null) ...[
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_imagePath!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _showImagePickerDialog,
                                    icon: Icon(Icons.edit),
                                    label: Text('Ganti Foto'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _removeImage,
                                    icon: Icon(Icons.delete),
                                    label: Text('Hapus'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Container(
                              width: double.infinity,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  style: BorderStyle.solid,
                                ),
                                color: Colors.grey[50],
                              ),
                              child: InkWell(
                                onTap: _showImagePickerDialog,
                                borderRadius: BorderRadius.circular(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tap untuk menambah foto materi',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isSaving
                              ? null
                              : () async {
                                setState(() {
                                  errorMessage = null;
                                  _isSaving = true;
                                });
                                if (selectedMapel == null ||
                                    selectedMapel!.isEmpty ||
                                    selectedHari == null ||
                                    selectedHari!.isEmpty) {
                                  setState(() {
                                    errorMessage =
                                        'Hari dan Mata pelajaran wajib dipilih!';
                                    _isSaving = false;
                                  });
                                  return;
                                }
                                if (jamMulaiController.text.isEmpty ||
                                    jamSelesaiController.text.isEmpty) {
                                  setState(() {
                                    errorMessage =
                                        'Jam mulai dan jam selesai wajib diisi!';
                                    _isSaving = false;
                                  });
                                  return;
                                }
                                await _saveJadwal();
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isSaving
                              ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text('Simpan', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
