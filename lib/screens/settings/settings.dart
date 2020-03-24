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

class SettingsScreenState extends ScreenState<SettingsScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final Map<String, TextEditingController> serverFieldControllers = {
    'hostname': TextEditingController(),
    'port': TextEditingController(),
  };
  bool serverTesting = false;
  bool serverTested = false;
  bool serverAvailable = false;
  bool serverSaved = false;
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
                decoration: InputDecoration(
                  labelText: '服务器地址',
                ),
                onChanged: onServerChanged,
              ),
              TextFormField(
                controller: serverFieldControllers['port'],
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
            color: serverTesting
                ? Colors.orangeAccent
                : serverTested
                    ? serverAvailable
                        ? serverSaved ? Colors.green : Colors.lightGreen
                        : Colors.redAccent
                    : Colors.orange,
            textColor: Colors.white,
            onPressed: onTestOrSavePressed,
            child: Text(serverTesting
                ? '连接测试中...'
                : serverTested
                    ? serverAvailable
                        ? serverSaved ? '已设置成功' : '连接测试成功，点击应用新设置'
                        : '连接测试失败，请重试'
                    : '连接测试'),
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
            child: new Text('退出程序'),
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
      serverTested = false;
      serverAvailable = false;
      serverSaved = false;
      schemeId = null;
    });
  }

  void onTestOrSavePressed() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (serverTesting) {
      Messager.info('请稍等');
      return;
    }
    if (serverTested && serverAvailable) {
      if (serverSaved) {
        return;
      }
      var config = await ConfigurationManager.configuration();
      serverFieldControllers.forEach((field, ctrl) async {
        config.setString('server.$field', ctrl.text);
      });
      prepareHTTPAPI(reload: true);
      Messager.ok('服务器设置成功');
      setState(() {
        serverSaved = true;
      });
      fetchSchemes();
    } else {
      var hostname = serverFieldControllers['hostname'].text;
      var port = serverFieldControllers['port'].text;
      if (hostname.isEmpty || port.isEmpty) {
        Messager.warning('请先输入服务器信息');
        return;
      }
      setState(() {
        serverTesting = true;
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
          Messager.ok('连接成功');
          setState(() {
            serverTesting = false;
            serverTested = true;
            serverAvailable = true;
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
          serverTesting = false;
          serverTested = true;
          serverAvailable = false;
        });
      }, test: (error) => true);
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
      serverTesting = false;
      serverTested = false;
      serverAvailable = false;
      serverSaved = false;
      schemeId = null;
    });
  }

}
