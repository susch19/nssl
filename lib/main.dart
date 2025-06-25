import 'dart:convert';
import 'dart:ui';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nssl/options/themes.dart';
import 'package:nssl/pages/forgot_password.dart';
import 'package:nssl/pages/pages.dart';
import 'package:nssl/manager/manager_export.dart';
import 'package:nssl/models/model_export.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/firebase/cloud_messsaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
  };
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Startup.initializeMinFunction();
  var dir = await Startup.fs.systemTempDirectory
      .childDirectory("message")
      .create();
  var file = dir.childFile(DateTime.now().microsecondsSinceEpoch.toString());
  await file.writeAsString(jsonEncode(message.data));
}

final appRestartProvider = StateProvider<int>((ref) => 0);

Future<void> main() async {
  // iWonderHowLongThisTakes();
  runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          return EagerInitialize(
            FutureBuilder(
              builder: (c, t) {
                if (t.connectionState == ConnectionState.done) {
                  ref.watch(appRestartProvider);
                  return NSSLPage();
                } else
                  return MaterialApp(
                    builder: (context, child) {
                      return Center(
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: SvgPicture.asset(
                            "assets/vectors/app_icon.svg",
                          ),
                        ),
                      );
                    },
                  );
              },
              future: Startup.initialize(ref).then(
                (value) => FirebaseMessaging.onBackgroundMessage(
                  _firebaseMessagingBackgroundHandler,
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

class EagerInitialize extends ConsumerWidget {
  final Widget child;

  const EagerInitialize(this.child);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeProvider);
    ref.watch(cloudMessagingProvider);

    return child;
  }
}

class NSSL extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NSSLPage();
  }
}

class NSSLPage extends ConsumerStatefulWidget {
  NSSLPage({Key? key}) : super(key: key);

  @override
  _NSSLState createState() => _NSSLState();
}

class _NSSLState extends ConsumerState<NSSLPage> {
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
      ref.read(cloudMessagingProvider.notifier).onMessage(message);
    });

    FirebaseMessaging.onMessage.listen((event) {
      ref.read(cloudMessagingProvider.notifier).onMessage(event);
    });

    for (var list in ref.read(shoppingListsProvider).shoppingLists)
      if (list.messagingEnabled) list.subscribeForFirebaseMessaging();
  }

  Future subscribeFirebase(BuildContext context) async {
    if (!Startup.firebaseSupported()) return;
    var initMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initMessage != null) {
      ref.read(cloudMessagingProvider.notifier).onMessage(initMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = ref.watch(userProvider);

    return AdaptiveTheme(
      light: Themes.lightTheme.theme!,
      dark: Themes.darkTheme.theme,
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        scrollBehavior: CustomScrollBehavior(),
        title: 'NSSL',
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          new _NSSLLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[
          const Locale('en', ''),
          const Locale('de', ''),
        ],
        theme: theme,
        darkTheme: darkTheme,
        debugShowMaterialGrid: materialGrid,
        home: user.ownId >= 0 ? mainAppHome() : mainAppLoginRegister(),
        routes: <String, WidgetBuilder>{
          '/login': (BuildContext context) => LoginPage(),
          '/registration': (BuildContext context) => Registration(),
          '/search': (BuildContext context) => ProductAddPage(),
          '/forgot_password': (BuildContext context) => ForgotPasswordPage(),
        },
        showPerformanceOverlay: performanceOverlay,
        showSemanticsDebugger: false,
      ),
      // debugShowMaterialGrid: materialGrid,
    );
  }

  Scaffold mainAppHome() => Scaffold(
    key: _mainScaffoldKey,
    resizeToAvoidBottomInset: false,
    body: MainPage(), //CustomThemePage()//LoginPage(),
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
