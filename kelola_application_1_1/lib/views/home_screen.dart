import 'package:flutter/material.dart';
import 'package:kelola_application_1_1/views/budget_screen.dart';
import 'package:kelola_application_1_1/views/dashboard_screen.dart';
import 'package:kelola_application_1_1/views/data_screen.dart';
import 'package:kelola_application_1_1/views/setting_screen.dart';
import 'package:get_storage/get_storage.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    Dashboard(),
    DataScreen(),
    Budget(),
    SettingsUser(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Transaksi',
    'Budget',
    'Settings',
  ];

  double _logoHeight = 100.0;
  double _appBarHeight = 60.0;

  @override
  Widget build(BuildContext context) {
    String username = GetStorage().read('username') ??
        ''; // Membaca username dari penyimpanan lokal
    print(
        'Username: $username'); // Pencetakan nama pengguna untuk memeriksa apakah disimpan dengan benar

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_appBarHeight),
        child: AppBar(
          backgroundColor: Colors.white,
          leading: Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: SizedBox(
              height: _logoHeight,
              width: _logoHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset('images/logo.png'),
              ),
            ),
          ),
          title: Align(
            alignment: Alignment.centerRight,
            child: Text(
              _titles[_currentIndex],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        selectedItemColor: Color.fromRGBO(140, 226, 218, 0.8),
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
