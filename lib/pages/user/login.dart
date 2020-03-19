import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sorting/pages/home.dart';
import 'package:sorting/pages/user/register.dart';
import '../../models/user.dart';
import '../../widgets/message.dart';
import '../../api/http_api.dart';

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
  GlobalKey<EditableTextState> key = new GlobalKey();

  @override
  void initState() {
    super.initState();
    flushCaptcha();
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
                )
              )
            ),
            Form(
              key: formKey,
              child: Column(
                children:[
                  Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: TextFormField(
                      key: key,
                      keyboardType: TextInputType.number,
                      focusNode: focusNodes['username'],
                      initialValue: '18112345678',
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: '手机号',
                      ),
                      validator: (val) {
                        return val.length == 0 ? "请输入手机号" : null;
                      },
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
                      initialValue: '666666',
                      decoration: InputDecoration(
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
                        child: TextFormField(
                          focusNode: focusNodes['captcha'],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '验证码',
                          ),
                          validator: (val) {
                            return val.length != 4 ? "验证码长度错误" : null;
                          },
                          onSaved: (val) => formData['captcha'] = val,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          flushCaptcha();
                        },
                        child: captchaImage ??
                          FlatButton(child: null, onPressed: () { flushCaptcha(); })
                      )
                    ],
                  )
                ]
              )
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 32, 0, 8),
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
                Navigator.push(context, new MaterialPageRoute(builder: (_) => RegisterPage()));
              },
              child: Text('注册')
            )
          ],
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
        Navigator.pushReplacement(context, new MaterialPageRoute(builder: (_) => HomePage()));
      } else {
        Messager.error(ret.data['msg']);
      }
    }
  }
}