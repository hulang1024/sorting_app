import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../screen.dart';
import '../../widgets/network_data_list.dart';
import '../item/list_tile.dart';
import '../../api/http_api.dart';

class PackageDetailsScreen extends Screen {
  PackageDetailsScreen(this.package, [this.isDeleted = false]) : super(title: '包裹详情');

  final Map package;
  final bool isDeleted;

  @override
  State<StatefulWidget> createState() => PackageDetailsScreenState();
}

class PackageDetailsScreenState extends ScreenState<PackageDetailsScreen> {
  Map details = {
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

    api.get(
      widget.isDeleted ? '/deleted_package/details' : '/package/details',
      queryParameters: {'code': widget.package['code']},
    ).then((ret) {
      setState(() {
        details = ret.data;
      });
    });
  }

  @override
  Widget render(BuildContext context) {
    var package = details['package'];
    var destAddress = details['destAddress'] ?? {};
    var creator = details['creator'] ?? {};
    var deleteOperator = details['deleteOperator'] ?? {};

    return ListView(
      children: [
        Column(
          children: [
            Row(children: [
              Container(width: 90, child: Text('包裹编号')),
              Text(package['code'] ?? ''),
            ]),
            Row(children: [
              Container(width: 90, child: Text('目的地')),
              Container(width: 200, child: Text(destAddress['address'] ?? '')),
            ]),
            Row(children: [
              Container(width: 90, child: Text('目的地编号')),
              Text(package['destCode'] ?? ''),
            ]),
            Row(children: [
              Container(width: 90, child: Text('创建者')),
              Text(creator['name'] ?? ''),
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text('(手机号:${creator['phone'] ?? '-'})'),
              )
            ]),
            Row(children: [
              Container(width: 90, child: Text('创建时间')),
              Text(creator['createAt'] ?? ''),
            ]),
            widget.isDeleted
                ? Row(children: [
                    Container(width: 90, child: Text('删除者')),
                    Text(deleteOperator['name'] ?? '-'),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text('(手机号:${deleteOperator['phone'] ?? '-'})'),
                    ),
                  ])
                : SizedBox(),
            widget.isDeleted
                ? Row(children: [
                    Container(width: 90, child: Text('删除时间')),
                    Text(package['deleteAt']),
                  ])
                : SizedBox()
          ],
        ),
        widget.isDeleted
            ? SizedBox()
            : Column(
                children: [
                  Divider(),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                    child: Text(
                      '快件（$itemTotal个）',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: NetworkDataList(
                      options: Options(
                          height: 202,
                          url: '/item/page',
                          queryParams: {'packageCode': package['code']},
                          noData: Text('未包含快件'),
                          rowBuilder: (item, index, context) {
                            return buildItemListTile(item, false, context);
                          },
                          onData: (data) {
                            setState(() {
                              itemTotal = data['total'];
                            });
                          }),
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}
