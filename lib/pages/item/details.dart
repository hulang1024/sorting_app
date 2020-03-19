import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ItemDetailsPage extends StatefulWidget {
  final Map item;

  ItemDetailsPage(this.item);

  @override
  State<StatefulWidget> createState() => ItemDetailsPageState(item);
}

class ItemDetailsPageState extends State<ItemDetailsPage> {
  final Map item;

  ItemDetailsPageState(this.item);

  @override
  Widget build(BuildContext context) {
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
                            Container(width: 100, child: Text('快件编号')),
                            Text(item['code']),
                          ]
                      ),
                      Row(
                          children: [
                            Container(width: 100, child: Text('目的地编号')),
                            Text(item['destCode']),
                          ]
                      ),
                      Row(
                          children: [
                            Container(width: 100, child: Text('打包时间')),
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