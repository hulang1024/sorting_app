import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:sorting/entity/user_entity.dart';
import 'package:sorting/session.dart';
import 'config.dart';
import 'screens/settings/version.dart';
import 'widgets/message.dart';
import 'api/http_api.dart';
import 'home.dart';
import 'screens/user/register.dart';
import 'screens/settings/settings.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> with SingleTickerProviderStateMixin {
  GlobalKey<FormState> formKey = GlobalKey();
  Map<String, TextEditingController> controllers = {};
  Map<String, FocusNode> focusNodes = {};
  Map<String, dynamic> formData = {};
  Image captchaImage;
  bool captchaLoading = true;
  bool logging = false;

  @override
  void initState() {
    super.initState();
    ['username', 'password', 'captcha'].forEach((key) {
      controllers[key] = TextEditingController();
      focusNodes[key] = FocusNode();
    });

    (() async {
      var config = await ConfigurationManager.configuration();
      controllers['username'].text = config.getString('username');
      if (controllers['username'].text.isNotEmpty) {
        focusNodes['username'].nextFocus();
      }

      if (await prepareHTTPAPI()) {
        VersionManager.checkUpdate();
        flushCaptcha();
      } else {
        Messager.warning('请先进行初始设置');
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsScreen()));
      }
    })();
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
    return Material(
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: ListView(
          children: [
            Center(
              child: Text(
                '欢迎登陆',
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
                    padding: EdgeInsets.only(top: 8),
                    child: TextFormField(
                      controller: controllers['username'],
                      focusNode: focusNodes['username'],
                      keyboardType: TextInputType.phone,
                      autofocus: true,
                      maxLength: 11,
                      decoration: InputDecoration(
                        hintText: '请输入手机号/编号',
                        counterText: '',
                      ),
                      style: TextStyle(letterSpacing: 2),
                      validator: (val) {
                        return val.length == 0 ? "请输入用户名" : null;
                      },
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(focusNodes[controllers['password'].text.isEmpty
                            ? 'password' : 'captcha']);
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
                      maxLength: 20,
                      decoration: InputDecoration(
                        hintText: '密码',
                        counterText: '',
                      ),
                      obscureText: true,
                      style: TextStyle(letterSpacing: 2),
                      validator: (val) {
                        return val.length < 6 ? "密码长度错误" : null;
                      },
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(
                            controllers['captcha'].text.isEmpty ? focusNodes['captcha'] : FocusNode());
                      },
                      onSaved: (val) => formData['password'] = val.trim(),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 8),
                        width: 112,
                        child: TextFormField(
                          controller: controllers['captcha'],
                          focusNode: focusNodes['captcha'],
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            hintText: '验证码',
                            counterText: '',
                          ),
                          style: TextStyle(letterSpacing: 2),
                          validator: (val) {
                            return val.length != 4 ? "验证码错误" : null;
                          },
                          onSaved: (val) => formData['captcha'] = val,
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        width: 152,
                        height: 60,
                        padding: EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: onCaptchaPressed,
                          child: AnimatedOpacity(
                            duration: Duration(milliseconds: 500),
                            opacity: captchaLoading ? 0 : 1,
                            curve: captchaLoading ? Curves.easeOut : Curves.easeIn,
                            child: captchaImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 40, 0, 8),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  onPressed: onLoginPressed,
                  child: Text(logging ? '登录中' : '登录'),
                ),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              buttonPadding: EdgeInsets.symmetric(horizontal: 0),
              children: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsScreen(homeAction: false)));
                  },
                  child: Text('应用设置'),
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
                  child: Text('用户注册'),
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
      await flushCaptcha();
      FocusScope.of(context).requestFocus(focusNodes['captcha']);
      controllers['captcha'].text = '';
    } else {
      Messager.warning('无法刷新验证码，请先设置服务器');
    }
  }

  Future flushCaptcha() {
    setState(() {
      captchaLoading = true;
    });
    // 不能直接使用NetworkImage，因为NetworkImage和dio将产生不同的session
    return api.get(
      '/user/login_captcha?width=152&height=52&v=${DateTime.now().millisecondsSinceEpoch}',
      options: Options(responseType: ResponseType.bytes),
    ).then((resp) {
      setState(() {
        captchaImage = Image.memory(resp);
        captchaLoading = false;
      });
    });
  }

  void onLoginPressed() async {
    if(!await prepareHTTPAPI()) {
      Messager.warning('无法登陆，请先设置服务器');
      return;
    }

    var config = await ConfigurationManager.configuration();

    if (config.getString('branch.code') == null) {
        Messager.warning('无法登陆，还未设置网点');
        return;
    }
    formData['branchCode'] = config.getString('branch.code');

    var form = formKey.currentState;
    if (!form.validate()) return;
    form.save();

    setState(() {
      logging = true;
    });
    api.post('/user/login', queryParameters: formData).then((ret) {
      if (ret.isOk) {
        setCurrentUser(UserEntity().fromJson(ret.data));
        if (config.getBool('rememberUsername')) {
          config.setString('username', formData['username']);
        } else {
          config.setString('username', '');
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home()));
      } else {
        Messager.error(ret.msg);
        var errorField = {'2': 'captcha', '3': 'username', '4': 'password'}[ret.code.toString()];
        FocusScope.of(context).requestFocus(focusNodes[errorField]);
        if (errorField != 'username') {
          controllers[errorField].text = '';
        }
        setState(() {
          logging = false;
        });
      }
    }).catchError((_) {
      setState(() {
        logging = false;
      });
      Messager.error('连接服务器失败');
    }, test: (error) => true);
  }
}
