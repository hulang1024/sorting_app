import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sorting/service/coded_address.dart';
import 'package:sorting/service/package.dart';
import '../../widgets/data_list.dart';
import '../../api/http_api.dart';
import '../screen.dart';
import '../../widgets/code_input.dart';
import '../../widgets/message.dart';
import 'list_tile.dart';

/// 建包屏。
class PackageCreateScreen extends Screen {
  PackageCreateScreen({this.smartCreate = false}) : super(title: smartCreate ? '智能建包' : '手动建包', autoKeyboardFocus: false);

  final bool smartCreate;

  @override
  State<StatefulWidget> createState() => PackageCreateScreenState();
}

class PackageCreateScreenState extends ScreenState<PackageCreateScreen> {
  GlobalKey<DataListViewState> packageListViewKey = GlobalKey();
  GlobalKey<CodeInputState> codeInputKey = GlobalKey();
  TextEditingController destCodeController = TextEditingController();
  var focusNodes = {
    'code': FocusNode(),
    'destCode': FocusNode(),
  };
  Map<String, dynamic> formData = {};
  String address = '';
  bool querying = false;

  @override
  Widget render(BuildContext context) {
    return ListView(
      children: [
        Column(
          children: [
            CodeInput(
              key: codeInputKey,
              focusNode: focusNodes['code'],
              labelText: '集包编号',
              onDone: (code) {
                FocusScope.of(context).nextFocus();
              },
            ),
            TextField(
              controller: destCodeController,
              keyboardType: TextInputType.number,
              focusNode: focusNodes['destCode'],
              decoration: InputDecoration(
                labelText: '目的地编号',
                labelStyle: TextStyle(fontWeight: FontWeight.normal, letterSpacing: 0),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
              onChanged: (value) {
                queryAddress();
              },
            ),
            addressQueryResult(),
          ],
        ),
        RaisedButton(
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          onPressed: () {
            submit();
          },
          child: Text('建包'),
        ),
        DataListView(
          key: packageListViewKey,
          height: 224,
          loadData: loadData,
          noDataText: '没有集包创建记录',
          rowBuilder: (package, [index, context]) {
            return PackageListTile(package, context);
          },
        ),
      ],
    );
  }

  Widget addressQueryResult() {
    return Container(
      padding: EdgeInsets.only(top: 2),
      height: 16,
      child: Align(
        child: querying
            ? Text('查询中...', style: TextStyle(color: Colors.grey, fontSize: 11.5))
            : destCodeController.text.isNotEmpty
                ? address.isNotEmpty
                    ? Text('目的地：' + address, style: TextStyle(fontSize: 11.5))
                    : Text('未查询到地址', style: TextStyle(color: Colors.red, fontSize: 11.5))
                : Text('', style: TextStyle(fontSize: 11.5)),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Future<Page> loadData(Map<String, dynamic> queryParams) {
    queryParams['fromAll'] = '1';
    queryParams['isSmartCreate'] = widget.smartCreate;
    return PackageService().queryPage(queryParams);
  }

  void queryAddress() async {
    String destCode = destCodeController.text;
    if (destCode.isEmpty) {
      setState(() {
        this.address = '';
      });
      return;
    }
    setState(() {
      querying = true;
    });
    String address = await CodedAddressService().query(code: destCode);
    setState(() {
      this.address = address ?? '';
      querying = false;
    });
  }

  @protected
  void onOKKeyDown() {
    if (focusNodes['destCode'].hasFocus) {
      submit();
    } else if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).nextFocus();
    } else {
      submit();
    }
  }

  void submit() async {
    FocusScope.of(context).unfocus(focusPrevious: true);

    formData['code'] = codeInputKey.currentState.controller.text;
    formData['destCode'] = destCodeController.text;

    for (var field in formData.keys) {
      if (formData[field].isEmpty) {
        focusNodes[field].requestFocus();
        return;
      }
    }


    Result result = await PackageService().add(
      formData,
      (widget.smartCreate ? {'smartCreate': widget.smartCreate, 'allocItemNumMax': 10} : null),
    );
    if (result.isOk) {
      Messager.ok('创建集包成功');
      codeInputKey.currentState.controller.clear();
      destCodeController.clear();
      packageListViewKey.currentState.query();
      formData.clear();
    } else {
      Messager.error(result.msg);

      if (result.code == 2) {
        focusNodes['code'].requestFocus();
      } else if (result.code == 3) {
        focusNodes['destCode'].requestFocus();
      }
    }
  }
}
