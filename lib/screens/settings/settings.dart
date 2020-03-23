import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen.dart';
import '../../api/http_api.dart';
import '../../widgets/message.dart';

class SettingsScreen extends Screen {
  SettingsScreen() : super(title: '设置', homeAction: false, addPadding: EdgeInsets.only(top: -8));
  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}

class SettingsScreenState extends ScreenState<SettingsScreen> {
  GlobalKey<FormState> formKey = GlobalKey();
  Map<String, TextEditingController> controllers = {};
  var prefsFuture = SharedPreferences.getInstance();
  bool serverSaved;
  bool serverTested;
  bool serverAvailable;
  List schemes = [];
  int schemeId;

  @override
  void initState() {
    super.initState();

    ['server.hostname', 'server.port'].forEach((key) {
      controllers[key] = TextEditingController();
    });

    serverSaved = false;
    serverTested = false;
    serverAvailable = false;
    prefsFuture.then((prefs) {
      controllers.forEach((key, val) {
        controllers[key].text = prefs.getString(key);
      });
      if (controllers['server.hostname'].text.isNotEmpty && controllers['server.port'].text.isNotEmpty) {
        querySchemes();
      }
    });
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
                controller: controllers['server.hostname'],
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: '服务器地址',
                ),
                onChanged: onServerChanged,
              ),
              TextFormField(
                controller: controllers['server.port'],
                keyboardType: TextInputType.number,
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
            color: serverTested
                ? serverAvailable
                    ? serverSaved ? Colors.green : Theme.of(context).primaryColor
                    : Colors.redAccent
                : Colors.orange,
            textColor: Colors.white,
            onPressed: onTestOrSavePressed,
            child: Text(serverTested
                ? serverAvailable
                    ? serverSaved ? '已设置成功' : '设置'
                    : '测试连接失败，请重试'
                : '测试连接'),
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
                          items: schemes.map((item) => DropdownMenuItem(value: item['id'], child: Text(item['company']))).toList(),
                          hint: Text('请选择'),
                          onChanged: (value) {
                            setState(() {
                              schemeId = value;
                              prefsFuture.then((prefs) {
                                prefs.setInt('schemeId', schemeId);
                                Messager.ok("模式设置成功");
                              });
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
            child: new Text('退出程序'),
          ),
        ),
      ],
    );
  }

  void querySchemes() {
    prefsFuture.then((prefs) {
      api.get('/scheme/all').then((ret) {
        setState(() {
          schemes = ret.data;
          schemeId = prefs.getInt('schemeId');
        });
      });
    });
  }

  void onServerChanged(_) {
    setState(() {
      serverSaved = false;
      serverTested = false;
      serverAvailable = false;
      if (schemeId != null) {
        prefsFuture.then((prefs) => prefs.remove('schemeId'));
        schemeId = null;
      }
      if (schemes.length > 0) {
        schemes.clear();
      }
    });
  }

  void onTestOrSavePressed() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (serverAvailable) {
      prefsFuture.then((prefs) {
        if (prefs.get('existsSetting') == null) {
          prefs.setBool('existsSetting', true);
        }
        controllers.forEach((key, ctrl) async {
          prefs.setString(key, ctrl.text);
        });
        setState(() {
          serverSaved = true;
        });
        Messager.ok('服务器设置成功');
        api.options.baseUrl = 'http://${prefs.get('server.hostname')}:${prefs.get('server.port')}';
        querySchemes();
      });
      return;
    }

    var hostname = controllers['server.hostname'].text;
    var port = controllers['server.port'].text;
    if (hostname.isEmpty || port.isEmpty) {
      return;
    }
    Dio(BaseOptions(
      baseUrl: 'http://$hostname:$port',
      responseType: ResponseType.json,
      connectTimeout: 1000,
      sendTimeout: 1000,
      receiveTimeout: 1000,
    )).get('/user/ping').then((ret) {
      if (ret.data == 'pong') {
        Messager.ok('连接成功');
        setState(() {
          serverTested = true;
          serverAvailable = true;
        });
      }
    }).catchError((Object obj) {
      DioError e = obj as DioError;
      Messager.error('连接失败，可能的原因：'
          '\n  服务器配置不正确'
          '\n  服务器未正常运行'
          '\n  未连接到服务器所在网络'
          '\n\n  错误消息：${e.message}');
      setState(() {
        serverTested = true;
        serverAvailable = false;
      });
    }, test: (error) => true);
  }

  void onResetPressed() {
    prefsFuture.then((prefs) {
      prefs.clear();
    });
    controllers.forEach((key, ctrl) {
      ctrl.text = '';
    });
    api.options.baseUrl = '';
    setState(() {
      serverSaved = false;
      serverTested = false;
      serverAvailable = false;
      schemes.clear();
      schemeId = null;
    });
  }
}
