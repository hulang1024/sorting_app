import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/http_api.dart';
import 'item/search.dart';
import 'package/create.dart';
import 'package/delete.dart';
import 'package/item_alloc.dart';
import 'package/search.dart';
import 'package/smart_create.dart';
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
          new PopupMenuButton(
              icon: new Icon(Icons.more_horiz),
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                new PopupMenuItem(
                    value: 'profile',
                    child: new Text('我的')
                ),
                new PopupMenuItem(
                    value: 'setting',
                    child: new Text('配置')
                ),
                new PopupMenuItem(
                    value: 'logout',
                    child: new Text('注销')
                ),
                new PopupMenuItem(
                    value: 'exit',
                    child: new Text('退出')
                )
              ],
              onSelected: (String value){
                switch(value) {
                  case 'profile':
                    Navigator.push(context, new MaterialPageRoute(builder: (_) => ProfilePage()));
                    break;
                  case 'setting':
                    break;
                  case 'logout':
                    Navigator.pushReplacement(context, new MaterialPageRoute(builder: (_) => LoginPage()));
                    api.post('/user/logout');
                    break;
                  case 'exit':
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                    break;
                }
              }
          )
        ]
      ),
      floatingActionButtonLocation:FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, new MaterialPageRoute(
              builder: (context) => PackageCreatePage()
          ));
        },
        child: new Icon(Icons.add)
      ),
      body: Container(
        color: Color.fromRGBO(210, 210, 210, 0.4),
        margin: EdgeInsets.fromLTRB(0, 1, 0, 0),
        child: GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                mainAxisSpacing: 1.0,
                crossAxisSpacing: 1.0
            ),
            children: [
              Container(
                  child: FlatButton(
                    color: Colors.white,
                    shape: new RoundedRectangleBorder(),
                    onPressed: () {
                      Navigator.push(context, new MaterialPageRoute(
                        builder: (context) => PackageSearchPage()
                      ));
                    },
                    child: Text('查询包裹', style: TextStyle(fontSize: 16))
                  )
              ),
              Container(
                  child: FlatButton(
                    color: Colors.white,
                    shape: new RoundedRectangleBorder(),
                    onPressed: () {
                      Navigator.push(context, new MaterialPageRoute(
                          builder: (_) => ItemSearchPage()
                      ));
                    },
                    child: Text('查询快件', style: TextStyle(fontSize: 16))
                  )
              ),
              Container(
                  child: FlatButton(
                    color: Colors.white,
                    shape: new RoundedRectangleBorder(),
                    onPressed: () {
                      Navigator.push(context, new MaterialPageRoute(
                          builder: (context) => PackageCreatePage()
                      ));
                    },
                    child: Text('手动建包', style: TextStyle(fontSize: 16))
                  )
              ),
              Container(
                  child: FlatButton(
                    color: Colors.white,
                    shape: new RoundedRectangleBorder(),
                    onPressed: () {
                      Navigator.push(context, new MaterialPageRoute(
                          builder: (context) => PackageSmartCreatePage()
                      ));
                    },
                    child: Text('智能建包', style: TextStyle(fontSize: 16))
                  )
              ),
              Container(
                  child: FlatButton(
                    color: Colors.white,
                    shape: new RoundedRectangleBorder(),
                    onPressed: () {
                      Navigator.push(context, new MaterialPageRoute(
                          builder: (context) => ItemAllocPage()
                      ));
                    },
                    child: Text('加减快件', style: TextStyle(fontSize: 16))
                  )
              ),
              Container(
                  child: FlatButton(
                    color: Colors.white,
                    shape: new RoundedRectangleBorder(),
                    onPressed: () {
                      Navigator.push(context, new MaterialPageRoute(
                          builder: (context) => PackageDeletePage()
                      ));
                    },
                    child: Text('删除包裹', style: TextStyle(fontSize: 16))
                  )
              ),
            ]
        ),
      )
    );
  }
}
