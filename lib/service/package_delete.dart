import 'package:quiver/strings.dart';
import 'package:sorting/api/http_api.dart';
import 'package:sorting/dao/db_utils.dart';
import 'package:sorting/dao/package.dart';
import 'package:sorting/entity/package_entity.dart';
import '../session.dart';

class PackageDeleteService {
  PackageRepo _repo = PackageRepo();

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

  /// 删除集包
  Future<Result> delete(String code) async {
    Result ret;
    switch (api.isAvailable) {
      case true:
        ret = await api.delete('/package', queryParameters: {'code': code}).catchError((_) => null);
        if (ret == null) {
          continue OFFLINE;
        }
        if (ret.isOk) {
          await _softDelete(code, 0);
        }
        break;

      OFFLINE:
      case false:
        ret = await _softDelete(code, 1);
        break;
    }

    return ret;
  }

  Future<Result> _softDelete(String code, int status) async {
    var db = await getDB();

    if (await DBUtils.findOne('package_delete_op', where: 'code = "$code"') != null) {
      return Result.fail(code: 2, msg: '已删除');
    }

    bool hasItems = (await db.rawQuery('''
      select count(1) as count from package_item_rel r
      where r.packageCode = "$code"
    '''))[0]['count'] > 0;
    if (hasItems) {
      return Result.fail(code: 3, msg: '集包包含快件，不能删除');
    }
    PackageEntity package = await _repo.findById(code);
    return db.transaction((txn) async {
      final now = getNowDateTimeString();
      bool ok;
      if (package != null) {
        ok = await txn.update('package', {'status': 4, 'lastUpdate': now}, where: 'code = "$code"') > 0;
        if (!ok) {
          return Result.fail();
        }
        // 如果是离线删除，并且要删除的集包的状态为未上传
        if (status == 1 && package.status == 1) {
          // 则删除操作状态设为删除完成，以跳过之后的请求服务器删除
          status = 0;
        }
      }
      ok = await txn.insert('package_delete_op',
          {'code': code, 'operator': getCurrentUser().id, 'deleteAt': now, 'status': status}) > 0;
      return Result.ok();
    });
  }
}