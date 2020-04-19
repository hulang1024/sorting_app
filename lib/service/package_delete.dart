import 'package:quiver/strings.dart';
import 'package:sorting/api/http_api.dart';
import 'package:sorting/dao/db_utils.dart';
import '../session.dart';

class PackageDeleteService {
  /// 查询集包删除记录
  Future<Page> queryPage(Map<String, dynamic> queryParams) async {
    List<String> where = [];
    if (!equalsIgnoreCase(queryParams['fromAll'], "1")) {
      where.add('operator = ${getCurrentUser().id}');
    }
    if (queryParams['status'] != null) {
      where.add('status = ${queryParams['status']}');
    }
    return DBUtils.fetchPage('package_delete_op',
        pageParams: queryParams,
        where: where,
        orderBy: 'strftime("%s", deleteAt) desc');
  }
}