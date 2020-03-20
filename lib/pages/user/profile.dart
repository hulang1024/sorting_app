import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../models/user.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
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
            padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              children: [
                Row(children: [
                  Container(width: 90, child: Text('姓名')),
                  Text(user['name']),
                ]),
                Row(children: [
                  Container(width: 90, child: Text('手机号')),
                  Text(user['phone']),
                ]),
                Row(children: [
                  Container(width: 90, child: Text('编号')),
                  Text(user['code']),
                ]),
              ],
            ),
          )
        ],
      ),
    );
  }
}
