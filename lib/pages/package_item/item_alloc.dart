import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/network_data_list.dart';
import '../../api/http_api.dart';
import '../../widgets/code_input.dart';
import '../../widgets/message.dart';

class PackageItemAllocPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PackageItemAllocPageState();
}

class PackageItemAllocPageState extends State<PackageItemAllocPage> {
  GlobalKey<NetworkDataListState> networkDataListKey = GlobalKey();
  Map<String, GlobalKey<CodeInputState>> codeInputKeys = {
    'packageCode': GlobalKey(),
    'itemCode': GlobalKey(),
  };
  var focusNodes = {
    'packageCode': FocusNode(),
    'itemCode': FocusNode(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('加减快件'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
        child: ListView(
          children: [
            Column(
              children: [
                CodeInput(
                  key: codeInputKeys['packageCode'],
                  labelText: '包裹编号',
                  onDone: (code) {
                    networkDataListKey.currentState.query({'packageCode': code});
                    FocusScope.of(context).requestFocus(focusNodes['itemCode']);
                  },
                ),
                CodeInput(
                  key: codeInputKeys['itemCode'],
                  focusNode: focusNodes['itemCode'],
                  labelText: '快件编号',
                  onDone: (code) {
                    focusNodes['itemCode'].unfocus();
                  },
                ),
              ],
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                RaisedButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    submit(1);
                  },
                  child: Text('加件'),
                ),
                RaisedButton(
                  color: Colors.redAccent,
                  textColor: Colors.white,
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    submit(2);
                  },
                  child: Text('减件'),
                ),
              ],
            ),
            Divider(),
            NetworkDataList(
              key: networkDataListKey,
              options: Options(
                url: '/package_item_op/page',
                noData: Text('未查询到记录'),
                rowBuilder: (item, [index, context]) {
                  return ListTile(
                    title: Text('${item['opType'] == 1 ? '加件' : '减件'} ${item['itemCode']}'),
                    subtitle: Text([
                      '包裹 ${item['packageCode']}',
                      '操作者 ${item['operatorName']}(${item['operatorPhone']})',
                      '操作时间 ${item['opTime']}',
                    ].join('\n')),
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 2, 0),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void submit(opType) async {
    Map<String, dynamic> formData = {};
    if (opType == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      formData['schemeId'] = prefs.getInt('schemeId');
    }
    codeInputKeys.forEach((k, key) => formData[k] = key.currentState.controller.text);
    if (formData['packageCode'].isNotEmpty && formData['itemCode'].isNotEmpty) {
      var ret = await api.post('/package_item_op/${opType == 1 ? 'add_item' : 'delete_item'}', queryParameters: formData);
      if (ret.data['code'] == 0) {
        Messager.ok('${opType == 1 ? '加件' : '减件'}成功');
        codeInputKeys.forEach((k, key) => key.currentState.controller.text = '');
        formData.clear();
        networkDataListKey.currentState.query();
      } else {
        Messager.error(ret.data['msg']);
      }
    }
  }
}
