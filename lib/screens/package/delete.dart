import 'package:flutter/material.dart';
import 'package:sorting/service/package.dart';
import '../screen.dart';
import '../../widgets/message.dart';
import '../../widgets/data_list.dart';
import '../../widgets/code_input.dart';
import '../../api/http_api.dart';
import 'list_tile.dart';

class PackageDeleteScreen extends Screen {
  PackageDeleteScreen() : super(title: '删除集包');

  @override
  State<StatefulWidget> createState() => PackageDeleteScreenState();
}

class PackageDeleteScreenState extends ScreenState<PackageDeleteScreen> {
  final GlobalKey<DataListViewState> dataListKey = GlobalKey();
  final GlobalKey<CodeInputState> codeInputKey = GlobalKey();

  @override
  Widget render(BuildContext context) {
    return ListView(
      children: [
        CodeInput(
          key: codeInputKey,
          labelText: '集包编号',
          onDone: (code) async {
            FocusScope.of(context).requestFocus(FocusNode());
            submit(code);
          },
        ),
        DataListView(
          key: dataListKey,
          height: 336,
          loadData: loadData,
          noDataText: '没有集包删除记录',
          rowBuilder: (package, [index, context]) {
            return PackageListTile(package, context);
          },
        ),
      ],
    );
  }

  Future<Page> loadData(Map<String, dynamic> queryParams) {
    queryParams['isDeleted'] = true;
    return PackageService().queryPage(queryParams);
  }

  void submit(code) async {
    if (code.isEmpty) return;
    Result ret = await PackageService().delete(code);
    if (ret.isOk) {
      Messager.ok('删除成功');
      codeInputKey.currentState.controller.clear();
      dataListKey.currentState.query();
    } else {
      Messager.error(ret.msg);
    }
  }
}
