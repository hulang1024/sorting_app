import 'package:intl/intl.dart';
import 'package:sorting/generated/json/base/json_convert_content.dart';
import 'package:sqflite/sqflite.dart';

import '../api/http_api.dart';
import 'database.dart';

Future<Database> getDB() {
  return SortingDatabase.instance();
}

class DBUtils {
  static Future<T> findOne<T>(String table, {
    List<String> columns,
    where,
    List<dynamic> whereArgs,
    JsonConvert Function() convert}) async {
    var db = await getDB();
    List<Map<String, dynamic>> result = await db.query(table,
      columns: columns,
        where: where is List ? (where.isNotEmpty ? where.join(' and ') : null) : where,
      whereArgs: whereArgs,
    );
    return result.length > 0 ? convert().fromJson(result[0]) : null;
  }

  static Future<Page> fetchPage(String table, Map<String, dynamic> pageParams,
      {bool distinct,
        List<String> columns,
        where,
        List<dynamic> whereArgs,
        String groupBy,
        String having,
        String orderBy,
        JsonConvert Function() convert}) async {
    int pageNo = pageParams['page'];
    int size = pageParams['size'];
    var db = await getDB();
    where = where is List ? (where.isNotEmpty ? where.join(' and ') : null) : where;
    String sql = 'select count(1) as count from $table';
    if (where != null) {
      sql += ' where $where';
    }
    if (groupBy != null) {
      sql += ' group by $groupBy';
    }
    if (having != null) {
      sql += ' having $having';
    }
    int total = (await db.rawQuery(sql, whereArgs))[0]['count'];
    if (total == 0) {
      return Page(content: [], total: 0);
    }
    List<Map<String, dynamic>> result = await db.query(table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      orderBy: orderBy,
      offset: (pageNo - 1) * size,
      limit: size,);
    return Page(content: result.map((e) => convert().fromJson(e)).toList(), total: total);
  }
}

String getNowDateTimeString() {
  return DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
}