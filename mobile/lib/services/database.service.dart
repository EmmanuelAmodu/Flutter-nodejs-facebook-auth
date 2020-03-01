import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  Future<Database> initDB({String createQuery}) async {
    return openDatabase(
      join(await getDatabasesPath(), 'eyo_app_db.db'),
      onCreate: (db, version) async  {
        if (createQuery != null) await db.execute(createQuery);
      },
      version: 1,
    );
  }
}
