import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:testProject/models/model_export.dart';

//class FileManager {
//  static String applicationDocumentsDirectory;
//
//  static Future initialize() async {
//    applicationDocumentsDirectory =
//        (await  getApplicationDocumentsDirectory()).path;
//  }
//
//  static Future<File> _getFile(String filename) async =>
//      new File((await getApplicationDocumentsDirectory()).path + '/$filename');
//
//  static Future<Directory> _getDirectory(String filename) async =>
//      new Directory(
//          (await getApplicationDocumentsDirectory()).path + '/$filename');
//
//  static Future write(String filename, String text,
//      {bool append: false}) async {
//    var file = await (await _getFile(filename))
//        .open(mode: append ? FileMode.APPEND : FileMode.WRITE);
//    file.writeString(text);
//  }
//
//  static Future writeln(String filename, String text,
//      {bool append: false}) async {
//    var file = await (await _getFile(filename))
//        .open(mode: append ? FileMode.APPEND : FileMode.WRITE);
//    file.writeString((append ? "\u{13}" : "") + text);
//  }
//
//  static Future<String> readAsString(String filename) async =>
//      (await _getFile(filename)).readAsString();
//
//  static Future<List<String>> readAsLines(String filename) async =>
//      (await _getFile(filename)).readAsStringSync().split("\u{13}");
//
//  static bool fileExists(String filename) {
//    var f = new File(applicationDocumentsDirectory + "/" + filename);
//    return f.existsSync();
//  }
//
//  static Future<bool> createFile(String filename, {String path = ""}) async {
//    var f = new File(applicationDocumentsDirectory + "/" + filename);
//    if (!(await f.exists())) f.create();
//    return true;
//  }
//
//  static bool folderExists(String path, String name) {
//    return new Directory(applicationDocumentsDirectory + path + "/" + name)
//        .existsSync();
//        }
//
//  static Future<Directory> createFolder(String name, {String path = ""}) async {
//    var dir = await _getDirectory((path != "" ? path + "/" : path) + name);
//    if (!await dir.exists()) await dir.create();
//    return dir;
//  }
//
//  static Directory getDirectory(String name, {String path = ""}) =>
//      new Directory(applicationDocumentsDirectory +
//          "/" +
//          (path != "" ? path + "/" : path) +
//          name);
//
//  static Future<bool> deleteFile(String filename, {String path = ""}) async {
//    await (await _getFile((path != "" ? path + "/" : path) + filename))
//        .delete();
//    return true;
//  }
//}

class DatabaseManager {
  static Database database;

  static Future initialize() async {

    database = await openDatabase(
        (await getApplicationDocumentsDirectory()).path + "/db.db",
        version: 2, onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE ShoppingItems (id INTEGER PRIMARY KEY, name TEXT, amount INTEGER, crossed INTEGER, res_list_id INTEGER)");
      await db.execute(
          "CREATE TABLE ShoppingLists (id INTEGER PRIMARY KEY, name TEXT, messaging INTEGER, user_id INTEGER)");
      await db.execute(
          "CREATE TABLE User (own_id INTEGER, username TEXT, email TEXT, token TEXT, current_list_index INTEGER)"); //TODO for multiple users any indicator of last user
      await db.execute(
          "CREATE TABLE Themes (id INTEGER PRIMARY KEY, primary_color INTEGER, accent_color INTEGER, brightness TEXT, accent_color_brightness TEXT, user_id INTEGER)");
    }, onUpgrade: _upgradeDatabase);
  }

  static Future _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    //user_id new on ShoppingLists and Themes
    var list = (await db.rawQuery("SELECT * FROM User LIMIT 1"));
    if (list.length != 0) User.ownId = list.first["own_id"];

    bool userExists = list.length != 0;
    if (oldVersion == 1) {
      var lists = await db.rawQuery("SELECT * FROM ShoppingLists");
      await db.execute("ALTER TABLE ShoppingLists ADD user_id INTEGER");
      if (lists.length > 0 && userExists)
        await db
            .rawUpdate('UPDATE ShoppingLists SET user_id = ?', [User.ownId]);

      var theme = await db.rawQuery("SELECT * FROM Themes");
      await db.execute("ALTER TABLE Themes ADD user_id INTEGER");
      if (theme.length > 0 && userExists)
        await db.rawUpdate('UPDATE Themes SET user_id = ?', [User.ownId]);
    }
    return null;
  }
}
