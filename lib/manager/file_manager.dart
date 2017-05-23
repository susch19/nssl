import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileManager {
  static String applicationDocumentsDirectory;

  static Future initialize() async {
    applicationDocumentsDirectory =
        (await getApplicationDocumentsDirectory()).path;
  }

  static Future<File> _getFile(String filename) async =>
      new File((await getApplicationDocumentsDirectory()).path +
          '/$filename');

  static Future<Directory> _getDirectory(String filename) async =>
      new Directory(
          (await getApplicationDocumentsDirectory()).path +
              '/$filename');

  static Future write(String filename, String text,
      {bool append: false}) async {
    var file = await (await _getFile(filename))
        .open(mode: append ? FileMode.APPEND : FileMode.WRITE);
    file.writeString(text);
  }

  static Future writeln(String filename, String text,
      {bool append: false}) async {
    var file = await (await _getFile(filename))
        .open(mode: append ? FileMode.APPEND : FileMode.WRITE);
    file.writeString(text + "\u{13}");
  }

  static Future<String> readAsString(String filename) async =>
      (await _getFile(filename)).readAsString();

  static Future<List<String>> readAsLines(String filename) async =>
      (await _getFile(filename)).readAsStringSync().split("\u{13}");

  static bool fileExists(String filename) {
    var f = new File(applicationDocumentsDirectory + filename);
    return f.existsSync();
  }

  static Future<bool> createFile(String filename, {String path = ""}) async{
    var f = new File(applicationDocumentsDirectory + "/" + filename);
    if (!(await f.exists())) f.create();
    return true;
  }

  static bool folderExists(String path, String name) {
    return new Directory(applicationDocumentsDirectory + path + "/" + name)
        .existsSync();
  }

  static Future<Directory> createFolder(String name, {String path = ""}) async {
    var dir = await _getDirectory((path != "" ? path + "/" : path) + name);
    if (!await dir.exists()) await dir.create();
    return dir;
  }

  static Directory getDirectory(String name, {String path = ""}) =>
      new Directory(applicationDocumentsDirectory +
          "/" +
          (path != "" ? path + "/" : path) +
          name);

  static Future<bool> deleteFile(String filename, {String path = ""}) async{
      await (await _getFile((path != "" ? path + "/" : path) + filename))
          .delete();
      return true;
  }
}
