import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
// Import screens (nanti akan dibuat)

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/jadwal_form_screen.dart';
import 'screens/mapel_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/user_list_screen.dart';
import 'providers/jadwal_provider.dart';
import 'providers/mapel_provider.dart';
import 'providers/user_provider.dart';

void main() {
  if (kIsWeb) {
    // Inisialisasi database factory untuk web
    databaseFactory = databaseFactoryFfiWeb;
  }
  runApp(JadwalPelajaranApp());
}

class JadwalPelajaranApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JadwalProvider()),
        ChangeNotifierProvider(create: (_) => MapelProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Aplikasi Jadwal Pelajaran',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LoginScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => MainNavigation(),
          '/jadwal_form': (context) => JadwalFormScreen(),
          '/mapel': (context) => MapelScreen(),
          '/profile': (context) => ProfileScreen(),
          '/user_list': (context) => UserListScreen(),
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[HomeScreen(), ProfileScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
