import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../screen.dart';
import '../../widgets/data_list.dart';
import '../item/list_tile.dart';
import '../../repositories/package.dart';
import '../../api/http_api.dart';
import 'list_tile.dart';

class PackageDetailsScreen extends Screen {
  PackageDetailsScreen(this.package, [this.isDeleted = false]) : super(title: '集包详情');

  final Map package;
  final bool isDeleted;

  @override
  State<StatefulWidget> createState() => PackageDetailsScreenState();
}

class PackageDetailsScreenState extends ScreenState<PackageDetailsScreen> {
  Map<String, dynamic> details = {
    'package': {},
    'destAddress': {},
    'creator': {},
    'deleteOperator': {},
    'items': [],
  };
  int itemTotal = 0;

  @override
  void initState() {
    super.initState();
    details['package'] = widget.package;
    var package = details['package'];

    (() async {
      if (!widget.isDeleted) {
        // 如果是服务器集包数据，就从服务器查询
        // 如果是本地集包数据且是上传成功状态并且可连接服务器，也从服务器查询；否则从本地库查询
        PackageRepo repo = package['status'] == null || (package['status'] == 0 && serverAvailable())
            ? PackageRemoteRepo() : PackageLocalRepo();
        details = await repo.details(package['code']);
        setState(() {});
      } else {
        details = (await api.get('/deleted_package/details', queryParameters: {'code': package['code']})).data;
        setState(() {});
      }
    })();

  }

  @override
  Widget render(BuildContext context) {
    var package = details['package'];
    var destAddress = details['destAddress'];
    var creator = details['creator'];
    var deleteOperator = details['deleteOperator'];

    return ListView(
      children: [
        Column(
          children: [
            Row(children: [
              Container(width: 90, child: Text('集包编号')),
              Text(package['code'] ?? ''),
            ]),
            if (destAddress != null)
              Row(children: [
                Container(width: 90, child: Text('目的地')),
                Container(width: 200, child: Text(destAddress['address'] ?? '')),
              ]),
            Row(children: [
              Container(width: 90, child: Text('目的地编号')),
              Text(package['destCode'] ?? ''),
            ]),
            if (creator != null) ...[
              Row(children: [
                Container(width: 90, child: Text('创建者')),
                Text(creator['name'] ?? ''),
                Text('(手机号:${creator['phone'] ?? '-'})'),
              ]),
              Row(children: [
                Container(width: 90, child: Text('创建时间')),
                Text(package['createAt'] ?? ''),
              ]),
            ],
            if (package['status'] != null)
              Row(children: [
                Container(width: 90, child: Text('数据状态')),
                Text([
                  '已上传成功',
                  '未上传到服务器',
                  '上传失败，已存在相同编号',
                  '上传失败，未查询到目的地编号'][package['status']],
                  style: TextStyle(color: package['status'] == 0 ? Colors.green : statusColor(package['status'])),
                ),
              ]),
            if (package['lastUpdate'] != null)
              Row(children: [
                Container(width: 90, child: Text('更新时间')),
                Text(package['lastUpdate']),
              ]),
            if (widget.isDeleted && deleteOperator != null) ...[
              Row(children: [
                Container(width: 90, child: Text('删除者')),
                Text(deleteOperator['name'] ?? '-'),
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text('(手机号:${deleteOperator['phone'] ?? '-'})'),
                ),
              ]),
              Row(children: [
                Container(width: 90, child: Text('删除时间')),
                Text(package['deleteAt']),
              ]),
            ],
          ],
        ),
        if (!widget.isDeleted) packageItemsView(package),
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
          options: Options(
            height: 202,
            url: '/item/page',
            queryParams: {'packageCode': package['code']},
            noData: Text('未包含快件'),
            rowBuilder: (item, index, context) {
              return ItemListTile(item, false, context);
            },
            onData: (Page page) {
              setState(() {
                itemTotal = page.total;
              });
            },
          ),
        ),
      ],
    );
  }
}
