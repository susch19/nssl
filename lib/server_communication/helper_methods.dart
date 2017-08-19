import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:testProject/manager/file_manager.dart';
import 'package:testProject/models/model_export.dart';
import 'package:testProject/server_communication/jwt.dart';
import 'user_sync.dart';

class HelperMethods {
  static const String url = "http://192.168.49.28:4344";

  static Future<http.Response> post(String path,
      [Object body = null, skipTokenRefresh = false]) async {
    if (!skipTokenRefresh) await handleTokenRefresh();
    var g = http.post("$url/$path", body: JSON.encode(body), headers: {
      "Content-Type": "application/json",
      User.token == null ? "X-foo" : "X-Token": User.token
    });
    http.Response res;
    await g.then((x) => res = x);
    reactToRespone(res);
    return res;
  }

  static Future<http.Response> get(String path) async {
    await handleTokenRefresh();
    var g = http.get("$url/$path", headers: {
      "Content-Type": "application/json",
      User.token == null ? "X-foo" : "X-Token": User.token
    });
    http.Response res;
    await g.then((x) => res = x);
    reactToRespone(res);
    return res;
  }

  static Future<http.Response> put(String path,
      [Object body = null, bool skipTokenRefresh = false]) async {
    if (!skipTokenRefresh) await handleTokenRefresh();
    var g = http.put("$url/$path", body: JSON.encode(body), headers: {
      "Content-Type": "application/json",
      User.token == null ? "X-foo" : "X-Token": User.token
    });
    http.Response res;
    await g.then((x) => res = x);
    reactToRespone(res);
    return res;
  }

  static Future<http.Response> delete(String path) async {
    await handleTokenRefresh();
    var g = http.delete("$url/$path", headers: {
      "Content-Type": "application/json",
      User.token == null ? "X-foo" : "X-Token": User.token
    });
    http.Response res;
    await g.then((x) => res = x);
    reactToRespone(res);
    return res;
  }

  void onDataLoaded(String responseText) {
    var jsonString = responseText;
    print(jsonString);
  }

  static bool reactToRespone(http.Response respone,
      {BuildContext context, ScaffoldState scaffoldState}) {
    if (respone.statusCode == 500) {
      throw new Exception();
    } else if (respone.statusCode == 401) {
      throw new Exception();
    }
    return true;
  }

  static handleTokenRefresh() async {
    if (await JWT.newToken()) {
      var t = await UserSync.refreshToken();
      var m = JSON.decode(t.body);
      var to = m["token"];
      FileManager.write("token.txt", to);
      User.token = to;
    }
  }
}
