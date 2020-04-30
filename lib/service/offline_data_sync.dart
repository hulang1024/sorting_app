import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorting/api/http_api.dart';
import 'package:sorting/dao/db_utils.dart';
import 'package:sorting/service/package_delete.dart';
import 'package:sorting/widgets/message.dart';
import 'package:sqflite/sqflite.dart';
import 'package.dart';

/// 同步离线数据到服务器
class OfflineDataSyncService {
  PackageService _packageService = PackageService();
  PackageDeleteService _packageDeleteService = PackageDeleteService();

  Future<int> sync() async {
    int uploadRows = 0;
    uploadRows += await _uploadPackages(isSmartCreate: false);
    uploadRows += await _uploadPackageItemRelations();
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


  Future<int> _uploadPackageItemRelations() async {
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
        select r.* from package_item_rel r
        where r.status = 1
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
      ret.data.forEach((status, itemCodes) {
        itemCodes.forEach((code) {
          batch.update('package_item_rel', {'status': status}, where: 'itemCode = "$code"');
          batch.update('package_item_op',  {'status': status}, where: 'itemCode = "$code"');
        });
      });
      batch.commit();
    } while (rows.length == PAGE_SIZE);
    return (pageNo == 1 ? 0 : pageNo) * PAGE_SIZE + rows.length;
  }

}