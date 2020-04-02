import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Database db;

class SortingDatabase {
  static const DB_FILENAME = 'sorting.db';

  static Future<Database> getInstance() async {
    if (db != null) return db;
    String dbPath = join(await getDatabasesPath(), DB_FILENAME);
    db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          create table if not exists `package`(
            `code`        char(10)   primary key    not null,
            `dest_code`   char(30)                  not null,
            `create_at`   datetime                  not null,
            `operator`    int                       not null
          );
          
          create table if not exists `package_deleted`(
            `code`        char(10)   primary key    not null,
          );
        ''');
      },
    );
    return db;

  }
}
