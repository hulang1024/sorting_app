import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/message.dart';
import '../api/http_api.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> formKey = new GlobalKey();
  var focusNodes = {
    'username': new FocusNode(),
    'password': new FocusNode(),
    'captcha': new FocusNode()
  };
  FocusScopeNode focusScopeNode;
  var formData = {'username': '', 'password': '', 'captcha': ''};
  var captchaImage;

  @override
  void initState() {
    super.initState();
    flushCaptcha();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Center(
                child: Text(
                  '分拣系统终端',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )
                )
              ),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  focusNode: focusNodes['username'],
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: '手机号',
                  ),
                  validator: (val) {
                    return val.length == 0 ? "请输入手机号" : null;
                  },
                  style: TextStyle(fontSize: 20),
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(focusNodes['password']);
                  },
                  onSaved: (val) => formData['username'] = val.trim(),
                )
              ),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: TextFormField(
                  focusNode: focusNodes['password'],
                  decoration: InputDecoration(
                    labelText: '密码',
                  ),
                  obscureText: true,
                  validator: (val) {
                    return val.length < 6 ? "密码长度错误" : null;
                  },
                  style: TextStyle(fontSize: 20),
                  onSaved: (val) => formData['password'] = val.trim(),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 8),
                    width: 112,
                    child: TextFormField(
                      focusNode: focusNodes['captcha'],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '验证码',
                      ),
                      validator: (val) {
                        return val.length != 4 ? "验证码长度错误" : null;
                      },
                      style: TextStyle(fontSize: 20),
                      onSaved: (val) => formData['captcha'] = val,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      flushCaptcha();
                    },
                    child: captchaImage != null ? captchaImage : FlatButton(child: null, onPressed: () {})
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 32, 0, 0),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: RaisedButton(
                    elevation: 10.0,
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    onPressed: onLoginPressed,
                    child: Text('登录'),
                  ),
                )
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('注册')
              )
            ],
          )
        )
      )
    );
  }

  void flushCaptcha() async {
    //不能直接使用NetworkImage，因为NetworkImage和dio将产生不同的session
    var resp = await api.get(
        '/user/login_captcha?width=150&height=50&v=${DateTime.now().millisecondsSinceEpoch}',
        options: Options(responseType: ResponseType.bytes));
    setState(() {
      captchaImage = Image.memory(resp.data);
    });
  }

  void onLoginPressed() async {
    var form = formKey.currentState;
    if (form.validate()) {
      form.save();
      var ret = await api.post('/user/login', data: formData, options: Options(
        contentType: 'application/x-www-form-urlencoded'
      ));
      if (ret.data['code'] == 0) {
        var qUser = ret.data['data'];
        user['id'] = qUser['id'];
        user['name'] = qUser['name'];
        user['phone'] = qUser['phone'];
        Navigator.pushReplacementNamed(context, '/home');
      } else {

        Messager.error(ret.data['msg']);
      }
    }
  }
}