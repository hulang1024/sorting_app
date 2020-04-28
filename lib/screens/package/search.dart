import 'package:flutter/material.dart';
import 'package:sorting/entity/package_entity.dart';
import '../../widgets/data_list.dart';
import '../screen.dart';
import '../../widgets/code_input.dart';
import '../../api/http_api.dart';
import 'details.dart';
import 'list_tile.dart';

class PackageSearchScreen extends Screen {
  PackageSearchScreen() : super(title: '查询集包');
  @override
  State<StatefulWidget> createState() => PackageSearchScreenState();
}

class PackageSearchScreenState extends ScreenState<PackageSearchScreen> {
  final GlobalKey<DataListViewState> dataListViewStateKey = GlobalKey();

  @override
  Widget render(BuildContext context) {
    return ListView(
      children: [
        CodeInput(
          labelText: '集包编号',
          onDone: (code) {
            FocusScope.of(context).requestFocus(FocusNode());
            dataListViewStateKey.currentState.query({'code': code});
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
}
