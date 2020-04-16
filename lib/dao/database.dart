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
          create table if not exists `package`(
            `code`            char(10)   primary key    not null,
            `destCode`        char(30)                  not null,
            `createAt`        char(19)                  not null,
            `operator`        int                       not null,
            `status`          int                       not null,
            `lastUpdate`      char(19),
            `deleteAt`        char(19),
            `deleteOperator`  int
          );
        ''');
        await db.execute(''' 
          create table if not exists `package_item_op`(
            `id`              integer   primary key autoincrement not null,
            `packageCode`     char(30)             not null,
            `itemCode`        char(19)             not null,
            `opType`          int                  not null,
            `opTime`          int                  not null,
            `operator`        int                  not null,
            `status`          int                   not null
          );
        ''');
        await db.execute('''
          create table if not exists `package_item_rel`(
            `id`              integer   primary key autoincrement not null,
            `packageCode`     char(30)             not null,
            `itemCode`        char(19)             not null,
            `createAt`        int                  not null,
            `operator`        int                  not null,
            `status`          int                   not null
          );
        ''');
      },
    );
    return _db;
  }

  static void clear() async {
    deleteDatabase(join(await getDatabasesPath(), DB_FILENAME));
    _db = null;
  }
}