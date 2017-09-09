import 'dart:async';

import 'package:testProject/manager/file_manager.dart';
import 'package:testProject/models/shopping_list.dart';

class User {
  static String username;
  static String eMail;
  static List<ShoppingList> shoppingLists = new List<ShoppingList>();
  static String token;
  static int currentListIndex;
  static ShoppingList currentList;

  static Future load() async {
    var z = (await DatabaseManager.database.rawQuery("SELECT * FROM User LIMIT 1")).first;

      User.username = z["username"];
      User.eMail = z["email"];
      User.token = z["token"];
      User.currentListIndex = z["current_list_index"];
    
  }

  static Future save() async {
    await DatabaseManager.database.rawDelete("DELETE FROM User");
    await DatabaseManager.database.rawInsert(
        "INSERT INTO User(username, email, token, current_list_index) VALUES(?, ?, ?, ?)",
        [User.username, User.eMail, User.token, User.currentListIndex]);
  }
}
