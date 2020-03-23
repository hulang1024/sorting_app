import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_screenIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _screenIndex,
        items: [
          new BottomNavigationBarItem(
            icon: new Icon(Icons.settings),
            title: new Text('设置'),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('首页'),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.person),
            title: new Text('我的'),
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
