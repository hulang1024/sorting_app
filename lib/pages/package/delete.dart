import 'package:flutter/material.dart';
import '../../widgets/message.dart';
import '../../widgets/network_data_list.dart';
import '../../widgets/code_input.dart';
import '../../api/http_api.dart';
import 'details.dart';

class PackageDeletePage extends StatelessWidget {
  final GlobalKey<NetworkDataListState> networkDataListKey = new GlobalKey();

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
                  labelText: '包裹编号',
                  onDone: (code) async {
                    var ret = await api.post('/deleted_package',
                        queryParameters: {'code': code});
                    if (ret.data['code'] == 0) {
                      Messager.ok('删除成功');
                      networkDataListKey.currentState.query();
                    } else {
                      Messager.error(ret.data['msg']);
                    }
                  }
                ),
                NetworkDataList(
                  key: networkDataListKey,
                  options: new Options(
                    url: '/deleted_package/page',
                    noData: Text('未查询到包裹删除记录'),
                    rowBuilder: (item, [index, context]) {
                      return ListTile(
                          title: Text(item['code']),
                          subtitle: Text(item['createAt']),
                          contentPadding: EdgeInsets.fromLTRB(0, 0, 2, 0),
                          trailing: RaisedButton(
                              child: Text('详情'),
                              onPressed: () {
                                Navigator.push(context, new MaterialPageRoute(
                                    builder: (context) => PackageDetailsPage(item, true)
                                ));
                              }
                          )
                      );
                    }
                  )
                )
              ],
            )
        )
    );
  }
}