import 'dart:async';
import 'dart:io';
import 'package:testProject/Manager/FileManager.dart';
import 'package:testProject/Models/Models.dart';

class Startup {
  static Future<bool> initialize() async {
    await FileManager.initialize();

    var dir = await FileManager.createFolder("ShoppingLists");
    FileManager.fileCreate("token.txt");
    FileManager.fileCreate("User.txt");
    FileManager.fileCreate("ShoppingLists.txt");

    User.token = await FileManager.readAsString("token.txt");

    User.username = await FileManager.readAsString("User.txt");

    for (var list in dir.listSync())
      if (list != null)
        User.shoppingLists.add(await ShoppingList
            .load(int.parse(list.path.split('/').last.split('.')[0])));


    if (User.shoppingLists.length > 0)
      User.currentList = User.shoppingLists[0];
    else {
      User.currentList = new ShoppingList()
        ..name = "TempList"
        ..id = 1
        ..shoppingItems = new List<ShoppingItem>();
      User.currentList.shoppingItems.add(new ShoppingItem()
        ..name =
            "Das hier soll ein sehr langer Text sein, um zu schauen, wie die App damit umgeht"
        ..amount = 2);
      User.currentList.shoppingItems.add(new ShoppingItem()
        ..name = "Test"
        ..amount = 3);
    }
    return true;
  }
}
