import 'package:flutter/material.dart';
import '../screen.dart';
import '../../api/http_api.dart';
import '../../widgets/message.dart';

class PasswordModifyScreen extends Screen {
  PasswordModifyScreen() : super(title: '修改密码', autoKeyboardFocus: false);
  @override
  State<StatefulWidget> createState() => PasswordModifyScreenState();
}

class PasswordModifyScreenState extends ScreenState<PasswordModifyScreen> {
  GlobalKey<FormState> formKey = GlobalKey();
  var focusNodes = {
    'oldPassword': FocusNode(),
    'newPassword': FocusNode(),
  };
  Map<String, dynamic> formData = {};

  @override
  Widget render(BuildContext context) {
    return ListView(
      children: [
        Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                focusNode: focusNodes['oldPassword'],
                autofocus: true,
                maxLength: 20,
                decoration: InputDecoration(
                  labelText: '旧密码',
                  counterText: '',
                ),
                obscureText: true,
                validator: (val) {
                  return val.length < 6 ? "密码长度错误" : null;
                },
                onEditingComplete: () {
                  FocusScope.of(context).requestFocus(focusNodes['newPassword']);
                },
                onSaved: (val) => formData['oldPassword'] = val.trim(),
              ),
              TextFormField(
                focusNode: focusNodes['newPassword'],
                maxLength: 20,
                decoration: InputDecoration(
                  labelText: '新密码',
                  counterText: '',
                ),
                validator: (val) {
                  return val.length < 6 ? "密码长度错误" : null;
                },
                onSaved: (val) => formData['newPassword'] = val.trim(),
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
            child: Text('确定'),
          ),
        ),
      ],
    );
  }

  @override
  void onOKKeyDown() {
    if (focusNodes['newPassword'].hasFocus) {
      submit();
    } else if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).nextFocus();
    } else {
      submit();
    }
  }

  void submit() async {
    var form = formKey.currentState;
    if (form.validate()) {
      form.save();
      Result ret = await api.put('/user/password', queryParameters: formData);
      if (ret.isOk) {
        Messager.ok('修改成功');
      } else {
        Messager.error(ret.msg);
      }
    }
  }
}
