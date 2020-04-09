import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package.dart';

Database _db;

class SortingDatabase {
  static const DB_FILENAME = 'sorting.db';

  static Future<Database> instance() async {
    if (_db != null) return _db;
    String dbPath = join(await getDatabasesPath(), DB_FILENAME);
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          create table if not exists `package`(
            `code`       char(10)   primary key    not null,
            `destCode`   char(30)                  not null,
            `createAt`   char(19)                  not null,
            `operator`   int                       not null,
            `status`     int                       not null,
            `lastUpdate` char(19)
          );
          
          create table if not exists `package_deleted`(
            `code`        char(10)   primary key    not null
          );
        ''');
      },
    );
    return _db;
  }

  static Future<void> sync() async {
    return PackageLocalRepoSync().sync();
  }

  static void clear() async {
    deleteDatabase(join(await getDatabasesPath(), DB_FILENAME));
    _db = null;
  }
}