import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sorting/dao/database.dart';
import 'package:sorting/input/bindings/inputkey.dart';
import 'package:sorting/input/bindings/key_binding.dart';
import 'package:sorting/input/bindings/key_combination.dart';
import 'package:sorting/screens/settings/general.dart';
import 'package:sorting/screens/settings/key_binding.dart';
import 'package:sorting/service/data_sync.dart';
import 'package:sorting/session.dart';
import '../../screens/settings/about.dart';
import '../screen.dart';
import '../../widgets/message.dart';

class SettingsScreen extends Screen {
  SettingsScreen({homeAction: true}) : super(title: '设置', homeAction: homeAction, addPadding: EdgeInsets.only(top: -8));
  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}

class SettingsScreenState extends ScreenState<SettingsScreen> {
  Map<String, GlobalKey> buttonKeys = {};
  List<KeyBinding> keyBindings = [];

  @override
  void initState() {
    super.initState();

    final Queue inputKeys = Queue.of([
      InputKey.Num1, InputKey.Num2, InputKey.Num3,
      InputKey.Num4, InputKey.Num5, InputKey.Num6,
      InputKey.Num7, InputKey.Num8
    ]);
    keyBindings = [
      'general-settings',
      if (getCurrentUser() != null) 'upload-offline-data',
      if (getCurrentUser() != null) 'pull-basic-data',
      if (getCurrentUser() != null) 'delete-offline-data',
      if (getCurrentUser() != null) 'delete-basic-data',
      if (getCurrentUser() != null) 'key-configuration',
      'about',
      'exit',
    ].map((action) => KeyBinding(inputKeys.removeFirst(), action)).toList();
    keyBindings.forEach((binding) {
      buttonKeys[binding.action] = GlobalKey();
    });
  }

  @override
  Widget render(BuildContext context) {
    int buttonOrder = 0;
    return ListView(
      children: [
        RaisedButton(
          key: buttonKeys['general-settings'],
          color: Color(0xffbbbbbb),
          textColor: Colors.white,
          onPressed: () {
            push(GeneralSettingsScreen());
          },
          child: Text('${++buttonOrder}. 通用设置'),
        ),
        if (getCurrentUser() != null)
          RaisedButton(
            key: buttonKeys['upload-offline-data'],
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            onPressed: () async {
              Messager.info('上传中');
              int total = await DataSyncService().uploadOfflineData();
              if (total > 0) {
                Messager.ok('上传离线数据完成');
              } else {
                Messager.warning('无数据');
              }
            },
            child: Text('${++buttonOrder}. 上传离线数据'),
          ),
        if (getCurrentUser() != null)
          RaisedButton(
            key: buttonKeys['pull-basic-data'],
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            onPressed: () async {
              Messager.info('下载中');
              int total = await DataSyncService().pullBasicData();
              if (total >= 0) {
                Messager.ok('更新基础数据完成');
              }
            },
            child: Text('${++buttonOrder}. 更新基础数据'),
          ),
        if (getCurrentUser() != null)
          RaisedButton(
            key: buttonKeys['delete-offline-data'],
            color: Colors.redAccent,
            textColor: Colors.white,
            onPressed: () {
              Messager.warning('请长按按钮以确认');
            },
            onLongPress: () async {
              SortingDatabase.deleteOfflineData();
              Messager.ok('已删除离线数据');
            },
            child: Text('${++buttonOrder}. 删除离线数据'),
          ),
        if (getCurrentUser() != null)
          RaisedButton(
            key: buttonKeys['delete-basic-data'],
            color: Colors.redAccent,
            textColor: Colors.white,
            onPressed: () {
              Messager.warning('请长按按钮以确认');
            },
            onLongPress: () async {
              SortingDatabase.deleteBasicData();
              Messager.ok('已删除基础数据');
            },
            child: Text('${++buttonOrder}. 删除基础数据'),
          ),
        RaisedButton(
          key: buttonKeys['key-configuration'],
          color: Color(0xffbbbbbb),
          textColor: Colors.white,
          onPressed: () {
            push(KeyBindingScreen());
          },
          child: Text('${++buttonOrder}. 按键配置'),
        ),
        RaisedButton(
          key: buttonKeys['about'],
          color: Color(0xffbbbbbb),
          textColor: Colors.white,
          onPressed: () {
            push(AboutScreen());
          },
          child: Text('${++buttonOrder}. 关于'),
        ),
        RaisedButton(
          key: buttonKeys['exit'],
          color: Colors.redAccent,
          textColor: Colors.white,
          onPressed: () {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          },
          child: Text('${++buttonOrder}. 退出程序'),
        ),
      ],
    );
  }

  @override
  void onKeyDown(KeyCombination keyCombination) {
    for (var binding in keyBindings) {
      if (binding.keyCombination.isPressed(keyCombination)) {
        RaisedButton button = buttonKeys[binding.action].currentContext?.widget as RaisedButton;
        if (button == null) return;
        if (button.onLongPress != null) {
          button.onLongPress();
        } else if (button.onPressed != null) {
          button.onPressed();
        }
        return;
      }
    }
    super.onKeyUp(keyCombination);
  }
}
