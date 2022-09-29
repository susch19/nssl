import 'package:flutter/material.dart';

import 'request_classes.dart';
import 'dart:async';
import 'helper_methods.dart';
import 'package:http/http.dart';

final String usersPath = "users";
final String sessionPath = "session";
final String passwortPath = "password";

class UserSync {
  static Future<Response> create(String username, String email, String password,
          BuildContext context) =>
      HelperMethods.post("registration", context,
          LoginArgs(username: username, pwHash: password, eMail: email), true);

  static Future<Response> login(
          String username, String password, BuildContext context) =>
      HelperMethods.post(sessionPath, context,
          LoginArgs(username: username, pwHash: password), true);

  static Future<Response> loginEmail(
          String email, String password, BuildContext context) =>
      HelperMethods.post(sessionPath, context,
          LoginArgs(eMail: email, pwHash: password), true);

  static Future<Response> info(BuildContext context) =>
      HelperMethods.get(usersPath, context);

  static Future<Response> refreshToken(BuildContext? context) =>
      HelperMethods.put(sessionPath, context, null, true);

  static Future<Response> changePassword(String oldPassword, String newPassword,
          String? token, BuildContext context) =>
      HelperMethods.put(
          usersPath, context, ChangePasswordArgs(oldPassword, newPassword));

  static Future<Response> resetPassword(String email, BuildContext context) =>
      HelperMethods.post(passwortPath, context, ResetPasswordArgs(email), true);
}
