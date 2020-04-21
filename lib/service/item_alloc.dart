import 'package:quiver/strings.dart';
import 'package:sorting/api/http_api.dart';
import 'package:sorting/dao/db_utils.dart';
import 'package:sorting/dao/package.dart';
import 'package:sorting/entity/package_item_op_entity.dart';
import 'package:sorting/entity/package_item_rel_entity.dart';
import '../session.dart';

class ItemAllocService {
  PackageRepo _packageRepo = PackageRepo();

  /// 查询快件操作记录
  Future<Page> queryPage(Map<String, dynamic> queryParams) async {
    List<String> where = [];
    if (!equalsIgnoreCase(queryParams['fromAll'], "1")) {
      where.add('operator = ${getCurrentUser().id}');
    }
    if (queryParams['opType'] != null) {
      where.add('opType = ${queryParams['opType']}');
    }
    return DBUtils.fetchPage('package_item_op',
      pageParams: queryParams,
      where: where,
      orderBy: 'strftime("%s", opTime) desc',
      convert: () => PackageItemOpEntity());
  }

  // 查询操作详情
  Future<Map<String, dynamic>> details(int id) async {
    Map<String, dynamic> details = {};
    var op = await DBUtils.findOne('package_item_op', where: 'id = $id', convert: () => PackageItemOpEntity());
    details['op'] = op;
    if (op.operator == getCurrentUser().id) {
      details['creator'] = getCurrentUser().toJson();
    }
    return details;
  }

  Future<Result> operate(int opType, formData) async {
    Result ret;
    if (serverAvailable()) {
      ret = await api.post('/package_item_op/${opType == 1 ? 'add_item' : 'delete_item'}', queryParameters: formData);
      if (ret.isOk) {
        await (opType == 1 ? _addItem : _delItem)(formData['packageCode'], formData['itemCode'], 0);
      }
    } else {
      var package = await _packageRepo.findById(formData['packageCode']);
      if (package?.status == 4) {
        return Result.fail(code: 2, msg: '该集包已删除');
      }
      ret = await (opType == 1 ? _addItem : _delItem)(formData['packageCode'], formData['itemCode'], 1);
    }
    return ret;
  }

  Future<Result> _addItem(String packageCode, String itemCode, int status) async {
    var db = await getDB();
    var packageItemRel = await DBUtils.findOne('package_item_rel', where: 'itemCode = $itemCode', convert: () => PackageItemRelEntity());
    if (packageItemRel != null) {
      if (packageItemRel.packageCode == packageCode) {
        return Result.fail(code: 5, msg: '快件早已加到集包');
      } else {
        return Result.fail(code: 5, msg: '快件早已加到其它集包');
      }
    }
    return await db.transaction((txn) async {
      PackageItemRelEntity rel = PackageItemRelEntity();
      rel.packageCode = packageCode;
      rel.itemCode = itemCode;
      rel.operator = getCurrentUser().id;
      rel.createAt = getNowDateTimeString();
      rel.status = status;
      bool ok = await txn.insert('package_item_rel', rel.toJson()) > 0;
      if (!ok) {
        return Result.fail();
      }

      PackageItemOpEntity op = PackageItemOpEntity();
      op.packageCode = packageCode;
      op.itemCode = itemCode;
      op.opType = 1;
      op.opTime = getNowDateTimeString();
      op.operator = getCurrentUser().id;
      op.status = status;
      return Result.from(await txn.insert('package_item_op', op.toJson()) > 0);
    });
  }

  Future<Result> _delItem(String packageCode, String itemCode, int status) async {
    var db = await getDB();
    return await db.transaction((txn) async {
      await txn.delete('package_item_rel', where: 'packageCode = "$packageCode" and itemCode = "$itemCode"');

      PackageItemOpEntity op = PackageItemOpEntity();
      op.packageCode = packageCode;
      op.itemCode = itemCode;
      op.opType = 2;
      op.opTime = getNowDateTimeString();
      op.operator = getCurrentUser().id;
      op.status = status;
      return Result.from(await txn.insert('package_item_op', op.toJson()) > 0);
    });
  }
}