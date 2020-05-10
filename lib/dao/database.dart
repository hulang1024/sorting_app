import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
          create table if not exists `key_binding`(
            `action`           int             not null,
            `keyCombination`   varchar(20)     not null
          );
        ''');
        await db.execute('''
          create table if not exists `package`(
            `code`            varchar(20)   primary key not null,
            `destCode`        varchar(30)               not null,
            `createAt`        char(19)                  not null,
            `operator`        int                       not null,
            `isSmartCreate`   int                       not null,
            `status`          int                       not null,
            `lastUpdate`      char(19)
          );
        ''');
        await db.execute('''
          create table if not exists `package_delete_op`(
            `code`            varchar(20)   primary key not null,
            `operator`        int                       not null,
            `deleteAt`        char(19)                  not null,
            `status`          int                       not null
          );
        ''');
        await db.execute(''' 
          create table if not exists `package_item_op`(
            `id`              integer   primary key autoincrement not null,
            `packageCode`     varchar(20)             not null,
            `itemCode`        varchar(20)             not null,
            `opType`          int                     not null,
            `opTime`          int                     not null,
            `operator`        int                     not null,
            `status`          int                     not null
          );
        ''');
        await db.execute('''
          create table if not exists `package_item_rel`(
            `id`              integer   primary key autoincrement not null,
            `packageCode`     char(30)             not null,
            `itemCode`        char(19)             not null,
            `createAt`        int                  not null,
            `operator`        int                  not null,
            `status`          int                  not null
          );
        ''');
        await db.execute('''
          create table if not exists `coded_address`(
            `code`     varchar(30)  primary key  not null,
            `address`  varchar(255)              not null
          );
        ''');
      },
    );
    return _db;
  }

  static void delete() async {
    deleteDatabase(join(await getDatabasesPath(), DB_FILENAME));
    _db = null;
  }

  static void deleteOfflineData() async {
    var db = await instance();
    for (String table in ['package', 'package_delete_op', 'package_item_op', 'package_item_rel']) {
      await db.delete(table);
    }
  }

  static void deleteBasicData() async {
    var db = await instance();
    await db.delete('coded_address');
  }
}