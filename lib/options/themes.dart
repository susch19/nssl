import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nssl/manager/file_manager.dart';
import 'package:nssl/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Themes {
  static NSSLThemeData lightTheme = NSSLThemeData(
      ThemeData(
          primarySwatch: Colors.blue,
          accentColor: Colors.teal,
          accentColorBrightness: Brightness.light,
          brightness: Brightness.light),
      0,
      0);
  static NSSLThemeData darkTheme = NSSLThemeData(
      ThemeData(
          primarySwatch: Colors.blue,
          accentColor: Colors.teal,
          accentColorBrightness: Brightness.dark,
          brightness: Brightness.dark),
      0,
      0);
  static ThemeMode tm = ThemeMode.system;

  static Future saveTheme(ThemeData t, MaterialColor primary, MaterialAccentColor accent) async {
    // await DatabaseManager.database.rawDelete("DELETE FROM Themes");
    var id = ((t.brightness == Brightness.light ? 1 : 2) << 32) + User.ownId;
    (await SharedPreferences.getInstance()).setInt("lastTheme", id);
    tm = t.brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    if (!Platform.isAndroid) return;
    await DatabaseManager.database.rawInsert(
        "INSERT OR REPLACE INTO Themes(id, primary_color, accent_color, brightness, accent_color_brightness, user_id) VALUES(?, ?, ?, ?, ?, ?)",
        [
          id,
          Colors.primaries.indexOf(primary),
          Colors.accents.indexOf(accent),
          t.brightness.toString(),
          t.accentColorBrightness.toString(),
          User.ownId
        ]);
  }

  static Future loadTheme() async {
    if (!Platform.isAndroid) return;
    var t;
    var lastId = (await SharedPreferences.getInstance()).getInt("lastTheme") ?? 0;
    try {
      if (User.ownId != null)
        t = (await DatabaseManager.database.rawQuery("SELECT * FROM Themes where user_id = ?", [User.ownId]));
    } catch (e) {
      var temp = (await DatabaseManager.database.rawQuery("SELECT * FROM Themes"))?.first;
      if(temp == null)
        return;
      await DatabaseManager.database.execute("DROP TABLE Themes");
      await DatabaseManager.database.execute(
          "CREATE TABLE Themes (id INTEGER PRIMARY KEY, primary_color INTEGER, accent_color INTEGER, brightness TEXT, accent_color_brightness TEXT, user_id INTEGER)");
      saveTheme(
          ThemeData(
              primarySwatch: Colors.primaries[temp["primary_color"]],
              accentColor: Colors.accents[temp["accent_color"]],
              brightness: temp["brightness"].toString().toLowerCase().contains("dark") ? Brightness.dark : Brightness.light,
              accentColorBrightness:
                  temp["accent_color_brightness"].toString().toLowerCase().contains("dark") ? Brightness.dark : Brightness.light),
          temp["primary_color"],
          temp["accent_color"]);
    }
    if (t.length == 0) return;
    for (var t2 in t) {
      if (lastId == t2["id"]) {
        tm = t2["brightness"].toLowerCase().contains("dark") == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      }

      if (t2["brightness"].toLowerCase().contains("dark") == Brightness.dark) {
        darkTheme = NSSLThemeData(
            ThemeData(
                primarySwatch: Colors.primaries[t2["primary_color"]],
                accentColor: Colors.accents[t2["accent_color"]],
                brightness: Brightness.dark,
                accentColorBrightness:
                    t2["accent_color_brightness"].toLowerCase().contains("dark") ? Brightness.dark : Brightness.light),
            t2["primary_color"],
            t2["accent_color"]);
      } else {
        lightTheme = NSSLThemeData(
            ThemeData(
                primarySwatch: Colors.primaries[t2["primary_color"]],
                accentColor: Colors.accents[t2["accent_color"]],
                brightness: Brightness.light,
                accentColorBrightness:
                    t2["accent_color_brightness"].toLowerCase().contains("dark") ? Brightness.dark : Brightness.light),
            t2["primary_color"],
            t2["accent_color"]);
      }
    }
  }
}

class NSSLThemeData {
  ThemeData theme;
  int primarySwatchIndex;
  int accentSwatchIndex;

  NSSLThemeData(this.theme, this.primarySwatchIndex, this.accentSwatchIndex);
}
