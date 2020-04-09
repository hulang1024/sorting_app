import 'package:flutter/material.dart';
import 'package:sorting/repositories/database.dart';
import 'screens/screen.dart';
import 'screens/menu/main_menu.dart';
import 'screens/settings/settings.dart';
import 'screens/user/profile.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {
  final List<Screen> screens = [
    SettingsScreen(),
    MainMenu(),
    ProfileScreen(),
  ];
  int _screenIndex = 1;

  @override
  void initState() {
    super.initState();
    SortingDatabase.sync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_screenIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _screenIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('设置'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('首页'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
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
