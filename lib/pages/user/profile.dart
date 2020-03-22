import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../api/http_api.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  var user = {};

  @override
  void initState() {
    super.initState();
    api.get('/user/session').then((ret) => {
      setState(() {
        user = ret.data['user'];
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Column(
              children: [
                Row(children: [
                  Container(width: 80, child: Text('姓名')),
                  Text(user['name'] ?? ''),
                ]),
                Row(children: [
                  Container(width: 80, child: Text('手机号')),
                  Text(user['phone'] ?? ''),
                ]),
                Row(children: [
                  Container(width: 80, child: Text('编号')),
                  Text(user['code'] ?? ''),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
