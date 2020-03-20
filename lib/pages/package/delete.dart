import 'package:flutter/material.dart';
import '../../widgets/message.dart';
import '../../widgets/network_data_list.dart';
import '../../widgets/code_input.dart';
import '../../api/http_api.dart';
import 'details.dart';

class PackageDeletePage extends StatelessWidget {
  final GlobalKey<NetworkDataListState> networkDataListKey = GlobalKey();
  final GlobalKey<CodeInputState> codeInputKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('删除包裹'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: ListView(
          children: [
            CodeInput(
              key: codeInputKey,
              labelText: '包裹编号',
              onDone: (code) async {
                if (code.isEmpty) return;
                var ret = await api.delete('/package', queryParameters: {'code': code});
                if (ret.data['code'] == 0) {
                  Messager.ok('删除成功');
                  codeInputKey.currentState.controller.clear();
                  networkDataListKey.currentState.query();
                } else {
                  Messager.error(ret.data['msg']);
                }
              },
            ),
            NetworkDataList(
              key: networkDataListKey,
              options: Options(
                url: '/deleted_package/page',
                noData: Text('未查询到包裹删除记录'),
                rowBuilder: (item, [index, context]) {
                  return ListTile(
                    title: Text(item['code']),
                    subtitle: Text(item['deleteAt']),
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 2, 0),
                    trailing: RaisedButton(
                      child: Text('详情'),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PackageDetailsPage(item, true)));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
