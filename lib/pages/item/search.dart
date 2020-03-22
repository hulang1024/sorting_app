import 'package:flutter/material.dart';
import '../../widgets/network_data_list.dart';
import '../../widgets/code_input.dart';
import 'details.dart';

class ItemSearchPage extends StatelessWidget {
  final GlobalKey<NetworkDataListState> networkDataListKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('查询快件'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: ListView(
          children: [
            CodeInput(
              labelText: '快件编号',
              onDone: (code) {
                FocusScope.of(context).requestFocus(FocusNode());
                networkDataListKey.currentState.query({'code': code});
              },
            ),
            Container(
              margin: EdgeInsets.only(top: 8),
              child: NetworkDataList(
                key: networkDataListKey,
                options: Options(
                  url: '/item/page',
                  noData: Text('未查询到快件'),
                  rowBuilder: (item, index, context) {
                    return ListTile(
                      title: Text(item['code']),
                      subtitle: Text(item['packTime'] == null ? '未分配' : '已分配' + '\n' + item['destAddress']),
                      contentPadding: EdgeInsets.fromLTRB(0, 0, 2, 0),
                      trailing: RaisedButton(
                        child: Text('详情'),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ItemDetailsPage(item)));
                        },
                      ),
                    );
                  },
                  onData: (data) {
                    if (data['content'].length == 1) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ItemDetailsPage(data['content'][0])));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
