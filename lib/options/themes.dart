import 'package:flutter/material.dart';

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
}
