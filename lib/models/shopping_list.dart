import 'package:flutter/material.dart';
import 'package:testProject/firebase/cloud_messsaging.dart';
import 'package:testProject/models/shopping_item.dart';
import 'package:testProject/manager/manager_export.dart';
import 'dart:async';
import 'package:testProject/server_communication/return_classes.dart';
import 'package:testProject/server_communication/shopping_list_sync.dart';

class ShoppingList {
  int id;
  String name;
  List<ShoppingItem> shoppingItems = new List<ShoppingItem>();
  bool messagingEnabled = true;

  Future save() async {
    await DatabaseManager.database.inTransaction(() async {
      int count = await DatabaseManager.database.rawUpdate(
          'UPDATE ShoppingLists SET name = ?, messaging = ? WHERE id = ?',
          [name, messagingEnabled ? 1 : 0, id]);
      if (count == 0)
        await DatabaseManager.database.rawInsert(
            'INSERT INTO ShoppingLists(id, name, messaging) VALUES(?, ?, ?)',
            [id, name, messagingEnabled ? 1 : 0]);

      await DatabaseManager.database
          .rawDelete("DELETE FROM ShoppingItems WHERE res_list_id = ?", [id]);
      for (var item in shoppingItems) {
        await DatabaseManager.database.rawInsert(
            "INSERT INTO ShoppingItems(id, name, amount, crossed, res_list_id) VALUES (?, ?, ?, ?, ?)",
            [item.id, item.name, item.amount, item.crossedOut ? 1 : 0, id]);
      }
    });
  }

  static Future<List<ShoppingList>> load() async {
    var items =
        await DatabaseManager.database.rawQuery("SELECT * FROM ShoppingItems");
    var lists =
        await DatabaseManager.database.rawQuery("SELECT * FROM ShoppingLists");

    return lists
        .map((x) => new ShoppingList()
          ..id = x["id"]
          ..messagingEnabled = x["messaging"] == 0 ? false : true
          ..name = x["name"]
          ..shoppingItems = items
              .where((y) => y["res_list_id"] == x["id"])
              .map((y) => new ShoppingItem()
                ..amount = y["amount"]
                ..crossedOut = y["crossed"] == 0 ? false : true
                ..id = y["id"]
                ..name = y["name"])
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
    var crossedOut = (await DatabaseManager.database.rawQuery(
        "SELECT id, crossed FROM ShoppingItems WHERE res_list_id = ?", [id]));

    shoppingItems.clear();
    for (var item in newList.products)
      shoppingItems.add(new ShoppingItem()
        ..name = item.name
        ..id = item.id
        ..amount = item.amount
        ..crossedOut = (crossedOut.firstWhere((x) => x["id"] == item.id,
                    orElse: () => {"crossed": 0})["crossed"] ==
                0
            ? false
            : true));
    save();
  }

  void subscribeForFirebaseMessaging() =>
      firebaseMessaging.subscribeToTopic(id.toString() + "shoppingListTopic");

  void unsubscribeFromFirebaseMessaging() => firebaseMessaging
      .unsubscribeFromTopic(id.toString() + "shoppingListTopic");
}
