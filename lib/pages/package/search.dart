import 'package:flutter/material.dart';
import 'package:sorting/pages/package/list.dart';
import '../../widgets/code_input.dart';
import 'details.dart';

class PackageSearchPage extends StatelessWidget {
  final GlobalKey<PackageListViewState> packageListViewKey = GlobalKey();

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
                FocusScope.of(context).requestFocus(FocusNode());
                packageListViewKey.currentState.query({'code': code});
              },
            ),
            PackageListView(
              key: packageListViewKey,
              queryParams: {'fromAll': '1'},
              onData: (data) {
                if (data['content'].length == 1) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PackageDetailsPage(data['content'][0])));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
