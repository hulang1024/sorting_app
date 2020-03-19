import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../api/http_api.dart';

class ItemDetailsPage extends StatefulWidget {
  final Map item;

  ItemDetailsPage(this.item);

  @override
  State<StatefulWidget> createState() => ItemDetailsPageState(item);
}

class ItemDetailsPageState extends State<ItemDetailsPage> {
  ItemDetailsPageState(this.item);

  final Map item;
  Map details = {
    'item': {},
    'destAddress': {}
  };

  @override
  void initState() {
    super.initState();
    details['item'] = item;
    api.get('/item/details',
        queryParameters: {'code': item['code']}).then((ret) {
      setState(() {
        details = ret.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var item = details['item'];
    var destAddress = details['destAddress'] ?? {};

    return Scaffold(
        appBar: AppBar(
          title: Text('快件详情'),
          centerTitle: true,
        ),
        body: Column(
            children: [
              Container(
                  padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                  child: Column(
                    children: [
                      Row(
                          children: [
                            Container(width: 90, child: Text('快件编号')),
                            Text(item['code']),
                          ]
                      ),
                      Row(
                          children: [
                            Container(width: 90, child: Text('目的地')),
                            Container(width: 200, child: Text(destAddress['address'] ?? ''))
                          ]
                      ),
                      Row(
                          children: [
                            Container(width: 90, child: Text('目的地编号')),
                            Text(item['destCode']),
                          ]
                      ),
                      Row(
                          children: [
                            Container(width: 90, child: Text('创建时间')),
                            Text(item['createAt']),
                          ]
                      ),
                      item['packTime'] == null ? SizedBox() : Row(
                          children: [
                            Container(width: 90, child: Text('打包时间')),
                            Text(item['packTime']),
                          ]
                      )
                    ],
                  )
              )
            ]
        )
    );
  }


}