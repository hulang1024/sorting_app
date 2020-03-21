import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/http_api.dart';
import '../../widgets/message.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  GlobalKey<FormState> formKey = GlobalKey();
  Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();

    ['server.hostname', 'server.port'].forEach((key) {
      controllers[key] = TextEditingController();
    });

    SharedPreferences.getInstance().then((prefs) {
      controllers.forEach((key, val) {
        controllers[key].text = prefs.getString(key);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: ListView(
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
                  ),
                  TextFormField(
                    controller: controllers['server.port'],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '服务器端口',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 24, 0, 0),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: RaisedButton(
                  onPressed: onTestPressed,
                  child: Text('测试连接'),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 24, 0, 0),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: submit,
                  child: Text('保存'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void onTestPressed() {
    var hostname = controllers['server.hostname'].text;
    var port = controllers['server.port'].text;
    Dio(BaseOptions(
      baseUrl: 'http://$hostname:$port',
      responseType: ResponseType.json,
      connectTimeout: 1000,
      sendTimeout: 1000,
      receiveTimeout: 1000,
    )).get('/user/ping').then((ret) {
      if (ret.data == 'pong') {
        Messager.ok('连接成功');
      }
    }).catchError((Object obj) {
      DioError e = obj as DioError;
      Messager.error('连接失败，可能的原因：'
          '\n  服务器配置不正确'
          '\n  服务器未正常运行'
          '\n  未连接到服务器所在网络'
          '\n\n  错误消息：${e.message}');
    }, test: (error) => true);
  }

  void submit() async {
    if (!formKey.currentState.validate()) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('existsSetting', true);
    controllers.forEach((key, ctrl) async {
      prefs.setString(key, ctrl.text);
    });
    Messager.ok('保存成功');
  }
}
