import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/manager/database_manager.dart';
import 'dart:convert';
import 'dart:async';
import 'package:nssl/models/model_export.dart';
import 'package:nssl/server_communication/jwt.dart';
import 'user_sync.dart';

class HelperMethods {
  static const String scheme = "https";
  static const String host = "nssl.susch.eu";
  static const int port = 443;
  // static const String scheme = "http";
  // static const String host = "192.168.49.22";
  // static const String url = "http://192.168.49.22:4344";

  static Future<http.Response> post(String path, BuildContext? context,
      [Object? body, skipTokenRefresh = false, Map<String, dynamic>? query]) async {
    if (!skipTokenRefresh) await handleTokenRefresh(context);
    var res = await http.post(
        Uri(host: host, scheme: scheme, path: path, port: port, queryParameters: query /*, port: 4344*/),
        body: jsonEncode(body),
        headers: {"Content-Type": "application/json", User.token == "" ? "X-foo" : "X-Token": User.token});
    reactToRespone(res, context);
    return res;
  }

  static Future<http.Response> get(String path, BuildContext? context, [String query = ""]) async {
    await handleTokenRefresh(context);
    var res = await http.get(Uri(host: host, scheme: scheme, path: path, query: query, port: port /*, port: 4344*/),
        headers: {"Content-Type": "application/json", User.token == "" ? "X-foo" : "X-Token": User.token});
    reactToRespone(res, context);
    return res;
  }

  static Future<http.Response> put(String path, BuildContext? context,
      [Object? body, bool skipTokenRefresh = false]) async {
    if (!skipTokenRefresh) await handleTokenRefresh(context);
    var res = await http.put(Uri(host: host, scheme: scheme, path: path, port: port /*, port: 4344*/),
        body: jsonEncode(body),
        headers: {"Content-Type": "application/json", User.token == "" ? "X-foo" : "X-Token": User.token});
    reactToRespone(res, context);
    return res;
  }

  static Future<http.Response> delete(String path, BuildContext? context) async {
    await handleTokenRefresh(context);
    var res = await http.delete(Uri(host: host, scheme: scheme, path: path, port: port /*, port: 4344*/),
        headers: {"Content-Type": "application/json", User.token == "" ? "X-foo" : "X-Token": User.token});

    reactToRespone(res, context);
    return res;
  }

  void onDataLoaded(String responseText) {
    var jsonString = responseText;
    print(jsonString);
  }

  static bool reactToRespone(http.Response respone, BuildContext? context, {ScaffoldState? scaffoldState}) {
    if (context == null) return false;
    if (respone.statusCode == 500) {
      throw Exception();
    } else if (respone.statusCode == 401) {
      showDialog(
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(NSSLStrings.of(context).tokenExpired()),
              content: Text(NSSLStrings.of(context).tokenExpiredExplanation()),
              actions: [
                MaterialButton(
                  onPressed: () async {
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                  child: const Text("OK"),
                )
              ],
            );
          },
          context: context);
    }
    return true;
  }

  static handleTokenRefresh(BuildContext? context) async {
    if (await JWT.newToken()) {
      var t = await UserSync.refreshToken(context);
      if (t.body == "") return;
      var m = jsonDecode(t.body);
      var to = m["token"];
      User.token = to;
      DatabaseManager.database.execute("Update User set token = ?", [to]);
    }
  }
}
