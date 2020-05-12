import 'package:flutter/material.dart';
import 'package:sorting/entity/package_entity.dart';
import 'package:sorting/service/package_delete.dart';
import 'package:sorting/widgets/status.dart';
import '../screen.dart';
import '../../widgets/message.dart';
import '../../widgets/data_list.dart';
import '../../widgets/code_input.dart';
import '../../api/http_api.dart';
import 'details.dart';

/// 删除集包。
class PackageDeleteScreen extends Screen {
  PackageDeleteScreen() : super(title: '删除集包', autoKeyboardFocus: false);

  @override
  State<StatefulWidget> createState() => PackageDeleteScreenState();
}

class PackageDeleteScreenState extends ScreenState<PackageDeleteScreen> {
  GlobalKey<DataListViewState> dataListKey = GlobalKey();
  GlobalKey<CodeInputState> codeInputKey = GlobalKey();

  @override
  Widget render(BuildContext context) {
    return ListView(
      children: [
        CodeInput(
          key: codeInputKey,
          labelText: '集包编号',
          suffixIcon: Icons.delete_forever,
          onDone: (code) async {
            submit();
          },
        ),
        DataListView(
          key: dataListKey,
          height: 336,
          loadData: loadData,
          noDataText: '没有集包删除记录',
          rowBuilder: (op, [index, context]) {
            return ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(op['code'], style: TextStyle(color: Colors.black87, fontSize: 14)),
                  Text(op['status'] == 0 ? '删除成功' : op['status'] == 1 ? '等待上传' : '删除失败',
                    style: TextStyle(color: deleteOpStatus(op['status']).color, fontSize: 14),
                  ),
                ],
              ),
              trailing: Icon(Icons.keyboard_arrow_right),
              contentPadding: EdgeInsets.zero,
              dense: true,
              onTap: () {
              Navigator.push(context, MaterialPageRoute(builder:
                  (context) => PackageDetailsScreen(PackageEntity().fromJson({'code': op['code'], 'status': 4}))));
              },);
            },
        ),
      ],
    );
  }

  Future<Page> loadData(Map<String, dynamic> queryParams) {
    return PackageDeleteService().queryPage(queryParams);
  }

  @override
  void onOKKeyDown() {
    submit();
  }

  void submit() async {
    FocusScope.of(context).unfocus(focusPrevious: true);

    String code = codeInputKey.currentState.controller.text;
    if (code.isEmpty) {
      return;
    }

    Result ret = await PackageDeleteService().delete(code);
    if (ret.isOk) {
      Messager.ok('删除成功');
      codeInputKey.currentState.controller.clear();
      dataListKey.currentState.query();
    } else {
      Messager.error(ret.msg);
    }
  }

}

Status deleteOpStatus(code) => [
  Status(text: '删除成功', color: Colors.green),
  Status(text: '等待上传', color: Colors.orange),
  Status(text: '删除失败，集包包含快件', color: Colors.red),
  Status(text: '删除失败，集包不存在', color: Colors.red),
][code];