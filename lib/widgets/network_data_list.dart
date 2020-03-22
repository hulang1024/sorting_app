import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../api/http_api.dart';

class Options {
  double height;
  @required
  String url;
  Map<String, dynamic> queryParams;
  Widget noData;
  @required
  RowBuilder rowBuilder;
  ValueChanged onData;

  Options({this.height, this.url, this.queryParams, this.noData, this.rowBuilder, this.onData});
}

class NetworkDataList extends StatefulWidget {
  NetworkDataList({Key key, @required this.options}) : super(key: key);

  final Options options;

  @override
  State<StatefulWidget> createState() => NetworkDataListState();
}

typedef RowBuilder = Widget Function(Map row, int index, BuildContext context);

class NetworkDataListState extends State<NetworkDataList> {
  ScrollController listController = ScrollController();
  Map<String, dynamic> _queryParams = {};
  bool _loading = true;
  bool _more = true;
  int _pageNo = 1;
  int _pageSize = 5;
  int _total = 0;
  List _list = [];

  @override
  void initState() {
    super.initState();
    _queryParams = widget.options.queryParams ?? {};
    _fetch();
    listController.addListener(() {
      if (listController.position.pixels == listController.position.maxScrollExtent && !_loading && _more) {
        _pageNo++;
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
    if (_list.length == 0 && !_loading) {
      return Center(child: widget.options.noData ?? Text('未查询到数据'));
    } else {
      return listView();
    }
  }

  Widget listView() {
    return Column(
      children: [
        SizedBox(
          height: widget.options.height ?? 300,
          child: ListView.builder(
            controller: listController,
            itemCount: _list.length + 1,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
            itemBuilder: (BuildContext context, int index) {
              if (_list.length == 0) return null;
              if (index == _list.length) {
                if (!_more) return null;
                return Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 8.0),
                    width: 32.0,
                    height: 32.0,
                    child: Opacity(opacity: _loading ? 1 : 0, child: CircularProgressIndicator()),
                  ),
                );
              }

              return widget.options.rowBuilder(_list[index], index, context);
            },
          ),
        ),
        Text('共$_total个记录'),
      ],
    );
  }

  void query([_queryParams]) {
    _list.clear();
    _pageNo = 1;
    if (_queryParams != null) {
      this._queryParams.addAll(_queryParams);
    }
    setState(() {
      _more = true;
    });
    _fetch();
  }

  void _fetch() async {
    setState(() {
      _loading = true;
    });
    Map<String, dynamic> _queryParams = {};
    _queryParams.addAll(this._queryParams);
    _queryParams.addAll({'page': _pageNo, 'size': _pageSize});
    var ret = await api.get(widget.options.url, queryParameters: _queryParams);
    if (widget.options.onData != null) {
      widget.options.onData(ret.data);
    }
    setState(() {
      List retList = (ret.data['content'] as List);
      retList.forEach((e) => _list.add(e));
      _total = ret.data['total'];
      if (retList.length < _pageSize) {
        _more = false;
      }
      _loading = false;
    });
  }
}
