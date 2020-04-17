import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorting/service/item_alloc.dart';
import '../screen.dart';
import '../settings/settings.dart';
import '../../widgets/data_list.dart';
import '../../api/http_api.dart';
import '../../widgets/code_input.dart';
import '../../widgets/message.dart';
import 'list_tile.dart';

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
          height: 232,
          loadData: loadData,
          queryParams: {'opType': widget.opType},
          noDataText: '未查询到记录',
          rowBuilder: (op, [index, context]) {
            return ItemOpRecordListTile(op, context);
          },
        ),
      ],
    );
  }

  Future<Page> loadData(Map<String, dynamic> queryParams) {
    return ItemAllocService().queryPage(queryParams);
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
      Result ret = await ItemAllocService().operate(opType, formData);
      if (ret.isOk) {
        Messager.ok('${opType == 1 ? '加件' : '减件'}成功');
        // 只清空快件号
        formData['itemCode'] = '';
        codeInputKeys['itemCode'].currentState.controller.text = '';
        FocusScope.of(context).requestFocus(focusNodes['itemCode']);
        dataListKey.currentState.query();
      } else {
        Messager.error(ret.msg);
      }
    }
  }
}
