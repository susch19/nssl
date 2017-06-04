import 'dart:async';
import 'package:flutter/material.dart';
import 'package:testProject/manager/file_manager.dart';

class Themes {
  static List<ThemeData> themes = [
    new ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.teal,
        accentColorBrightness: Brightness.light,
        brightness: Brightness.dark),
    new ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.teal,
        accentColorBrightness: Brightness.dark,
        brightness: Brightness.light),
    new ThemeData(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.amberAccent,
        accentColorBrightness: Brightness.dark,
        brightness: Brightness.dark),
    new ThemeData(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.amberAccent,
        accentColorBrightness: Brightness.light,
        brightness: Brightness.light),
    new ThemeData(
        primarySwatch: Colors.deepOrange,
        accentColor: Colors.pinkAccent,
        accentColorBrightness: Brightness.dark,
        brightness: Brightness.dark),
    new ThemeData(
        primarySwatch: Colors.deepOrange,
        accentColor: Colors.pinkAccent,
        accentColorBrightness: Brightness.light,
        brightness: Brightness.light),
  ];

  static Future saveTheme(
      ThemeData t, MaterialColor primary, MaterialAccentColor accent) async {
    if (FileManager.fileExists("theme")) await FileManager.deleteFile("theme");
    await FileManager.createFile("theme");
    await FileManager.writeln(
        "theme", Colors.primaries.indexOf(primary).toString());
    await FileManager.writeln(
        "theme", Colors.accents.indexOf(accent).toString(),
        append: true);
    await FileManager.writeln("theme", t.brightness.toString(), append: true);
    await FileManager.writeln("theme", t.accentColorBrightness.toString(),
        append: true);
  }

  static Future loadTheme() async {
    if (!FileManager.fileExists("theme")) return;

    var lines = await FileManager.readAsLines("theme");
    themes.clear();
    themes.add(new ThemeData(
        primarySwatch: Colors.primaries[int.parse(lines[0])],
        accentColor: Colors.accents[int.parse(lines[1])],
        brightness: lines[2].toLowerCase().contains("dark")
            ? Brightness.dark
            : Brightness.light,
        accentColorBrightness: lines[3].toLowerCase().contains("dark")
            ? Brightness.dark
            : Brightness.light));
  }
}
