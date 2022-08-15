import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Db {
  static Database? _db;

  static init(List<String> createList) {
    if (_db == null) {
      getDatabasesPath().then((value) {
        openDatabase(join(value, 'tasks.db'), onCreate: (db, version) {
          for (String s in createList) {
            db.execute(s);
          }
        }, onUpgrade: (db, oldVersion, newVersion) {
          List<String> oldTable = [
            "products", "employes", "processes", "storages", "workshop", "stages"
          ];
          for (String t in oldTable) {
            try {
              db.execute("drop table $t");
            } catch (e) {
              print(e);
            }
          }
          for (String s in createList) {
            db.execute(s);
          }
        }, version: 14)
            .then((value) => _db = value);
      });
    }
  }

  static void delete(String sql, [List<Object?>? args]) async {
    await _db!.rawDelete(sql, args);
  }

  static Future<int> insert(String sql, [List<Object?>? args]) async {
    int result = await _db!.rawInsert(sql, args);
    return result;
  }

  static Future<List<Map<String, dynamic?>>> query(String table) async {
    return _db!.query(table);
  }
}
