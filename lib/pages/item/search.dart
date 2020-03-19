import 'package:flutter/material.dart';
import '../../widgets/network_data_list.dart';
import '../../widgets/code_input.dart';
import 'details.dart';

class ItemSearchPage extends StatelessWidget {
  final GlobalKey<NetworkDataListState> networkDataListKey = new GlobalKey();

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
                networkDataListKey.currentState.query({'code': code});
              }
            ),
            NetworkDataList(
              key: networkDataListKey,
              options: new Options(
                url: '/item/page',
                noData: Text('未查询到快件'),
                rowBuilder: (item, [index, context]) {
                  return ListTile(
                    title: Text(item['code']),
                    subtitle: Text(item['createAt']),
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 2, 0),
                    trailing: RaisedButton(
                      child: Text('详情'),
                      onPressed: () {
                        Navigator.push(context, new MaterialPageRoute(
                            builder: (context) => ItemDetailsPage(item)
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