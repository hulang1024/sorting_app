import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sorting/screens/settings/settings.dart';
import 'package:sorting/session.dart';
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

    (() async {
      if (!api.isAvailable) {
        return;
      }
      user = await api.get('/user/session');
      setState(() {});
    })();

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
        Padding(padding: EdgeInsets.only(top: 90)),
        RaisedButton(
          color: Colors.orange,
          textColor: Colors.white,
          onPressed: () {
            push(PasswordModifyScreen());
          },
          child: Text('修改密码'),
        ),
        RaisedButton(
          color: Colors.redAccent,
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => Login()));
            setCurrentUser(null);
            api.post('/user/logout');
          },
          child: Text('退出用户'),
        ),
        RaisedButton(
          onPressed: () {
            push(SettingsScreen());
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings, size: 16,),
              Text('设置')
            ]),
        ),
      ],
    );
  }
}
