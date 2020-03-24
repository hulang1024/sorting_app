import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../user/password_modify.dart';
import '../screen.dart';
import '../../login.dart';
import '../../api/http_api.dart';

class ProfileScreen extends Screen {
  ProfileScreen() : super(title: '我的', homeAction: false);
  @override
  State<StatefulWidget> createState() => ProfileScreenState();
}

class ProfileScreenState extends ScreenState<ProfileScreen> {
  var user = {};

  @override
  void initState() {
    super.initState();

    api.get('/user/session').then((ret) {
      setState(() {
        user = ret.data['user'];
      });
    });
  }

  @override
  Widget render(BuildContext context) {
    return ListView(
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
        Row(children: [
          Container(width: 80, child: Text('注册时间')),
          Text(user['createAt'] ?? ''),
        ]),
        Container(
          margin: EdgeInsets.only(top: 120),
          child: SizedBox(
            width: double.infinity,
            child: RaisedButton(
              color: Colors.orange,
              textColor: Colors.white,
              onPressed: () {
                push(PasswordModifyScreen());
              },
              child: Text('修改密码'),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 8),
          child: SizedBox(
            width: double.infinity,
            child: RaisedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => Login()));
                api.post('/user/logout');
              },
              child: Text('退出当前用户'),
            ),
          ),
        ),
      ],
    );
  }
}
