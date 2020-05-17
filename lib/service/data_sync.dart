import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorting/api/http_api.dart';
import 'package:sorting/dao/db_utils.dart';
import 'package:sorting/service/coded_address.dart';
import 'package:sorting/service/package_delete.dart';
import 'package:sorting/widgets/message.dart';
import 'package:sqflite/sqflite.dart';
import 'package.dart';

/// 本地与服务器数据同步
class DataSyncService {
  PackageService _packageService = PackageService();
  PackageDeleteService _packageDeleteService = PackageDeleteService();

  /// 应用启动时执行任务
  Future<void> onAppInitState() async {
    await uploadOfflineData();
    await pullBasicData(checkVersion: true);
  }

  /// 更新基础数据
  Future<int> pullBasicData({checkVersion: false}) async {
    return await pullCodedAddress(checkVersion: checkVersion);
  }

  /// 上传离线数据
  Future<int> uploadOfflineData() async {
    int uploadRows = 0;
    uploadRows += await _uploadPackages(isSmartCreate: false);
    uploadRows += await _uploadPackageItemOperations();
    uploadRows += await _uploadPackages(isSmartCreate: true);
    uploadRows += await _requestDeletePackages();
    return uploadRows;
  }

  Future<int> _uploadPackages({isSmartCreate}) async {
    const PAGE_SIZE = 24;
    int pageNo = 0;
    Page page;

    var db = await getDB();
    String now = getNowDateTimeString();
    do {
      page = await _packageService.queryPage({
        'fromAll': '1',
        'isDeleted': false,
        'isSmartCreate': isSmartCreate,
        'status': 1,
        'page': ++pageNo,
        'size': PAGE_SIZE,
      });
      if (page.content.length == 0) {
        break;
      }
      
      Function toJson = ({List<String> filterFields}) {
        return page.content.map((package) {
          Map<String, dynamic> map = package.toJson();
          map.removeWhere((key, val) => !filterFields.contains(key));
          return map;
        }).toList();
      };
      Result ret = await api.post('/package/batch',
        data: toJson(filterFields: ['code', 'destCode', 'createAt', 'operator']),
        queryParameters: {'smartCreate': isSmartCreate, 'allocItemNumMax': 10});
      if (!ret.isOk) {
        break;
      }
      Batch batch = db.batch();
      ret.data.forEach((status, packageCodes) {
        packageCodes.forEach((code) {
          batch.update('package', {'status': status, 'lastUpdate': now}, where: 'code = "$code"');
        });
      });
      batch.commit();
    } while (page.content.length == PAGE_SIZE);
    return (pageNo == 1 ? 0 : pageNo) * PAGE_SIZE + page.content.length;
  }

  Future<int> _requestDeletePackages() async {
    const PAGE_SIZE = 24;
    int pageNo = 0;
    Page page;

    var db = await getDB();
    do {
      page = await _packageDeleteService.queryPage({'status': 1, 'page': ++pageNo, 'size': PAGE_SIZE});
      if (page.content.length == 0) {
        break;
      }

      Result ret = await api.post('/package/batch_delete', data: page.content);
      if (!ret.isOk) {
        break;
      }
      Batch batch = db.batch();
      ret.data.forEach((status, packageCodes) {
        packageCodes.forEach((code) {
          batch.update('package_delete_op', {'status': status}, where: 'code = "$code"');
        });
      });
      batch.commit();
    } while (page.content.length == PAGE_SIZE);
    return (pageNo == 1 ? 0 : pageNo) * PAGE_SIZE + page.content.length;
  }


  Future<int> _uploadPackageItemOperations() async {
    const PAGE_SIZE = 24;
    int pageNo = 0;
    List<Map<String, dynamic>> rows;

    var db = await getDB();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int schemeId = prefs.getInt('schemeId');
    if (schemeId == null) {
      Messager.error('自动上传集包快件关联失败：请先设置模式');
      return 0;
    }
    do {
      ++pageNo;
      rows = await db.rawQuery('''
        select * from package_item_op
        where status = 1
        limit ${(pageNo - 1) * PAGE_SIZE}, $PAGE_SIZE
      ''');
      if (rows.isEmpty) {
        break;
      }
      Result ret = await api.post('/package_item_op/batch', data: jsonEncode(rows), queryParameters: {'schemeId': schemeId});
      if (!ret.isOk) {
        break;
      }
      Batch batch = db.batch();
      ret.data.forEach((status, ids) {
        ids.forEach((id) {
          batch.rawUpdate('''
            update package_item_rel set status = $status
            where itemCode = (select itemCode from package_item_op where id=$id)
          ''');
          batch.update('package_item_op',  {'status': status}, where: 'id = $id');
        });
      });
      batch.commit();
    } while (rows.length == PAGE_SIZE);
    return (pageNo == 1 ? 0 : pageNo) * PAGE_SIZE + rows.length;
  }

  Future<int> pullCodedAddress({@required checkVersion}) async {
    // 检查版本
    if (checkVersion) {
      // 检查服务器中记录数量是否不大于本地记录数
      var count = await api.get('/coded_address/count');
      if (count == await CodedAddressService().count()) {
        return 0;
      }
    }

    List records = await api.get('/coded_address/all');
    // 如果未查询到任何数据，则当作下载失败
    if (records.isEmpty) {
      return -1;
    }

    var db = await getDB();
    return db.transaction((txn) async {
      await txn.delete('coded_address');
      Batch batch = txn.batch();
      records.forEach((record) {
        batch.insert('coded_address', record);
      });
      await batch.commit();
      return records.length;
    });
  }

}