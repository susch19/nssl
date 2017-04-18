import 'package:testProject/Models/ShoppingItem.dart';
import 'package:testProject/Manager/Manager.dart';
import 'dart:async';

class ShoppingList { //TODO Implement with server synchronize
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
    //FileManager.writeln(filename, Name);
   // FileManager.writelist(filename+2, ShoppingItems);

    //file.writeAll(ShoppingItems,"\u{19}");
    for (var item in shoppingItems) {
      await FileManager.writeln(filename, item.toString(), append: true);
    }

   /* var li = await FileManager.readAsString(filename);
    var li2 = li.split("\u{19}");
    li2.removeLast();
    var listeBack = li2.map((s) {
      var sp = s.split("|");
      return new ShoppingItem()..name=sp[0]..amount=int.parse(sp[1]);
    });
    List<ShoppingItem> items = listeBack.toList();*/ //TODO what did i want with this?
  }
}
