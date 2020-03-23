import 'package:flutter/material.dart';
import '../screen.dart';
import '../../api/http_api.dart';
import '../../widgets/message.dart';

class RegisterScreen extends Screen {
  RegisterScreen() : super(title: '注册', homeAction: false, addPadding: EdgeInsets.only(top: -8, left: 24, right: 24));
  @override
  State<StatefulWidget> createState() => RegisterScreenState();
}

class RegisterScreenState extends ScreenState<RegisterScreen> {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController codeTextController = TextEditingController();
  var focusNodes = {
    'name': FocusNode(),
    'phone': FocusNode(),
    'code': FocusNode(),
    'password': FocusNode(),
  };
  Map<String, dynamic> formData = {};

  @override
  void initState() {
    super.initState();
    api.get('/user/next_code').then((ret) {
      codeTextController.text = ret.data;
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
                focusNode: focusNodes['name'],
                keyboardType: TextInputType.text,
                autofocus: true,
                decoration: InputDecoration(
                  icon: Icon(Icons.person),
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
                  icon: Icon(Icons.smartphone),
                  labelText: '手机号',
                  helperText: '手机号可用作登录用户名',
                ),
                validator: (val) {
                  return val.length == 0 ? "请输入手机号" : null;
                },
                onEditingComplete: () {
                  FocusScope.of(context).requestFocus(focusNodes['password']);
                },
                onSaved: (val) => formData['phone'] = val.trim(),
              ),
              TextFormField(
                controller: codeTextController,
                keyboardType: TextInputType.number,
                focusNode: focusNodes['code'],
                readOnly: true,
                decoration: InputDecoration(
                  icon: Icon(Icons.credit_card),
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
                  icon: Icon(Icons.lock),
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
          child: RaisedButton(
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            onPressed: submit,
            child: Text('注册'),
          ),
        ),
      ],
    );
  }

  void submit() async {
    var form = formKey.currentState;
    if (form.validate()) {
      form.save();
      var ret = await api.post('/user/register', data: formData);
      if (ret.data['code'] == 0) {
        Messager.ok('注册成功');
        pop();
      } else {
        Messager.error(ret.data['msg']);
      }
    }
  }
}
