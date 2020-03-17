import 'package:flutter/material.dart';
import 'package:sorting/widgets/message.dart';

class PackageCreatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new PackageCreatePageState();
}

class PackageCreatePageState extends State<PackageCreatePage> {
  GlobalKey<FormState> formKey = new GlobalKey();
  var formData = {'code': '', 'destCode': ''};
  var focusNodes = {
    'code': new FocusNode(),
    'destCode': new FocusNode(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('手动建包'),
        centerTitle: true
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: (RawKeyEvent event) {
                    if (event.data.logicalKey.keyId == 32) {
                      focusNodes['code'].unfocus();
                      FocusScope.of(context).requestFocus(focusNodes['destCode']);
                    }
                  },
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    autofocus: true,
                    focusNode: focusNodes['code'],
                    decoration: InputDecoration(
                      labelText: '包编号',
                    ),
                    validator: (val) {
                      return val.length == 0 ? "请输入包编号" : null;
                    },
                    style: TextStyle(fontSize: 20),
                    onSaved: (val) => formData['code'] = val.trim(),
                  )
                )
              ),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: (RawKeyEvent event) {
                    if (event.data.logicalKey.keyId == 32) {
                      submit();
                    }
                  },
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    focusNode: focusNodes['destCode'],
                    decoration: InputDecoration(
                      labelText: '目的地编号',
                    ),
                    validator: (val) {
                      return val.length == 0 ? "目的地编号 " : null;
                    },
                    style: TextStyle(fontSize: 20),
                    onSaved: (val) => formData['destCode'] = val.trim(),
                  )
                )
              ),
            ],
          )
        )
      )
    );
  }

  void submit() {
    Messager.ok('假装提交成功');
  }
}