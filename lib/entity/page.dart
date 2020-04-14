part of api;

/// 分页数据
class Page {
  /// 记录总数 total >= content.length
  int total;
  /// 当前分页数据
  List<dynamic> content;

  Page({this.total, this.content});

  static fromMap(Map<String, dynamic> map) {
    return Page(total: map['total'], content: map['content']);
  }
}

