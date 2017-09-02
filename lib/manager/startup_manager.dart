import 'dart:async';
import 'package:flutter/material.dart';
import 'package:testProject/manager/file_manager.dart';
import 'package:testProject/models/model_export.dart';
import 'package:testProject/options/themes.dart';
import 'package:testProject/server_communication/return_classes.dart';
import 'package:testProject/server_communication/s_c.dart';

class Startup {
  static Future<bool> initialize() async {
    await DatabaseManager.initialize();
    await Themes.loadTheme();

    await User.load();

    if (User.username == "" || User.eMail == "")
      return;

    var res = await ShoppingListSync.getLists(null);
    if (res.statusCode == 200) {
      var result = GetListsResult.fromJson(res.body);

      User.shoppingLists.clear();
      var crossedOut = (await DatabaseManager.database
          .rawQuery("SELECT id, crossed FROM ShoppingItems WHERE crossed = 1"));
      for (var res in result.shoppingLists) {
        var list = new ShoppingList()
          ..id = res.id
          ..name = res.name
          ..shoppingItems = new List<ShoppingItem>();

        for (var item in res.products)
          list.shoppingItems.add(new ShoppingItem()
            ..name = item.name
            ..id = item.id
            ..amount = item.amount
            ..crossedOut = (crossedOut.firstWhere((x) => x["id"] == item.id,
                        orElse: () => {"crossed": 0})["crossed"] ==
                    0
                ? false
                : true));
        User.shoppingLists.add(list);
        list.save();
      }
    } else
      User.shoppingLists = await ShoppingList.load();
    User.currentList = User.shoppingLists.firstWhere(
        (x) => x.id == User.currentListIndex,
        orElse: () => User.shoppingLists.first);

    return true;
    // FileManager.createFolder("ShoppingListsCo");
    // FileManager.createFile("token.txt");
    // FileManager.createFile("User.txt");
    // FileManager.createFile("listList.txt");

    // User.token = await FileManager.readAsString("token.txt");

    // var userData = await FileManager.readAsLines("User.txt");
    // if(userData.where((s)=> s.isNotEmpty).length == 2) {
    //   User.username = userData[0];
    //   User.eMail = userData[1];
    // }
    // else {
    //   User.username = null;
    //   User.eMail = null;
    // }
    // for (var list in dir.listSync())
    //   if (list != null)
    //     User.shoppingLists.add(await ShoppingList
    //         .load(int.parse(list.path.split('/').last.split('.')[0])));

    // await Themes.loadTheme();

    // if (User.shoppingLists.length > 0) {
    //   var listId = int.parse(await FileManager.readAsString("lastList.txt"));
    //   User.currentList = User.shoppingLists.firstWhere((x) => x.id == listId);
    // } else {
    //   User.currentList = new ShoppingList()
    //     ..name = "No List yet"
    //     ..id = 1
    //     ..shoppingItems = new List<ShoppingItem>();
    // }
    // User.currentListIndex = User.currentList.id;
    // await User.save();
  }
}
