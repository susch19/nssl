import 'dart:async';
import 'package:nssl/manager/file_manager.dart';
import 'package:nssl/models/model_export.dart';
import 'package:nssl/options/themes.dart';
import 'package:nssl/server_communication/return_classes.dart';
import 'package:nssl/server_communication/s_c.dart';

class Startup {
  static Future<bool> initialize() async {

    await DatabaseManager.initialize();

    await User.load();

    if (User.username == null || User.username == "" || User.eMail == null || User.eMail == "") return false;
    await Themes.loadTheme();
    User.shoppingLists = await ShoppingList.load();
    if(User.shoppingLists.length == 0)
      return true;
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

  static Future initializeNewListsFromServer() async {
    var res = await ShoppingListSync.getLists(null);


    if (res.statusCode == 200) {
      var result = GetListsResult.fromJson(res.body);

      User.shoppingLists.clear();
      await DatabaseManager.database.rawDelete("DELETE FROM ShoppingLists where user_id = ?", [User.ownId]);

      var crossedOut = (await DatabaseManager.database
          .rawQuery("SELECT id, crossed FROM ShoppingItems WHERE crossed = 1"));
      result.shoppingLists.forEach((resu) {
        var list = new ShoppingList()
          ..id = resu.id
          ..name = resu.name
          ..shoppingItems = new List<ShoppingItem>();

        for (var item in resu.products)
          list.shoppingItems.add(new ShoppingItem(item.name)
            ..id = item.id
            ..amount = item.amount
            ..crossedOut = (crossedOut.firstWhere((x) => x["id"] == item.id,
                        orElse: () => {"crossed": 0})["crossed"] ==
                    0
                ? false
                : true));
        User.shoppingLists.add(list);
        list.save();
      });
    }
    User.currentList = User.shoppingLists.firstWhere(
            (x) => x.id == User.currentListIndex,
        orElse: () => User.shoppingLists.first);

    return true;
  }
}
