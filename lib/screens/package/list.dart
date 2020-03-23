import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../widgets/network_data_list.dart';
import 'details.dart';

// 包裹列表
class PackageListView extends StatefulWidget {
  PackageListView({Key key, this.height, this.queryParams, this.onData}) : super(key: key);

  final double height;
  final Map<String, dynamic> queryParams;
  final ValueChanged onData;

  @override
  State<StatefulWidget> createState() => PackageListViewState();
}

class PackageListViewState extends State<PackageListView> {
  final GlobalKey<NetworkDataListState> networkDataListKey = GlobalKey();

  void query([queryParams]) {
    networkDataListKey.currentState.query(queryParams);
  }

  @override
  Widget build(BuildContext context) {
    return NetworkDataList(
      key: networkDataListKey,
      options: Options(
        height: widget.height,
        url: '/package/page',
        queryParams: widget.queryParams,
        noData: Text('未查询到包裹'),
        rowBuilder: (package, [index, context]) {
          return ListTile(
            title: Text(package['code'], style: TextStyle(fontSize: 14)),
            subtitle: Text(package['destAddress'] + '\n' + package['operatorName'] + '(${package['operatorPhone']})',
                style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.fromLTRB(0, 4, 0, 4),
            trailing: Container(child: Icon(Icons.keyboard_arrow_right)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PackageDetailsScreen(package)));
            },
          );
        },
        onData: widget.onData,
      ),
    );
  }
}
