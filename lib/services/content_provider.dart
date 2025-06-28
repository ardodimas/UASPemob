import 'dart:async';
import '../models/jadwal.dart';
import '../models/user.dart';
import '../models/mapel.dart';
import 'db_service.dart';

/// ContentProvider untuk Flutter - mirip dengan Android ContentProvider
/// Menyediakan interface terpusat untuk akses data
class ContentProvider {
  static final ContentProvider _instance = ContentProvider._internal();
  factory ContentProvider() => _instance;
  ContentProvider._internal();

  final StreamController<Map<String, dynamic>> _dataController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream untuk mendengarkan perubahan data
  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;

  /// URI constants untuk berbagai jenis data
  static const String JADWAL_URI = 'content://jadwal_pelajaran/jadwal';
  static const String USER_URI = 'content://jadwal_pelajaran/user';
  static const String MAPEL_URI = 'content://jadwal_pelajaran/mapel';

  /// Query data berdasarkan URI
  Future<List<Map<String, dynamic>>> query(
    String uri, {
    String? selection,
    List<Object>? selectionArgs,
    String? orderBy,
    int? limit,
  }) async {
    try {
      List<Map<String, dynamic>> result = [];

      if (uri.startsWith(JADWAL_URI)) {
        result = await _queryJadwal(selection, selectionArgs, orderBy, limit);
      } else if (uri.startsWith(USER_URI)) {
        result = await _queryUser(selection, selectionArgs, orderBy, limit);
      } else if (uri.startsWith(MAPEL_URI)) {
        result = await _queryMapel(selection, selectionArgs, orderBy, limit);
      }

      // Notify listeners tentang perubahan data
      // _dataController.add({'uri': uri, 'operation': 'query', 'data': result});

      return result;
    } catch (e) {
      throw ContentProviderException('Query failed: $e');
    }
  }

  /// Insert data berdasarkan URI
  Future<int> insert(String uri, Map<String, dynamic> values) async {
    try {
      int result = 0;

      if (uri.startsWith(JADWAL_URI)) {
        result = await _insertJadwal(values);
      } else if (uri.startsWith(USER_URI)) {
        result = await _insertUser(values);
      } else if (uri.startsWith(MAPEL_URI)) {
        result = await _insertMapel(values);
      }

      // Notify listeners tentang perubahan data
      _dataController.add({'uri': uri, 'operation': 'insert', 'id': result});

      return result;
    } catch (e) {
      throw ContentProviderException('Insert failed: $e');
    }
  }

  /// Update data berdasarkan URI
  Future<int> update(
    String uri,
    Map<String, dynamic> values, {
    String? selection,
    List<Object>? selectionArgs,
  }) async {
    try {
      int result = 0;

      if (uri.startsWith(JADWAL_URI)) {
        result = await _updateJadwal(values, selection, selectionArgs);
      } else if (uri.startsWith(USER_URI)) {
        result = await _updateUser(values, selection, selectionArgs);
      } else if (uri.startsWith(MAPEL_URI)) {
        result = await _updateMapel(values, selection, selectionArgs);
      }

      // Notify listeners tentang perubahan data
      _dataController.add({
        'uri': uri,
        'operation': 'update',
        'affectedRows': result,
      });

      return result;
    } catch (e) {
      throw ContentProviderException('Update failed: $e');
    }
  }

  /// Delete data berdasarkan URI
  Future<int> delete(
    String uri, {
    String? selection,
    List<Object>? selectionArgs,
  }) async {
    try {
      int result = 0;

      if (uri.startsWith(JADWAL_URI)) {
        result = await _deleteJadwal(selection, selectionArgs);
      } else if (uri.startsWith(USER_URI)) {
        result = await _deleteUser(selection, selectionArgs);
      } else if (uri.startsWith(MAPEL_URI)) {
        result = await _deleteMapel(selection, selectionArgs);
      }

      // Notify listeners tentang perubahan data
      _dataController.add({
        'uri': uri,
        'operation': 'delete',
        'affectedRows': result,
      });

      return result;
    } catch (e) {
      throw ContentProviderException('Delete failed: $e');
    }
  }

  /// Helper methods untuk Jadwal
  Future<List<Map<String, dynamic>>> _queryJadwal(
    String? selection,
    List<Object>? selectionArgs,
    String? orderBy,
    int? limit,
  ) async {
    final jadwalList = await DBService.getAllJadwal();
    List<Map<String, dynamic>> result =
        jadwalList.map((j) => j.toMap()).toList();

    // Apply selection filter
    if (selection != null && selectionArgs != null) {
      result =
          result.where((jadwal) {
            // Simple selection implementation
            if (selection.contains('hari')) {
              final hariIndex = selection.indexOf('hari');
              return jadwal['hari'] == selectionArgs[hariIndex];
            }
            return true;
          }).toList();
    }

    // Apply ordering
    if (orderBy != null) {
      if (orderBy.contains('jamMulai')) {
        result.sort((a, b) => a['jamMulai'].compareTo(b['jamMulai']));
      }
    }

    // Apply limit
    if (limit != null && limit > 0) {
      result = result.take(limit).toList();
    }

    return result;
  }

  Future<int> _insertJadwal(Map<String, dynamic> values) async {
    final jadwal = Jadwal.fromMap(values);
    return await DBService.insertJadwal(jadwal);
  }

  Future<int> _updateJadwal(
    Map<String, dynamic> values,
    String? selection,
    List<Object>? selectionArgs,
  ) async {
    final jadwal = Jadwal.fromMap(values);
    if (jadwal.id != null) {
      return await DBService.updateJadwal(jadwal.id!, jadwal);
    }
    return 0;
  }

  Future<int> _deleteJadwal(
    String? selection,
    List<Object>? selectionArgs,
  ) async {
    if (selectionArgs != null && selectionArgs.isNotEmpty) {
      return await DBService.deleteJadwal(selectionArgs.first as int);
    }
    return 0;
  }

  /// Helper methods untuk User
  Future<List<Map<String, dynamic>>> _queryUser(
    String? selection,
    List<Object>? selectionArgs,
    String? orderBy,
    int? limit,
  ) async {
    final userList = await DBService.getAllUsers();
    List<Map<String, dynamic>> result = userList.map((u) => u.toMap()).toList();

    // Filter manual jika selection dan selectionArgs ada
    if (selection != null && selectionArgs != null) {
      if (selection.contains('username = ?') &&
          selection.contains('password = ?')) {
        final username = selectionArgs[0];
        final password = selectionArgs[1];
        result =
            result
                .where(
                  (user) =>
                      user['username'] == username &&
                      user['password'] == password,
                )
                .toList();
      }
    }

    // Apply limit
    if (limit != null && limit > 0) {
      result = result.take(limit).toList();
    }

    return result;
  }

  Future<int> _insertUser(Map<String, dynamic> values) async {
    final user = User.fromMap(values);
    return await DBService.createUser(user);
  }

  Future<int> _updateUser(
    Map<String, dynamic> values,
    String? selection,
    List<Object>? selectionArgs,
  ) async {
    // Note: DBService doesn't have updateUser method, so we'll create a new one
    final user = User.fromMap(values);
    return await DBService.createUser(user);
  }

  Future<int> _deleteUser(
    String? selection,
    List<Object>? selectionArgs,
  ) async {
    if (selectionArgs != null && selectionArgs.isNotEmpty) {
      return await DBService.deleteUser(selectionArgs.first as int);
    }
    return 0;
  }

  /// Helper methods untuk Mapel
  Future<List<Map<String, dynamic>>> _queryMapel(
    String? selection,
    List<Object>? selectionArgs,
    String? orderBy,
    int? limit,
  ) async {
    final mapelList = await DBService.getAllMapel();
    return mapelList.map((m) => m.toMap()).toList();
  }

  Future<int> _insertMapel(Map<String, dynamic> values) async {
    final mapel = Mapel.fromMap(values);
    return await DBService.insertMapel(mapel);
  }

  Future<int> _updateMapel(
    Map<String, dynamic> values,
    String? selection,
    List<Object>? selectionArgs,
  ) async {
    final mapel = Mapel.fromMap(values);
    if (mapel.id != null) {
      return await DBService.updateMapel(mapel.id!, mapel);
    }
    return 0;
  }

  Future<int> _deleteMapel(
    String? selection,
    List<Object>? selectionArgs,
  ) async {
    if (selectionArgs != null && selectionArgs.isNotEmpty) {
      return await DBService.deleteMapel(selectionArgs.first as int);
    }
    return 0;
  }

  /// Dispose resources
  void dispose() {
    _dataController.close();
  }
}

/// Exception class untuk ContentProvider
class ContentProviderException implements Exception {
  final String message;
  ContentProviderException(this.message);

  @override
  String toString() => 'ContentProviderException: $message';
}

/// ContentResolver - interface untuk mengakses ContentProvider
class ContentResolver {
  static final ContentProvider _contentProvider = ContentProvider();

  /// Query data
  static Future<List<Map<String, dynamic>>> query(
    String uri, {
    String? selection,
    List<Object>? selectionArgs,
    String? orderBy,
    int? limit,
  }) {
    return _contentProvider.query(
      uri,
      selection: selection,
      selectionArgs: selectionArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  /// Insert data
  static Future<int> insert(String uri, Map<String, dynamic> values) {
    return _contentProvider.insert(uri, values);
  }

  /// Update data
  static Future<int> update(
    String uri,
    Map<String, dynamic> values, {
    String? selection,
    List<Object>? selectionArgs,
  }) {
    return _contentProvider.update(
      uri,
      values,
      selection: selection,
      selectionArgs: selectionArgs,
    );
  }

  /// Delete data
  static Future<int> delete(
    String uri, {
    String? selection,
    List<Object>? selectionArgs,
  }) {
    return _contentProvider.delete(
      uri,
      selection: selection,
      selectionArgs: selectionArgs,
    );
  }

  /// Listen to data changes
  static Stream<Map<String, dynamic>> listenToChanges() {
    return _contentProvider.dataStream;
  }
}
