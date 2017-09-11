import 'dart:async';
import 'package:jwt/json_web_token.dart';
import 'package:testProject/models/user.dart';

class JWT {
  static Future<bool> newToken() async {
    JsonWebTokenDecoder dec = new JsonWebTokenDecoder();
    var map = dec.convert(User.token);
    DateTime expires = DateTime.parse(map["expires"].substring(0, 10));
    if ((new DateTime.now()).add(new Duration(days: 29)).isAfter(expires))
      return true;
    return false;
  }

  static Future<int> getIdFromToken(String token) async{
    JsonWebTokenDecoder dec = new JsonWebTokenDecoder();
    var map = dec.convert(token);
    return int.parse(map["id"]);
  }
}
