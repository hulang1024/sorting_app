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
    if (queryParams['isSmartCreate'] != null) {
      where.add('isSmartCreate = ${queryParams['isSmartCreate'] ? 1 : 0}');
    }
    if (queryParams['isDeleted'] != null) {
      where.add('status ${queryParams['isDeleted'] ? '=4' : '!=4'}');
    }

    Page page = await DBUtils.fetchPage('package',
        pageParams: queryParams,
        where: where,
        orderBy: 'strftime("%s", createAt) desc',
        convert: () => PackageEntity());

    if (page.total > 0) {
      final destCodes = page.content.map((m) => (m as PackageEntity).destCode);
      var codedAddressMap = {};
      (await (await getDB()).query('coded_address',
          where: 'code in (${destCodes.map((e) => '"$e"').join(',')})')).forEach((m) {
        codedAddressMap[m['code']] = m['address'];
      });
      page.content.forEach((item) {
        PackageEntity package = item as PackageEntity;
        package.destAddress = codedAddressMap[package.destCode];
      });
    }
    return page;
  }

  // 查询集包详情
  Future<Map<String, dynamic>> details(PackageEntity package) async {
    Map<String, dynamic> details = {};
    // 如果是服务器集包数据（根据status为null为空判断），就从服务器查询
    if (package.status == null) {
      details = await api.get('/package/details', queryParameters: {'code': package.code});
      package = PackageEntity().fromJson(details['package']);
    }
    // 如果是本地集包数据，从本地库查询
    else {
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
        var codedAddress = await DBUtils.findOne('coded_address', where: 'code = "${package.destCode}"');
        if (codedAddress != null) {
          details['destAddress'] = codedAddress;
        }
      }
    }
    details['package'] = package;
    return details;
  }

  /// 增加集包
  Future<Result> add(Map<String, dynamic> package, Map<String, dynamic> smartCreateSpec) async {
    Result ret;
    switch(api.isAvailable) {
      case true:
        // 可用，给服务器发送建包请求
        ret = await api.post('/package', data: package, queryParameters: smartCreateSpec).catchError((_) => null);
        if (ret == null) {
          continue OFFLINE;
        }
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
        break;

      OFFLINE:
      case false:
        ret = await _save({...package, 'status': 1/*表示未同步到服务器*/}, smartCreateSpec);
        break;
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
      package['isSmartCreate'] = smartCreateSpec != null ? (smartCreateSpec['smartCreate'] ? 1 : 0) : 0;
      return Result.from(await db.insert('package', package) > 0);
    }
  }
}