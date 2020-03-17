import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/http_api.dart';

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
                    value: 'config',
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
                  case 'config':
                    Navigator.pushNamed(context, '/config');
                    break;
                  case 'logout':
                    Navigator.pushReplacementNamed(context, '/login');
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
          Navigator.pushNamed(context, '/package_create');
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
                    },
                    child: Text('查询包裹')
                  )
              ),
              Container(
                  child: FlatButton(
                    color: Colors.white,
                    shape: new RoundedRectangleBorder(),
                    onPressed: () {
                    },
                    child: Text('查询快件')
                  )
              ),
              Container(
                  child: FlatButton(
                    color: Colors.white,
                    shape: new RoundedRectangleBorder(),
                    onPressed: () {
                      Navigator.pushNamed(context, '/package_create');
                    },
                    child: Text('手动建包')
                  )
              ),
              Container(
                  child: FlatButton(
                    color: Colors.white,
                    shape: new RoundedRectangleBorder(),
                    onPressed: () {
                    },
                    child: Text('智能建包')
                  )
              ),
              Container(
                  child: FlatButton(
                    color: Colors.white,
                    shape: new RoundedRectangleBorder(),
                    onPressed: () {
                    },
                    child: Text('加减快件')
                  )
              ),
              Container(
                  child: FlatButton(
                    color: Colors.white,
                    shape: new RoundedRectangleBorder(),
                    onPressed: () {
                    },
                    child: Text('删除包裹')
                  )
              ),
            ]
        ),
      )
    );
  }
}
