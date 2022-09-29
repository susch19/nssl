import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/options/themes.dart';
import 'package:nssl/pages/pages.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage();

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(NSSLStrings.of(context).settings()),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back)),
      ),
      body: ListView(children: [
        ListTile(
          leading: Icon(Icons.palette),
          title: Text(NSSLStrings.of(context).changeTheme()),
          onTap: () {
            Navigator.push(
                    context,
                    MaterialPageRoute<DismissDialogAction>(
                      builder: (BuildContext context) => CustomThemePage(),
                      fullscreenDialog: true,
                    ))
                .whenComplete(() => AdaptiveTheme.of(context)
                    .setTheme(light: Themes.lightTheme.theme!, dark: Themes.darkTheme.theme, notify: true));
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.info),
          title: Text(NSSLStrings.of(context).about()),
          onTap: () => Navigator.push(
              context, MaterialPageRoute<DismissDialogAction>(builder: (c) => AboutPage(), fullscreenDialog: true)),
        ),
      ]),
    );
  }
}
