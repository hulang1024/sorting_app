import 'package:quiver/strings.dart';
import 'package:sorting/api/http_api.dart';
import 'package:sorting/dao/db_utils.dart';
import 'package:sorting/dao/package.dart';
import 'package:sorting/entity/package_entity.dart';
import '../session.dart';

class PackageService {
  PackageRepo _repo = PackageRepo();

  /// 查询集包
  Future<Page> queryPage(Map<String, dynamic> queryParams) async {
    List<String> where = [];
    if (!equalsIgnoreCase(queryParams['fromAll'], "1")) {
      where.add('operator = ${getCurrentUser().id}');
    }
    if (isNotEmpty(queryParams['code'])) {
      where.add('code like "${queryParams['code']}%"');
    }
    if (queryParams['status'] != null) {
      where.add('status = ${queryParams['status']}');
    }
    if (queryParams['isDeleted'] != null) {
      where.add('status ${queryParams['isDeleted'] ? '=4' : '!=4'}');
    }
    return DBUtils.fetchPage('package',
        pageParams: queryParams,
        where: where,
        orderBy: 'strftime("%s", createAt) desc',
        convert: () => PackageEntity());
  }

  // 查询集包详情
  Future<Map<String, dynamic>> details(PackageEntity package) async {
    Map<String, dynamic> details = {};
    // 如果是服务器集包数据，就从服务器查询
    // 如果是本地集包数据且是上传成功状态并且可连接服务器，也从服务器查询；否则从本地库查询
    if ((package.status == null || (package.status == 0 && serverAvailable())) && package.status != 4) {
      details = await api.get('/package/details', queryParameters: {'code': package.code});
      package = PackageEntity().fromJson(details['package']);
    } else {
      if (package.status == 4) {
        Map<String, dynamic> deleteInfo = {};
        deleteInfo.addAll(await DBUtils.findOne('package_delete_op', where: 'code = "${package.code}"'));
        if (deleteInfo['operator'] == getCurrentUser().id) {
          deleteInfo['operatorInfo'] = getCurrentUser().toJson();
        }
        details['deleteInfo'] = deleteInfo;
      }
      package = await _repo.findById(package.code);
      if (package != null) {
        if (package.operator == getCurrentUser().id) {
          details['creator'] = getCurrentUser().toJson();
        }
      }
    }
    details['package'] = package;
    return details;
  }

  /// 增加集包
  Future<Result> add(Map<String, dynamic> package, Map<String, dynamic> smartCreateSpec) async {
    Result ret;
    // 先判断服务器是否可用
    if (serverAvailable()) {
      // 可用，给服务器发送建包请求
      ret = await api.post('/package', data: package, queryParameters: smartCreateSpec);

      // 服务器建包成功
      if (ret.isOk) {
        // 在本地建包
        Result ret = await _save({...package, 'status': 0/*表示成功*/}, smartCreateSpec);
        // 这种情况应该不会发生：服务器建包成功但本地建包失败由于本地已存在相同编号。还是处理下
        if (ret.code == 2) {
          var db = await getDB();
          await db.update('package',
            {'status': 0, 'lastUpdate': getNowDateTimeString()},
            where: 'code = ${package['code']}',
          );
        }
      } else {
        // 服务器建包失败，什么都不做
      }
    } else {
      if (smartCreateSpec != null) {
        return Result.fail(msg: '连接服务器失败，无法智能建包');
      }
      ret = await _save({...package, 'status': 1/*表示未同步到服务器*/}, smartCreateSpec);
    }

    return ret;
  }

  /// 删除集包
  Future<Result> delete(String code) async {
    Result ret;
    if (serverAvailable()) {
      ret = await api.delete('/package', queryParameters: {'code': code});
      if (ret.isOk) {
        await _softDelete(code, 0);
      }
    } else {
      ret = await _softDelete(code, 1);
    }

    return ret;
  }

  Future<Result> _save(Map<String, dynamic> package, Map<String, dynamic> smartCreateSpec) async {
    package['createAt'] = getNowDateTimeString();
    package['operator'] = getCurrentUser().id;
    var db = await getDB();
    var oldPackage = await _repo.findById(package['code']);
    if (oldPackage != null) {
      if ([0, 1].contains(oldPackage.status)) {
        return Result.fail(code: 2, msg: '集包已存在');
      } else {
        bool ok = await db.update('package',
          {'status': package['status'], 'destCode': package['destCode'], 'lastUpdate': getNowDateTimeString()},
          where: 'code = "${package['code']}"',
        ) > 0;
        return Result.from(ok);
      }
    } else {
      return Result.from(await db.insert('package', package) > 0);
    }
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
      }
      ok = await txn.insert('package_delete_op',
          {'code': code, 'operator': getCurrentUser().id, 'deleteAt': now, 'status': status}) > 0;
      return Result.from(ok);
    });
  }
}