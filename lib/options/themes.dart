import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nssl/manager/database_manager.dart';
import 'package:nssl/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = ChangeNotifierProvider<Themes>((ref) {
  return Themes(ref);
});

class Themes with ChangeNotifier {
  static late Ref _ref;
  Themes(Ref ref) {
    _ref = ref;
  }

  static NSSLThemeData lightTheme = NSSLThemeData(
      ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        secondaryHeaderColor: Colors.teal,
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.teal.shade400),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateColor.resolveWith(
            (s) {
              if (s.contains(MaterialState.selected)) {
                return Colors.teal.shade200;
              }
              return Colors.black;
            },
          ),
        ),
      ),
      0,
      0);
  static NSSLThemeData darkTheme = NSSLThemeData(
      ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        secondaryHeaderColor: Colors.teal,
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.teal.shade100),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateColor.resolveWith(
            (s) {
              if (s.contains(MaterialState.selected)) {
                return Colors.teal.shade600;
              }
              return Colors.white;
            },
          ),
        ),
      ),
      0,
      0);
  static ThemeMode tm = ThemeMode.system;

  static Future saveTheme(ThemeData t, MaterialColor primary, MaterialAccentColor accent) async {
    // await DatabaseManager.database.rawDelete("DELETE FROM Themes");
    var userId = _ref.watch(userIdProvider);
    if (userId == null) return;
    var id = ((t.brightness == Brightness.light ? 1 : 2) << 32) + userId;
    (await SharedPreferences.getInstance()).setInt("lastTheme", id);
    tm = t.brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    await DatabaseManager.database.rawInsert(
        "INSERT OR REPLACE INTO Themes(id, primary_color, accent_color, brightness, accent_color_brightness, user_id) VALUES(?, ?, ?, ?, ?, ?)",
        [id, Colors.primaries.indexOf(primary), Colors.accents.indexOf(accent), t.brightness.toString(), "", userId]);
  }

  static Future loadTheme() async {
    late var t;
    var lastId = (await SharedPreferences.getInstance()).getInt("lastTheme") ?? 0;
    var userId = _ref.watch(userIdProvider);
    try {
      if (userId != null)
        t = (await DatabaseManager.database.rawQuery("SELECT * FROM Themes where user_id = ?", [userId]));
    } catch (e) {
      var temp = (await DatabaseManager.database.rawQuery("SELECT * FROM Themes")).first;

      await DatabaseManager.database.execute("DROP TABLE Themes");
      await DatabaseManager.database.execute(
          "CREATE TABLE Themes (id INTEGER PRIMARY KEY, primary_color INTEGER, accent_color INTEGER, brightness TEXT, accent_color_brightness TEXT, user_id INTEGER)");
      var primary = Colors.primaries[temp["primary_color"] as int];
      var accent = Colors.accents[temp["accent_color"] as int];
      var primaryBrightness =
          temp["brightness"].toString().toLowerCase().contains("dark") ? Brightness.dark : Brightness.light;
      saveTheme(
          ThemeData(
            brightness: primaryBrightness,
            primarySwatch: primary,
            secondaryHeaderColor: accent,
            floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: accent.shade400),
            checkboxTheme: CheckboxThemeData(
              fillColor: MaterialStateColor.resolveWith(
                (s) {
                  if (s.contains(MaterialState.selected)) {
                    return accent.shade200;
                  }
                  return Colors.black;
                },
              ),
            ),
          ),
          primary,
          accent);
      // ThemeData(
      //     primarySwatch: Colors.primaries[temp["primary_color"] as int],
      //     accentColor: Colors.accents[temp["accent_color"] as int],
      //     brightness: temp["brightness"].toString().toLowerCase().contains("dark") ? Brightness.dark : Brightness.light,
      //     accentColorBrightness:
      //         temp["accent_color_brightness"].toString().toLowerCase().contains("dark") ? Brightness.dark : Brightness.light),
      // temp["primary_color"] as MaterialColor?,
      // temp["accent_color"] as MaterialAccentColor?);
    }
    if (t.length == 0) return;
    for (var t2 in t) {
      if (lastId == t2["id"]) {
        tm = t2["brightness"].toLowerCase().contains("dark") == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      }

      if ((t2["brightness"] as String).toLowerCase().contains("dark")) {
        var primary = Colors.primaries[t2["primary_color"] as int];
        var accent = Colors.accents[t2["accent_color"] as int];
        var primaryBrightness =
            t2["brightness"].toString().toLowerCase().contains("dark") ? Brightness.dark : Brightness.light;
        darkTheme = NSSLThemeData(
            ThemeData(
              brightness: primaryBrightness,
              primarySwatch: primary,
              secondaryHeaderColor: accent,
              floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: accent.shade400),
              checkboxTheme: CheckboxThemeData(
                fillColor: MaterialStateColor.resolveWith(
                  (s) {
                    if (s.contains(MaterialState.selected)) {
                      return accent.shade200;
                    }
                    return Colors.black;
                  },
                ),
              ),
            ),
            t2["primary_color"],
            t2["accent_color"]);
      } else {
        var primary = Colors.primaries[t2["primary_color"] as int];
        var accent = Colors.accents[t2["accent_color"] as int];
        var primaryBrightness =
            t2["brightness"].toString().toLowerCase().contains("dark") ? Brightness.dark : Brightness.light;
        lightTheme = NSSLThemeData(
            ThemeData(
              brightness: primaryBrightness,
              primarySwatch: primary,
              secondaryHeaderColor: accent,
              floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: accent.shade400),
              checkboxTheme: CheckboxThemeData(
                fillColor: MaterialStateColor.resolveWith(
                  (s) {
                    if (s.contains(MaterialState.selected)) {
                      return accent.shade200;
                    }
                    return Colors.black;
                  },
                ),
              ),
            ),
            t2["primary_color"],
            t2["accent_color"]);
      }
    }
  }
}

class NSSLThemeData {
  ThemeData? theme;
  int? primarySwatchIndex;
  int? accentSwatchIndex;

  NSSLThemeData(this.theme, this.primarySwatchIndex, this.accentSwatchIndex);
}
