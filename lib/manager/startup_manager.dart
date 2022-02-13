import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nssl/firebase/cloud_messsaging.dart';
import 'package:nssl/manager/database_manager.dart';
import 'package:nssl/models/model_export.dart';
import 'package:nssl/options/themes.dart';
import 'package:nssl/server_communication/return_classes.dart';
import 'package:nssl/server_communication/s_c.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file/local.dart';

class Startup {
  static SharedPreferences? sharedPreferences;
  static List<RemoteMessage> remoteMessages = <RemoteMessage>[];
  static const LocalFileSystem fs = const LocalFileSystem();

  static Future<bool> initializeMinFunction() async {
    if (!Platform.isAndroid) return true;
    return Firebase.initializeApp()
        .then((value) async => await ScanditFlutterDataCaptureBarcode.initialize())
        .then((value) => true);
  }

  static Future<void> loadMessagesFromFolder(Function setState) async {
    var dir = await Startup.fs.systemTempDirectory.childDirectory("message").create();
    var subFiles = dir.listSync();
    if (subFiles.length == 0) return;
    subFiles.sort((a, b) => a.basename.compareTo(b.basename));
    subFiles
        .where((event) => Startup.fs.isFileSync(event.path))
        .map((event) => Startup.fs.file(event.path))
        .forEach((subFile) {
      var str = subFile.readAsStringSync();
      var remoteMessage = RemoteMessage(data: jsonDecode(str));
      CloudMessaging.onMessage(remoteMessage, setState);
      subFile.delete();
    });
  }

  static Future<void> deleteMessagesFromFolder() async {
    var dir = await Startup.fs.systemTempDirectory.childDirectory("message").create();
    var subFiles = dir.listSync();
    if (subFiles.length == 0) return;
    subFiles
        .where((event) => Startup.fs.isFileSync(event.path))
        .map((event) => Startup.fs.file(event.path))
        .forEach((subFile) {
      subFile.delete();
    });
  }

  static Future<bool> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    var f1 = initializeMinFunction();
    await DatabaseManager.initialize();
    await User.load();

    if (User.username == null || User.username == "" || User.eMail == null || User.eMail == "") return false;
    await Themes.loadTheme();

    User.shoppingLists = await ShoppingList.load();
    if (User.shoppingLists.length == 0) return true;
    User.currentList =
        User.shoppingLists.firstWhere((x) => x.id == User.currentListIndex, orElse: () => User.shoppingLists.first);
    await f1;
    return true;
  }

  static Future initializeNewListsFromServer() async {
    var res = await ShoppingListSync.getLists(null);

    if (res.statusCode == 200) {
      var result = GetListsResult.fromJson(res.body);

      User.shoppingLists.clear();
      await DatabaseManager.database.rawDelete("DELETE FROM ShoppingLists where user_id = ?", [User.ownId]);

      var crossedOut =
          (await DatabaseManager.database.rawQuery("SELECT id, crossed FROM ShoppingItems WHERE crossed = 1"));
      result.shoppingLists.forEach((resu) {
        var list = ShoppingList(resu.id, resu.name)..shoppingItems = <ShoppingItem?>[];

        for (var item in resu.products!)
          list.shoppingItems!.add(ShoppingItem(item.name)
            ..id = item.id
            ..amount = item.amount
            ..crossedOut =
                (crossedOut.firstWhere((x) => x["id"] == item.id, orElse: () => {"crossed": 0})["crossed"] == 0
                    ? false
                    : true));
        User.shoppingLists.add(list);
        list.save();
      });
    }
    User.currentList =
        User.shoppingLists.firstWhere((x) => x.id == User.currentListIndex, orElse: () => User.shoppingLists.first);

    return true;
  }
}
