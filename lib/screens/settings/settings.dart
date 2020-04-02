import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sorting/screens/settings/about.dart';
import '../../config.dart';
import '../screen.dart';
import '../../api/http_api.dart';
import '../../widgets/message.dart';

class SettingsScreen extends Screen {
  SettingsScreen() : super(title: '设置', homeAction: false, addPadding: EdgeInsets.only(top: -8));
  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}

enum ServerConfigureState {
  untested, testing, unavailable, available, setup
}

class SettingsScreenState extends ScreenState<SettingsScreen> {
  final Map<String, TextEditingController> fieldControllers = {};
  ServerConfigureState serverConfigureState = ServerConfigureState.untested;
  List schemes = [];  // 可选择的"模式"的列表
  int schemeId;       // 记录已选择的"模式"

  @override
  void initState() {
    super.initState();

    ['branch.name', 'branch.code', 'server.hostname', 'server.port'].forEach((field) {
      fieldControllers[field] = TextEditingController();
    });

    (() async {
      var config = await ConfigurationManager.configuration();
      fieldControllers.forEach((key, ctrl) {
        ctrl.text = config.getString(key);
      });
      bool prepared = await prepareHTTPAPI();
      if (prepared) {
        fetchSchemes();
        setState(() {
          schemeId = config.getInt('schemeId');
        });
      }
    })();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (serverConfigureState == ServerConfigureState.available) {
      Messager.warning('并未使用新服务器配置');
    }
  }

  @override
  Widget render(BuildContext context) {
    return ListView(
      children: [
        Row(children: <Widget>[
          Expanded(child:
            TextField(
              controller: fieldControllers['server.hostname'],
              keyboardType: TextInputType.number,
              maxLength: 15,
              inputFormatters: [WhitelistingTextInputFormatter(RegExp(r'\d{1,3}|\.'))],
              readOnly: serverConfigureState == ServerConfigureState.testing,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: '服务器地址',
                labelStyle: TextStyle(),
                counterText: '',
              ),
              onChanged: onServerChanged,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(':', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          Expanded(child:
            TextField(
              controller: fieldControllers['server.port'],
              keyboardType: TextInputType.number,
              maxLength: 4,
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              readOnly: serverConfigureState == ServerConfigureState.testing,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: '服务器端口',
                counterText: '',
              ),
              onChanged: onServerChanged,
            ),
          ),
        ]),
        Container(
          margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: RaisedButton(
            color: [
              Colors.orange,
              Colors.orangeAccent,
              Colors.redAccent,
              Colors.lightGreen,
              Colors.green
            ][serverConfigureState.index],
            textColor: Colors.white,
            onPressed: onServerConfigurePressed,
            child: Text([
              '连接测试',
              '连接测试中，请稍等',
              '连接测试失败，请重试',
              '连接测试成功，点击使用新配置',
              '已设置成功'
            ][serverConfigureState.index]),
          ),
        ),
        TextField(
          controller: fieldControllers['branch.name'],
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: '网点名称',
          ),
          onChanged: onServerChanged,
        ),
        TextField(
          controller: fieldControllers['branch.code'],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '网点编码',
          ),
          onChanged: onServerChanged,
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: RaisedButton(
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            onPressed: onSaveBranchPressed,
            child: Text('设置网点'),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            children: [
              Text('模式', style: TextStyle(color: Color(0x99000000), fontSize: 13)),
              Container(
                margin: EdgeInsets.fromLTRB(8, 0, 0, 0),
                width: 136,
                child: schemes.length == 0
                    ? SizedBox()
                    : DropdownButtonHideUnderline(child:
                        DropdownButton(
                          items: schemes.map((item) => DropdownMenuItem(
                              value: item['id'],
                              child: Text(item['company']),
                          )).toList(),
                          hint: Text('请选择'),
                          onChanged: onSchemeChanged,
                          value: schemeId,
                          style: TextStyle(
                            color: Color(0xff4a4a4a),
                            fontSize: 14,
                          ),
                          isDense: false,
                        ),
                      ),
              ),
            ],
          ),
        ),
        RaisedButton(
          onPressed: () {
            Messager.warning('请长按按钮以确认');
          },
          onLongPress: onResetPressed,
          child: Text('重置设置'),
        ),
        RaisedButton(
          onPressed: () {
            push(AboutScreen());
          },
          child: Text('关于'),
        ),
        RaisedButton(
          onPressed: () {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          },
          child: Text('退出程序'),
        ),
      ],
    );
  }

  Future fetchSchemes() async {
    await prepareHTTPAPI();
    var ret = await api.get('/scheme/all');
    setState(() {
      schemes = ret.data;
    });
  }

  void onSaveBranchPressed() async {
    var config = await ConfigurationManager.configuration();
    int validateOkCnt = 0;
    fieldControllers.forEach((field, ctrl) {
      if (field.startsWith('branch.') && ctrl.text.isNotEmpty) {
        config.setString(field, ctrl.text);
        validateOkCnt++;
      }
    });
    if (validateOkCnt == 2) {
      Messager.ok('保存成功');
    } else {
      Messager.error('保存失败');
    }
  }

  void onServerChanged(_) {
    setState(() {
      serverConfigureState = ServerConfigureState.untested;
      schemeId = null;
    });
  }

  void onServerConfigurePressed() async {
    FocusScope.of(context).requestFocus(FocusNode());

    switch (serverConfigureState) {
      case ServerConfigureState.testing:
        setState(() {
          serverConfigureState = ServerConfigureState.untested;
        });
        break;
      case ServerConfigureState.untested:
      case ServerConfigureState.unavailable: {
        var hostname = fieldControllers['server.hostname'].text;
        var port = fieldControllers['server.port'].text;
        if (hostname.isEmpty || port.isEmpty) {
          Messager.warning('请先输入服务器信息');
          return;
        }
        setState(() {
          serverConfigureState = ServerConfigureState.testing;
        });
        // 新建一个Dio不影响全局的http api，因为这里用户还没有确定保存新设置
        Dio(BaseOptions(
          baseUrl: 'http://$hostname:$port',
          responseType: ResponseType.json,
          connectTimeout: 3000,
          sendTimeout: 3000,
          receiveTimeout: 3000,
        )).get('/user/ping').then((ret) {
          if (ret.data == 'pong') {
            Messager.ok('连接测试成功');
            setState(() {
              serverConfigureState = ServerConfigureState.available;
            });
          }
        }).catchError((Object o) {
          final e = o as DioError;
          Messager.error('连接失败，可能的原因：'
              '\n  服务器配置不正确'
              '\n  服务器未正常运行'
              '\n  未连接到服务器所在网络'
              '\n\n  错误消息：${e.message}');
          setState(() {
            serverConfigureState = ServerConfigureState.unavailable;
          });
        }, test: (error) => true);
        break;
      }
      case ServerConfigureState.available: {
        var config = await ConfigurationManager.configuration();
        fieldControllers.forEach((field, ctrl) {
          if (field.startsWith('server.')) {
            config.setString(field, ctrl.text);
          }
        });
        prepareHTTPAPI(reload: true);
        Messager.ok('服务器设置成功');
        setState(() {
          serverConfigureState = ServerConfigureState.setup;
        });
        fetchSchemes();
        break;
      }
      case ServerConfigureState.setup:
        Messager.ok('已设置');
        break;
    }
  }

  void onSchemeChanged(value) async {
    var config = await ConfigurationManager.configuration();
    config.setInt('schemeId', schemeId);
    Messager.ok("模式设置成功");
    setState(() {
      schemeId = value;
    });
  }

  void onResetPressed() {
    fieldControllers.forEach((key, ctrl) => ctrl.text = '');
    ConfigurationManager.clear();
    ConfigurationManager.configuration().then((config) {
      config.remove('schemeId');
    });
    prepareHTTPAPI(reload: true);
    Messager.ok('重置设置成功');
    setState(() {
      serverConfigureState = ServerConfigureState.untested;
      schemeId = null;
    });
  }
}
