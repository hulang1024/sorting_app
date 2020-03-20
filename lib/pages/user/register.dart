import 'package:flutter/material.dart';
import '../../api/http_api.dart';
import '../../widgets/message.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController codeTextController = TextEditingController();
  var focusNodes = {
    'name': FocusNode(),
    'phone': FocusNode(),
    'code': FocusNode(),
    'password': FocusNode(),
  };
  FocusScopeNode focusScopeNode;
  var formData = {'name': '', 'phone': '', 'code': '', 'password': ''};

  @override
  void initState() {
    super.initState();
    api.get('/user/next_code').then((ret) {
      //formData['code'] = ret.data;
      codeTextController.text = ret.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('注册新用户'), centerTitle: true),
      body: Container(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: ListView(
          children: [
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
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
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    focusNode: focusNodes['phone'],
                    decoration: InputDecoration(
                      labelText: '手机号',
                      helperText: '手机号可用作登录用户名',
                    ),
                    validator: (val) {
                      return val.length == 0 ? "请输入手机号" : null;
                    },
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(focusNodes['code']);
                    },
                    onSaved: (val) => formData['phone'] = val.trim(),
                  ),
                  TextFormField(
                    controller: codeTextController,
                    keyboardType: TextInputType.number,
                    focusNode: focusNodes['code'],
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: '编号',
                      helperText: '编号也可用作登录用户名',
                    ),
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(focusNodes['password']);
                    },
                    onSaved: (val) => formData['code'] = val.trim(),
                  ),
                  TextFormField(
                    focusNode: focusNodes['password'],
                    decoration: InputDecoration(
                      labelText: '密码',
                    ),
                    validator: (val) {
                      return val.length < 6 ? "密码长度错误" : null;
                    },
                    onSaved: (val) => formData['password'] = val.trim(),
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
                  elevation: 10.0,
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: submit,
                  child: Text('注册'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void submit() async {
    var form = formKey.currentState;
    if (form.validate()) {
      form.save();
      var ret = await api.post('/user/register', data: formData);
      if (ret.data['code'] == 0) {
        Messager.ok('注册成功');
        Navigator.of(context).pop();
      } else {
        Messager.error(ret.data['msg']);
      }
    }
  }
}
