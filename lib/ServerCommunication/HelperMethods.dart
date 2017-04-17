import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:testProject/Models/Models.dart';

class HelperMethods {
  static const String url = "https://susch.undo.it:443";
  //static const String url = "http://176.95.26.106:80";
  //static const String url = "http://192.168.49.46:4344";


  static Future<http.Response> post(String path, [Object body = null]) async {
    var g = http.post("$url/$path",
        body: JSON.encode(body), headers: {"Content-Type": "application/json", User.token==null?"X-foo":"X-Token":User.token});
    http.Response res;
    await g.then((x) => res = x);
    return res;
  }

  static Future<http.Response> get(String path) async {
    var g = http.get("$url/$path",
        headers: {"Content-Type": "application/json", User.token==null?"X-foo":"X-Token":User.token});
    http.Response res;
    await g.then((x) => res = x);
    return res;
  }

  static Future<http.Response> put(String path, [Object body = null]) async {
    var g = http.put("$url/$path",
        body: JSON.encode(body), headers: {"Content-Type": "application/json", User.token==null?"X-foo":"X-Token":User.token});
    http.Response res;
    await g.then((x) => res = x);
    return res;
  }

  static Future<http.Response> delete(String path) async {
    var g = http.delete("$url/$path",
        headers: {"Content-Type": "application/json", User.token==null?"X-foo":"X-Token":User.token});
    http.Response res;
    await g.then((x) => res = x);
    return res;
  }

  void onDataLoaded(String responseText) {
    var jsonString = responseText;
    print(jsonString);
  }

  static bool reactToRespone(http.Response respone, {BuildContext context, ScaffoldState scaffoldState}){
    if(respone.statusCode != 200)
    {
      scaffoldState.showSnackBar(new SnackBar(content: new Text(respone.reasonPhrase)));
      return false;
    }
    return true;
  }
}
