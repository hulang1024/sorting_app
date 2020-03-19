import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../api/http_api.dart';

class Options {
  double height;
  @required String url;
  Map<String, dynamic> queryParams;
  Widget noData;
  @required RowBuilder rowBuilder;

  Options({this.height, this.url, this.queryParams, this.noData, this.rowBuilder});
}

class NetworkDataList extends StatefulWidget {
  NetworkDataList({
    Key key,
    @required this.options
  }) : super(key: key);

  final Options options;

  @override
  State<StatefulWidget> createState() => new NetworkDataListState(this.options);
}

typedef RowBuilder = Widget Function(Map row, int index, BuildContext context);

class NetworkDataListState extends State<NetworkDataList> {
  NetworkDataListState(this.options);

  Options options;

  ScrollController listController = new ScrollController();
  bool loading = true, more = true;
  int pageNo = 1;
  Map<String, dynamic> queryParams = {};
  int pageSize = 5;
  int total = 0;
  List list = [];

  @override
  void initState() {
    super.initState();
    _fetch();
    queryParams = options.queryParams ?? {};
    listController.addListener(() {
      if (listController.position.pixels == listController.position.maxScrollExtent && !loading && more) {
        pageNo++;
        _fetch();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    listController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (list.length == 0 && !loading) {
      return Center(child: options.noData ?? Text('未查询到数据'));
    } else {
      return listView();
    }
  }

  Widget listView() {
    return Column(
      children: [
        SizedBox(
          height: options.height ?? 300,
          child: new ListView.builder(
            controller: listController,
            itemCount: list.length + 1,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
            itemBuilder: (BuildContext context, int index) {
              if (list.length == 0) return null;
              if (index == list.length) {
                if (!more) return null;
                return new Center(
                  child: new Container(
                    margin: const EdgeInsets.only(top: 8.0),
                    width: 32.0,
                    height: 32.0,
                    child: new Opacity(
                        opacity: loading ? 1 : 0,
                        child: CircularProgressIndicator()
                    ),
                  ),
                );
              }

              return options.rowBuilder(list[index], index, context);
            }
          )
        ),
        new Text('共$total个')
      ]
    );
  }

  void query([queryParams]) {
    list.clear();
    pageNo = 1;
    if (queryParams != null) {
      this.queryParams.addAll(queryParams);
    }
    setState(() {
      more = true;
    });
    _fetch();
  }

  void _fetch() async {
    setState(() {
      loading = true;
    });
    Map<String, dynamic> queryParams = {};
    queryParams.addAll(this.queryParams);
    queryParams.addAll({'page': pageNo, 'size': pageSize});
    var ret = await api.get(options.url, queryParameters: queryParams);
    setState(() {
      List retList = (ret.data['content'] as List);
      retList.forEach((e) => list.add(e));
      total = ret.data['total'];
      if (retList.length < pageSize) {
        more = false;
      }
      loading = false;
    });
  }

}