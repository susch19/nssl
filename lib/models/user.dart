import 'dart:async';

import 'package:testProject/manager/file_manager.dart';
import 'package:testProject/models/shopping_list.dart';
import 'package:testProject/server_communication/jwt.dart';

class User {
  static String username;
  static String eMail;
  static List<ShoppingList> shoppingLists = new List<ShoppingList>();
  static String token;
  static int currentListIndex;
  static ShoppingList currentList;
  static int ownId;

  static Future load() async {
    var list = (await DatabaseManager.database.rawQuery("SELECT * FROM User LIMIT 1"));
    if(list.length == 0)
      return;
    var z = list.first;
    User.username = z["username"];
      User.eMail = z["email"];
      User.token = z["token"];
      User.currentListIndex = z["current_list_index"];
      if(!z.containsKey("own_id"))
      {
        await DatabaseManager.database.execute("DROP TABLE User");
        await DatabaseManager.database.execute("CREATE TABLE User (own_id INTEGER, username TEXT, email TEXT, token TEXT, current_list_index INTEGER)");
        User.ownId = await JWT.getIdFromToken(User.token);
        await save();
      }
      else
        User.ownId = z["own_id"];
  }

  static Future save() async {
    await DatabaseManager.database.rawDelete("DELETE FROM User");
    await DatabaseManager.database.rawInsert(
        "INSERT INTO User(own_id, username, email, token, current_list_index) VALUES(?, ?, ?, ?, ?)",
        [User.ownId, User.username, User.eMail, User.token, User.currentListIndex]);
  }
}
