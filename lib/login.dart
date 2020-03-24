import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'config.dart';
import 'widgets/message.dart';
import 'api/http_api.dart';
import 'home.dart';
import 'screens/user/register.dart';
import 'screens/settings/settings.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  GlobalKey<FormState> formKey = GlobalKey();
  var controllers = {
    'username': TextEditingController(),
    'password': TextEditingController(),
    'captcha': TextEditingController(),
  };
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

    ConfigurationManager.configuration().then((config) {
      controllers['username'].text = config.getString('username');

      prepareHTTPAPI().then((prepared) {
        if (prepared) {
          flushCaptcha();
        } else {
          Messager.warning('请先进行初始设置');
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsScreen()));
          return;
        }
      });
    });
  }

  @override
  void deactivate() async {
    super.deactivate();
    if (ModalRoute.of(context).isCurrent) {
      if(await prepareHTTPAPI()) {
        flushCaptcha();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
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
                      controller: controllers['username'],
                      focusNode: focusNodes['username'],
                      keyboardType: TextInputType.number,
                      autofocus: controllers['username'].text.isEmpty,
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
                      controller: controllers['password'],
                      focusNode: focusNodes['password'],
                      autofocus: true,
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
                            controller: controllers['captcha'],
                            focusNode: focusNodes['captcha'],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              icon: Icon(Icons.security),
                              labelText: '验证码',
                            ),
                            validator: (val) {
                              return val.length != 4 ? "验证码错误" : null;
                            },
                            onSaved: (val) => formData['captcha'] = val,
                          ),
                        ),
                      ),
                      captchaImage != null
                          ? GestureDetector(onTap: onCaptchaPressed, child: captchaImage)
                          : FlatButton(child: null, onPressed: onCaptchaPressed),
                    ],
                  ),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
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
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsScreen()));
                  },
                  child: Text('设置'),
                ),
                FlatButton(
                  onPressed: () {
                    Messager.info("请联系管理员重置您的密码");
                  },
                  child: Text('忘记密码'),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => RegisterScreen()));
                  },
                  child: Text('注册'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onCaptchaPressed() async {
    if(await prepareHTTPAPI()) {
      flushCaptcha();
    } else {
      Messager.warning('无法刷新验证码，请先设置服务器');
    }
  }

  void flushCaptcha() {
    // 不能直接使用NetworkImage，因为NetworkImage和dio将产生不同的session
    api.get(
      '/user/login_captcha?width=150&height=50&v=${DateTime.now().millisecondsSinceEpoch}',
      options: Options(responseType: ResponseType.bytes),
    ).then((resp) {
      setState(() {
        captchaImage = Image.memory(resp.data);
      });
      FocusScope.of(context).requestFocus(focusNodes['captcha']);
      controllers['captcha'].text = '';
    });
  }

  void onLoginPressed() async {
    if(!await prepareHTTPAPI()) {
      Messager.warning('无法登陆，请先设置服务器');
      return;
    }

    var form = formKey.currentState;
    if (!form.validate()) return;
    form.save();

    api.post('/user/login', queryParameters: formData).then((ret) {
      if (ret.data['code'] == 0) {
        ConfigurationManager.configuration().then((config) {
          config.setString('username', formData['username']);
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home()));
      } else {
        Messager.error(ret.data['msg']);
        var errorField = {'2': 'captcha', '3': 'username', '4': 'password'}[ret.data['code'].toString()];
        FocusScope.of(context).requestFocus(focusNodes[errorField]);
        if (errorField != 'username') {
          controllers[errorField].text = '';
        }
      }
    }).catchError((_) {
      Messager.error('连接服务器失败');
    }, test: (error) => true);
  }
}
