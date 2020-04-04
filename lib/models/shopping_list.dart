import 'package:flutter/material.dart';
import 'package:nssl/firebase/cloud_messsaging.dart';
import 'package:nssl/models/shopping_item.dart';
import 'package:nssl/manager/manager_export.dart';
import 'package:nssl/models/user.dart';
import 'dart:async';
import 'package:nssl/server_communication/return_classes.dart';
import 'package:nssl/server_communication/shopping_list_sync.dart';

class ShoppingList {
  int id;
  String name;
  List<ShoppingItem> shoppingItems = new List<ShoppingItem>();
  bool messagingEnabled = true;

  Future save() async {
    await DatabaseManager.database.transaction((z) async {
      int count = await z.rawUpdate('UPDATE ShoppingLists SET name = ?, messaging = ? WHERE id = ?', [name, messagingEnabled ? 1 : 0, id]);
      if (count == 0)
        await z.rawInsert('INSERT INTO ShoppingLists(id, name, messaging, user_id) VALUES(?, ?, ?, ?)', [id, name, messagingEnabled ? 1 : 0, User.ownId]);

      await z.rawDelete("DELETE FROM ShoppingItems WHERE res_list_id = ?", [id]);
      for (var item in shoppingItems) {
        await z.execute("INSERT OR REPLACE INTO ShoppingItems(id, name, amount, crossed, res_list_id, sortorder) VALUES (?, ?, ?, ?, ?, ?)",
            [item.id, item.name, item.amount, item.crossedOut ? 1 : 0, id, item.sortOrder]);
      }
    });
  }

  static Future<List<ShoppingList>> load() async {
    var lists = await DatabaseManager.database.rawQuery("SELECT * FROM ShoppingLists WHERE user_id = ?", [User.ownId]);

    var items = await DatabaseManager.database.rawQuery("SELECT * FROM ShoppingItems ORDER BY res_list_id, sortorder");

    // TODO: if db ordering enough for us, or do we want to order by ourself in code?
    // return lists
    //     .map((x) => new ShoppingList()
    //       ..id = x["id"]
    //       ..messagingEnabled = x["messaging"] == 0 ? false : true
    //       ..name = x["name"]
    //       ..shoppingItems = (items
    //           .where((y) => y["res_list_id"] == x["id"])
    //           .map((y) => new ShoppingItem(y["name"])
    //             ..amount = y["amount"]
    //             ..crossedOut = y["crossed"] == 0 ? false : true
    //             ..id = y["id"]
    //             ..sortOrder = y["sortorder"])
    //           .toList()
    //             ..sort((a, b) => a.sortOrder?.compareTo(b.sortOrder))))
    //     .toList();

    return lists
        .map((x) => new ShoppingList()
          ..id = x["id"]
          ..messagingEnabled = x["messaging"] == 0 ? false : true
          ..name = x["name"]
          ..shoppingItems = items
              .where((y) => y["res_list_id"] == x["id"])
              .map((y) => new ShoppingItem(y["name"])
                ..amount = y["amount"]
                ..crossedOut = y["crossed"] == 0 ? false : true
                ..id = y["id"]
                ..sortOrder = y["sortorder"])
              .toList())
        .toList();
  }

  Future refresh([BuildContext context]) async {
    var res = await ShoppingListSync.getList(id, context);
//    if (res.statusCode == 401) {
//      showInSnackBar(loc.notLoggedInYet() + res.reasonPhrase);
//      return;
//    }
//    if (res.statusCode != 200) {
//      showInSnackBar(loc.genericErrorMessageSnackbar());
//      return;
//    }
    var newList = GetListResult.fromJson(res.body);
    var items = (await DatabaseManager.database.rawQuery("SELECT id, crossed, sortorder FROM ShoppingItems WHERE res_list_id = ?", [id]));

    shoppingItems.clear();
    for (var item in newList.products)
      shoppingItems.add(new ShoppingItem(item.name)
        ..id = item.id
        ..amount = item.amount
        ..changed = item.changed
        ..created = item.created
        ..crossedOut = (items.firstWhere((x) => x["id"] == item.id, orElse: () => {"crossed": 0})["crossed"] == 0 ? false : true)
        ..sortOrder = (items.firstWhere((x) => x["id"] == item.id, orElse: () => {"sortorder": 0})["sortorder"]));

    shoppingItems.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    save();
  }

  static Future<Null> reloadAllLists([BuildContext cont]) async {
    var result = GetListsResult.fromJson((await ShoppingListSync.getLists(cont)).body);
    User.shoppingLists.clear();
    await DatabaseManager.database.delete("ShoppingLists", where: "user_id = ?", whereArgs: [User.ownId]);
    //await DatabaseManager.database.rawDelete("DELETE FROM ShoppingLists where user_id = ?", [User.ownId]);
    var items = (await DatabaseManager.database.rawQuery("SELECT id, crossed, sortorder FROM ShoppingItems"));
    for (var res in result.shoppingLists) {
      var list = new ShoppingList()
        ..id = res.id
        ..name = res.name
        ..shoppingItems = new List<ShoppingItem>();

      for (var item in res.products)
        list.shoppingItems.add(new ShoppingItem(item.name)
          ..id = item.id
          ..amount = item.amount
          ..crossedOut = (items.firstWhere((x) => x["id"] == item.id, orElse: () => {"crossed": 0})["crossed"] == 0 ? false : true)
          ..sortOrder = (items.firstWhere((x) => x["id"] == item.id, orElse: () => {"sortorder": 0})["sortorder"]));

      list.shoppingItems.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      User.shoppingLists.add(list);

      list.subscribeForFirebaseMessaging();
      list.save();
    }
  }

  void subscribeForFirebaseMessaging() => firebaseMessaging.subscribeToTopic(id.toString() + "shoppingListTopic");

  void unsubscribeFromFirebaseMessaging() => firebaseMessaging.unsubscribeFromTopic(id.toString() + "shoppingListTopic");
}
