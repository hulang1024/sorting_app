import 'package:sorting/repositories/database.dart';

class PackageRepo {
  static Future<int> save(Map<String, dynamic> package) async {
    await SortingDatabase.getInstance();
    return db.insert('package', package);
  }


}