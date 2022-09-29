import 'dart:async';
import 'dart:convert';
import 'package:nssl/models/user.dart';

class JWT {
  static Future<bool> newToken() async {
    //JsonWebToken jwt = JsonWebToken.decode(User.token);
    var jwt = jsonDecode(tokenToJson(User.token));

    // var expiresEnd = jwt.indexOf('Z\",\n');
    // if(expiresEnd == -1)
    //     expiresEnd = jwt.indexOf('Z\",\r\n');

    // var exp = jwt.substring(jwt.indexOf("expires"), jwt.indexOf('Z\",\n'));
    DateTime expires = DateTime.parse(jwt["expires"]);
    if ((DateTime.now()).add(Duration(days: 29)).isAfter(expires)) return true;
    return false;
  }

  static String tokenToJson(String? token) {
    if (token == null || token == "") return "";
    var temps = token.substring(token.indexOf(".") + 1, token.lastIndexOf("."));
    if (temps.length % 4 != 0) temps = temps.padRight(temps.length + (4 - temps.length % 4), "=");
    return Utf8Decoder().convert(Base64Codec().decode(temps));
  }

  static Future<int> getIdFromToken(String? token) async {
    //JsonWebToken jwt = JsonWebToken.decode(token);
    //var map = jwt.payload.toJson();
    //return int.parse(map["id"]);
    var jwt = jsonDecode(tokenToJson(token));
    return jwt["id"];

//    DateTime.parse("2018-07-07T10:49:56.9479953Z");
//    var codec = Base64Codec.urlSafe();
//    var s = codec.decode(User.token
//        .substring(User.token.indexOf("."), User.token.lastIndexOf(".")));
//    return 10;
  }
}
