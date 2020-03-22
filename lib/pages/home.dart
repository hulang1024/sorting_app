import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/http_api.dart';
import 'settings/settings.dart';
import 'item/search.dart';
import 'package/create.dart';
import 'package/delete.dart';
import 'package_item/item_alloc.dart';
import 'package/search.dart';
import 'user/login.dart';
import 'user/profile.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('首页'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_horiz),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'profile', child: Text('我的')),
              PopupMenuItem(value: 'setting', child: Text('设置')),
              PopupMenuItem(value: 'logout', child: Text('注销')),
              PopupMenuItem(value: 'exit', child: Text('退出')),
            ],
            onSelected: (String value) {
              switch (value) {
                case 'profile':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
                  break;
                case 'setting':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
                  break;
                case 'logout':
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
                  api.post('/user/logout');
                  break;
                case 'exit':
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  break;
              }
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PackageCreatePage()));
        },
        child: Icon(Icons.add),
      ),
      body: Container(
        color: Color.fromRGBO(210, 210, 210, 0.4),
        margin: EdgeInsets.fromLTRB(0, 1, 0, 0),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 1.0,
          ),
          children: [
            Container(
              child: FlatButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PackageSearchPage()));
                },
                child: Text('查询包裹', style: TextStyle(fontSize: 16)),
              ),
            ),
            Container(
              child: FlatButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ItemSearchPage()));
                },
                child: Text('查询快件', style: TextStyle(fontSize: 16)),
              ),
            ),
            Container(
              child: FlatButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PackageCreatePage()));
                },
                child: Text('创建包裹', style: TextStyle(fontSize: 16)),
              ),
            ),
            Container(
              child: FlatButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PackageCreatePage(smartCreate: true)));
                },
                child: Text('智能建包', style: TextStyle(fontSize: 16)),
              ),
            ),
            Container(
              child: FlatButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PackageItemAllocPage()));
                },
                child: Text('加减快件', style: TextStyle(fontSize: 16)),
              ),
            ),
            Container(
              child: FlatButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PackageDeletePage()));
                },
                child: Text('删除包裹', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
