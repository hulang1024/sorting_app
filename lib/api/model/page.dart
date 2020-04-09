part of api;

/// 分页数据
class Page {
  int _total;
  List<dynamic> _content;

  /// 记录总数 total >= content.length
  int get total => _total;
  /// 当前分页数据
  List<dynamic> get content => _content;

  Page({total, content}) : _total = total, _content = content;

  static fromMap(Map<String, dynamic> map) {
    return new Page(total: map['total'], content: map['content']);
  }
}

