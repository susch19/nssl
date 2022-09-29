import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'package:path/path.dart' as path;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FakeDatabase extends Database {
  @override
  Batch batch() {
    throw UnimplementedError();
  }

  @override
  Future<void> close() {
    return Future.value(null);
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    return Future.value(0);
  }

  @override
  Future<T> devInvokeMethod<T>(String method, [arguments]) {
    return Future.value(null);
  }

  @override
  Future<T> devInvokeSqlMethod<T>(String method, String sql, [List<Object?>? arguments]) {
    return Future.value(null);
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) {
    return Future.value(null);
  }

  @override
  Future<int> getVersion() {
    return Future.value(10);
  }

  @override
  Future<int> insert(String table, Map<String, Object?> values,
      {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) {
    return Future.value(values.length);
  }

  @override
  bool get isOpen => true;

  @override
  String get path => "";

  @override
  Future<List<Map<String, Object?>>> query(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) {
    return Future.value([]);
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) {
    return Future.value(0);
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) {
    return Future.value(0);
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) {
    return Future.value([]);
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) {
    return Future.value(0);
  }

  @override
  Future<void> setVersion(int version) {
    return Future.value(null);
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action, {bool? exclusive}) {
    // TODO: implement transaction
    throw UnimplementedError();
  }

  @override
  Future<int> update(String table, Map<String, Object?> values,
      {String? where, List<Object?>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) {
    return Future.value(0);
  }
}

class DatabaseManager {
  static late Database database; // = FakeDatabase();

  static int _version = 3;

  static Future initialize() async {
    // if (kIsWeb) {
    //   return;
    // }
    WidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    String dbPath;
    if (kIsWeb) {
      dbPath = "db.db";
    } else
      dbPath = path.join((await getApplicationDocumentsDirectory()).path, "db.db");
    database = await databaseFactoryFfi.openDatabase(dbPath,
        options: OpenDatabaseOptions(
            version: _version,
            onCreate: (Database db, int version) async {
              await db.execute(
                  "CREATE TABLE ShoppingItems (id INTEGER PRIMARY KEY, name TEXT, amount INTEGER, crossed INTEGER, res_list_id INTEGER, sortorder INTEGER)");
              await db.execute(
                  "CREATE TABLE ShoppingLists (id INTEGER PRIMARY KEY, name TEXT, messaging INTEGER, user_id INTEGER)");
              await db.execute(
                  "CREATE TABLE User (own_id INTEGER, username TEXT, email TEXT, token TEXT, current_list_index INTEGER)"); //TODO for multiple users any indicator of last user
              await db.execute(
                  "CREATE TABLE Themes (id INTEGER PRIMARY KEY, primary_color INTEGER, accent_color INTEGER, brightness TEXT, accent_color_brightness TEXT, user_id INTEGER)");
            },
            onUpgrade: _upgradeDatabase));
  }

  static Future _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    //user_id new on ShoppingLists and Themes
    var list = (await db.rawQuery("SELECT * FROM User LIMIT 1"));
    int? userId;
    if (list.length != 0) userId = list.first["own_id"] as int?;
    bool userExists = list.length != 0;
    if (oldVersion == 1) {
      var lists = await db.rawQuery("SELECT * FROM ShoppingLists");
      await db.execute("ALTER TABLE ShoppingLists ADD user_id INTEGER");
      if (lists.length > 0 && userExists) await db.rawUpdate('UPDATE ShoppingLists SET user_id = ?', [userId]);

      var theme = await db.rawQuery("SELECT * FROM Themes");
      await db.execute("ALTER TABLE Themes ADD user_id INTEGER");
      if (theme.length > 0 && userExists) await db.rawUpdate('UPDATE Themes SET user_id = ?', [userId]);
    }

    if (oldVersion < 3) {
      await db.execute("ALTER TABLE ShoppingItems ADD sortorder INTEGER");
      await db.execute("UPDATE ShoppingItems SET sortorder = id");
    }
    return null;
  }
}
