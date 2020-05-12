import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sorting/input/bindings/inputkey.dart';
import 'package:sorting/input/bindings/key_binding.dart';
import 'package:sorting/input/bindings/key_combination.dart';
import 'package:sorting/screens/settings/settings.dart';
import 'package:sorting/session.dart';
import '../user/password_modify.dart';
import '../screen.dart';
import '../../login.dart';
import '../../api/http_api.dart';

class ProfileScreen extends Screen {
  ProfileScreen({Key key}) : super(key: key, title: '我的', homeAction: false, isNavigationScreen: true);
  @override
  State<StatefulWidget> createState() => ProfileScreenState();
}

class ProfileScreenState extends ScreenState<ProfileScreen> {
  Map<String, GlobalKey> _buttonKeys = {};
  List<KeyBinding> _keyBindings = [];
  var _user = {};

  @override
  void initState() {
    super.initState();

    (() async {
      if (!api.isAvailable) {
        return;
      }
      var ret = await api.get('/user/session');
      setState(() {
        _user = ret['user'];
      });
    })();

    _keyBindings = [
      KeyBinding(KeyCombination(InputKey.Num1), 'settings'),
      KeyBinding(KeyCombination(InputKey.Num2), 'modify-password'),
      KeyBinding(KeyCombination(InputKey.Num3), 'logout'),
    ];
    _keyBindings.forEach((binding) {
      _buttonKeys[binding.action] = GlobalKey();
    });
  }

  @override
  Widget render(BuildContext context) {
    return ListView(
      children: [
        Row(children: [
          Container(width: 80, child: Text('姓名')),
          Text(_user['name'] ?? ''),
        ]),
        Row(children: [
          Container(width: 80, child: Text('手机号')),
          Text(_user['phone'] ?? ''),
        ]),
        Row(children: [
          Container(width: 80, child: Text('编号')),
          Text(_user['code'] ?? ''),
        ]),
        Row(children: [
          Container(width: 80, child: Text('注册时间')),
          Text(_user['createAt'] ?? ''),
        ]),
        Padding(padding: EdgeInsets.only(top: 90)),
        RaisedButton(
          key: _buttonKeys['settings'],
          color: Color(0xffbbbbbb),
          textColor: Colors.white,
          onPressed: () {
            push(SettingsScreen());
          },
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('1. '),
                Icon(Icons.settings, size: 16,),
                Text('设置'),
              ]),
        ),
        RaisedButton(
          key: _buttonKeys['modify-password'],
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          onPressed: () {
            push(PasswordModifyScreen());
          },
          child: Text('2. 修改密码'),
        ),
        RaisedButton(
          key: _buttonKeys['logout'],
          color: Colors.redAccent,
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => Login()));
            setCurrentUser(null);
            api.post('/user/logout');
          },
          child: Text('3. 退出用户'),
        ),
      ],
    );
  }

  @override
  void onKeyDown(KeyCombination keyCombination) {
    for (var binding in _keyBindings) {
      if (binding.keyCombination.isPressed(keyCombination)) {
        (_buttonKeys[binding.action].currentContext?.widget as RaisedButton).onPressed();
        return;
      }
    }
    super.onKeyUp(keyCombination);
  }
}
