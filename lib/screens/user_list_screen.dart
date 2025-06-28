import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/db_service.dart';
import '../utils/shared_prefs.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<User>> _userListFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _userListFuture = DBService.getAllUsers();
    });
  }

  void _handleDelete(BuildContext context, User userToDelete) async {
    // Dapatkan username yang sedang login
    final loggedInUsername = await SharedPrefsHelper.getUsername();

    // Hapus user dari DB
    if (userToDelete.id != null) {
      await DBService.deleteUser(userToDelete.id!);
    }

    Navigator.of(context).pop(); // Tutup dialog

    // Cek apakah user yang dihapus adalah user yang sedang login
    if (loggedInUsername == userToDelete.username) {
      await SharedPrefsHelper.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      // Jika tidak, cukup refresh daftar user
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar User')),
      body: FutureBuilder<List<User>>(
        future: _userListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Belum ada user terdaftar.'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(user.username),
                subtitle: Text('ID: ${user.id}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: Text('Hapus User'),
                          content: Text(
                            'Yakin ingin menghapus user "${user.username}"?',
                          ),
                          actions: [
                            TextButton(
                              child: Text('Batal'),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                            TextButton(
                              child: Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed:
                                  () => _handleDelete(dialogContext, user),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
