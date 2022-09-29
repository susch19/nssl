import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:nssl/main.dart';
import 'package:nssl/manager/database_manager.dart';
import 'package:nssl/server_communication/jwt.dart';
import 'package:riverpod/riverpod.dart';

final userFromDbProvider = FutureProvider<User?>((ref) async {
  ref.watch(appRestartProvider);
  var list = (await DatabaseManager.database.rawQuery("SELECT * FROM User LIMIT 1"));
  if (list.length == 0) return null;
  var z = list.first;
  var username = z["username"] as String;
  var eMail = z["email"] as String;
  var token = z["token"] as String;
  var ownId = await JWT.getIdFromToken(token);
  var currentListIndex = z["current_list_index"] as int;
  var containsOwnId = z.containsKey("own_id");
  if (!containsOwnId) {
    await DatabaseManager.database.execute("DROP TABLE User");
    await DatabaseManager.database.execute(
        "CREATE TABLE User (own_id INTEGER, username TEXT, email TEXT, token TEXT, current_list_index INTEGER)");
  } else
    ownId = z["own_id"] as int;
  User.token = token;
  var user = User(ownId, username, eMail);
  ref.watch(currentListIndexProvider.notifier).state = currentListIndex;

  if (!containsOwnId) user.save(currentListIndex);
  return user;
});

final userStateProvider = StateProvider<User>((ref) {
  return User.empty;
});

final userProvider = Provider<User>((ref) {
  var fromDb = ref.watch(userFromDbProvider);
  var fromState = ref.watch(userStateProvider);
  if (fromState.ownId == -1 && !fromDb.hasError && !fromDb.isLoading && fromDb.hasValue) {
    return fromDb.valueOrNull ?? fromState;
  }
  return fromState;
});

final userIdProvider = Provider<int?>((ref) {
  return ref.watch(userProvider).ownId;
});

final currentListIndexProvider = StateProvider<int?>((ref) {
  return null;
});

@immutable
class User {
  static User empty = const User(-1, "", "");

  final String username;
  final String eMail;
  // final List<ShoppingList> shoppingLists = <ShoppingList>[];
  static String token = "";
  final int ownId;

  @override
  bool operator ==(final Object other) =>
      other is User && other.username == username && other.eMail == eMail && other.ownId == ownId;

  @override
  int get hashCode => Object.hash(username, eMail, ownId);

  const User(this.ownId, this.username, this.eMail);

  // static Future load() async {
  //   var list = (await DatabaseManager.database.rawQuery("SELECT * FROM User LIMIT 1"));
  //   if (list.length == 0) return;
  //   var z = list.first;
  //   User.username = z["username"] as String?;
  //   User.eMail = z["email"] as String?;
  //   User.token = z["token"] as String?;
  //   User.currentListIndex = z["current_list_index"] as int?;
  //   if (!z.containsKey("own_id")) {
  //     await DatabaseManager.database.execute("DROP TABLE User");
  //     await DatabaseManager.database.execute(
  //         "CREATE TABLE User (own_id INTEGER, username TEXT, email TEXT, token TEXT, current_list_index INTEGER)");
  //     User.ownId = await JWT.getIdFromToken(User.token);
  //     await save();
  //   } else
  //     User.ownId = z["own_id"] as int?;
  // }

  Future save(int? currentListIndex) async {
    await DatabaseManager.database.rawDelete("DELETE FROM User");
    await DatabaseManager.database.execute(
        "INSERT INTO User(own_id, username, email, token, current_list_index) VALUES(?, ?, ?, ?, ?)",
        [ownId, username, eMail, token, currentListIndex]);
  }

  Future delete() async {
    await DatabaseManager.database.rawDelete("DELETE FROM User where own_id = ?", [ownId]);
    await DatabaseManager.database.rawDelete(
        "DELETE FROM ShoppingItems where res_list_id in( SELECT id FROM ShoppingLists where user_id = ?)", [ownId]);
    await DatabaseManager.database.rawDelete("DELETE FROM ShoppingLists where user_id = ?", [ownId]);
  }
}
