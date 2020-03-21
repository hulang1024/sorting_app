import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/code_input.dart';
import '../../api/http_api.dart';
import '../../widgets/message.dart';
import 'list.dart';

class PackageCreatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PackageCreatePageState();
}

class PackageCreatePageState extends State<PackageCreatePage> {
  GlobalKey<PackageListViewState> packageListViewKey = GlobalKey();
  GlobalKey<CodeInputState> codeInputKey = GlobalKey();
  TextEditingController destCodeController = TextEditingController();
  var focusNodes = {
    'code': FocusNode(),
    'destCode': FocusNode(),
    'destCodeKeyboard': FocusNode(),
  };
  Map<String, dynamic> formData = {};
  String address = '';
  bool querying = false;

  @override
  Widget build(BuildContext context) {
    Widget queryResult = Align(
      child: querying
          ? Text('查询中...', style: TextStyle(color: Colors.grey))
          : destCodeController.text.isNotEmpty
              ? address.isNotEmpty ? Text('地址：' + address) : Text('未查询到地址', style: TextStyle(color: Colors.red))
              : Text(''),
      alignment: Alignment.centerLeft,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('创建包裹'),
        centerTitle: true,
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
                  },
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (RawKeyEvent event) {
                      if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                        //focusNodes['destCode'].unfocus();
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
                      onChanged: (value) {
                        queryAddress();
                      },
                    ),
                  ),
                ),
                queryResult,
              ],
            ),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                submit();
              },
              child: Text('创建'),
            ),
            PackageListView(
              key: packageListViewKey,
              height: 200,
            )
          ],
        ),
      ),
    );
  }

  queryAddress() {
    querying = true;
    api.get('/coded_address', queryParameters: {'code': destCodeController.text}).then((ret) {
      setState(() {
        address = ret.data.toString();
        querying = false;
      });
    });
  }

  void submit() async {
    queryAddress();
    formData['destCode'] = destCodeController.text;
    if (formData['code'].isNotEmpty && formData['destCode'].isNotEmpty) {
      var ret = await api.post('/package', data: formData);
      if (ret.data['code'] == 0) {
        Messager.ok('创建包裹成功');
        codeInputKey.currentState.controller.clear();
        destCodeController.clear();
        formData.clear();
        packageListViewKey.currentState.query();
      } else {
        Messager.error(ret.data['msg']);
      }
    }
  }
}
