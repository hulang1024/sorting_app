import 'package:flutter/material.dart';
import 'package:sorting/entity/package_entity.dart';
import '../../widgets/data_list.dart';
import '../screen.dart';
import '../../widgets/code_input.dart';
import '../../api/http_api.dart';
import 'details.dart';
import 'list_tile.dart';

class PackageSearchScreen extends Screen {
  PackageSearchScreen() : super(title: '查询集包', autoKeyboardFocus: false);
  @override
  State<StatefulWidget> createState() => PackageSearchScreenState();
}

class PackageSearchScreenState extends ScreenState<PackageSearchScreen> {
  GlobalKey<DataListViewState> dataListViewStateKey = GlobalKey();
  GlobalKey<CodeInputState> codeInputKey = GlobalKey();

  @override
  Widget render(BuildContext context) {
    return ListView(
      children: [
        CodeInput(
          key: codeInputKey,
          labelText: '集包编号',
          suffixIcon: Icons.search,
          onDone: (code) {
            search();
          },
        ),
        DataListView(
          key: dataListViewStateKey,
          height: 336,
          url: '/package/page',
          convert: () => PackageEntity(),
          queryParams: {'fromAll': '1'},
          noDataText: '未查询到集包',
          rowBuilder: (package, [index, context]) {
            return PackageListTile(package, context);
          },
          onData: (Page page) {
            if (page.content.length == 1) {
              push(PackageDetailsScreen(page.content[0]));
            }
          },
        ),
      ],
    );
  }

  @override
  void onOKKeyDown() {
    search();
  }

  void search() {
    FocusScope.of(context).unfocus();
    dataListViewStateKey.currentState.query({'code': codeInputKey.currentState.controller.text});
  }
}
