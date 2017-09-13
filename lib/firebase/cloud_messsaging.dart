import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:testProject/models/model_export.dart';

final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

class CloudMessaging {
  static Future onMessage(Map<String, dynamic> message, Function setState) async{
    int listId = int.parse(message["listId"]);
    if(User.ownId == int.parse(message["userId"])){
      return null;
    }
    if (User.shoppingLists
            .firstWhere((x) => x.id == listId, orElse: () => null) ==
        null) {
      var mapp = JSON.decode(message["items"]);
      //User was added to new list
      User.shoppingLists.add(new ShoppingList()
        ..id = listId
        ..name = message["Name"]
        ..shoppingItems = mapp
            .map((x) => new ShoppingItem()
              ..id = x["Id"]
              ..amount = x["Amount"]
              ..name = x["Name"])
            .toList());
      firebaseMessaging
          .subscribeToTopic(listId.toString() + "shoppingListTopic");
    } else if (message.length == 1){
    //List deleted
      User.shoppingLists.removeWhere((x) => x.id == listId);
      firebaseMessaging
          .unsubscribeFromTopic(listId.toString() + "shoppingListTopic");
    } else {
      var action = message["action"];
      var list = User.shoppingLists.firstWhere((x) => x.id == listId);
      switch (action) {
        case "ItemChanged": //Id, Amount, action
          var id = int.parse(message["Id"]);
          list.shoppingItems.firstWhere((x) => x.id == id).amount =
              int.parse(message["Amount"]);
          list.save();
          break;
        case "ItemDeleted": //Id, action
          var id = int.parse(message["Id"]);
          list.shoppingItems.removeWhere((x) => x.id == id);
          list.save();
          break;
        case "NewItemAdded": //Id, Name, Gtin, Amount, action
          if (list.shoppingItems.firstWhere(
                  (x) => x.id == int.parse(message["Id"]),
                  orElse: () => null) !=
              null) break;
          list.shoppingItems.add(new ShoppingItem()
            ..id = int.parse(message["Id"])
            ..amount = int.parse(message["Amount"])
            ..name = message["Name"]
            ..crossedOut = false);
          list.save();
          break;
        case "ListRename": //Name, action
          list.name = message["Name"];
          list.save();
          break;
        case "Refresh": //action
          await list.refresh();
          break;
      }
    }
    var args = new List();
    args.add(() {});
    Function.apply(setState, args);

    return null;
  }
}
