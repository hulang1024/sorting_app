import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/message.dart';
import '../../api/http_api.dart';
import '../user/register.dart';
import '../setting/settings.dart';
import '../home.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> formKey = GlobalKey();
  var configLoaded = false;
  var focusNodes = {
    'username': FocusNode(),
    'password': FocusNode(),
    'captcha': FocusNode(),
    'keyboard': FocusNode(),
  };
  Map<String, dynamic> formData = {};
  var captchaImage;

  @override
  void initState() {
    super.initState();
    loadingConfig().then((_) {
      flushCaptcha();
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    if (ModalRoute.of(context).isCurrent) {
      loadingConfig().then((_) {
        flushCaptcha();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 40, 24, 0),
        child: ListView(
          children: [
            Center(
              child: Text(
                '分拣系统终端',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      focusNode: focusNodes['username'],
                      initialValue: '',
                      autofocus: true,
                      decoration: InputDecoration(
                        icon: Icon(Icons.account_circle),
                        labelText: '用户名',
                        hintText: '手机号/编号',
                      ),
                      validator: (val) {
                        return val.length == 0 ? "请输入用户名" : null;
                      },
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(focusNodes['password']);
                      },
                      onSaved: (val) => formData['username'] = val.trim(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: TextFormField(
                      focusNode: focusNodes['password'],
                      decoration: InputDecoration(
                        icon: Icon(Icons.lock),
                        labelText: '密码',
                      ),
                      obscureText: true,
                      validator: (val) {
                        return val.length < 6 ? "密码长度错误" : null;
                      },
                      onSaved: (val) => formData['password'] = val.trim(),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 8),
                        width: 112,
                        child: RawKeyboardListener(
                          focusNode: focusNodes['keyboard'],
                          onKey: (RawKeyEvent event) {
                            if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                              onLoginPressed();
                            }
                          },
                          child: TextFormField(
                            focusNode: focusNodes['captcha'],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              icon: Icon(Icons.picture_in_picture),
                              labelText: '验证码',
                            ),
                            validator: (val) {
                              return val.length != 4 ? "验证码错误" : null;
                            },
                            onSaved: (val) => formData['captcha'] = val,
                          ),
                        ),
                      ),
                      captchaImage ?? FlatButton(child: null, onPressed: flushCaptcha),
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 32, 0, 8),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: RaisedButton(
                  elevation: 4.0,
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  onPressed: onLoginPressed,
                  child: Text('登录'),
                ),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                FlatButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
                  },
                  child: Text('设置'),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage()));
                  },
                  child: Text('注册'),
                ),
                FlatButton(
                  onPressed: () {
                    Messager.info("请联系管理员重置您的密码");
                  },
                  child: Text('忘记密码'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void flushCaptcha() {
    //不能直接使用NetworkImage，因为NetworkImage和dio将产生不同的session
    api
        .get(
      '/user/login_captcha?width=150&height=50&v=${DateTime.now().millisecondsSinceEpoch}',
      options: Options(responseType: ResponseType.bytes),
    )
        .then((resp) {
      setState(() {
        captchaImage = Image.memory(resp.data);
      });
    });
  }

  Future loadingConfig() {
    return new Future(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('existsSetting') != null) {
        api.options.baseUrl = 'http://${prefs.get('server.hostname')}:${prefs.get('server.port')}';
        configLoaded = true;
        return;
      } else {
        Messager.info('请先进行初始设置');
        Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
      }
    });
  }

  void onLoginPressed() {
    if (!configLoaded) return;
    var form = formKey.currentState;
    if (form.validate()) {
      form.save();
      api.post('/user/login', queryParameters: formData).then((ret) {
        if (ret.data['code'] == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
        } else {
          Messager.error(ret.data['msg']);
        }
      }).catchError((_) {
        Messager.error('连接服务器失败');
      }, test: (error) => true);
    }
  }
}
