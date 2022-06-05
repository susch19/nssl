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
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file/local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  static Future<void> loadMessagesFromFolder(WidgetRef ref) async {
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
      ref.read(cloudMessagingProvider);
      CloudMessaging.onMessage(remoteMessage);
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

  static Future<bool> initialize(WidgetRef ref) async {
    WidgetsFlutterBinding.ensureInitialized();
    var f1 = initializeMinFunction();
    await DatabaseManager.initialize();
    var user = await ref.read(userFromDbProvider.future);

    if (user == null || user.username == "" || user.eMail == "") return false;
    ref.read(themeProvider);
    await Themes.loadTheme();

    var provider = ref.read(shoppingListsProvider);
    await provider.load();

    await f1;
    return true;
  }

  static Future initializeNewListsFromServer(WidgetRef ref) async {
    var provider = ref.read(shoppingListsProvider);
    await provider.reloadAllLists();

    return true;
  }
}
