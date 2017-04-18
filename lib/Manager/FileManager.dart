import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class FileManager {
  static String applicationDocumentsDirectory;

  static Future initialize() async {
    applicationDocumentsDirectory =
        (await PathProvider.getApplicationDocumentsDirectory()).path;
  }

  static Future<File> _getFile(String filename) async =>
      new File((await PathProvider.getApplicationDocumentsDirectory()).path +
          '/$filename');

  static Future<Directory> _getDirectory(String filename) async =>
      new Directory(
          (await PathProvider.getApplicationDocumentsDirectory()).path +
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

  static void fileCreate(String filename) {
    var f = new File(applicationDocumentsDirectory + "/" + filename);
    if (!f.existsSync()) f.createSync();
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
}
