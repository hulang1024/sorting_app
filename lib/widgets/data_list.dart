import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sorting/generated/json/base/json_convert_content.dart';
import '../api/http_api.dart';

/// 数据列表视图。
class DataListView extends StatefulWidget {
  DataListView({
    Key key,
    this.height,
    this.loadData,
    this.url,
    this.queryParams,
    this.convert,
    this.dataFilter,
    this.onData,
    @required this.rowBuilder,
    @required this.noDataText,
    this.showPagination = true,
  }) : assert(loadData != null || url != null),
        super(key: key);

  /// 列表容器高度。
  /// 
  /// 如果此属性为null，则组件会自动计算出一个合适的值作为列表容器的高度。
  final double height;

  /// 数据源函数。
  ///
  /// 如果此属性非null，则将调用此函数的返回值作为列表的数据源。
  /// 如果此属性为null，则使用[url]属性。
  final Future<Page> Function(Map<String, dynamic> queryParams) loadData;

  /// 数据源的URL。
  ///
  /// 如果此属性非null，则请求该URL获得列表的数据源，
  /// 如果此属性为null，则使用[loadData]属性。
  final String url;

  /// 查询参数。
  /// 
  /// 请求[url]时或调用[loadData]时传递的参数。
  final Map<String, dynamic> queryParams;

  /// 数据格式转换函数。
  ///
  /// 该函数应返回[JsonConvert]，其用于将Map转换为其它类型，
  /// 如果此属性非null，那么会在用数据源渲染列表之前，调用此函数作[Iterable.map]产生数据源。
  final JsonConvert Function() convert;

  /// 数据过滤器。
  ///
  /// 如果此属性非null，在调用[convert]之前，调用此函数，然后将其返回值作为新的数据源。
  final Page Function(Page page) dataFilter;

  /// 数据源渲染之后的回调。
  final ValueChanged<Page> onData;

  /// 数据列表行渲染函数。
  final Widget Function(dynamic row, int index, BuildContext context) rowBuilder;

  /// 数据源为空时，显示的文本字符串。
  final String noDataText;

  /// 是否显示分页信息。
  final bool showPagination;

  @override
  State<StatefulWidget> createState() => DataListViewState();
}

class DataListViewState extends State<DataListView> {
  ScrollController _listController = ScrollController();
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
    _queryParams = widget.queryParams ?? {};
    _fetch();
    _listController.addListener(() {
      if (_listController.position.pixels == _listController.position.maxScrollExtent && !_loading && _more) {
        _pageNo++;
        _fetch();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _listController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_list.length == 0 && !_loading) {
      return Center(
        child: Container(
          margin: EdgeInsets.only(top: 16),
          child: Text(widget.noDataText,
            style: TextStyle(color: Colors.black87, fontSize: 14),
          ),
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
          height: (widget.height ?? 304) - 19,
          child: ListView.builder(
            controller: _listController,
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

              return widget.rowBuilder(_list[index], index, context);
            },
          ),
        ),
        if (widget.showPagination)
          InkWell(
            onTap: () {
              query();
            },
            child: Text('共 $_total 个记录', style: TextStyle(color: Colors.grey, fontSize: 13))),
      ],
    );
  }

  /// 查询数据
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

    if (widget.loadData != null) {
      _load(await widget.loadData(queryParams));
    } else {
      api.get(widget.url, queryParameters: queryParams).then((ret) {
        _load(Page.fromMap(ret));
      }).catchError((_) {
        setState(() {
          _loading = false;
        });
      }, test: (error) => true);
    }
  }

  void _load(Page page) {
    // 应用数据转换器
    if (widget.convert != null) {
      page.content = page.content.map((e) => widget.convert().fromJson(e)).toList();
    }
    // 应用数据过滤器
    if (widget.dataFilter != null) {
      page = widget.dataFilter(page);
    }

    setState(() {
      page.content.forEach((e) => _list.add(e));
      _total = page.total;
      if (page.content.length < _pageSize) {
        _more = false;
      }

      _loading = false;
    });

    if (widget.onData != null) {
      widget.onData(page);
    }
  }
}
