import 'package:flutter/material.dart';
import '../../api/http_api.dart';
import '../../widgets/message.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  GlobalKey<FormState> formKey = new GlobalKey();
  var focusNodes = {
    'name': new FocusNode(),
    'phone': new FocusNode(),
    'password': new FocusNode()
  };
  FocusScopeNode focusScopeNode;
  var formData = {'name': '', 'phone': '', 'password': ''};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('注册新用户'),
        centerTitle: true
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: ListView(
          children: [
            Form(
              key: formKey,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: TextFormField(
                      focusNode: focusNodes['name'],
                      keyboardType: TextInputType.text,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: '姓名',
                      ),
                      validator: (val) {
                        return val.length == 0 ? "请输入姓名" : null;
                      },
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(focusNodes['phone']);
                      },
                      onSaved: (val) => formData['name'] = val.trim(),
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      focusNode: focusNodes['phone'],
                      decoration: InputDecoration(
                        labelText: '手机号',
                      ),
                      validator: (val) {
                        return val.length == 0 ? "请输入手机号" : null;
                      },
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(focusNodes['password']);
                      },
                      onSaved: (val) => formData['phone'] = val.trim(),
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: TextFormField(
                      focusNode: focusNodes['password'],
                      decoration: InputDecoration(
                        labelText: '密码',
                      ),
                      validator: (val) {
                        return val.length < 6 ? "密码长度错误" : null;
                      },
                      onSaved: (val) => formData['password'] = val.trim(),
                    ),
                  )
                ]
              )
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: RaisedButton(
                  elevation: 10.0,
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: submit,
                  child: Text('注册'),
                )
              )
            )
          ]
        )
      )
    );
  }

  void submit() async {
    var form = formKey.currentState;
    if (form.validate()) {
      form.save();
      var ret = await api.post('/user/register', data: formData);
      if (ret.data['code'] == 0) {
        Navigator.of(context).pop();
        Messager.ok('注册成功');
      } else {
        Messager.error(ret.data['msg']);
      }
    }
  }
}