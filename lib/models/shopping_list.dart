import 'package:testProject/models/shopping_item.dart';
import 'package:testProject/manager/manager_export.dart';
import 'dart:async';

class ShoppingList {
  int id;
  String name;
  List<ShoppingItem> shoppingItems;

  static Future<ShoppingList> load(int id) async {
    var items =
        await FileManager.readAsLines("ShoppingLists/${id.toString()}.sl");
    return new ShoppingList()
      ..id = id
      ..name = items[0]
      ..shoppingItems = items.sublist(1).where((s) => s != "").map((s) {
        var split = s.split("\u{1F}");
        var item = new ShoppingItem()
          ..name = split[0]
          ..amount = int.parse(split[1])
          ..id = int.parse(split[2]);
        return item;
      }).toList();
  }

  Future save() async {
    var filename = "ShoppingLists/${id.toString()}.sl";
    if (FileManager.fileExists(filename))
      await FileManager.deleteFile(filename);
    await FileManager.createFile(filename);
    await FileManager.writeln(filename, name);

    for (var item in shoppingItems) {
      await FileManager.writeln(filename, item.toString(), append: true);
    }
  }
}
