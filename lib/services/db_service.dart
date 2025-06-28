import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/jadwal.dart';
import '../models/mapel.dart';
import '../models/user.dart';

class DBService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'jadwal_app.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE users(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT UNIQUE,
              password TEXT
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE jadwal ADD COLUMN hari TEXT');
        }
        if (oldVersion < 4) {
          // Pastikan kolom hari ada di tabel jadwal
          try {
            await db.execute('ALTER TABLE jadwal ADD COLUMN hari TEXT');
          } catch (e) {
            // Kolom sudah ada, abaikan error
          }
        }
        if (oldVersion < 5) {
          // Tambah kolom imagePath untuk menyimpan path gambar
          try {
            await db.execute('ALTER TABLE jadwal ADD COLUMN imagePath TEXT');
          } catch (e) {
            // Kolom sudah ada, abaikan error
          }
        }
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE jadwal(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hari TEXT,
        mapel TEXT,
        jamMulai TEXT,
        jamSelesai TEXT,
        catatan TEXT,
        imagePath TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE mapel(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');
  }

  // CRUD Jadwal
  static Future<int> insertJadwal(Jadwal jadwal) async {
    final db = await database;
    return await db.insert('jadwal', jadwal.toMap());
  }

  static Future<List<Jadwal>> getAllJadwal() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('jadwal');
    return List.generate(maps.length, (i) => Jadwal.fromMap(maps[i]));
  }

  static Future<int> updateJadwal(int id, Jadwal jadwal) async {
    final db = await database;
    return await db.update(
      'jadwal',
      jadwal.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteJadwal(int id) async {
    final db = await database;
    return await db.delete('jadwal', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Mapel
  static Future<int> insertMapel(Mapel mapel) async {
    final db = await database;
    return await db.insert('mapel', mapel.toMap());
  }

  static Future<List<Mapel>> getAllMapel() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('mapel');
    return List.generate(maps.length, (i) => Mapel.fromMap(maps[i]));
  }

  static Future<int> updateMapel(int id, Mapel mapel) async {
    final db = await database;
    return await db.update(
      'mapel',
      mapel.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteMapel(int id) async {
    final db = await database;
    return await db.delete('mapel', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD User
  static Future<int> createUser(User user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<User?> getUser(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User(
        id: maps[0]['id'],
        username: maps[0]['username'],
        password: maps[0]['password'],
      );
    }
    return null;
  }

  // Fungsi untuk mendapatkan semua user
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(
      maps.length,
      (i) => User(
        id: maps[i]['id'],
        username: maps[i]['username'],
        password: maps[i]['password'],
      ),
    );
  }

  static Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
