import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sorting/dao/database.dart';
import 'package:sorting/screens/settings/general.dart';
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

  @override
  Widget render(BuildContext context) {
    return ListView(
      children: [
        RaisedButton(
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          onPressed: () {
            push(GeneralSettingsScreen());
          },
          child: Text('通用设置'),
        ),
        if (getCurrentUser() != null)
          RaisedButton(
            color: Colors.orange,
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
            child: Text('上传离线数据'),
          ),
        if (getCurrentUser() != null)
          RaisedButton(
            color: Colors.orange,
            textColor: Colors.white,
            onPressed: () async {
              Messager.info('下载中');
              int total = await DataSyncService().downloadBasicData();
              if (total >= 0) {
                Messager.ok('下载基础数据完成');
              }
            },
            child: Text('下载基础数据'),
          ),
        if (getCurrentUser() != null)
          RaisedButton(
            color: Colors.redAccent,
            textColor: Colors.white,
            onPressed: () {
              Messager.warning('请长按按钮以确认');
            },
            onLongPress: () async {
              SortingDatabase.delete();
              Messager.ok('已删除离线数据');
            },
            child: Text('删除离线数据'),
          ),
        if (getCurrentUser() != null)
          RaisedButton(
            color: Colors.redAccent,
            textColor: Colors.white,
            onPressed: () {
              Messager.warning('请长按按钮以确认');
            },
            onLongPress: () async {
              SortingDatabase.deleteBasicData();
              Messager.ok('已删除基础数据');
            },
            child: Text('删除基础数据'),
          ),
        RaisedButton(
          onPressed: () {
            push(AboutScreen());
          },
          child: Text('关于'),
        ),
        RaisedButton(
          color: Colors.lightGreen,
          textColor: Colors.white,
          onPressed: () {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          },
          child: Text('退出程序'),
        ),
      ],
    );
  }
}
