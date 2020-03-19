import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/code_input.dart';
import '../../api/http_api.dart';
import '../../utils/key_utils.dart';
import '../../widgets/message.dart';
import 'list.dart';

class PackageCreatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new PackageCreatePageState();
}

class PackageCreatePageState extends State<PackageCreatePage> {
  GlobalKey<PackageListViewState> packageListViewKey = new GlobalKey();
  GlobalKey<CodeInputState> codeInputKey = new GlobalKey();
  TextEditingController destCodeController = new TextEditingController();
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
        padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
        child: ListView(
          children: [
            Column(
              children: [
                CodeInput(
                  key: codeInputKey,
                  labelText: '包裹编号',
                  onDone: (code) {
                    formData['code'] = code;
                    FocusScope.of(context).requestFocus(focusNodes['destCode']);
                  }
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                  child: RawKeyboardListener(
                    focusNode: new FocusNode(),
                    onKey: (RawKeyEvent event) {
                      if (isOKKey(event)) {
                        focusNodes['destCode'].unfocus();
                        submit();
                      }
                    },
                    child: TextField(
                      controller: destCodeController,
                      keyboardType: TextInputType.number,
                      focusNode: focusNodes['destCode'],
                      decoration: InputDecoration(
                        labelText: '目的地编号',
                      ),
                    )
                  )
                )
              ]
            ),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              onPressed: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                submit();
              },
              child: Text('创建')
            ),
            PackageListView(
              key: packageListViewKey,
              height: 200
            )
          ]
        )
      )
    );
  }

  void submit() async {
    formData['destCode'] = destCodeController.text;
    if (formData['code'].isNotEmpty && formData['destCode'].isNotEmpty) {
      var ret = await api.post('/package', data: formData);
      if (ret.data['code'] == 0) {
        Messager.ok('创建包裹成功');
        codeInputKey.currentState.controller.clear();
        destCodeController.clear();
        packageListViewKey.currentState.query();
      } else {
        Messager.error(ret.data['msg']);
      }
    }
  }
}