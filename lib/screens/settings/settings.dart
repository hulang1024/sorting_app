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

/// 设置首屏。
class SettingsScreen extends Screen {
  SettingsScreen({homeAction: true}) : super(title: '设置', homeAction: homeAction, addPadding: EdgeInsets.all(-8));
  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}

class SettingsScreenState extends ScreenState<SettingsScreen> {
  Map<String, GlobalKey> settingsItemKeys = {};
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
      if (getCurrentUser() != null) 'key-configuration',
      if (getCurrentUser() != null) 'upload-offline-data',
      if (getCurrentUser() != null) 'pull-basic-data',
      if (getCurrentUser() != null) 'delete-offline-data',
      if (getCurrentUser() != null) 'delete-basic-data',
      'about',
      'exit',
    ].map((action) => KeyBinding(inputKeys.removeFirst(), action)).toList();
    keyBindings.forEach((binding) {
      settingsItemKeys[binding.action] = GlobalKey();
    });
  }

  @override
  Widget render(BuildContext context) {
    int buttonOrder = 0;
    return ListView(
      children: [
        SettingsItem(
          key: settingsItemKeys['general-settings'],
          icon: Icons.settings_applications,
          title: '${++buttonOrder}. 通用设置',
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            push(GeneralSettingsScreen());
          },
        ),
        SettingsItem(
          key: settingsItemKeys['key-configuration'],
          icon: Icons.keyboard,
          title: '${++buttonOrder}. 按键配置',
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            push(KeyBindingScreen());
          },
        ),
        if (getCurrentUser() != null)
          SettingsItem(
            key: settingsItemKeys['upload-offline-data'],
            icon: Icons.cloud_upload,
            title: '${++buttonOrder}. 上传离线数据',
            onTap: () async {
              Messager.info('上传中');
              int total = await DataSyncService().uploadOfflineData();
              if (total > 0) {
                Messager.ok('上传离线数据完成');
              } else {
                Messager.warning('无数据');
              }
            },
          ),
        if (getCurrentUser() != null)
          SettingsItem(
            key: settingsItemKeys['pull-basic-data'],
            icon: Icons.cloud_download,
            title: '${++buttonOrder}. 更新基础数据',
            onTap: () async {
              Messager.info('下载中');
              int total = await DataSyncService().pullBasicData();
              if (total >= 0) {
                Messager.ok('更新基础数据完成');
              }
            },
          ),
        if (getCurrentUser() != null)
          SettingsItem(
            key: settingsItemKeys['delete-offline-data'],
            icon: Icons.delete,
            title: '${++buttonOrder}. 删除离线数据',
            onTap: () {
              Messager.warning('请长按按钮以确认');
            },
            onLongPress: () async {
              SortingDatabase.deleteOfflineData();
              Messager.ok('已删除离线数据');
            },
          ),
        if (getCurrentUser() != null)
          SettingsItem(
            key: settingsItemKeys['delete-basic-data'],
            icon: Icons.delete,
            title: '${++buttonOrder}. 删除基础数据',
            onTap: () {
              Messager.warning('请长按按钮以确认');
            },
            onLongPress: () async {
              SortingDatabase.deleteBasicData();
              Messager.ok('已删除基础数据');
            },
          ),
        SettingsItem(
          key: settingsItemKeys['about'],
          icon: Icons.info_outline,
          title: '${++buttonOrder}. 关于',
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            push(AboutScreen());
          },
        ),
        SettingsItem(
          key: settingsItemKeys['exit'],
          icon: Icons.exit_to_app,
          title: '${++buttonOrder}. 退出程序',
          onTap: () {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          },
        ),
      ],
    );
  }

  @override
  void onKeyDown(KeyCombination keyCombination) {
    for (var binding in keyBindings) {
      if (binding.keyCombination.isPressed(keyCombination)) {
        SettingsItem item = settingsItemKeys[binding.action].currentContext?.widget as SettingsItem;
        if (item == null) return;
        if (item.onLongPress != null) {
          item.onLongPress();
        } else if (item.onTap != null) {
          item.onTap();
        }
        return;
      }
    }
    super.onKeyDown(keyCombination);
  }
}

class SettingsItem extends StatelessWidget {
  SettingsItem({
    Key key,
    @required this.icon,
    @required this.title,
    this.trailing,
    @required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final Widget trailing;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(icon, size: 23,),
            title: Text(title, style: TextStyle(fontSize: 14.5),),
            trailing: trailing,
            dense: true,
            onTap: onTap,
            onLongPress: onLongPress,
          ),
          Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16,),
        ],
      ),
    );
  }

}