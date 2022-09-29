import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nssl/firebase/cloud_messsaging.dart';
import 'package:nssl/helper/iterable_extensions.dart';
import 'package:nssl/models/model_export.dart';
import 'package:nssl/manager/manager_export.dart';
import 'dart:async';
import 'package:nssl/server_communication/return_classes.dart';
import 'package:nssl/server_communication/shopping_list_sync.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shoppingListsProvider = ChangeNotifierProvider<ShoppingListController>((ref) {
  var userId = ref.watch(userIdProvider);
  if (userId == null) return ShoppingListController(ref, -1);

  var manager = ShoppingListController(ref, userId);

  return manager;
});

final listProvider = Provider.family<ShoppingList?, int>((ref, indx) {
  var shoppingListController = ref.watch(shoppingListsProvider);
  if (indx + 1 > shoppingListController.shoppingLists.length) return null;

  return shoppingListController.shoppingLists[indx];
});

final currentListProvider = Provider<ShoppingList?>((ref) {
  var index = ref.watch(currentListIndexProvider);
  if (index == null) return null;
  return ref.watch(listProvider.create(index));
});

final currentShoppingItemsProvider = Provider<List<ShoppingItem>>((ref) {
  var list = ref.watch(currentListProvider);
  if (list == null || list.id < 0) return [];
  return ref.watch(shoppingItemsPerListProvider.create(list.id));
});

final shoppingListByIndexProvider = Provider.family<ShoppingList?, int>((ref, indx) {
  var shoppingListController = ref.watch(shoppingListsProvider);
  if (indx > shoppingListController.shoppingLists.length) return null;

  return shoppingListController.shoppingLists[indx];
});

final shoppingListByIdProvider = Provider.family<ShoppingList?, int>((ref, id) {
  var shoppingListController = ref.watch(shoppingListsProvider);

  return shoppingListController.shoppingLists.firstOrNull((element) => element.id == id);
});

class ShoppingListController with ChangeNotifier {
  static late Ref _ref;
  static late int _userId;
  List<ShoppingList> shoppingLists = [];

  ShoppingListController(Ref ref, int userId) {
    _ref = ref;
    _userId = userId;
  }

  Future save(ShoppingList list) async {
    await DatabaseManager.database.transaction((z) async {
      await z.execute('INSERT OR REPLACE INTO ShoppingLists(id, name, messaging, user_id) VALUES(?, ?, ?, ?)',
          [list.id, list.name, list.messagingEnabled ? 1 : 0, _userId]);
      var shoppingItems = _ref.read(shoppingItemsPerListProvider.create(list.id));
      await z.rawDelete("DELETE FROM ShoppingItems WHERE res_list_id = ? and id not in (?)",
          [list.id, shoppingItems.map((e) => e.id).join(",")]);
      for (var item in shoppingItems) {
        await z.execute(
            "INSERT OR REPLACE INTO ShoppingItems(id, name, amount, crossed, res_list_id, sortorder) VALUES (?, ?, ?, ?, ?, ?)",
            [item.id, item.name, item.amount, item.crossedOut ? 1 : 0, list.id, item.sortOrder]);
      }
    });
  }

  Future addSingleItem(ShoppingList list, ShoppingItem item, {int index = -1}) async {
    // var shoppingItems = _ref.read(shoppingItemsPerListProvider.create(list.id));
    // if (index < 0) index = shoppingItems.length;
    // shoppingItems.insert(index, item);

    // var newList = ShoppingList(list.id, list.name, messagingEnabled: list.messagingEnabled);
    // _exchangeLists(list, newList);
    var sip = _ref.watch(shoppingItemsProvider.notifier);
    var newState = sip.state.toList();
    newState.add(item);
    sip.state = newState;

    await DatabaseManager.database.execute(
        "INSERT OR REPLACE INTO ShoppingItems(id, name, amount, crossed, res_list_id, sortorder) VALUES (?, ?, ?, ?, ?, ?)",
        [item.id, item.name, item.amount, item.crossedOut ? 1 : 0, list.id, item.sortOrder]);
    save(list);
    notifyListeners();
  }

  Future deleteSingleItemById(ShoppingList list, int itemId) async {
    var sip = _ref.watch(shoppingItemsProvider.notifier);
    var newState = sip.state.toList();
    newState.removeWhere((x) => x.id == itemId);
    sip.state = newState;
    // var newList = ShoppingList(list.id, list.name, list.shoppingItems.where((element) => element != item).toList(),
    //     messagingEnabled: list.messagingEnabled);
    // _exchangeLists(list, newList);
    await DatabaseManager.database.rawDelete("DELETE FROM ShoppingItems WHERE id = ?", [itemId]);
    save(list);
  }

  Future deleteSingleItem(ShoppingList list, ShoppingItem item) async {
    var sip = _ref.watch(shoppingItemsProvider.notifier);
    var newState = sip.state.toList();
    newState.remove(item);
    sip.state = newState;
    // var newList = ShoppingList(list.id, list.name, list.shoppingItems.where((element) => element != item).toList(),
    //     messagingEnabled: list.messagingEnabled);
    // _exchangeLists(list, newList);
    await DatabaseManager.database.rawDelete("DELETE FROM ShoppingItems WHERE id = ?", [item.id]);
    save(list);
  }

  Future<List<ShoppingList>> load() async {
    var lists = await DatabaseManager.database.rawQuery("SELECT * FROM ShoppingLists WHERE user_id = ?", [_userId]);

    var items = await DatabaseManager.database.rawQuery("SELECT * FROM ShoppingItems ORDER BY res_list_id, sortorder");

    int curSortOrder = 0;
    var newShoppingItems = items.map(
      (y) {
        var sortOrder = y["sortorder"] as int?;
        if (sortOrder != null)
          curSortOrder = sortOrder;
        else
          curSortOrder++;
        return ShoppingItem(
          y["name"] as String,
          y["res_list_id"] as int,
          curSortOrder,
          amount: y["amount"] as int,
          crossedOut: y["crossed"] == 0 ? false : true,
          id: y["id"] as int,
        );
      },
    ).toList();

    shoppingLists = lists
        .map((x) =>
            ShoppingList(x["id"] as int, x["name"] as String, messagingEnabled: x["messaging"] == 0 ? false : true))
        .toList();

    var sip = _ref.watch(shoppingItemsProvider.notifier);
    sip.state = newShoppingItems;

    notifyListeners();
    return shoppingLists;
  }

  Future refresh(ShoppingList list, [BuildContext? context]) async {
    var res = await ShoppingListSync.getList(list.id, context);

    var newListResult = GetListResult.fromJson(res.body);
    List<Map<String, dynamic>> items;
    items = (await DatabaseManager.database
        .rawQuery("SELECT id, crossed, sortorder FROM ShoppingItems WHERE res_list_id = ?", [list.id]));

    var shoppingItems = <ShoppingItem>[];
    var sip = _ref.watch(shoppingItemsProvider.notifier);
    var newState = sip.state.toList();
    newState.removeWhere((item) => item.listId == list.id);

    for (var item in newListResult.products!)
      shoppingItems.add(ShoppingItem(
        item.name,
        list.id,
        item.sortOrder,
        id: item.id,
        amount: item.amount,
        changed: item.changed,
        created: item.created,
        crossedOut:
            (items.firstWhere((x) => x["id"] == item.id, orElse: () => {"crossed": 0})["crossed"] == 0 ? false : true),
      ));

    shoppingItems.sort((a, b) => a.sortWithOffset.compareTo(b.sortWithOffset));
    newState.addAll(shoppingItems);
    var newList = ShoppingList(list.id, list.name, messagingEnabled: list.messagingEnabled);
    _exchangeLists(list, newList);
    sip.state = newState;
    save(newList);

    notifyListeners();
  }

  void _exchangeLists(ShoppingList list, ShoppingList newList) {
    var index = shoppingLists.indexOf(list);
    shoppingLists.remove(list);
    shoppingLists.insert(index, newList);
    notifyListeners();
  }

  Future<Null> reloadAllLists([BuildContext? cont]) async {
    var res = (await ShoppingListSync.getLists(cont));
    if (res.statusCode != 200) return;

    // DatabaseManager.database.rawDelete("DELETE FROM ShoppingLists where user_id = ?", _ref.read())) //TODO Should everything be deleted from this user?

    var result = GetListsResult.fromJson(res.body);
    shoppingLists.clear();
    await DatabaseManager.database.delete("ShoppingLists", where: "user_id = ?", whereArgs: [_userId]);

    List<Map<String, dynamic>> items;
    items = (await DatabaseManager.database
        .rawQuery("SELECT id, crossed, sortorder FROM ShoppingItems where crossed = 1 or sortorder > 0"));

    var shoppintItemsState = _ref.watch(shoppingItemsProvider.notifier);
    var shoppingItems = <ShoppingItem>[];
    for (var res in result.shoppingLists) {
      int currentSortOrder = -1;
      for (var item in res.products) {
        var order = items.firstWhere((x) => x["id"] == item.id,
            orElse: () => {"sortorder": item.sortOrder})["sortorder"] as int;
        if (order == -1 || currentSortOrder == order)
          order = ++currentSortOrder;
        else
          currentSortOrder = order;
        shoppingItems.add(ShoppingItem(
          item.name,
          res.id,
          order,
          id: item.id,
          amount: item.amount,
          changed: item.changed,
          created: item.created,
          crossedOut: (items.firstWhere((x) => x["id"] == item.id, orElse: () => {"crossed": 0})["crossed"] == 0
              ? false
              : true),
        ));
      }

      // if (shoppingItems.any((element) => element.sortOrder == null))
      //   for (int i = 0; i < shoppingItems.length; i++) {
      //     var oldItem = shoppingItems[i];
      //     shoppingItems.removeAt(i);
      //     shoppingItems.insert(
      //         i,
      //         ShoppingItem(oldItem.name, oldItem.listId,  i,
      //             id: oldItem.id,
      //             crossedOut: oldItem.crossedOut,
      //             amount: oldItem.amount,
      //             changed: oldItem.changed,
      //             created: oldItem.created));
      //   }

      var list = ShoppingList(res.id, res.name);
      shoppingLists.add(list);
      list.subscribeForFirebaseMessaging();
      save(list);
    }
    shoppingItems.sort((a, b) => a.sortWithOffset.compareTo(b.sortWithOffset));
    shoppintItemsState.state = shoppingItems;
    notifyListeners();
  }

  void addList(ShoppingList shoppingList) {
    shoppingLists.add(shoppingList);
    shoppingList.subscribeForFirebaseMessaging();
    save(shoppingList);
    notifyListeners();
  }

  void removeList(int listId) {
    shoppingLists.removeWhere((x) => x.id == listId);

    firebaseMessaging?.unsubscribeFromTopic(listId.toString() + "shoppingListTopic");
    notifyListeners();
  }

  void saveAndNotify(ShoppingList list) {
    save(list);
    notifyListeners();
  }

  void toggleFirebaseMessaging(int listId) {
    var list = shoppingLists.firstWhere((element) => element.id == listId);
    var newList = ShoppingList(listId, list.name, messagingEnabled: !list.messagingEnabled);
    newList.messagingEnabled ? list.subscribeForFirebaseMessaging() : list.unsubscribeFromFirebaseMessaging();
    _exchangeLists(list, newList);
    save(newList);
  }

  void rename(int id, String name) {
    var list = shoppingLists.firstWhere((element) => element.id == id);

    var newList = ShoppingList(id, name, messagingEnabled: list.messagingEnabled);
    _exchangeLists(list, newList);
    saveAndNotify(list);
  }
}

@immutable
class ShoppingList {
  static ShoppingList empty = const ShoppingList.messaging(1, "", false);

  final int id;
  final String name;
  // final List<ShoppingItem> shoppingItems;
  final bool messagingEnabled;

  const ShoppingList(this.id, this.name, /*this.shoppingItems,*/ {this.messagingEnabled = true});

  const ShoppingList.messaging(this.id, this.name, /*this.shoppingItems,*/ this.messagingEnabled);

  void subscribeForFirebaseMessaging() {
    if (kIsWeb) return;
    firebaseMessaging?.subscribeToTopic(id.toString() + "shoppingListTopic");
  }

  void unsubscribeFromFirebaseMessaging() {
    if (kIsWeb) return;
    firebaseMessaging?.unsubscribeFromTopic(id.toString() + "shoppingListTopic");
  }
}
