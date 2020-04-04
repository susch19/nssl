import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:nssl/models/model_export.dart';

class DatabaseManager {
  static Database database;

  static int _version = 3;

  static Future initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    database = await openDatabase((await getApplicationDocumentsDirectory()).path + "/db.db", version: _version, onCreate: (Database db, int version) async {
      await db
          .execute("CREATE TABLE ShoppingItems (id INTEGER PRIMARY KEY, name TEXT, amount INTEGER, crossed INTEGER, res_list_id INTEGER, sortorder INTEGER)");
      await db.execute("CREATE TABLE ShoppingLists (id INTEGER PRIMARY KEY, name TEXT, messaging INTEGER, user_id INTEGER)");
      await db.execute(
          "CREATE TABLE User (own_id INTEGER, username TEXT, email TEXT, token TEXT, current_list_index INTEGER)"); //TODO for multiple users any indicator of last user
      await db.execute(
          "CREATE TABLE Themes (id INTEGER PRIMARY KEY, primary_color INTEGER, accent_color INTEGER, brightness TEXT, accent_color_brightness TEXT, user_id INTEGER)");
    }, onUpgrade: _upgradeDatabase);
  }

  static Future _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    //user_id new on ShoppingLists and Themes
    var list = (await db.rawQuery("SELECT * FROM User LIMIT 1"));
    if (list.length != 0) User.ownId = list.first["own_id"];

    bool userExists = list.length != 0;
    if (oldVersion == 1) {
      var lists = await db.rawQuery("SELECT * FROM ShoppingLists");
      await db.execute("ALTER TABLE ShoppingLists ADD user_id INTEGER");
      if (lists.length > 0 && userExists) await db.rawUpdate('UPDATE ShoppingLists SET user_id = ?', [User.ownId]);

      var theme = await db.rawQuery("SELECT * FROM Themes");
      await db.execute("ALTER TABLE Themes ADD user_id INTEGER");
      if (theme.length > 0 && userExists) await db.rawUpdate('UPDATE Themes SET user_id = ?', [User.ownId]);
    }

    if (oldVersion == 1 || oldVersion == 2) {
      await db.execute("ALTER TABLE ShoppingItems ADD sortorder INTEGER");
      await db.execute("UPDATE ShoppingItems SET sortorder = id");
    }
    return null;
  }
}
