import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../package/details.dart';
import '../screen.dart';
import '../../api/http_api.dart';

class ItemDetailsScreen extends Screen {
  ItemDetailsScreen(this.item) : super(title: '快件详情');

  final Map item;

  @override
  State<StatefulWidget> createState() => ItemDetailsScreenState();
}

class ItemDetailsScreenState extends ScreenState<ItemDetailsScreen> {
  Map details = {'item': {}, 'destAddress': {}};

  @override
  void initState() {
    super.initState();
    details['item'] = widget.item;
    api.get('/item/details', queryParameters: {'code': widget.item['code']}).then((ret) {
      setState(() {
        details = ret.data;
      });
    });
  }

  @override
  Widget render(BuildContext context) {
    var item = details['item'];
    var destAddress = details['destAddress'] ?? {};

    return ListView(
      children: [
        Column(
          children: [
            Row(children: [
              Container(width: 90, child: Text('快件编号')),
              Text(item['code']),
            ]),
            Row(children: [
              Container(width: 90, child: Text('目的地')),
              Container(width: 200, child: Text(destAddress['address'] ?? '')),
            ]),
            Row(children: [
              Container(width: 90, child: Text('目的地编号')),
              Text(item['destCode']),
            ]),
            Row(children: [
              Container(width: 90, child: Text('创建时间')),
              Text(item['createAt']),
            ]),
            Row(children: [
              Container(width: 90, child: Text('分配状态')),
              Text(
                item['packTime'] == null ? '未分配 ' : '已分配 ',
                style: TextStyle(color: item['packTime'] == null ? Colors.grey : Colors.green),
              ),
            ]),
            if (item['packTime'] != null) ...[
              Row(children: [
                Container(width: 90, child: Text('分配时间')),
                Text(item['packTime']),
              ]),
              Row(children: [
                Container(width: 90, child: Text('集包编号')),
                Text.rich(
                  TextSpan(
                    text: details['packageCode'],
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        push(PackageDetailsScreen({'code': details['packageCode']}));
                      },
                  ),
                ),
              ]),
            ],
          ],
        ),
      ],
    );
  }
}
