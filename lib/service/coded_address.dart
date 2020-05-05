import 'package:sorting/api/http_api.dart';
import 'package:sorting/dao/db_utils.dart';
import 'package:sorting/service/data_sync.dart';

class CodedAddressService {
  /// 判断本地地址库是否有数据
  Future<bool> existsData() async {
    return (await (await getDB()).rawQuery('select count(1) as count from coded_address'))[0]['count'] > 0;
  }

  /// 查询地址
  Future<String> query({code}) async {
    // 如果本地地址库有数据，则查询
    if (await existsData()) {
      return _queryAddress(code);
    }
    // 如果没有数据但API可用，则从服务器下载完成之后然后再次尝试从本地数据库查询
    else if (api.isAvailable) {
      int total = await DataSyncService().downloadCodedAddress();
      if (total >= 0) {
        return _queryAddress(code);
      } else {
        return null;
      }
    }
    else {
      return null;
    }
  }

  Future<String> _queryAddress(String code) async {
    var codedAddress = await DBUtils.findOne('coded_address', where: 'code = "$code"');
    return codedAddress != null ? codedAddress['address'] : null;
  }
}