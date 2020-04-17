import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sorting/entity/package_entity.dart';
import 'package:sorting/entity/package_item_op_entity.dart';
import 'package:sorting/screens/item/list_tile.dart';
import 'package:sorting/service/item_alloc.dart';
import '../package/details.dart';
import '../screen.dart';

class ItemAllocOpDetailsScreen extends Screen {
  ItemAllocOpDetailsScreen(this.op) : super(title: '集包${op.opType == 1 ? '增件' : '减件'}详情');

  final PackageItemOpEntity op;

  @override
  State<StatefulWidget> createState() => ItemAllocOpDetailsScreenState();
}

class ItemAllocOpDetailsScreenState extends ScreenState<ItemAllocOpDetailsScreen> {
  Map details = {'op': {}};

  @override
  void initState() {
    super.initState();
    details['op'] = widget.op;
    (() async {
      details = await ItemAllocService().details(widget.op.id);
      setState(() {});
    })();
  }

  @override
  Widget render(BuildContext context) {
    PackageItemOpEntity op = details['op'];
    var creator = details['creator'] ?? {};

    return ListView(
      children: [
        Column(
          children: [
            Row(children: [
              Container(width: 90, child: Text('集包编号')),
              Text.rich(
                TextSpan(
                  text: op.packageCode,
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      push(PackageDetailsScreen(PackageEntity().fromJson({'code': op.packageCode, 'status': op.status})));
                    },
                ),
              ),
            ]),
            Row(children: [
              Container(width: 90, child: Text('快件编号')),
              Text(op.itemCode),
            ]),
            Row(children: [
              Container(width: 90, child: Text('操作时间')),
              Text(op.opTime ?? ''),
            ]),
            Row(children: [
              Container(width: 90, child: Text('创建者')),
              Text(creator['name'] ?? ''),
              Text('(手机号:${creator['phone'] ?? '-'})'),
            ]),
            Row(children: [
              Container(width: 90, child: Text('数据状态')),
              Text(itemStatus(op.status).text,
                style: TextStyle(color: op.status == 0 ? Colors.green : itemStatus(op.status).color),
              ),
            ]),
          ],
        ),
      ],
    );
  }
}
