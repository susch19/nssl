import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:testProject/models/model_export.dart';

final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

class CloudMessaging {
  static Future onMessage(Map<String, dynamic> message, Function setState) {
    int listId = int.parse(message["listId"]);

    if (User.shoppingLists.firstWhere((x) => x.id == listId, orElse: null) ==
        null) {
      //User was added to new list
      User.shoppingLists.add(new ShoppingList()
        ..id = listId
        ..name = message["name"]
        ..shoppingItems = message["products"].map((x) => new ShoppingItem()
          ..id = x["id"]
          ..amount = x["amount"]
          ..name = x["name"]));
    } else if(message.length == 1)
      //List deleted
      User.shoppingLists.removeWhere((x) => x.id == listId);
    else if (message.containsKey("amount")) {
      //Item changed
      var id = int.parse(message["id"]);
      var list = User.shoppingLists.firstWhere((x) => x.id == listId);
      list.shoppingItems.firstWhere((x) => x.id == id).amount =
          int.parse(message["amount"]);
    } else if (message.containsKey("id") && !message.containsKey("amount")) {
      //Item deleted
      var id = int.parse(message["id"]);
      var list = User.shoppingLists.firstWhere((x) => x.id == listId);
      list.shoppingItems.removeWhere((x) => x.id == id);
    } else if (message.containsKey("productId")) {
      //New item added
      var list = User.shoppingLists.firstWhere((x) => x.id == listId);
      list.shoppingItems.add(new ShoppingItem()
        ..id = int.parse(message["productId"])
        ..amount = 1
        ..name = message["name"]
        ..crossedOut = false);
    }
    var args = new List();
    args.add((){});
    Function.apply(setState, args);

    return null;
  }
}
