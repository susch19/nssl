import 'dart:async';
import 'package:flutter/material.dart';
import 'package:testProject/manager/file_manager.dart';
import 'package:testProject/models/user.dart';

class Themes {
  static List<ThemeData> themes = [
    new ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.teal,
        accentColorBrightness: Brightness.light,
        brightness: Brightness.light),
  ];

  static Future saveTheme(
      ThemeData t, MaterialColor primary, MaterialAccentColor accent) async {
    await DatabaseManager.database.rawDelete("DELETE FROM Themes");
    await DatabaseManager.database.rawInsert(
        "INSERT INTO Themes(id, primary_color, accent_color, brightness, accent_color_brightness, user_id) VALUES(1, ?, ?, ?, ?, ?)",
        [
          Colors.primaries.indexOf(primary),
          Colors.accents.indexOf(accent),
          t.brightness.toString(),
          t.accentColorBrightness.toString(),
          User.ownId
        ]);
  }

  static Future loadTheme() async {
    var t;
    try {
      if(User.ownId != null)
      t = (await DatabaseManager.database
          .rawQuery("SELECT * FROM Themes where user_id = ?", [User.ownId]));
    } catch (e) {
      var temp =
          (await DatabaseManager.database.rawQuery("SELECT * FROM Themes"))
              ?.first;
      await DatabaseManager.database.execute("DROP TABLE Themes");
      await DatabaseManager.database.execute(
          "CREATE TABLE Themes (id INTEGER PRIMARY KEY, primary_color INTEGER, accent_color INTEGER, brightness TEXT, accent_color_brightness TEXT, user_id INTEGER)");
      saveTheme(
          new ThemeData(
              primarySwatch: Colors.primaries[temp["primary_color"]],
              accentColor: Colors.accents[temp["accent_color"]],
              brightness: temp["brightness"].toLowerCase().contains("dark")
                  ? Brightness.dark
                  : Brightness.light,
              accentColorBrightness:
                  temp["accent_color_brightness"].toLowerCase().contains("dark")
                      ? Brightness.dark
                      : Brightness.light),
          temp["primary_color"],
          temp["accent_color"]);
    }
    if (t.length == 0) return;
    var t2 = t.first;
    themes.clear();
    themes.add(new ThemeData(
        primarySwatch: Colors.primaries[t2["primary_color"]],
        accentColor: Colors.accents[t2["accent_color"]],
        brightness: t2["brightness"].toLowerCase().contains("dark")
            ? Brightness.dark
            : Brightness.light,
        accentColorBrightness:
            t2["accent_color_brightness"].toLowerCase().contains("dark")
                ? Brightness.dark
                : Brightness.light));
  }
}
