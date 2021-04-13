import 'package:flutter/material.dart';

import 'request_classes.dart';
import 'dart:async';
import 'helper_methods.dart';
import 'package:http/http.dart';

final String path = "users";
final String path2 = "session";

class UserSync {
  static Future<Response> create(
          String username, String email, String password, BuildContext context) =>
      HelperMethods.post("registration", context,
          LoginArgs(username: username, pwHash: password, eMail: email), true);

  static Future<Response> login(String username, String password, BuildContext context) =>
      HelperMethods.post(
          path2, context, LoginArgs(username: username, pwHash: password), true);

  static Future<Response> loginEmail(String email, String password, BuildContext context) =>
      HelperMethods.post(path2, context, LoginArgs(eMail: email, pwHash: password), true);

  static Future<Response> info(BuildContext context) => HelperMethods.get(path, context);

  static Future<Response> refreshToken(BuildContext? context) =>
      HelperMethods.put(path2, context, null, true);

  static Future<Response> changePassword(String oldPassword, String newPassword, String? token, BuildContext context) =>
      HelperMethods.put(path, context, ChangePasswordArgs(oldPassword, newPassword));
}
