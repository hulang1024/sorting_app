import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen.dart';
import '../settings/settings.dart';
import '../../widgets/data_list.dart';
import '../../api/http_api.dart';
import '../../widgets/code_input.dart';
import '../../widgets/message.dart';

class PackageItemAllocScreen extends Screen {
  PackageItemAllocScreen({this.opType}) : super(title: opType == 1 ? '集包加件' : '集包减件');
  final int opType;

  @override
  State<StatefulWidget> createState() => PackageItemAllocScreenState();
}

class PackageItemAllocScreenState extends ScreenState<PackageItemAllocScreen> {
  GlobalKey<DataListViewState> dataListKey = GlobalKey();
  Map<String, GlobalKey<CodeInputState>> codeInputKeys = {
    'packageCode': GlobalKey(),
    'itemCode': GlobalKey(),
  };
  var focusNodes = {
    'packageCode': FocusNode(),
    'itemCode': FocusNode(),
  };

  @override
  Widget render(BuildContext context) {
    return ListView(
      children: [
        Column(
          children: [
            CodeInput(
              key: codeInputKeys['packageCode'],
              labelText: '集包编号',
              onDone: (code) {
                dataListKey.currentState.query({'packageCode': code});
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
        Container(
          margin: EdgeInsets.only(top: 8),
          child:
            RaisedButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                submit();
              },
              child: Text('确定'),
            ),
        ),
        DataListView(
          key: dataListKey,
          options: Options(
            height: 200,
            url: '/package_item_op/page',
            queryParams: {'opType': widget.opType},
            noData: Text('未查询到记录'),
            rowBuilder: (item, [index, context]) {
              return ListTile(
                title: Text('${item['opType'] == 1 ? '加件' : '减件'} ${item['itemCode']}'),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('集包${item['packageCode']}'),
                    Text('操作${item['opTime']} ${item['operatorName']}(${item['operatorPhone']})'),
                    Text('${item['opType'] == 1 ? '加件' : '减件'}${true ? '成功' : '失败'}', style: TextStyle(color: true ? Colors.green : Colors.red)),
                  ],
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
                onTap: () {
                  Messager.info('没有更多操作');
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void submit() async {
    int opType = widget.opType;
    Map<String, dynamic> formData = {};
    if (opType == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      formData['schemeId'] = prefs.getInt('schemeId');
      if (formData['schemeId'] == null) {
        Messager.error('请先设置模式');
        push(SettingsScreen());
        return;
      }
    }
    codeInputKeys.forEach((k, key) => formData[k] = key.currentState.controller.text);
    if (formData['packageCode'].isNotEmpty && formData['itemCode'].isNotEmpty) {
      var ret = await api.post('/package_item_op/${opType == 1 ? 'add_item' : 'delete_item'}', queryParameters: formData);
      if (ret.data['code'] == 0) {
        Messager.ok('${opType == 1 ? '加件' : '减件'}成功');
        // 只清空快件号
        formData['itemCode'] = '';
        codeInputKeys['itemCode'].currentState.controller.text = '';
        FocusScope.of(context).requestFocus(focusNodes['itemCode']);
        dataListKey.currentState.query();
      } else {
        Messager.error(ret.data['msg']);
      }
    }
  }
}
