import 'package:flutter/material.dart';
import '../../screens/package/list.dart';
import '../screen.dart';
import '../../widgets/code_input.dart';
import 'details.dart';

class PackageSearchScreen extends Screen {
  PackageSearchScreen() : super(title: '查询包裹');
  @override
  State<StatefulWidget> createState() => PackageSearchScreenState();
}

class PackageSearchScreenState extends ScreenState<PackageSearchScreen> {
  final GlobalKey<PackageListViewState> packageListViewKey = GlobalKey();

  @override
  Widget render(BuildContext context) {
    return ListView(
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
          height: 310,
          queryParams: {'fromAll': '1'},
          onData: (data) {
            if (data['content'].length == 1) {
              push(PackageDetailsScreen(data['content'][0]));
            }
          },
        ),
      ],
    );
  }
}
