import 'package:flutter/foundation.dart';
import '../models/jadwal.dart';
import '../services/db_service.dart';

class JadwalProvider with ChangeNotifier {
  List<Jadwal> _jadwalList = [];
  bool _isLoading = false;
  String? _error;

  List<Jadwal> get jadwalList => _jadwalList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load semua jadwal
  Future<void> loadJadwal() async {
    _setLoading(true);
    try {
      final jadwal = await DBService.getAllJadwal();
      _jadwalList = jadwal;
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat jadwal: $e';
    }
    _setLoading(false);
  }

  // Tambah jadwal baru
  Future<void> addJadwal(Jadwal jadwal) async {
    _setLoading(true);
    try {
      await DBService.insertJadwal(jadwal);
      await loadJadwal(); // Reload data
      _error = null;
    } catch (e) {
      _error = 'Gagal menambah jadwal: $e';
    }
    _setLoading(false);
  }

  // Update jadwal
  Future<void> updateJadwal(int id, Jadwal jadwal) async {
    _setLoading(true);
    try {
      await DBService.updateJadwal(id, jadwal);
      await loadJadwal(); // Reload data
      _error = null;
    } catch (e) {
      _error = 'Gagal mengupdate jadwal: $e';
    }
    _setLoading(false);
  }

  // Hapus jadwal
  Future<void> deleteJadwal(int id) async {
    _setLoading(true);
    try {
      await DBService.deleteJadwal(id);
      await loadJadwal(); // Reload data
      _error = null;
    } catch (e) {
      _error = 'Gagal menghapus jadwal: $e';
    }
    _setLoading(false);
  }

  // Get jadwal berdasarkan hari
  List<Jadwal> getJadwalByHari(String hari) {
    return _jadwalList.where((jadwal) => jadwal.hari == hari).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
