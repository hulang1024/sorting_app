import 'package:flutter/material.dart';
import 'package:sorting/service/offline_data_sync.dart';
import 'screens/screen.dart';
import 'screens/menu/main_menu.dart';
import 'screens/user/profile.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {
  final List<Screen> screens = [
    MainMenu(),
    ProfileScreen(),
  ];
  int _screenIndex = 0;

  @override
  void initState() {
    super.initState();
    OfflineDataSyncService().sync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_screenIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _screenIndex,
        elevation: 4,
        backgroundColor: Colors.white,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('首页'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            title: Text('我的'),
          ),
        ],
        onTap: (index) {
          setState(() {
            _screenIndex = index;
          });
        },
      ),
    );
  }
}
