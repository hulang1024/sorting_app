import 'package:flutter/material.dart';
import 'package:sorting/screens/screen.dart';
import '../screen.dart';
import '../../widgets/network_data_list.dart';
import '../../widgets/code_input.dart';
import 'details.dart';
import 'list_tile.dart';

class ItemSearchScreen extends Screen {
  ItemSearchScreen() : super(title: '查询快件');

  @override
  State<StatefulWidget> createState() => ItemSearchScreenState();
}

class ItemSearchScreenState extends ScreenState<ItemSearchScreen> {
  final GlobalKey<NetworkDataListState> networkDataListKey = GlobalKey();

  @override
  Widget render(BuildContext context) {
    return ListView(
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
              height: 304,
              url: '/item/page',
              noData: Text('未查询到快件'),
              rowBuilder: (item, index, context) {
                return buildItemListTile(item, true, context);
              },
              onData: (data) {
                if (data['content'].length == 1) {
                  push(ItemDetailsScreen(data['content'][0]));
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
