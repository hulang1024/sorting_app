import 'package:flutter/material.dart';
import 'package:sorting/entity/package_item_op_entity.dart';
import 'package:sorting/service/item_alloc.dart';
import '../screen.dart';
import '../../widgets/data_list.dart';
import '../../api/http_api.dart';
import 'list_tile.dart';

class PackageItemAllocSearchScreen extends Screen {
  PackageItemAllocSearchScreen() : super(title: '集包快件操作记录', autoKeyboardFocus: false);

  @override
  State<StatefulWidget> createState() => PackageItemAllocSearchScreenState();
}

class PackageItemAllocSearchScreenState extends ScreenState<PackageItemAllocSearchScreen> {
  GlobalKey<DataListViewState> dataListKey = GlobalKey();

  @override
  Widget render(BuildContext context) {
    return ListView(
      children: [
        DataListView(
          key: dataListKey,
          height: 382,
          loadData: loadData,
          convert: () => PackageItemOpEntity(),
          noDataText: '未查询到记录',
          rowBuilder: (item, index, context) {
            return ItemOpRecordListTile(item, context, showType: true);
          },
        ),
      ],
    );
  }
  Future<Page> loadData(Map<String, dynamic> queryParams) {
    return ItemAllocService().queryPage(queryParams);
  }
}
