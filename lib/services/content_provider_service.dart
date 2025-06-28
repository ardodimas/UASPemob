import 'dart:async';
import '../models/jadwal.dart';
import '../models/user.dart';
import '../models/mapel.dart';
import 'content_provider.dart';

/// Service yang menggunakan ContentProvider untuk akses data
/// Ini adalah contoh implementasi yang mirip dengan Android ContentProvider
class ContentProviderService {
  static final ContentProviderService _instance =
      ContentProviderService._internal();
  factory ContentProviderService() => _instance;
  ContentProviderService._internal();

  /// Stream untuk mendengarkan perubahan data
  Stream<Map<String, dynamic>> get dataChanges =>
      ContentResolver.listenToChanges();

  /// ========== JADWAL OPERATIONS ==========

  /// Mendapatkan semua jadwal
  Future<List<Jadwal>> getAllJadwal() async {
    try {
      final result = await ContentResolver.query(ContentProvider.JADWAL_URI);
      return result.map((map) => Jadwal.fromMap(map)).toList();
    } catch (e) {
      throw ContentProviderException('Failed to get jadwal: $e');
    }
  }

  /// Mendapatkan jadwal berdasarkan hari
  Future<List<Jadwal>> getJadwalByHari(String hari) async {
    try {
      final result = await ContentResolver.query(
        ContentProvider.JADWAL_URI,
        selection: 'hari = ?',
        selectionArgs: [hari],
        orderBy: 'jamMulai ASC',
      );
      return result.map((map) => Jadwal.fromMap(map)).toList();
    } catch (e) {
      throw ContentProviderException('Failed to get jadwal by hari: $e');
    }
  }

  /// Menambah jadwal baru
  Future<int> insertJadwal(Jadwal jadwal) async {
    try {
      final res = await ContentResolver.insert(
        ContentProvider.JADWAL_URI,
        jadwal.toMap(),
      );
      return res;
    } catch (e) {
      throw ContentProviderException('Failed to insert jadwal: $e');
    }
  }

  /// Update jadwal
  Future<int> updateJadwal(Jadwal jadwal) async {
    try {
      return await ContentResolver.update(
        ContentProvider.JADWAL_URI,
        jadwal.toMap(),
        selection: 'id = ?',
        selectionArgs: [jadwal.id.toString()],
      );
    } catch (e) {
      throw ContentProviderException('Failed to update jadwal: $e');
    }
  }

  /// Hapus jadwal
  Future<int> deleteJadwal(int id) async {
    try {
      return await ContentResolver.delete(
        ContentProvider.JADWAL_URI,
        selection: 'id = ?',
        selectionArgs: [id],
      );
    } catch (e) {
      throw ContentProviderException('Failed to delete jadwal: $e');
    }
  }

  /// ========== USER OPERATIONS ==========

  /// Mendapatkan semua user
  Future<List<User>> getAllUsers() async {
    try {
      final result = await ContentResolver.query(ContentProvider.USER_URI);
      return result.map((map) => User.fromMap(map)).toList();
    } catch (e) {
      throw ContentProviderException('Failed to get users: $e');
    }
  }

  /// Login user
  Future<User?> loginUser(String username, String password) async {
    try {
      final result = await ContentResolver.query(
        ContentProvider.USER_URI,
        selection: 'username = ? AND password = ?',
        selectionArgs: [username, password],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return User.fromMap(result.first);
      }
      return null;
    } catch (e) {
      throw ContentProviderException('Failed to login user: $e');
    }
  }

  /// Register user baru
  Future<int> registerUser(User user) async {
    try {
      return await ContentResolver.insert(
        ContentProvider.USER_URI,
        user.toMap(),
      );
    } catch (e) {
      throw ContentProviderException('Failed to register user: $e');
    }
  }

  /// Hapus user
  Future<int> deleteUser(int id) async {
    try {
      return await ContentResolver.delete(
        ContentProvider.USER_URI,
        selection: 'id = ?',
        selectionArgs: [id],
      );
    } catch (e) {
      throw ContentProviderException('Failed to delete user: $e');
    }
  }

  /// ========== MAPEL OPERATIONS ==========

  /// Mendapatkan semua mapel
  Future<List<Mapel>> getAllMapel() async {
    try {
      final result = await ContentResolver.query(ContentProvider.MAPEL_URI);
      return result.map((map) => Mapel.fromMap(map)).toList();
    } catch (e) {
      throw ContentProviderException('Failed to get mapel: $e');
    }
  }

  /// Menambah mapel baru
  Future<int> insertMapel(Mapel mapel) async {
    try {
      return await ContentResolver.insert(
        ContentProvider.MAPEL_URI,
        mapel.toMap(),
      );
    } catch (e) {
      throw ContentProviderException('Failed to insert mapel: $e');
    }
  }

  /// Update mapel
  Future<int> updateMapel(Mapel mapel) async {
    try {
      return await ContentResolver.update(
        ContentProvider.MAPEL_URI,
        mapel.toMap(),
        selection: 'id = ?',
        selectionArgs: [mapel.id.toString()],
      );
    } catch (e) {
      throw ContentProviderException('Failed to update mapel: $e');
    }
  }

  /// Hapus mapel
  Future<int> deleteMapel(int id) async {
    try {
      return await ContentResolver.delete(
        ContentProvider.MAPEL_URI,
        selection: 'id = ?',
        selectionArgs: [id],
      );
    } catch (e) {
      throw ContentProviderException('Failed to delete mapel: $e');
    }
  }

  /// ========== UTILITY METHODS ==========

  /// Mendapatkan jadwal untuk hari tertentu dengan urutan waktu
  Future<List<Jadwal>> getJadwalHariIni(String hari) async {
    try {
      final result = await ContentResolver.query(
        ContentProvider.JADWAL_URI,
        selection: 'hari = ?',
        selectionArgs: [hari],
        orderBy: 'jamMulai ASC',
      );
      return result.map((map) => Jadwal.fromMap(map)).toList();
    } catch (e) {
      throw ContentProviderException('Failed to get jadwal hari ini: $e');
    }
  }

  /// Mencari jadwal berdasarkan mata pelajaran
  Future<List<Jadwal>> searchJadwalByMapel(String mapel) async {
    try {
      final result = await ContentResolver.query(
        ContentProvider.JADWAL_URI,
        selection: 'mapel LIKE ?',
        selectionArgs: ['%$mapel%'],
        orderBy: 'hari ASC, jamMulai ASC',
      );
      return result.map((map) => Jadwal.fromMap(map)).toList();
    } catch (e) {
      throw ContentProviderException('Failed to search jadwal by mapel: $e');
    }
  }

  /// Mendapatkan statistik jadwal
  Future<Map<String, dynamic>> getJadwalStats() async {
    try {
      final allJadwal = await getAllJadwal();

      // Hitung statistik
      final totalJadwal = allJadwal.length;
      final hariCount = <String, int>{};
      final mapelCount = <String, int>{};

      for (final jadwal in allJadwal) {
        hariCount[jadwal.hari] = (hariCount[jadwal.hari] ?? 0) + 1;
        mapelCount[jadwal.mapel] = (mapelCount[jadwal.mapel] ?? 0) + 1;
      }

      return {
        'totalJadwal': totalJadwal,
        'hariCount': hariCount,
        'mapelCount': mapelCount,
        'hariTerbanyak':
            hariCount.entries.reduce((a, b) => a.value > b.value ? a : b).key,
        'mapelTerbanyak':
            mapelCount.entries.reduce((a, b) => a.value > b.value ? a : b).key,
      };
    } catch (e) {
      throw ContentProviderException('Failed to get jadwal stats: $e');
    }
  }
}

/// Exception class untuk ContentProviderService
class ContentProviderException implements Exception {
  final String message;
  ContentProviderException(this.message);

  @override
  String toString() => 'ContentProviderServiceException: $message';
}
