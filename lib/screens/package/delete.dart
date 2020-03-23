import 'package:flutter/material.dart';
import '../screen.dart';
import '../../widgets/message.dart';
import '../../widgets/network_data_list.dart';
import '../../widgets/code_input.dart';
import '../../api/http_api.dart';
import 'details.dart';

class PackageDeleteScreen extends Screen {
  PackageDeleteScreen() : super(title: '删除包裹');

  @override
  State<StatefulWidget> createState() => PackageDeleteScreenState();
}

class PackageDeleteScreenState extends ScreenState<PackageDeleteScreen> {
  final GlobalKey<NetworkDataListState> networkDataListKey = GlobalKey();
  final GlobalKey<CodeInputState> codeInputKey = GlobalKey();

  @override
  Widget render(BuildContext context) {
    return ListView(
      children: [
        CodeInput(
          key: codeInputKey,
          labelText: '包裹编号',
          onDone: (code) async {
            FocusScope.of(context).requestFocus(FocusNode());
            submit(code);
          },
        ),
        NetworkDataList(
          key: networkDataListKey,
          options: Options(
            height: 310,
            url: '/deleted_package/page',
            noData: Text('未查询到包裹删除记录'),
            rowBuilder: (item, [index, context]) {
              return ListTile(
                title: Text(item['code']),
                subtitle: Text(item['deleteAt']),
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                trailing: Container(child: Icon(Icons.keyboard_arrow_right)),
                onTap: () {
                  push(PackageDetailsScreen(item, true));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void submit(code) async {
    if (code.isEmpty) return;
    var ret = await api.delete('/package', queryParameters: {'code': code});
    if (ret.data['code'] == 0) {
      Messager.ok('删除成功');
      codeInputKey.currentState.controller.clear();
      networkDataListKey.currentState.query();
    } else {
      Messager.error(ret.data['msg']);
    }
  }
}
