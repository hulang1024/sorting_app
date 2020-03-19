import 'package:flutter/material.dart';
import 'package:sorting/pages/package/list.dart';
import '../../widgets/code_input.dart';

class PackageSearchPage extends StatelessWidget {
  final GlobalKey<PackageListViewState> packageListViewKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('查询包裹'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: ListView(
          children: [
            CodeInput(
              labelText: '包裹编号',
              onDone: (code) {
                packageListViewKey.currentState.query({'code': code});
              }
            ),
            PackageListView(
              key: packageListViewKey,
              queryParams: {'fromAll': '1'}
            )
          ],
        )
      )
    );
  }
}