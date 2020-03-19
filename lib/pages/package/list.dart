import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sorting/widgets/network_data_list.dart';
import 'details.dart';

// 包裹列表
class PackageListView extends StatefulWidget {
  PackageListView({Key key, this.height, this.queryParams}) : super(key: key);
  final double height;
  final Map<String, dynamic> queryParams;

  @override
  State<StatefulWidget> createState() => new PackageListViewState(this.height, this.queryParams);
}

class PackageListViewState extends State<PackageListView> {
  final GlobalKey<NetworkDataListState> networkDataListKey = new GlobalKey();

  PackageListViewState(this.height, this.queryParams);

  double height;
  Map queryParams;

  void query([queryParams]) {
    networkDataListKey.currentState.query(queryParams);
  }

  @override
  Widget build(BuildContext context) {
    return NetworkDataList(
      key: networkDataListKey,
      options: new Options(
        height: height,
        url: '/package/page',
        queryParams: queryParams,
        noData: Text('未查询到包裹'),
        rowBuilder: (package, [index, context]) {
          return ListTile(
              title: Text(package['code']),
              subtitle: Text(package['createAt']),
              contentPadding: EdgeInsets.fromLTRB(0, 0, 2, 0),
              trailing: RaisedButton(
                  child: Text('详情'),
                  onPressed: () {
                    Navigator.push(context, new MaterialPageRoute(
                        builder: (context) => PackageDetailsPage(package)
                    ));
                  }
              )
          );
        }
      )
    );
  }
}