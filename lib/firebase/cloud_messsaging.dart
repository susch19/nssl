import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nssl/helper/iterable_extensions.dart';
import 'package:nssl/manager/startup_manager.dart';
import 'package:nssl/models/model_export.dart';
import 'package:nssl/server_communication/helper_methods.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cloud_messsaging.g.dart';

FirebaseMessaging? get firebaseMessaging =>
    Startup.firebaseSupported() ? FirebaseMessaging.instance : null;

@Riverpod(keepAlive: true)
class CloudMessaging extends _$CloudMessaging {
  @override
  void build() {
    return;
  }

  Future onMessage(RemoteMessage message) async {
    final dynamic data = message.data;
    final deviceToken = data["deviceToken"];
    if (deviceToken != null && deviceToken == HelperMethods.deviceToken) return;

    int listId = int.parse(data["listId"]);
    var ownId = ref.read(userIdProvider);
    if (deviceToken == null && ownId == int.parse(data["userId"])) {
      return null;
    }
    var listController = ref.read(shoppingListsProvider);

    var list = listController.shoppingLists.firstOrNull(
      (element) => element.id == listId,
    );

    if (list == null) {
      var mapp = jsonDecode(data["items"]);
      //User was added to new list
      var items = ref.watch(shoppingItemsProvider.notifier);
      var newState = items.state.toList();
      newState.addAll(
        mapp.map(
          (x) => ShoppingItem(
            x["name"],
            listId,
            x["sortOrder"],
            id: x["id"],
            amount: x["amount"],
          ),
        ),
      );
      items.state = newState;
      listController.addList(ShoppingList(listId, data["name"]));
    } else if (data.length == 1) {
      //List deleted
      listController.removeList(listId);
    } else {
      var action = data["action"];
      var list = listController.shoppingLists.firstWhere((x) => x.id == listId);
      switch (action) {
        case "ItemChanged": //Id, Amount, action
          var id = int.parse(data["id"]);
          var items = ref.watch(shoppingItemsProvider.notifier);
          var newState = items.state.toList();
          var item = newState.firstWhere((x) => x.id == id);
          newState.remove(item);
          newState.add(item.cloneWith(newAmount: int.parse(data["amount"])));
          items.state = newState;
          listController.save(list);
          break;
        case "ItemDeleted": //Id, action
          var id = int.parse(data["id"]);
          listController.deleteSingleItemById(list, id);
          break;
        case "NewItemAdded": //Id, Name, Gtin, Amount, action
          var newItemId = int.parse(data["id"]);
          var existing = ref.read(shoppingItemProvider(newItemId));
          if (existing != null) break;

          listController.addSingleItem(
            list,
            ShoppingItem(
              data["name"],
              list.id,
              int.parse(data["sortOrder"]),
              id: int.parse(data["id"]),
              amount: int.parse(data["amount"]),
              crossedOut: false,
            ),
          );
          break;
        case "ListRename": //Name, action
          listController.rename(list.id, data["name"] as String);
          break;
        case "Refresh": //action
          listController.refresh(list);
          break;
        case "ItemRenamed": //product.Id, product.Name
          var itemId = int.parse(data["id"]);
          var items = ref.watch(shoppingItemsProvider.notifier);
          var newState = items.state.toList();
          var item = newState.firstWhere((x) => x.id == itemId);
          newState.remove(item);
          newState.add(item.cloneWith(newName: data["name"]));
          items.state = newState;
          listController.save(list);
          break;
        case "OrderChanged":
          var itemId = int.parse(data["id"]);
          var items = ref.watch(shoppingItemsProvider.notifier);
          var newState = items.state.toList();
          var item = newState.firstWhere((x) => x.id == itemId);
          newState.remove(item);
          newState.add(
            item.cloneWith(
              newAmount: int.parse(data["amount"]),
              newSortOrder: int.parse(data["sortOrder"]),
            ),
          );
          items.state = newState;
          listController.save(list);
          break;
      }
    }

    return null;
  }
}
