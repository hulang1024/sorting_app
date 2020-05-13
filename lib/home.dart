import 'package:flutter/material.dart';
import 'package:sorting/service/data_sync.dart';
import 'screens/screen.dart';
import 'screens/menu/main_menu.dart';
import 'screens/user/profile.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {
  List<Screen> _screens = [
    MainMenu(key: GlobalKey()),
    ProfileScreen(key: GlobalKey()),
  ];
  int _screenIndex = 0;

  @override
  void initState() {
    super.initState();
    DataSyncService().onAppInitState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_screenIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _screenIndex,
        elevation: 4,
        //backgroundColor: Colors.white,
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
          if (index == _screenIndex) return;
          setState(() {
            _screenIndex = index;
          });
          // 解决根页面的RawKeyboardListener的焦点冲突
          for (int i = 0; i < _screens.length; i++) {
            if (i != index) {
              ((_screens[i].key as GlobalKey).currentState as ScreenState).keyFocusNode.unfocus();
            }
          }
        },
      ),
    );
  }
}
