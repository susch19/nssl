import 'package:nssl/options/themes.dart';
import 'package:nssl/pages/pages.dart';
import 'package:nssl/manager/manager_export.dart';
import 'package:nssl/models/model_export.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/firebase/cloud_messsaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
// iWonderHowLongThisTakes();
  Startup.initialize().then((s) {
    //if (s) Startup.initializeNewListsFromServer();
    runApp(new NSSLPage());
  });
}

class NSSL extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new NSSLPage();
  }
}

class NSSLPage extends StatefulWidget {
  NSSLPage({Key key}) : super(key: key);

  static _NSSLState state;
  @override
  _NSSLState createState() {
    state = new _NSSLState();
    return state;
  }
}

class _NSSLState extends State<NSSLPage> {
  _NSSLState() : super();
  final GlobalKey<ScaffoldState> _mainScaffoldKey = new GlobalKey<ScaffoldState>();

  String ean = "";
  bool performanceOverlay = false;
  bool materialGrid = false;

  @override
  initState() {
    super.initState();
    firebaseMessaging.configure(onMessage: (x) => CloudMessaging.onMessage(x, setState));
    for (var list in User.shoppingLists) if (list.messagingEnabled) list.subscribeForFirebaseMessaging();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
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
      theme: Themes.themes.first,
      home: User.username == null ? mainAppLoginRegister() : mainAppHome(),
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => new LoginPage(),
        '/registration': (BuildContext context) => new Registration(),
        '/search': (BuildContext context) => new ProductAddPage(),
        '/forgot_password': (BuildContext context) => new CustomThemePage(),
      },
      showPerformanceOverlay: performanceOverlay,
      showSemanticsDebugger: false,
      debugShowMaterialGrid: materialGrid,
    );
  }

  Scaffold mainAppHome() => new Scaffold(
      key: _mainScaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: new MainPage() //new CustomThemePage()//LoginPage(),
      );

  Scaffold mainAppLoginRegister() => new Scaffold(
        key: _mainScaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: new LoginPage(),
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