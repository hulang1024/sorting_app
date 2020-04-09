import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../api/http_api.dart';
import 'database.dart';

Future<Database> getDB() {
  return SortingDatabase.instance();
}

class DBUtils {
  static Future<Page> fetchPage(String table, Map<String, dynamic> pageParams,
      {bool distinct,
        List<String> columns,
        List<String> where,
        List<dynamic> whereArgs,
        String groupBy,
        String having,
        String orderBy}) async {
    int pageNo = pageParams['page'];
    int size = pageParams['size'];
    var db = await getDB();
    List<Map<String, dynamic>> result = await db.query(table,
      distinct: distinct,
      columns: columns,
      where: where.isNotEmpty ? where.join(' and ') : null,
      whereArgs: whereArgs,
      groupBy: groupBy,
      orderBy: orderBy,
      offset: (pageNo - 1) * size,
      limit: size,);
    return Page(content: result, total: null);
  }
}

String getNowDateTimeString() {
  return DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
}