import 'dart:convert';
import 'package:quiver/strings.dart';
import 'package:sorting/api/http_api.dart';
import 'package:sorting/dao/db_utils.dart';
import 'package:sorting/dao/package.dart';
import 'package:sorting/entity/package_entity.dart';
import 'package:sqflite/sqflite.dart';
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
    if (queryParams['isDeleted'] ?? false) {
      where.add('deleteAt ${(queryParams['isDeleted'] ?? false) ? 'is not null' : 'is null'}');
    }
    return DBUtils.fetchPage('package', queryParams,
        columns: queryParams['status'] != null ? ['code', 'destCode', 'createAt', 'operator'] : null,
        where: where,
        orderBy: 'strftime("%s", createAt) desc',
        convert: () => PackageEntity());
  }

  // 查询集包详情
  Future<Map<String, dynamic>> details(PackageEntity package) async {
    Map<String, dynamic> details = {};
    // 如果是服务器集包数据，就从服务器查询
    // 如果是本地集包数据且是上传成功状态并且可连接服务器，也从服务器查询；否则从本地库查询
    if ((package.status == null || (package.status == 0 && serverAvailable())) && package.deleteAt == null) {
      details = await api.get('/package/details', queryParameters: {'code': package.code});
      package = PackageEntity().fromJson(details['package']);
    } else {
      package = await _repo.findById(package.code);
      if (package.operator == getCurrentUser().id) {
        details['creator'] = getCurrentUser().toJson();
      }
      if (package.createAt != null && package.deleteOperator == getCurrentUser().id) {
        details['deleteOperator'] = getCurrentUser().toJson();
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
        await _softDelete(code);
      }
    } else {
      ret = await _softDelete(code);
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
        // 状态为上传失败时，实际为修改
        bool ok = await db.update('package',
          {'status': 1, 'destCode': package['destCode'], 'lastUpdate': getNowDateTimeString()},
          where: 'code = "${package['code']}"',
        ) > 0;
        return Result.from(ok);
      }
    } else {
      return Result.from(await db.insert('package', package) > 0);
    }
  }

  Future<Result> _softDelete(String code) async {
    var db = await getDB();
    PackageEntity package = await _repo.findById(code);
    if (package == null) {
      return Result.fail(code: 2, msg: '不存在的集包');
    }
    if (package.status == 4) {
      return Result.fail(code: 2, msg: '已删除');
    }
    return Result.from(await db.update('package', {
      'status': 4,
      'deleteAt': getNowDateTimeString(),
      'deleteOperator': getCurrentUser().id
    }, where: 'code = "$code"') > 0);
  }

  /// 同步到服务器
  Future<int> sync() async {
    const SIZE = 24;
    int pageNo = 0;
    Page page;
    do {
      page = await queryPage({'fromAll': '1', 'status': 1, 'page': ++pageNo, 'size': SIZE});
      if (page.total == 0) {
        break;
      }
      Result ret = await api.post('/package/batch', data: jsonEncode(page.content));
      var db = await getDB();
      Batch batch = db.batch();
      ret.data.forEach((status, packageCodes) {
        packageCodes.forEach((code) {
          batch.update('package', {'status': status, 'lastUpdate': getNowDateTimeString()}, where: 'code = "$code"');
        });
      });
      batch.commit();
    } while (page.content.length == SIZE);
    final total = (pageNo == 1 ? 0 : pageNo) * SIZE + page.content.length;
    return total;
  }
}