import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../api/http_api.dart';

typedef LoadDataCallback = Future<Page> Function(Map<String, dynamic> queryParams);

/// 数据列表视图的选项
class Options {
  double height;
  LoadDataCallback loadData;
  String url;
  Map<String, dynamic> queryParams;
  Widget noData;
  @required
  RowBuilder rowBuilder;
  ValueChanged<Page> onData;

  Options({this.height, this.loadData, this.url, this.queryParams, this.noData, this.rowBuilder, this.onData});
}

/// 数据列表视图
class DataListView extends StatefulWidget {
  DataListView({Key key, @required this.options}) : super(key: key);

  final Options options;

  @override
  State<StatefulWidget> createState() => DataListViewState();
}

typedef RowBuilder = Widget Function(Map row, int index, BuildContext context);

class DataListViewState extends State<DataListView> {
  ScrollController listController = ScrollController();
  Map<String, dynamic> _queryParams = {};
  bool _loading = true;
  bool _more = true;
  int _pageNo = 1;
  int _pageSize = 10;
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
      return Center(
        child: Container(
          margin: EdgeInsets.only(top: 16),
          child: widget.options.noData ?? Text('未查询到数据'),
        ),
      );
    } else {
      return listView();
    }
  }

  Widget listView() {
    return Column(
      children: [
        Container(
          height: widget.options.height ?? 304,
          child: ListView.builder(
            controller: listController,
            itemCount: _list.length + 1,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            itemBuilder: (BuildContext context, int index) {
              if (_list.length == 0 || index == _list.length) {
                if (!_more) return null;
                return Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 8.0),
                    width: 32.0,
                    height: 32.0,
                    child: Opacity(
                      opacity: _loading ? 1 : 0,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              return widget.options.rowBuilder(_list[index], index, context);
            },
          ),
        ),
        //if(_total != null) Text('共 $_total 个记录', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
    // 设为加载中
    setState(() {
      _loading = true;
    });
    // 将分页参数增加到查询参数
    Map<String, dynamic> queryParams = {};
    queryParams.addAll(this._queryParams);
    queryParams.addAll({'page': _pageNo, 'size': _pageSize});

    var load = (Page page) {
      setState(() {
        page.content.forEach((e) => _list.add(e));
        _total = page.total;
        if (page.content.length < _pageSize) {
          _more = false;
        }
        _loading = false;
      });
    };

    if (widget.options.loadData != null) {
      Page page = await widget.options.loadData(queryParams);
      load(page);
      setState(() {
        _loading = false;
      });
    } else {
      api.get(widget.options.url, queryParameters: queryParams).then((ret) {
        if (widget.options.onData != null) {
          widget.options.onData(ret.data);
        }
        load(ret.data);
      }).catchError((_) {
        setState(() {
          _loading = false;
        });
      }, test: (error) => true);
    }
  }
}
