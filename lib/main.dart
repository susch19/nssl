import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nssl/options/themes.dart';
import 'package:nssl/pages/pages.dart';
import 'package:nssl/manager/manager_export.dart';
import 'package:nssl/models/model_export.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/firebase/cloud_messsaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
      };
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Startup.initializeMinFunction();
  //Startup.remoteMessages.add(message);
  var dir = await Startup.fs.systemTempDirectory.childDirectory("message").create();
  var file = dir.childFile(DateTime.now().microsecondsSinceEpoch.toString());
  await file.writeAsString(jsonEncode(message.data));
}

Future<void> main() async {
// iWonderHowLongThisTakes();

  runApp(FutureBuilder(
    builder: (c, t) {
      if (t.connectionState == ConnectionState.done)
        return NSSLPage();
      else
        return Container(color: Colors.green);
    },
    future: Startup.initialize()
        .then((value) => FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler)),
  ));
}

class NSSL extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NSSLPage();
  }
}

class NSSLPage extends StatefulWidget {
  NSSLPage({Key? key}) : super(key: key);

  static _NSSLState? state;
  @override
  _NSSLState createState() {
    var localState = new _NSSLState();
    state = localState;
    return localState;
  }
}

class _NSSLState extends State<NSSLPage> {
  _NSSLState() : super();
  final GlobalKey<ScaffoldState> _mainScaffoldKey = GlobalKey<ScaffoldState>();

  String ean = "";
  bool performanceOverlay = false;
  bool materialGrid = false;

  @override
  void initState() {
    super.initState();

    subscribeFirebase(context);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      CloudMessaging.onMessage(message, setState);
    });

    FirebaseMessaging.onMessage.listen((event) {
      CloudMessaging.onMessage(event, setState);
    });
    // FirebaseMessaging.onBackgroundMessage((message) async {
    //   return;
    // });
    // FirebaseMessaging.onBackgroundMessage((message) => CloudMessaging.onMessage(message, setState));
    // firebaseMessaging.configure(
    //     onMessage: (x) => CloudMessaging.onMessage(x, setState), onLaunch: (x) => Startup.initialize());
    for (var list in User.shoppingLists) if (list.messagingEnabled) list.subscribeForFirebaseMessaging();
  }

  Future subscribeFirebase(BuildContext context) async {
    if (!Platform.isAndroid) return;

    var initMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initMessage != null) {
      CloudMessaging.onMessage(initMessage, setState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
        light: Themes.lightTheme.theme!,
        dark: Themes.darkTheme.theme,
        initial: AdaptiveThemeMode.system,
        builder: (theme, darkTheme) => MaterialApp(
              scrollBehavior: CustomScrollBehavior(),
              title: 'NSSL',
              color: Colors.grey[500],
              localizationsDelegates: <LocalizationsDelegate<dynamic>>[
                new _NSSLLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: const <Locale>[
                const Locale('en', 'US'),
                const Locale('de', 'DE'),
              ],
              theme: theme,
              darkTheme: darkTheme,
              home: User.username == null ? mainAppLoginRegister() : mainAppHome(),
              routes: <String, WidgetBuilder>{
                '/login': (BuildContext context) => LoginPage(),
                '/registration': (BuildContext context) => Registration(),
                '/search': (BuildContext context) => ProductAddPage(),
                '/forgot_password': (BuildContext context) => CustomThemePage(),
              },
              showPerformanceOverlay: performanceOverlay,
              showSemanticsDebugger: false,
              debugShowMaterialGrid: materialGrid,
            ));
  }

  Scaffold mainAppHome() => Scaffold(
      key: _mainScaffoldKey, resizeToAvoidBottomInset: false, body: MainPage() //CustomThemePage()//LoginPage(),
      );

  Scaffold mainAppLoginRegister() => Scaffold(
        key: _mainScaffoldKey,
        resizeToAvoidBottomInset: false,
        body: LoginPage(),
      );
}

class _NSSLLocalizationsDelegate extends LocalizationsDelegate<NSSLStrings> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<NSSLStrings> load(Locale locale) => NSSLStrings.load(locale);

  @override
  bool shouldReload(_NSSLLocalizationsDelegate old) => false;
}
