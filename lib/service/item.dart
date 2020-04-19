import 'package:quiver/strings.dart';
import 'package:sorting/api/http_api.dart';
import 'package:sorting/dao/db_utils.dart';
import 'package:sorting/entity/item_entity.dart';
import '../session.dart';

class ItemService {
  /// 查询快件记录
  Future<Page> queryPage(Map<String, dynamic> queryParams) async {
    List<String> where = [];
    if (!equalsIgnoreCase(queryParams['fromAll'], "1")) {
      where.add('operator = ${getCurrentUser().id}');
    }
    where.add('packageCode = "${queryParams['packageCode']}"');
    return DBUtils.fetchPage('package_item_rel',
      pageParams: queryParams,
      columns: ['itemCode code', 'status'],
      where: where,
      orderBy: 'strftime("%s", createAt) desc',
      convert: () => ItemEntity());
  }
}