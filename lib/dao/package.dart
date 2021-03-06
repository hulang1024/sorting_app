import 'dart:async';
import 'package:sorting/entity/package_entity.dart';
import 'db_utils.dart';

/// 集包Dao
class PackageRepo {
  Future<PackageEntity> findById(String code) async {
    return await DBUtils.findOne('package', where: 'code = "$code"', convert: () => PackageEntity());
  }
}