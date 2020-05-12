import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sorting/entity/item_entity.dart';
import 'package:sorting/entity/package_entity.dart';
import 'package:sorting/service/item.dart';
import 'package:sorting/service/package.dart';
import '../screen.dart';
import '../../widgets/data_list.dart';
import '../item/list_tile.dart';
import '../../api/http_api.dart';
import 'delete.dart';
import 'list_tile.dart';

/// 集包详情。
class PackageDetailsScreen extends Screen {
  PackageDetailsScreen(this.package) : super(title: '集包详情');

  final PackageEntity package;

  @override
  State<StatefulWidget> createState() => PackageDetailsScreenState();
}

class PackageDetailsScreenState extends ScreenState<PackageDetailsScreen> {
  String code;
  Map<String, dynamic> details = {
    'package': null,
    'destAddress': null,
    'creator': null,
    'deleteInfo': null,
  };
  int itemTotal = 0;

  @override
  void initState() {
    super.initState();
    code = widget.package.code;
    details['package'] = widget.package;
    (() async {
      details = await PackageService().details(widget.package);
      setState(() {});
    })();
  }

  @override
  Widget render(BuildContext context) {
    PackageEntity package = details['package'];
    var destAddress = details['destAddress'];
    var creator = details['creator'];
    var deleteInfo = details['deleteInfo'];

    return ListView(
      children: [
        Column(
          children: [
            Row(children: [
              Container(width: 90, child: Text('集包编号')),
              Text(package?.code ?? code),
            ]),
            if (destAddress != null)
              Row(children: [
                Container(width: 90, child: Text('目的地')),
                Container(width: 200, child: Text(destAddress['address'] ?? '')),
              ]),
            if (package != null)
              Row(children: [
                Container(width: 90, child: Text('目的地编号')),
                Text(package?.destCode ?? ''),
              ]),
            if (creator != null) ...[
              Row(children: [
                Container(width: 90, child: Text('创建者')),
                Text(creator['name'] ?? ''),
                Text('(手机号:${creator['phone'] ?? '-'})'),
              ]),
              Row(children: [
                Container(width: 90, child: Text('创建时间')),
                Text(package?.createAt ?? ''),
              ]),
            ],
            if (package?.status != null)
              Row(children: [
                Container(width: 90, child: Text('数据状态')),
                Text(packageStatus(package.status).text,
                  style: TextStyle(color: package.status == 0 ? Colors.green : packageStatus(package.status).color),
                ),
              ]),
            if (package?.lastUpdate != null)
              Row(children: [
                Container(width: 90, child: Text('更新时间')),
                Text(package.lastUpdate),
              ]),
            if (deleteInfo != null) ...[
              Row(children: [
                Container(width: 90, child: Text('删除者')),
                Text(deleteInfo['operatorInfo']['name'] ?? '-'),
                Text('(手机号:${deleteInfo['operatorInfo']['phone'] ?? '-'})'),
              ]),
              Row(children: [
                Container(width: 90, child: Text('删除时间')),
                Text(deleteInfo['deleteAt']),
              ]),
              Row(children: [
                Container(width: 90, child: Text('操作状态')),
                Text(deleteOpStatus(deleteInfo['status']).text,
                  style: TextStyle(color: deleteOpStatus(deleteInfo['status']).color),),
              ]),
            ],
          ],
        ),
        if (package != null && package.status != 4) packageItemsView(package),
      ],
    );
  }

  Widget packageItemsView(package) {
    return Column(
      children: [
        Divider(),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: Text('快件（$itemTotal个）',),
        ),
        DataListView(
          height: 202,
          loadData: loadPackageItemsData,
          queryParams: {'packageCode': package.code},
          noDataText: '未包含快件',
          showPagination: false,
          rowBuilder: (item, index, context) {
            return ItemListTile(item, false, context);
          },
        ),
      ],
    );
  }

  Future<Page> loadPackageItemsData(Map<String, dynamic> queryParams) async {
    Page page;
    if (api.isAvailable) {
      page = Page.fromMap(await api.get('/item/page', queryParameters: queryParams));
      page.content = page.content.map((e) => ItemEntity().fromJson(e)).toList();
    } else {
      page = await ItemService().queryPage(queryParams);
    }
    setState(() {
      itemTotal = page.total;
    });
    return page;
  }
}
