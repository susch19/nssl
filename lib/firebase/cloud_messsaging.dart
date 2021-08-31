import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nssl/models/model_export.dart';

FirebaseMessaging? get firebaseMessaging => Platform.isAndroid ? FirebaseMessaging.instance : null;

class CloudMessaging {
  static Future onMessage(RemoteMessage message, Function setState) async {
   
    final dynamic data = message.data;

    int listId = int.parse(data["listId"]);
    if (User.ownId == int.parse(data["userId"])) {
      return null;
    }

    if (User.shoppingLists.firstWhere((x) => x.id == listId, orElse: () => ShoppingList.empty) == ShoppingList.empty) {
      var mapp = jsonDecode(data["items"]);
      //User was added to new list
      User.shoppingLists.add(ShoppingList(listId, data["name"])
        ..shoppingItems = mapp
            .map((x) => ShoppingItem(x["name"])
              ..id = x["id"]
              ..amount = x["amount"]
              ..sortOrder = x["sortOrder"])
            .toList());
      firebaseMessaging!.subscribeToTopic(listId.toString() + "shoppingListTopic");
    } else if (data.length == 1) {
      //List deleted
      User.shoppingLists.removeWhere((x) => x.id == listId);
      firebaseMessaging!.unsubscribeFromTopic(listId.toString() + "shoppingListTopic");
    } else {
      var action = data["action"];
      var list = User.shoppingLists.firstWhere((x) => x.id == listId);
      switch (action) {
        case "ItemChanged": //Id, Amount, action
          var id = int.parse(data["id"]);
          list.shoppingItems!.firstWhere((x) => x!.id == id)!.amount = int.parse(data["amount"]);
          list.save();
          break;
        case "ItemDeleted": //Id, action
          var id = int.parse(data["id"]);
          list.shoppingItems!.removeWhere((x) => x!.id == id);
          list.save();
          break;
        case "NewItemAdded": //Id, Name, Gtin, Amount, action
          if (list.shoppingItems!.firstWhere((x) => x!.id == int.parse(data["id"]), orElse: () => null) != null) break;
          list.shoppingItems!.add(ShoppingItem(data["name"])
            ..id = int.parse(data["id"])
            ..amount = int.parse(data["amount"])
            ..crossedOut = false
            ..sortOrder = int.parse(data["sortOrder"]));
          list.save();
          break;
        case "ListRename": //Name, action
          list.name = data["name"];
          list.save();
          break;
        case "Refresh": //action
          await list.refresh();
          break;
        case "ItemRenamed": //product.Id, product.Name
          list.shoppingItems!.firstWhere((x) => x!.id == int.parse(data["id"]))!.name = data["name"];
          list.save();
          break;
        case "OrderChanged":
          var id = int.parse(data["id"]);
          list.shoppingItems!.firstWhere((x) => x!.id == id)!.sortOrder = int.parse(data["sortOrder"]);
          list.save();
          break;
      }
    }
    var args = [];
    args.add(() {});
    Function.apply(setState, args);

    return null;
  }
}
