import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../api/http_api.dart';
import '../item/details.dart';

class PackageDetailsPage extends StatefulWidget {
  PackageDetailsPage(this.package, [this.isDeleted = false]);
  final Map package;
  final bool isDeleted;
  @override
  State<StatefulWidget> createState() => PackageDetailsPageState(package, isDeleted);
}

class PackageDetailsPageState extends State<PackageDetailsPage> {
  PackageDetailsPageState(this.package, this.isDeleted);

  final Map package;
  final bool isDeleted;
  Map details = {
    'package': null,
    'creator': {},
    'deleteOperator': {},
    'items': []
  };

  @override
  void initState() {
    super.initState();

    details['package'] = package;
    api.get(isDeleted ? '/deleted_package/details' : '/package/details',
      queryParameters: {'code': package['code']}).then((ret) {
      setState(() {
        details = ret.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var package = details['package'];
    var creator = details['creator'] ?? {};
    var deleteOperator = details['deleteOperator'] ?? {};
    var items = details['items'];

    return Scaffold(
      appBar: AppBar(
        title: Text('包裹详情'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Divider(),
          Container(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(width: 100, child: Text('包裹编号')),
                    Text(package['code']),
                  ]
                ),
                Row(
                  children: [
                    Container(width: 100, child: Text('目的地编号')),
                    Text(package['destCode']),
                  ]
                ),
                Row(
                  children: [
                    Container(width: 100, child: Text('创建者')),
                    Text(creator['name'] ?? '-'),
                    Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: new Text('(手机号:${creator['phone'] ?? '-'})'))
                  ]
                ),
                Row(
                  children: [
                    Container(width: 100, child: Text('创建时间')),
                    Text(creator['createAt']),
                  ]
                ),
                isDeleted ? Row(
                  children: [
                    Container(width: 100, child: Text('删除者')),
                    Text(deleteOperator['name'] ?? '-'),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: new Text('(手机号:${deleteOperator['phone'] ?? '-'})')
                    )
                  ]
                ) : SizedBox(),
                isDeleted ? Row(
                  children: [
                    Container(width: 100, child: Text('删除时间')),
                    Text(package['deleteAt']),
                  ]
                ) : SizedBox()
              ],
            )
          ),
          isDeleted ? SizedBox() : Column(
            children: [
              Divider(),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                child: Text(
                  '快件 （${items.length}个）',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              Column(
                children: [
                  SizedBox(
                    height: 230,
                    child: new ListView.builder(
                      itemCount: items.length,
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                      itemBuilder: (BuildContext context, int index) {
                        var item = items[index];
                        return new ListTile(
                          title: new Text(item['code']),
                          contentPadding: EdgeInsets.fromLTRB(0, 0, 2, 0),
                          trailing: RaisedButton(
                            child: Text('详情'),
                            onPressed: () {
                              Navigator.push(context, new MaterialPageRoute(
                                  builder: (context) => ItemDetailsPage(item)
                              ));
                            }
                          )
                        );
                      }
                    )
                  )
                ]
              )
            ]
          )
        ]
      )
    );
  }


}