import 'dart:async';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:nssl/localization/nssl_strings.dart';
import 'package:nssl/options/themes.dart';

class CustomThemePage extends StatefulWidget {
  CustomThemePage();

  @override
  CustomThemePageState createState() => CustomThemePageState();
}

class CustomThemePageState extends State<CustomThemePage> {
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  CustomThemePageState();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _saveNeeded = false;
  TextEditingController tec = TextEditingController();

  MaterialColor primary = Colors.blue;
  MaterialAccentColor accent  = Colors.tealAccent;
  Brightness? primaryBrightness = Brightness.dark;
  Brightness? accentBrightness = Brightness.dark;

  ThemeData? td;

  double primaryColorSlider = 0.0;
  double accentColorSlider = 0.0;
  bool? primaryColorCheckbox = false;
  bool accentColorCheckbox = true;

  Future<bool> _onWillPop() async {
    if (!_saveNeeded) return true;

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle = theme.textTheme.subtitle1!.copyWith(color: theme.textTheme.caption!.color);

    return await (showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: Text(NSSLStrings.of(context)!.discardNewTheme(), style: dialogTextStyle),
            actions: <Widget>[
              TextButton(
                  child: Text(NSSLStrings.of(context)!.cancelButton()),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  }),
              TextButton(
                  child: Text(NSSLStrings.of(context)!.discardButton()),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  }),
            ],
          ),
        )) ??
        false;
  }

  void _handleSubmitted() {
    Themes.saveTheme(td!, primary, accent);
    if (td!.brightness == Brightness.dark) {
      AdaptiveTheme.of(context).setThemeMode(AdaptiveThemeMode.dark);
      Themes.darkTheme = NSSLThemeData(td, primaryColorSlider.round(), accentColorSlider.round());
    } else {
      AdaptiveTheme.of(context).setThemeMode(AdaptiveThemeMode.light);
      Themes.lightTheme = NSSLThemeData(td, primaryColorSlider.round(), accentColorSlider.round());
    }
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (td == null) {
      var darkTheme = Themes.tm == ThemeMode.system
          ? MediaQuery.of(context).platformBrightness == Brightness.dark
          : Themes.tm == ThemeMode.dark;
      // print(Themes.tm);
      td = darkTheme ? Themes.darkTheme.theme : Themes.lightTheme.theme;
      primaryColorCheckbox = darkTheme;
      primary =
          Colors.primaries[darkTheme ? Themes.darkTheme.primarySwatchIndex! : Themes.lightTheme.primarySwatchIndex!];
      accent = Colors.accents[darkTheme ? Themes.darkTheme.accentSwatchIndex! : Themes.lightTheme.accentSwatchIndex!];

      primaryBrightness = td!.brightness;
      primaryColorSlider = Colors.primaries.indexOf(primary).toDouble();
      accentColorSlider = Colors.accents.indexOf(accent).toDouble();
    }

    // var textColorTheme = TextStyle(color: td.textTheme.headline6.color);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.save,
            // color: td.accentIconTheme.color,
          ),
          // backgroundColor: td.accentColor,
          onPressed: _handleSubmitted),
      // backgroundColor: td.scaffoldBackgroundColor,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(NSSLStrings.of(context)!.changeTheme()
            // , style: textColorTheme
            ),
        // backgroundColor: td.primaryColor,
        // iconTheme: td.iconTheme,
        // textTheme: td.textTheme,
      ),
      body: Form(
          key: _formKey,
          onWillPop: _onWillPop,
          child: ListView(padding: const EdgeInsets.all(16.0), children: <Widget>[
            Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Text(
                NSSLStrings.of(context)!.changePrimaryColor(),
                // style: td.textTheme.subtitle1,
              ),
              Slider(
                value: primaryColorSlider,
                max: (Colors.primaries).length.ceilToDouble() - 1.0,
                divisions: Colors.primaries.length - 1,
                onChanged: onChangedPrimarySlider,
                // activeColor: td.accentColor,
              ),
            ]),
            Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Text(
                NSSLStrings.of(context)!.changeAccentColor(),
                //  style: td.textTheme.subtitle1,
              ),
              Slider(
                value: accentColorSlider,
                max: Colors.accents.length.ceilToDouble() - 1.0,
                divisions: Colors.accents.length - 1,
                onChanged: onChangedSecondarySlider,
                // activeColor: td.accentColor
              ),
            ]),
            Row(children: [
              Text(
                NSSLStrings.of(context)!.changeDarkTheme(),
                // style: td.textTheme.subtitle1,
              ),
              Checkbox(
                value: primaryColorCheckbox,
                onChanged: primaryBrightnessChange,
                // activeColor: td.accentColor,
              ),
            ]),
            // Row(children: [
            //   Text(
            //     NSSLStrings.of(context).changeAccentTextColor(),
            //     // style: td.textTheme.subtitle1,
            //   ),
            //   Checkbox(
            //     value: accentColorCheckbox,
            //     onChanged: secondaryBrightnessChange,
            //     // activeColor: td.accentColor,
            //   ),
            // ]),
            // Row(children: [
            //   Text('Demo', style: textColorTheme),
            //   Checkbox(value: true, onChanged: (v) {}, activeColor: td.accentColor),
            // ]),
            // ColorPicker(
            //   pickerColor: pickerColor,
            //   onColorChanged: changeColor,
            //   enableLabel: true,
            //   pickerAreaHeightPercent: 0.8,
            // ),
          ])),
    );
  }

  void onChangedPrimarySlider(double value) {
    int index = value.round();
    primaryColorSlider = value;
    primary = Colors.primaries[index];
    setColors();
  }

  void onChangedSecondarySlider(double value) {
    int index = value.round();
    accentColorSlider = value;
    accent = Colors.accents[index];
    // accent = Colors.greenAccent;
    setColors();
  }

  void setColors() {
    _saveNeeded = true;
    // print(primary);
    // print(accent);
    // print(primaryBrightness);
    // print(accentBrightness);
    if (primaryBrightness == Brightness.light)
      td = ThemeData(
        brightness: primaryBrightness,
        primarySwatch: primary,
        secondaryHeaderColor: accent,
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: accent.shade400),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateColor.resolveWith(
            (s) {
              if (s.contains(MaterialState.selected)) {
                return accent.shade200;
              }
              return Colors.black;
            },
          ),
        ),
      );
    else
      td = ThemeData(
        brightness: primaryBrightness,
        primarySwatch: primary,
        secondaryHeaderColor: accent,
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: accent.shade100),
        checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateColor.resolveWith((states) {
            return Colors.black;
          }),
          fillColor: MaterialStateColor.resolveWith(
            (s) {
              if (s.contains(MaterialState.selected)) {
                return accent.shade200;
              }
              return Colors.black;
            },
          ),
        ),
      );

    AdaptiveTheme.of(context).setTheme(light: td!, dark: td);
  }

  void primaryBrightnessChange(bool? value) {
    primaryColorCheckbox = value;
    primaryBrightness = value! ? Brightness.dark : Brightness.light;
    setColors();
  }

  void secondaryBrightnessChange(bool value) {
    accentColorCheckbox = value;
    accentBrightness = value ? Brightness.dark : Brightness.light;
    setColors();
  }

  // buildBody() {
  //   return Scaffold(
  //       appBar: AppBar(
  //         title: const Text("Theme"),
  //       ),
  //       floatingActionButton: FloatingActionButton(
  //         onPressed: () => {},
  //         child: IconButton(
  //           icon: Icon(Icons.search),
  //           onPressed: () {},
  //         ),
  //       ),
  //       body: ListView(
  //         children: <Widget>[
  //           ElevatedButton(
  //             onPressed: () {},
  //             child: const Text("Theme"),
  //           ),
  //           Divider(),
  //           TextButton(
  //             onPressed: () {},
  //             child: const Text("Theme"),
  //           ),
  //           Divider(),
  //           TextField(
  //             controller: tec,
  //           ),
  //         ],
  //       ),
  //       persistentFooterButtons: [TextButton(child: const Text("Theme"), onPressed: () {})]);
  // }
}
