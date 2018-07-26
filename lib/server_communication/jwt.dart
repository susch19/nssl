import 'dart:async';
import 'dart:convert';
import 'package:testProject/models/user.dart';

class JWT {
  static Future<bool> newToken() async {
    //JsonWebToken jwt = new JsonWebToken.decode(User.token);
    String jwt = tokenToJson();
    var exp = jwt.substring(jwt.indexOf("expires"), jwt.indexOf('Z\",\n'));
    DateTime expires = DateTime.parse(exp.substring(11, exp.indexOf(".")));
    if ((new DateTime.now()).add(new Duration(days: 29)).isAfter(expires))
      return true;
    return false;
  }

  static String tokenToJson() {
    var s = User.token;
    var temps = s
        .substring(s.indexOf(".")+1, s.lastIndexOf("."));
    if(temps.length % 4 != 0)
      temps = temps.padRight(temps.length+(4-temps.length%4), "=");
    return Utf8Decoder().convert(Base64Codec().decode(temps));
  }

  static Future<int> getIdFromToken(String token) async {
    //JsonWebToken jwt = new JsonWebToken.decode(token);
    //var map = jwt.payload.toJson();
    //return int.parse(map["id"]);
    String jwt = tokenToJson();
    var exp = jwt.substring(jwt.indexOf("id"), jwt.indexOf(',\n', jwt.indexOf("id")));
    return int.parse(exp.substring(5));

//    DateTime.parse("2018-07-07T10:49:56.9479953Z");
//    var codec = Base64Codec.urlSafe();
//    var s = codec.decode(User.token
//        .substring(User.token.indexOf("."), User.token.lastIndexOf(".")));
//    return 10;


  }
}
