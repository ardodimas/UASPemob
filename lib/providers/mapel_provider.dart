import 'package:flutter/foundation.dart';
import '../models/mapel.dart';
import '../services/db_service.dart';

class MapelProvider with ChangeNotifier {
  List<Mapel> _mapelList = [];
  bool _isLoading = false;
  String? _error;

  List<Mapel> get mapelList => _mapelList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load semua mapel
  Future<void> loadMapel() async {
    _setLoading(true);
    try {
      final mapel = await DBService.getAllMapel();
      _mapelList = mapel;
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat mata pelajaran: $e';
    }
    _setLoading(false);
  }

  // Tambah mapel baru
  Future<void> addMapel(Mapel mapel) async {
    _setLoading(true);
    try {
      await DBService.insertMapel(mapel);
      await loadMapel(); // Reload data
      _error = null;
    } catch (e) {
      _error = 'Gagal menambah mata pelajaran: $e';
    }
    _setLoading(false);
  }

  // Update mapel
  Future<void> updateMapel(int id, Mapel mapel) async {
    _setLoading(true);
    try {
      await DBService.updateMapel(id, mapel);
      await loadMapel(); // Reload data
      _error = null;
    } catch (e) {
      _error = 'Gagal mengupdate mata pelajaran: $e';
    }
    _setLoading(false);
  }

  // Hapus mapel
  Future<void> deleteMapel(int id) async {
    _setLoading(true);
    try {
      await DBService.deleteMapel(id);
      await loadMapel(); // Reload data
      _error = null;
    } catch (e) {
      _error = 'Gagal menghapus mata pelajaran: $e';
    }
    _setLoading(false);
  }

  // Get nama mapel untuk dropdown
  List<String> getMapelNamaList() {
    return _mapelList.map((mapel) => mapel.nama).toList();
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
