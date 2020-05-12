import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// 应用数据库。
class SortingDatabase {
  static Database _db;
  static const DB_FILENAME = 'sorting.db';

  static Future<Database> instance() async {
    if (_db != null) return _db;
    String dbPath = join(await getDatabasesPath(), DB_FILENAME);
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        // 按键绑定
        await db.execute('''
          create table if not exists `key_binding`(
            `id`               integer   primary key autoincrement not null,
            `action`           int             not null,
            `keyCombination`   varchar(20)     not null
          );
        ''');

        // 集包创建记录
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

        // 集包删除记录
        await db.execute('''
          create table if not exists `package_delete_op`(
            `code`            varchar(20)   primary key not null,
            `operator`        int                       not null,
            `deleteAt`        char(19)                  not null,
            `status`          int                       not null
          );
        ''');

        // 集包快件分配记录
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

        // 集包快件关联
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

        // 目的地地址
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

  /// 删除数据库
  static void delete() async {
    deleteDatabase(join(await getDatabasesPath(), DB_FILENAME));
    _db = null;
  }

  /// 删除离线操作数据
  static void deleteOfflineData() async {
    var db = await instance();
    for (String table in ['package', 'package_delete_op', 'package_item_op', 'package_item_rel']) {
      await db.delete(table);
    }
  }

  /// 删除基础数据
  static void deleteBasicData() async {
    var db = await instance();
    await db.delete('coded_address');
  }
}