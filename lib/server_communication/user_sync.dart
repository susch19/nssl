import 'request_classes.dart';
import 'dart:async';
import 'helper_methods.dart';
import 'package:http/http.dart';

final String path = "users";
final String path2 = "session";

class UserSync {
  static Future<Response> create(
          String username, String email, String password) =>
      HelperMethods.post("registration",
          new LoginArgs(username: username, pwHash: password, eMail: email));

  static Future<Response> login(String username, String password) =>
      HelperMethods.post(
          path2, new LoginArgs(username: username, pwHash: password));

  static Future<Response> loginEmail(String email, String password) =>
      HelperMethods.post(path2, new LoginArgs(eMail: email, pwHash: password));

  static Future<Response> info() => HelperMethods.get(path);

  static Future<Response> refreshToken() =>
      HelperMethods.put(path2, null, true);

  static Future<Response> changePassword(
          int userId, String oldPassword, String newPassword, String token) =>
      HelperMethods.put(path, new ChangePasswordArgs(oldPassword, newPassword));
}
