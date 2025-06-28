import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/db_service.dart';
import '../utils/shared_prefs.dart';

class UserProvider with ChangeNotifier {
  List<User> _userList = [];
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  List<User> get userList => _userList;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load semua user
  Future<void> loadUsers() async {
    _setLoading(true);
    try {
      final users = await DBService.getAllUsers();
      _userList = users;
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat daftar user: $e';
    }
    _setLoading(false);
  }

  // Login user
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    try {
      final user = await DBService.getUser(username, password);
      if (user != null) {
        _currentUser = user;
        await SharedPrefsHelper.saveLogin(username);
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = 'Username atau password salah!';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Gagal login: $e';
      _setLoading(false);
      return false;
    }
  }

  // Register user baru
  Future<bool> register(String username, String password) async {
    _setLoading(true);
    try {
      final user = User(username: username, password: password);
      await DBService.createUser(user);
      await loadUsers(); // Reload data
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Gagal mendaftar: $e';
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await SharedPrefsHelper.logout();
    _currentUser = null;
    notifyListeners();
  }

  // Hapus user
  Future<void> deleteUser(int id) async {
    _setLoading(true);
    try {
      await DBService.deleteUser(id);
      await loadUsers(); // Reload data
      _error = null;
    } catch (e) {
      _error = 'Gagal menghapus user: $e';
    }
    _setLoading(false);
  }

  // Check login status
  Future<void> checkLoginStatus() async {
    final username = await SharedPrefsHelper.getUsername();
    if (username != null) {
      // Cari user berdasarkan username
      final users = await DBService.getAllUsers();
      final user = users.firstWhere(
        (u) => u.username == username,
        orElse: () => User(username: username, password: ''),
      );
      _currentUser = user;
    }
    notifyListeners();
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
