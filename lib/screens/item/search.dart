import 'package:flutter/material.dart';
import 'package:sorting/entity/item_entity.dart';
import '../screen.dart';
import '../../widgets/data_list.dart';
import '../../widgets/code_input.dart';
import '../../api/http_api.dart';
import 'details.dart';
import 'list_tile.dart';

class ItemSearchScreen extends Screen {
  ItemSearchScreen() : super(title: '查询快件');

  @override
  State<StatefulWidget> createState() => ItemSearchScreenState();
}

class ItemSearchScreenState extends ScreenState<ItemSearchScreen> {
  final GlobalKey<DataListViewState> dataListKey = GlobalKey();

  @override
  Widget render(BuildContext context) {
    return ListView(
      children: [
        CodeInput(
          labelText: '快件编号',
          onDone: (code) {
            FocusScope.of(context).requestFocus(FocusNode());
            dataListKey.currentState.query({'code': code});
          },
        ),
        DataListView(
          key: dataListKey,
          height: 336,
          url: '/item/page',
          convert: () => ItemEntity(),
          noDataText: '未查询到快件',
          rowBuilder: (item, index, context) {
            return ItemListTile(item, true, context);
          },
          onData: (Page page) {
            if (page.content.length == 1) {
              push(ItemDetailsScreen(page.content[0]));
            }
          },
        ),
      ],
    );
  }
}
