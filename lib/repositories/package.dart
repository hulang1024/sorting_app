import 'dart:async';
import 'package:quiver/strings.dart';
import 'package:sqflite/sqflite.dart';
import '../api/http_api.dart';
import '../user.dart';
import 'db_utils.dart';
import 'dart:convert';

abstract class PackageRepo {
  Future<Page> page(Map<String, dynamic> queryParams);
  Future<Map<String, dynamic>> details(String code);
}

class PackageLocalRepo implements PackageRepo {
  @override
  Future<Page> page(Map<String, dynamic> queryParams) async {
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

    return DBUtils.fetchPage('package', queryParams,
      columns: queryParams['status'] != null ? ['code', 'destCode', 'createAt', 'operator'] : null,
      where: where,
      orderBy: 'strftime("%s", createAt) desc',);
  }

  @override
  Future<Map<String, dynamic>> details(String code) async {
    var db = await getDB();
    Map<String, dynamic> details = {};

    details['package'] = await findById(code);
    if (details['package']['operator'] == getCurrentUser().id) {
      details['creator'] = {'name': getCurrentUser().name, 'phone': getCurrentUser().phone};
    }
    return details;
  }

  Future<Result> add(Map<String, dynamic> package, Map<String, dynamic> smartCreateSpec) async {
    package['createAt'] = getNowDateTimeString();
    package['operator'] = getCurrentUser().id;
    var db = await getDB();
    var oldPackage = await findById(package['code']);
    if (oldPackage != null) {
      if ([0, 1].contains(oldPackage['status'])) {
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

  Future<Map<String, dynamic>> findById(String code) async {
    var db = await getDB();
    var results = await db.query('package', where: 'code = "$code"');
    return results.length == 1 ? results[0] : null;
  }
}

class PackageRemoteRepo implements PackageRepo {
  @override
  Future<Page> page(Map<String, dynamic> queryParams) async {
    return (await api.get('/package/page', queryParameters: queryParams)).data;
  }

  @override
  Future<Map<String, dynamic>> details(String code) async {
    return (await api.get('/package/details', queryParameters: {'code': code})).data;
  }

  Future<Result> add(Map<String, dynamic> package, Map<String, dynamic> smartCreateSpec) async {
    return (await api.post('/package', data: package, queryParameters: smartCreateSpec)).data;
  }
}

class PackageAddRepo {
  PackageRemoteRepo _packageRemoteRepo = PackageRemoteRepo();
  PackageLocalRepo _packageLocalRepo = PackageLocalRepo();

  Future<Result> add(Map<String, dynamic> package, Map<String, dynamic> smartCreateSpec) async {
    Result ret;
    // 先判断服务器是否可用
    if (serverAvailable()) {
      // 可用，给服务器发送建包请求
      ret = await _packageRemoteRepo.add(package, smartCreateSpec);

      // 服务器建包成功
      if (ret.isOk) {
        // 在本地建包
        Result ret = await _packageLocalRepo.add({...package, 'status': 0/*表示成功*/}, smartCreateSpec);
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
      ret = await _packageLocalRepo.add({...package, 'status': 1/*表示未同步到服务器*/}, smartCreateSpec);
    }

    return ret;
  }
}

class PackageLocalRepoSync {
  static PackageLocalRepo _repo = PackageLocalRepo();

  Future<void> sync() async {
    const SIZE = 24;
    int pageNo = 1;
    Page page;
    do {
      page = await _repo.page({'fromAll': '1', 'status': 1, 'page': pageNo, 'size': SIZE});
      Result ret = (await api.post('/package/batch', data: jsonEncode(page.content))).data;
      var db = await getDB();
      Batch batch = db.batch();
      ret.data.forEach((status, packageCodes) {
        packageCodes.forEach((code) {
          batch.update('package', {'status': status, 'lastUpdate': getNowDateTimeString()}, where: 'code = "$code"');
        });
      });
      batch.commit();
      pageNo++;
    } while (page.content.length == SIZE);
  }
}