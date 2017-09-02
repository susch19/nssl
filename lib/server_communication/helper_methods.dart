import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testProject/localization/nssl_strings.dart';
import 'dart:convert';
import 'dart:async';
import 'package:testProject/models/model_export.dart';
import 'package:testProject/server_communication/jwt.dart';
import 'user_sync.dart';

class HelperMethods {
  static const String url = "https://susch.undo.it";

  static Future<http.Response> post(String path, BuildContext context,
      [Object body, skipTokenRefresh = false]) async {
    if (!skipTokenRefresh) await handleTokenRefresh(context);
    var g = http.post("$url/$path", body: JSON.encode(body), headers: {
      "Content-Type": "application/json",
      User.token == null ? "X-foo" : "X-Token": User.token
    });
    http.Response res;
    await g.then((x) => res = x);
    reactToRespone(res, context);
    return res;
  }

  static Future<http.Response> get(String path, BuildContext context) async {
    await handleTokenRefresh(context);
    var g = http.get("$url/$path", headers: {
      "Content-Type": "application/json",
      User.token == null ? "X-foo" : "X-Token": User.token
    });
    http.Response res;
    await g.then((x) => res = x);
    reactToRespone(res, context);
    return res;
  }

  static Future<http.Response> put(String path, BuildContext context,
      [Object body, bool skipTokenRefresh = false]) async {
    if (!skipTokenRefresh) await handleTokenRefresh(context);
    var g = http.put("$url/$path", body: JSON.encode(body), headers: {
      "Content-Type": "application/json",
      User.token == null ? "X-foo" : "X-Token": User.token
    });
    http.Response res;
    await g.then((x) => res = x);
    reactToRespone(res, context);
    return res;
  }

  static Future<http.Response> delete(String path, BuildContext context) async {
    await handleTokenRefresh(context);
    var g = http.delete("$url/$path", headers: {
      "Content-Type": "application/json",
      User.token == null ? "X-foo" : "X-Token": User.token
    });
    http.Response res;
    await g.then((x) => res = x);
    reactToRespone(res, context);
    return res;
  }

  void onDataLoaded(String responseText) {
    var jsonString = responseText;
    print(jsonString);
  }

  static bool reactToRespone(http.Response respone, BuildContext context,
      {ScaffoldState scaffoldState}) {
    if (respone.statusCode == 500) {
      throw new Exception();
    } else if (respone.statusCode == 401) {
      var ad = new AlertDialog(
        title: new Text(NSSLStrings.of(context).tokenExpired()),
        content: new Text(NSSLStrings.of(context).tokenExpiredExplanation()),
        actions: [
          new MaterialButton(
            onPressed: () async {
              Navigator.pushReplacementNamed(context, "/login");
            },
            child: const Text("OK"),
          )
        ],
      );
      showDialog(child: ad, context: context);
    }
    return true;
  }

  static handleTokenRefresh(BuildContext context) async {
    if (await JWT.newToken()) {
      var t = await UserSync.refreshToken(context);
      var m = JSON.decode(t.body);
      var to = m["token"];
      User.token = to;
      User.save();
    }
  }
}
