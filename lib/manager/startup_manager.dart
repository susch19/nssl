import 'dart:async';
import 'package:testProject/manager/file_manager.dart';
import 'package:testProject/models/model_export.dart';

class Startup {
  static Future<bool> initialize() async {
    await FileManager.initialize();

    var dir = await FileManager.createFolder("ShoppingLists");
    FileManager.createFile("token.txt");
    FileManager.createFile("User.txt");
    FileManager.createFile("listList.txt");

    User.token = await FileManager.readAsString("token.txt");

    var userData = await FileManager.readAsLines("User.txt");
    User.username = userData[0];
    User.eMail = userData[1];

    for (var list in dir.listSync())
      if (list != null)
        User.shoppingLists.add(await ShoppingList
            .load(int.parse(list.path.split('/').last.split('.')[0])));

    if (User.shoppingLists.length > 0) {
      var listId = int.parse(await FileManager.readAsString("lastList.txt"));
      User.currentList = User.shoppingLists.firstWhere((x) => x.id == listId);
    } else {
      User.currentList = new ShoppingList()
        ..name = "No List yet"
        ..id = 1
        ..shoppingItems = new List<ShoppingItem>();
    }
    return true;
  }
}
