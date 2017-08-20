import 'dart:async';
import 'package:flutter/material.dart';
import 'package:testProject/manager/file_manager.dart';

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
        "INSERT INTO Themes(id, primary_color, accent_color, brightness, accent_color_brightness) VALUES(1, ?, ?, ?, ?)",
        [
          Colors.primaries.indexOf(primary),
          Colors.accents.indexOf(accent),
          t.brightness.toString(),
          t.accentColorBrightness.toString()
        ]);
  }

  static Future loadTheme() async {
    var t = (await DatabaseManager.database.rawQuery("SELECT * FROM Themes"));
    if(t.length == 0) return;
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
