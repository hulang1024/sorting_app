import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final GlobalKey<FormState> formKey = GlobalKey();
  final Map<String, TextEditingController> serverFieldControllers = {
    'hostname': TextEditingController(),
    'port': TextEditingController(),
  };
  ServerConfigureState serverConfigureState = ServerConfigureState.untested;
  List schemes = [];  // 可选择的"模式"的列表
  int schemeId;       // 记录已选择的"模式"

  @override
  void initState() {
    super.initState();

    ConfigurationManager.configuration().then((config) {
      serverFieldControllers.forEach((key, ctrl) {
        ctrl.text = config.getString('server.$key');
      });
      prepareHTTPAPI().then((prepared) {
        if (prepared) {
          fetchSchemes();
          setState(() {
            schemeId = config.getInt('schemeId');
          });
        }
      });
    });
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
        Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: serverFieldControllers['hostname'],
                keyboardType: TextInputType.url,
                readOnly: serverConfigureState == ServerConfigureState.testing,
                decoration: InputDecoration(
                  labelText: '服务器地址',
                ),
                onChanged: onServerChanged,
              ),
              TextFormField(
                controller: serverFieldControllers['port'],
                keyboardType: TextInputType.number,
                readOnly: serverConfigureState == ServerConfigureState.testing,
                decoration: InputDecoration(
                  labelText: '服务器端口',
                ),
                onChanged: onServerChanged,
              ),
            ],
          ),
        ),
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
                    : DropdownButtonHideUnderline(
                        child: DropdownButton(
                          items: schemes.map((item) => DropdownMenuItem(
                              value: item['id'],
                              child: Text(item['company']),
                          )).toList(),
                          hint: Text('请选择'),
                          onChanged: (value) {
                            ConfigurationManager.configuration().then((config) {
                              config.setInt('schemeId', schemeId);
                              Messager.ok("模式设置成功");
                            });
                            setState(() {
                              schemeId = value;
                            });
                          },
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
        Container(
          margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: RaisedButton(
            color: Colors.redAccent,
            textColor: Colors.white,
            onPressed: onResetPressed,
            child: Text('重置设置'),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: RaisedButton(
            onPressed: () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
            child: Text('退出程序'),
          ),
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
        var hostname = serverFieldControllers['hostname'].text;
        var port = serverFieldControllers['port'].text;
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
        serverFieldControllers.forEach((field, ctrl) async {
          config.setString('server.$field', ctrl.text);
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

  void onResetPressed() {
    ConfigurationManager.clear();
    serverFieldControllers.forEach((key, ctrl) => ctrl.text = '');
    ConfigurationManager.configuration().then((config) {
      config.remove('schemeId');
    });
    prepareHTTPAPI(reload: true);
    setState(() {
      serverConfigureState = ServerConfigureState.untested;
      schemeId = null;
    });
  }

}
