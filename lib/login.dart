import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:sorting/entity/user_entity.dart';
import 'package:sorting/screens/screen.dart';
import 'package:sorting/screens/settings/general.dart';
import 'package:sorting/session.dart';
import 'config/config.dart';
import 'input/bindings/key_bindings_manager.dart';
import 'screens/settings/version.dart';
import 'widgets/message.dart';
import 'api/http_api.dart';
import 'home.dart';
import 'screens/user/register.dart';
import 'screens/settings/settings.dart';

class Login extends Screen {
  Login() : super(title: "欢迎登陆", hasAppBar: false, autoKeyboardFocus: false, addPadding: EdgeInsets.all(-8));
  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends ScreenState<Login> with SingleTickerProviderStateMixin {
  Map<String, TextEditingController> controllers = {};
  Map<String, FocusNode> focusNodes = {};
  GlobalKey captchaContainerKey = GlobalKey();
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

      if (await api.prepare()) {
        VersionManager.checkUpdate();
        flushCaptcha();
      } else {
        Messager.warning('请先进行初始设置');
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => GeneralSettingsScreen()));
      }

      await KeyBindingManager.load();
    })();
  }

  @override
  void deactivate() async {
    super.deactivate();
    if (ModalRoute.of(context).isCurrent) {
      if(await api.prepare()) {
        flushCaptcha();
      }
    }
  }

  @override
  Widget render(BuildContext context) {
    return Material(
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 32, 16, 0),
        child: ListView(
          children: [
            Text('欢迎登陆', style: TextStyle(color: Colors.black87.withOpacity(0.8), fontSize: 21, fontWeight: FontWeight.bold)),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 32),
                  decoration: BoxDecoration(
                    color: Color(0xffe9e7ef),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: TextField(
                    controller: controllers['username'],
                    focusNode: focusNodes['username'],
                    keyboardType: TextInputType.phone,
                    autofocus: true,
                    maxLength: 11,
                    decoration: InputDecoration(
                      labelText: '手机号码/编号',
                      counterText: '',
                      contentPadding: EdgeInsets.fromLTRB(16,8,0,8),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(letterSpacing: 2),
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(focusNodes[controllers['password'].text.isEmpty
                          ? 'password' : 'captcha']);
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Color(0xffe9e7ef),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: TextField(
                    controller: controllers['password'],
                    focusNode: focusNodes['password'],
                    autofocus: true,
                    maxLength: 20,
                    decoration: InputDecoration(
                      labelText: '密码',
                      counterText: '',
                      contentPadding: EdgeInsets.fromLTRB(16,8,0,8),
                      border: InputBorder.none,
                    ),
                    obscureText: true,
                    style: TextStyle(letterSpacing: 2),
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(
                          controllers['captcha'].text.isEmpty ? focusNodes['captcha'] : FocusNode());
                    },
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 16, 8, 0),
                      decoration: BoxDecoration(
                        color: Color(0xffe9e7ef),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      width: 124,
                      child: TextField(
                        controller: controllers['captcha'],
                        focusNode: focusNodes['captcha'],
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: '验证码',
                          counterText: '',
                          contentPadding: EdgeInsets.fromLTRB(16,8,0,8),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(letterSpacing: 2),
                      ),
                    ),
                    Expanded(
                      key: captchaContainerKey,
                      child: Container(
                        height: 50,
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
                    ),
                  ],
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 24, 0, 24),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: onLoginPressed,
                  child: Text(logging ? '登录中' : '登录'),
                ),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                FlatButton(
                  onPressed: () {
                    push(SettingsScreen(homeAction: false));
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
                    push(RegisterScreen());
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

  @override
  void onOKKeyDown() {
    if (focusNodes['captcha'].hasFocus) {
      onLoginPressed();
    } else if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).nextFocus();
    } else {
      onLoginPressed();
    }
  }

  void onCaptchaPressed() async {
    if(await api.prepare()) {
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
      '/user/login_captcha?width=${(captchaContainerKey.currentContext.findRenderObject() as RenderBox).size.width.toInt()}&height=50&v=${DateTime.now().millisecondsSinceEpoch}',
      options: Options(responseType: ResponseType.bytes),
    ).then((resp) {
      setState(() {
        captchaImage = Image.memory(resp);
        captchaLoading = false;
      });
    });
  }

  void onLoginPressed() async {
    FocusScope.of(context).unfocus();

    if(!await api.prepare()) {
      Messager.warning('无法登陆，请先设置服务器');
      return;
    }

    var config = await ConfigurationManager.configuration();

    if (config.getString('branch.code') == null) {
        Messager.warning('无法登陆，还未设置网点');
        return;
    }

    // 验证字段
    String error;
    if (controllers['username'].text.isEmpty) {
      error = '请输入用户名';
    } else if (controllers['password'].text.length < 6) {
      error = '密码长度错误';
    } else if (controllers['captcha'].text.length != 4) {
      error = '验证码错误';
    }
    if (error != null) {
      Messager.warning(error);
      return;
    }
    Map<String, dynamic> formData = {};
    ['username', 'password', 'captcha'].forEach((key) {
      formData[key] = controllers[key].text;
    });
    formData['branchCode'] = config.getString('branch.code');

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
